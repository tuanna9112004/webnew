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
            'header' => "Content-Type: application/json
",
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
    return in_array($paymentStatus, ['da_dat_coc', 'da_thanh_toan'], true);
}

function telegram_payment_status_label(string $paymentStatus): string
{
    return match ($paymentStatus) {
        'da_dat_coc' => 'Đã đặt cọc',
        'da_thanh_toan' => 'Đã thanh toán',
        default => $paymentStatus,
    };
}

function telegram_payment_plan_label(string $paymentPlan): string
{
    return match ($paymentPlan) {
        'deposit_30' => 'Thanh toán cọc',
        'full' => 'Thanh toán toàn bộ',
        'cod' => 'COD',
        default => $paymentPlan,
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

function build_order_telegram_message(array $order, ?array $payment = null): string
{
    $status = (string)($order['payment_status'] ?? '');
    $statusLabel = telegram_payment_status_label($status);
    $title = $status === 'da_thanh_toan' ? '💸 <b>Đơn hàng đã thanh toán</b>' : '💰 <b>Đơn hàng đã đặt cọc</b>';
    $customerName = trim((string)($order['contact_name'] ?? ($order['customer_name'] ?? 'Khách lẻ')));
    $phone = trim((string)($order['contact_phone'] ?? ''));
    $paymentPlan = telegram_payment_plan_label((string)($order['payment_plan'] ?? ''));
    $paidAmount = format_price((float)($order['paid_amount'] ?? 0));
    $remainingAmount = format_price((float)($order['remaining_amount'] ?? 0));
    $totalAmount = format_price((float)($order['total_amount'] ?? 0));
    $depositRequired = format_price((float)($order['deposit_required_amount'] ?? 0));
    $latestPaymentAmount = $payment ? format_price((float)($payment['paid_amount'] ?? 0)) : '';
    $paidAt = '';
    if ($payment && !empty($payment['confirmed_at'])) {
        $paidAt = (string)$payment['confirmed_at'];
    } elseif (!empty($payment['paid_at'])) {
        $paidAt = (string)$payment['paid_at'];
    } else {
        $paidAt = date('Y-m-d H:i:s');
    }

    $lines = [
        $title,
        '• <b>Mã đơn:</b> ' . telegram_escape_html((string)($order['order_code'] ?? '')),
        '• <b>Khách:</b> ' . telegram_escape_html($customerName),
    ];

    if ($phone !== '') {
        $lines[] = '• <b>SĐT:</b> ' . telegram_escape_html($phone);
    }

    $lines[] = '• <b>Trạng thái:</b> ' . telegram_escape_html($statusLabel);
    if ($paymentPlan !== '') {
        $lines[] = '• <b>Hình thức:</b> ' . telegram_escape_html($paymentPlan);
    }
    if ($latestPaymentAmount !== '') {
        $lines[] = '• <b>Vừa nhận:</b> ' . telegram_escape_html($latestPaymentAmount);
    }
    $lines[] = '• <b>Đã thanh toán:</b> ' . telegram_escape_html($paidAmount);
    $lines[] = '• <b>Còn lại:</b> ' . telegram_escape_html($remainingAmount);
    $lines[] = '• <b>Tổng đơn:</b> ' . telegram_escape_html($totalAmount);

    if ((float)($order['deposit_required_amount'] ?? 0) > 0) {
        $lines[] = '• <b>Mức cọc yêu cầu:</b> ' . telegram_escape_html($depositRequired);
    }

    $lines[] = '• <b>Thời gian:</b> ' . telegram_escape_html($paidAt);

    return implode("
", $lines);
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
    $message = build_order_telegram_message($order, $payment);
    $sendResult = telegram_send_message($message);
    if (!$sendResult['ok']) {
        return $sendResult;
    }

    $insertStmt = db()->prepare('INSERT INTO telegram_notification_logs (order_id, event_key, chat_id, message_text, sent_at) VALUES (?, ?, ?, ?, NOW())');
    $insertStmt->execute([$orderId, $paymentStatus, $chatId, $message]);

    return ['ok' => true, 'message' => 'sent'];
}
