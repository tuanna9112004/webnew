<?php
require_once __DIR__ . '/includes/functions.php';

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
$categorySlug = trim((string)($_GET['category_slug'] ?? ''));
$productSlug = trim((string)($_GET['slug'] ?? ''));

if ($categorySlug !== '' && $productSlug !== '') {
    $product = get_product_by_slug($categorySlug, $productSlug);
} elseif ($id > 0) {
    $product = get_product($id);
    if ($product) {
        header('Location: ' . product_detail_url($product), true, 301);
        exit;
    }
} else {
    $product = null;
}

if (!$product) {
    http_response_code(404);
    exit('Không tìm thấy sản phẩm.');
}

$canonicalUrl = product_detail_url($product);
$currentRequestPath = parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH) ?: '';
$expectedPath = product_detail_path($product);
if ($currentRequestPath !== '' && rawurldecode(rtrim($currentRequestPath, '/')) !== rawurldecode(rtrim($expectedPath, '/'))) {
    header('Location: ' . $canonicalUrl, true, 301);
    exit;
}

$images = get_product_images((int)$product['id']);
$variantOptions = get_product_variants((int)$product['id']);
$pageTitle = $product['product_name'];
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$cartNotice = flash_get('cart_notice');

$galleryImages = [];
if (!empty($product['thumbnail'])) {
    $galleryImages[] = resolve_media_url($product['thumbnail']);
}
foreach ($images as $img) {
    if (!empty($img['image_url'])) {
        $galleryImages[] = resolve_media_url($img['image_url']);
    }
}
$galleryImages = array_values(array_unique($galleryImages));
if (!$galleryImages) {
    $galleryImages[] = resolve_media_url(null);
}

$defaultVariant = null;
foreach ($variantOptions as $variant) {
    if (!empty($variant['is_default'])) {
        $defaultVariant = $variant;
        break;
    }
}
if (!$defaultVariant && $variantOptions) {
    $defaultVariant = $variantOptions[0];
}

$displayPrice = calculate_variant_display_price($product, $defaultVariant);
$displayOriginal = calculate_variant_original_price($product, $defaultVariant);
$variantPayload = build_variant_matrix_payload($variantOptions);
$colorChoices = $variantPayload['colors'];
$sizeChoices = $variantPayload['sizes'];
$requiresVariantChoice = count($variantPayload['items']) > 1 && (count($colorChoices) > 1 || count($sizeChoices) > 1);
$shopZaloLink = shop_zalo_link();
$zaloText = rawurlencode('Tôi muốn mua sản phẩm: ' . $product['product_name'] . ' - Mã: ' . $product['product_code']);
$buyZaloLink = $shopZaloLink . (strpos($shopZaloLink, '?') !== false ? '&' : '?') . 'text=' . $zaloText;

require_once __DIR__ . '/includes/header.php';
?>
<style>
.product-detail-shell{display:grid;grid-template-columns:minmax(0,1.02fr) minmax(0,.98fr);gap:48px;padding:26px 0 64px;max-width:100%}
.gallery-box,.detail-box-up{background:#fff;border:1px solid #ececec;border-radius:28px;box-shadow:0 14px 40px rgba(15,23,42,.05);min-width:0;width:100%;box-sizing:border-box}
.gallery-box{padding:22px}
.main-image-box{border-radius:22px;background:#f7f7f7;overflow:hidden;display:flex;align-items:center;justify-content:center;min-height:620px;position:relative;}
.main-image-box img{width:100%;height:100%;max-height:700px;object-fit:cover;transition:opacity 0.3s ease;}

/* TỐI ƯU THUMBNAIL CHO PHÉP KÉO NGANG (SCROLL) MƯỢT MÀ VÀ KHÔNG BỊ TRÀN */
.thumb-row {
    display: flex;
    flex-wrap: nowrap;
    gap: 12px;
    margin-top: 14px;
    overflow-x: auto;
    overflow-y: hidden;
    padding-bottom: 8px;
    scroll-behavior: smooth;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: thin;
    scrollbar-color: #d4d4d8 transparent;
    width: 100%;
}
.thumb-row::-webkit-scrollbar {
    height: 4px;
}
.thumb-row::-webkit-scrollbar-track {
    background: transparent;
}
.thumb-row::-webkit-scrollbar-thumb {
    background: #d4d4d8;
    border-radius: 10px;
}
.thumb-row button {
    border: 1px solid #dedede;
    background: #fff;
    padding: 0;
    border-radius: 16px;
    flex: 0 0 88px;
    height: 108px;
    overflow: hidden;
    cursor: pointer;
    transition: all 0.2s;
}
.thumb-row button.active{border-color:#111;box-shadow:0 0 0 2px rgba(17,17,17,.08)}
.thumb-row img{width:100%;height:100%;object-fit:cover}

.detail-box-up{padding:30px 32px}
.product-code{font-size:14px;color:#7b7b86;margin-top:8px}
.price-stack{display:flex;align-items:flex-end;gap:12px;margin:18px 0 10px}
.price-sale{font-size:34px;font-weight:800;letter-spacing:-.02em}
.price-original{font-size:18px;color:#9ca3af;text-decoration:line-through}
.variant-section{margin:28px 0 12px}
.variant-row{display:flex;align-items:flex-start;gap:22px;margin-bottom:22px}
.variant-label{width:104px;flex:0 0 104px;font-size:16px;font-weight:700;padding-top:10px}
.choice-wrap{display:flex;gap:12px;flex-wrap:wrap}

/* FIX Ô CHỌN MÀU: HỖ TRỢ CẢ ẢNH VÀ CHẤM MÀU */
.color-chip{display:inline-flex;align-items:center;gap:8px;min-height:40px;padding:4px 14px 4px 6px;border-radius:10px;border:1px solid #d4d4d8;background:#fff;cursor:pointer;transition:.2s;font-size:15px;font-weight:600;color:#111}
.color-chip.no-img{padding:0 14px 0 10px}
.color-swatch{width:20px;height:20px;border-radius:50%;border:1px solid rgba(0,0,0,0.1);display:inline-block;flex-shrink:0}
.color-chip img{width:28px;height:28px;border-radius:6px;object-fit:cover;border:1px solid #eee;flex-shrink:0}
.color-chip.active{border-color:#111;box-shadow:0 0 0 1px #111;background:#fafafa}
.color-chip.disabled{opacity:.35;cursor:not-allowed;background:#f9f9f9}

/* Ô CHỌN SIZE */
.size-chip{min-width:44px;height:40px;padding:0 14px;border-radius:10px;border:1px solid #d4d4d8;background:#fff;font-weight:700;font-size:15px;line-height:1;cursor:pointer;transition:.2s}
.size-chip.active{border-color:#111;background:#111;color:#fff}
.size-chip.disabled{opacity:.35;cursor:not-allowed}

.qty-row{display:flex;align-items:center;gap:18px;margin:20px 0 14px}
.qty-label{width:104px;flex:0 0 104px;font-size:16px;font-weight:700}
.qty-control{display:inline-flex;align-items:center;border:1px solid #e5e7eb;border-radius:12px;overflow:hidden}
.qty-control button{width:42px;height:42px;border:none;background:#fff;font-size:28px;cursor:pointer;color:#4b5563}
.qty-control input{width:56px;height:42px;border:none;text-align:center;font-weight:700;font-size:20px}
.variant-hint{min-height:28px;color:#a1a1aa;font-size:14px;padding-left:126px}
.action-row{display:flex;gap:16px;align-items:center;flex-wrap:wrap;margin-top:8px}
.wish-btn{width:68px;height:68px;border:1px solid #e5e7eb;border-radius:10px;background:#f5f5f5;display:inline-flex;align-items:center;justify-content:center;cursor:pointer}
.wish-btn svg{width:28px;height:28px;color:#8b8b95}
.primary-outline,.primary-dark{height:68px;border-radius:10px;padding:0 34px;font-size:16px;font-weight:800;letter-spacing:.02em;border:1px solid #111;display:inline-flex;align-items:center;justify-content:center;text-decoration:none;cursor:pointer;transition:all 0.2s;}
.primary-outline{background:#fff;color:#111;min-width:272px}
.primary-dark{background:#232323;color:#fff;min-width:186px}
.primary-outline[disabled],.primary-dark.disabled{opacity:.55;cursor:not-allowed;pointer-events:none}
.sub-links{display:flex;gap:14px;flex-wrap:wrap;margin-top:14px}
.sub-links a{font-size:14px;color:#4b5563}
.detail-info{margin-top:36px;border-top:1px solid #efefef;padding-top:26px}
.detail-info h3{margin:0 0 16px;font-size:18px}
.info-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px 18px;margin-bottom:22px}
.info-card{background:#fafafa;border:1px solid #f0f0f0;border-radius:16px;padding:14px 16px}
.info-card span{display:block;color:#8b8b95;font-size:13px;margin-bottom:6px}
.stock-note{color:#10b981;font-size:14px;font-weight:700}
.desc-box{font-size:15px;line-height:1.75;color:#444}
.alert-float{margin-bottom:16px}
.mobile-sticky-actions{display:none}

/* CSS Cho Hiệu Ứng Bay Vào Giỏ Hàng */
.flying-img {
    position: fixed;
    z-index: 99999;
    border-radius: 50%;
    opacity: 0.8;
    pointer-events: none;
    box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    transition: all 0.8s cubic-bezier(0.25, 1, 0.5, 1);
}

/* Toast Thông báo AJAX */
.ajax-toast {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: #10b981;
    color: #fff;
    padding: 14px 24px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    font-weight: 600;
    z-index: 9999;
    transform: translateY(100px);
    opacity: 0;
    transition: all 0.3s ease;
}
.ajax-toast.show {
    transform: translateY(0);
    opacity: 1;
}

/* CSS CHO SLIDER ẢNH */
.slider-arrow {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    width: 44px;
    height: 44px;
    background: rgba(255, 255, 255, 0.8);
    border: 1px solid #e5e7eb;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    z-index: 10;
    transition: all 0.2s;
    color: #111;
}
.slider-arrow:hover {
    background: #fff;
    box-shadow: 0 6px 16px rgba(0,0,0,0.12);
    transform: translateY(-50%) scale(1.05);
}
.slider-prev { left: 16px; }
.slider-next { right: 16px; }

@media(max-width:1024px){
    .product-detail-shell{grid-template-columns:1fr;gap:22px}
    .variant-hint{padding-left:0}
    .variant-row,.qty-row{flex-direction:column;gap:10px;align-items:flex-start}
    .variant-label,.qty-label{width:auto;flex:initial;padding-top:0}
    .main-image-box{min-height:420px}
}

@media(max-width:768px){
    .detail-box-up{padding:22px 18px}
    .main-image-box{min-height:340px}
    .primary-outline,.primary-dark{width:100%;min-width:0}
    .wish-btn{width:56px;height:56px}
    .action-row{align-items:stretch}
    .mobile-sticky-actions{display:flex;position:fixed;left:0;right:0;bottom:0;z-index:999;background:rgba(255,255,255,.96);backdrop-filter:blur(14px);padding:10px 14px;border-top:1px solid #e5e7eb;gap:10px}
    .mobile-sticky-actions button,.mobile-sticky-actions a{flex:1;height:52px;border-radius:12px;font-size:15px;font-weight:800}
    .info-grid{grid-template-columns:1fr 1fr} 
    .slider-arrow{width:36px; height:36px;}
    
    /* TỐI ƯU MOBILE CHO LIST ẢNH: Ẩn thanh cuộn để tự nhiên hơn */
    .thumb-row { 
        margin-top: 10px; 
        gap: 8px; 
        padding-bottom: 0;
        scrollbar-width: none; /* Firefox */
    }
    .thumb-row::-webkit-scrollbar {
        display: none; /* Chrome, Safari, Opera */
    }
    .thumb-row button {
        flex: 0 0 64px; /* Giảm kích thước ảnh trên mobile */
        height: 80px;
        border-radius: 12px;
    }
}
</style>

<div class="product-detail-shell">
    <section class="gallery-box">
        <div class="main-image-box">
            <?php if (count($galleryImages) > 1): ?>
                <button type="button" class="slider-arrow slider-prev" id="sliderPrev" aria-label="Previous image">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
                </button>
            <?php endif; ?>

            <img id="mainProductImage" src="<?= e($galleryImages[0]) ?>" alt="<?= e($product['product_name']) ?>">

            <?php if (count($galleryImages) > 1): ?>
                <button type="button" class="slider-arrow slider-next" id="sliderNext" aria-label="Next image">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                </button>
            <?php endif; ?>
        </div>
        
        <?php if (count($galleryImages) > 1): ?>
        <div class="thumb-row" id="thumbRow">
            <?php foreach ($galleryImages as $index => $imageUrl): ?>
                <button type="button" class="<?= $index === 0 ? 'active' : '' ?>" data-image="<?= e($imageUrl) ?>" data-index="<?= $index ?>"><img src="<?= e($imageUrl) ?>" alt="thumb <?= $index + 1 ?>"></button>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>
    </section>

    <section class="detail-box-up">
        <?php if ($cartNotice): ?><div class="alert alert-<?= e($cartNotice['type'] === 'success' ? 'success' : 'info') ?> alert-float"><?= e($cartNotice['message']) ?></div><?php endif; ?>
        <div class="meta-row-wrap">
            <span class="meta-pill">Danh mục: <?= e($product['category_name'] ?: 'Chưa phân loại') ?></span>
            <?php if (!empty($product['product_type_name'])): ?><span class="meta-pill meta-pill-light">Loại: <?= e($product['product_type_name']) ?></span><?php endif; ?>
            <?php if (!empty($product['condition_names'])): ?><?php foreach (explode(', ', $product['condition_names']) as $conditionName): ?><span class="meta-pill meta-pill-accent"><?= e($conditionName) ?></span><?php endforeach; ?><?php endif; ?>
        </div>
        <h1 style="margin:0;font-size:36px;line-height:1.15"><?= e($product['product_name']) ?></h1>
        <div class="product-code">Mã SP: <?= e($product['product_code']) ?></div>

        <div class="price-stack">
            <div class="price-sale" id="productSalePrice"><?= format_price($displayPrice) ?></div>
            <div class="price-original" id="productOriginalPrice" <?= $displayOriginal <= $displayPrice ? 'style="display:none"' : '' ?>><?= format_price($displayOriginal) ?></div>
        </div>
        <p class="lead-text" style="margin:0;color:#4b5563;line-height:1.8;"><?= nl2br(e($product['short_description'] ?: 'Thiết kế gọn gàng, dễ phối và phù hợp cho nhu cầu mặc hằng ngày.')) ?></p>

        <form id="productActionForm" method="post" action="<?= route_url('/cart.php?action=add') ?>">
            <?= csrf_field() ?>
            <?= public_form_field() ?>
            <input type="hidden" name="cart_action" value="add">
            <input type="hidden" name="product_id" value="<?= (int)$product['id'] ?>">
            <input type="hidden" name="variant_id" id="selectedVariantId" value="<?= $defaultVariant ? (int)$defaultVariant['id'] : '' ?>">

            <?php if ($colorChoices): ?>
            <div class="variant-section">
                <div class="variant-row">
                    <div class="variant-label">Màu sắc:</div>
                    <div class="choice-wrap" id="colorChoiceWrap">
                        <?php foreach ($colorChoices as $color): ?>
                            <?php
                                // Tìm xem biến thể màu này có ảnh đại diện hay không
                                $variantWithColor = array_filter($variantPayload['items'], fn($v) => $v['color'] === $color && !empty($v['image_url']));
                                $variantWithColor = reset($variantWithColor);
                                $imgUrl = '';
                                if ($variantWithColor) {
                                    $imgUrl = resolve_media_url($variantWithColor['image_url']);
                                }
                            ?>
                            <button type="button" class="color-chip <?= $imgUrl ? 'has-img' : 'no-img' ?>" data-color="<?= e($color) ?>" title="<?= e($color) ?>">
                                <?php if ($imgUrl): ?>
                                    <img src="<?= e($imgUrl) ?>" alt="<?= e($color) ?>" onerror="this.outerHTML='<span class=\'color-swatch\' style=\'background: <?= e(variant_color_style($color)) ?>;\'></span>'; this.parentElement.classList.remove('has-img'); this.parentElement.classList.add('no-img');">
                                <?php else: ?>
                                    <span class="color-swatch" style="background: <?= e(variant_color_style($color)) ?>;"></span>
                                <?php endif; ?>
                                <span><?= e($color) ?></span>
                            </button>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>
            <?php endif; ?>

            <?php if ($sizeChoices): ?>
            <div class="variant-section" style="margin-top:0;">
                <div class="variant-row">
                    <div class="variant-label">Size:</div>
                    <div class="choice-wrap" id="sizeChoiceWrap">
                        <?php foreach ($sizeChoices as $size): ?>
                            <button type="button" class="size-chip" data-size="<?= e($size) ?>"><?= e($size) ?></button>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>
            <?php endif; ?>

            <div class="qty-row">
                <div class="qty-label">Số lượng:</div>
                <div class="qty-control">
                    <button type="button" id="qtyMinus">−</button>
                    <input type="number" id="qtyInput" name="quantity" min="1" value="1">
                    <button type="button" id="qtyPlus">+</button>
                </div>
            </div>
            <div class="variant-hint" id="variantHint"><?= $requiresVariantChoice ? 'Vui lòng chọn màu sắc hoặc kích cỡ!' : 'Bạn có thể thêm vào giỏ hoặc mua ngay.' ?></div>
            <div class="stock-note" id="stockNote"><?= $defaultVariant && !empty($defaultVariant['stock_qty']) ? 'Còn ' . (int)$defaultVariant['stock_qty'] . ' sản phẩm' : '' ?></div>

            <div class="action-row">
                <button type="button" class="wish-btn" aria-label="Yêu thích">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M19.5 12.57 12 20l-7.5-7.43a5 5 0 0 1 7.07-7.07L12 5.93l.43-.43a5 5 0 1 1 7.07 7.07Z"/></svg>
                </button>
                <button type="submit" class="primary-outline" id="addToCartBtn">THÊM VÀO GIỎ HÀNG</button>
                <a href="#" class="primary-dark" id="buyNowBtn">MUA NGAY</a>
            </div>
            <div class="sub-links">
                <a target="_blank" rel="noopener noreferrer" href="<?= e($buyZaloLink) ?>">Mua qua Zalo</a>
                <a href="<?= route_url('/cart.php') ?>">Xem giỏ hàng</a>
            </div>
        </form>

        <div class="detail-info">
            <h3>Thông tin chi tiết</h3>
            <div class="info-grid">
                <div class="info-card"><span>Giới tính</span><strong><?= e($product['gender'] ?: 'Đang cập nhật') ?></strong></div>
                <div class="info-card"><span>Chất liệu</span><strong><?= e($product['material'] ?: 'Đang cập nhật') ?></strong></div>
                <div class="info-card"><span>Phong cách</span><strong><?= e($product['style_name'] ?: 'Đang cập nhật') ?></strong></div>
                <div class="info-card"><span>Tổng tồn kho</span><strong><?= (int)($product['quantity'] ?? 0) ?></strong></div>
            </div>
            <div class="desc-box"><?= nl2br(e($product['information'] ?: 'Chưa có thông tin chi tiết.')) ?></div>
        </div>
    </section>
</div>

<div class="mobile-sticky-actions">
    <button type="button" class="primary-outline" id="mobileAddToCartBtn">Thêm giỏ</button>
    <a href="#" class="primary-dark" id="mobileBuyNowBtn">Mua ngay</a>
</div>

<div id="ajaxToast" class="ajax-toast">Đã thêm vào giỏ hàng!</div>

<script>
const variantsPayload = <?= json_encode($variantPayload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?>;
const galleryImages = <?= json_encode($galleryImages, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?>;
const requiresVariantChoice = <?= $requiresVariantChoice ? 'true' : 'false' ?>;
const checkoutBaseUrl = <?= json_encode(route_url('/checkout.php?product_id=' . (int)$product['id'])) ?>;
const defaultImage = <?= json_encode($galleryImages[0]) ?>;
const defaultPrices = {price: <?= json_encode($displayPrice) ?>, original: <?= json_encode($displayOriginal) ?>};
let selectedColor = <?= json_encode($defaultVariant['color_value'] ?? '') ?>;
let selectedSize = <?= json_encode($defaultVariant['size_value'] ?? '') ?>;
let selectedVariantId = <?= json_encode($defaultVariant['id'] ?? null) ?>;

// --- BIẾN TRẠNG THÁI CHO SLIDESHOW ---
let currentImageIndex = 0;
let slideInterval;
let autoPlayEnabled = true;

const colorButtons = Array.from(document.querySelectorAll('#colorChoiceWrap .color-chip'));
const sizeButtons = Array.from(document.querySelectorAll('#sizeChoiceWrap .size-chip'));
const salePriceEl = document.getElementById('productSalePrice');
const originalPriceEl = document.getElementById('productOriginalPrice');
const variantHintEl = document.getElementById('variantHint');
const stockNoteEl = document.getElementById('stockNote');
const selectedVariantInput = document.getElementById('selectedVariantId');
const addToCartBtn = document.getElementById('addToCartBtn');
const buyNowBtn = document.getElementById('buyNowBtn');
const mobileAddToCartBtn = document.getElementById('mobileAddToCartBtn');
const mobileBuyNowBtn = document.getElementById('mobileBuyNowBtn');
const qtyInput = document.getElementById('qtyInput');
const mainImageEl = document.getElementById('mainProductImage');

function formatVnd(value){ return new Intl.NumberFormat('vi-VN').format(Number(value || 0)) + ' đ'; }

function matchingVariants(){
  return (variantsPayload.items || []).filter(function(item){
    const colorOk = !selectedColor || item.color === selectedColor;
    const sizeOk = !selectedSize || item.size === selectedSize;
    return colorOk && sizeOk;
  });
}

function findExactVariant(){
  return (variantsPayload.items || []).find(function(item){
    const colorOk = (variantsPayload.colors || []).length ? item.color === selectedColor : true;
    const sizeOk = (variantsPayload.sizes || []).length ? item.size === selectedSize : true;
    return colorOk && sizeOk;
  }) || null;
}

function updateThumbActive(imageUrl){
  document.querySelectorAll('#thumbRow button').forEach(function(btn){ 
      btn.classList.toggle('active', btn.dataset.image === imageUrl); 
  });
}

function setMainImage(imageUrl, newIndex = null){
  if (!imageUrl) return;
  
  mainImageEl.style.opacity = 0.8;
  setTimeout(() => {
      mainImageEl.src = imageUrl;
      mainImageEl.style.opacity = 1;
  }, 100);
  
  updateThumbActive(imageUrl);

  if (newIndex !== null) {
      currentImageIndex = parseInt(newIndex, 10);
  } else {
      const idx = galleryImages.indexOf(imageUrl);
      if (idx !== -1) currentImageIndex = idx;
  }
}

function updateButtonsState(valid){
  addToCartBtn.disabled = !valid;
  mobileAddToCartBtn.disabled = !valid;
  buyNowBtn.classList.toggle('disabled', !valid);
  mobileBuyNowBtn.classList.toggle('disabled', !valid);
}

function refreshOptionAvailability(){
  colorButtons.forEach(function(btn){
    const color = btn.dataset.color || '';
    const possible = (variantsPayload.items || []).some(function(item){
      const colorOk = item.color === color;
      const sizeOk = !selectedSize || !item.size || item.size === selectedSize;
      return colorOk && sizeOk;
    });
    btn.classList.toggle('disabled', !possible);
    btn.classList.toggle('active', color === selectedColor);
  });
  sizeButtons.forEach(function(btn){
    const size = btn.dataset.size || '';
    const possible = (variantsPayload.items || []).some(function(item){
      const sizeOk = item.size === size;
      const colorOk = !selectedColor || !item.color || item.color === selectedColor;
      return sizeOk && colorOk;
    });
    btn.classList.toggle('disabled', !possible);
    btn.classList.toggle('active', size === selectedSize);
  });
}

function refreshVariantView(){
  refreshOptionAvailability();
  
  let targetImage = defaultImage;
  let targetIndex = 0;
  
  if (selectedColor) {
      const colorVariant = (variantsPayload.items || []).find(item => item.color === selectedColor && item.image_url);
      if (colorVariant) {
          targetImage = colorVariant.image_url.startsWith('http') || colorVariant.image_url.startsWith('/') ? colorVariant.image_url : '<?= e(BASE_URL) ?>/' + colorVariant.image_url.replace(/^\/+/, '');
          targetIndex = null; 
      }
      stopSlideShow();
  }

  setMainImage(targetImage, targetIndex);

  const variant = findExactVariant();
  if (variant) {
    selectedVariantId = variant.id;
    selectedVariantInput.value = variant.id;
    salePriceEl.textContent = formatVnd(variant.price);
    
    if (Number(variant.original_price || 0) > Number(variant.price || 0)) {
      originalPriceEl.textContent = formatVnd(variant.original_price);
      originalPriceEl.style.display = '';
    } else {
      originalPriceEl.style.display = 'none';
    }
    
    stockNoteEl.textContent = variant.stock_qty > 0 ? ('Còn ' + variant.stock_qty + ' sản phẩm') : '';
    variantHintEl.textContent = 'Đã chọn: ' + (variant.label || 'Biến thể');
    updateButtonsState(true);
    return;
  }
  
  selectedVariantId = null;
  selectedVariantInput.value = '';
  stockNoteEl.textContent = '';
  salePriceEl.textContent = formatVnd(defaultPrices.price);
  
  if (Number(defaultPrices.original) > Number(defaultPrices.price)) {
    originalPriceEl.textContent = formatVnd(defaultPrices.original);
    originalPriceEl.style.display = '';
  } else {
    originalPriceEl.style.display = 'none';
  }
  
  variantHintEl.textContent = requiresVariantChoice ? 'Vui lòng chọn màu sắc hoặc kích cỡ!' : 'Bạn có thể thêm vào giỏ hoặc mua ngay.';
  updateButtonsState(!requiresVariantChoice && !(variantsPayload.items || []).length ? true : !requiresVariantChoice && (variantsPayload.items || []).length <= 1);
}

// -----------------------------------------------------
// LOGIC SLIDESHOW TỰ ĐỘNG VÀ ĐIỀU HƯỚNG TAY
// -----------------------------------------------------
function nextImage() {
    if (!autoPlayEnabled || !galleryImages || galleryImages.length <= 1) return;
    currentImageIndex = (currentImageIndex + 1) % galleryImages.length;
    setMainImage(galleryImages[currentImageIndex], currentImageIndex);
}

function prevImage() {
    if (!autoPlayEnabled || !galleryImages || galleryImages.length <= 1) return;
    currentImageIndex = (currentImageIndex - 1 + galleryImages.length) % galleryImages.length;
    setMainImage(galleryImages[currentImageIndex], currentImageIndex);
}

function startSlideShow() {
    if (autoPlayEnabled && galleryImages && galleryImages.length > 1) {
        clearInterval(slideInterval);
        slideInterval = setInterval(nextImage, 2000); 
    }
}

function stopSlideShow() {
    autoPlayEnabled = false;
    clearInterval(slideInterval);
}

const sliderPrevBtn = document.getElementById('sliderPrev');
const sliderNextBtn = document.getElementById('sliderNext');

if (sliderPrevBtn) {
    sliderPrevBtn.addEventListener('click', function(e) {
        e.preventDefault();
        stopSlideShow(); 
        
        autoPlayEnabled = true; prevImage(); autoPlayEnabled = false;
    });
}

if (sliderNextBtn) {
    sliderNextBtn.addEventListener('click', function(e) {
        e.preventDefault();
        stopSlideShow(); 
        
        autoPlayEnabled = true; nextImage(); autoPlayEnabled = false;
    });
}

document.querySelectorAll('#thumbRow button').forEach(function(btn){ 
    btn.addEventListener('click', function(e){ 
        e.preventDefault();
        stopSlideShow(); 
        const index = this.dataset.index;
        setMainImage(this.dataset.image, index); 
    }); 
});

startSlideShow();
// -----------------------------------------------------

colorButtons.forEach(function(btn){ 
    btn.addEventListener('click', function(){ 
        if (btn.classList.contains('disabled')) return; 
        selectedColor = btn.dataset.color || ''; 
        refreshVariantView(); 
    }); 
});

sizeButtons.forEach(function(btn){ 
    btn.addEventListener('click', function(){ 
        if (btn.classList.contains('disabled')) return; 
        selectedSize = btn.dataset.size || ''; 
        refreshVariantView(); 
    }); 
});

document.getElementById('qtyMinus').addEventListener('click', function(){ qtyInput.value = Math.max(1, parseInt(qtyInput.value || '1', 10) - 1); });
document.getElementById('qtyPlus').addEventListener('click', function(){ qtyInput.value = Math.max(1, parseInt(qtyInput.value || '1', 10) + 1); });

function goBuyNow(e){
  if (!selectedVariantId && requiresVariantChoice) { e.preventDefault(); alert('Vui lòng chọn đúng màu và size trước khi mua ngay.'); return; }
  const qty = Math.max(1, parseInt(qtyInput.value || '1', 10));
  let url = checkoutBaseUrl + '&quantity=' + qty;
  if (selectedVariantId) { url += '&variant_id=' + selectedVariantId; }
  window.location.href = url;
}
buyNowBtn.addEventListener('click', goBuyNow);
mobileBuyNowBtn.addEventListener('click', goBuyNow);
mobileAddToCartBtn.addEventListener('click', function(){ addToCartBtn.click(); });


document.getElementById('productActionForm').addEventListener('submit', function(e) {
    e.preventDefault(); 

    if (!selectedVariantId && requiresVariantChoice) {
        alert('Vui lòng chọn đúng màu và size trước khi thêm vào giỏ hàng.');
        return;
    }

    const form = this;
    const formData = new FormData(form);
    const originalBtnText = addToCartBtn.textContent;
    const addedQty = Math.max(1, parseInt(qtyInput.value || '1', 10));

    addToCartBtn.disabled = true;
    addToCartBtn.textContent = 'ĐANG THÊM...';

    fetch(form.action, {
        method: 'POST',
        body: formData,
        headers: {
            'X-Requested-With': 'XMLHttpRequest'
        }
    })
    .then(async response => {
        const contentType = response.headers.get('content-type') || '';
        if (contentType.includes('application/json')) {
            const data = await response.json();
            if (response.ok && data.ok) {
                triggerFlyToCart();
                showSuccessToast(data.message || 'Đã thêm vào giỏ hàng.');
                if (typeof data.cart_count !== 'undefined') {
                    updateHeaderCartCount(addedQty, data.cart_count);
                } else {
                    updateHeaderCartCount(addedQty);
                }
                return;
            }
            throw new Error(data.message || 'Có lỗi xảy ra khi thêm vào giỏ hàng.');
        }

        if (response.ok || response.redirected) {
            triggerFlyToCart();
            showSuccessToast();
            updateHeaderCartCount(addedQty); 
        } else {
            throw new Error('Có lỗi xảy ra khi thêm vào giỏ hàng, vui lòng thử lại.');
        }
    })
    .catch(error => {
        console.error('Lỗi thêm giỏ hàng:', error);
        alert(error && error.message ? error.message : 'Không thể kết nối với máy chủ.');
    })
    .finally(() => {
        setTimeout(() => {
            addToCartBtn.disabled = false;
            addToCartBtn.textContent = originalBtnText;
        }, 1000);
    });
});

function updateHeaderCartCount(addedQty, exactCount = null) {
    const cartCountEl = document.getElementById('cartItemCount');
    if (cartCountEl) {
        const currentCount = parseInt(cartCountEl.textContent || '0', 10);
        cartCountEl.textContent = Number.isInteger(exactCount) ? exactCount : (currentCount + addedQty);
        cartCountEl.classList.add('bump');
        setTimeout(() => {
            cartCountEl.classList.remove('bump');
        }, 300);
    }
}

function triggerFlyToCart() {
    const img = document.getElementById('mainProductImage');
    if (!img) return;

    let cartIcon = document.getElementById('headerCartLink');
    let targetX = window.innerWidth - 60;
    let targetY = 60;

    if (cartIcon) {
        const cartRect = cartIcon.getBoundingClientRect();
        targetX = cartRect.left + (cartRect.width / 2) - 20; 
        targetY = cartRect.top + (cartRect.height / 2) - 20;
    }

    const imgRect = img.getBoundingClientRect();
    const flyingImg = img.cloneNode();

    flyingImg.classList.add('flying-img');
    flyingImg.style.width = imgRect.width + 'px';
    flyingImg.style.height = imgRect.height + 'px';
    flyingImg.style.left = imgRect.left + 'px';
    flyingImg.style.top = imgRect.top + 'px';
    flyingImg.style.objectFit = 'cover';

    document.body.appendChild(flyingImg);
    flyingImg.offsetWidth; 

    flyingImg.style.left = targetX + 'px';
    flyingImg.style.top = targetY + 'px';
    flyingImg.style.width = '40px';
    flyingImg.style.height = '40px';
    flyingImg.style.opacity = '0.2';
    flyingImg.style.transform = 'scale(0.1)';

    setTimeout(() => {
        flyingImg.remove();
    }, 800);
}

function showSuccessToast(message = null) {
    const toast = document.getElementById('ajaxToast');
    if (message) {
        toast.textContent = message;
    }
    toast.classList.add('show');
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

if (colorButtons.length === 1 && !selectedColor) { selectedColor = colorButtons[0].dataset.color || ''; }
if (sizeButtons.length === 1 && !selectedSize) { selectedSize = sizeButtons[0].dataset.size || ''; }
refreshVariantView();
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>