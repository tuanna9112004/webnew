<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

// =========================================================================
// XỬ LÝ AJAX TÌM KIẾM SẢN PHẨM TRONG POPUP TẠO ĐƠN
// =========================================================================
if (isset($_GET['ajax_search_product'])) {
    header('Content-Type: application/json');
    $q = trim($_GET['q'] ?? '');
    if (strlen($q) < 2) { echo json_encode([]); exit; }
    
    try {
        // Tìm kiếm giới hạn 20 kết quả khớp tên sản phẩm, tên biến thể hoặc mã SKU
        $stmt = db()->prepare("
            SELECT p.id as product_id, p.product_name, p.thumbnail,
                   v.id as variant_id, v.variant_name, v.sku, v.sale_price, v.original_price
            FROM products p
            LEFT JOIN product_variants v ON p.id = v.product_id
            WHERE p.product_name LIKE ? OR v.variant_name LIKE ? OR v.sku LIKE ?
            LIMIT 20
        ");
        $lk = "%$q%";
        $stmt->execute([$lk, $lk, $lk]);
        
        $results = [];
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $price = (float)($row['sale_price'] > 0 ? $row['sale_price'] : $row['original_price']);
            $variantLabel = $row['variant_name'] ? ' - ' . $row['variant_name'] : '';
            $skuLabel = $row['sku'] ? ' (SKU: ' . $row['sku'] . ')' : '';
            
            $results[] = [
                'product_id' => $row['product_id'],
                'variant_id' => $row['variant_id'],
                'name' => trim($row['product_name'] . $variantLabel . $skuLabel),
                'price' => $price,
                'image' => resolve_media_url($row['thumbnail'])
            ];
        }
        echo json_encode($results);
    } catch (Exception $e) {
        echo json_encode([]);
    }
    exit;
}

$pageTitle = 'Quản lý đơn hàng';
$missing = require_upgrade_tables(['orders', 'order_items', 'order_addresses']);
$status = trim((string)($_GET['status'] ?? ''));
$paymentStatus = trim((string)($_GET['payment_status'] ?? ''));
$q = trim((string)($_GET['q'] ?? ''));

// =========================================================================
// XỬ LÝ FORM TẠO ĐƠN THỦ CÔNG (TỪ POPUP)
// =========================================================================
if (is_post() && ($_POST['action'] ?? '') === 'create_order') {
    verify_csrf_or_fail();
    try {
        // Dữ liệu sản phẩm khách chọn đã được mã hóa JSON truyền qua hidden input
        $orderItemsData = json_decode($_POST['order_items_json'] ?? '[]', true);
        
        if (empty($orderItemsData)) {
            throw new Exception("Vui lòng chọn ít nhất 1 sản phẩm để lên đơn!");
        }

        // Logic: Gọi hàm lưu database của bạn ở đây. Dưới đây chỉ là ví dụ để bạn hình dung
        // admin_create_manual_order($_POST['customer_name'], $_POST['contact_phone'], $_POST['address'], $_POST['total_amount'], $_POST['payment_status'], $_POST['order_status'], $orderItemsData);
        
        $_SESSION['success_msg'] = "Đã lên đơn hàng thủ công thành công!";
        header('Location: ' . route_url('/admin/orders.php'));
        exit;
    } catch (Exception $e) {
        $_SESSION['error_msg'] = "Lỗi tạo đơn: " . $e->getMessage();
    }
}

// Lấy danh sách đơn hàng từ DB
$orders = $missing ? [] : admin_get_orders(['status' => $status, 'payment_status' => $paymentStatus, 'q' => $q]);

// =========================================================================
// THUẬT TOÁN SẮP XẾP ƯU TIÊN THÔNG MINH (SMART SORTING)
// =========================================================================
if (!$missing && !empty($orders)) {
    usort($orders, function($a, $b) {
        $getPriority = function($order) {
            $os = $order['order_status'] ?? '';
            $ps = $order['payment_status'] ?? '';

            if (in_array($ps, ['da_thanh_toan', 'da_dat_coc']) && $os === 'cho_xac_nhan') return 1;
            if ($os === 'cho_xac_nhan') return 2;
            if (in_array($ps, ['da_thanh_toan', 'da_dat_coc']) && $os === 'dang_chuan_bi') return 3;
            if ($os === 'dang_chuan_bi') return 4;
            if ($ps === 'chua_hoan_tien') return 5;
            if ($os === 'dang_giao') return 6;
            if (in_array($os, ['da_giao', 'da_huy', 'tra_hang'])) return 10;
            return 8; 
        };

        $pA = $getPriority($a);
        $pB = $getPriority($b);

        if ($pA === $pB) {
            if ($pA === 10) return strtotime($b['placed_at']) <=> strtotime($a['placed_at']);
            return strtotime($a['placed_at']) <=> strtotime($b['placed_at']);
        }
        return $pA <=> $pB;
    });
}

$statusMap = order_status_options();
$paymentMap = payment_status_options();
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
        /* ==========================================================================
           MODERN ADMIN DASHBOARD STYLESHEET
           ========================================================================== */
        :root {
            --admin-bg: #f3f4f6;
            --admin-card: #ffffff;
            --admin-text-main: #111827;
            --admin-text-muted: #6b7280;
            --admin-border: #e5e7eb;
            --admin-primary: #4f46e5;
            --admin-primary-hover: #4338ca;
            --admin-danger: #ef4444;
            --admin-danger-bg: #fef2f2;
            --admin-danger-border: #fecaca;
            --admin-success: #10b981;
            --admin-success-bg: #ecfdf5;
            --admin-warning: #f59e0b;
            --admin-warning-bg: #fffbeb;
            --admin-info: #0ea5e9;
            --admin-info-bg: #e0f2fe;
            --admin-radius: 12px;
            --admin-shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --admin-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --sidebar-width: 260px;
        }

        body { background-color: var(--admin-bg); color: var(--admin-text-main); font-family: 'Inter', sans-serif; margin: 0; padding: 0; -webkit-font-smoothing: antialiased; }

        .admin-wrapper { display: flex; min-height: 100vh; width: 100%; }
        .admin-sidebar { width: var(--sidebar-width); background: var(--admin-card); border-right: 1px solid var(--admin-border); flex-shrink: 0; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; overflow-y: auto; }
        .sidebar-header { padding: 24px; display: flex; align-items: center; gap: 12px; }
        .sidebar-header h2 { font-size: 22px; font-weight: 700; margin: 0; color: var(--admin-primary); letter-spacing: -0.5px; }
        .sidebar-menu { list-style: none; padding: 0 16px; margin: 0; flex-grow: 1; }
        .sidebar-menu li { margin-bottom: 4px; }
        .sidebar-menu a { display: flex; align-items: center; gap: 12px; padding: 12px 16px; color: var(--admin-text-muted); text-decoration: none; font-size: 14px; font-weight: 500; border-radius: 8px; transition: all 0.2s ease; }
        .sidebar-menu a:hover { background-color: #f9fafb; color: var(--admin-text-main); }
        .sidebar-menu a.active { background-color: #eef2ff; color: var(--admin-primary); font-weight: 600; }
        .sidebar-menu a.text-danger { color: var(--admin-danger); margin-top: auto; }
        .sidebar-menu a.text-danger:hover { background-color: var(--admin-danger-bg); }

        .admin-main { flex-grow: 1; padding: 32px; max-width: calc(100% - var(--sidebar-width)); overflow-x: hidden; }
        .admin-container { background: var(--admin-card); border-radius: var(--admin-radius); box-shadow: var(--admin-shadow); padding: 24px; margin-bottom: 40px; border: 1px solid var(--admin-border); }
        
        .admin-header { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: flex-start; gap: 20px; margin-bottom: 24px; }
        .admin-header-title h1 { font-size: 24px; font-weight: 700; margin: 0 0 8px 0; color: var(--admin-text-main); }
        .admin-header-title p { color: var(--admin-text-muted); font-size: 14px; margin: 0; }

        .btn-primary-action { background-color: var(--admin-success); color: #fff; padding: 10px 20px; font-size: 14px; font-weight: 600; border-radius: 8px; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.2s ease; box-shadow: var(--admin-shadow-sm); border: none; cursor: pointer; }
        .btn-primary-action:hover { background-color: #059669; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2); }

        .color-legend { display: flex; flex-wrap: wrap; gap: 16px; margin-top: 12px; background: #f9fafb; padding: 12px 16px; border-radius: 8px; border: 1px solid var(--admin-border); }
        .legend-item { display: flex; align-items: center; font-size: 13px; color: var(--admin-text-main); font-weight: 500; }
        .legend-dot { display: inline-block; width: 12px; height: 12px; border-radius: 3px; margin-right: 6px; }

        .admin-filters { background: #f9fafb; border: 1px solid var(--admin-border); border-radius: 10px; padding: 20px; margin-bottom: 24px; }
        .filter-form { display: flex; flex-wrap: wrap; gap: 16px; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 200px; }
        .filter-group label { font-size: 13px; font-weight: 600; color: var(--admin-text-main); }
        .filter-control { padding: 10px 14px; border: 1px solid var(--admin-border); border-radius: 8px; font-size: 14px; background: #fff; outline: none; transition: all 0.2s ease; font-family: 'Inter', sans-serif; width: 100%; box-sizing: border-box; }
        .filter-control:focus { border-color: var(--admin-primary); box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1); }
        .filter-actions { display: flex; gap: 12px; }
        .btn { padding: 10px 20px; height: 42px; font-size: 14px; border-radius: 8px; font-weight: 600; cursor: pointer; border: none; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; box-sizing: border-box; }
        .btn-search { background: var(--admin-text-main); color: #fff; }
        .btn-search:hover { background: #374151; }
        .btn-reset { background: #e5e7eb; color: var(--admin-text-main); }
        .btn-reset:hover { background: #d1d5db; }

        .table-responsive { width: 100%; overflow-x: auto; border-radius: 10px; border: 1px solid var(--admin-border); background: #fff; }
        .admin-table { width: 100%; border-collapse: separate; border-spacing: 0; text-align: left; min-width: 1000px; }
        .admin-table th { background-color: #f9fafb; color: var(--admin-text-muted); font-weight: 600; font-size: 12px; text-transform: uppercase; padding: 16px 14px; border-bottom: 1px solid var(--admin-border); white-space: nowrap; }
        .admin-table td { padding: 16px 14px; vertical-align: middle; border-bottom: 1px solid var(--admin-border); font-size: 14px; transition: background-color 0.2s; }
        .admin-table tr:last-child td { border-bottom: none; }

        .admin-table tr { transition: opacity 0.3s, filter 0.3s; }
        .row-completed { opacity: 0.55; background-color: #f9fafb; filter: grayscale(30%); }
        .row-completed:hover { opacity: 1; filter: grayscale(0%); background-color: #fff; }
        .row-money-issue td:first-child { border-left: 4px solid #8b5cf6; }
        .row-urgent-paid td:first-child { border-left: 4px solid var(--admin-success); }
        .row-urgent-paid { background-color: var(--admin-success-bg); }
        .row-action-needed td:first-child { border-left: 4px solid var(--admin-warning); }
        .row-shipping td:first-child { border-left: 4px solid var(--admin-info); }
        .row-unpaid td:first-child { border-left: 4px solid var(--admin-danger); }

        .status-badge { display: inline-flex; padding: 6px 12px; font-size: 12px; font-weight: 600; border-radius: 20px; white-space: nowrap; align-items: center; gap: 4px; }
        .status-badge::before { content: ''; display: block; width: 6px; height: 6px; border-radius: 50%; }
        .badge-warning { background: var(--admin-warning-bg); color: var(--admin-warning); } .badge-warning::before { background-color: var(--admin-warning); }
        .badge-success { background: var(--admin-success-bg); color: var(--admin-success); } .badge-success::before { background-color: var(--admin-success); }
        .badge-danger { background: var(--admin-danger-bg); color: var(--admin-danger); } .badge-danger::before { background-color: var(--admin-danger); }
        .badge-primary { background: #eef2ff; color: var(--admin-primary); } .badge-primary::before { background-color: var(--admin-primary); }
        .badge-info { background: var(--admin-info-bg); color: var(--admin-info); } .badge-info::before { background-color: var(--admin-info); }

        .channel-pill { display: inline-block; padding: 4px 8px; border-radius: 6px; background: #f3f4f6; color: #4b5563; font-size: 12px; font-weight: 600; text-transform: capitalize; }
        .btn-view { display: inline-flex; padding: 8px 16px; font-size: 13px; border-radius: 6px; background-color: #fff; color: var(--admin-primary); border: 1px solid var(--admin-primary); font-weight: 600; }
        .btn-view:hover { background-color: #eef2ff; }
        .muted-text { color: var(--admin-text-muted); font-size: 13px; }
        .fw-600 { font-weight: 600; color: var(--admin-text-main); display: block; margin-bottom: 2px;}
        .date-text { font-family: monospace; font-size: 13px; color: var(--admin-text-muted); }

        /* ==========================================
           FORM GRID (Đồng bộ)
           ========================================== */
        .form-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; margin-bottom: 16px; }
        .form-group { margin-bottom: 16px; }
        .form-label { display: block; font-size: 13px; font-weight: 700; margin-bottom: 8px; color: var(--admin-text-main); }

        /* ==========================================
           MODAL (POPUP TẠO ĐƠN CHUẨN)
           ========================================== */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(17, 24, 39, 0.6); z-index: 9999; align-items: center; justify-content: center; backdrop-filter: blur(4px); opacity: 0; transition: opacity 0.2s ease; }
        .modal-overlay.active { display: flex; opacity: 1; }
        .modal-container { background: #fff; width: 100%; max-width: 800px; border-radius: 16px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); overflow: hidden; transform: scale(0.95); transition: transform 0.2s ease; max-height: 90vh; display: flex; flex-direction: column; }
        .modal-overlay.active .modal-container { transform: scale(1); }
        
        .modal-header { padding: 20px 24px; border-bottom: 1px solid var(--admin-border); display: flex; justify-content: space-between; align-items: center; background: #f9fafb; }
        .modal-header h2 { margin: 0; font-size: 18px; font-weight: 700; color: var(--admin-text-main); display: flex; align-items: center; gap: 8px; }
        .modal-close { background: none; border: none; font-size: 24px; cursor: pointer; color: var(--admin-text-muted); line-height: 1; padding: 0; transition: color 0.2s; }
        .modal-close:hover { color: var(--admin-danger); }
        
        .modal-body { padding: 24px; overflow-y: auto; }
        .modal-section-title { font-size: 14px; font-weight: 700; color: var(--admin-primary); margin: 0 0 16px 0; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 2px solid #eef2ff; padding-bottom: 8px; display: flex; align-items: center; gap: 8px;}
        
        .modal-footer { padding: 16px 24px; border-top: 1px solid var(--admin-border); background: #f9fafb; display: flex; justify-content: flex-end; gap: 12px; }

        /* SEARCH DROPDOWN UI */
        .search-dropdown { position: absolute; top: 100%; left: 0; right: 0; background: #fff; border: 1px solid var(--admin-border); border-radius: 8px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); z-index: 1000; max-height: 250px; overflow-y: auto; display: none; }
        .search-item { padding: 10px 14px; border-bottom: 1px solid var(--admin-border); cursor: pointer; display: flex; align-items: center; gap: 12px; }
        .search-item:last-child { border-bottom: none; }
        .search-item:hover { background: #f9fafb; }
        .search-item img { width: 40px; height: 40px; object-fit: cover; border-radius: 6px; border: 1px solid #e5e7eb; }
        .search-item-name { font-size: 14px; font-weight: 600; color: var(--admin-text-main); margin-bottom: 2px;}
        .search-item-price { font-size: 13px; color: var(--admin-danger); font-weight: 600;}

        /* Bảng giỏ hàng mini */
        .mini-cart-table { width: 100%; border-collapse: collapse; margin-bottom: 16px; border: 1px solid var(--admin-border); border-radius: 8px; overflow: hidden; }
        .mini-cart-table th { background: #f9fafb; font-size: 12px; text-transform: uppercase; font-weight: 600; color: var(--admin-text-muted); padding: 10px 12px; text-align: left; border-bottom: 1px solid var(--admin-border); }
        .mini-cart-table td { padding: 10px 12px; font-size: 13px; border-bottom: 1px solid var(--admin-border); vertical-align: middle; }
        .mini-cart-table tr:last-child td { border-bottom: none; }
        .qty-input { width: 60px; padding: 6px; border: 1px solid #d1d5db; border-radius: 6px; text-align: center; font-size: 13px; }

        .loading-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.7); z-index: 10000; align-items: center; justify-content: center; }
        .loading-overlay.active { display: flex; }
        .spinner { width: 40px; height: 40px; border: 4px solid var(--admin-border); border-top-color: var(--admin-primary); border-radius: 50%; animation: spin 1s linear infinite; }
        @keyframes spin { 100% { transform: rotate(360deg); } }

        /* Responsive */
        @media (max-width: 1024px) { .admin-main { padding: 20px; } }
        @media (max-width: 768px) {
            .admin-wrapper { flex-direction: column; }
            .admin-sidebar { width: 100%; height: auto; position: relative; border-right: none; border-bottom: 1px solid var(--admin-border); }
            .sidebar-menu { display: flex; overflow-x: auto; padding: 12px; gap: 8px; }
            .sidebar-menu li { margin: 0; white-space: nowrap; }
            .admin-main { max-width: 100%; padding: 16px; }
            .admin-header { flex-direction: column; align-items: flex-start; gap: 16px; }
            .filter-actions, .filter-actions .btn { width: 100%; }
            .form-grid { grid-template-columns: 1fr; gap: 0; }
            .modal-container { height: 100vh; max-height: 100vh; border-radius: 0; }
        }
    </style>
</head>
<body>

<div class="loading-overlay" id="loadingOverlay"><div class="spinner"></div></div>

<div class="admin-wrapper">
    <aside class="admin-sidebar">
        <div class="sidebar-header">
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--admin-primary)"><path d="M12 2L2 7l10 5 10-5-10-5z"></path><path d="M2 17l10 5 10-5"></path><path d="M2 12l10 5 10-5"></path></svg>
            <h2>Quản lý</h2>
        </div>
        <ul class="sidebar-menu">
            <li><a href="<?= route_url('/admin/products.php') ?>"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg> Sản phẩm</a></li>
            <li><a href="<?= route_url('/admin/orders.php') ?>" class="active"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2l3 6"></path><path d="M18 2l-3 6"></path><path d="M3 10h18"></path><path d="M4 10l1 10h14l1-10"></path></svg> Đơn hàng</a></li>
            <li><a href="<?= route_url('/admin/categories.php') ?>"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg> Danh mục</a></li>
            <li><a href="<?= route_url('/admin/product_types.php') ?>"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg> Loại sản phẩm</a></li>
            <li><a href="<?= route_url('/admin/product_conditions.php') ?>"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg> Tình trạng</a></li>
            <li><a href="<?= route_url('/admin/styles.php') ?>"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg> Phong cách</a></li>
            <li style="margin-top: 24px;"><a href="<?= route_url('/admin/logout.php') ?>" class="text-danger"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg> Đăng xuất</a></li>
        </ul>
    </aside>

    <main class="admin-main">
        <div class="admin-container">
            
            <?php if (isset($_SESSION['success_msg'])): ?>
                <div style="background-color: var(--admin-success-bg); color: var(--admin-success); padding: 16px; border-radius: 8px; margin-bottom: 24px; border: 1px solid #a7f3d0;">
                    <?= e($_SESSION['success_msg']) ?>
                    <?php unset($_SESSION['success_msg']); ?>
                </div>
            <?php endif; ?>

            <?php if (isset($_SESSION['error_msg'])): ?>
                <div style="background-color: var(--admin-danger-bg); color: var(--admin-danger); padding: 16px; border-radius: 8px; margin-bottom: 24px; border: 1px solid var(--admin-danger-border);">
                    <?= e($_SESSION['error_msg']) ?>
                    <?php unset($_SESSION['error_msg']); ?>
                </div>
            <?php endif; ?>

            <div class="admin-header">
                <div class="admin-header-title">
                    <h1>Quản lý đơn hàng</h1>
                    <p>Theo dõi và xử lý các đơn đặt hàng từ khách hàng.</p>
                    
                    <div class="color-legend">
                        <div class="legend-item"><span class="legend-dot" style="background:var(--admin-success);"></span> Đã thanh toán (Chưa làm)</div>
                        <div class="legend-item"><span class="legend-dot" style="background:var(--admin-warning);"></span> Cần xác nhận</div>
                        <div class="legend-item"><span class="legend-dot" style="background:var(--admin-danger);"></span> Chưa thanh toán</div>
                        <div class="legend-item"><span class="legend-dot" style="background:var(--admin-info);"></span> Đang Ship</div>
                        <div class="legend-item" style="opacity:0.6;"><span class="legend-dot" style="background:#9ca3af;"></span> Hoàn tất / Đã hủy</div>
                    </div>
                </div>
                
                <div style="display:flex; gap:10px; flex-wrap:wrap;">
                    <button type="button" class="btn-primary-action" onclick="openOrderModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                        Tạo đơn thủ công
                    </button>
                </div>
            </div>

            <?php if ($missing): ?>
                <div style="padding:16px; border-radius:8px; background:var(--admin-danger-bg); border:1px solid var(--admin-danger-border); color:var(--admin-danger); margin-bottom: 24px;">
                    <strong>Lưu ý:</strong> Hệ thống phát hiện thiếu bảng CSDL: <?= e(implode(', ', $missing)) ?>.
                </div>
            <?php else: ?>
                <div class="admin-filters">
                    <form class="filter-form" method="get" id="filterForm">
                        <div class="filter-group" style="flex: 2; min-width: 250px;">
                            <label>Tìm kiếm đơn hàng</label>
                            <input type="text" name="q" id="searchInput" class="filter-control" value="<?= e($q) ?>" placeholder="Nhập Mã đơn / Tên / SĐT...">
                        </div>
                        <div class="filter-group" style="flex: 1; min-width: 180px;">
                            <label>Trạng thái đơn hàng</label>
                            <select name="status" class="filter-control auto-submit">
                                <option value="">-- Tất cả --</option>
                                <?php foreach ($statusMap as $key => $val): ?>
                                    <option value="<?= e($key) ?>" <?= $status === $key ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="filter-group" style="flex: 1; min-width: 180px;">
                            <label>Thanh toán</label>
                            <select name="payment_status" class="filter-control auto-submit">
                                <option value="">-- Tất cả --</option>
                                <?php foreach ($paymentMap as $key => $val): ?>
                                    <option value="<?= e($key) ?>" <?= $paymentStatus === $key ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="filter-actions">
                            <button class="btn btn-search" type="submit">Tìm kiếm</button>
                            <a href="<?= route_url('/admin/orders.php') ?>" class="btn btn-reset">Xóa lọc</a>
                        </div>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Khách hàng</th>
                                <th>Tổng tiền</th>
                                <th>Thanh toán</th>
                                <th>Trạng thái</th>
                                <th>Ngày tạo</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php if (empty($orders)): ?>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 60px 20px; color: var(--admin-text-muted);">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom: 12px; color: #9ca3af;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                                    <br>Không tìm thấy đơn hàng.
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($orders as $order): ?>
                                <?php 
                                    $oStatus = $statusMap[$order['order_status']] ?? [$order['order_status'], 'primary'];
                                    $pStatus = $paymentMap[$order['payment_status']] ?? [$order['payment_status'], 'info'];

                                    $rowClass = '';
                                    if (in_array($order['order_status'], ['da_giao', 'da_huy', 'tra_hang'])) {
                                        $rowClass = 'row-completed'; 
                                    } elseif ($order['payment_status'] === 'chua_hoan_tien') {
                                        $rowClass = 'row-money-issue'; 
                                    } elseif (in_array($order['payment_status'], ['da_thanh_toan', 'da_dat_coc']) && in_array($order['order_status'], ['cho_xac_nhan', 'dang_chuan_bi'])) {
                                        $rowClass = 'row-urgent-paid'; 
                                    } elseif ($order['order_status'] === 'cho_xac_nhan') {
                                        $rowClass = 'row-action-needed'; 
                                    } elseif ($order['order_status'] === 'dang_giao') {
                                        $rowClass = 'row-shipping'; 
                                    } elseif ($order['payment_status'] === 'chua_thanh_toan') {
                                        $rowClass = 'row-unpaid'; 
                                    }
                                ?>
                                <tr class="<?= $rowClass ?>">
                                    <td><span style="font-family: monospace; font-weight: 700; color: var(--admin-primary); font-size: 15px;">#<?= e($order['order_code']) ?></span></td>
                                    <td>
                                        <span class="fw-600"><?= e($order['customer_name'] ?: $order['contact_name']) ?></span>
                                        <span class="muted-text">SĐT: <?= e($order['contact_phone']) ?></span>
                                    </td>
                                    <td><strong style="color: var(--admin-danger);"><?= format_price($order['total_amount']) ?></strong></td>
                                    <td><span class="status-badge badge-<?= $pStatus[1] ?>"><?= e($pStatus[0]) ?></span></td>
                                    <td><span class="status-badge badge-<?= $oStatus[1] ?>"><?= e($oStatus[0]) ?></span></td>
                                    <td><span class="date-text"><?= e(date('H:i d/m/Y', strtotime($order['placed_at']))) ?></span></td>
                                    <td><a href="<?= route_url('/admin/order_view.php') ?>?id=<?= (int)$order['id'] ?>" class="btn btn-view">Chi tiết</a></td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            <?php endif; ?>
        </div>
    </main>
</div>

<div class="modal-overlay" id="createOrderModal">
    <div class="modal-container">
        <div class="modal-header">
            <h2>
                <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="12" y1="18" x2="12" y2="12"></line><line x1="9" y1="15" x2="15" y2="15"></line></svg>
                Lên đơn hàng thủ công
            </h2>
            <button class="modal-close" onclick="closeOrderModal()">&times;</button>
        </div>
        
        <form method="post" id="manualOrderForm" onsubmit="return validateAndSubmit()">
            <?= csrf_field() ?>
            <input type="hidden" name="action" value="create_order">
            <input type="hidden" name="order_items_json" id="orderItemsJson">
            
            <div class="modal-body">
                <h3 class="modal-section-title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                    1. Thông tin khách hàng
                </h3>
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Tên khách hàng <span style="color:var(--admin-danger);">*</span></label>
                        <input type="text" name="customer_name" class="form-control" required placeholder="VD: Anh Tùng">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số điện thoại <span style="color:var(--admin-danger);">*</span></label>
                        <input type="tel" name="contact_phone" class="form-control" required placeholder="VD: 0987654321">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Địa chỉ giao hàng</label>
                    <input type="text" name="address" class="form-control" placeholder="Ghi đầy đủ số nhà, đường, phường xã, tỉnh thành...">
                </div>

                <h3 class="modal-section-title" style="margin-top: 24px;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                    2. Chọn Sản phẩm
                </h3>
                
                <div class="form-group" style="position: relative;">
                    <input type="text" id="searchProductInput" class="form-control" placeholder="🔍 Gõ tên hoặc mã sản phẩm để tìm và thêm vào đơn..." autocomplete="off">
                    <div id="searchDropdown" class="search-dropdown"></div>
                </div>

                <div class="table-responsive" style="margin-bottom: 20px; overflow-y:visible; border-radius: 8px;">
                    <table class="mini-cart-table">
                        <thead>
                            <tr>
                                <th>Sản phẩm đã chọn</th>
                                <th style="width: 70px; text-align: center;">SL</th>
                                <th style="text-align: right;">Đơn giá</th>
                                <th style="text-align: right;">Thành tiền</th>
                                <th style="width: 40px;"></th>
                            </tr>
                        </thead>
                        <tbody id="selectedProductsBody">
                            <tr id="emptyProductRow"><td colspan="5" style="text-align:center; color:var(--admin-text-muted); padding: 24px;">Giỏ hàng trống. Hãy tìm và chọn sản phẩm ở ô trên.</td></tr>
                        </tbody>
                    </table>
                </div>

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Tổng tiền thu (VNĐ) <span style="color:var(--admin-danger);">*</span></label>
                        <input type="number" id="totalAmountInput" name="total_amount" class="form-control" required min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Trạng thái thanh toán</label>
                        <select name="payment_status" class="form-control">
                            <option value="chua_thanh_toan">Chưa thanh toán (COD)</option>
                            <option value="da_dat_coc">Khách đã đặt cọc</option>
                            <option value="da_thanh_toan">Khách đã CK đủ</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Trạng thái xử lý</label>
                    <select name="order_status" class="form-control">
                        <option value="cho_xac_nhan">Chờ xác nhận</option>
                        <option value="dang_chuan_bi">Đang chuẩn bị hàng</option>
                        <option value="da_giao">Giao xong (Khách mua trực tiếp)</option>
                    </select>
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn btn-reset" onclick="closeOrderModal()" style="width: auto;">Hủy bỏ</button>
                <button type="submit" class="btn-primary-action" style="margin: 0; width: auto;">Lưu đơn hàng</button>
            </div>
        </form>
    </div>
</div>

<script>
// 1. Quản lý Auto-Submit Bộ lọc
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('filterForm');
    const autoSubmitSelects = document.querySelectorAll('.auto-submit');

    autoSubmitSelects.forEach(select => {
        select.addEventListener('change', () => { showLoading(); form.submit(); });
    });
    form.addEventListener('submit', showLoading);
});

function showLoading() {
    document.getElementById('loadingOverlay').classList.add('active');
}

// 2. Quản lý Modal
const modal = document.getElementById('createOrderModal');
function openOrderModal() {
    modal.classList.add('active');
    document.body.style.overflow = 'hidden'; 
}
function closeOrderModal() {
    modal.classList.remove('active');
    document.body.style.overflow = '';
}
modal.addEventListener('click', function(e) {
    if (e.target === modal) closeOrderModal();
});

// 3. Quản lý Tìm kiếm & Giỏ hàng AJAX
let selectedItems = [];
const searchInput = document.getElementById('searchProductInput');
const searchDropdown = document.getElementById('searchDropdown');
const tbody = document.getElementById('selectedProductsBody');
const totalInput = document.getElementById('totalAmountInput');
const jsonInput = document.getElementById('orderItemsJson');

let searchTimeout;

// 3.1 Gõ tìm kiếm
searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    const q = this.value.trim();
    if (q.length < 2) {
        searchDropdown.style.display = 'none';
        return;
    }
    
    searchTimeout = setTimeout(() => {
        fetch(`?ajax_search_product=1&q=${encodeURIComponent(q)}`)
            .then(res => res.json())
            .then(data => {
                searchDropdown.innerHTML = '';
                if(data.length === 0) {
                    searchDropdown.innerHTML = '<div style="padding:12px; text-align:center; color:var(--admin-text-muted); font-size:13px;">Không tìm thấy sản phẩm phù hợp</div>';
                } else {
                    data.forEach(item => {
                        const div = document.createElement('div');
                        div.className = 'search-item';
                        div.innerHTML = `
                            <img src="${item.image || '/assets/default-placeholder.png'}" onerror="this.src='/assets/default-placeholder.png'">
                            <div style="flex: 1;">
                                <div class="search-item-name">${item.name}</div>
                                <div class="search-item-price">${new Intl.NumberFormat('vi-VN').format(item.price)}đ</div>
                            </div>
                        `;
                        div.onclick = () => addItemToCart(item);
                        searchDropdown.appendChild(div);
                    });
                }
                searchDropdown.style.display = 'block';
            });
    }, 300);
});

// Ẩn dropdown khi click ra ngoài
document.addEventListener('click', (e) => {
    if (!searchInput.contains(e.target) && !searchDropdown.contains(e.target)) {
        searchDropdown.style.display = 'none';
    }
});

// 3.2 Thêm vào giỏ
function addItemToCart(item) {
    searchDropdown.style.display = 'none';
    searchInput.value = '';
    
    // Kiểm tra xem đã có trong giỏ chưa (cùng product_id và variant_id)
    const existingIndex = selectedItems.findIndex(i => i.variant_id === item.variant_id && i.product_id === item.product_id);
    if (existingIndex > -1) {
        selectedItems[existingIndex].qty += 1;
    } else {
        selectedItems.push({ ...item, qty: 1 });
    }
    renderCart();
}

// 3.3 Đổi số lượng
window.updateItemQty = function(index, newQty) {
    newQty = parseInt(newQty);
    if (newQty < 1) newQty = 1;
    selectedItems[index].qty = newQty;
    renderCart();
};

// 3.4 Xóa khỏi giỏ
window.removeItemFromCart = function(index) {
    selectedItems.splice(index, 1);
    renderCart();
};

// 3.5 Render lại bảng giỏ hàng & Tính tiền
function renderCart() {
    if (selectedItems.length === 0) {
        tbody.innerHTML = '<tr id="emptyProductRow"><td colspan="5" style="text-align:center; color:var(--admin-text-muted); padding: 24px;">Giỏ hàng trống. Hãy tìm và chọn sản phẩm ở ô trên.</td></tr>';
        totalInput.value = 0;
        jsonInput.value = '[]';
        return;
    }
    
    let html = '';
    let grandTotal = 0;
    
    selectedItems.forEach((item, index) => {
        const lineTotal = item.price * item.qty;
        grandTotal += lineTotal;
        html += `
            <tr>
                <td>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <img src="${item.image || '/assets/default-placeholder.png'}" onerror="this.src='/assets/default-placeholder.png'" style="width:36px; height:36px; border-radius:4px; object-fit:cover; border:1px solid #e5e7eb;">
                        <span style="font-weight:600; color:var(--admin-text-main); font-size:13px; line-height:1.4;">${item.name}</span>
                    </div>
                </td>
                <td style="text-align:center;">
                    <input type="number" class="qty-input" min="1" value="${item.qty}" onchange="updateItemQty(${index}, this.value)">
                </td>
                <td style="text-align:right; font-size:13px; color:var(--admin-text-muted);">${new Intl.NumberFormat('vi-VN').format(item.price)}</td>
                <td style="text-align:right; font-weight:600; color:var(--admin-danger);">${new Intl.NumberFormat('vi-VN').format(lineTotal)}</td>
                <td style="text-align:center;">
                    <button type="button" onclick="removeItemFromCart(${index})" style="background:none; border:none; color:var(--admin-danger); cursor:pointer; padding:4px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                    </button>
                </td>
            </tr>
        `;
    });
    
    tbody.innerHTML = html;
    totalInput.value = grandTotal; // Tự động điền số tiền tổng
    jsonInput.value = JSON.stringify(selectedItems); // Cập nhật input ẩn để đẩy lên Server
}

// 4. Validate trước khi submit
function validateAndSubmit() {
    if (selectedItems.length === 0) {
        alert("Vui lòng tìm và chọn ít nhất 1 sản phẩm trước khi lưu đơn!");
        return false;
    }
    showLoading();
    return true;
}
</script>
</body>
</html>