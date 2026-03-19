<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

$orderId = (int)($_GET['id'] ?? 0);
$order = $orderId > 0 ? admin_get_order($orderId) : null;

if (!$order) {
    http_response_code(404);
    exit('Không tìm thấy đơn hàng.');
}

$error = '';
$success = '';

// Xử lý khi Submit Form Cập nhật
if (is_post()) {
    verify_csrf_or_fail();
    try {
        $newOrderStatus = (string)($_POST['order_status'] ?? '');
        $newPaymentStatus = (string)($_POST['payment_status'] ?? '');
        $note = trim((string)($_POST['note'] ?? '')) ?: null;

        admin_update_order_status($orderId, $newOrderStatus, $note);

        if ($newPaymentStatus) {
            admin_update_order_payment_status($orderId, $newPaymentStatus);
        }

        $_SESSION['success_msg'] = "Đã cập nhật đơn hàng thành công!";
        redirect('/admin/order_view.php?id=' . $orderId);
    } catch (Throwable $e) {
        $error = "Lỗi khi cập nhật: " . $e->getMessage();
    }
}

$items = get_order_items($orderId);
$address = get_order_address($orderId);
$payments = get_order_payments($orderId);

$statusMap = order_status_options();
$paymentMap = payment_status_options();

$currentOrderStatus = $statusMap[$order['order_status']] ?? [$order['order_status'], 'primary'];
$currentPaymentStatus = $paymentMap[$order['payment_status']] ?? [$order['payment_status'], 'info'];

// Xác định lựa chọn thanh toán của khách lúc đặt hàng
$paymentChoiceLabel = 'Thanh toán toàn bộ (100%)';
if (isset($order['payment_method']) && strpos(strtolower($order['payment_method']), 'deposit') !== false) {
    $paymentChoiceLabel = 'Thanh toán tiền cọc';
} elseif ((float)($order['deposit_required_amount'] ?? 0) > 0 && (float)$order['deposit_required_amount'] < (float)$order['total_amount']) {
    $paymentChoiceLabel = 'Thanh toán tiền cọc';
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn #<?= e($order['order_code']) ?></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --admin-bg: #f3f4f6;
            --admin-card: #ffffff;
            --admin-text-main: #111827;
            --admin-text-muted: #6b7280;
            --admin-border: #e5e7eb;
            --admin-primary: #4f46e5;
            --admin-primary-hover: #4338ca;
            --admin-danger: #ef4444;
            --admin-danger-bg: #fef2f2;
            --admin-danger-border: #fecaca;
            --admin-success: #10b981;
            --admin-success-bg: #ecfdf5;
            --admin-warning: #f59e0b;
            --admin-warning-bg: #fffbeb;
            --admin-info: #0ea5e9;
            --admin-info-bg: #e0f2fe;
            --admin-radius: 12px;
            --admin-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }

        body { margin: 0; font-family: 'Inter', sans-serif; background: var(--admin-bg); color: var(--admin-text-main); }
        .container { max-width: 1200px; margin: 0 auto; padding: 32px 24px; }
        
        .header-nav { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
        .back-link { display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--admin-text-muted); font-weight: 600; transition: color 0.2s; }
        .back-link:hover { color: var(--admin-primary); }

        .grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; }
        
        .card { background: var(--admin-card); border: 1px solid var(--admin-border); border-radius: var(--admin-radius); padding: 24px; box-shadow: var(--admin-shadow); margin-bottom: 24px; }
        .card-header { display: flex; align-items: center; gap: 10px; margin-bottom: 16px; border-bottom: 1px solid var(--admin-border); padding-bottom: 12px; }
        .card-header h2 { margin: 0; font-size: 18px; font-weight: 700; color: var(--admin-text-main); }
        .card-header svg { color: var(--admin-text-muted); }

        .order-title { margin: 0 0 8px; font-size: 24px; font-weight: 800; display: flex; align-items: center; gap: 12px; }
        .order-meta { color: var(--admin-text-muted); font-size: 14px; margin-bottom: 16px; }
        
        .table-responsive { overflow-x: auto; margin-top: 16px; border-radius: 8px; border: 1px solid var(--admin-border); }
        .table { width: 100%; border-collapse: collapse; }
        .table th, .table td { padding: 14px 16px; border-bottom: 1px solid var(--admin-border); text-align: left; font-size: 14px; vertical-align: top; }
        .table th { background: #f9fafb; font-size: 12px; text-transform: uppercase; color: var(--admin-text-muted); font-weight: 600; }
        .table tr:last-child td { border-bottom: none; }
        
        .item-name { font-weight: 600; color: var(--admin-text-main); display: block; margin-bottom: 4px; }
        .item-code { font-size: 12px; color: var(--admin-text-muted); font-family: monospace; }
        
        /* CSS CHUYÊN BIỆT CHO HIỂN THỊ BIẾN THỂ */
        .variant-pill { display: inline-block; padding: 3px 8px; background-color: #f1f5f9; color: #475569; font-size: 12px; font-weight: 600; border-radius: 6px; margin-bottom: 6px; border: 1px solid #e2e8f0; }

        .status-badge { display: inline-flex; padding: 6px 12px; font-size: 12px; font-weight: 600; border-radius: 20px; white-space: nowrap; align-items: center; gap: 6px; }
        .status-badge::before { content: ''; display: block; width: 6px; height: 6px; border-radius: 50%; }
        
        .badge-warning { background: var(--admin-warning-bg); color: var(--admin-warning); } .badge-warning::before { background-color: var(--admin-warning); }
        .badge-success { background: var(--admin-success-bg); color: var(--admin-success); } .badge-success::before { background-color: var(--admin-success); }
        .badge-danger { background: var(--admin-danger-bg); color: var(--admin-danger); } .badge-danger::before { background-color: var(--admin-danger); }
        .badge-primary { background: #eef2ff; color: var(--admin-primary); } .badge-primary::before { background-color: var(--admin-primary); }
        .badge-info { background: var(--admin-info-bg); color: var(--admin-info); } .badge-info::before { background-color: var(--admin-info); }

        .btn { display: inline-flex; align-items: center; justify-content: center; width: 100%; padding: 12px 16px; border-radius: 8px; background: var(--admin-primary); color: #fff; text-decoration: none; border: none; cursor: pointer; font-weight: 600; transition: all 0.2s; font-size: 14px; }
        .btn:hover { background: var(--admin-primary-hover); transform: translateY(-1px); }

        .field { margin-bottom: 16px; }
        .field label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 8px; color: var(--admin-text-main); }
        .field select, .field textarea { width: 100%; padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 14px; font-family: 'Inter', sans-serif; outline: none; transition: border 0.2s; }
        .field select:focus, .field textarea:focus { border-color: var(--admin-primary); box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1); }

        .summary-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px dashed var(--admin-border); font-size: 14px; }
        .summary-row:last-child { border-bottom: none; }
        .summary-row strong { color: var(--admin-text-main); font-size: 15px; }
        .summary-row.total strong { color: var(--admin-danger); font-size: 18px; }

        .alert { padding: 14px 16px; border-radius: 8px; font-weight: 500; font-size: 14px; margin-bottom: 20px; }
        .alert-danger { background: var(--admin-danger-bg); border: 1px solid var(--admin-danger-border); color: #991b1b; }
        .alert-success { background: var(--admin-success-bg); border: 1px solid #a7f3d0; color: var(--admin-success); }

        .info-block { margin-top: 12px; line-height: 1.6; }
        .muted { color: var(--admin-text-muted); }

        .link-source { display: inline-flex; align-items: center; gap: 6px; padding: 6px 10px; font-size: 12px; font-weight: 600; border-radius: 6px; text-decoration: none; transition: all 0.2s; border: 1px solid transparent; white-space: nowrap; margin-bottom: 6px;}
        .link-source:hover { transform: translateY(-1px); }
        .btn-copy { background: #f3f4f6; border: 1px solid #d1d5db; color: #4b5563; padding: 6px 10px; font-size: 12px; font-weight: 600; border-radius: 6px; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px; white-space: nowrap; font-family: 'Inter', sans-serif; }
        .btn-copy:hover { background: #e5e7eb; }
        .btn-copy.copied { background: var(--admin-success-bg); color: var(--admin-success); border-color: #a7f3d0; }
        
        .link-zalo { color: #0068ff; background: #e5f0ff; } .link-zalo:hover { background: #d0e4ff; }
        .link-fb { color: #1877f2; background: #e7f0fd; } .link-fb:hover { background: #d4e4fc; }
        .link-phone { color: #059669; background: #d1fae5; } .link-phone:hover { background: #bbf7d0; }
        .link-web { color: #4b5563; background: #f3f4f6; } .link-web:hover { background: #e5e7eb; }

        @media(max-width: 900px) { 
            .grid { grid-template-columns: 1fr; } 
            .container { padding: 16px; }
        }
    </style>
</head>
<body>
<div class="container">
    
    <div class="header-nav">
        <a href="<?= route_url('/admin/orders.php') ?>" class="back-link">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
            Quay lại danh sách đơn hàng
        </a>
    </div>

    <?php if ($error): ?>
        <div class="alert alert-danger"><?= e($error) ?></div>
    <?php endif; ?>
    <?php if (isset($_SESSION['success_msg'])): ?>
        <div class="alert alert-success"><?= e($_SESSION['success_msg']) ?></div>
        <?php unset($_SESSION['success_msg']); ?>
    <?php endif; ?>

    <div class="grid">
        <div>
            <div class="card">
                <h1 class="order-title">
                    Đơn hàng #<?= e($order['order_code']) ?>
                    <span class="status-badge badge-<?= $currentOrderStatus[1] ?>"><?= e($currentOrderStatus[0]) ?></span>
                </h1>
                <div class="order-meta">
                    📅 Đặt lúc: <?= e(date('H:i - d/m/Y', strtotime($order['placed_at']))) ?> 
                    · Kênh: <strong style="text-transform: capitalize; color: var(--admin-text-main);"><?= e($order['purchase_channel']) ?></strong>
                </div>
                
                <div style="background: #f9fafb; padding: 16px; border-radius: 8px; border: 1px solid var(--admin-border); margin-top: 16px;">
                    <div style="font-weight: 600; color: var(--admin-text-main); margin-bottom: 4px;">👤 Khách hàng: <?= e($order['customer_name'] ?: $order['contact_name']) ?></div>
                    <div style="color: var(--admin-text-muted); font-size: 14px;">📞 Số điện thoại: <strong><?= e($order['contact_phone']) ?></strong></div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                    <h2>Sản phẩm đã đặt</h2>
                </div>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th>Nguồn nhập hàng</th>
                                <th style="text-align: center;">SL</th>
                                <th style="text-align: right;">Đơn giá</th>
                                <th style="text-align: right;">Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($items as $item): ?>
                            <?php 
                                // Truy vấn link nhập hàng từ Database dựa vào product_id của item
                                $importLink = '';
                                if (!empty($item['product_id'])) {
                                    $stmt = db()->prepare('SELECT import_link FROM products WHERE id = ?');
                                    $stmt->execute([$item['product_id']]);
                                    $importLink = trim((string)$stmt->fetchColumn());
                                }

                                // Nhận diện biến thể (Thường lưu ở cột variant_name_snapshot hoặc variant_name)
                                $variantName = $item['variant_name_snapshot'] ?? $item['variant_name'] ?? '';
                            ?>
                            <tr>
                                <td>
                                    <span class="item-name"><?= e($item['product_name_snapshot']) ?></span>
                                    
                                    <?php if (!empty($variantName)): ?>
                                        <span class="variant-pill">🏷️ Phân loại: <?= e($variantName) ?></span><br>
                                    <?php endif; ?>

                                    <span class="item-code">Mã: <?= e($item['product_code_snapshot']) ?></span>
                                </td>
                                
                                <td>
                                    <?php 
                                    if (empty($importLink)) {
                                        echo '<span class="muted">-</span>';
                                    } else {
                                        $lowerData = strtolower($importLink);
                                        $isPhone = preg_match('/^[0-9\+\-\s\.]+$/', $importLink) && strlen(preg_replace('/[^0-9]/', '', $importLink)) >= 8;
                                        
                                        echo '<div style="display:flex; flex-direction:column; align-items:flex-start;">';
                                        
                                        if ($isPhone) {
                                            $cleanPhone = preg_replace('/[^0-9\+]/', '', $importLink);
                                            echo '<a class="link-source link-phone" href="tel:' . e($cleanPhone) . '">📞 ' . e($importLink) . '</a>';
                                            
                                            echo '<div style="display: flex; gap: 6px;">';
                                            echo '<a class="link-source link-zalo" target="_blank" href="https://zalo.me/' . e($cleanPhone) . '">💬 Zalo</a>';
                                            echo '<button type="button" class="btn-copy" onclick="copyText(this, \'' . e($cleanPhone) . '\')">📋 Copy</button>';
                                            echo '</div>';
                                        } else {
                                            $hrefUrl = (strpos($importLink, 'http') !== 0) ? 'https://' . $importLink : $importLink;
                                            
                                            if (strpos($lowerData, 'zalo.me') !== false) {
                                                echo '<a class="link-source link-zalo" target="_blank" href="' . e($importLink) . '">💬 Chat Zalo</a>';
                                            } elseif (strpos($lowerData, 'facebook.com') !== false || strpos($lowerData, 'fb.com') !== false) {
                                                echo '<a class="link-source link-fb" target="_blank" href="' . e($importLink) . '">📘 Facebook</a>';
                                            } else {
                                                $displayUrl = (strlen($importLink) > 18) ? substr($importLink, 0, 15) . '...' : $importLink;
                                                echo '<a class="link-source link-web" target="_blank" href="' . e($hrefUrl) . '">🔗 ' . e($displayUrl) . '</a>';
                                            }
                                            echo '<button type="button" class="btn-copy" style="margin-top: 4px;" onclick="copyText(this, \'' . e($importLink) . '\')">📋 Copy Link</button>';
                                        }
                                        echo '</div>';
                                    }
                                    ?>
                                </td>

                                <td style="text-align: center; font-weight: 600;"><?= (int)$item['quantity'] ?></td>
                                <td style="text-align: right;"><?= format_price($item['final_unit_price']) ?></td>
                                <td style="text-align: right; font-weight: 600; color: var(--admin-text-main);"><?= format_price($item['line_total']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="10" r="3"></circle></svg>
                    <h2>Địa chỉ giao hàng</h2>
                </div>
                <div class="info-block">
                <?php if ($address): ?>
                    <div style="font-size: 15px; font-weight: 600; margin-bottom: 6px;"><?= e($address['receiver_name']) ?> <span class="muted" style="font-weight: 400;">(SĐT: <?= e($address['receiver_phone']) ?>)</span></div>
                    <div class="muted">📍 <?= e($address['address_line'] . ', ' . $address['ward_name'] . ', ' . $address['district_name'] . ', ' . $address['province_name']) ?></div>
                <?php else: ?>
                    <div class="muted">Chưa có thông tin địa chỉ giao hàng.</div>
                <?php endif; ?>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2" ry="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg>
                    <h2>Lịch sử giao dịch</h2>
                </div>
                <?php if (!$payments): ?>
                    <div class="muted" style="padding-top: 10px;">Chưa có giao dịch thanh toán nào được ghi nhận.</div>
                <?php else: ?>
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Mã GD</th>
                                    <th>Số tiền</th>
                                    <th>Kênh/Cổng</th>
                                    <th>Thời gian</th>
                                </tr>
                            </thead>
                            <tbody>
                            <?php foreach ($payments as $payment): ?>
                                <tr>
                                    <td style="font-family: monospace;"><?= e($payment['provider_transaction_id']) ?></td>
                                    <td style="font-weight: 600; color: var(--admin-success);"><?= format_price($payment['paid_amount']) ?></td>
                                    <td><span class="status-badge badge-info"><?= e($payment['provider']) ?></span></td>
                                    <td class="muted"><?= e(date('H:i d/m/Y', strtotime($payment['created_at']))) ?></td>
                                </tr>
                            <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php endif; ?>
            </div>
        </div>

        <div>
            <div class="card" style="border-top: 4px solid var(--admin-primary);">
                <div class="card-header">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                    <h2>Tóm tắt thanh toán</h2>
                </div>
                
                <div style="margin-bottom: 16px; text-align: center;">
                    <span class="status-badge badge-<?= $currentPaymentStatus[1] ?>" style="font-size: 14px; padding: 8px 16px;">
                        <?= e($currentPaymentStatus[0]) ?>
                    </span>
                </div>

                <div style="background: #f0fdf4; border: 1px dashed #22c55e; padding: 12px; border-radius: 8px; margin-bottom: 16px; text-align: center;">
                    <span style="display: block; font-size: 12px; color: #166534; margin-bottom: 4px; font-weight: 600; text-transform: uppercase;">Lựa chọn của khách:</span>
                    <strong style="font-size: 16px; color: #15803d;">
                        <?= $paymentChoiceLabel ?>
                    </strong>
                </div>

                <div class="summary-row">
                    <span class="muted">Tiền cọc yêu cầu:</span>
                    <strong style="color: var(--admin-info);"><?= format_price($order['deposit_required_amount']) ?></strong>
                </div>
                <div class="summary-row">
                    <span class="muted">Khách đã trả:</span>
                    <strong style="color: var(--admin-success);"><?= format_price($order['paid_amount']) ?></strong>
                </div>
                <div class="summary-row">
                    <span class="muted">Còn phải thu:</span>
                    <strong><?= format_price($order['remaining_amount']) ?></strong>
                </div>
                <div class="summary-row total" style="margin-top: 8px; border-top: 2px solid var(--admin-border); padding-top: 16px;">
                    <span style="font-weight: 700; color: var(--admin-text-main);">TỔNG CỘNG:</span>
                    <strong><?= format_price($order['total_amount']) ?></strong>
                </div>
            </div>

            <div class="card" style="position: sticky; top: 24px;">
                <div class="card-header">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    <h2>Bảng điều khiển</h2>
                </div>
                
                <form method="post" id="updateOrderForm" onsubmit="return confirmUpdate(event)">
                    <?= csrf_field() ?>
                    
                    <div class="field">
                        <label>🚚 Trạng thái đơn hàng</label>
                        <select name="order_status" id="order_status_select">
                            <?php foreach ($statusMap as $key => $val): ?>
                                <option value="<?= e($key) ?>" <?= $order['order_status'] === $key ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <div class="field">
                        <label>💰 Trạng thái thanh toán</label>
                        <select name="payment_status" id="payment_status_select">
                            <?php foreach ($paymentMap as $key => $val): ?>
                                <option value="<?= e($key) ?>" <?= $order['payment_status'] === $key ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <div class="field">
                        <label>📝 Ghi chú nội bộ</label>
                        <textarea name="note" rows="4" placeholder="Nhập ghi chú để lưu lại thông tin xử lý (Khách không thấy)..."></textarea>
                    </div>
                    
                    <button class="btn" type="submit">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px;"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                        Lưu Cập Nhật
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
// 1. Logic Xác nhận thay đổi form
function confirmUpdate(event) {
    const orderSelect = document.getElementById('order_status_select');
    const paymentSelect = document.getElementById('payment_status_select');
    
    const newOrderText = orderSelect.options[orderSelect.selectedIndex].text;
    const newPaymentText = paymentSelect.options[paymentSelect.selectedIndex].text;

    const message = `Bạn có chắc chắn muốn lưu thay đổi?\n\n- Đơn hàng: ${newOrderText}\n- Thanh toán: ${newPaymentText}`;

    // Nếu người dùng bấm Cancel, form sẽ không được gửi đi
    if (!confirm(message)) {
        event.preventDefault(); 
        return false;
    }
    
    return true;
}


// 2. Hàm thực hiện copy link/số
function copyText(button, textToCopy) {
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(textToCopy).then(() => {
            showCopiedState(button);
        }).catch(err => {
            fallbackCopyTextToClipboard(textToCopy, button);
        });
    } else {
        fallbackCopyTextToClipboard(textToCopy, button);
    }
}

function showCopiedState(button) {
    const originalText = button.innerHTML;
    button.innerHTML = "✔ Đã copy!";
    button.classList.add("copied");
    setTimeout(() => {
        button.innerHTML = originalText;
        button.classList.remove("copied");
    }, 2000);
}

function fallbackCopyTextToClipboard(text, button) {
    var textArea = document.createElement("textarea");
    textArea.value = text;
    textArea.style.position = "fixed";
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    try {
        var successful = document.execCommand('copy');
        if(successful) {
            showCopiedState(button);
        } else {
            alert('Không thể copy, vui lòng thao tác tay!');
        }
    } catch (err) {
        alert('Trình duyệt không hỗ trợ copy tự động!');
    }
    document.body.removeChild(textArea);
}
</script>
</body>
</html>