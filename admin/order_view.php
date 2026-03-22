<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

$orderId = (int)($_GET['id'] ?? 0);
$order = $orderId > 0 ? admin_get_order($orderId) : null;

if (!$order) {
    http_response_code(404);
    exit('Không tìm thấy đơn hàng.');
}

// -------------------------------------------------------------
// ĐỊNH NGHĨA % CỌC MẶC ĐỊNH
// Bạn có thể đổi số 30 thành hàm lấy từ DB ví dụ: get_setting('default_deposit_rate')
// -------------------------------------------------------------
$defaultDepositRate = 30; 
if (isset($order['default_deposit_rate']) && $order['default_deposit_rate'] > 0) {
    $defaultDepositRate = (float)$order['default_deposit_rate'];
}
// -------------------------------------------------------------

$error = '';
$success = '';

$internalNoteColumn = null;
if (column_exists('orders', 'internal_note')) {
    $internalNoteColumn = 'internal_note';
} elseif (column_exists('orders', 'note')) {
    $internalNoteColumn = 'note';
}

if (is_post()) {
    verify_csrf_or_fail();
    $action = $_POST['action'] ?? 'update_status';

    if ($action === 'update_status') {
        try {
            $newOrderStatus = (string)($_POST['order_status'] ?? '');
            $newPaymentStatus = (string)($_POST['payment_status'] ?? '');
            $newPaymentPlan = (string)($_POST['payment_plan'] ?? '');
            $note = trim((string)($_POST['note'] ?? '')) ?: null;

            // Tương thích ngược nếu form gửi lên mã cũ
            if ($newPaymentPlan === 'deposit_30') $newPaymentPlan = 'deposit';

            // KIỂM TRA ĐIỀU KIỆN RÀNG BUỘC
            if ($newPaymentStatus === 'da_dat_coc' && $newPaymentPlan !== 'deposit') {
                throw new Exception('Chỉ được phép chọn Trạng thái "Đã đặt cọc" khi Hình thức thanh toán là "Cọc ' . $defaultDepositRate . '%".');
            }

            // 1. Cập nhật Trạng thái & Ghi chú
            admin_update_order_status($orderId, $newOrderStatus, $note);
            if ($newPaymentStatus !== '') {
                admin_update_order_payment_status($orderId, $newPaymentStatus);
            }

            // 2. Cập nhật trực tiếp số tiền & Hình thức thanh toán từ Form nhập liệu
            $newPaidAmount = isset($_POST['paid_amount']) ? (float)$_POST['paid_amount'] : (float)$order['paid_amount'];
            $total = (float)$order['total_amount'];
            
            $newRemainingAmount = $total - $newPaidAmount;
            if ($newRemainingAmount < 0) {
                $newRemainingAmount = 0;
            }

            // Cập nhật paid_amount, remaining_amount, payment_plan
            $stmtReset = db()->prepare("UPDATE orders SET paid_amount = ?, remaining_amount = ?, payment_plan = ?, updated_at = NOW() WHERE id = ?");
            $stmtReset->execute([$newPaidAmount, $newRemainingAmount, $newPaymentPlan, $orderId]);

            // 3. Cập nhật ghi chú nội bộ
            if ($internalNoteColumn !== null) {
                $stmt = db()->prepare("UPDATE orders SET {$internalNoteColumn} = ?, updated_at = NOW() WHERE id = ?");
                $stmt->execute([$note, $orderId]);
            }

            $_SESSION['success_msg'] = 'Đã cập nhật đơn hàng thành công!';
            redirect('/admin/order_view.php?id=' . $orderId);
        } catch (Throwable $e) {
            $error = $e->getMessage();
        }
    } elseif ($action === 'update_address') {
        try {
            $rName = trim((string)($_POST['receiver_name'] ?? ''));
            $rPhone = trim((string)($_POST['receiver_phone'] ?? ''));
            $aLine = trim((string)($_POST['address_line'] ?? ''));
            $wName = trim((string)($_POST['ward_name'] ?? ''));
            $dName = trim((string)($_POST['district_name'] ?? ''));
            $pName = trim((string)($_POST['province_name'] ?? ''));
            $cNote = trim((string)($_POST['customer_note'] ?? ''));

            $stmt = db()->prepare("UPDATE order_addresses SET receiver_name = ?, receiver_phone = ?, address_line = ?, ward_name = ?, district_name = ?, province_name = ? WHERE order_id = ?");
            $stmt->execute([$rName, $rPhone, $aLine, $wName, $dName, $pName, $orderId]);

            $stmt2 = db()->prepare("UPDATE orders SET customer_note = ?, updated_at = NOW() WHERE id = ?");
            $stmt2->execute([$cNote ?: null, $orderId]);

            $_SESSION['success_msg'] = 'Đã cập nhật địa chỉ thành công!';
            redirect('/admin/order_view.php?id=' . $orderId);
        } catch (Throwable $e) {
            $error = 'Lỗi cập nhật địa chỉ: ' . $e->getMessage();
        }
    }
}

// Hàm hỗ trợ lấy ảnh
function get_product_images_for_view($productId) {
    if (!$productId) return [];
    $images = [];
    try {
        $stmt = db()->prepare("SELECT image_url FROM product_images WHERE product_id = ? ORDER BY id ASC");
        $stmt->execute([$productId]);
        $images = $stmt->fetchAll(PDO::FETCH_COLUMN);
    } catch (Throwable $e) {}
    
    if (empty($images)) {
        try {
            $stmt = db()->prepare("SELECT image FROM products WHERE id = ?");
            $stmt->execute([$productId]);
            $img = $stmt->fetchColumn();
            if ($img) $images = [$img];
        } catch (Throwable $e) {}
    }

    $formattedImages = [];
    foreach ($images as $img) {
        if (empty($img)) continue;
        if (function_exists('resolve_media_url')) {
            $formattedImages[] = resolve_media_url($img);
        } else {
            $img = str_replace('\\', '/', $img);
            $formattedImages[] = (strpos($img, 'http') === 0) ? $img : '/' . ltrim($img, '/');
        }
    }
    return $formattedImages;
}

$items = get_order_items($orderId);
$address = get_order_address($orderId);
$payments = get_order_payments($orderId);
$intent = get_latest_payment_intent_for_order($orderId);

$statusMap = order_status_options();
$paymentMap = payment_status_options();

if (is_post() && isset($_POST['action']) && $_POST['action'] === 'update_status' && empty($error)) {
    $order = admin_get_order($orderId);
}

$currentOrderStatus = $statusMap[$order['order_status']] ?? [$order['order_status'], 'primary'];
$currentPaymentStatus = $paymentMap[$order['payment_status']] ?? [$order['payment_status'], 'info'];

$subtotalAmount = (float)($order['subtotal_amount'] ?? 0);
$shippingFee = (float)($order['shipping_fee'] ?? 0);
$discountAmount = (float)($order['discount_amount'] ?? 0);
$totalAmount = (float)($order['total_amount'] ?? 0);
$depositRequiredAmount = (float)($order['deposit_required_amount'] ?? 0);

if ($depositRequiredAmount <= 0) {
    // Tính số tiền cọc linh động theo tỷ lệ cấu hình
    $depositRequiredAmount = round($totalAmount * ($defaultDepositRate / 100));
}

$paidAmount = (float)($order['paid_amount'] ?? 0);
$remainingAmount = (float)($order['remaining_amount'] ?? 0);
$isFreeShipping = $shippingFee <= 0;

$paymentPlan = (string)($order['payment_plan'] ?? '');
if ($paymentPlan === 'deposit_30') $paymentPlan = 'deposit'; // Tương thích dữ liệu cũ

$internalNoteValue = $internalNoteColumn ? (string)($order[$internalNoteColumn] ?? '') : '';

$bankAccountNo = sepay_bank_account_no();
$intentAmount = (float)($intent['requested_amount'] ?? 0);

$isOrderClosed = in_array((string)$order['order_status'], ['da_giao', 'da_huy', 'tra_hang'], true);
$isFullyPaid = ((string)$order['payment_status'] === 'da_thanh_toan' || ($totalAmount > 0 && $paidAmount >= $totalAmount));

$canShowQr = false;
$qrTransferAmount = 0;
$paymentInstructionTitle = 'Thanh toán nhanh';
$qrTransferNote = trim((string)($intent['transfer_note'] ?? '')) ?: (string)$order['order_code'];

if ((string)$order['payment_status'] === 'chua_thanh_toan' && $paymentPlan === 'deposit') {
    $canShowQr = true; $qrTransferAmount = $depositRequiredAmount; $paymentInstructionTitle = 'Chuyển khoản tiền cọc'; $qrTransferNote = (string)$order['order_code'] . ' COC';
} elseif ((string)$order['payment_status'] === 'chua_thanh_toan' && $paymentPlan === 'full') {
    $canShowQr = true; $qrTransferAmount = $totalAmount; $paymentInstructionTitle = 'Chuyển khoản 100%';
} elseif ((string)$order['payment_status'] === 'da_dat_coc') {
    $canShowQr = true; $qrTransferAmount = $remainingAmount; $paymentInstructionTitle = 'Thanh toán còn lại'; $qrTransferNote = (string)$order['order_code'] . ' CON LAI';
}

if ($isOrderClosed || $isFullyPaid || $bankAccountNo === '' || $qrTransferAmount <= 0) $canShowQr = false;

$qrImageUrl = '';
if ($canShowQr) {
    if (!empty($intent['qr_image_url']) && $intentAmount == $qrTransferAmount) {
        $qrImageUrl = (string)$intent['qr_image_url'];
    } else {
        $qrImageUrl = sepay_qr_url($qrTransferAmount, $qrTransferNote);
    }
}

$shouldHighlightPendingQr = (!$isOrderClosed && in_array((string)$order['payment_status'], ['chua_thanh_toan', 'da_dat_coc'], true) && $canShowQr);

function render_import_link_for_order_item(?int $productId): string {
    if (!$productId) return '<span class="text-muted">-</span>';
    $stmt = db()->prepare('SELECT import_link FROM products WHERE id = ?');
    $stmt->execute([$productId]);
    $importLink = trim((string)$stmt->fetchColumn());
    if ($importLink === '') return '<span class="text-muted">-</span>';

    $isPhone = preg_match('/^[0-9\+\-\s\.]+$/', $importLink) && strlen(preg_replace('/[^0-9]/', '', $importLink)) >= 8;
    ob_start();
    echo '<div class="action-links-col">';
    if ($isPhone) {
        $cleanPhone = preg_replace('/[^0-9\+]/', '', $importLink);
        echo '<a class="badge badge-success link-action" href="tel:' . e($cleanPhone) . '">📞 ' . e($importLink) . '</a>';
        echo '<div class="action-btn-group">';
        echo '<a class="badge badge-info link-action" target="_blank" href="https://zalo.me/' . e($cleanPhone) . '">Zalo</a>';
        echo '<button type="button" class="btn-icon" onclick="copyText(this, ' . json_encode($cleanPhone) . ')" title="Copy SĐT"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></button>';
        echo '</div>';
    } else {
        $hrefUrl = (strpos($importLink, 'http') !== 0) ? 'https://' . $importLink : $importLink;
        $displayUrl = (strlen($importLink) > 15) ? substr($importLink, 0, 15) . '...' : $importLink;
        echo '<div class="action-btn-group">';
        echo '<a class="badge badge-light link-action" target="_blank" href="' . e($hrefUrl) . '">🔗 ' . e($displayUrl) . '</a>';
        echo '<button type="button" class="btn-icon" onclick="copyText(this, ' . json_encode($importLink) . ')" title="Copy Link"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></button>';
        echo '</div>';
    }
    echo '</div>';
    return ob_get_clean();
}

// Helpers Render Icons Form
function render_status_icon($key) {
    $k = strtolower($key);
    if (strpos($k, 'cho_xac_nhan') !== false || strpos($k, 'pending') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>';
    if (strpos($k, 'dang_chuan_bi') !== false || strpos($k, 'processing') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>';
    if (strpos($k, 'giao_hang') !== false || strpos($k, 'dang_giao') !== false || strpos($k, 'shipping') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>';
    if (strpos($k, 'da_giao') !== false || strpos($k, 'thanh_cong') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>';
    if (strpos($k, 'huy') !== false || strpos($k, 'cancel') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>';
    if (strpos($k, 'tra_hang') !== false || strpos($k, 'return') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 14 4 9 9 4"></polyline><path d="M20 20v-7a4 4 0 0 0-4-4H4"></path></svg>';
    return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle></svg>';
}

function render_payment_icon($key) {
    $k = strtolower($key);
    if (strpos($k, 'chua') !== false || strpos($k, 'unpaid') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>';
    if (strpos($k, 'dat_coc') !== false || strpos($k, 'deposit') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg>'; 
    if (strpos($k, 'da_thanh_toan') !== false || strpos($k, 'paid') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path><polyline points="9 12 11 14 15 10"></polyline></svg>';
    if (strpos($k, 'cho_hoan') !== false || strpos($k, 'refunding') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>';
    if (strpos($k, 'da_hoan') !== false || strpos($k, 'refunded') !== false) return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>';
    return '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle></svg>';
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>#<?= e($order['order_code']) ?> | Đơn Hàng</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-body: #f3f4f6;
            --bg-card: #ffffff;
            --text-main: #111827;
            --text-muted: #6b7280;
            --border-color: #e5e7eb;
            
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --primary-bg: #e0e7ff;
            
            --danger: #ef4444;
            --danger-hover: #dc2626;
            --danger-bg: #fee2e2;
            --danger-border: #fca5a5;
            
            --success: #10b981;
            --success-bg: #d1fae5;
            --success-border: #6ee7b7;
            
            --warning: #f59e0b;
            --warning-bg: #fef3c7;
            --warning-border: #fcd34d;
            
            --info: #0ea5e9;
            --info-bg: #e0f2fe;
            --info-border: #7dd3fc;
            
            --light-bg: #f9fafb;
            
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 14px;
            --radius-xl: 18px;
            
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.05), 0 2px 4px -2px rgb(0 0 0 / 0.05);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.05), 0 4px 6px -4px rgb(0 0 0 / 0.05);
        }

        /* RESET & BASE */
        *, *::before, *::after { box-sizing: border-box; }
        html, body { 
            height: 100vh; overflow: hidden; margin: 0; 
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; 
            background: var(--bg-body); color: var(--text-main); 
            -webkit-font-smoothing: antialiased; 
        }
        
        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #9ca3af; }

        /* BỐ CỤC CHÍNH */
        .app-layout { 
            display: flex; flex-direction: column; height: 100vh; 
            padding: 16px 24px; max-width: 1600px; margin: 0 auto; 
        }
        
        /* HEADER NAV */
        .top-nav { 
            display: flex; justify-content: space-between; align-items: center; 
            margin-bottom: 12px; flex-shrink: 0; 
        }
        .top-nav-left { display: flex; align-items: center; gap: 12px; }
        
        .back-btn { 
            background: #fff; border: 1px solid var(--border-color); 
            padding: 6px 12px; border-radius: var(--radius-sm); 
            font-weight: 600; font-size: 13px; color: var(--text-main); text-decoration: none; 
            display: flex; align-items: center; gap: 6px; 
            box-shadow: var(--shadow-sm); transition: all 0.2s ease;
        }
        .back-btn:hover { background: var(--light-bg); border-color: #d1d5db; transform: translateY(-1px); }
        
        .page-title { 
            font-size: 18px; font-weight: 800; margin: 0; color: var(--text-main); 
            display: flex; align-items: center; gap: 8px;
        }
        
        /* THÔNG BÁO ALERT */
        .alert { 
            padding: 8px 14px; border-radius: var(--radius-sm); 
            font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; margin: 0;
            animation: fadeIn 0.3s ease-out;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        .alert-success { background: var(--success-bg); color: #065f46; border: 1px solid var(--success-border); }
        .alert-danger { background: var(--danger-bg); color: #991b1b; border: 1px solid var(--danger-border); }

        /* GRID HỆ THỐNG */
        .dashboard-grid { 
            display: grid; 
            grid-template-columns: 320px minmax(380px, 1fr) 370px; 
            gap: 16px; flex-grow: 1; min-height: 0; 
        }
        .col { display: flex; flex-direction: column; gap: 16px; min-height: 0; }
        .col-scrollable { overflow-y: auto; padding-right: 4px; padding-bottom: 16px; } 

        /* CARDS */
        .card { 
            background: var(--bg-card); border-radius: var(--radius-lg); 
            box-shadow: var(--shadow-md); border: 1px solid var(--border-color);
            display: flex; flex-direction: column; overflow: hidden; flex-shrink: 0;
            transition: box-shadow 0.2s ease;
        }
        .card:hover { box-shadow: var(--shadow-lg); }
        
        .card-header { 
            padding: 12px 16px; border-bottom: 1px solid var(--border-color); 
            display: flex; justify-content: space-between; align-items: center; 
            background: var(--bg-card); z-index: 2;
        }
        .card-header h2 { 
            font-size: 13px; font-weight: 700; margin: 0; color: var(--text-main); 
            display: flex; align-items: center; gap: 6px; text-transform: uppercase; letter-spacing: 0.02em;
        }
        .card-header h2 svg { color: var(--text-muted); width: 16px; height: 16px; }
        .card-body { padding: 14px 16px; flex-grow: 1; display: flex; flex-direction: column; gap: 12px;}
        .card-body-scroll { padding: 0; overflow-y: auto; flex-grow: 1; min-height: 0;}

        /* BADGES */
        .badge { 
            padding: 3px 8px; font-size: 11px; font-weight: 700; border-radius: 9999px; 
            display: inline-flex; align-items: center; justify-content: center; gap: 4px;
            white-space: nowrap; border: 1px solid transparent; text-decoration: none;
        }
        .badge::before { content:''; width: 5px; height: 5px; border-radius: 50%; }
        .badge-warning { background: var(--warning-bg); color: #b45309; border-color: var(--warning-border);} .badge-warning::before { background: var(--warning); }
        .badge-success { background: var(--success-bg); color: #047857; border-color: var(--success-border);} .badge-success::before { background: var(--success); }
        .badge-danger { background: var(--danger-bg); color: #b91c1c; border-color: var(--danger-border);} .badge-danger::before { background: var(--danger); }
        .badge-primary { background: var(--primary-bg); color: var(--primary); border-color: #c7d2fe;} .badge-primary::before { background: var(--primary); }
        .badge-info { background: var(--info-bg); color: #0369a1; border-color: var(--info-border);} .badge-info::before { background: var(--info); }
        .badge-light { background: var(--light-bg); color: var(--text-muted); border-color: var(--border-color);} .badge-light::before { background: #9ca3af; }

        /* RADIO BUTTON GROUPS (GRID GỌN GÀNG) */
        .radio-btn-group { display: flex; flex-wrap: wrap; gap: 8px; }
        .radio-btn-group input[type="radio"] { display: none; }
        .radio-btn-group label {
            padding: 8px; font-size: 12px; font-weight: 600;
            border: 1px solid var(--border-color); border-radius: var(--radius-sm);
            cursor: pointer; transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1); color: var(--text-muted); 
            background: #fff; text-align: center; flex: 1 1 calc(50% - 8px); 
            display: flex; align-items: center; justify-content: center; gap: 6px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.02); user-select: none;
        }
        .radio-btn-group label:hover { border-color: var(--primary); color: var(--primary); background: #f8fafc; }
        .radio-btn-group input[type="radio"]:checked + label {
            background: var(--primary-bg); color: var(--primary); border-color: var(--primary);
            box-shadow: 0 2px 4px rgba(79, 70, 229, 0.15); transform: scale(0.98);
        }
        .radio-btn-group input[type="radio"]:disabled + label {
            opacity: 0.5; cursor: not-allowed; background: var(--bg-body); color: var(--text-muted); border-color: var(--border-color); box-shadow: none;
        }

        /* HIỆU ỨNG HIGHLIGHT THAY ĐỔI TRẠNG THÁI (MỚI) */
        .radio-btn-group label.status-old-highlight {
            background: var(--warning-bg) !important;
            color: #92400e !important;
            border-color: var(--warning) !important;
            border-style: dashed !important;
            opacity: 0.8;
        }
        .radio-btn-group input[type="radio"]:checked + label.status-new-highlight {
            background: var(--success-bg) !important;
            color: #065f46 !important;
            border-color: var(--success) !important;
            box-shadow: inset 0 0 0 1px var(--success), 0 2px 4px rgba(16, 185, 129, 0.2) !important;
            transform: scale(0.98);
        }

        /* INFO BLOCKS */
        .info-block { 
            background: var(--bg-card); border: 1px solid var(--border-color); 
            border-radius: var(--radius-md); padding: 12px; 
            box-shadow: var(--shadow-sm); transition: 0.2s;
        }
        .info-block:hover { border-color: #d1d5db; }
        .info-label { 
            font-size: 11px; color: var(--text-muted); font-weight: 600; 
            text-transform: uppercase; margin-bottom: 6px; display: flex; justify-content: space-between; align-items: center;
        }
        .info-val { 
            font-size: 13px; font-weight: 500; color: var(--text-main); 
            display: flex; align-items: flex-start; justify-content: space-between; gap: 8px; margin-bottom: 6px;
        }
        .info-val:last-child { margin-bottom: 0; }
        .info-val .text { word-break: break-word; flex: 1; line-height: 1.4; }
        .info-val strong { font-weight: 700; color: var(--text-main); }

        /* NÚT COPY & ICONS */
        .btn-action { 
            background: #fff; border: 1px solid var(--border-color); color: var(--text-muted); 
            padding: 3px 8px; font-size: 11px; font-weight: 600; border-radius: var(--radius-sm); 
            cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 4px;
            box-shadow: var(--shadow-sm); text-decoration: none;
        }
        .btn-action:hover { border-color: var(--primary); color: var(--primary); background: var(--primary-bg); }
        .btn-icon { 
            background: transparent; border: none; padding: 3px; border-radius: 4px; color: var(--text-muted); 
            cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center;
        }
        .btn-icon:hover { background: var(--border-color); color: var(--text-main); }
        .text-muted { color: var(--text-muted); }

        /* BẢNG SẢN PHẨM & GIAO DỊCH */
        .table { width: 100%; border-collapse: collapse; text-align: left; }
        .table th { 
            background: var(--light-bg); position: sticky; top: 0; 
            padding: 10px 16px; font-size: 11px; color: var(--text-muted); 
            text-transform: uppercase; font-weight: 700; border-bottom: 1px solid var(--border-color); 
            z-index: 1; letter-spacing: 0.05em;
        }
        .table td { 
            padding: 12px 16px; border-bottom: 1px solid var(--border-color); 
            font-size: 13px; vertical-align: middle; transition: background 0.1s;
        }
        .table tr:last-child td { border-bottom: none; }
        .table tr:hover td { background: #f8fafc; }
        
        .product-name { font-weight: 700; color: var(--text-main); font-size: 13px; display: block; margin-bottom: 4px; line-height: 1.3;}
        .product-code { 
            font-size: 11px; color: var(--primary); font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; 
            background: var(--primary-bg); padding: 2px 6px; border-radius: 4px; font-weight: 600; 
        }
        .action-links-col { display: flex; flex-direction: column; gap: 4px; }
        .action-btn-group { display: flex; gap: 4px; align-items: center; }

        /* BIÊN LAI THANH TOÁN */
        .receipt { background: #fff; padding: 0 16px 16px; }
        .summary-row { 
            display: flex; justify-content: space-between; align-items: center; padding: 8px 0; 
            border-bottom: 1px dashed var(--border-color); font-size: 13px;
        }
        .summary-row:last-child { border: none; }
        .summary-row .label { color: var(--text-muted); font-weight: 500; }
        .summary-row .val { color: var(--text-main); font-weight: 700; font-size: 14px;}
        .summary-row.total { border-top: 2px solid var(--border-color); border-bottom: none; margin-top: 6px; padding-top: 12px; align-items: flex-end;}
        .summary-row.total .val { color: var(--primary); font-size: 18px; font-weight: 900;}
        
        .highlight-box { 
            background: var(--light-bg); border: 1px solid var(--border-color); 
            border-radius: var(--radius-md); padding: 12px; margin-top: 12px;
        }
        
        /* FORM NHẬP LIỆU */
        .form-group { margin-bottom: 12px; }
        .form-group label.section-title { display: block; font-size: 11px; font-weight: 700; margin-bottom: 8px; color: var(--text-main); text-transform: uppercase; letter-spacing: 0.05em; }
        .form-control { 
            width: 100%; padding: 8px 12px; border: 1px solid var(--border-color); 
            border-radius: var(--radius-sm); font-size: 13px; font-weight: 500; 
            font-family: inherit; outline: none; background: #fff; 
            box-shadow: var(--shadow-sm); transition: all 0.2s;
        }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-bg); }
        .form-control:disabled { background: #f3f4f6; color: #9ca3af; cursor: not-allowed; }
        textarea.form-control { resize: vertical; min-height: 60px; }

        .btn-submit { 
            width: 100%; padding: 10px; background: var(--primary); color: #fff; 
            border: none; border-radius: var(--radius-sm); font-weight: 700; font-size: 14px; 
            cursor: pointer; transition: all 0.2s; box-shadow: var(--shadow-md); 
            display: flex; align-items: center; justify-content: center; gap: 6px; margin-top: 12px;
        }
        .btn-submit:hover { background: var(--primary-hover); transform: translateY(-1px); box-shadow: 0 4px 10px 0 rgba(79, 70, 229, 0.3); }

        .btn-qr { background: var(--info); box-shadow: 0 4px 6px -1px rgba(14, 165, 233, 0.3); margin-top: 12px; padding: 8px; font-size: 13px;}
        .btn-qr:hover { background: #0284c7; box-shadow: 0 10px 15px -3px rgba(14, 165, 233, 0.4); }

        /* HIỆU ỨNG NHẤN MẠNH NÚT QR KHI CHƯA THANH TOÁN (Pulse Effect) */
        @keyframes pulse-qr {
            0% { box-shadow: 0 0 0 0 rgba(14, 165, 233, 0.5); }
            70% { box-shadow: 0 0 0 10px rgba(14, 165, 233, 0); }
            100% { box-shadow: 0 0 0 0 rgba(14, 165, 233, 0); }
        }
        .pulse-anim { animation: pulse-qr 2s infinite; border: 2px solid #38bdf8; }

        /* MODALS */
        .modal-overlay { 
            position: fixed; top:0; left:0; right:0; bottom:0; 
            background: rgba(17, 24, 39, 0.6); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
            z-index: 9999; display: none; justify-content: center; align-items: center; 
            padding: 24px; opacity: 0; transition: opacity 0.3s ease; 
        }
        .modal-overlay.active { display: flex; opacity: 1; }
        .modal-content { 
            background: #fff; border-radius: var(--radius-xl); width: 100%; max-width: 500px; 
            max-height: 90vh; overflow-y: auto; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5); 
            transform: scale(0.95) translateY(10px); transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); 
        }
        .modal-overlay.active .modal-content { transform: scale(1) translateY(0); }
        .modal-header { 
            padding: 16px 20px; border-bottom: 1px solid var(--border-color); 
            display: flex; justify-content: space-between; align-items: center; 
            position: sticky; top: 0; background: rgba(255,255,255,0.95); backdrop-filter: blur(4px); z-index: 10;
        }
        .btn-close { 
            background: var(--light-bg); border: 1px solid var(--border-color); 
            width: 32px; height: 32px; border-radius: 50%; cursor: pointer; 
            display: flex; align-items: center; justify-content: center; color: var(--text-muted); 
            transition: 0.2s;
        }
        .btn-close:hover { background: var(--danger-bg); color: var(--danger); border-color: var(--danger-border); }
        .modal-body { padding: 20px; text-align: center; }

        @media (max-width: 1200px) {
            html, body { height: auto; overflow: auto; }
            .app-layout { height: auto; padding: 12px; }
            .dashboard-grid { grid-template-columns: 1fr; display: flex; flex-direction: column; }
            .col { min-height: auto; overflow: visible; padding-right: 0;}
            .card-body-scroll { overflow: visible; }
            .table th, .table td { padding: 10px; }
        }
    </style>
</head>
<body>

<div class="app-layout">
    
    <div class="top-nav">
        <div class="top-nav-left">
            <a href="<?= route_url('/admin/orders.php') ?>" class="back-btn">
                <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                Quay lại
            </a>
            <h1 class="page-title">
                Đơn hàng #<?= e($order['order_code']) ?>
                <span class="badge badge-<?= e($currentOrderStatus[1]) ?>" style="font-size: 12px; padding: 4px 10px; margin-left: 6px;"><?= e($currentOrderStatus[0]) ?></span>
            </h1>
        </div>
        <div class="top-nav-right">
            <?php if ($error): ?>
                <div class="alert alert-danger">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                    <?= e($error) ?>
                </div>
            <?php endif; ?>
            <?php if (isset($_SESSION['success_msg'])): ?>
                <div class="alert alert-success">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    <?= e($_SESSION['success_msg']) ?>
                </div>
                <?php unset($_SESSION['success_msg']); ?>
            <?php endif; ?>
        </div>
    </div>

    <div class="dashboard-grid">
        
        <div class="col col-left col-scrollable">
            <div class="card">
                <div class="card-header">
                    <h2><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg> Khách hàng</h2>
                </div>
                <div class="card-body">
                    
                    <div class="info-block">
                        <div class="info-label">Thông tin cơ bản</div>
                        <div class="info-val">
                            <span class="text">Tên khách: <strong><?= e($order['customer_name'] ?: $order['contact_name']) ?></strong></span>
                            <button type="button" class="btn-icon" onclick="copyText(this, '<?= e($order['customer_name'] ?: $order['contact_name']) ?>')"><svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></button>
                        </div>
                        <div class="info-val">
                            <span class="text">Điện thoại: <strong style="color: var(--primary); font-size: 14px;"><?= e($order['contact_phone']) ?></strong></span>
                            <button type="button" class="btn-icon" onclick="copyText(this, '<?= e($order['contact_phone']) ?>')"><svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></button>
                        </div>
                    </div>

                    <div class="info-block">
                        <div class="info-label">Chi tiết đặt hàng</div>
                        <div class="info-val">
                            <span class="text">Kênh đặt: <strong style="text-transform: capitalize;"><?= e($order['purchase_channel']) ?></strong></span>
                        </div>
                        <div class="info-val">
                            <span class="text">Thời gian: <strong><?= e(date('H:i - d/m/Y', strtotime($order['placed_at']))) ?></strong></span>
                        </div>
                    </div>

                    <?php if ($address): ?>
                        <div id="address_display" class="info-block">
                            <div class="info-label">
                                Địa chỉ giao hàng
                                <button type="button" class="btn-action" style="padding: 2px 6px; font-size: 10px;" onclick="toggleAddressEdit()">Sửa đổi</button>
                            </div>
                            <?php $fullAddressStr = $address['address_line'] . ', ' . $address['ward_name'] . ', ' . $address['district_name'] . ', ' . $address['province_name']; ?>
                            <div class="info-val">
                                <span class="text" style="font-size: 12px; line-height: 1.5; color: var(--text-main);"><?= e($fullAddressStr) ?></span>
                                <button type="button" class="btn-icon" style="align-self: flex-start; margin-top: -2px;" onclick="copyText(this, '<?= e($fullAddressStr) ?>')"><svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></button>
                            </div>
                        </div>

                        <div id="address_edit" class="info-block" style="display: none; border-color: var(--primary);">
                            <form method="post" style="margin:0;">
                                <?= csrf_field() ?>
                                <input type="hidden" name="action" value="update_address">
                                <div class="form-group" style="margin-bottom: 8px;">
                                    <input type="text" name="receiver_name" class="form-control" style="font-size:12px; padding: 6px 10px;" value="<?= e($address['receiver_name']) ?>" placeholder="Họ tên người nhận" required>
                                </div>
                                <div class="form-group" style="margin-bottom: 8px;">
                                    <input type="text" name="receiver_phone" class="form-control" style="font-size:12px; padding: 6px 10px;" value="<?= e($address['receiver_phone']) ?>" placeholder="Số điện thoại" required>
                                </div>
                                <div class="form-group" style="margin-bottom: 8px;">
                                    <input type="text" name="address_line" class="form-control" style="font-size:12px; padding: 6px 10px;" value="<?= e($address['address_line']) ?>" placeholder="Số nhà, tên đường" required>
                                </div>
                                <div class="form-group" style="margin-bottom: 8px;">
                                    <input type="text" name="ward_name" class="form-control" style="font-size:12px; padding: 6px 10px;" value="<?= e($address['ward_name']) ?>" placeholder="Phường/Xã" required>
                                </div>
                                <div class="form-group" style="margin-bottom: 8px;">
                                    <input type="text" name="district_name" class="form-control" style="font-size:12px; padding: 6px 10px;" value="<?= e($address['district_name']) ?>" placeholder="Quận/Huyện" required>
                                </div>
                                <div class="form-group" style="margin-bottom: 12px;">
                                    <input type="text" name="province_name" class="form-control" style="font-size:12px; padding: 6px 10px;" value="<?= e($address['province_name']) ?>" placeholder="Tỉnh/Thành phố" required>
                                </div>
                                <div style="display:flex; gap:6px;">
                                    <button type="submit" class="btn-submit" style="margin-top:0; padding: 6px; font-size: 12px; flex: 2;">Lưu Địa Chỉ</button>
                                    <button type="button" class="btn-action" style="flex: 1;" onclick="toggleAddressEdit()">Hủy</button>
                                </div>
                            </form>
                        </div>
                    <?php endif; ?>

                    <?php if (!empty($order['customer_note'])): ?>
                        <div class="info-block" style="background: var(--warning-bg); border-color: var(--warning-border);">
                            <div class="info-label" style="color: #b45309;">Khách hàng ghi chú</div>
                            <div class="info-val" style="color: #92400e; font-size: 12px; font-style: italic; font-weight: 500;">
                                "<?= nl2br(e($order['customer_note'])) ?>"
                            </div>
                        </div>
                    <?php endif; ?>

                </div>
            </div>
        </div>

        <div class="col col-center">
            
            <div class="card" style="flex: 2;">
                <div class="card-header">
                    <h2><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg> Danh sách sản phẩm</h2>
                </div>
                <div class="card-body-scroll">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th>Nguồn / Liên kết</th>
                                <th style="text-align:center;">SL</th>
                                <th style="text-align:right;">Đơn giá</th>
                                <th style="text-align:right;">Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($items as $item): ?>
                                <?php 
                                    $variantName = $item['variant_name_snapshot'] ?? $item['variant_name'] ?? ''; 
                                    $productImages = get_product_images_for_view(!empty($item['product_id']) ? (int)$item['product_id'] : null);
                                ?>
                                <tr>
                                    <td>
                                        <span class="product-name"><?= e($item['product_name_snapshot']) ?></span>
                                        <div style="display: flex; gap: 6px; align-items: center; flex-wrap: wrap; margin-top: 4px;">
                                            <span class="product-code"><?= e($item['product_code_snapshot']) ?></span>
                                            <?php if (!empty($variantName)): ?>
                                                <span style="font-size:11px; font-weight:600; color:var(--text-muted); background:var(--light-bg); padding:2px 6px; border-radius:4px; border: 1px solid var(--border-color);"><?= e($variantName) ?></span>
                                            <?php endif; ?>
                                            <?php if (!empty($productImages)): ?>
                                                <button type="button" class="btn-action" style="padding: 2px 6px; font-size: 10px;" onclick="openImageModal(<?= htmlspecialchars(json_encode($productImages)) ?>, '<?= htmlspecialchars(e($item['product_name_snapshot']), ENT_QUOTES) ?>')">📷 Xem ảnh</button>
                                            <?php endif; ?>
                                            <?php if (!empty($item['product_id'])): ?>
                                                <a href="<?= route_url('/product.php?id=' . (int)$item['product_id']) ?>" target="_blank" class="btn-action" style="padding: 2px 6px; font-size: 10px;">🌐 Web</a>
                                            <?php endif; ?>
                                        </div>
                                    </td>
                                    <td><?= render_import_link_for_order_item(!empty($item['product_id']) ? (int)$item['product_id'] : null) ?></td>
                                    <td style="text-align:center; font-weight:700; font-size:14px;"><?= (int)$item['quantity'] ?></td>
                                    <td style="text-align:right; color:var(--text-muted); font-size: 12px; font-weight: 500;"><?= format_price($item['final_unit_price']) ?></td>
                                    <td style="text-align:right; font-weight:700; color:var(--text-main); font-size: 14px;"><?= format_price($item['line_total']) ?></td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card" style="flex: 1; min-height: 200px;">
                <div class="card-header">
                    <h2><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="2" y="5" width="20" height="14" rx="2" ry="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg> Lịch sử giao dịch</h2>
                </div>
                <div class="card-body-scroll">
                    <?php if (!$payments): ?>
                        <div style="padding: 24px 16px; text-align: center; color: var(--text-muted); font-size: 13px; font-weight: 500;">
                            <svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" style="margin-bottom: 8px; opacity: 0.5;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg><br>
                            Chưa có giao dịch thanh toán nào được ghi nhận.
                        </div>
                    <?php else: ?>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Mã GD (Provider)</th>
                                    <th>Cổng</th>
                                    <th style="text-align:right;">Số tiền</th>
                                    <th style="text-align:right;">Thời gian</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($payments as $payment): ?>
                                    <tr>
                                        <td><span style="font-family: ui-monospace, SFMono-Regular, Consolas, monospace; font-size: 11px; font-weight: 600; background: var(--light-bg); border: 1px solid var(--border-color); padding: 2px 6px; border-radius: 4px;"><?= e($payment['provider_transaction_id']) ?></span></td>
                                        <td><span class="badge badge-light" style="font-size:10px;"><?= e($payment['provider']) ?></span></td>
                                        <td style="text-align:right; font-weight:700; color:var(--success); font-size: 13px;">+<?= format_price($payment['paid_amount']) ?></td>
                                        <td style="text-align:right; font-size:12px; color:var(--text-muted); font-weight: 500;"><?= e(date('H:i d/m/Y', strtotime($payment['created_at']))) ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    <?php endif; ?>
                </div>
            </div>

        </div>

        <div class="col col-right col-scrollable">
            
            <div class="card" style="border-top: 3px solid var(--primary);">
                <div class="card-header">
                    <h2><svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg> Cập nhật Đơn hàng</h2>
                </div>
                <div class="card-body">
                    <form method="post" id="updateOrderForm" onsubmit="return confirmUpdate(event)" style="margin: 0;">
                        <?= csrf_field() ?>
                        <input type="hidden" name="action" value="update_status">

                        <div class="form-group">
                            <label class="section-title">Trạng thái vận chuyển</label>
                            <div class="radio-btn-group">
                                <?php foreach ($statusMap as $key => $val): ?>
                                    <input type="radio" name="order_status" id="status_<?= e($key) ?>" value="<?= e($key) ?>" <?= $order['order_status'] === $key ? 'checked' : '' ?>>
                                    <label for="status_<?= e($key) ?>">
                                        <?= render_status_icon($key) ?>
                                        <span><?= e($val[0]) ?></span>
                                    </label>
                                <?php endforeach; ?>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="section-title">Hình thức thanh toán</label>
                            <div class="radio-btn-group">
                                <input type="radio" name="payment_plan" id="plan_none" value="" <?= $paymentPlan === '' ? 'checked' : '' ?>>
                                <label for="plan_none">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                    <span>Chưa rõ</span>
                                </label>

                                <input type="radio" name="payment_plan" id="plan_deposit" value="deposit" <?= $paymentPlan === 'deposit' ? 'checked' : '' ?>>
                                <label for="plan_deposit">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21.21 15.89A10 10 0 1 1 8 2.83"></path><path d="M22 12A10 10 0 0 0 12 2v10z"></path></svg>
                                    <span>Cọc <?= $defaultDepositRate ?>%</span>
                                </label>

                                <input type="radio" name="payment_plan" id="plan_full" value="full" <?= $paymentPlan === 'full' ? 'checked' : '' ?>>
                                <label for="plan_full">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="4" width="20" height="16" rx="2" ry="2"></rect><line x1="6" y1="8" x2="6.01" y2="8"></line><line x1="10" y1="8" x2="10.01" y2="8"></line></svg>
                                    <span>100% (Full)</span>
                                </label>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="section-title">Trạng thái thanh toán</label>
                            <div class="radio-btn-group">
                                <?php foreach ($paymentMap as $key => $val): ?>
                                    <input type="radio" name="payment_status" id="pstatus_<?= e($key) ?>" value="<?= e($key) ?>" <?= $order['payment_status'] === $key ? 'checked' : '' ?>>
                                    <label for="pstatus_<?= e($key) ?>">
                                        <?= render_payment_icon($key) ?>
                                        <span><?= e($val[0]) ?></span>
                                    </label>
                                <?php endforeach; ?>
                            </div>
                        </div>
                        
                        <div class="form-group" style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed var(--border-color); padding-top: 12px; margin-top: 16px;">
                            <label style="margin: 0; min-width: 120px;" class="section-title" for="paid_amount_input">Khách đã trả (VNĐ)</label>
                            <input type="number" id="paid_amount_input" name="paid_amount" class="form-control" style="font-size: 15px; font-weight: 800; color: var(--success); width: auto; max-width: 160px; text-align: right;" value="<?= (float)$order['paid_amount'] ?>">
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <textarea id="note_input" name="note" class="form-control" placeholder="Nhập ghi chú nội bộ dành cho cửa hàng..." style="font-size: 12px; padding: 10px;"><?= e($internalNoteValue) ?></textarea>
                        </div>

                        <button type="submit" class="btn-submit">
                            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                            Lưu Cập Nhật Đơn Hàng
                        </button>
                    </form>
                </div>
            </div>

            <div class="card" style="padding: 0;">
                <div class="card-header" style="background: var(--light-bg); border-bottom: 1px dashed var(--border-color); flex-direction: column; align-items: center; gap: 8px; padding: 12px;">
                    <h2 style="font-size:12px; text-transform:uppercase; letter-spacing:1px; color:var(--text-muted); margin:0; display:block;">Biên lai thanh toán</h2>
                    <span class="badge badge-<?= e($currentPaymentStatus[1]) ?>" style="font-size: 13px; padding: 4px 12px; box-shadow: var(--shadow-sm);"><?= e($currentPaymentStatus[0]) ?></span>
                </div>
                
                <div class="receipt">
                    <div class="summary-row" style="margin-top: 12px;">
                        <span class="label">Hình thức:</span>
                        <span class="val">
                            <?php if ($paymentPlan === 'deposit'): ?>
                                <span class="badge badge-warning" style="font-size: 11px; padding: 2px 8px;">Cọc <?= $defaultDepositRate ?>%</span>
                            <?php elseif ($paymentPlan === 'full'): ?>
                                <span class="badge badge-success" style="font-size: 11px; padding: 2px 8px;">100% (Full)</span>
                            <?php elseif ($paymentPlan !== ''): ?>
                                <span class="badge badge-light" style="font-size: 11px; padding: 2px 8px; text-transform: uppercase;"><?= e($paymentPlan) ?></span>
                            <?php else: ?>
                                <span class="text-muted" style="font-size: 12px;">Chưa xác định</span>
                            <?php endif; ?>
                        </span>
                    </div>

                    <div class="summary-row">
                        <span class="label">Tiền hàng:</span>
                        <span class="val"><?= format_price($subtotalAmount) ?></span>
                    </div>
                    <div class="summary-row">
                        <span class="label">Phí vận chuyển:</span>
                        <span class="val"><?= $isFreeShipping ? '<span style="color:var(--success); font-weight: 700;">Miễn phí</span>' : format_price($shippingFee) ?></span>
                    </div>
                    <?php if ($discountAmount > 0): ?>
                        <div class="summary-row">
                            <span class="label">Giảm giá:</span>
                            <span class="val" style="color:var(--danger);">-<?= format_price($discountAmount) ?></span>
                        </div>
                    <?php endif; ?>
                    
                    <div class="summary-row total">
                        <span class="label" style="color:var(--text-main); font-weight: 800; font-size: 14px; align-self: center;">TỔNG CỘNG:</span>
                        <span class="val"><?= format_price($totalAmount) ?></span>
                    </div>

                    <div class="highlight-box">
                        <div style="display:flex; justify-content:space-between; margin-bottom:8px; font-size:13px;">
                            <span style="color:var(--text-muted); font-weight:600;">Khách đã trả:</span>
                            <span style="color:var(--success); font-weight:700;"><?= format_price($paidAmount) ?></span>
                        </div>
                        <div style="display:flex; justify-content:space-between; font-size:14px; border-top: 1px dashed var(--border-color); padding-top:8px; align-items: center;">
                            <span style="font-weight:700; color:var(--text-main);">Còn lại cần thu:</span>
                            <span style="font-size: 16px; font-weight:900; color:<?= $remainingAmount > 0 ? 'var(--danger)' : 'var(--text-main)' ?>;"><?= format_price($remainingAmount) ?></span>
                        </div>
                    </div>

                    <?php if ($canShowQr): ?>
                        <button type="button" class="btn-submit btn-qr <?= $shouldHighlightPendingQr ? 'pulse-anim' : '' ?>" onclick="openQrModal()">
                            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                            Mã QR Thanh Toán
                        </button>
                    <?php endif; ?>
                </div>
            </div>

        </div>

    </div>
</div>

<div class="modal-overlay" id="imageModalOverlay">
    <div class="modal-content" style="max-width: 600px;">
        <div class="modal-header">
            <h3 style="margin:0; font-size:16px; font-weight:800; color: var(--text-main);" id="imageModalTitle">Ảnh Sản Phẩm</h3>
            <button class="btn-close" onclick="closeImageModal()"><svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
        </div>
        <div class="modal-body">
            <div id="imageModalGrid" style="display:grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap:16px;"></div>
        </div>
    </div>
</div>

<?php if ($canShowQr && $qrImageUrl): ?>
<div class="modal-overlay" id="qrModalOverlay">
    <div class="modal-content" style="max-width: 380px;">
        <div class="modal-header">
            <h3 style="margin:0; font-size:16px; font-weight:800; color: var(--text-main);"><?= e($paymentInstructionTitle) ?></h3>
            <button class="btn-close" onclick="closeQrModal()"><svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
        </div>
        <div class="modal-body" style="padding: 24px 20px;">
            <div style="font-size: 24px; font-weight: 900; color: var(--danger); margin-bottom: 20px; letter-spacing: -0.02em;">
                <?= format_price($qrTransferAmount) ?>
            </div>
            <div style="background: var(--light-bg); padding: 20px; border-radius: var(--radius-xl); border: 2px dashed #cbd5e1; display: inline-block; margin-bottom: 20px;">
                <img src="<?= e($qrImageUrl) ?>" alt="QR Code" style="width: 240px; height: 240px; border-radius: 10px; box-shadow: var(--shadow-md); object-fit: contain; background: #fff;">
            </div>
            <button type="button" class="btn-submit" style="background: var(--success); box-shadow: 0 4px 14px 0 rgba(16, 185, 129, 0.3); padding: 10px;" onclick="downloadImage('<?= e($qrImageUrl) ?>', 'QR_<?= e($order['order_code']) ?>.png')">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2-2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                Tải Mã QR
            </button>
            <div style="margin-top: 16px; font-size: 13px; font-weight: 500; color: var(--text-muted); padding: 10px; background: var(--warning-bg); border-radius: var(--radius-sm); border: 1px solid var(--warning-border);">
                Nội dung chuyển khoản: <strong style="color: #92400e; font-size: 14px; user-select: all; cursor: pointer;" title="Click để copy" onclick="copyText(this, '<?= e($qrTransferNote) ?>')"><?= e($qrTransferNote) ?></strong>
            </div>
        </div>
    </div>
</div>
<?php endif; ?>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const pStatusRadios = document.querySelectorAll('input[name="payment_status"]');
    const pPlanRadios = document.querySelectorAll('input[name="payment_plan"]');
    const pInput = document.getElementById('paid_amount_input');
    
    const total = <?= (float)$totalAmount ?>;
    const dep = <?= (float)$depositRequiredAmount ?>;
    const defaultDepositRate = <?= $defaultDepositRate ?>;
    
    // --- LƯU TRẠNG THÁI BAN ĐẦU ĐỂ HIGHLIGHT ---
    const radioGroups = ['order_status', 'payment_plan', 'payment_status'];
    radioGroups.forEach(name => {
        const initialChecked = document.querySelector(`input[name="${name}"]:checked`);
        if(initialChecked) {
            initialChecked.dataset.initial = "true";
        }
        
        document.querySelectorAll(`input[name="${name}"]`).forEach(radio => {
            radio.addEventListener('change', () => updateHighlight(name));
        });
    });

    // Hàm cập nhật màu highlight (Vàng = Cũ, Xanh = Mới)
    function updateHighlight(groupName) {
        const radios = document.querySelectorAll(`input[name="${groupName}"]`);
        const initialRadio = document.querySelector(`input[name="${groupName}"][data-initial="true"]`);
        const currentRadio = document.querySelector(`input[name="${groupName}"]:checked`);

        // Reset class
        radios.forEach(r => {
            if (r.nextElementSibling) {
                r.nextElementSibling.classList.remove('status-old-highlight', 'status-new-highlight');
            }
        });

        // Nếu trạng thái hiện tại khác trạng thái lúc tải trang
        if (initialRadio && currentRadio && initialRadio !== currentRadio) {
            initialRadio.nextElementSibling.classList.add('status-old-highlight');
            currentRadio.nextElementSibling.classList.add('status-new-highlight');
        }
    }
    
    // --- LOGIC THANH TOÁN (CẬP NHẬT SỐ TIỀN) ---
    function getSelectedRadioValue(name) {
        const checked = document.querySelector(`input[name="${name}"]:checked`);
        return checked ? checked.value : null;
    }
    
    function updatePaidAmount() {
        if (!pInput) return;
        const pStatus = getSelectedRadioValue('payment_status');
        if (pStatus === 'chua_thanh_toan') {
            pInput.value = 0;
        } else if (pStatus === 'da_dat_coc') {
            pInput.value = dep;
        } else if (pStatus === 'da_thanh_toan') {
            pInput.value = total;
        }
    }
    
    function checkPaymentLogic() {
        if (!pPlanRadios.length || !pStatusRadios.length) return;
        const isDepositPlan = getSelectedRadioValue('payment_plan') === 'deposit';
        
        pStatusRadios.forEach(radio => {
            if (radio.value === 'da_dat_coc') {
                radio.disabled = !isDepositPlan; 
                
                if (!isDepositPlan && radio.checked) {
                    document.querySelector('input[name="payment_status"][value="chua_thanh_toan"]').checked = true;
                    updatePaidAmount();
                    updateHighlight('payment_status'); // Chạy highlight vì JS tự chuyển state
                }
            }
        });
    }

    pStatusRadios.forEach(radio => radio.addEventListener('change', updatePaidAmount));
    pPlanRadios.forEach(radio => radio.addEventListener('change', checkPaymentLogic));
    
    checkPaymentLogic(); 
});

function toggleAddressEdit() {
    const d = document.getElementById('address_display');
    const e = document.getElementById('address_edit');
    if (d.style.display === 'none') { 
        d.style.display = 'block'; e.style.display = 'none'; 
    } else { 
        d.style.display = 'none'; e.style.display = 'block'; 
    }
}

function confirmUpdate(e) {
    const selectedStatus = document.querySelector('input[name="payment_status"]:checked');
    const selectedPlan = document.querySelector('input[name="payment_plan"]:checked');
    const selectedOrderState = document.querySelector('input[name="order_status"]:checked');
    const defaultDepositRate = <?= $defaultDepositRate ?>;

    if (selectedStatus && selectedPlan && selectedStatus.value === 'da_dat_coc' && selectedPlan.value !== 'deposit') {
        alert(`Lỗi: Hình thức thanh toán phải là "Cọc ${defaultDepositRate}%" mới được phép chọn trạng thái "Đã đặt cọc".`);
        e.preventDefault();
        return false;
    }

    const oText = selectedOrderState ? selectedOrderState.nextElementSibling.querySelector('span').innerText : '';
    const pText = selectedStatus ? selectedStatus.nextElementSibling.querySelector('span').innerText : '';
    const planText = selectedPlan ? selectedPlan.nextElementSibling.querySelector('span').innerText : '';
    
    const amount = document.getElementById('paid_amount_input').value;
    const formattedAmount = new Intl.NumberFormat('vi-VN').format(amount);
    
    if (!confirm(`Xác nhận lưu thay đổi đơn hàng?\n\n📦 Vận chuyển: ${oText.trim()}\n💳 Hình thức TT: ${planText.trim()}\n💳 Trạng thái TT: ${pText.trim()}\n💰 Tiền đã thu: ${formattedAmount}đ`)) {
        e.preventDefault(); 
        return false;
    }
    return true;
}

function copyText(btn, text) {
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(() => showCopied(btn)).catch(() => fallbackCopy(text, btn));
    } else {
        fallbackCopy(text, btn);
    }
}

function showCopied(btn) {
    const oldHtml = btn.innerHTML; 
    btn.innerHTML = `<svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
    btn.style.color = "var(--success)"; 
    btn.style.borderColor = "var(--success-border)"; 
    btn.style.background = "var(--success-bg)";
    setTimeout(() => { 
        btn.innerHTML = oldHtml; 
        btn.style = ''; 
    }, 1500);
}

function fallbackCopy(text, btn) {
    const ta = document.createElement("textarea"); 
    ta.value = text; 
    ta.style.position = "fixed"; 
    document.body.appendChild(ta); 
    ta.focus(); 
    ta.select();
    try { 
        if(document.execCommand('copy')) showCopied(btn); 
    } catch(e) { console.error('Fallback copy failed'); }
    document.body.removeChild(ta);
}

function openQrModal() { document.getElementById('qrModalOverlay').classList.add('active'); }
function closeQrModal() { document.getElementById('qrModalOverlay').classList.remove('active'); }

function openImageModal(imgs, title) {
    document.getElementById('imageModalTitle').innerText = title;
    const grid = document.getElementById('imageModalGrid'); 
    grid.innerHTML = '';
    
    if (!imgs || !imgs.length) {
        grid.innerHTML = '<div style="grid-column:1/-1; text-align:center; color:var(--text-muted); padding: 40px;">Chưa có ảnh mô tả cho sản phẩm này.</div>';
    } else {
        imgs.forEach((u, i) => {
            const url = u.replace(/"/g, '&quot;');
            grid.innerHTML += `
                <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden; background: var(--bg-card); box-shadow: var(--shadow-sm);">
                    <img src="${url}" style="width: 100%; height: 200px; object-fit: contain; background: #fff; border-bottom: 1px solid var(--border-color);">
                    <div style="padding: 10px;">
                        <button type="button" class="btn-action" style="width: 100%; justify-content: center; padding: 6px;" onclick="downloadImage('${url}', 'SP_${i+1}.png')">
                            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2-2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                            Tải Ảnh Về
                        </button>
                    </div>
                </div>`;
        });
    }
    document.getElementById('imageModalOverlay').classList.add('active');
}

function closeImageModal() { document.getElementById('imageModalOverlay').classList.remove('active'); }

async function downloadImage(url, name) {
    try {
        const res = await fetch(url); 
        const blob = await res.blob(); 
        const bUrl = URL.createObjectURL(blob);
        const a = document.createElement('a'); 
        a.href = bUrl; 
        a.download = name; 
        document.body.appendChild(a); 
        a.click(); 
        document.body.removeChild(a); 
        URL.revokeObjectURL(bUrl);
    } catch(e) {
        const a = document.createElement('a'); 
        a.href = url; 
        a.download = name; 
        a.target = '_blank'; 
        document.body.appendChild(a); 
        a.click(); 
        document.body.removeChild(a);
    }
}

window.onclick = e => {
    const qrModal = document.getElementById('qrModalOverlay');
    const imgModal = document.getElementById('imageModalOverlay');
    if (e.target == qrModal) closeQrModal();
    if (e.target == imgModal) closeImageModal();
}
</script>
</body>
</html>