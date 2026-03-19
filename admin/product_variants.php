<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

$productId = (int)($_GET['product_id'] ?? $_POST['product_id'] ?? 0);
$product = $productId > 0 ? get_product($productId) : null;
if (!$product) {
    http_response_code(404);
    exit('Không tìm thấy sản phẩm để quản lý biến thể.');
}

$variantId = (int)($_GET['id'] ?? 0);
$editingVariant = $variantId > 0 ? get_product_variant($variantId, $productId) : null;
$message = null;
$error = null;
$productImages = get_product_images($productId);
$imagePool = [];
if (!empty($product['thumbnail'])) {
    $imagePool[] = $product['thumbnail'];
}
foreach ($productImages as $img) {
    if (!empty($img['image_url'])) {
        $imagePool[] = $img['image_url'];
    }
}
$imagePool = array_values(array_unique(array_filter($imagePool)));

if (is_post()) {
    verify_csrf_or_fail();
    $action = (string)($_POST['action'] ?? 'save');

    if ($action === 'delete') {
        $deleteId = (int)($_POST['variant_id'] ?? 0);
        if ($deleteId > 0) {
            db()->prepare('DELETE FROM product_variants WHERE id = ? AND product_id = ?')->execute([$deleteId, $productId]);
            sync_product_variant_summary($productId);
            header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&deleted=1'));
            exit;
        }
    }

    if ($action === 'bulk_generate') {
        $colors = trim((string)($_POST['bulk_colors'] ?? ''));
        $sizes = trim((string)($_POST['bulk_sizes'] ?? ''));
        $created = create_product_variants_from_matrix($productId, $product, $colors, $sizes);
        header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&bulk_created=' . $created));
        exit;
    }

    $variantIdPost = (int)($_POST['variant_id'] ?? 0);
    $variantName = trim((string)($_POST['variant_name'] ?? ''));
    $sizeValue = trim((string)($_POST['size_value'] ?? ''));
    $colorValue = trim((string)($_POST['color_value'] ?? ''));
    $sku = trim((string)($_POST['sku'] ?? ''));
    $originalPrice = (float)($_POST['original_price'] ?? 0);
    $salePrice = ($_POST['sale_price'] ?? '') !== '' ? (float)$_POST['sale_price'] : null;
    $purchasePrice = ($_POST['purchase_price'] ?? '') !== '' ? (float)$_POST['purchase_price'] : null;
    $stockQty = max(0, (int)($_POST['stock_qty'] ?? 0));
    $manualImageUrl = trim((string)($_POST['image_url'] ?? ''));
    $selectedGalleryImage = trim((string)($_POST['gallery_image_url'] ?? ''));
    $isDefault = !empty($_POST['is_default']) ? 1 : 0;
    $isActive = !empty($_POST['is_active']) ? 1 : 0;

    $uploadedImage = handle_image_upload($_FILES['variant_image_file'] ?? null, [
        'destination' => 'uploads',
        'optimize' => true,
        'max_width' => 1400,
        'jpeg_quality' => 82,
        'webp_quality' => 80,
    ]);

    $finalImageUrl = null;
    if ($uploadedImage) {
        $finalImageUrl = $uploadedImage;
    } elseif ($selectedGalleryImage !== '' && in_array($selectedGalleryImage, $imagePool, true)) {
        $finalImageUrl = $selectedGalleryImage;
    } elseif ($manualImageUrl !== '') {
        $finalImageUrl = $manualImageUrl;
    } elseif ($editingVariant && !empty($editingVariant['image_url'])) {
        $finalImageUrl = $editingVariant['image_url'];
    }

    if ($sku === '') {
        $sku = generate_variant_sku_by_values($product, $colorValue, $sizeValue);
    }

    $variantNameFinal = $variantName !== '' ? $variantName : build_variant_label([
        'color_value' => $colorValue ?: null,
        'size_value' => $sizeValue ?: null,
        'variant_name' => null,
    ]);

    try {
        if ($variantIdPost > 0) {
            db()->prepare('UPDATE product_variants SET sku = ?, variant_name = ?, size_value = ?, color_value = ?, original_price = ?, sale_price = ?, purchase_price = ?, stock_qty = ?, image_url = ?, is_default = ?, is_active = ?, updated_at = NOW() WHERE id = ? AND product_id = ?')
                ->execute([$sku, $variantNameFinal, $sizeValue ?: null, $colorValue ?: null, $originalPrice, $salePrice, $purchasePrice, $stockQty, $finalImageUrl ?: null, $isDefault, $isActive, $variantIdPost, $productId]);
            $targetVariantId = $variantIdPost;
        } else {
            db()->prepare('INSERT INTO product_variants (product_id, sku, variant_name, size_value, color_value, original_price, sale_price, purchase_price, stock_qty, image_url, is_default, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())')
                ->execute([$productId, $sku, $variantNameFinal, $sizeValue ?: null, $colorValue ?: null, $originalPrice, $salePrice, $purchasePrice, $stockQty, $finalImageUrl ?: null, $isDefault, $isActive]);
            $targetVariantId = (int)db()->lastInsertId();
        }

        if ($isDefault) {
            db()->prepare('UPDATE product_variants SET is_default = 0 WHERE product_id = ? AND id <> ?')->execute([$productId, $targetVariantId]);
            db()->prepare('UPDATE product_variants SET is_default = 1 WHERE id = ? AND product_id = ?')->execute([$targetVariantId, $productId]);
        }

        sync_product_variant_summary($productId);
        header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&saved=1'));
        exit;
    } catch (Throwable $e) {
        $error = $e->getMessage();
    }
}

if (isset($_GET['saved'])) {
    $message = 'Đã lưu biến thể thành công.';
}
if (isset($_GET['deleted'])) {
    $message = 'Đã xóa biến thể.';
}
if (isset($_GET['bulk_created'])) {
    $message = 'Đã tạo thêm ' . (int)$_GET['bulk_created'] . ' biến thể mới.';
}

$variants = get_product_variants($productId, false);
$pageTitle = 'Biến thể sản phẩm';
$editingImage = $editingVariant['image_url'] ?? '';
$bulkDefaults = get_product_variant_dimensions($productId);
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($pageTitle) ?></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body{font-family:Inter,sans-serif;background:#f8fafc;color:#0f172a;margin:0}.wrap{max-width:1280px;margin:0 auto;padding:24px}.top{display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;margin-bottom:18px}.card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;padding:20px;box-shadow:0 10px 30px rgba(15,23,42,.06)}.grid{display:grid;grid-template-columns:1.2fr 1fr;gap:18px}.form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}.image-choices{display:grid;grid-template-columns:repeat(auto-fill,minmax(84px,1fr));gap:10px}.thumb-choice{position:relative;border:1px solid #d1d5db;border-radius:14px;padding:6px;cursor:pointer}.thumb-choice input{position:absolute;inset:0;opacity:0;cursor:pointer}.thumb-choice img{width:100%;height:92px;border-radius:10px;object-fit:cover;display:block}.thumb-choice.active{border-color:#111827;box-shadow:0 0 0 3px rgba(17,24,39,.08)}@media(max-width:980px){.grid,.form-grid{grid-template-columns:1fr}}.form-group{margin-bottom:14px}.form-label{display:block;font-size:13px;font-weight:700;margin-bottom:8px;color:#475569}.form-control{width:100%;box-sizing:border-box;padding:12px 14px;border:1px solid #d1d5db;border-radius:12px;font-size:14px}.btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;border-radius:12px;padding:11px 16px;font-size:14px;font-weight:700;text-decoration:none;border:none;cursor:pointer}.btn-primary{background:#111827;color:#fff}.btn-secondary{background:#fff;color:#111827;border:1px solid #d1d5db}.btn-danger{background:#7f1d1d;color:#fff}table{width:100%;border-collapse:collapse}th,td{padding:12px 10px;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;vertical-align:top}th{font-size:12px;text-transform:uppercase;color:#64748b}.pill{display:inline-flex;padding:5px 9px;border-radius:999px;background:#eff6ff;color:#1d4ed8;font-size:12px;font-weight:700}.muted{color:#64748b}.alert{padding:14px 16px;border-radius:12px;margin-bottom:14px;font-size:14px}.ok{background:#ecfdf5;color:#065f46;border:1px solid #a7f3d0}.bad{background:#fef2f2;color:#991b1b;border:1px solid #fecaca}.helper{font-size:13px;color:#64748b;line-height:1.6}.preview-image{width:56px;height:70px;object-fit:cover;border-radius:10px;border:1px solid #e5e7eb}
    </style>
</head>
<body>
<div class="wrap">
    <div class="top">
        <div>
            <h1 style="margin:0 0 6px;">Biến thể sản phẩm</h1>
            <div class="muted"><?= e($product['product_name']) ?> — <?= e($product['product_code']) ?></div>
        </div>
        <div style="display:flex;gap:10px;flex-wrap:wrap;">
            <a class="btn btn-secondary" href="<?= route_url('/admin/product_form.php') ?>?id=<?= (int)$productId ?>">Quay lại sản phẩm</a>
            <a class="btn btn-secondary" href="<?= route_url('/admin/products.php') ?>">Danh sách sản phẩm</a>
        </div>
    </div>

    <?php if ($message): ?><div class="alert ok"><?= e($message) ?></div><?php endif; ?>
    <?php if ($error): ?><div class="alert bad"><?= e($error) ?></div><?php endif; ?>

    <div class="card" style="margin-bottom:18px;">
        <h2 style="margin-top:0;">Tạo nhanh ma trận biến thể</h2>
        <form method="post">
            <?= csrf_field() ?>
            <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
            <input type="hidden" name="action" value="bulk_generate">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Màu sắc</label>
                    <input class="form-control" name="bulk_colors" value="<?= e($_POST['bulk_colors'] ?? implode(', ', $bulkDefaults['colors'])) ?>" placeholder="Xanh, Đỏ, Tím, Vàng hoặc Xanh / Đỏ / Tím / Vàng">
                </div>
                <div class="form-group">
                    <label class="form-label">Size</label>
                    <input class="form-control" name="bulk_sizes" value="<?= e($_POST['bulk_sizes'] ?? implode(', ', $bulkDefaults['sizes'])) ?>" placeholder="S, M, L hoặc S / M / L">
                </div>
            </div>
            <div class="helper" style="margin-bottom:14px;">Nếu nhập cả màu và size, hệ thống sẽ tự nhân tổ hợp. Ví dụ 4 màu × 3 size = 12 biến thể. Hệ thống sẽ tự bỏ qua tổ hợp đã tồn tại.</div>
            <button class="btn btn-primary" type="submit">Tạo nhanh biến thể</button>
        </form>
    </div>

    <div class="grid">
        <div class="card">
            <h2 style="margin-top:0;">Danh sách biến thể</h2>
            <table>
                <thead><tr><th>Ảnh</th><th>SKU</th><th>Màu</th><th>Size</th><th>Giá bán</th><th>Tồn</th><th></th></tr></thead>
                <tbody>
                <?php if (!$variants): ?>
                    <tr><td colspan="7" class="muted" style="padding:24px 10px;">Chưa có biến thể nào.</td></tr>
                <?php endif; ?>
                <?php foreach ($variants as $variant): ?>
                    <tr>
                        <td><?php if (!empty($variant['image_url'])): ?><img class="preview-image" src="<?= e(resolve_media_url($variant['image_url'])) ?>" alt="<?= e($variant['variant_name'] ?: 'Variant') ?>"><?php endif; ?></td>
                        <td><div style="font-weight:700;"><?= e($variant['sku']) ?></div><?php if (!empty($variant['is_default'])): ?><span class="pill">Mặc định</span><?php endif; ?></td>
                        <td><?= e($variant['color_value'] ?: '-') ?></td>
                        <td><?= e($variant['size_value'] ?: '-') ?></td>
                        <td><?= format_price(calculate_variant_display_price($product, $variant)) ?></td>
                        <td><?= (int)$variant['stock_qty'] ?></td>
                        <td>
                            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                <a class="btn btn-secondary" href="<?= route_url('/admin/product_variants.php') ?>?product_id=<?= (int)$productId ?>&id=<?= (int)$variant['id'] ?>">Sửa</a>
                                <form method="post" onsubmit="return confirm('Xóa biến thể này?');">
                                    <?= csrf_field() ?>
                                    <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="variant_id" value="<?= (int)$variant['id'] ?>">
                                    <button class="btn btn-danger" type="submit">Xóa</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <div class="card">
            <h2 style="margin-top:0;"><?= $editingVariant ? 'Sửa biến thể' : 'Thêm biến thể mới' ?></h2>
            <form method="post" enctype="multipart/form-data">
                <?= csrf_field() ?>
                <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
                <input type="hidden" name="variant_id" value="<?= (int)($editingVariant['id'] ?? 0) ?>">
                <div class="form-grid">
                    <div class="form-group"><label class="form-label">Màu</label><input class="form-control" name="color_value" value="<?= e($editingVariant['color_value'] ?? '') ?>"></div>
                    <div class="form-group"><label class="form-label">Size</label><input class="form-control" name="size_value" value="<?= e($editingVariant['size_value'] ?? '') ?>"></div>
                    <div class="form-group"><label class="form-label">Tên biến thể</label><input class="form-control" name="variant_name" value="<?= e($editingVariant['variant_name'] ?? '') ?>"></div>
                    <div class="form-group"><label class="form-label">SKU</label><input class="form-control" name="sku" value="<?= e($editingVariant['sku'] ?? '') ?>"></div>
                    <div class="form-group"><label class="form-label">Giá gốc</label><input class="form-control" type="number" step="1000" min="0" name="original_price" value="<?= e((string)($editingVariant['original_price'] ?? $product['original_price'] ?? 0)) ?>"></div>
                    <div class="form-group"><label class="form-label">Giá bán</label><input class="form-control" type="number" step="1000" min="0" name="sale_price" value="<?= e((string)($editingVariant['sale_price'] ?? $product['sale_price'] ?? '')) ?>"></div>
                    <div class="form-group"><label class="form-label">Giá nhập</label><input class="form-control" type="number" step="1000" min="0" name="purchase_price" value="<?= e((string)($editingVariant['purchase_price'] ?? $product['purchase_price'] ?? '')) ?>"></div>
                    <div class="form-group"><label class="form-label">Tồn kho</label><input class="form-control" type="number" min="0" name="stock_qty" value="<?= e((string)($editingVariant['stock_qty'] ?? 0)) ?>"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Upload ảnh riêng cho biến thể</label>
                    <input class="form-control" type="file" name="variant_image_file" accept="image/*">
                </div>
                <?php if ($imagePool): ?>
                <div class="form-group">
                    <label class="form-label">Hoặc chọn ảnh từ danh sách ảnh của sản phẩm</label>
                    <div class="image-choices" id="galleryChoices">
                        <?php foreach ($imagePool as $imageUrl): ?>
                            <?php $checked = $editingImage !== '' && $editingImage === $imageUrl; ?>
                            <label class="thumb-choice <?= $checked ? 'active' : '' ?>">
                                <input type="radio" name="gallery_image_url" value="<?= e($imageUrl) ?>" <?= $checked ? 'checked' : '' ?>>
                                <img src="<?= e(resolve_media_url($imageUrl)) ?>" alt="Ảnh sản phẩm">
                            </label>
                        <?php endforeach; ?>
                    </div>
                </div>
                <?php endif; ?>
                <div class="form-group">
                    <label class="form-label">Hoặc nhập URL / giữ ảnh hiện tại</label>
                    <input class="form-control" name="image_url" value="<?= e($editingVariant['image_url'] ?? '') ?>" placeholder="Để trống nếu muốn dùng ảnh upload hoặc ảnh đã chọn ở trên">
                </div>
                <div style="display:flex;gap:14px;flex-wrap:wrap;margin:8px 0 18px;">
                    <label><input type="checkbox" name="is_default" value="1" <?= !empty($editingVariant['is_default']) ? 'checked' : '' ?>> Đặt làm biến thể mặc định</label>
                    <label><input type="checkbox" name="is_active" value="1" <?= !isset($editingVariant['is_active']) || !empty($editingVariant['is_active']) ? 'checked' : '' ?>> Đang bán</label>
                </div>
                <div style="display:flex;gap:10px;flex-wrap:wrap;">
                    <button class="btn btn-primary" type="submit">Lưu biến thể</button>
                    <a class="btn btn-secondary" href="<?= route_url('/admin/product_variants.php') ?>?product_id=<?= (int)$productId ?>">Tạo mới</a>
                </div>
            </form>
            <div class="helper" style="margin-top:14px;">Bạn có thể upload ảnh riêng cho từng biến thể, hoặc chọn nhanh một ảnh từ list ảnh chung của sản phẩm này.</div>
        </div>
    </div>
</div>
<script>
document.querySelectorAll('#galleryChoices .thumb-choice input').forEach(function(input){
    input.addEventListener('change', function(){
        document.querySelectorAll('#galleryChoices .thumb-choice').forEach(function(item){ item.classList.remove('active'); });
        if (this.checked) { this.closest('.thumb-choice').classList.add('active'); }
    });
});
</script>
</body>
</html>
