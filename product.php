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
.product-detail-shell{display:grid;grid-template-columns:minmax(0,1.02fr) minmax(0,.98fr);gap:48px;padding:26px 0 64px}.gallery-box,.detail-box-up{background:#fff;border:1px solid #ececec;border-radius:28px;box-shadow:0 14px 40px rgba(15,23,42,.05)}.gallery-box{padding:22px}.main-image-box{border-radius:22px;background:#f7f7f7;overflow:hidden;display:flex;align-items:center;justify-content:center;min-height:620px}.main-image-box img{width:100%;height:100%;max-height:700px;object-fit:cover}.thumb-row{display:flex;gap:12px;margin-top:14px;overflow:auto;padding-bottom:4px}.thumb-row button{border:1px solid #dedede;background:#fff;padding:0;border-radius:16px;flex:0 0 88px;height:108px;overflow:hidden;cursor:pointer}.thumb-row button.active{border-color:#111;box-shadow:0 0 0 2px rgba(17,17,17,.08)}.thumb-row img{width:100%;height:100%;object-fit:cover}.detail-box-up{padding:30px 32px}.product-code{font-size:14px;color:#7b7b86;margin-top:8px}.price-stack{display:flex;align-items:flex-end;gap:12px;margin:18px 0 10px}.price-sale{font-size:34px;font-weight:800;letter-spacing:-.02em}.price-original{font-size:18px;color:#9ca3af;text-decoration:line-through}.variant-section{margin:28px 0 12px}.variant-row{display:flex;align-items:flex-start;gap:22px;margin-bottom:22px}.variant-label{width:104px;flex:0 0 104px;font-size:16px;font-weight:700;padding-top:10px}.choice-wrap{display:flex;gap:12px;flex-wrap:wrap}.color-chip{width:34px;height:34px;border-radius:999px;border:1px solid #d4d4d8;background:#eee;cursor:pointer;position:relative;transition:.2s}.color-chip.active{box-shadow:0 0 0 3px rgba(17,17,17,.1);border-color:#111;transform:translateY(-1px)}.color-chip.disabled{opacity:.35;cursor:not-allowed}.size-chip{min-width:44px;height:40px;padding:0 14px;border-radius:10px;border:1px solid #d4d4d8;background:#fff;font-weight:700;font-size:20px;line-height:1;cursor:pointer;transition:.2s}.size-chip.active{border-color:#111;background:#111;color:#fff}.size-chip.disabled{opacity:.35;cursor:not-allowed}.qty-row{display:flex;align-items:center;gap:18px;margin:20px 0 14px}.qty-label{width:104px;flex:0 0 104px;font-size:16px;font-weight:700}.qty-control{display:inline-flex;align-items:center;border:1px solid #e5e7eb;border-radius:12px;overflow:hidden}.qty-control button{width:42px;height:42px;border:none;background:#fff;font-size:28px;cursor:pointer;color:#4b5563}.qty-control input{width:56px;height:42px;border:none;text-align:center;font-weight:700;font-size:20px}.variant-hint{min-height:28px;color:#a1a1aa;font-size:14px;padding-left:126px}.action-row{display:flex;gap:16px;align-items:center;flex-wrap:wrap;margin-top:8px}.wish-btn{width:68px;height:68px;border:1px solid #e5e7eb;border-radius:10px;background:#f5f5f5;display:inline-flex;align-items:center;justify-content:center;cursor:pointer}.wish-btn svg{width:28px;height:28px;color:#8b8b95}.primary-outline,.primary-dark{height:68px;border-radius:10px;padding:0 34px;font-size:16px;font-weight:800;letter-spacing:.02em;border:1px solid #111;display:inline-flex;align-items:center;justify-content:center;text-decoration:none;cursor:pointer}.primary-outline{background:#fff;color:#111;min-width:272px}.primary-dark{background:#232323;color:#fff;min-width:186px}.primary-outline[disabled],.primary-dark.disabled{opacity:.55;cursor:not-allowed;pointer-events:none}.sub-links{display:flex;gap:14px;flex-wrap:wrap;margin-top:14px}.sub-links a{font-size:14px;color:#4b5563}.detail-info{margin-top:36px;border-top:1px solid #efefef;padding-top:26px}.detail-info h3{margin:0 0 16px;font-size:18px}.info-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px 18px;margin-bottom:22px}.info-card{background:#fafafa;border:1px solid #f0f0f0;border-radius:16px;padding:14px 16px}.info-card span{display:block;color:#8b8b95;font-size:13px;margin-bottom:6px}.stock-note{color:#10b981;font-size:14px;font-weight:700}.desc-box{font-size:15px;line-height:1.75;color:#444}.alert-float{margin-bottom:16px}.mobile-sticky-actions{display:none}@media(max-width:1024px){.product-detail-shell{grid-template-columns:1fr;gap:22px}.variant-hint{padding-left:0}.variant-row,.qty-row{flex-direction:column;gap:10px;align-items:flex-start}.variant-label,.qty-label{width:auto;flex:initial;padding-top:0}.main-image-box{min-height:420px}}@media(max-width:768px){.detail-box-up{padding:22px 18px}.main-image-box{min-height:340px}.primary-outline,.primary-dark{width:100%;min-width:0}.wish-btn{width:56px;height:56px}.action-row{align-items:stretch}.mobile-sticky-actions{display:flex;position:fixed;left:0;right:0;bottom:0;z-index:999;background:rgba(255,255,255,.96);backdrop-filter:blur(14px);padding:10px 14px;border-top:1px solid #e5e7eb;gap:10px}.mobile-sticky-actions button,.mobile-sticky-actions a{flex:1;height:52px;border-radius:12px;font-size:15px;font-weight:800}.info-grid{grid-template-columns:1fr 1fr}}
</style>

<div class="product-detail-shell">
    <section class="gallery-box">
        <div class="main-image-box"><img id="mainProductImage" src="<?= e($galleryImages[0]) ?>" alt="<?= e($product['product_name']) ?>"></div>
        <?php if (count($galleryImages) > 1): ?>
        <div class="thumb-row" id="thumbRow">
            <?php foreach ($galleryImages as $index => $imageUrl): ?>
                <button type="button" class="<?= $index === 0 ? 'active' : '' ?>" data-image="<?= e($imageUrl) ?>"><img src="<?= e($imageUrl) ?>" alt="thumb <?= $index + 1 ?>"></button>
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
            <input type="hidden" name="cart_action" value="add">
            <input type="hidden" name="product_id" value="<?= (int)$product['id'] ?>">
            <input type="hidden" name="variant_id" id="selectedVariantId" value="<?= $defaultVariant ? (int)$defaultVariant['id'] : '' ?>">

            <?php if ($colorChoices): ?>
            <div class="variant-section">
                <div class="variant-row">
                    <div class="variant-label">Màu sắc:</div>
                    <div class="choice-wrap" id="colorChoiceWrap">
                        <?php foreach ($colorChoices as $color): ?>
                            <button type="button" class="color-chip" data-color="<?= e($color) ?>" title="<?= e($color) ?>" style="background: <?= e(variant_color_style($color)) ?>;"></button>
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
  document.querySelectorAll('#thumbRow button').forEach(function(btn){ btn.classList.toggle('active', btn.dataset.image === imageUrl); });
}
function setMainImage(imageUrl){
  if (!imageUrl) return;
  mainImageEl.src = imageUrl;
  updateThumbActive(imageUrl);
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
    if (variant.image_url) { setMainImage(variant.image_url.startsWith('http') || variant.image_url.startsWith('/') ? variant.image_url : '<?= e(BASE_URL) ?>/' + variant.image_url.replace(/^\/+/, '')); }
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
  setMainImage(defaultImage);
  variantHintEl.textContent = requiresVariantChoice ? 'Vui lòng chọn màu sắc hoặc kích cỡ!' : 'Bạn có thể thêm vào giỏ hoặc mua ngay.';
  updateButtonsState(!requiresVariantChoice && !(variantsPayload.items || []).length ? true : !requiresVariantChoice && (variantsPayload.items || []).length <= 1);
}
colorButtons.forEach(function(btn){ btn.addEventListener('click', function(){ if (btn.classList.contains('disabled')) return; selectedColor = btn.dataset.color || ''; refreshVariantView(); }); });
sizeButtons.forEach(function(btn){ btn.addEventListener('click', function(){ if (btn.classList.contains('disabled')) return; selectedSize = btn.dataset.size || ''; refreshVariantView(); }); });
document.querySelectorAll('#thumbRow button').forEach(function(btn){ btn.addEventListener('click', function(){ setMainImage(btn.dataset.image); }); });
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
document.getElementById('productActionForm').addEventListener('submit', function(e){
  if (!selectedVariantId && requiresVariantChoice) {
    e.preventDefault();
    alert('Vui lòng chọn đúng màu và size trước khi thêm vào giỏ hàng.');
  }
});
if (colorButtons.length === 1 && !selectedColor) { selectedColor = colorButtons[0].dataset.color || ''; }
if (sizeButtons.length === 1 && !selectedSize) { selectedSize = sizeButtons[0].dataset.size || ''; }
refreshVariantView();
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
