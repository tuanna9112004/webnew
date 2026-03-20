<?php
require_once __DIR__ . '/includes/functions.php';

$pageTitle = 'Giỏ hàng của bạn';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$missing = require_upgrade_tables(['carts', 'cart_items']);
$cart = !$missing ? get_current_cart(true) : null;
$message = flash_get('cart_notice');
$error = null;
$isAjaxRequest = (($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') === 'XMLHttpRequest');

if (!$missing && is_post()) {
    verify_public_or_customer_form_or_fail();
    $action = (string)($_POST['cart_action'] ?? $_GET['action'] ?? '');

    if ($action === 'add') {
        $productId = (int)($_POST['product_id'] ?? 0);
        $variantId = !empty($_POST['variant_id']) ? (int)$_POST['variant_id'] : null;
        $quantity = max(1, (int)($_POST['quantity'] ?? 1));
        $result = add_item_to_cart($productId, $variantId, $quantity);
        if ($result['ok']) {
            if ($isAjaxRequest) {
                $latestCart = get_current_cart(false);
                $latestTotals = $latestCart ? get_cart_totals((int)$latestCart['id']) : ['item_count' => 0];
                header('Content-Type: application/json; charset=UTF-8');
                echo json_encode([
                    'ok' => true,
                    'message' => $result['message'] ?? 'Đã thêm vào giỏ hàng.',
                    'cart_count' => (int)($latestTotals['item_count'] ?? 0),
                ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
                exit;
            }

            flash_set('cart_notice', $result['message'] ?? 'Đã thêm vào giỏ hàng.', 'success');
            header('Location: ' . route_url('/cart.php'));
            exit;
        }

        if ($isAjaxRequest) {
            http_response_code(422);
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode([
                'ok' => false,
                'message' => $result['message'] ?? 'Không thể thêm vào giỏ hàng.',
            ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            exit;
        }

        $error = $result['message'] ?? 'Không thể thêm vào giỏ hàng.';
    }

    if ($action === 'update') {
        if (!empty($_POST['remove_item_id'])) {
            remove_cart_item((int)$_POST['remove_item_id']);
            flash_set('cart_notice', 'Đã xóa sản phẩm khỏi giỏ hàng.', 'success');
            header('Location: ' . route_url('/cart.php'));
            exit;
        }

        // --- BẮT ĐẦU LOGIC CẬP NHẬT BIẾN THỂ TRỰC TIẾP ---
        $currentCart = get_current_cart(false);
        $currentTotals = $currentCart ? get_cart_totals((int)$currentCart['id']) : null;
        $currentItems = $currentTotals ? $currentTotals['items'] : [];

        foreach ((array)($_POST['variants'] ?? []) as $itemId => $newVariantId) {
            $itemId = (int)$itemId;
            $newVariantId = (int)$newVariantId;
            
            $matchedItem = null;
            foreach ($currentItems as $it) {
                if ($it['id'] == $itemId) {
                    $matchedItem = $it;
                    break;
                }
            }

            // Nếu người dùng chọn biến thể mới khác với biến thể đang có trong giỏ
            if ($matchedItem && $matchedItem['variant_id'] != $newVariantId) {
                // Lấy số lượng mới nhất người dùng vừa nhập (nếu có), nếu không thì dùng số lượng cũ
                $qty = (int)($_POST['quantities'][$itemId] ?? $matchedItem['quantity']);
                
                // Mẹo: Xóa item cũ và thêm item mới bằng hàm hệ thống (để kích hoạt tự động gộp trùng nếu cần)
                remove_cart_item($itemId);
                add_item_to_cart((int)$matchedItem['product_id'], $newVariantId, $qty);
                
                // Hủy biến $_POST quantities của item cũ này để vòng lặp cập nhật số lượng bên dưới bỏ qua nó
                unset($_POST['quantities'][$itemId]); 
            }
        }
        // --- KẾT THÚC LOGIC CẬP NHẬT BIẾN THỂ ---

        // Cập nhật số lượng cho các sản phẩm còn lại
        foreach ((array)($_POST['quantities'] ?? []) as $itemId => $qty) {
            update_cart_item_quantity((int)$itemId, (int)$qty);
        }
        
        // Kiểm tra nếu là request từ JS ngầm thì không redirect
        if (isset($_POST['is_ajax']) && $_POST['is_ajax'] === '1') {
            // Bypass redirect
        } else {
            flash_set('cart_notice', 'Đã cập nhật giỏ hàng.', 'success');
            header('Location: ' . route_url('/cart.php'));
            exit;
        }
    }

    if ($action === 'remove') {
        remove_cart_item((int)($_POST['item_id'] ?? 0));
        flash_set('cart_notice', 'Đã xóa sản phẩm khỏi giỏ hàng.', 'success');
        header('Location: ' . route_url('/cart.php'));
        exit;
    }

    if ($action === 'clear') {
        clear_current_cart();
        flash_set('cart_notice', 'Đã làm trống giỏ hàng.', 'success');
        header('Location: ' . route_url('/cart.php'));
        exit;
    }
}

$cart = !$missing ? get_current_cart(false) : null;
$totals = $cart ? get_cart_totals((int)$cart['id']) : ['items' => [], 'item_count' => 0, 'subtotal' => 0, 'total' => 0, 'shipping_fee' => 0, 'discount_amount' => 0];
$items = $totals['items'];

require_once __DIR__ . '/includes/header.php';
?>

<div class="checkout-shell" style="padding-top:24px;">
    <?php if ($missing): ?>
        <div class="alert alert-warning">Thiếu bảng hệ thống mới: <?= e(implode(', ', $missing)) ?>. Hãy import file migration trước khi dùng giỏ hàng.</div>
    <?php endif; ?>
    <?php if ($message): ?>
        <div class="alert alert-<?= e($message['type'] === 'success' ? 'success' : ($message['type'] === 'warning' ? 'warning' : 'info')) ?>"><?= e($message['message']) ?></div>
    <?php endif; ?>
    <?php if ($error): ?>
        <div class="alert alert-error"><?= e($error) ?></div>
    <?php endif; ?>

    <div class="grid-2">
        <div class="checkout-card">
            <div class="flex-between" style="margin-bottom:16px; align-items:flex-end;">
                <div>
                    <h1 class="section-title">Giỏ hàng</h1>
                    <p class="section-subtitle">Bạn có thể gom nhiều sản phẩm, mỗi sản phẩm chọn màu / size và số lượng riêng trong cùng một đơn.</p>
                </div>
                <a class="btn-secondary" href="<?= route_url('/index.php#product-list') ?>">Mua thêm</a>
            </div>

            <?php if (!$items): ?>
                <div class="alert alert-info mb-0">Giỏ hàng đang trống. Hãy quay lại gian hàng để chọn thêm sản phẩm.</div>
            <?php else: ?>
                <form method="post">
                    <?= csrf_field() ?>
                    <?= public_form_field() ?>
                    <input type="hidden" name="cart_action" value="update">
                    <div class="cart-list">
                        <?php foreach ($items as $item): ?>
                            <?php 
                                // Lấy tất cả biến thể của sản phẩm này để hiển thị trong dropdown
                                $productVariants = get_product_variants((int)$item['product_id']);
                                $hasMultipleVariants = !empty($productVariants) && count($productVariants) > 1;
                            ?>
                            <div class="cart-item-card">
                                <div class="cart-item-media">
                                    <img src="<?= e(resolve_media_url($item['effective_image'] ?: $item['thumbnail'])) ?>" alt="<?= e($item['product_name']) ?>">
                                </div>
                                <div class="cart-item-main">
                                    <div class="cart-item-title"><?= e($item['product_name']) ?></div>
                                    <div class="cart-item-meta">Mã: <?= e($item['product_code']) ?></div>
                                    
                                    <?php if ($hasMultipleVariants): ?>
                                        <div class="cart-item-meta" style="margin-top: 6px;">
                                            <label style="font-size: 12px; font-weight: 600; color: #4b5563; display: block; margin-bottom: 4px;">Phân loại:</label>
                                            <select name="variants[<?= (int)$item['id'] ?>]" class="form-control cart-variant-select" style="font-size: 13px; padding: 4px 8px; height: auto; border-radius: 6px; width: 100%; max-width: 200px;">
                                                <?php foreach ($productVariants as $v): ?>
                                                    <?php 
                                                        $vLabel = build_variant_label([
                                                            'variant_name' => $v['variant_name'] ?? null,
                                                            'size_value' => $v['size_value'] ?? null,
                                                            'color_value' => $v['color_value'] ?? null,
                                                        ]) ?: 'Mặc định';
                                                    ?>
                                                    <option value="<?= (int)$v['id'] ?>" <?= $item['variant_id'] == $v['id'] ? 'selected' : '' ?>>
                                                        <?= e($vLabel) ?>
                                                    </option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                    <?php else: ?>
                                        <div class="cart-item-meta">Phân loại: <?= e(build_variant_label([
                                            'variant_name' => $item['variant_name'],
                                            'size_value' => $item['size_value'],
                                            'color_value' => $item['color_value'],
                                        ]) ?: 'Mặc định') ?></div>
                                    <?php endif; ?>

                                    <div class="cart-item-price" style="margin-top: 6px;"><?= format_price($item['unit_price_snapshot']) ?></div>
                                </div>
                                <div class="cart-item-side">
                                    <label class="form-label" style="margin-bottom:6px;">Số lượng</label>
                                    <input class="form-control cart-qty-input" type="number" min="1" name="quantities[<?= (int)$item['id'] ?>]" value="<?= (int)$item['quantity'] ?>">
                                    <div class="cart-line-total">Tạm tính: <?= format_price((float)$item['unit_price_snapshot'] * (int)$item['quantity']) ?></div>
                                    <button class="btn-ghost" type="submit" name="remove_item_id" value="<?= (int)$item['id'] ?>">Xóa</button>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>

                    <div style="display:flex; gap:12px; flex-wrap:wrap; margin-top:18px;">
                        <button class="btn-primary" type="submit">Cập nhật giỏ hàng</button>
                    </div>
                </form>

                <form method="post" style="margin-top:12px;">
                    <?= csrf_field() ?>
                    <?= public_form_field() ?>
                    <input type="hidden" name="cart_action" value="clear">
                    <button class="btn-ghost" type="submit" onclick="return confirm('Bạn muốn làm trống toàn bộ giỏ hàng?');">Làm trống giỏ hàng</button>
                </form>
            <?php endif; ?>
        </div>

        <div class="checkout-card">
            <h2 class="section-title" style="font-size:20px;">Tóm tắt đơn hàng</h2>
            <div class="summary-box">
                <div class="flex-between"><span>Tổng số lượng</span><strong><?= (int)$totals['item_count'] ?></strong></div>
                <div class="flex-between mt-16"><span>Tạm tính</span><strong><?= format_price($totals['subtotal']) ?></strong></div>
                <div class="flex-between mt-16"><span>Phí ship dự kiến</span><strong><?= format_price($totals['shipping_fee']) ?></strong></div>
                <div class="flex-between mt-16"><span>Giảm giá</span><strong><?= format_price($totals['discount_amount']) ?></strong></div>
                <hr style="border:none; border-top:1px solid #e5e7eb; margin:16px 0;">
                <div class="flex-between"><span>Tổng thanh toán</span><strong style="font-size:18px;"><?= format_price($totals['total']) ?></strong></div>
                <div class="flex-between mt-16"><span>Cọc dự kiến <?= (int)shop_deposit_rate() ?>%</span><strong><?= format_price(ceil((float)$totals['total'] * shop_deposit_rate() / 100)) ?></strong></div>
            </div>
            <?php if ($items): ?>
                <div style="display:flex; gap:12px; flex-wrap:wrap; margin-top:20px;">
                    <a class="btn-primary" href="<?= route_url('/checkout.php') ?>">Tiến hành checkout</a>
                    <a class="btn-secondary" target="_blank" rel="noopener noreferrer" href="<?= e(shop_zalo_link()) ?>">Đặt qua Zalo</a>
                </div>
            <?php endif; ?>
            <div class="alert alert-info mt-24 mb-0">Checkout web sẽ gom tất cả sản phẩm trong giỏ vào cùng một đơn hàng. Mỗi dòng sản phẩm giữ nguyên màu / size / số lượng bạn đã chọn.</div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Lắng nghe cả sự kiện đổi số lượng VÀ đổi dropdown biến thể
    document.body.addEventListener('change', function(e) {
        if (e.target.classList.contains('cart-qty-input') || e.target.classList.contains('cart-variant-select')) {
            const input = e.target;
            
            // Không cho phép số lượng nhỏ hơn 1
            if (input.classList.contains('cart-qty-input') && input.value < 1) {
                input.value = 1;
            }

            const form = input.closest('form');
            const formData = new FormData(form);
            
            // Đính kèm cờ báo hiệu đây là AJAX request
            formData.append('is_ajax', '1');

            const container = document.querySelector('.checkout-shell');
            
            // Thêm hiệu ứng mờ nhẹ để user biết trang đang xử lý
            container.style.opacity = '0.5';
            container.style.pointerEvents = 'none';

            fetch(window.location.href, {
                method: 'POST',
                body: formData
            })
            .then(res => res.text())
            .then(html => {
                // Bóc tách DOM trả về để chỉ thay thế phần .checkout-shell
                const doc = new DOMParser().parseFromString(html, 'text/html');
                const newShell = doc.querySelector('.checkout-shell');
                if (newShell) {
                    container.innerHTML = newShell.innerHTML;
                }
            })
            .catch(err => {
                console.error('Lỗi khi cập nhật giỏ hàng:', err);
                window.location.reload(); 
            })
            .finally(() => {
                // Phục hồi lại tương tác
                container.style.opacity = '1';
                container.style.pointerEvents = 'auto';
            });
        }
    });
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>