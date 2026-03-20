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
/* =========================================
   TỐI ƯU GIAO DIỆN CHECKOUT & MOBILE
========================================= */
:root {
    --primary-color: #111827;
    --border-color: #e5e7eb;
    --text-muted: #6b7280;
    --bg-light: #f8fafc;
}

.checkout-shell { padding: 16px; max-width: 1200px; margin: 0 auto; }
.checkout-layout { display: flex; flex-direction: column; gap: 20px; }
.checkout-card { background: #fff; padding: 16px; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); border: 1px solid var(--border-color); }
.layout-sidebar { order: 1; }
.layout-main { order: 2; }
.section-title { font-size: 18px; font-weight: 700; margin-bottom: 4px; color: var(--primary-color); }
.section-subtitle { color: var(--text-muted); font-size: 13px; margin-bottom: 20px; }

.form-grid.col-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px 10px; }
.form-group { display: flex; flex-direction: column; }
.form-group.full-width { grid-column: 1 / -1; }
.form-label { font-weight: 600; font-size: 13px; margin-bottom: 6px; color: #374151; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.form-control, .form-select, .form-textarea { width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #d1d5db; font-size: 16px; box-sizing: border-box; transition: border-color 0.2s; background: #fff; }
.form-control:focus, .form-select:focus, .form-textarea:focus { outline: none; border-color: #0f172a; box-shadow: 0 0 0 3px rgba(15, 23, 42, 0.1); }
.form-textarea { resize: vertical; min-height: 70px; }
.required-star { color: #ef4444; margin-left: 2px; }

select.form-select { cursor: pointer; appearance: auto; -webkit-appearance: auto; }

.inline-radio { display: flex; flex-direction: row; gap: 8px; }
.inline-radio label { flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 4px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--bg-light); cursor: pointer; font-size: 13px; font-weight: 500; text-align: center; }
.inline-radio input[type="radio"] { margin: 0; }

.payment-section-title { font-size: 16px; font-weight: 700; color: var(--primary-color); margin-bottom: 12px; }
.payment-options-container { display: flex; flex-direction: column; gap: 10px; }
.payment-option-label { display: flex; align-items: center; gap: 12px; padding: 14px; border: 2px solid var(--border-color); border-radius: 10px; background: #fff; font-size: 15px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; }
.payment-option-label input[type="radio"] { width: 20px; height: 20px; margin: 0; cursor: pointer; accent-color: #0f172a; }
.payment-option-label:has(input:checked) { border-color: #0f172a; background: var(--bg-light); box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }

.action-buttons { display: flex; flex-direction: column; gap: 10px; margin-top: 20px; }
.btn-primary, .btn-secondary { width: 100%; text-align: center; padding: 14px; font-size: 15px; font-weight: 600; border-radius: 8px; box-sizing: border-box; cursor: pointer; text-decoration: none; border: none; }
.btn-primary { background: var(--primary-color); color: #fff; }
.btn-secondary { background: #f1f5f9; color: var(--primary-color); }

.summary-box { background: var(--bg-light); padding: 16px; border-radius: 12px; margin-top: 16px; }
.flex-between { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; font-size: 14px; }
.flex-between:last-child { margin-bottom: 0; }
.flex-between strong { font-size: 15px; color: #ef4444; }

.product-preview-card { display: flex; gap: 12px; align-items: flex-start; padding-bottom: 12px; border-bottom: 1px dashed var(--border-color); margin-bottom: 12px; }
.product-preview-img { width: 70px; height: 90px; object-fit: cover; border-radius: 8px; border: 1px solid var(--border-color); }
.product-preview-info { flex: 1; }
.product-preview-title { font-size: 14px; font-weight: 700; line-height: 1.4; color: var(--primary-color); }
.product-preview-meta { color: var(--text-muted); font-size: 12px; margin-top: 4px; }

.alert { padding: 12px; border-radius: 8px; margin-bottom: 16px; font-size: 13px; line-height: 1.5; }
.alert-warning { background: #fef08a; color: #854d0e; }
.alert-error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
.alert-info { background: #e0f2fe; color: #075985; }
.mt-24 { margin-top: 20px; }
.mb-0 { margin-bottom: 0 !important; }
.link-muted { color: #2563eb; text-decoration: underline; }

/* Nút Nhờ nhận hộ */
.toggle-receiver-label { display: inline-flex; align-items: center; gap: 8px; padding: 12px 14px; background: #f1f5f9; border: 1px solid #cbd5e1; border-radius: 8px; cursor: pointer; font-weight: 600; font-size: 14px; color: #334155; transition: all 0.2s; user-select: none; }
.toggle-receiver-label:hover { background: #e2e8f0; }
.toggle-receiver-label input[type="checkbox"] { width: 18px; height: 18px; cursor: pointer; accent-color: #0f172a; margin: 0;}

@media (min-width: 768px) {
    .checkout-shell { padding: 32px 16px; }
    .checkout-layout { flex-direction: row; align-items: flex-start; }
    .checkout-card { padding: 28px; }
    .layout-main { flex: 3; order: 1; }
    .layout-sidebar { flex: 2; position: sticky; top: 24px; order: 2; }
    .form-grid.col-2 { gap: 20px 16px; }
    .form-label { font-size: 14px; }
    .action-buttons { flex-direction: row; }
    .product-preview-img { width: 90px; height: 110px; }
    .product-preview-title { font-size: 16px; }
    .inline-radio label { padding: 12px; font-size: 14px; }
}
</style>

<div class="checkout-shell">
    <?php if ($missing): ?>
        <div class="alert alert-warning">Thiếu bảng hệ thống mới: <?= e(implode(', ', $missing)) ?>. Hãy import file migration trước khi checkout.</div>
    <?php endif; ?>
    
    <?php if ($error): ?>
        <div class="alert alert-error"><?= e($error) ?></div>
    <?php endif; ?>

    <?php if ($mode === 'cart' && empty($cartTotals['items'])): ?>
        <div class="alert alert-info">Giỏ hàng đang trống. <a class="link-muted" href="<?= route_url('/index.php#product-list') ?>">Quay lại gian hàng</a> hoặc <a class="link-muted" href="<?= route_url('/cart.php') ?>">xem giỏ hàng</a>.</div>
    <?php else: ?>
    
    <div class="checkout-layout">
        <div class="checkout-card layout-main">
            <h1 class="section-title">Thanh toán đơn hàng</h1>
            <p class="section-subtitle"><?= $mode === 'cart' ? 'Gom chung sản phẩm vào một đơn.' : 'Thanh toán cọc hoặc toàn bộ đơn.' ?></p>
            
            <?php if (!$customer): ?>
                <div class="alert alert-info">Đăng nhập để lưu lịch sử: <a class="link-muted" href="<?= route_url('/customer/login.php') ?>">Đăng nhập</a> / <a class="link-muted" href="<?= route_url('/customer/register.php') ?>">Đăng ký</a>.</div>
            <?php endif; ?>

            <form method="post" id="checkoutForm">
                <?= csrf_field() ?>
                
                <?php if ($mode === 'single'): ?>
                    <input type="hidden" name="product_id" value="<?= (int)$product['id'] ?>">
                    <?php if ($selectedVariant): ?><input type="hidden" name="variant_id" value="<?= (int)$selectedVariant['id'] ?>"><?php endif; ?>
                    <div class="form-group mb-0 mt-24">
                        <label class="form-label">Số lượng mua</label>
                        <input class="form-control" type="number" name="quantity" min="1" value="<?= e((string)max(1, (int)old_input('quantity', '1'))) ?>">
                    </div>
                <?php endif; ?>

                <div class="form-grid col-2 mt-24">
                    <div class="form-group">
                        <label class="form-label">Họ và tên người mua <span class="required-star">*</span></label>
                        <input class="form-control" name="contact_name" id="contact_name" placeholder="Họ tên" value="<?= e(old_input('contact_name', $customer['full_name'] ?? '')) ?>" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số điện thoại <span class="required-star">*</span></label>
                        <input class="form-control" name="contact_phone" id="contact_phone" placeholder="SĐT" value="<?= e(old_input('contact_phone', $customer['phone'] ?? '')) ?>" required>
                    </div>
                    <div class="form-group full-width">
                        <label class="form-label">Email (Không bắt buộc)</label>
                        <input class="form-control" name="contact_email" placeholder="Nhập email" value="<?= e(old_input('contact_email', $customer['email'] ?? '')) ?>">
                    </div>
                    
                    <?php if ($customer && $addresses): ?>
                    <div class="form-group full-width">
                        <label class="form-label">Lấy địa chỉ giao hàng</label>
                        <div class="inline-radio">
                            <label><input type="radio" name="address_source" value="saved" <?= old_input('address_source', 'saved') === 'saved' ? 'checked' : '' ?>> Đã lưu</label>
                            <label><input type="radio" name="address_source" value="manual" <?= old_input('address_source') === 'manual' ? 'checked' : '' ?>> Nhập mới</label>
                        </div>
                    </div>
                    <?php endif; ?>
                </div>

                <?php if ($customer && $addresses): ?>
                <div class="form-group mt-24" id="savedAddressContainer">
                    <label class="form-label">Chọn địa chỉ đã lưu</label>
                    <select class="form-select" name="saved_address_id" id="savedAddressSelect">
                        <?php foreach ($addresses as $address): ?>
                            <option value="<?= (int)$address['id'] ?>" <?= (int)old_input('saved_address_id', (string)$address['id']) === (int)$address['id'] || !empty($address['is_default_shipping']) ? 'selected' : '' ?>>
                                <?= e($address['label'] ?: 'Địa chỉ') ?> — <?= e($address['receiver_name']) ?> — <?= e($address['address_line']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>

                <div class="form-grid col-2 mt-24">
                    
                    <div class="form-group full-width" style="margin-bottom: 8px;">
                        <label class="toggle-receiver-label">
                            <input type="checkbox" id="toggleReceiverCheckbox"> 
                            🎁 Nhờ người khác nhận hộ (Nhập Tên và SĐT người nhận)
                        </label>
                    </div>

                    <div id="receiverInfoWrapper" style="display: none; grid-column: 1 / -1; background: #f8fafc; padding: 16px; border: 1px dashed #cbd5e1; border-radius: 8px; margin-bottom: 12px;">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                            <div class="form-group">
                                <label class="form-label">Tên người nhận</label>
                                <input class="form-control" name="receiver_name" id="f_receiver_name" placeholder="Nhập tên người nhận..." value="<?= e(old_input('receiver_name')) ?>">
                            </div>
                            <div class="form-group">
                                <label class="form-label">SĐT nhận</label>
                                <input class="form-control" name="receiver_phone" id="f_receiver_phone" placeholder="Nhập SĐT..." value="<?= e(old_input('receiver_phone')) ?>">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group full-width">
                        <label class="form-label">Tỉnh/Thành phố <span class="required-star">*</span></label>
                        <select class="form-select" name="province_name" id="f_province_name" required>
                            <option value="">-- Đang tải dữ liệu... --</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Quận/Huyện <span class="required-star">*</span></label>
                        <select class="form-select" name="district_name" id="f_district_name" required>
                            <option value="">-- Chọn Quận/Huyện --</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Phường/Xã <span class="required-star">*</span></label>
                        <select class="form-select" name="ward_name" id="f_ward_name" required>
                            <option value="">-- Chọn Phường/Xã --</option>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <label class="form-label">Số nhà, Tên đường <span class="required-star">*</span></label>
                        <input class="form-control" name="address_line" id="f_address_line" placeholder="VD: 123 Đường ABC..." value="<?= e(old_input('address_line')) ?>" required>
                    </div>
                    <div class="form-group full-width">
                        <label class="form-label">Ghi chú thêm cho shop</label>
                        <textarea class="form-textarea" name="customer_note" placeholder="Ví dụ: Giao giờ hành chính, gọi trước khi giao..."><?= e(old_input('customer_note')) ?></textarea>
                    </div>
                </div>

                <div class="mt-24">
                    <div class="payment-section-title">Thanh toán</div>
                    <div class="payment-options-container">
                        <label class="payment-option-label">
                            <input type="radio" name="payment_plan" value="deposit_30" <?= old_input('payment_plan', 'deposit_30') === 'deposit_30' ? 'checked' : '' ?>> 
                            <span>Cọc <?= (int)shop_deposit_rate() ?>% qua Ngân hàng</span>
                        </label>
                        <label class="payment-option-label">
                            <input type="radio" name="payment_plan" value="full" <?= old_input('payment_plan') === 'full' ? 'checked' : '' ?>> 
                            <span>Thanh toán toàn bộ</span>
                        </label>
                    </div>
                </div>

                <div class="action-buttons">
                    <button class="btn-primary" type="submit">Tạo đơn & Thanh toán</button>
                    <a class="btn-secondary" target="_blank" rel="noopener noreferrer" href="<?= e(shop_zalo_link()) ?>">Hỗ trợ mua qua Zalo</a>
                </div>
            </form>
        </div>

        <div class="checkout-card layout-sidebar">
            <h2 class="section-title">Tóm tắt đơn hàng</h2>
            
            <?php if ($mode === 'cart'): ?>
                <div class="mt-24">
                    <?php foreach ($cartTotals['items'] as $item): ?>
                        <div class="product-preview-card">
                            <img class="product-preview-img" src="<?= e(resolve_media_url($item['effective_image'] ?: $item['thumbnail'])) ?>" alt="<?= e($item['product_name']) ?>">
                            <div class="product-preview-info">
                                <div class="product-preview-title"><?= e($item['product_name']) ?></div>
                                <div class="product-preview-meta">
                                    <?= e(build_variant_label([
                                        'variant_name' => $item['variant_name'],
                                        'size_value' => $item['size_value'],
                                        'color_value' => $item['color_value'],
                                    ])) ?>
                                </div>
                                <div class="product-preview-meta">Số lượng: <strong><?= (int)$item['quantity'] ?></strong></div>
                                <div style="margin-top: 6px; font-weight: 700; color: #ef4444;">
                                    <?= format_price((float)$item['unit_price_snapshot'] * (int)$item['quantity']) ?>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php else: ?>
                <div class="product-preview-card mt-24">
                    <img class="product-preview-img" src="<?= e(resolve_media_url($product['thumbnail'])) ?>" alt="<?= e($product['product_name']) ?>">
                    <div class="product-preview-info">
                        <div class="product-preview-title"><?= e($product['product_name']) ?></div>
                        <div class="product-preview-meta">Mã: <?= e($product['product_code']) ?></div>
                        <?php if ($selectedVariant): ?>
                            <div class="product-preview-meta">Phân loại: <?= e(build_variant_label($selectedVariant)) ?></div>
                        <?php endif; ?>
                    </div>
                </div>
            <?php endif; ?>
            
            <div class="summary-box">
                <div class="flex-between">
                    <span><?= $mode === 'cart' ? 'Tổng số lượng:' : 'Đơn giá:' ?></span>
                    <span style="font-weight: 600; color: #111827;"><?= $mode === 'cart' ? (int)$cartTotals['item_count'] : format_price($price) ?></span>
                </div>
                <div class="flex-between">
                    <span>Tổng tiền:</span>
                    <strong><?= format_price($totalPreview) ?></strong>
                </div>
                <div class="flex-between" style="border-top: 1px dashed #cbd5e1; padding-top: 10px; margin-top: 10px;">
                    <span>Cọc (<?= (int)shop_deposit_rate() ?>%):</span>
                    <strong><?= format_price($depositPreview) ?></strong>
                </div>
            </div>
            
            <div class="alert alert-info mt-24 mb-0">
                Mã QR thanh toán tự động sẽ được tạo ngay sau khi bạn bấm <strong>Tạo đơn</strong>.
            </div>
        </div>
    </div>
    <?php endif; ?>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

<script>
$(document).ready(function() {
    const customerAddresses = <?= json_encode($addresses ?? []) ?>;
    const oldProv = <?= json_encode(old_input('province_name')) ?>;
    const oldDist = <?= json_encode(old_input('district_name')) ?>;
    const oldWard = <?= json_encode(old_input('ward_name')) ?>;

    // --- LOGIC: NHỜ NGƯỜI KHÁC NHẬN HỘ ---
    const checkboxToggle = $('#toggleReceiverCheckbox');
    const receiverWrapper = $('#receiverInfoWrapper');
    const fReceiverName = $('#f_receiver_name');
    const fReceiverPhone = $('#f_receiver_phone');
    const contactName = $('#contact_name');
    const contactPhone = $('#contact_phone');

    // Nếu lúc load trang (hoặc load lại do validation lỗi) mà 2 ô này có dữ liệu khác rỗng, thì mở sẵn checkbox
    if (fReceiverName.val().trim() !== '' && fReceiverName.val() !== contactName.val()) {
        checkboxToggle.prop('checked', true);
        receiverWrapper.show();
    }

    checkboxToggle.change(function() {
        if ($(this).is(':checked')) {
            receiverWrapper.slideDown(200);
            fReceiverName.focus();
        } else {
            receiverWrapper.slideUp(200);
            // Khi tắt, có thể clear dữ liệu đi hoặc để nguyên kệ khách
        }
    });

    // 1. Tải danh sách 63 Tỉnh/Thành khi trang vừa mở
    $.getJSON('https://esgoo.net/api-tinhthanh/1/0.htm', function(data_tinh) {
        if (data_tinh.error === 0) {
            $("#f_province_name").html('<option value="">-- Chọn Tỉnh / Thành phố --</option>');
            $.each(data_tinh.data, function (key, val) {
                $("#f_province_name").append('<option value="'+val.full_name+'" data-id="'+val.id+'">'+val.full_name+'</option>');
            });

            // Sau khi tải Tỉnh xong, kiểm tra xem có cần đổ dữ liệu không
            if ($('input[name="address_source"]:checked').val() === 'saved') {
                applyAddressData();
            } else if (oldProv) {
                matchAndSelect($('#f_province_name'), oldProv);
                loadDistricts($('#f_province_name').find(':selected').data('id'), oldDist, oldWard);
            }
        }
    });

    // 2. Bắt sự kiện khi người dùng tự đổi Tỉnh -> Tải Quận
    $("#f_province_name").change(function() {
        var idtinh = $(this).find(':selected').data('id');
        loadDistricts(idtinh);
    });

    // 3. Bắt sự kiện khi người dùng tự đổi Quận -> Tải Phường
    $("#f_district_name").change(function() {
        var idquan = $(this).find(':selected').data('id');
        loadWards(idquan);
    });

    function loadDistricts(provinceId, districtToSelect = '', wardToSelect = '') {
        $("#f_district_name").html('<option value="">-- Đang tải... --</option>');
        $("#f_ward_name").html('<option value="">-- Chọn Phường / Xã --</option>');
        
        if (provinceId && provinceId !== 'custom') {
            $.getJSON('https://esgoo.net/api-tinhthanh/2/'+provinceId+'.htm', function(data_quan) {
                if (data_quan.error === 0) {
                    $("#f_district_name").html('<option value="">-- Chọn Quận / Huyện --</option>');
                    $.each(data_quan.data, function (key, val) {
                        $("#f_district_name").append('<option value="'+val.full_name+'" data-id="'+val.id+'">'+val.full_name+'</option>');
                    });
                    
                    if (districtToSelect) {
                        matchAndSelect($('#f_district_name'), districtToSelect);
                        const dId = $('#f_district_name').find(':selected').data('id');
                        if (dId) loadWards(dId, wardToSelect);
                    }
                }
            });
        } else {
            $("#f_district_name").html('<option value="">-- Chọn Quận / Huyện --</option>');
            if (districtToSelect) matchAndSelect($('#f_district_name'), districtToSelect);
        }
    }

    function loadWards(districtId, wardToSelect = '') {
        $("#f_ward_name").html('<option value="">-- Đang tải... --</option>');
        
        if (districtId && districtId !== 'custom') {
            $.getJSON('https://esgoo.net/api-tinhthanh/3/'+districtId+'.htm', function(data_phuong) {
                if (data_phuong.error === 0) {
                    $("#f_ward_name").html('<option value="">-- Chọn Phường / Xã --</option>');
                    $.each(data_phuong.data, function (key, val) {
                        $("#f_ward_name").append('<option value="'+val.full_name+'" data-id="'+val.id+'">'+val.full_name+'</option>');
                    });

                    if (wardToSelect) {
                        matchAndSelect($('#f_ward_name'), wardToSelect);
                    }
                }
            });
        } else {
            $("#f_ward_name").html('<option value="">-- Chọn Phường / Xã --</option>');
            if (wardToSelect) matchAndSelect($('#f_ward_name'), wardToSelect);
        }
    }

    function matchAndSelect($select, text) {
        if (!text) return;
        const search = text.toLowerCase().replace(/^(thành phố|tỉnh|quận|huyện|thị xã|phường|xã|thị trấn)\s+/i, '').trim();
        let matched = false;
        
        $select.find('option').each(function() {
            const optText = $(this).val().toLowerCase().replace(/^(thành phố|tỉnh|quận|huyện|thị xã|phường|xã|thị trấn)\s+/i, '').trim();
            if (optText === search || $(this).val() === text) {
                $(this).prop('selected', true);
                matched = true;
                return false; 
            }
        });

        if (!matched) {
            const newOpt = $('<option>', { value: text, text: text, 'data-id': 'custom' });
            $select.append(newOpt);
            newOpt.prop('selected', true);
        }
    }

    // === ĐỔ DỮ LIỆU ĐỊA CHỈ ĐÃ LƯU ===
    function applyAddressData() {
        const source = $('input[name="address_source"]:checked').val();
        
        if (source === 'saved') {
            $('#savedAddressContainer').show();
            const selectedId = parseInt($('#savedAddressSelect').val(), 10);
            
            if (customerAddresses.length > 0) {
                const addr = customerAddresses.find(a => parseInt(a.id, 10) === selectedId);
                
                if (addr) {
                    // Nếu tên/sđt lưu trong Address KHÁC với thông tin mua hàng -> Bật toggle Nhờ nhận hộ
                    if (addr.receiver_name && addr.receiver_name !== contactName.val()) {
                        checkboxToggle.prop('checked', true).trigger('change');
                    } else {
                        checkboxToggle.prop('checked', false).trigger('change');
                    }

                    fReceiverName.val(addr.receiver_name || '');
                    fReceiverPhone.val(addr.receiver_phone || '');
                    $('#f_address_line').val(addr.address_line || '');
                    
                    if (addr.province_name) {
                        matchAndSelect($('#f_province_name'), addr.province_name);
                        const pId = $('#f_province_name').find(':selected').data('id');
                        if (pId) {
                            loadDistricts(pId, addr.district_name, addr.ward_name);
                        }
                    }
                }
            }
        } else if (source === 'manual') {
            $('#savedAddressContainer').hide();
            fReceiverName.val('');
            fReceiverPhone.val('');
            checkboxToggle.prop('checked', false).trigger('change'); // Tắt Nhờ nhận hộ
            $('#f_address_line').val('');
            $('#f_province_name').val('').trigger('change');
        }
    }

    $('input[name="address_source"]').change(applyAddressData);
    $('#savedAddressSelect').change(applyAddressData);

    // Chặn lỗi: Trước khi Submit form
    $('#checkoutForm').submit(function() {
        // Nếu KHÔNG tick Nhờ nhận hộ -> copy luôn Tên/SĐT mua hàng sang nhận hàng
        if (!checkboxToggle.is(':checked')) {
            fReceiverName.val(contactName.val().trim());
            fReceiverPhone.val(contactPhone.val().trim());
        } else {
            // Nếu TICK Nhờ nhận hộ, nhưng cố tình để trống -> Dùng fallback lấy thông tin mua hàng
            if (!fReceiverName.val().trim()) {
                fReceiverName.val(contactName.val().trim());
            }
            if (!fReceiverPhone.val().trim()) {
                fReceiverPhone.val(contactPhone.val().trim());
            }
        }
    });
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>