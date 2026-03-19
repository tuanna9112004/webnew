<?php
require_once __DIR__ . '/includes/functions.php';

$pageTitle = 'Thanh toán đơn hàng';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$missing = require_upgrade_tables(['orders', 'order_items', 'order_addresses', 'payment_intents']);
$customer = current_customer();
$addresses = $customer ? get_customer_addresses((int)$customer['id']) : [];
$error = null;
$mode = 'cart';
$productId = (int)($_GET['product_id'] ?? $_POST['product_id'] ?? 0);
$selectedVariantId = (int)($_GET['variant_id'] ?? $_POST['variant_id'] ?? 0);
$product = $productId > 0 ? get_product($productId) : null;
$selectedVariant = ($product && $selectedVariantId > 0) ? get_product_variant($selectedVariantId, $productId) : null;
$cart = !$missing ? get_current_cart(false) : null;
$cartTotals = ($cart && !$missing) ? get_cart_totals((int)$cart['id']) : ['items' => [], 'item_count' => 0, 'subtotal' => 0, 'total' => 0, 'shipping_fee' => 0, 'discount_amount' => 0];

if (!$cartTotals['items'] && $product) {
    $mode = 'single';
}

if (!$missing && is_post()) {
    verify_csrf_or_fail();
    if ($mode === 'cart' && $cart && $cartTotals['items']) {
        $result = create_order_from_cart_checkout($cart, $_POST, $customer);
    } elseif ($product) {
        $result = create_order_from_product_checkout($product, $_POST, $customer);
    } else {
        $result = ['ok' => false, 'message' => 'Giỏ hàng đang trống.'];
    }

    if ($result['ok']) {
        $url = route_url('/order.php?code=' . urlencode($result['order_code']));
        if (!$customer) {
            $url .= '&token=' . urlencode($result['guest_access_token']);
        }
        header('Location: ' . $url);
        exit;
    }
    $error = $result['message'] ?? 'Không thể tạo đơn hàng.';
}

if ($mode === 'single' && !$product) {
    http_response_code(404);
    exit('Không tìm thấy dữ liệu để thanh toán.');
}

if ($mode === 'cart') {
    $totalPreview = (float)$cartTotals['total'];
    $depositPreview = ceil($totalPreview * shop_deposit_rate() / 100);
} else {
    $price = calculate_variant_display_price($product, $selectedVariant);
    $quantityPreview = max(1, (int)($_POST['quantity'] ?? $_GET['quantity'] ?? 1));
    $totalPreview = $price * $quantityPreview;
    $depositPreview = ceil($totalPreview * shop_deposit_rate() / 100);
}

require_once __DIR__ . '/includes/header.php';
?>

<style>
/* CSS cho phần chọn phương thức thanh toán to hơn */
.payment-options-container {
    display: flex;
    flex-direction: column;
    gap: 16px;
    margin-top: 10px;
}
.payment-option-label {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 18px 20px;
    border: 2px solid #e5e7eb;
    border-radius: 12px;
    background: #fff;
    font-size: 17px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
}
.payment-option-label input[type="radio"] {
    width: 24px;
    height: 24px;
    margin: 0;
    cursor: pointer;
    accent-color: #0f172a; /* Đổi màu xanh đen cho nút tick, có thể thay đổi */
}
.payment-option-label:hover {
    border-color: #cbd5e1;
    background: #f8fafc;
}
/* Hiệu ứng khi được chọn (hoạt động tốt trên trình duyệt hiện đại) */
.payment-option-label:has(input:checked) {
    border-color: #0f172a;
    background: #f8fafc;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

/* Tối ưu giao diện Mobile cho trang thanh toán */
@media (max-width: 768px) {
    .grid-2 {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }
    .checkout-card {
        padding: 16px;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }
    .form-group {
        margin-bottom: 12px;
    }
    .form-control, .form-select, .form-textarea {
        font-size: 16px; /* Ngăn iOS tự zoom khi tap vào input */
        padding: 12px;
        border-radius: 8px;
    }
    .btn-primary, .btn-secondary {
        width: 100%;
        text-align: center;
        padding: 14px;
        font-size: 16px;
        font-weight: 600;
        border-radius: 8px;
    }
    .inline-radio {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .inline-radio label {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px;
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        background: #f9fafb;
    }
    .cart-item-card.compact {
        align-items: flex-start;
    }
    .summary-box {
        background: #f8fafc;
        padding: 16px;
        border-radius: 8px;
    }
}
</style>

<div class="checkout-shell" style="padding-top:24px;">
    <?php if ($missing): ?>
        <div class="alert alert-warning">Thiếu bảng hệ thống mới: <?= e(implode(', ', $missing)) ?>. Hãy import file migration trước khi checkout.</div>
    <?php endif; ?>
    <?php if ($error): ?>
        <div class="alert alert-error"><?= e($error) ?></div>
    <?php endif; ?>

    <?php if ($mode === 'cart' && empty($cartTotals['items'])): ?>
        <div class="alert alert-info">Giỏ hàng đang trống. <a class="link-muted" href="<?= route_url('/index.php#product-list') ?>">Quay lại gian hàng</a> hoặc <a class="link-muted" href="<?= route_url('/cart.php') ?>">xem giỏ hàng</a>.</div>
    <?php else: ?>
    <div class="grid-2">
        <div class="checkout-card">
            <h1 class="section-title">Thanh toán trên web</h1>
            <p class="section-subtitle"><?= $mode === 'cart' ? 'Đơn hàng sẽ gom toàn bộ sản phẩm trong giỏ vào một đơn duy nhất.' : 'Bạn có thể chọn cọc 30% hoặc thanh toán toàn bộ đơn hàng.' ?></p>
            <?php if (!$customer): ?>
                <div class="alert alert-info">Bạn có thể mua không cần đăng nhập. Muốn lưu thông tin và xem lịch sử đơn? <a class="link-muted" href="<?= route_url('/customer/login.php') ?>">Đăng nhập</a> hoặc <a class="link-muted" href="<?= route_url('/customer/register.php') ?>">tạo tài khoản</a>.</div>
            <?php endif; ?>

            <form method="post" id="checkoutForm">
                <?= csrf_field() ?>
                <?php if ($mode === 'single'): ?>
                    <input type="hidden" name="product_id" value="<?= (int)$product['id'] ?>">
                    <?php if ($selectedVariant): ?><input type="hidden" name="variant_id" value="<?= (int)$selectedVariant['id'] ?>"><?php endif; ?>
                    <div class="form-group">
                        <label class="form-label">Số lượng</label>
                        <input class="form-control" type="number" name="quantity" min="1" value="<?= e((string)max(1, (int)old_input('quantity', '1'))) ?>">
                    </div>
                <?php endif; ?>

                <div class="grid-2">
                    <div class="form-group">
                        <label class="form-label">Họ và tên</label>
                        <input class="form-control" name="contact_name" value="<?= e(old_input('contact_name', $customer['full_name'] ?? '')) ?>">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số điện thoại</label>
                        <input class="form-control" name="contact_phone" value="<?= e(old_input('contact_phone', $customer['phone'] ?? '')) ?>">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <input class="form-control" name="contact_email" value="<?= e(old_input('contact_email', $customer['email'] ?? '')) ?>">
                    </div>
                    
                    <?php if ($customer && $addresses): ?>
                    <div class="form-group" style="grid-column: 1 / -1;">
                        <label class="form-label">Lấy địa chỉ đã lưu?</label>
                        <div class="inline-radio">
                            <label><input type="radio" name="address_source" value="saved" <?= old_input('address_source', 'saved') === 'saved' ? 'checked' : '' ?>> Dùng địa chỉ trong tài khoản</label>
                            <label><input type="radio" name="address_source" value="manual" <?= old_input('address_source') === 'manual' ? 'checked' : '' ?>> Nhập địa chỉ mới</label>
                        </div>
                    </div>
                    <?php endif; ?>
                </div>

                <?php if ($customer && $addresses): ?>
                <div class="form-group" id="savedAddressContainer">
                    <label class="form-label">Chọn địa chỉ đã lưu</label>
                    <select class="form-select" name="saved_address_id" id="savedAddressSelect">
                        <?php foreach ($addresses as $address): ?>
                            <option value="<?= (int)$address['id'] ?>" <?= (int)old_input('saved_address_id', (string)$address['id']) === (int)$address['id'] ? 'selected' : '' ?>>
                                <?= e($address['label'] ?: 'Địa chỉ') ?> — <?= e($address['receiver_name']) ?> — <?= e($address['address_line']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>

                <div class="grid-2">
                    <div class="form-group"><label class="form-label">Người nhận</label><input class="form-control" name="receiver_name" id="f_receiver_name" value="<?= e(old_input('receiver_name', $customer['full_name'] ?? '')) ?>"></div>
                    <div class="form-group"><label class="form-label">SĐT người nhận</label><input class="form-control" name="receiver_phone" id="f_receiver_phone" value="<?= e(old_input('receiver_phone', $customer['phone'] ?? '')) ?>"></div>
                    <div class="form-group"><label class="form-label">Tỉnh/Thành</label><input class="form-control" name="province_name" id="f_province_name" value="<?= e(old_input('province_name')) ?>"></div>
                    <div class="form-group"><label class="form-label">Quận/Huyện</label><input class="form-control" name="district_name" id="f_district_name" value="<?= e(old_input('district_name')) ?>"></div>
                    <div class="form-group"><label class="form-label">Phường/Xã</label><input class="form-control" name="ward_name" id="f_ward_name" value="<?= e(old_input('ward_name')) ?>"></div>
                    <div class="form-group"><label class="form-label">Ghi chú địa chỉ</label><input class="form-control" name="address_note" id="f_address_note" value="<?= e(old_input('address_note')) ?>"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Địa chỉ chi tiết</label>
                    <input class="form-control" name="address_line" id="f_address_line" value="<?= e(old_input('address_line')) ?>">
                </div>
                <div class="form-group">
                    <label class="form-label">Ghi chú thêm cho shop</label>
                    <textarea class="form-textarea" name="customer_note" placeholder="Ví dụ: Giao giờ hành chính, gọi trước khi giao...\n"><?= e(old_input('customer_note')) ?></textarea>
                </div>

                <div class="form-group mt-24">
                    <label class="form-label" style="font-size: 18px; font-weight: 700; color: #111827;">Chọn cách thanh toán trên web</label>
                    <div class="payment-options-container">
                        <label class="payment-option-label">
                            <input type="radio" name="payment_plan" value="deposit_30" <?= old_input('payment_plan', 'deposit_30') === 'deposit_30' ? 'checked' : '' ?>> 
                            <span>Cọc <?= (int)shop_deposit_rate() ?>%</span>
                        </label>
                        <label class="payment-option-label">
                            <input type="radio" name="payment_plan" value="full" <?= old_input('payment_plan') === 'full' ? 'checked' : '' ?>> 
                            <span>Thanh toán toàn bộ</span>
                        </label>
                    </div>
                </div>

                <div style="display:flex; gap:12px; flex-wrap:wrap; margin-top:24px;">
                    <button class="btn-primary" type="submit">Tạo đơn & chờ thanh toán</button>
                    <a class="btn-secondary" target="_blank" rel="noopener noreferrer" href="<?= e(shop_zalo_link()) ?>">Mua qua Zalo</a>
                </div>
            </form>
        </div>

        <div class="checkout-card">
            <h2 class="section-title" style="font-size:20px;">Tóm tắt đơn</h2>
            <?php if ($mode === 'cart'): ?>
                <div class="cart-list compact">
                    <?php foreach ($cartTotals['items'] as $item): ?>
                        <div class="cart-item-card compact">
                            <div class="cart-item-media compact"><img src="<?= e(resolve_media_url($item['effective_image'] ?: $item['thumbnail'])) ?>" alt="<?= e($item['product_name']) ?>"></div>
                            <div class="cart-item-main compact">
                                <div class="cart-item-title"><?= e($item['product_name']) ?></div>
                                <div class="cart-item-meta"><?= e(build_variant_label([
                                    'variant_name' => $item['variant_name'],
                                    'size_value' => $item['size_value'],
                                    'color_value' => $item['color_value'],
                                ])) ?></div>
                                <div class="cart-item-meta">SL: <?= (int)$item['quantity'] ?></div>
                            </div>
                            <div class="cart-item-price compact"><?= format_price((float)$item['unit_price_snapshot'] * (int)$item['quantity']) ?></div>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php else: ?>
                <div class="address-card" style="display:flex; gap:14px; align-items:flex-start;">
                    <img src="<?= e(resolve_media_url($product['thumbnail'])) ?>" alt="<?= e($product['product_name']) ?>" style="width:92px; height:110px; object-fit:cover; border-radius:12px; border:1px solid #e5e7eb;">
                    <div>
                        <div style="font-size:18px; font-weight:800;"><?= e($product['product_name']) ?></div>
                        <div style="color:#64748b; font-size:14px; margin-top:4px;">Mã: <?= e($product['product_code']) ?></div>
                        <div style="color:#111827; font-size:16px; font-weight:800; margin-top:10px;"><?= format_price($price) ?></div>
                        <?php if ($selectedVariant): ?><div style="color:#64748b;font-size:14px;margin-top:8px;">Biến thể: <?= e(build_variant_label($selectedVariant)) ?></div><?php endif; ?>
                    </div>
                </div>
            <?php endif; ?>
            <div class="summary-box mt-24">
                <div class="flex-between"><span><?= $mode === 'cart' ? 'Tổng số lượng' : 'Đơn giá' ?></span><strong><?= $mode === 'cart' ? (int)$cartTotals['item_count'] : format_price($price) ?></strong></div>
                <div class="flex-between mt-16"><span>Tổng tiền dự kiến</span><strong><?= format_price($totalPreview) ?></strong></div>
                <div class="flex-between mt-16"><span>Cọc dự kiến <?= (int)shop_deposit_rate() ?>%</span><strong><?= format_price($depositPreview) ?></strong></div>
            </div>
            <div class="alert alert-info mt-24 mb-0">Sau khi tạo đơn, hệ thống sẽ sinh mã thanh toán riêng cho đơn của bạn. Khi SePay callback thành công, trạng thái thanh toán của đơn sẽ tự cập nhật.</div>
        </div>
    </div>
    <?php endif; ?>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Truyền dữ liệu địa chỉ từ PHP sang JS
    const customerAddresses = <?= json_encode($addresses ?? []) ?>;
    
    const radiosSource = document.querySelectorAll('input[name="address_source"]');
    const selectSaved = document.getElementById('savedAddressSelect');
    const containerSaved = document.getElementById('savedAddressContainer');
    
    // Các trường input cần tự động đổ
    const fName = document.getElementById('f_receiver_name');
    const fPhone = document.getElementById('f_receiver_phone');
    const fProv = document.getElementById('f_province_name');
    const fDist = document.getElementById('f_district_name');
    const fWard = document.getElementById('f_ward_name');
    const fLine = document.getElementById('f_address_line');
    const fNote = document.getElementById('f_address_note');

    function applyAddressData() {
        const source = document.querySelector('input[name="address_source"]:checked')?.value;
        
        if (source === 'saved') {
            if (containerSaved) containerSaved.style.display = 'block';
            if (selectSaved && customerAddresses.length > 0) {
                const selectedId = parseInt(selectSaved.value, 10);
                const addr = customerAddresses.find(a => a.id === selectedId);
                
                if (addr) {
                    fName.value = addr.receiver_name || '';
                    fPhone.value = addr.receiver_phone || addr.phone || '';
                    fProv.value = addr.province_name || '';
                    fDist.value = addr.district_name || '';
                    fWard.value = addr.ward_name || '';
                    fLine.value = addr.address_line || '';
                    fNote.value = addr.address_note || '';
                }
            }
        } else if (source === 'manual') {
            if (containerSaved) containerSaved.style.display = 'none';
            // Để trống form cho người dùng tự nhập mới
            fName.value = '';
            fPhone.value = '';
            fProv.value = '';
            fDist.value = '';
            fWard.value = '';
            fLine.value = '';
            fNote.value = '';
        }
    }

    // Gắn sự kiện lắng nghe
    radiosSource.forEach(radio => radio.addEventListener('change', applyAddressData));
    if (selectSaved) {
        selectSaved.addEventListener('change', applyAddressData);
    }

    // Chạy lần đầu khi load trang
    if (radiosSource.length > 0) {
        applyAddressData();
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>