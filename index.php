<?php
require_once __DIR__ . '/includes/functions.php';

function render_product_cards(array $products): string
{
    ob_start();
    foreach ($products as $index => $product):
        $productUrl = product_detail_url($product);
        $imageUrl   = e(resolve_media_url($product['thumbnail']));
        $imageAlt   = e($product['product_name']);
        $isPriority = $index < 4;
        
        // Xử lý mô tả ngắn: loại bỏ thẻ HTML nếu có và đặt text mặc định nếu trống
        $shortDesc = !empty($product['short_description']) 
            ? e(strip_tags($product['short_description'])) 
            : 'Sản phẩm thời trang cao cấp, thiết kế hiện đại và tinh tế.';

        // Tính toán phần trăm giảm giá
        $discountPercent = 0;
        if (!empty($product['sale_price']) && !empty($product['original_price']) && $product['original_price'] > $product['sale_price']) {
            $discountPercent = round((($product['original_price'] - $product['sale_price']) / $product['original_price']) * 100);
        }
        ?>
        <article class="product-card-pro">
            <a class="product-image-wrap" href="<?= $productUrl ?>">
                <img
                    src="<?= $imageUrl ?>"
                    alt="<?= $imageAlt ?>"
                    loading="<?= $isPriority ? 'eager' : 'lazy' ?>"
                    fetchpriority="<?= $isPriority ? 'high' : 'auto' ?>"
                    decoding="async"
                    width="600"
                    height="750"
                >
                <div class="image-overlay"></div>
                <span class="product-badge"><?= e($product['category_name'] ?: 'Chưa phân loại') ?></span>
                
                <?php if ($discountPercent > 0): ?>
                    <span class="discount-badge">-<?= $discountPercent ?>%</span>
                <?php endif; ?>
            </a>

            <div class="product-card-content">
                <div class="product-top">
                    <div class="product-meta">
                        <span class="meta-item"><?= e($product['product_type_name'] ?: 'Cập nhật') ?></span>
                        <span class="meta-dot">•</span>
                        <span class="meta-item"><?= e($product['gender'] ?: 'Unisex') ?></span>
                    </div>

                    <h3 class="product-title">
                        <a href="<?= $productUrl ?>">
                            <?= e($product['product_name']) ?>
                        </a>
                    </h3>
                    
                    <p class="product-short-desc" title="<?= $shortDesc ?>">
                        <?= $shortDesc ?>
                    </p>

                    <div class="product-code">Mã: <?= e($product['product_code']) ?></div>
                </div>

                <div class="product-bottom">
                    <div class="price-stack">
                        <?php if (!empty($product['sale_price'])): ?>
                            <div class="price"><?= format_price($product['sale_price']) ?></div>
                            <div class="price-old"><?= format_price($product['original_price']) ?></div>
                        <?php else: ?>
                            <div class="price"><?= format_price($product['original_price']) ?></div>
                        <?php endif; ?>
                    </div>

                    <div class="card-actions">
                        <a class="btn btn-light" href="<?= $productUrl ?>">Chi tiết</a>
                        <a class="btn btn-buy-now" href="<?= $productUrl ?>">Mua ngay</a>
                    </div>
                </div>
            </div>
        </article>
    <?php endforeach;

    if (empty($products)): ?>
        <div class="empty-state">
            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="color: #ccc; margin-bottom: 20px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            <h3>Chưa có sản phẩm nào</h3>
            <p>Hiện chưa có sản phẩm phù hợp với bộ lọc bạn chọn. Vui lòng thử lại.</p>
        </div>
    <?php endif;

    return ob_get_clean();
}

function render_pagination_html($page, $totalPages) {
    if ($totalPages <= 1) return '';
    ob_start();
    ?>
    <div class="pagination-lux">
        <?php if ($page > 1): ?>
            <button type="button" class="page-btn text-btn" data-page="<?= $page - 1 ?>" aria-label="Trang trước">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
            </button>
        <?php endif; ?>
        
        <?php 
        $start = max(1, $page - 2);
        $end = min($totalPages, $page + 2);
        
        if ($start > 1) { 
            echo '<button type="button" class="page-btn" data-page="1">1</button>';
            if ($start > 2) echo '<span class="page-dots">...</span>'; 
        }
        
        for ($i = $start; $i <= $end; $i++): ?>
            <button type="button" class="page-btn <?= $i === $page ? 'active' : '' ?>" data-page="<?= $i ?>"><?= $i ?></button>
        <?php endfor; 
        
        if ($end < $totalPages) { 
            if ($end < $totalPages - 1) echo '<span class="page-dots">...</span>';
            echo '<button type="button" class="page-btn" data-page="' . $totalPages . '">' . $totalPages . '</button>';
        }
        ?>
        
        <?php if ($page < $totalPages): ?>
            <button type="button" class="page-btn text-btn" data-page="<?= $page + 1 ?>" aria-label="Trang sau">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
            </button>
        <?php endif; ?>
    </div>
    <?php
    return ob_get_clean();
}

$priceRange = trim($_GET['price_range'] ?? '');
$priceMin = null;
$priceMax = null;

switch ($priceRange) {
    case 'under_200':
        $priceMin = null;
        $priceMax = 200000;
        break;
    case '200_500':
        $priceMin = 200000;
        $priceMax = 500000;
        break;
    case '500_1000':
        $priceMin = 500000;
        $priceMax = 1000000;
        break;
    case 'over_1000':
        $priceMin = 1000000;
        $priceMax = null;
        break;
}

$filters = [
    'category_id' => (isset($_GET['category']) && $_GET['category'] !== '') ? (int)$_GET['category'] : null,
    'type_id'     => (isset($_GET['type']) && $_GET['type'] !== '') ? (int)$_GET['type'] : null,
    'gender'      => (isset($_GET['gender']) && $_GET['gender'] !== '') ? trim($_GET['gender']) : null,
    'price_min'   => $priceMin,
    'price_max'   => $priceMax,
    'q'           => trim($_GET['q'] ?? ''),
];

// Lấy toàn bộ sản phẩm theo filter
$allProducts = get_products($filters);

// XỬ LÝ PHÂN TRANG (10 SP / Trang)
$limit = 10;
$totalProducts = count($allProducts);
$totalPages = ceil($totalProducts / $limit);
$page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
if ($page > $totalPages && $totalPages > 0) {
    $page = $totalPages;
}
// Cắt mảng sản phẩm cho trang hiện tại
$paginatedProducts = array_slice($allProducts, ($page - 1) * $limit, $limit);

$categories = get_categories();
$productTypes = get_product_types();

$visibleProductTypes = array_filter($productTypes, function ($type) use ($filters) {
    if (empty($filters['category_id'])) {
        return true;
    }
    return (int)$type['category_id'] === (int)$filters['category_id'];
});

$productTypesForJs = array_map(function ($type) {
    return [
        'id' => (int)$type['id'],
        'name' => $type['name'],
        'category_id' => (int)$type['category_id'],
    ];
}, $productTypes);

if (isset($_GET['ajax']) && $_GET['ajax'] == '1') {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'count' => $totalProducts,
        'html'  => render_product_cards($paginatedProducts),
        'pagination' => render_pagination_html($page, $totalPages)
    ]);
    exit;
}

$brandLogoUrl    = resolve_media_url('img/logo.jpg');
$heroBannerUrl   = resolve_media_url('img/logoduongmotmi.jpg');
$tiktokIconUrl   = resolve_media_url('img/tt.png');
$facebookIconUrl = resolve_media_url('img/fb.png');
$instagramIconUrl = resolve_media_url('img/ig.png');
$zaloIconUrl     = resolve_media_url('img/zl.png');
$pageTitle = 'Trang chủ';
require_once __DIR__ . '/includes/header.php';

// CỜ HIỂN THỊ POPUP: Chỉ hiện khi người dùng KHÔNG sử dụng bất kỳ filter nào (Trang chủ thuần)
$isFiltering = (!empty($filters['category_id']) || !empty($filters['type_id']) || !empty($filters['gender']) || !empty($filters['price_max']) || !empty($filters['price_min']) || !empty($filters['q']));
$showPopup = !$isFiltering;
?>

<style>
/* =========================================================
   CSS RIÊNG CHO TRANG INDEX TỐI ƯU GỌN NHẸ (LUXURY UPDATE)
   ========================================================= */
:root {
    --primary-color: #111;
    --primary-hover: #333;
    --danger-color: #e5003f; /* Đỏ nổi bật hơn cho giá giảm */
    --text-main: #1a1a24;
    --text-muted: #666; /* Đậm hơn một chút để dễ đọc mô tả */
    --radius-pill: 50px;
    --radius-md: 16px;
    --z-index-modal: 9999;
    --card-shadow: 0 10px 30px rgba(0,0,0,0.03);
    --card-hover-shadow: 0 20px 40px rgba(0,0,0,0.08);
}

.intro-open-btn {
    position: fixed;
    bottom: 30px;
    right: 30px;
    background: var(--primary-color);
    color: #ffffff;
    border: none;
    padding: 14px 24px;
    border-radius: var(--radius-pill);
    font-weight: 700;
    font-size: 15px;
    cursor: pointer;
    box-shadow: 0 10px 25px rgba(0,0,0,0.25);
    z-index: 100;
    transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    animation: pulseFloat 2s infinite;
}

.intro-open-btn:hover {
    transform: scale(1.05) translateY(-5px);
    background: var(--primary-hover);
    animation: none;
}

@keyframes pulseFloat {
    0% { transform: translateY(0); box-shadow: 0 5px 15px rgba(0,0,0,0.2); }
    50% { transform: translateY(-5px); box-shadow: 0 15px 25px rgba(0,0,0,0.3); }
    100% { transform: translateY(0); box-shadow: 0 5px 15px rgba(0,0,0,0.2); }
}

body.popup-open {
    overflow: hidden;
}

.store-intro-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    display: flex;
    align-items: center;    
    justify-content: center; 
    z-index: var(--z-index-modal);
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.4s ease, visibility 0.4s ease;
}

.store-intro-overlay.show {
    opacity: 1;
    visibility: visible;
}

.store-intro-modal {
    position: relative;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    width: 950px;
    max-width: 92%;
    max-height: 85vh; 
    border-radius: 30px;
    overflow-y: auto; 
    transform: scale(0.9) translateY(30px);
    transition: transform 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    box-shadow: 0 30px 60px rgba(0,0,0,0.2);
    border: 1px solid rgba(255,255,255,0.8);
}

.store-intro-overlay.show .store-intro-modal {
    transform: scale(1) translateY(0);
}

.popup-close-btn {
    position: absolute;
    top: 20px;
    right: 20px;
    width: 40px;
    height: 40px;
    background: rgba(0, 0, 0, 0.05);
    backdrop-filter: blur(4px);
    border: 1px solid rgba(255,255,255,0.5);
    border-radius: 50%;
    font-size: 24px;
    font-weight: 300;
    line-height: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    z-index: 10;
    transition: all 0.3s;
    color: var(--text-main);
}

.popup-close-btn:hover {
    background: var(--primary-color);
    color: #fff;
    transform: rotate(90deg);
}

.hero-brand-layout-home {
    display: grid;
    grid-template-columns: 1fr 1fr;
    background: transparent;
}

.hero-brand-content {
    padding: 50px;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.hero-brand-content h1 {
    font-size: 38px;
    line-height: 1.1;
    margin-bottom: 20px;
    font-weight: 900;
    letter-spacing: -1px;
    background: linear-gradient(45deg, #111, #555);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

.hero-brand-content p {
    font-size: 17px;
    color: var(--text-muted);
    margin-bottom: 30px;
    line-height: 1.6;
}

.hero-socials-home {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.social-card {
    display: flex;
    align-items: center;
    gap: 15px;
    background: #ffffff;
    padding: 15px;
    border-radius: var(--radius-md);
    border: 1px solid rgba(0,0,0,0.05);
    transition: all 0.3s;
    box-shadow: 0 4px 10px rgba(0,0,0,0.02);
    text-decoration: none;
}

.social-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.08);
    border-color: rgba(0,0,0,0.1);
}

.social-icon img {
    border-radius: 8px;
}

.social-text {
    display: flex;
    flex-direction: column;
}

.social-text strong {
    font-size: 15px;
    font-weight: 700;
    color: var(--text-main);
}

.social-text span {
    font-size: 12px;
    font-weight: 500;
    color: var(--text-muted);
}

.hero-brand-banner {
    height: 100%;
    position: relative;
    overflow: hidden;
}

.hero-brand-banner img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 0 30px 30px 0;
}

/* =========================================================
   LUXURY CATEGORY PILLS (FIX AUTO WRAP)
   ========================================================= */
.category-pills {
    display: flex;
    flex-wrap: wrap; /* Cho phép các nút rớt xuống dòng thay vì kéo ngang */
    justify-content: center;
    gap: 12px;
    margin-bottom: 25px;
}

.category-pills .pill {
    padding: 12px 24px;
    border-radius: 30px;
    background: #fff;
    color: #444;
    border: 1px solid #eaeaea;
    font-size: 14px;
    font-weight: 700;
    text-decoration: none;
    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
    box-shadow: 0 2px 8px rgba(0,0,0,0.02);
    display: inline-flex;
    align-items: center;
    justify-content: center;
}

.category-pills .pill:hover, 
.category-pills .pill.active {
    background: var(--primary-color);
    color: #fff;
    border-color: var(--primary-color);
    box-shadow: 0 6px 18px rgba(0,0,0,0.15);
    transform: translateY(-2px);
}

/* Ẩn Filter button Desktop */
.mobile-filter-toggle {
    display: none;
    width: 100%;
    margin-bottom: 15px;
    align-items: center;
    justify-content: center;
    gap: 8px;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(0,0,0,0.05);
    color: var(--text-main);
    box-shadow: 0 4px 15px rgba(0,0,0,0.05);
    font-weight: 700;
    border-radius: var(--radius-md);
    padding: 14px;
}

.mobile-filter-toggle svg {
    transition: transform 0.3s ease;
}

.mobile-filter-toggle.is-open .chevron {
    transform: rotate(180deg);
}

@keyframes slideDown {
    from { opacity: 0; transform: translateY(-15px); }
    to { opacity: 1; transform: translateY(0); }
}

/* =========================================================
   UI/UX SẢN PHẨM (GRID, CARD, HOVER EFFECTS) - BẢN LUXURY
   ========================================================= */
.product-grid-pro {
    display: grid;
    grid-template-columns: repeat(4, 1fr); /* Desktop: 4 items per row */
    gap: 30px;
    padding: 20px 0;
    transition: opacity 0.3s ease;
}

.product-grid-pro.is-loading {
    opacity: 0.5;
    pointer-events: none;
}

.product-card-pro {
    background: #ffffff;
    border-radius: 24px;
    overflow: hidden;
    transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    box-shadow: var(--card-shadow);
    border: 1px solid rgba(0,0,0,0.03);
    display: flex;
    flex-direction: column;
    height: 100%;
    position: relative;
}

.product-card-pro:hover {
    transform: translateY(-10px);
    box-shadow: var(--card-hover-shadow);
    border-color: rgba(0,0,0,0.08);
}

.product-image-wrap {
    position: relative;
    overflow: hidden;
    aspect-ratio: 4/5;
    display: block;
    background: #f8f9fa; 
}

.product-image-wrap img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.7s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

.image-overlay {
    position: absolute;
    top: 0; left: 0; right: 0; bottom: 0;
    background: linear-gradient(to bottom, rgba(0,0,0,0.05) 0%, rgba(0,0,0,0) 30%, rgba(0,0,0,0.1) 100%);
    opacity: 0;
    transition: opacity 0.4s ease;
    z-index: 1;
}

.product-card-pro:hover .product-image-wrap img {
    transform: scale(1.08);
}
.product-card-pro:hover .image-overlay {
    opacity: 1;
}

.product-badge {
    position: absolute;
    top: 16px;
    left: 16px;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    padding: 6px 14px;
    border-radius: 30px;
    font-size: 11px;
    font-weight: 800;
    color: var(--text-main);
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    z-index: 2;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.discount-badge {
    position: absolute;
    top: 16px;
    right: 16px;
    background: var(--danger-color);
    color: #ffffff;
    padding: 6px 12px;
    border-radius: 12px;
    font-size: 13px;
    font-weight: 900;
    box-shadow: 0 4px 12px rgba(229, 0, 63, 0.4);
    z-index: 2;
    letter-spacing: 0.5px;
    transform: translateY(0);
    transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.product-card-pro:hover .discount-badge {
    transform: scale(1.1) rotate(3deg);
}

.product-card-content {
    padding: 24px;
    display: flex;
    flex-direction: column;
    flex-grow: 1;
    justify-content: space-between;
}

.product-top {
    margin-bottom: 20px;
}

.product-meta {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: #888;
    margin-bottom: 10px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.meta-dot {
    font-size: 14px;
    color: #ddd;
}

.product-title {
    font-size: 18px;
    font-weight: 800;
    line-height: 1.4;
    margin: 0 0 8px 0;
}

.product-title a {
    color: var(--text-main);
    text-decoration: none;
    transition: color 0.3s ease;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.product-title a:hover {
    color: var(--danger-color);
}

.product-short-desc {
    font-size: 13.5px;
    color: var(--text-muted);
    line-height: 1.6;
    margin-bottom: 12px;
    display: -webkit-box;
    -webkit-line-clamp: 2; 
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
}

.product-code {
    font-size: 11px;
    color: #777;
    background: #f1f1f4;
    display: inline-block;
    padding: 4px 10px;
    border-radius: 6px;
    font-weight: 600;
    letter-spacing: 0.5px;
}

.product-bottom {
    border-top: 1px dashed rgba(0,0,0,0.08);
    padding-top: 20px;
}

.price-stack {
    display: flex;
    align-items: center; 
    gap: 10px;
    margin-bottom: 18px;
    flex-wrap: wrap;
}

.price {
    font-size: 24px; 
    font-weight: 900;
    color: var(--danger-color); 
    letter-spacing: -0.5px;
}

.price-old {
    font-size: 15px;
    text-decoration: line-through;
    color: #a0a0a0;
    font-weight: 500;
}

.card-actions {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}

.card-actions .btn {
    text-align: center;
    padding: 12px;
    border-radius: 12px;
    font-size: 14px;
    font-weight: 700;
    text-decoration: none;
    transition: all 0.3s ease;
}

.btn-light {
    background: #f5f5f5;
    color: var(--text-main);
}

.btn-light:hover {
    background: #e0e0e0;
    transform: translateY(-2px);
}

.btn-buy-now {
    background: var(--primary-color);
    color: #ffffff;
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}

.btn-buy-now:hover {
    background: var(--danger-color);
    color: #ffffff;
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(229, 0, 63, 0.3);
}

/* =========================================================
   LUXURY PAGINATION CSS
   ========================================================= */
.pagination-lux {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    margin-top: 40px;
    padding-bottom: 20px;
}

.pagination-lux .page-btn {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    border: 1px solid #eaeaea;
    background: #fff;
    color: #333;
    font-weight: 700;
    font-size: 15px;
    cursor: pointer;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 5px rgba(0,0,0,0.02);
}

.pagination-lux .page-btn:hover {
    background: #f8f9fa;
    border-color: #ddd;
    transform: translateY(-2px);
}

.pagination-lux .page-btn.active {
    background: var(--primary-color);
    color: #fff;
    border-color: var(--primary-color);
    box-shadow: 0 6px 15px rgba(0,0,0,0.15);
}

.pagination-lux .page-dots {
    color: #999;
    font-weight: 700;
    padding: 0 4px;
}

/* =========================================================
   RESPONSIVE: MOBILE TỐI ƯU 2 SẢN PHẨM / HÀNG
   ========================================================= */
@media screen and (max-width: 768px) {
    /* Popup Mobile */
    .store-intro-modal {
        width: 92% !important;
        max-height: 85vh !important;
        padding: 0; 
        border-radius: 24px;
    }

    .hero-brand-layout-home {
        display: flex !important;
        flex-direction: column-reverse; 
        background: transparent;
    }

    .hero-brand-content {
        padding: 25px 20px !important;
    }

    .hero-brand-content h1 {
        font-size: 26px !important;
    }

    .hero-brand-content p {
        font-size: 14px;
        margin-bottom: 20px;
    }

    .hero-socials-home {
        grid-template-columns: 1fr; 
        gap: 12px;
    }

    .social-card {
        padding: 12px;
        border-radius: 12px;
    }

    .hero-brand-banner img {
        height: 200px; 
        border-radius: 24px 24px 0 0;
    }
    
    .popup-close-btn {
        background: rgba(255, 255, 255, 0.9);
        color: var(--primary-color);
        box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        top: 10px;
        right: 10px;
        width: 32px;
        height: 32px;
        font-size: 20px;
        border: none;
    }

    /* Đảm bảo nút danh mục gọn gàng trên mobile */
    .category-pills {
        gap: 8px;
        margin-bottom: 15px;
    }
    
    .category-pills .pill {
        padding: 10px 18px;
        font-size: 13px;
    }

    /* Logic bật tắt Filter Mobile */
    .mobile-filter-toggle {
        display: flex;
        border-radius: 14px;
        font-size: 14px;
    }

    .filter-panel {
        display: none; 
        margin-bottom: 20px;
        padding: 20px;
        border-radius: 20px;
        background: #fff;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
    }

    .filter-panel.show-on-mobile {
        display: block;
        animation: slideDown 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
    }

    .filter-grid {
        grid-template-columns: 1fr; 
        gap: 15px;
    }
    
    .filter-field label {
        margin-bottom: 6px;
        font-size: 12px;
        font-weight: 700;
    }
    
    .filter-actions {
        flex-direction: column;
        gap: 10px;
        margin-top: 15px;
    }
    
    .filter-actions .btn {
        width: 100%;
        border-radius: 12px;
    }

    /* TỐI ƯU 2 SẢN PHẨM 1 HÀNG TRÊN MOBILE */
    .product-grid-pro {
        grid-template-columns: repeat(2, 1fr) !important;
        gap: 12px;
        padding: 10px 0;
    }

    .product-card-pro {
        border-radius: 16px;
    }

    .product-card-pro:hover {
        transform: translateY(-4px); 
    }

    .product-card-content {
        padding: 14px; 
    }

    .product-badge {
        font-size: 9px; 
        padding: 4px 8px;
        top: 10px;
        left: 10px;
        border-radius: 12px;
    }

    .discount-badge {
        font-size: 10px;
        padding: 4px 8px;
        top: 10px;
        right: 10px;
        border-radius: 8px;
    }

    .product-top {
        margin-bottom: 12px;
    }

    .product-meta {
        font-size: 9px;
        margin-bottom: 6px;
    }

    .product-title {
        font-size: 14px; 
        line-height: 1.3;
        margin-bottom: 6px;
    }
    
    .product-short-desc {
        font-size: 11px;
        margin-bottom: 8px;
        line-height: 1.4;
    }

    .product-code {
        font-size: 10px;
        padding: 2px 6px;
        border-radius: 4px;
    }

    .product-bottom {
        padding-top: 12px;
    }

    .price-stack {
        flex-direction: row;
        flex-wrap: wrap;
        align-items: center;
        gap: 6px;
        margin-bottom: 12px;
    }

    .price {
        font-size: 18px; /* Trên mobile giá bé lại chút cho cân đối */
    }

    .price-old {
        font-size: 12px;
    }

    .card-actions {
        display: flex;
        flex-direction: column; 
        gap: 8px;
    }

    .card-actions .btn {
        font-size: 12px;
        padding: 10px 4px;
        border-radius: 10px;
        white-space: nowrap;
        width: 100%;
    }
}
</style>


<?php
$tiktokLink = function_exists('shop_social_link') ? shop_social_link('tiktok') : '#';
$facebookLink = function_exists('shop_social_link') ? shop_social_link('facebook') : '#';
$instagramLink = function_exists('shop_social_link') ? shop_social_link('instagram') : '#';
$zaloGroupLink = function_exists('shop_social_link') ? shop_social_link('zalo_group') : '#';
$shopNameDynamic = function_exists('shop_name') ? shop_name() : 'Duong Mot Mi SHOP';
?>

<?php if ($showPopup): ?>
<div class="store-intro-overlay" id="storeIntroPopup" aria-hidden="true">
    <div class="store-intro-modal" role="dialog" aria-modal="true" aria-labelledby="storeIntroTitle">
        <button class="popup-close-btn" type="button" data-close-popup>&times;</button>

        <section class="hero-pro hero-pro-upgraded">
            <div class="hero-brand-layout hero-brand-layout-home">
                <div class="hero-brand-content">
                    <div class="hero-socials hero-socials-home">
                        <a class="social-card tiktok" href="<?= e($tiktokLink ?: "#") ?>" target="_blank" rel="noopener noreferrer">
                            <div class="social-icon icon-image">
                                <img src="<?= e($tiktokIconUrl) ?>" alt="TikTok" width="24" height="24" loading="lazy" decoding="async">
                            </div>
                            <div class="social-text">
                                <strong>TikTok</strong>
                                <span>@duongmotmi2004</span>
                            </div>
                        </a>

                        <a class="social-card facebook" href="<?= e($facebookLink ?: "#") ?>" target="_blank" rel="noopener noreferrer">
                            <div class="social-icon icon-image">
                                <img src="<?= e($facebookIconUrl) ?>" alt="Facebook" width="24" height="24" loading="lazy" decoding="async">
                            </div>
                            <div class="social-text">
                                <strong>Facebook</strong>
                                <span>Liên hệ mua hàng</span>
                            </div>
                        </a>

                        <a class="social-card instagram" href="<?= e($instagramLink ?: "#") ?>" target="_blank" rel="noopener noreferrer">
                            <div class="social-icon icon-image">
                                <img src="<?= e($instagramIconUrl) ?>" alt="Instagram" width="24" height="24" loading="lazy" decoding="async">
                            </div>
                            <div class="social-text">
                                <strong>Instagram</strong>
                                <span>@giuong_tung</span>
                            </div>
                        </a>

                        <a class="social-card zalo" href="<?= e(shop_zalo_link()) ?>" target="_blank" rel="noopener noreferrer">
                            <div class="social-icon icon-image">
                                <img src="<?= e($zaloIconUrl) ?>" alt="Zalo" width="24" height="24" loading="lazy" decoding="async">
                            </div>
                            <div class="social-text">
                                <strong>Zalo</strong>
                                <span>Liên hệ mua hàng</span>
                            </div>
                        </a>

                        <a class="social-card zalo-group" href="<?= e($zaloGroupLink ?: "#") ?>" target="_blank" rel="noopener noreferrer">
                            <div class="social-icon icon-image">
                                <img src="<?= e($zaloIconUrl) ?>" alt="Zalo Group" width="24" height="24" loading="lazy" decoding="async">
                            </div>
                            <div class="social-text">
                                <strong>Nhóm Zalo</strong>
                                <span>Tham gia săn sale</span>
                            </div>
                        </a>
                    </div>
                </div>

                <div class="hero-brand-banner">
                    <img
                        src="<?= e($heroBannerUrl) ?>"
                        alt="<?= e($shopNameDynamic) ?>"
                        width="900"
                        height="900"
                        loading="eager"
                        decoding="async"
                    >
                </div>
            </div>
        </section>
    </div>
</div>
<?php endif; ?>

<button class="intro-open-btn" type="button" id="introOpenBtn">Giới thiệu shop</button>

<section class="shop-filter-wrap">
    <div class="category-pills">
        <a class="pill category-filter <?= !$filters['category_id'] ? 'active' : '' ?>"
           href="<?= route_url('/index.php') ?>"
           data-category="">
            Tất cả
        </a>

        <?php foreach ($categories as $cat): ?>
            <a class="pill category-filter <?= $filters['category_id'] === (int)$cat['id'] ? 'active' : '' ?>"
               href="<?= route_url('/index.php') ?>?category=<?= (int)$cat['id'] ?>"
               data-category="<?= (int)$cat['id'] ?>">
                <?= e($cat['name']) ?>
            </a>
        <?php endforeach; ?>
    </div>

    <button type="button" class="btn btn-outline mobile-filter-toggle" id="mobileFilterToggle">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon>
        </svg>
        Tùy chỉnh bộ lọc
        <svg class="chevron" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="6 9 12 15 18 9"></polyline>
        </svg>
    </button>

    <form id="filterForm" class="filter-panel" method="get" action="<?= route_url('/index.php') ?>">
        <input type="hidden" name="category" id="categoryInput" value="<?= $filters['category_id'] ?? '' ?>">
        <input type="hidden" name="page" id="pageInput" value="<?= $page ?>">

        <div class="filter-grid">
            <div class="filter-field filter-field-search">
                <label for="q">Tìm kiếm</label>
                <input
                    id="q"
                    type="text"
                    name="q"
                    value="<?= e($filters['q']) ?>"
                    placeholder="Tên sản phẩm, mã SP, loại..."
                >
            </div>

            <div class="filter-field">
                <label for="type">Loại</label>
                <select name="type" id="type">
                    <option value="">Tất cả loại</option>
                    <?php foreach ($visibleProductTypes as $type): ?>
                        <option value="<?= (int)$type['id'] ?>" <?= $filters['type_id'] === (int)$type['id'] ? 'selected' : '' ?>>
                            <?= e($type['name']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>

            <div class="filter-field">
                <label for="gender">Giới tính</label>
                <select name="gender" id="gender">
                    <option value="">Tất cả</option>
                    <option value="Nam" <?= $filters['gender'] === 'Nam' ? 'selected' : '' ?>>Nam</option>
                    <option value="Nữ" <?= $filters['gender'] === 'Nữ' ? 'selected' : '' ?>>Nữ</option>
                    <option value="Unisex" <?= $filters['gender'] === 'Unisex' ? 'selected' : '' ?>>Unisex</option>
                </select>
            </div>

            <div class="filter-field">
                <label for="price_range">Khoảng giá</label>
                <select name="price_range" id="price_range">
                    <option value="">Tất cả mức giá</option>
                    <option value="under_200" <?= $priceRange === 'under_200' ? 'selected' : '' ?>>Dưới 200K</option>
                    <option value="200_500" <?= $priceRange === '200_500' ? 'selected' : '' ?>>200K - 500K</option>
                    <option value="500_1000" <?= $priceRange === '500_1000' ? 'selected' : '' ?>>500K - 1 Triệu</option>
                    <option value="over_1000" <?= $priceRange === 'over_1000' ? 'selected' : '' ?>>Hơn 1 Triệu</option>
                </select>
            </div>
        </div>

        <div class="filter-actions">
            <button class="btn" type="submit">Lọc sản phẩm</button>
            <button class="btn btn-light" type="button" id="resetFilter">Xóa bộ lọc</button>
        </div>
    </form>
</section>

<section class="section-head" id="product-list">
    <div class="section-note" id="productCount"><?= count($allProducts) ?> sản phẩm</div>
</section>

<div class="product-grid-pro" id="productGrid">
    <?= render_product_cards($paginatedProducts) ?>
</div>

<div id="paginationWrapper">
    <?= render_pagination_html($page, $totalPages) ?>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const filterForm = document.getElementById('filterForm');
    const productGrid = document.getElementById('productGrid');
    const productCount = document.getElementById('productCount');
    const paginationWrapper = document.getElementById('paginationWrapper');
    const categoryInput = document.getElementById('categoryInput');
    const pageInput = document.getElementById('pageInput');
    const categoryFilters = document.querySelectorAll('.category-filter');
    const resetFilterBtn = document.getElementById('resetFilter');
    const searchInput = document.getElementById('q');
    const typeSelect = document.getElementById('type');
    const genderSelect = document.getElementById('gender');
    const priceRangeSelect = document.getElementById('price_range');
    const mobileFilterToggle = document.getElementById('mobileFilterToggle');
    const baseUrl = <?= json_encode(route_url('/index.php')) ?>;
    const allProductTypes = <?= json_encode($productTypesForJs, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?>;

    let typingTimer = null;
    let activeController = null;
    let requestId = 0;
    let lastQuery = '';

    if (mobileFilterToggle) {
        mobileFilterToggle.addEventListener('click', function() {
            filterForm.classList.toggle('show-on-mobile');
            this.classList.toggle('is-open');
        });
    }

    function updateActiveCategory(categoryId) {
        categoryFilters.forEach(link => {
            const value = link.dataset.category || '';
            link.classList.toggle('active', value === (categoryId || ''));
        });
    }

    function renderTypeOptions(categoryId, selectedType = '') {
        const normalizedCategory = categoryId ? String(categoryId) : '';
        const normalizedSelectedType = selectedType ? String(selectedType) : '';

        const filteredTypes = !normalizedCategory
            ? allProductTypes
            : allProductTypes.filter(type => String(type.category_id) === normalizedCategory);

        typeSelect.innerHTML = '<option value="">Tất cả loại</option>';
        let hasSelectedType = false;

        filteredTypes.forEach(type => {
            const option = document.createElement('option');
            option.value = String(type.id);
            option.textContent = type.name;

            if (String(type.id) === normalizedSelectedType) {
                option.selected = true;
                hasSelectedType = true;
            }
            typeSelect.appendChild(option);
        });

        if (normalizedSelectedType && !hasSelectedType) {
            typeSelect.value = '';
        }
    }

    function buildQueryFromForm() {
        const formData = new FormData(filterForm);
        const params = new URLSearchParams();

        for (const [key, value] of formData.entries()) {
            const normalizedValue = String(value).trim();
            if (normalizedValue !== '') {
                params.set(key, normalizedValue);
            }
        }
        return params;
    }

    function setLoadingState(isLoading) {
        productGrid.classList.toggle('is-loading', isLoading);
        productGrid.setAttribute('aria-busy', isLoading ? 'true' : 'false');
    }

    async function loadProducts(force = false) {
        const params = buildQueryFromForm();
        const queryString = params.toString();

        if (!force && queryString === lastQuery) {
            return;
        }

        const ajaxParams = new URLSearchParams(queryString);
        ajaxParams.set('ajax', '1');

        const browserUrl = queryString ? `${baseUrl}?${queryString}` : baseUrl;

        if (activeController) {
            activeController.abort();
        }

        activeController = new AbortController();
        const currentRequestId = ++requestId;

        setLoadingState(true);

        try {
            const response = await fetch(`${baseUrl}?${ajaxParams.toString()}`, {
                signal: activeController.signal,
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'Accept': 'application/json'
                }
            });

            if (!response.ok) throw new Error('Lỗi fetch');

            const data = await response.json();

            if (currentRequestId !== requestId) return;

            productGrid.classList.add('is-swapping');

            requestAnimationFrame(() => {
                productGrid.innerHTML = data.html;
                productCount.textContent = `${data.count} sản phẩm`;
                if (paginationWrapper && data.pagination !== undefined) {
                    paginationWrapper.innerHTML = data.pagination;
                }
                
                history.replaceState(null, '', browserUrl);
                updateActiveCategory(categoryInput.value);
                lastQuery = queryString;

                requestAnimationFrame(() => {
                    productGrid.classList.remove('is-swapping');
                });
            });
        } catch (error) {
            if (error.name === 'AbortError') return;
            console.error(error);
        } finally {
            if (currentRequestId === requestId) {
                setLoadingState(false);
            }
        }
    }

    // XỬ LÝ CLICK PHÂN TRANG
    document.addEventListener('click', function(e) {
        const pageBtn = e.target.closest('.page-btn');
        if (pageBtn) {
            e.preventDefault();
            const newPage = pageBtn.dataset.page;
            if (newPage) {
                pageInput.value = newPage;
                loadProducts(true);
                document.getElementById('product-list').scrollIntoView({ behavior: 'smooth' });
            }
        }
    });

    categoryFilters.forEach(link => {
        link.addEventListener('click', function (e) {
            e.preventDefault();
            
            const newCategoryId = this.dataset.category || '';
            categoryInput.value = newCategoryId;
            
            if (searchInput) searchInput.value = '';
            if (genderSelect) genderSelect.value = '';
            if (priceRangeSelect) priceRangeSelect.value = '';
            pageInput.value = 1; // Reset về trang 1
            
            renderTypeOptions(newCategoryId, '');
            updateActiveCategory(newCategoryId);
            
            loadProducts(true);
            
            if (window.innerWidth <= 768) {
                document.getElementById('product-list').scrollIntoView({ behavior: 'smooth' });
            }
        });
    });

    filterForm.addEventListener('submit', function (e) {
        e.preventDefault();
        pageInput.value = 1; // Reset trang 1 khi search
        loadProducts(true);
        if (window.innerWidth <= 768) {
             filterForm.classList.remove('show-on-mobile');
             mobileFilterToggle.classList.remove('is-open');
        }
    });

    filterForm.querySelectorAll('select').forEach(field => {
        field.addEventListener('change', function () {
            pageInput.value = 1; // Reset trang 1
            loadProducts(true);
        });
    });

    if (searchInput) {
        searchInput.addEventListener('input', function () {
            clearTimeout(typingTimer);
            typingTimer = setTimeout(() => {
                pageInput.value = 1; // Reset trang 1
                loadProducts(true);
            }, 300);
        });
    }

    resetFilterBtn.addEventListener('click', function () {
        categoryInput.value = '';
        pageInput.value = 1;
        if (searchInput) searchInput.value = '';
        if (typeSelect) typeSelect.value = '';
        if (genderSelect) genderSelect.value = '';
        if (priceRangeSelect) priceRangeSelect.value = '';

        updateActiveCategory('');
        renderTypeOptions('', '');
        loadProducts(true);
    });

    renderTypeOptions(categoryInput.value, '<?= (int)($filters['type_id'] ?? 0) ?>');
    updateActiveCategory(categoryInput.value);
    lastQuery = buildQueryFromForm().toString();

    // POPUP LOGIC
    const popup = document.getElementById('storeIntroPopup');
    const openPopupBtn = document.getElementById('introOpenBtn');
    const closePopupBtns = document.querySelectorAll('[data-close-popup]');

    function openPopup() {
        if (!popup) return;
        popup.classList.add('show');
        document.body.classList.add('popup-open');
    }

    function closePopup() {
        if (!popup) return;
        popup.classList.remove('show');
        document.body.classList.remove('popup-open');
    }

    if (openPopupBtn) {
        openPopupBtn.addEventListener('click', openPopup);
    }

    closePopupBtns.forEach(btn => {
        btn.addEventListener('click', closePopup);
    });

    if (popup) {
        popup.addEventListener('click', function (e) {
            if (e.target === popup) {
                closePopup();
            }
        });
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closePopup();
        }
    });

    <?php if ($showPopup): ?>
        const schedulePopup = () => {
            setTimeout(() => {
                if (!document.hidden) {
                    openPopup();
                }
            }, 800);
        };
        if ('requestIdleCallback' in window) {
            requestIdleCallback(schedulePopup, { timeout: 1500 });
        } else {
            window.addEventListener('load', schedulePopup, { once: true });
        }
    <?php endif; ?>
});
</script>
<?php require_once __DIR__ . '/includes/footer.php'; ?>