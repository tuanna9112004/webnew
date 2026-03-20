<?php
require_once __DIR__ . '/includes/functions.php';

$pageTitle = 'Checkout';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$missing = require_upgrade_tables(['carts', 'cart_items', 'orders', 'order_items', 'order_addresses', 'order_status_logs', 'payment_intents']);
$customer = current_customer();
$message = flash_get('checkout_notice');
$error = null;

if (!$customer && !guest_checkout_enabled()) {
    $returnTo = $_SERVER['REQUEST_URI'] ?? '/checkout.php';
    redirect('/customer/login.php?redirect=' . urlencode($returnTo));
}

$productId = (int)($_GET['product_id'] ?? $_POST['product_id'] ?? 0);
$variantId = !empty($_GET['variant_id']) ? (int)$_GET['variant_id'] : (!empty($_POST['variant_id']) ? (int)$_POST['variant_id'] : null);
$quantity = max(1, (int)($_GET['quantity'] ?? $_POST['quantity'] ?? 1));
$isBuyNow = $productId > 0;

$product = $isBuyNow ? get_product($productId) : null;
if ($isBuyNow && !$product) {
    http_response_code(404);
    exit('Không tìm thấy sản phẩm để checkout.');
}

$cart = !$missing && !$isBuyNow ? get_current_cart(false) : null;
$cartTotals = $cart ? get_cart_totals((int)$cart['id']) : ['items' => [], 'item_count' => 0, 'subtotal' => 0, 'shipping_fee' => 0, 'discount_amount' => 0, 'total' => 0];
$cartItems = $cartTotals['items'] ?? [];
if (!$missing && !$isBuyNow && !$cartItems) {
    flash_set('cart_notice', 'Giỏ hàng đang trống. Hãy chọn sản phẩm trước khi checkout.', 'warning');
    redirect('/cart.php');
}

$availableVariants = $product ? get_product_variants((int)$product['id']) : [];
$selectedVariant = null;
if ($product) {
    $selectedVariant = $variantId ? get_product_variant((int)$variantId, (int)$product['id']) : null;
    if (!$selectedVariant) {
        $selectedVariant = $availableVariants[0] ?? ensure_default_product_variant($product);
    }
}

$savedAddresses = $customer ? get_customer_addresses((int)$customer['id']) : [];
$defaultAddress = $savedAddresses[0] ?? null;
$form = [
    'contact_name' => old_input('contact_name', $customer['full_name'] ?? ''),
    'contact_phone' => old_input('contact_phone', $customer['phone'] ?? ''),
    'contact_email' => old_input('contact_email', $customer['email'] ?? ''),
    'receiver_name' => old_input('receiver_name', $defaultAddress['receiver_name'] ?? ($customer['full_name'] ?? '')),
    'receiver_phone' => old_input('receiver_phone', $defaultAddress['receiver_phone'] ?? ($customer['phone'] ?? '')),
    'province_name' => old_input('province_name', $defaultAddress['province_name'] ?? ''),
    'district_name' => old_input('district_name', $defaultAddress['district_name'] ?? ''),
    'ward_name' => old_input('ward_name', $defaultAddress['ward_name'] ?? ''),
    'address_line' => old_input('address_line', $defaultAddress['address_line'] ?? ''),
    'address_note' => old_input('address_note', $defaultAddress['address_note'] ?? ''),
    'customer_note' => old_input('customer_note', ''),
    'payment_plan' => old_input('payment_plan', 'full'),
    'address_source' => old_input('address_source', $customer && $defaultAddress ? 'saved' : 'manual'),
    'saved_address_id' => old_input('saved_address_id', $defaultAddress['id'] ?? ''),
];
$requestId = trim((string)($_POST['request_id'] ?? ''));
if ($requestId === '') {
    $requestId = bin2hex(random_bytes(16));
}

if (!$missing && is_post()) {
    verify_public_or_customer_form_or_fail();

    if (!$customer && !guest_checkout_enabled()) {
        $returnTo = $_SERVER['REQUEST_URI'] ?? '/checkout.php';
        redirect('/customer/login.php?redirect=' . urlencode($returnTo));
    }

    $result = $isBuyNow
        ? create_order_from_product_checkout($product, $_POST, $customer)
        : create_order_from_cart_checkout($cart, $_POST, $customer);

    if (!empty($result['ok'])) {
        $query = ['code' => $result['order_code'] ?? ''];
        if (!$customer && !empty($result['guest_access_token'])) {
            $query['token'] = $result['guest_access_token'];
        }
        header('Location: ' . route_url('/order.php?' . http_build_query($query)));
        exit;
    }

    $error = $result['message'] ?? 'Không thể tạo đơn hàng. Vui lòng thử lại.';
}

if ($isBuyNow) {
    $unitPrice = calculate_variant_display_price($product, $selectedVariant);
    $subtotal = format_order_money($unitPrice * $quantity);
    $shippingFee = calculate_checkout_shipping_fee($subtotal);
    $totalAmount = format_order_money($subtotal + $shippingFee);
} else {
    $subtotal = (float)$cartTotals['subtotal'];
    $shippingFee = (float)$cartTotals['shipping_fee'];
    $totalAmount = (float)$cartTotals['total'];
}
$depositAmount = format_order_money(ceil((float)$totalAmount * shop_deposit_rate() / 100));

require_once __DIR__ . '/includes/header.php';
?>
<style>
.checkout-page { padding: 24px 16px; max-width: 1180px; margin: 0 auto; }
.checkout-grid { display:grid; grid-template-columns: minmax(0,1.35fr) minmax(320px,0.9fr); gap: 24px; align-items:start; }
.checkout-section { background:#fff; border:1px solid #e5e7eb; border-radius:18px; padding:20px; box-shadow:0 10px 30px rgba(15,23,42,.05); }
.checkout-title { font-size:24px; font-weight:800; margin:0 0 8px; }
.checkout-subtitle { color:#64748b; margin:0 0 18px; line-height:1.6; }
.checkout-form-grid { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
.checkout-form-grid .full { grid-column:1 / -1; }
.checkout-form-grid .stack { display:flex; flex-direction:column; gap:8px; }
.summary-list { display:flex; flex-direction:column; gap:12px; }
.summary-item { display:flex; gap:12px; padding:12px 0; border-bottom:1px dashed #e5e7eb; }
.summary-item:last-child { border-bottom:none; }
.summary-thumb { width:72px; height:72px; border-radius:12px; overflow:hidden; flex:0 0 72px; background:#f8fafc; }
.summary-thumb img { width:100%; height:100%; object-fit:cover; }
.summary-meta { min-width:0; flex:1; }
.summary-name { font-weight:700; margin-bottom:6px; }
.summary-variant { font-size:13px; color:#64748b; margin-bottom:4px; }
.summary-price { font-weight:700; color:#ef4444; }
.checkout-summary-box { background:#f8fafc; border-radius:16px; padding:16px; }
.checkout-row { display:flex; align-items:center; justify-content:space-between; gap:12px; padding:8px 0; }
.checkout-row.total { font-size:18px; font-weight:800; }
.checkout-help { margin-top:14px; font-size:14px; line-height:1.7; color:#475569; }
.saved-address { border:1px solid #e5e7eb; border-radius:12px; padding:12px; margin-bottom:12px; background:#fafafa; }
.submit-btn[disabled] { opacity:.6; cursor:not-allowed; }
@media (max-width: 900px) {
    .checkout-grid { grid-template-columns:1fr; }
    .checkout-form-grid { grid-template-columns:1fr; }
}
</style>

<div class="checkout-page">
    <?php if ($missing): ?>
        <div class="alert alert-warning">Thiếu bảng hệ thống mới: <?= e(implode(', ', $missing)) ?>.</div>
    <?php endif; ?>

    <?php if ($message): ?>
        <div class="alert alert-<?= e($message['type'] === 'success' ? 'success' : ($message['type'] === 'warning' ? 'warning' : 'info')) ?>"><?= e($message['message']) ?></div>
    <?php endif; ?>

    <?php if ($error): ?>
        <div class="alert alert-error"><?= e($error) ?></div>
    <?php endif; ?>

    <div class="checkout-grid">
        <section class="checkout-section">
            <h1 class="checkout-title">Thanh toán nhanh</h1>
            <p class="checkout-subtitle">
                <?= $customer ? 'Bạn đang checkout bằng tài khoản của mình.' : 'Bạn có thể đặt hàng nhanh không cần đăng nhập. Sau khi đặt xong, bạn vẫn tra cứu đơn hàng được bằng mã đơn + số điện thoại.' ?>
            </p>

            <form method="post" id="checkoutForm">
                <?= csrf_field() ?>
                <?= public_form_field() ?>
                <?= checkout_request_field($requestId) ?>

                <?php if ($isBuyNow): ?>
                    <input type="hidden" name="product_id" value="<?= (int)$product['id'] ?>">
                    <input type="hidden" name="variant_id" value="<?= (int)($selectedVariant['id'] ?? 0) ?>">
                    <input type="hidden" name="quantity" value="<?= (int)$quantity ?>">
                <?php endif; ?>

                <div class="checkout-form-grid">
                    <div class="stack">
                        <label class="form-label">Họ tên đặt hàng *</label>
                        <input class="form-control" type="text" name="contact_name" value="<?= e($form['contact_name']) ?>" required>
                    </div>
                    <div class="stack">
                        <label class="form-label">Số điện thoại *</label>
                        <input class="form-control" type="text" name="contact_phone" value="<?= e($form['contact_phone']) ?>" required>
                    </div>
                    <div class="stack full">
                        <label class="form-label">Email</label>
                        <input class="form-control" type="email" name="contact_email" value="<?= e($form['contact_email']) ?>" placeholder="Không bắt buộc">
                    </div>

                    <?php if ($customer && $savedAddresses): ?>
                        <div class="full">
                            <label class="form-label">Chọn địa chỉ</label>
                            <div class="saved-address">
                                <label style="display:flex; gap:10px; align-items:flex-start;">
                                    <input type="radio" name="address_source" value="saved" <?= $form['address_source'] === 'saved' ? 'checked' : '' ?>>
                                    <span>Dùng địa chỉ đã lưu gần nhất.</span>
                                </label>
                                <input type="hidden" name="saved_address_id" value="<?= (int)($defaultAddress['id'] ?? 0) ?>">
                                <?php if ($defaultAddress): ?>
                                    <div style="margin-top:8px; color:#475569;">
                                        <?= e($defaultAddress['receiver_name']) ?> - <?= e($defaultAddress['receiver_phone']) ?><br>
                                        <?= e($defaultAddress['address_line']) ?>, <?= e($defaultAddress['ward_name']) ?>, <?= e($defaultAddress['district_name']) ?>, <?= e($defaultAddress['province_name']) ?>
                                    </div>
                                <?php endif; ?>
                            </div>
                            <label style="display:flex; gap:10px; align-items:flex-start;">
                                <input type="radio" name="address_source" value="manual" <?= $form['address_source'] !== 'saved' ? 'checked' : '' ?>>
                                <span>Nhập địa chỉ mới cho đơn này.</span>
                            </label>
                        </div>
                    <?php endif; ?>

                    <div class="stack">
                        <label class="form-label">Người nhận *</label>
                        <input class="form-control" type="text" name="receiver_name" value="<?= e($form['receiver_name']) ?>" required>
                    </div>
                    <div class="stack">
                        <label class="form-label">SĐT nhận hàng *</label>
                        <input class="form-control" type="text" name="receiver_phone" value="<?= e($form['receiver_phone']) ?>" required>
                    </div>
                    <div class="stack">
                        <label class="form-label">Tỉnh / Thành *</label>
                        <input class="form-control" type="text" name="province_name" value="<?= e($form['province_name']) ?>" required>
                    </div>
                    <div class="stack">
                        <label class="form-label">Quận / Huyện *</label>
                        <input class="form-control" type="text" name="district_name" value="<?= e($form['district_name']) ?>" required>
                    </div>
                    <div class="stack">
                        <label class="form-label">Phường / Xã *</label>
                        <input class="form-control" type="text" name="ward_name" value="<?= e($form['ward_name']) ?>" required>
                    </div>
                    <div class="stack full">
                        <label class="form-label">Địa chỉ chi tiết *</label>
                        <input class="form-control" type="text" name="address_line" value="<?= e($form['address_line']) ?>" required>
                    </div>
                    <div class="stack full">
                        <label class="form-label">Ghi chú giao hàng</label>
                        <input class="form-control" type="text" name="address_note" value="<?= e($form['address_note']) ?>" placeholder="Ví dụ: gọi trước khi giao">
                    </div>
                    <div class="stack full">
                        <label class="form-label">Ghi chú cho shop</label>
                        <textarea class="form-control" name="customer_note" rows="3" placeholder="Không bắt buộc"><?= e($form['customer_note']) ?></textarea>
                    </div>
                    <div class="stack full">
                        <label class="form-label">Phương thức thanh toán</label>
                        <select class="form-control" name="payment_plan">
                            <option value="full" <?= $form['payment_plan'] === 'full' ? 'selected' : '' ?>>Thanh toán toàn bộ</option>
                            <option value="deposit_30" <?= $form['payment_plan'] === 'deposit_30' ? 'selected' : '' ?>>Đặt cọc <?= (int)shop_deposit_rate() ?>%</option>
                        </select>
                    </div>
                </div>

                <div style="display:flex; gap:12px; flex-wrap:wrap; margin-top:20px;">
                    <button class="btn-primary submit-btn" type="submit" id="checkoutSubmitBtn">Đặt hàng ngay</button>
                    <a class="btn-secondary" href="<?= $isBuyNow ? route_url('/product.php?id=' . (int)$product['id']) : route_url('/cart.php') ?>">Quay lại</a>
                </div>
            </form>
        </section>

        <aside class="checkout-section">
            <h2 class="checkout-title" style="font-size:20px;">Tóm tắt đơn hàng</h2>

            <div class="summary-list">
                <?php if ($isBuyNow): ?>
                    <div class="summary-item">
                        <div class="summary-thumb">
                            <img src="<?= e(resolve_media_url($selectedVariant['image_url'] ?? ($product['thumbnail'] ?? ''))) ?>" alt="<?= e($product['product_name']) ?>">
                        </div>
                        <div class="summary-meta">
                            <div class="summary-name"><?= e($product['product_name']) ?></div>
                            <div class="summary-variant">
                                <?= e($selectedVariant ? build_variant_label($selectedVariant, $product) : 'Mặc định') ?> · SL: <?= (int)$quantity ?>
                            </div>
                            <div class="summary-price"><?= format_price($unitPrice) ?></div>
                        </div>
                    </div>
                <?php else: ?>
                    <?php foreach ($cartItems as $item): ?>
                        <div class="summary-item">
                            <div class="summary-thumb">
                                <img src="<?= e(resolve_media_url($item['effective_image'] ?: $item['thumbnail'])) ?>" alt="<?= e($item['product_name']) ?>">
                            </div>
                            <div class="summary-meta">
                                <div class="summary-name"><?= e($item['product_name']) ?></div>
                                <div class="summary-variant">
                                    <?= e(build_variant_label([
                                        'variant_name' => $item['variant_name'],
                                        'size_value' => $item['size_value'],
                                        'color_value' => $item['color_value'],
                                    ])) ?> · SL: <?= (int)$item['quantity'] ?>
                                </div>
                                <div class="summary-price"><?= format_price($item['unit_price_snapshot']) ?></div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>

            <div class="checkout-summary-box">
                <div class="checkout-row"><span>Tạm tính</span><strong><?= format_price($subtotal) ?></strong></div>
                <div class="checkout-row"><span>Phí ship dự kiến</span><strong><?= format_price($shippingFee) ?></strong></div>
                <div class="checkout-row"><span>Giảm giá</span><strong>0 đ</strong></div>
                <hr style="border:none;border-top:1px solid #e5e7eb;margin:10px 0;">
                <div class="checkout-row total"><span>Tổng thanh toán</span><strong><?= format_price($totalAmount) ?></strong></div>
                <div class="checkout-row"><span>Cọc dự kiến <?= (int)shop_deposit_rate() ?>%</span><strong><?= format_price($depositAmount) ?></strong></div>
            </div>

            <div class="checkout-help">
                Sau khi đặt xong, hệ thống sẽ tạo mã đơn và hướng bạn sang trang chi tiết đơn hàng. Nếu bạn mua với tư cách khách, hãy lưu lại mã đơn hoặc tra cứu lại bằng số điện thoại.
            </div>
        </aside>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('checkoutForm');
    const submitBtn = document.getElementById('checkoutSubmitBtn');
    if (!form || !submitBtn) return;

    const key = 'dmm_checkout_draft';
    const fields = [
        'contact_name','contact_phone','contact_email','receiver_name','receiver_phone',
        'province_name','district_name','ward_name','address_line','address_note',
        'customer_note','payment_plan','address_source'
    ];

    try {
        const saved = JSON.parse(localStorage.getItem(key) || '{}');
        fields.forEach(function(name) {
            const el = form.querySelector('[name="' + name + '"]');
            if (!el) return;
            if ((el.type === 'radio')) {
                if (saved[name] && el.value === saved[name]) {
                    el.checked = true;
                }
                return;
            }
            if (!el.value && saved[name]) {
                el.value = saved[name];
            }
        });
    } catch (e) {}

    form.addEventListener('input', function () {
        const data = {};
        fields.forEach(function(name) {
            const el = form.querySelector('[name="' + name + '"]');
            if (!el) return;
            if (el.type === 'radio') {
                const checked = form.querySelector('[name="' + name + '"]:checked');
                data[name] = checked ? checked.value : '';
                return;
            }
            data[name] = el.value;
        });
        localStorage.setItem(key, JSON.stringify(data));
    });

    form.addEventListener('submit', function () {
        submitBtn.disabled = true;
        submitBtn.textContent = 'Đang xử lý...';
    });
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
