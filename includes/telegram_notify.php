<?php

function telegram_notify_enabled(): bool
{
    return shop_setting_bool('telegram_notify_enabled', false);
}

function telegram_bot_token(): string
{
    return trim((string)shop_setting('telegram_bot_token', ''));
}

function telegram_chat_id(): string
{
    return trim((string)shop_setting('telegram_chat_id', ''));
}

function telegram_bot_username(): string
{
    return trim((string)shop_setting('telegram_bot_username', ''));
}

function ensure_telegram_notification_logs_table(): void
{
    db()->exec(
        'CREATE TABLE IF NOT EXISTS telegram_notification_logs (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            order_id INT UNSIGNED NOT NULL,
            event_key VARCHAR(64) NOT NULL,
            chat_id VARCHAR(64) NOT NULL,
            message_text TEXT NULL,
            sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_telegram_order_event_chat (order_id, event_key, chat_id),
            KEY idx_telegram_order_id (order_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
    );
}

function telegram_escape_html(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
}

function telegram_post_json(string $url, array $payload): array
{
    $json = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if ($json === false) {
        return ['ok' => false, 'status' => 0, 'body' => 'json_encode_failed'];
    }

    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
            CURLOPT_POSTFIELDS => $json,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_CONNECTTIMEOUT => 10,
        ]);
        $body = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($body === false) {
            return ['ok' => false, 'status' => $status, 'body' => $error ?: 'curl_failed'];
        }

        return ['ok' => $status >= 200 && $status < 300, 'status' => $status, 'body' => (string)$body];
    }

    $context = stream_context_create([
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/json\r\n",
            'content' => $json,
            'timeout' => 15,
            'ignore_errors' => true,
        ],
    ]);

    $body = @file_get_contents($url, false, $context);
    $status = 0;
    foreach (($http_response_header ?? []) as $headerLine) {
        if (preg_match('#^HTTP/\S+\s+(\d{3})#', (string)$headerLine, $m)) {
            $status = (int)$m[1];
            break;
        }
    }

    return ['ok' => $body !== false && $status >= 200 && $status < 300, 'status' => $status, 'body' => (string)($body ?: '')];
}

function telegram_send_message(string $text): array
{
    $token = telegram_bot_token();
    $chatId = telegram_chat_id();

    if (!telegram_notify_enabled()) {
        return ['ok' => false, 'message' => 'Telegram notification chưa được bật.'];
    }
    if ($token === '' || $chatId === '') {
        return ['ok' => false, 'message' => 'Thiếu Bot Token hoặc Chat ID Telegram.'];
    }

    $url = 'https://api.telegram.org/bot' . rawurlencode($token) . '/sendMessage';
    $payload = [
        'chat_id' => $chatId,
        'text' => $text,
        'parse_mode' => 'HTML',
        'disable_web_page_preview' => true,
    ];

    $result = telegram_post_json($url, $payload);
    if (!$result['ok']) {
        error_log('Telegram sendMessage failed: HTTP ' . ($result['status'] ?? 0) . ' | ' . ($result['body'] ?? ''));
        return ['ok' => false, 'message' => 'Gửi Telegram thất bại.'];
    }

    return ['ok' => true, 'message' => 'sent'];
}

function telegram_should_notify_payment_status(string $paymentStatus): bool
{
    return in_array($paymentStatus, ['da_dat_coc', 'da_thanh_toan', 'chua_thanh_toan'], true);
}

function telegram_payment_status_label(string $paymentStatus): string
{
    return match ($paymentStatus) {
        'da_dat_coc' => 'Đã đặt cọc',
        'da_thanh_toan' => 'Đã thanh toán',
        'chua_thanh_toan' => 'Chưa thanh toán',
        default => $paymentStatus,
    };
}

function get_latest_success_payment_for_order(int $orderId): ?array
{
    if (!table_exists('payments')) {
        return null;
    }

    $stmt = db()->prepare('SELECT * FROM payments WHERE order_id = ? AND payment_status = ? ORDER BY id DESC LIMIT 1');
    $stmt->execute([$orderId, 'success']);
    $row = $stmt->fetch();
    return $row ?: null;
}

function get_telegram_order_items_text(int $orderId): string
{
    $itemLines = [];

    try {
        // Query trực tiếp vào bảng order_items theo đúng schema của bạn
        $stmt = db()->prepare('SELECT product_name_snapshot, variant_name_snapshot, quantity FROM order_items WHERE order_id = ?');
        $stmt->execute([$orderId]);
        $items = $stmt->fetchAll();

        foreach ($items as $item) {
            $name = $item['product_name_snapshot'] ?? 'Sản phẩm';
            $variant = $item['variant_name_snapshot'] ?? '';
            $qty = $item['quantity'] ?? 1;
            
            $displayName = $name;
            if ($variant !== '') {
                $displayName .= ' (' . $variant . ')';
            }
            
            $itemLines[] = '  - ' . telegram_escape_html($displayName) . ' (x' . $qty . ')';
        }
    } catch (Throwable $e) {
        // Im lặng bỏ qua lỗi
    }

    return empty($itemLines) ? '  - (Chưa rõ chi tiết)' : implode("\n", $itemLines);
}

function build_order_telegram_message(array $order, ?array $payment = null, string $itemsText = ''): string
{
    // Lấy thông tin cơ bản (ưu tiên customer_name, fallback contact_name)
    $orderCode = telegram_escape_html((string)($order['order_code'] ?? ''));
    $customerName = telegram_escape_html(trim((string)($order['customer_name'] ?? ($order['contact_name'] ?? 'Khách lẻ'))));
    $phone = telegram_escape_html(trim((string)($order['contact_phone'] ?? '')));
    $totalAmount = format_price((float)($order['total_amount'] ?? 0));
    
    // Nối Tên và SĐT
    $customerInfo = $customerName;
    if ($phone !== '') {
        $customerInfo .= ' - ' . $phone;
    }

    // Logic lựa chọn thanh toán y hệt trong admin_order_view.php
    $paymentPlan = 'Thanh toán toàn bộ';
    if (isset($order['payment_method']) && strpos(strtolower($order['payment_method']), 'deposit') !== false) {
        $paymentPlan = 'Thanh toán tiền cọc';
    } elseif ((float)($order['deposit_required_amount'] ?? 0) > 0 && (float)$order['deposit_required_amount'] < (float)$order['total_amount']) {
        $paymentPlan = 'Thanh toán tiền cọc';
    } elseif (isset($order['payment_method']) && strpos(strtolower($order['payment_method']), 'cod') !== false) {
        $paymentPlan = 'COD';
    }

    $statusLabel = telegram_payment_status_label((string)($order['payment_status'] ?? ''));
    $paymentInfo = "($paymentPlan - $statusLabel)";
    
    // Thời gian thanh toán hoặc thời gian đặt hàng
    $paidAt = date('Y-m-d H:i:s');
    if ($payment && !empty($payment['created_at'])) {
        $paidAt = (string)$payment['created_at'];
    } elseif (!empty($order['placed_at'])) {
        $paidAt = (string)$order['placed_at'];
    } elseif (!empty($order['created_at'])) {
        $paidAt = (string)$order['created_at'];
    }

    $lines = [
        '📦 <b>ĐƠN HÀNG MỚI: ' . $orderCode . '</b>',
        '• <b>Khách:</b> ' . $customerInfo,
        '• <b>Giá trị:</b> ' . telegram_escape_html($totalAmount) . ' ' . telegram_escape_html($paymentInfo),
        '• <b>Sản phẩm:</b>' . "\n" . $itemsText,
        '• <b>Thời gian:</b> ' . telegram_escape_html($paidAt),
    ];

    return implode("\n", $lines);
}

function notify_order_payment_status_via_telegram(int $orderId): array
{
    if (!telegram_notify_enabled()) {
        return ['ok' => false, 'message' => 'telegram_disabled'];
    }

    $order = admin_get_order($orderId);
    if (!$order) {
        return ['ok' => false, 'message' => 'order_not_found'];
    }

    $paymentStatus = (string)($order['payment_status'] ?? '');
    if (!telegram_should_notify_payment_status($paymentStatus)) {
        return ['ok' => false, 'message' => 'status_not_supported'];
    }

    $chatId = telegram_chat_id();
    if ($chatId === '' || telegram_bot_token() === '') {
        return ['ok' => false, 'message' => 'telegram_not_configured'];
    }

    ensure_telegram_notification_logs_table();

    $checkStmt = db()->prepare('SELECT id FROM telegram_notification_logs WHERE order_id = ? AND event_key = ? AND chat_id = ? LIMIT 1');
    $checkStmt->execute([$orderId, $paymentStatus, $chatId]);
    if ($checkStmt->fetch()) {
        return ['ok' => true, 'message' => 'already_sent'];
    }

    $payment = get_latest_success_payment_for_order($orderId);
    $itemsText = get_telegram_order_items_text($orderId);

    $message = build_order_telegram_message($order, $payment, $itemsText);
    $sendResult = telegram_send_message($message);
    if (!$sendResult['ok']) {
        return $sendResult;
    }

    $insertStmt = db()->prepare('INSERT INTO telegram_notification_logs (order_id, event_key, chat_id, message_text, sent_at) VALUES (?, ?, ?, ?, NOW())');
    $insertStmt->execute([$orderId, $paymentStatus, $chatId, $message]);

    return ['ok' => true, 'message' => 'sent'];
}