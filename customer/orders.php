<?php
require_once __DIR__ . '/../includes/functions.php';
$pageTitle = current_customer() ? 'Đơn hàng của tôi' : 'Tra cứu đơn hàng';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$missing = require_upgrade_tables(['orders']);
$customer = current_customer();
$orders = [];
$lookupError = null;
$lookupOrders = []; 

$statusMap = array_map(fn($item) => $item[0], order_status_options());
$paymentMap = array_map(fn($item) => $item[0], payment_status_options());

// Hàm hỗ trợ lấy class màu sắc cho trạng thái đơn hàng
function get_order_status_badge_class($status) {
    $s = mb_strtolower($status, 'UTF-8');
    if (in_array($s, ['chờ xác nhận', 'pending', 'chờ xử lý', 'mới'])) return 'badge-warning';
    if (in_array($s, ['đang xử lý', 'processing', 'đang giao hàng', 'shipped', 'đang giao'])) return 'badge-info';
    if (in_array($s, ['hoàn thành', 'completed', 'đã giao', 'thành công'])) return 'badge-success';
    if (in_array($s, ['đã hủy', 'cancelled', 'thất bại', 'hủy'])) return 'badge-danger';
    return 'badge-default';
}

// Hàm hỗ trợ lấy class màu sắc cho trạng thái thanh toán
function get_payment_status_badge_class($status) {
    $s = mb_strtolower($status, 'UTF-8');
    if (in_array($s, ['chưa thanh toán', 'unpaid', 'pending'])) return 'badge-warning';
    if (in_array($s, ['đã thanh toán', 'paid', 'thành công'])) return 'badge-success';
    if (in_array($s, ['lỗi', 'failed', 'đã hoàn tiền', 'refunded'])) return 'badge-danger';
    return 'badge-default';
}

if (!$missing && $customer) {
    $orders = get_customer_orders((int)$customer['id']);
}

// Xử lý Tra cứu đơn hàng
if (!$missing && is_post()) {
    verify_public_or_customer_form_or_fail();
    $orderCode = trim((string)($_POST['order_code'] ?? ''));
    $phone = normalize_phone($_POST['contact_phone'] ?? null);
    
    if ($orderCode === '' || !$phone) {
        $lookupError = 'Vui lòng nhập đồng thời Mã đơn hàng và Số điện thoại để tra cứu.';
    } else {
        $stmt = db()->prepare('SELECT * FROM orders WHERE order_code = ? AND contact_phone = ? LIMIT 1');
        $stmt->execute([$orderCode, $phone]);
        $found = $stmt->fetch();
        $lookupOrders = $found ? [$found] : [];

        if (empty($lookupOrders)) {
            $lookupError = 'Không tìm thấy đơn hàng nào phù hợp với thông tin tra cứu.';
        }
    }
}

require_once __DIR__ . '/../includes/header.php';
?>

<style>
/* =========================================
   TỐI ƯU GIAO DIỆN CHUNG & MOBILE
========================================= */
:root {
    --primary-color: #111827;
    --border-color: #e5e7eb;
    --text-muted: #6b7280;
}

/* Layout cơ bản */
.account-shell { padding: 24px 16px; max-width: 800px; margin: 0 auto; }
.account-card { margin-bottom: 40px; }
.section-title { font-size: 20px; margin-bottom: 6px; font-weight: 700; }
.section-subtitle { color: var(--text-muted); font-size: 14px; margin-bottom: 20px; }

/* Biểu mẫu (Forms) */
.form-group { margin-bottom: 16px; }
.form-label { font-weight: 600; display: block; margin-bottom: 8px; font-size: 14px; }
.form-control { width: 100%; padding: 12px 14px; border-radius: 8px; border: 1px solid #d1d5db; font-size: 16px; box-sizing: border-box; }
.form-control:focus { outline: none; border-color: #4f46e5; box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1); }

/* Nút bấm (Buttons) */
.btn-primary, .btn-secondary { display: inline-block; border-radius: 8px; font-weight: 600; text-align: center; text-decoration: none; cursor: pointer; box-sizing: border-box; transition: all 0.2s; border: none; }
.btn-primary { padding: 12px 24px; background: var(--primary-color); color: #fff; width: 100%; font-size: 16px; }
.btn-secondary { padding: 8px 16px; background: #f3f4f6; color: var(--primary-color); font-size: 13px; }
.btn-secondary:hover { background: #e5e7eb; }

/* Thông báo (Alerts) */
.alert { padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; font-weight: 500; }
.alert-warning { background-color: #fef08a; color: #854d0e; }
.alert-info { background-color: #dbeafe; color: #1e40af; }
.alert-error { background-color: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
.alert-success { background-color: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }

/* Badges trạng thái */
.badge { padding: 4px 10px; border-radius: 9999px; font-size: 12px; font-weight: 600; display: inline-block; white-space: nowrap; }
.badge-warning { background-color: #fef08a; color: #854d0e; }
.badge-info { background-color: #dbeafe; color: #1e40af; }
.badge-success { background-color: #dcfce3; color: #166534; }
.badge-danger { background-color: #fee2e2; color: #991b1b; }
.badge-default { background-color: #f3f4f6; color: #374151; }

/* Bảng dữ liệu (Desktop Default) */
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table th { padding: 12px 8px; color: var(--text-muted); text-transform: uppercase; font-size: 12px; border-bottom: 2px solid var(--border-color); }
.data-table td { padding: 14px 8px; border-bottom: 1px solid var(--border-color); }
.text-highlight { font-weight: 700; color: #4f46e5; }
.text-price { font-weight: 700; color: #ef4444; }
.text-date { color: #475569; }

/* Bảng hiển thị dạng Card cho Mobile */
@media (max-width: 768px) {
    .responsive-table thead { display: none; }
    .responsive-table, .responsive-table tbody, .responsive-table tr, .responsive-table td { display: block; width: 100%; box-sizing: border-box; }
    .responsive-table tr { margin-bottom: 16px; border: 1px solid var(--border-color); border-radius: 12px; padding: 12px; background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
    .responsive-table td { text-align: right; padding: 8px 0; border-bottom: 1px dashed var(--border-color); min-height: 40px; display: flex; justify-content: space-between; align-items: center; }
    .responsive-table td:last-child { border-bottom: none; padding-bottom: 0; margin-top: 8px; justify-content: flex-end; }
    .responsive-table td::before { content: attr(data-label); text-align: left; font-weight: 600; color: var(--text-muted); font-size: 13px; margin-right: 16px; }
}

/* PC Override */
@media (min-width: 769px) {
    .account-shell { padding-top: 40px; }
    .btn-primary { width: auto; }
    .form-wrapper { padding-bottom: 24px; border-bottom: 1px dashed var(--border-color); margin-bottom: 24px; }
}
</style>

<div class="account-shell">
    <?php if ($missing): ?>
        <div class="alert alert-warning">Bạn cần import file migration nâng cấp CSDL trước: <?= e(implode(', ', $missing)) ?>.</div>
    <?php endif; ?>

    <?php if ($customer): ?>
        <div class="account-card">
            <h1 class="section-title">Đơn hàng của tôi</h1>
            <p class="section-subtitle">Danh sách đơn đặt hàng gắn với tài khoản hiện tại.</p>
            
            <?php if (!$orders): ?>
                <div class="alert alert-info">Chưa có đơn hàng nào trong tài khoản này.</div>
            <?php else: ?>
                <table class="data-table responsive-table">
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Ngày đặt</th>
                            <th>Tổng tiền</th>
                            <th>Thanh toán</th>
                            <th>Trạng thái</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($orders as $order): ?>
                            <?php 
                                $payStatus = $paymentMap[$order['payment_status']] ?? $order['payment_status'];
                                $ordStatus = $statusMap[$order['order_status']] ?? $order['order_status'];
                            ?>
                            <tr>
                                <td data-label="Mã đơn" class="text-highlight">#<?= e($order['order_code']) ?></td>
                                <td data-label="Ngày đặt" class="text-date"><?= e(date('d/m/Y H:i', strtotime($order['placed_at']))) ?></td>
                                <td data-label="Tổng tiền" class="text-price"><?= format_price($order['total_amount']) ?></td>
                                <td data-label="Thanh toán"><span class="badge <?= get_payment_status_badge_class($payStatus) ?>"><?= e($payStatus) ?></span></td>
                                <td data-label="Trạng thái"><span class="badge <?= get_order_status_badge_class($ordStatus) ?>"><?= e($ordStatus) ?></span></td>
                                <td data-label="">
                                    <a class="btn-secondary" href="<?= route_url('/order.php') ?>?code=<?= urlencode($order['order_code']) ?>">Xem chi tiết</a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php endif; ?>
        </div>
    <?php endif; ?>

    <div class="account-card">
        <h2 class="section-title">Tra cứu đơn hàng</h2>
        <p class="section-subtitle">Nhập đồng thời Mã đơn hàng và Số điện thoại đã đặt để kiểm tra trạng thái.</p>
        
        <?php if ($lookupError): ?>
            <div class="alert alert-error"><?= e($lookupError) ?></div>
        <?php endif; ?>
        
        <div class="form-wrapper">
            <form method="post">
                <?= csrf_field() ?>
                <?= public_form_field() ?>
                <div class="form-group">
                    <label class="form-label">Số điện thoại đặt hàng</label>
                    <input class="form-control" type="text" name="contact_phone" value="<?= e($_POST['contact_phone'] ?? '') ?>" placeholder="Nhập số điện thoại đã đặt đơn...">
                </div>
                <div class="form-group">
                    <label class="form-label">Mã đơn hàng</label>
                    <input class="form-control" type="text" name="order_code" value="<?= e($_POST['order_code'] ?? '') ?>" placeholder="VD: DH25010100001">
                </div>
                <button class="btn-primary" type="submit">Tra cứu đơn</button>
            </form>
        </div>

        <?php if (!empty($lookupOrders)): ?>
            <div class="alert alert-success">
                Đã tìm thấy <?= count($lookupOrders) ?> đơn hàng phù hợp với thông tin của bạn.
            </div>
            <table class="data-table responsive-table">
                <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Ngày đặt</th>
                        <th>Trạng thái</th>
                        <th>Tổng tiền</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($lookupOrders as $o): ?>
                        <?php $ordStatusLookup = $statusMap[$o['order_status']] ?? $o['order_status']; ?>
                        <tr>
                            <td data-label="Mã đơn" class="text-highlight">#<?= e($o['order_code']) ?></td>
                            <td data-label="Ngày đặt" class="text-date"><?= e(date('d/m/Y H:i', strtotime($o['placed_at']))) ?></td>
                            <td data-label="Trạng thái">
                                <span class="badge <?= get_order_status_badge_class($ordStatusLookup) ?>"><?= e($ordStatusLookup) ?></span>
                            </td>
                            <td data-label="Tổng tiền" class="text-price"><?= format_price($o['total_amount']) ?></td>
                            <td data-label="">
                                <a class="btn-secondary" href="<?= route_url('/order.php') ?>?code=<?= urlencode($o['order_code']) ?>&token=<?= urlencode($o['guest_access_token'] ?? '') ?>">Chi tiết</a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>