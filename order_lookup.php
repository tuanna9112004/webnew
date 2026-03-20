<?php
require_once __DIR__ . '/includes/functions.php';
$pageTitle = 'Tra cứu đơn hàng';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$missing = require_upgrade_tables(['orders']);
$lookupError = null;
$lookupOrders = [];

if (!$missing && is_post()) {
    verify_public_or_customer_form_or_fail();
    $orderCode = trim((string)($_POST['order_code'] ?? ''));
    $phone = normalize_phone($_POST['contact_phone'] ?? null);

    if ($orderCode === '' || !$phone) {
        $lookupError = 'Vui lòng nhập đồng thời Mã đơn hàng và Số điện thoại để tra cứu.';
    } else {
        $found = get_order_by_code_and_phone($orderCode, $phone);
        $lookupOrders = $found ? [$found] : [];
        if (!$lookupOrders) {
            $lookupError = 'Không tìm thấy đơn hàng nào phù hợp với thông tin tra cứu.';
        }
    }
}

require_once __DIR__ . '/includes/header.php';
?>
<div class="account-shell" style="padding:24px 16px; max-width:800px; margin:0 auto;">
    <?php if ($missing): ?>
        <div class="alert alert-warning">Thiếu bảng hệ thống mới: <?= e(implode(', ', $missing)) ?>.</div>
    <?php endif; ?>

    <div class="checkout-card">
        <h1 class="section-title">Tra cứu đơn hàng</h1>
        <p class="section-subtitle">Nhập mã đơn hàng và số điện thoại đã đặt để xem trạng thái mới nhất.</p>

        <?php if ($lookupError): ?>
            <div class="alert alert-error"><?= e($lookupError) ?></div>
        <?php endif; ?>

        <form method="post" class="checkout-card" style="padding:18px; border:1px solid #e5e7eb; border-radius:16px; background:#fff;">
            <?= csrf_field() ?>
            <?= public_form_field() ?>
            <div class="form-group">
                <label class="form-label">Mã đơn hàng</label>
                <input class="form-control" type="text" name="order_code" value="<?= e($_POST['order_code'] ?? '') ?>" placeholder="VD: DH260320ABC123">
            </div>
            <div class="form-group">
                <label class="form-label">Số điện thoại đặt hàng</label>
                <input class="form-control" type="text" name="contact_phone" value="<?= e($_POST['contact_phone'] ?? '') ?>" placeholder="Nhập số điện thoại đã dùng khi đặt hàng">
            </div>
            <button class="btn-primary" type="submit">Tra cứu đơn</button>
        </form>

        <?php if (!empty($lookupOrders)): ?>
            <div class="alert alert-success" style="margin-top:16px;">Đã tìm thấy <?= count($lookupOrders) ?> đơn hàng phù hợp.</div>
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
                    <?php $ordStatusLookup = (order_status_options()[$o['order_status']][0] ?? $o['order_status']); ?>
                    <tr>
                        <td data-label="Mã đơn" class="text-highlight">#<?= e($o['order_code']) ?></td>
                        <td data-label="Ngày đặt" class="text-date"><?= e(date('d/m/Y H:i', strtotime($o['placed_at']))) ?></td>
                        <td data-label="Trạng thái"><span class="badge badge-info"><?= e($ordStatusLookup) ?></span></td>
                        <td data-label="Tổng tiền" class="text-price"><?= format_price($o['total_amount']) ?></td>
                        <td data-label="">
                            <a class="btn-secondary" href="<?= route_url('/order.php') ?>?code=<?= urlencode($o['order_code']) ?>&phone=<?= urlencode((string)$o['contact_phone']) ?>">Chi tiết</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</div>
<?php require_once __DIR__ . '/includes/footer.php'; ?>
