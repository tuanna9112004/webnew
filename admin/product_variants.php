<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

// Hỗ trợ nhận diện cả param product_id và id để tránh lỗi "Không tìm thấy sản phẩm"
$productId = (int)($_GET['product_id'] ?? $_POST['product_id'] ?? $_GET['id'] ?? 0);
$product = $productId > 0 ? get_product($productId) : null;
if (!$product) {
    http_response_code(404);
    exit('Không tìm thấy sản phẩm để quản lý biến thể.');
}

$variantId = (int)($_GET['id'] ?? 0);
$editingVariant = $variantId > 0 ? get_product_variant($variantId, $productId) : null;
$message = null;
$error = null;

// Lấy danh sách ảnh hiện tại của sản phẩm để làm Image Pool
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

    // 1. CHỨC NĂNG XÓA 1 BIẾN THỂ
    if ($action === 'delete') {
        $deleteId = (int)($_POST['variant_id'] ?? 0);
        if ($deleteId > 0) {
            db()->prepare('DELETE FROM product_variants WHERE id = ? AND product_id = ?')->execute([$deleteId, $productId]);
            sync_product_variant_summary($productId);
            header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&deleted=1'));
            exit;
        }
    }

    // 2. CHỨC NĂNG XÓA TẤT CẢ BIẾN THỂ
    if ($action === 'delete_all') {
        db()->prepare('DELETE FROM product_variants WHERE product_id = ?')->execute([$productId]);
        sync_product_variant_summary($productId);
        header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&deleted_all=1'));
        exit;
    }

    // 3. CHỨC NĂNG XÓA THEO MÀU SẮC
    if ($action === 'delete_by_color') {
        $targetColor = trim((string)($_POST['target_color'] ?? ''));
        if ($targetColor !== '') {
            $stmt = db()->prepare('DELETE FROM product_variants WHERE product_id = ? AND color_value = ?');
            $stmt->execute([$productId, $targetColor]);
            $deletedCount = $stmt->rowCount();
            sync_product_variant_summary($productId);
            header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&deleted_color=' . urlencode($targetColor) . '&count=' . $deletedCount));
            exit;
        }
    }

    // 4. CHỨC NĂNG THÊM NHANH 1 BIẾN THỂ (QUICK ADD)
    if ($action === 'quick_add') {
        $qColor = trim((string)($_POST['q_color'] ?? ''));
        $qSize = trim((string)($_POST['q_size'] ?? ''));
        $qQty = max(0, (int)($_POST['q_qty'] ?? 0));
        
        $sku = generate_variant_sku_by_values($product, $qColor, $qSize);
        $vName = build_variant_label(['color_value' => $qColor ?: null, 'size_value' => $qSize ?: null, 'variant_name' => null]);
        
        db()->prepare('INSERT INTO product_variants (product_id, sku, variant_name, size_value, color_value, original_price, sale_price, purchase_price, stock_qty, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())')
            ->execute([$productId, $sku, $vName, $qSize ?: null, $qColor ?: null, $product['original_price'], $product['sale_price'], $product['purchase_price'], $qQty]);
            
        sync_product_variant_summary($productId);
        header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&quick_added=1'));
        exit;
    }

    // 5. CHỨC NĂNG SET LẠI MA TRẬN BIẾN THỂ (Xóa cũ - Giữ trùng - Thêm mới)
    if ($action === 'bulk_generate') {
        $colorsInput = trim((string)($_POST['bulk_colors'] ?? ''));
        $sizesInput = trim((string)($_POST['bulk_sizes'] ?? ''));
        
        $colors = array_values(array_filter(array_map('trim', preg_split('/[,\|\/]/', $colorsInput))));
        $sizes = array_values(array_filter(array_map('trim', preg_split('/[,\|\/]/', $sizesInput))));
        if (empty($colors)) $colors = [''];
        if (empty($sizes)) $sizes = [''];

        $existingVariants = get_product_variants($productId, false);
        
        // Tạo mảng những tổ hợp (Màu-Size) hợp lệ mới
        $validMatrixKeys = [];
        foreach ($colors as $c) {
            foreach ($sizes as $s) {
                $cKey = $c === '' ? 'NULL' : $c;
                $sKey = $s === '' ? 'NULL' : $s;
                $validMatrixKeys[] = $cKey . '|||' . $sKey;
            }
        }

        $deletedCount = 0;
        $createdCount = 0;

        // BƯỚC 1: Xóa những biến thể hiện tại KHÔNG nằm trong ma trận mới
        foreach ($existingVariants as $ev) {
            $cKey = empty($ev['color_value']) ? 'NULL' : $ev['color_value'];
            $sKey = empty($ev['size_value']) ? 'NULL' : $ev['size_value'];
            $evKey = $cKey . '|||' . $sKey;

            if (!in_array($evKey, $validMatrixKeys, true)) {
                db()->prepare('DELETE FROM product_variants WHERE id = ?')->execute([$ev['id']]);
                $deletedCount++;
            }
        }

        // Lấy lại danh sách sau khi xóa để kiểm tra thêm mới
        $currentVariants = get_product_variants($productId, false);
        $currentKeys = [];
        foreach ($currentVariants as $cv) {
            $cKey = empty($cv['color_value']) ? 'NULL' : $cv['color_value'];
            $sKey = empty($cv['size_value']) ? 'NULL' : $cv['size_value'];
            $currentKeys[] = $cKey . '|||' . $sKey;
        }

        // BƯỚC 2: Thêm mới những biến thể có trong ma trận nhưng CHƯA CÓ trong CSDL
        foreach ($colors as $c) {
            foreach ($sizes as $s) {
                $cKey = $c === '' ? 'NULL' : $c;
                $sKey = $s === '' ? 'NULL' : $s;
                $matrixKey = $cKey . '|||' . $sKey;

                if (!in_array($matrixKey, $currentKeys, true)) {
                    $sku = generate_variant_sku_by_values($product, $c, $s);
                    $vName = build_variant_label(['color_value' => $c ?: null, 'size_value' => $s ?: null, 'variant_name' => null]);
                    
                    db()->prepare('INSERT INTO product_variants (product_id, sku, variant_name, size_value, color_value, original_price, sale_price, purchase_price, stock_qty, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, 1, NOW(), NOW())')
                        ->execute([$productId, $sku, $vName, $s ?: null, $c ?: null, $product['original_price'], $product['sale_price'], $product['purchase_price']]);
                    $createdCount++;
                }
            }
        }

        sync_product_variant_summary($productId);
        header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&matrix_set=1&del=' . $deletedCount . '&add=' . $createdCount));
        exit;
    }

    // 6. LƯU THÔNG TIN 1 BIẾN THỂ (Edit/Add)
    if ($action === 'save') {
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
        $syncColorImage = !empty($_POST['sync_color_image']) ? 1 : 0;

        $uploadedImage = handle_image_upload($_FILES['variant_image_file'] ?? null, [
            'destination' => 'uploads',
            'optimize' => true,
            'max_width' => 1400,
            'jpeg_quality' => 82,
            'webp_quality' => 80,
        ]);

        $finalImageUrl = null;
        $isNewUploadedImage = false;

        if ($uploadedImage) {
            $finalImageUrl = $uploadedImage;
            $isNewUploadedImage = true;
        } elseif ($selectedGalleryImage !== '' && in_array($selectedGalleryImage, $imagePool, true)) {
            $finalImageUrl = $selectedGalleryImage;
        } elseif ($manualImageUrl !== '') {
            $finalImageUrl = $manualImageUrl;
            $isNewUploadedImage = true; // Tính manual URL là ảnh mới để gán vào gallery
        } elseif ($editingVariant && !empty($editingVariant['image_url'])) {
            $finalImageUrl = $editingVariant['image_url'];
        }

        // Tự động gán ảnh vừa upload/nhập url vào thư viện ảnh chung của sản phẩm
        if ($isNewUploadedImage && $finalImageUrl !== '') {
            if (!in_array($finalImageUrl, $imagePool, true)) {
                db()->prepare('INSERT INTO product_images (product_id, image_url, sort_order) VALUES (?, ?, 99)')->execute([$productId, $finalImageUrl]);
            }
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

            // Đồng bộ ảnh cho biến thể cùng màu
            if ($syncColorImage && $finalImageUrl && $colorValue !== '') {
                db()->prepare('UPDATE product_variants SET image_url = ?, updated_at = NOW() WHERE product_id = ? AND color_value = ?')
                    ->execute([$finalImageUrl, $productId, $colorValue]);
            }

            sync_product_variant_summary($productId);
            header('Location: ' . route_url('/admin/product_variants.php?product_id=' . $productId . '&saved=1'));
            exit;
        } catch (Throwable $e) {
            $error = $e->getMessage();
        }
    }
}

// Xử lý thông báo Flash
if (isset($_GET['saved'])) $message = 'Đã lưu biến thể thành công.';
if (isset($_GET['deleted'])) $message = 'Đã xóa biến thể.';
if (isset($_GET['deleted_all'])) $message = 'Đã dọn dẹp sạch sẽ toàn bộ biến thể.';
if (isset($_GET['quick_added'])) $message = 'Đã thêm nhanh biến thể thành công.';
if (isset($_GET['deleted_color'])) $message = 'Đã xóa ' . (int)$_GET['count'] . ' biến thể màu "' . e($_GET['deleted_color']) . '".';
if (isset($_GET['matrix_set'])) $message = 'Set ma trận thành công: Xóa ' . (int)$_GET['del'] . ' cũ, Thêm ' . (int)$_GET['add'] . ' mới.';
if (isset($_GET['bulk_created'])) $message = 'Tạo cũ (không xóa): Đã thêm ' . (int)$_GET['bulk_created'] . ' biến thể mới.';

$variants = get_product_variants($productId, false);
$pageTitle = 'Biến thể sản phẩm';
$editingImage = $editingVariant['image_url'] ?? '';
$bulkDefaults = get_product_variant_dimensions($productId);

$currentColorValue = e($editingVariant['color_value'] ?? '');
$syncCheckboxText = $currentColorValue !== '' ? 'Set ảnh này cho TẤT CẢ các size cùng màu "' . $currentColorValue . '"' : 'Set ảnh này cho tất cả biến thể cùng màu';
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
        body{font-family:Inter,sans-serif;background:#f8fafc;color:#0f172a;margin:0}.wrap{max-width:1280px;margin:0 auto;padding:24px}.top{display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;margin-bottom:18px}.card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;padding:20px;box-shadow:0 10px 30px rgba(15,23,42,.06); margin-bottom: 20px;}.grid{display:grid;grid-template-columns:1fr 1.3fr;gap:18px}.form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}.image-choices{display:grid;grid-template-columns:repeat(auto-fill,minmax(84px,1fr));gap:10px}.thumb-choice{position:relative;border:1px solid #d1d5db;border-radius:14px;padding:6px;cursor:pointer}.thumb-choice input{position:absolute;inset:0;opacity:0;cursor:pointer}.thumb-choice img{width:100%;height:92px;border-radius:10px;object-fit:cover;display:block}.thumb-choice.active{border-color:#111827;box-shadow:0 0 0 3px rgba(17,24,39,.08)}@media(max-width:980px){.grid,.form-grid{grid-template-columns:1fr}}.form-group{margin-bottom:14px}.form-label{display:block;font-size:13px;font-weight:700;margin-bottom:8px;color:#475569}.form-control{width:100%;box-sizing:border-box;padding:12px 14px;border:1px solid #d1d5db;border-radius:12px;font-size:14px}.btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;border-radius:12px;padding:11px 16px;font-size:14px;font-weight:700;text-decoration:none;border:none;cursor:pointer}.btn-primary{background:#111827;color:#fff}.btn-secondary{background:#fff;color:#111827;border:1px solid #d1d5db}.btn-danger{background:#7f1d1d;color:#fff}table{width:100%;border-collapse:collapse}th,td{padding:12px 10px;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;vertical-align:top}th{font-size:12px;text-transform:uppercase;color:#64748b}.pill{display:inline-flex;padding:5px 9px;border-radius:999px;background:#eff6ff;color:#1d4ed8;font-size:12px;font-weight:700}.muted{color:#64748b}.alert{padding:14px 16px;border-radius:12px;margin-bottom:14px;font-size:14px}.ok{background:#ecfdf5;color:#065f46;border:1px solid #a7f3d0}.bad{background:#fef2f2;color:#991b1b;border:1px solid #fecaca}.helper{font-size:13px;color:#64748b;line-height:1.6}.preview-image{width:56px;height:70px;object-fit:cover;border-radius:10px;border:1px solid #e5e7eb}
        
        .sync-image-wrap { background: #eff6ff; border: 1px dashed #93c5fd; padding: 10px 14px; border-radius: 12px; margin-top: 10px; display: flex; align-items: center; gap: 10px; cursor: pointer; }
        .sync-image-wrap:hover { background: #dbeafe; }
        .sync-image-wrap input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; accent-color: #2563eb; }
        .sync-image-wrap span { font-size: 13px; font-weight: 600; color: #1e3a8a; }

        .quick-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; }
        .btn-small { padding: 6px 12px; font-size: 13px; border-radius: 8px; }
        
        /* Flex hàng dọc để Card Danh sách dài theo Card Form */
        .flex-column-card { display: flex; flex-direction: column; }
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

    <div class="grid">
        <div class="flex-column-card">
            
            <div class="card">
                <h2 style="margin-top:0; font-size:18px;">Set Ma trận Biến thể</h2>
                <form method="post">
                    <?= csrf_field() ?>
                    <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
                    <input type="hidden" name="action" value="bulk_generate">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Tổ hợp Màu (cách bằng dấu , hoặc /)</label>
                            <input class="form-control" name="bulk_colors" value="<?= e(implode(', ', $bulkDefaults['colors'])) ?>" placeholder="Xanh, Đỏ, Tím, Vàng">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Tổ hợp Size</label>
                            <input class="form-control" name="bulk_sizes" value="<?= e(implode(', ', $bulkDefaults['sizes'])) ?>" placeholder="S, M, L">
                        </div>
                    </div>
                    <div class="helper" style="margin-bottom:14px; color:#b45309; background:#fffbeb; padding:8px; border-radius:8px;">
                        <strong>Lưu ý:</strong> Bấm nút này hệ thống sẽ tự động XÓA các biến thể cũ không nằm trong 2 ô trên, GIỮ LẠI biến thể hợp lệ, và THÊM MỚI các tổ hợp còn thiếu.
                    </div>
                    <button class="btn btn-primary" type="submit" onclick="return confirm('Chắc chắn set ma trận mới? Các biến thể không khớp màu/size trên sẽ bị xóa!');">Set Ma Trận</button>
                </form>
            </div>

            <div class="card">
                <h2 style="margin-top:0; font-size:18px;">Thêm 1 biến thể (Quick Add)</h2>
                <form method="post" style="display:flex; gap:10px; align-items:flex-end; flex-wrap:wrap;">
                    <?= csrf_field() ?>
                    <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
                    <input type="hidden" name="action" value="quick_add">
                    <div class="form-group" style="margin:0; flex:1;"><label class="form-label">Màu</label><input class="form-control" name="q_color" required></div>
                    <div class="form-group" style="margin:0; flex:1;"><label class="form-label">Size</label><input class="form-control" name="q_size"></div>
                    <div class="form-group" style="margin:0; flex:1;"><label class="form-label">Tồn kho</label><input class="form-control" type="number" min="0" value="0" name="q_qty"></div>
                    <button class="btn btn-secondary" type="submit" style="height:46px;">+ Thêm</button>
                </form>
            </div>

            <div class="card" style="flex-grow: 1;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                    <h2 style="margin:0; font-size:18px;">Danh sách biến thể</h2>
                    <div class="quick-actions">
                        <form method="post" style="display:inline;" onsubmit="return confirmColorDelete(this);">
                            <?= csrf_field() ?>
                            <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
                            <input type="hidden" name="action" value="delete_by_color">
                            <input type="hidden" name="target_color" id="targetColorInput">
                            <button class="btn btn-secondary btn-small" type="submit">Xóa theo màu</button>
                        </form>
                        
                        <form method="post" style="display:inline;" onsubmit="return confirm('DỌN DẸP SẠCH SẼ: Bạn có chắc chắn muốn xóa TOÀN BỘ biến thể không?');">
                            <?= csrf_field() ?>
                            <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
                            <input type="hidden" name="action" value="delete_all">
                            <button class="btn btn-danger btn-small" type="submit">Xóa tất cả</button>
                        </form>
                    </div>
                </div>
                
                <table>
                    <thead><tr><th>Ảnh</th><th>SKU</th><th>Màu</th><th>Size</th><th>Giá bán</th><th>Tồn</th><th></th></tr></thead>
                    <tbody>
                    <?php if (!$variants): ?>
                        <tr><td colspan="7" class="muted" style="padding:24px 10px; text-align:center;">Chưa có biến thể nào.</td></tr>
                    <?php endif; ?>
                    <?php foreach ($variants as $variant): ?>
                        <tr style="<?= $editingVariant && $editingVariant['id'] === $variant['id'] ? 'background:#f0fdf4;' : '' ?>">
                            <td><?php if (!empty($variant['image_url'])): ?><img class="preview-image" src="<?= e(resolve_media_url($variant['image_url'])) ?>" alt="Var"><?php endif; ?></td>
                            <td><div style="font-weight:700;"><?= e($variant['sku']) ?></div><?php if (!empty($variant['is_default'])): ?><span class="pill" style="margin-top:4px;">Mặc định</span><?php endif; ?></td>
                            <td><?= e($variant['color_value'] ?: '-') ?></td>
                            <td><?= e($variant['size_value'] ?: '-') ?></td>
                            <td><?= format_price(calculate_variant_display_price($product, $variant)) ?></td>
                            <td><?= (int)$variant['stock_qty'] ?></td>
                            <td>
                                <div style="display:flex;gap:4px;flex-direction:column;">
                                    <a class="btn btn-secondary btn-small" href="<?= route_url('/admin/product_variants.php') ?>?product_id=<?= (int)$productId ?>&id=<?= (int)$variant['id'] ?>">Sửa</a>
                                    <form method="post" onsubmit="return confirm('Xóa biến thể này?');">
                                        <?= csrf_field() ?>
                                        <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="variant_id" value="<?= (int)$variant['id'] ?>">
                                        <button class="btn btn-danger btn-small" style="width:100%;" type="submit">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div>
            <div class="card" style="position: sticky; top: 24px;">
                <h2 style="margin-top:0; color: #1d4ed8;"><?= $editingVariant ? 'Đang sửa: ' . e($editingVariant['sku']) : 'Thêm biến thể (Chi tiết)' ?></h2>
                <form method="post" enctype="multipart/form-data">
                    <?= csrf_field() ?>
                    <input type="hidden" name="product_id" value="<?= (int)$productId ?>">
                    <input type="hidden" name="variant_id" value="<?= (int)($editingVariant['id'] ?? 0) ?>">
                    <div class="form-grid">
                        <div class="form-group"><label class="form-label">Màu</label><input class="form-control" id="inputColorValue" name="color_value" value="<?= e($editingVariant['color_value'] ?? '') ?>"></div>
                        <div class="form-group"><label class="form-label">Size</label><input class="form-control" name="size_value" value="<?= e($editingVariant['size_value'] ?? '') ?>"></div>
                        <div class="form-group"><label class="form-label">Tên biến thể</label><input class="form-control" name="variant_name" value="<?= e($editingVariant['variant_name'] ?? '') ?>" placeholder="Tự sinh nếu để trống"></div>
                        <div class="form-group"><label class="form-label">SKU</label><input class="form-control" name="sku" value="<?= e($editingVariant['sku'] ?? '') ?>" placeholder="Tự sinh nếu để trống"></div>
                        <div class="form-group"><label class="form-label">Giá gốc</label><input class="form-control" type="number" step="1000" min="0" name="original_price" value="<?= e((string)($editingVariant['original_price'] ?? $product['original_price'] ?? 0)) ?>"></div>
                        <div class="form-group"><label class="form-label">Giá bán</label><input class="form-control" type="number" step="1000" min="0" name="sale_price" value="<?= e((string)($editingVariant['sale_price'] ?? $product['sale_price'] ?? '')) ?>"></div>
                        <div class="form-group"><label class="form-label">Giá nhập</label><input class="form-control" type="number" step="1000" min="0" name="purchase_price" value="<?= e((string)($editingVariant['purchase_price'] ?? $product['purchase_price'] ?? '')) ?>"></div>
                        <div class="form-group"><label class="form-label">Tồn kho</label><input class="form-control" type="number" min="0" name="stock_qty" value="<?= e((string)($editingVariant['stock_qty'] ?? 0)) ?>"></div>
                    </div>
                    
                    <div class="form-group" style="margin-top:14px;">
                        <label class="form-label">Upload ảnh riêng cho biến thể</label>
                        <input class="form-control" type="file" name="variant_image_file" accept="image/*">
                        <div class="helper">Ảnh tải lên sẽ tự động lưu vào Kho ảnh chung của Sản phẩm.</div>
                    </div>
                    
                    <?php if ($imagePool): ?>
                    <div class="form-group">
                        <label class="form-label">Hoặc chọn nhanh từ ảnh của sản phẩm</label>
                        <div class="image-choices" id="galleryChoices">
                            <?php foreach ($imagePool as $imageUrl): ?>
                                <?php $checked = $editingImage !== '' && $editingImage === $imageUrl; ?>
                                <label class="thumb-choice <?= $checked ? 'active' : '' ?>">
                                    <input type="radio" name="gallery_image_url" value="<?= e($imageUrl) ?>" <?= $checked ? 'checked' : '' ?>>
                                    <img src="<?= e(resolve_media_url($imageUrl)) ?>" alt="Img">
                                </label>
                            <?php endforeach; ?>
                        </div>
                    </div>
                    <?php endif; ?>
                    
                    <div class="form-group">
                        <label class="form-label">Hoặc nhập Link ảnh ngoài</label>
                        <input class="form-control" name="image_url" value="<?= e($editingVariant['image_url'] ?? '') ?>">
                    </div>

                    <label class="sync-image-wrap" id="syncImageWrap" style="display: <?= $currentColorValue !== '' ? 'flex' : 'none' ?>;">
                        <input type="checkbox" name="sync_color_image" value="1" checked>
                        <span id="syncImageText"><?= $syncCheckboxText ?></span>
                    </label>

                    <div style="display:flex;gap:14px;flex-wrap:wrap;margin:18px 0 18px;">
                        <label><input type="checkbox" name="is_default" value="1" <?= !empty($editingVariant['is_default']) ? 'checked' : '' ?>> Đặt làm mặc định</label>
                        <label><input type="checkbox" name="is_active" value="1" <?= !isset($editingVariant['is_active']) || !empty($editingVariant['is_active']) ? 'checked' : '' ?>> Đang bán</label>
                    </div>
                    
                    <div style="display:flex;gap:10px;flex-wrap:wrap;">
                        <button class="btn btn-primary" style="flex:1;" type="submit">Lưu biến thể này</button>
                        <?php if ($editingVariant): ?>
                            <a class="btn btn-secondary" href="<?= route_url('/admin/product_variants.php') ?>?product_id=<?= (int)$productId ?>">Hủy sửa</a>
                        <?php endif; ?>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
// Chọn ảnh bằng cách Click
document.querySelectorAll('#galleryChoices .thumb-choice input').forEach(function(input){
    input.addEventListener('change', function(){
        document.querySelectorAll('#galleryChoices .thumb-choice').forEach(function(item){ item.classList.remove('active'); });
        if (this.checked) { this.closest('.thumb-choice').classList.add('active'); }
    });
});

// Script cập nhật Checkbox Đồng bộ
const inputColor = document.getElementById('inputColorValue');
const syncWrap = document.getElementById('syncImageWrap');
const syncText = document.getElementById('syncImageText');

if (inputColor && syncWrap && syncText) {
    inputColor.addEventListener('input', function() {
        const val = this.value.trim();
        if (val !== '') {
            syncWrap.style.display = 'flex';
            syncText.textContent = 'Set ảnh này cho TẤT CẢ size cùng màu "' + val + '"';
        } else {
            syncWrap.style.display = 'none';
        }
    });
}

// Hàm cảnh báo Xóa theo màu
function confirmColorDelete(form) {
    let color = prompt("Nhập ĐÚNG tên màu bạn muốn xóa tất cả các size (Ví dụ: Đen, Trắng, Đỏ...):");
    if (color !== null && color.trim() !== '') {
        document.getElementById('targetColorInput').value = color.trim();
        return true;
    }
    return false;
}
</script>
</body>
</html>