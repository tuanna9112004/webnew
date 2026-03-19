<?php
require_once __DIR__ . '/../includes/functions.php';
$pageTitle = 'Tra cứu đơn hàng';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$missing = require_upgrade_tables(['orders']);
$customer = current_customer();
$orders = [];
$lookupError = null;
$lookupOrders = []; // Đổi từ 1 đơn thành mảng để chứa nhiều đơn

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
    verify_csrf_or_fail();
    $orderCode = trim((string)($_POST['order_code'] ?? ''));
    $phone = normalize_phone($_POST['contact_phone'] ?? null);
    
    // Yêu cầu bắt buộc SĐT, Mã đơn không bắt buộc
    if (!$phone) {
        $lookupError = 'Vui lòng nhập số điện thoại hợp lệ để tra cứu.';
    } else {
        if ($orderCode !== '') {
            // Nếu có nhập mã đơn -> Tìm chính xác 1 đơn
            $stmt = db()->prepare('SELECT * FROM orders WHERE order_code = ? AND contact_phone = ? LIMIT 1');
            $stmt->execute([$orderCode, $phone]);
            $lookupOrders = $stmt->fetchAll();
        } else {
            // Nếu chỉ nhập SĐT -> Lấy danh sách các đơn của SĐT này (Giới hạn 20 đơn gần nhất)
            $stmt = db()->prepare('SELECT * FROM orders WHERE contact_phone = ? ORDER BY id DESC LIMIT 20');
            $stmt->execute([$phone]);
            $lookupOrders = $stmt->fetchAll();
        }
        
        if (empty($lookupOrders)) {
            $lookupError = 'Không tìm thấy đơn hàng nào phù hợp với số điện thoại này.';
        }
    }
}

require_once __DIR__ . '/../includes/header.php';
?>

<style>
/* CSS Tối ưu Mobile và Badge màu sắc */
.badge {
    padding: 4px 10px;
    border-radius: 9999px;
    font-size: 12px;
    font-weight: 600;
    display: inline-block;
    white-space: nowrap;
}
.badge-warning { background-color: #fef08a; color: #854d0e; } /* Vàng */
.badge-info { background-color: #dbeafe; color: #1e40af; } /* Xanh dương */
.badge-success { background-color: #dcfce3; color: #166534; } /* Xanh lá */
.badge-danger { background-color: #fee2e2; color: #991b1b; } /* Đỏ */
.badge-default { background-color: #f3f4f6; color: #374151; } /* Xám */

/* Table Responsive cho Mobile */
@media (max-width: 768px) {
    .responsive-table thead {
        display: none;
    }
    .responsive-table, .responsive-table tbody, .responsive-table tr, .responsive-table td {
        display: block;
        width: 100%;
    }
    .responsive-table tr {
        margin-bottom: 16px;
        border: 1px solid #e5e7eb;
        border-radius: 12px;
        padding: 12px;
        background: #fff;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    .responsive-table td {
        text-align: right;
        padding: 8px 0;
        position: relative;
        border-bottom: 1px dashed #e5e7eb;
        min-height: 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .responsive-table td:last-child {
        border-bottom: none;
        justify-content: flex-end;
    }
    .responsive-table td::before {
        content: attr(data-label);
        text-align: left;
        font-weight: 600;
        color: #6b7280;
        font-size: 13px;
    }
    .form-group input, .btn-primary {
        width: 100%;
        box-sizing: border-box;
    }
}
</style>

<div class="account-shell" style="padding-top:24px;">
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
                                <td data-label="Mã đơn" style="font-weight: 700; color: #4f46e5;">#<?= e($order['order_code']) ?></td>
                                <td data-label="Ngày đặt"><?= e(date('d/m/Y H:i', strtotime($order['placed_at']))) ?></td>
                                <td data-label="Tổng tiền" style="font-weight: 700; color: #ef4444;"><?= format_price($order['total_amount']) ?></td>
                                <td data-label="Thanh toán"><span class="badge <?= get_payment_status_badge_class($payStatus) ?>"><?= e($payStatus) ?></span></td>
                                <td data-label="Trạng thái"><span class="badge <?= get_order_status_badge_class($ordStatus) ?>"><?= e($ordStatus) ?></span></td>
                                <td data-label="">
                                    <a class="btn-secondary" style="display: inline-block; padding: 6px 12px; background: #f3f4f6; color: #111827; border-radius: 6px; text-decoration: none; font-weight: 600; font-size: 13px;" href="<?= route_url('/order.php') ?>?code=<?= urlencode($order['order_code']) ?>">Xem chi tiết</a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php endif; ?>
        </div>
    <?php endif; ?>

    <div class="account-card mt-24" style="max-width:800px; margin-bottom: 40px;">
        <h2 class="section-title" style="font-size:20px;">Tra cứu đơn hàng</h2>
        <p class="section-subtitle">Tra cứu bằng số điện thoại (dành cho khách mua không cần đăng nhập).</p>
        
        <?php if ($lookupError): ?>
            <div class="alert alert-error" style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 12px; border-radius: 8px; margin-bottom: 16px;">
                <?= e($lookupError) ?>
            </div>
        <?php endif; ?>
        
        <form method="post" style="margin-bottom: 24px; padding-bottom: 24px; border-bottom: 1px dashed #e5e7eb;">
            <?= csrf_field() ?>
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label" style="font-weight: 600; display: block; margin-bottom: 6px;">Số điện thoại đặt hàng <span style="color: red;">*</span></label>
                <input class="form-control" type="text" name="contact_phone" value="<?= e($_POST['contact_phone'] ?? '') ?>" required placeholder="Nhập số điện thoại của bạn..." style="width: 100%; padding: 12px 14px; border-radius: 8px; border: 1px solid #d1d5db; font-size: 16px;">
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label" style="font-weight: 600; display: block; margin-bottom: 6px;">Mã đơn hàng (Không bắt buộc)</label>
                <input class="form-control" type="text" name="order_code" value="<?= e($_POST['order_code'] ?? '') ?>" placeholder="VD: DH25010100001" style="width: 100%; padding: 12px 14px; border-radius: 8px; border: 1px solid #d1d5db; font-size: 16px;">
            </div>
            <button class="btn-primary" type="submit" style="padding: 12px 24px; background: #111827; color: #fff; border: none; border-radius: 8px; cursor: pointer; font-weight: 600;">Tra cứu đơn</button>
        </form>

        <?php if (!empty($lookupOrders)): ?>
            <div class="alert alert-success" style="background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 12px; border-radius: 8px; margin-bottom: 16px; font-weight: 500;">
                Đã tìm thấy <?= count($lookupOrders) ?> đơn hàng khớp với số điện thoại của bạn.
            </div>
            <table class="data-table responsive-table" style="width: 100%; border-collapse: collapse; text-align: left;">
                <thead>
                    <tr style="border-bottom: 2px solid #e5e7eb;">
                        <th style="padding: 12px 8px; color: #6b7280; text-transform: uppercase; font-size: 12px;">Mã đơn</th>
                        <th style="padding: 12px 8px; color: #6b7280; text-transform: uppercase; font-size: 12px;">Ngày đặt</th>
                        <th style="padding: 12px 8px; color: #6b7280; text-transform: uppercase; font-size: 12px;">Trạng thái</th>
                        <th style="padding: 12px 8px; color: #6b7280; text-transform: uppercase; font-size: 12px;">Tổng tiền</th>
                        <th style="padding: 12px 8px;"></th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($lookupOrders as $o): ?>
                        <?php $ordStatusLookup = $statusMap[$o['order_status']] ?? $o['order_status']; ?>
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td data-label="Mã đơn" style="padding: 14px 8px; font-weight: 700; color: #4f46e5;">#<?= e($o['order_code']) ?></td>
                            <td data-label="Ngày đặt" style="padding: 14px 8px; color: #475569;"><?= e(date('d/m/Y H:i', strtotime($o['placed_at']))) ?></td>
                            <td data-label="Trạng thái" style="padding: 14px 8px; font-weight: 500;">
                                <span class="badge <?= get_order_status_badge_class($ordStatusLookup) ?>"><?= e($ordStatusLookup) ?></span>
                            </td>
                            <td data-label="Tổng tiền" style="padding: 14px 8px; font-weight: 700; color: #ef4444;"><?= format_price($o['total_amount']) ?></td>
                            <td data-label="" style="padding: 14px 8px; text-align: right;">
                                <a style="display: inline-block; padding: 6px 12px; background: #f3f4f6; color: #111827; border-radius: 6px; text-decoration: none; font-weight: 600; font-size: 13px;" href="<?= route_url('/order.php') ?>?code=<?= urlencode($o['order_code']) ?>&token=<?= urlencode($o['guest_access_token'] ?? '') ?>">Chi tiết</a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>