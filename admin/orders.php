<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

$pageTitle = 'Quản lý đơn hàng';
$missing = require_upgrade_tables(['orders', 'order_items', 'order_addresses']);

// Lấy tham số tìm kiếm
$status = trim((string)($_GET['status'] ?? ''));
$paymentStatus = trim((string)($_GET['payment_status'] ?? ''));
$q = trim((string)($_GET['q'] ?? ''));

// Kiểm tra xem có đang ở chế độ xem tất cả không
$viewAll = isset($_GET['view_all']) && $_GET['view_all'] == 1;

// Xác định nếu đây là lần truy cập mặc định (không có bộ lọc nào) và không bấm "Xem tất cả"
$isDefaultFilter = empty($status) && empty($paymentStatus) && empty($q) && !$viewAll;

// Lấy toàn bộ danh sách đơn hàng từ DB theo bộ lọc cơ bản (Nếu có)
$orders = $missing ? [] : admin_get_orders(['status' => $status, 'payment_status' => $paymentStatus, 'q' => $q]);

// =========================================================================
// XỬ LÝ LỌC MẶC ĐỊNH (CHỈ HIỂN THỊ ĐƠN CẦN XỬ LÝ)
// =========================================================================
if ($isDefaultFilter && !empty($orders)) {
    $filteredOrders = [];
    foreach ($orders as $order) {
        $os = $order['order_status'] ?? '';
        $ps = $order['payment_status'] ?? '';
        
        // CÁC TRƯỜNG HỢP BỊ LOẠI BỎ KHỎI MẶC ĐỊNH:
        // 1. Đơn đã hoàn thành (Giao xong)
        // 2. Đơn đã hủy
        // 3. Đơn trả hàng
        // 4. Đơn chưa thanh toán VÀ Đang chờ xác nhận (Mới tạo, khách chưa chuyển khoản xong)
        $isCompletedOrCancelled = in_array($os, ['da_giao', 'da_huy', 'tra_hang']);
        $isNewUnpaid = ($ps === 'chua_thanh_toan' && $os === 'cho_xac_nhan');
        
        // Nếu không thuộc các trường hợp bị loại bỏ -> Đưa vào danh sách cần xử lý
        if (!$isCompletedOrCancelled && !$isNewUnpaid) {
            $filteredOrders[] = $order;
        }
    }
    $orders = $filteredOrders;
}

// =========================================================================
// THUẬT TOÁN SẮP XẾP ƯU TIÊN THÔNG MINH (SMART SORTING)
// =========================================================================
if (!$missing && !empty($orders)) {
    usort($orders, function($a, $b) {
        $getPriority = function($order) {
            $os = $order['order_status'] ?? '';
            $ps = $order['payment_status'] ?? '';

            // 1. Ưu tiên 1 (Đỏ): Tiền đã vào (Thanh toán/Cọc) nhưng CHỜ XÁC NHẬN
            if (in_array($ps, ['da_thanh_toan', 'da_dat_coc']) && $os === 'cho_xac_nhan') return 1;
            
            // 2. Ưu tiên 2 (Đỏ): Tiền đã vào (Thanh toán/Cọc) nhưng ĐANG CHUẨN BỊ
            if (in_array($ps, ['da_thanh_toan', 'da_dat_coc']) && $os === 'dang_chuan_bi') return 2;
            
            // 3. Xanh Dương: Đang trên đường giao (Đang Ship)
            if ($os === 'dang_giao') return 3;
            
            // 4. Tím: Khách hủy/trả hàng yêu cầu hoàn tiền (Chưa hoàn tiền)
            if ($ps === 'chua_hoan_tien') return 4;
            
            // 5. Vàng/Cam: Đơn COD (Chưa thanh toán) - Mới đặt (Chờ xác nhận)
            if ($ps === 'chua_thanh_toan' && $os === 'cho_xac_nhan') return 5;
            
            // 6. Xám: Đơn COD (Chưa thanh toán) - Đang đóng gói
            if ($ps === 'chua_thanh_toan' && $os === 'dang_chuan_bi') return 6;

            // 10. Chót bảng (Xanh lá): Các đơn đã hoàn thành chu kỳ sống (Đã giao xong, Hủy xong, Trả hàng, Đã hoàn tiền)
            if (in_array($os, ['da_giao', 'da_huy', 'tra_hang']) || $ps === 'da_hoan_tien') return 10;
            
            // Các trường hợp ngoại lệ khác
            return 8; 
        };

        $pA = $getPriority($a);
        $pB = $getPriority($b);

        // Nếu 2 đơn cùng mức độ ưu tiên -> Xếp theo thời gian đặt hàng (Mới nhất lên trước)
        if ($pA === $pB) {
            return strtotime($b['placed_at']) <=> strtotime($a['placed_at']);
        }
        
        // Sắp xếp mức độ ưu tiên (Số nhỏ lên trước)
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
            --admin-success-hover: #059669;
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
        .btn-primary-action:hover { background-color: var(--admin-success-hover); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2); }

        .color-legend { display: flex; flex-wrap: wrap; gap: 16px; margin-top: 12px; background: #f9fafb; padding: 12px 16px; border-radius: 8px; border: 1px solid var(--admin-border); }
        .legend-item { display: flex; align-items: center; font-size: 13px; color: var(--admin-text-main); font-weight: 600; }
        .legend-dot { display: inline-block; width: 14px; height: 14px; border-radius: 4px; margin-right: 6px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }

        .admin-filters { background: #f9fafb; border: 1px solid var(--admin-border); border-radius: 10px; padding: 20px; margin-bottom: 24px; }
        .filter-form { display: flex; flex-wrap: wrap; gap: 16px; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 200px; }
        .filter-group label { font-size: 13px; font-weight: 600; color: var(--admin-text-main); }
        .filter-control { padding: 10px 14px; border: 1px solid var(--admin-border); border-radius: 8px; font-size: 14px; background: #fff; outline: none; transition: all 0.2s ease; font-family: 'Inter', sans-serif; width: 100%; box-sizing: border-box; }
        .filter-control:focus { border-color: var(--admin-primary); box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1); }
        .filter-actions { display: flex; gap: 12px; flex: 1; min-width: 180px; }
        .btn { padding: 10px 20px; height: 42px; font-size: 14px; border-radius: 8px; font-weight: 600; cursor: pointer; border: none; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; box-sizing: border-box; white-space: nowrap; }
        .btn-search { background: var(--admin-text-main); color: #fff; }
        .btn-search:hover { background: #374151; }
        .btn-reset { background: #e5e7eb; color: var(--admin-text-main); }
        .btn-reset:hover { background: #d1d5db; }

        /* BẢNG DỮ LIỆU ĐƠN HÀNG */
        .table-responsive { width: 100%; overflow-x: auto; border-radius: 10px; border: 1px solid var(--admin-border); background: #fff; }
        .admin-table { width: 100%; border-collapse: collapse; text-align: left; min-width: 1100px; }
        .admin-table th { background-color: #f9fafb; color: var(--admin-text-muted); font-weight: 600; font-size: 12px; text-transform: uppercase; padding: 16px 14px; border-bottom: 1px solid var(--admin-border); white-space: nowrap; }
        
        /* Chỉnh lại td cho phép background phủ full */
        .admin-table td { padding: 16px 14px; vertical-align: middle; border-bottom: 1px solid var(--admin-border); font-size: 14px; background-color: inherit; }
        .admin-table tr:last-child td { border-bottom: none; }

        /* SMART ROWS - BÔI MÀU FULL HÀNG THEO YÊU CẦU MỚI */
        .admin-table tr { transition: all 0.2s ease; }
        
        /* 1. Xanh Lá: Hoàn tất / Đã hủy / Trả hàng / Hoàn tiền */
        .row-completed { background-color: #d1fae5 !important; opacity: 0.85; }
        .row-completed td:first-child { border-left: 5px solid #059669; }
        .row-completed:hover { opacity: 1; background-color: #a7f3d0 !important; }
        
        /* 2. Đỏ: Ưu tiên 1 & 2 - Đã TT/Cọc chờ XL hoặc đang đóng gói */
        .row-urgent-paid { background-color: #fee2e2 !important; } 
        .row-urgent-paid td:first-child { border-left: 5px solid #dc2626; }
        
        /* 3. Tím: Hoàn trả nhưng chưa hoàn tiền */
        .row-money-issue { background-color: #ede9fe !important; } 
        .row-money-issue td:first-child { border-left: 5px solid #7c3aed; }
        
        /* 4. Xanh Dương: Đang giao */
        .row-shipping { background-color: #e0f2fe !important; }
        .row-shipping td:first-child { border-left: 5px solid #0284c7; }
        
        /* 5. Vàng/Cam: Đơn COD chưa TT chờ xử lý */
        .row-action-needed { background-color: #fef3c7 !important; } 
        .row-action-needed td:first-child { border-left: 5px solid #d97706; }
        
        /* 6. Xám: Các trạng thái chưa thanh toán khác */
        .row-unpaid { background-color: #f3f4f6 !important; }
        .row-unpaid td:first-child { border-left: 5px solid #9ca3af; }

        .status-badge { display: inline-flex; padding: 6px 12px; font-size: 12px; font-weight: 700; border-radius: 20px; white-space: nowrap; align-items: center; gap: 4px; border: 1px solid transparent; }
        .status-badge::before { content: ''; display: block; width: 6px; height: 6px; border-radius: 50%; }
        
        .badge-warning { background: #fff; color: var(--admin-warning); border-color: #fde68a; } .badge-warning::before { background-color: var(--admin-warning); }
        .badge-success { background: #fff; color: var(--admin-success); border-color: #a7f3d0; } .badge-success::before { background-color: var(--admin-success); }
        .badge-danger { background: #fff; color: var(--admin-danger); border-color: #fecaca; } .badge-danger::before { background-color: var(--admin-danger); }
        .badge-primary { background: #fff; color: var(--admin-primary); border-color: #c7d2fe; } .badge-primary::before { background-color: var(--admin-primary); }
        .badge-info { background: #fff; color: var(--admin-info); border-color: #bae6fd; } .badge-info::before { background-color: var(--admin-info); }

        .channel-pill { display: inline-block; padding: 4px 8px; border-radius: 6px; background: rgba(255,255,255,0.6); color: #374151; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; border: 1px solid rgba(0,0,0,0.05); }
        .btn-view { display: inline-flex; padding: 8px 16px; font-size: 13px; border-radius: 6px; background-color: #fff; color: var(--admin-text-main); border: 1px solid var(--admin-border); font-weight: 600; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
        .btn-view:hover { background-color: var(--admin-primary); color: #fff; border-color: var(--admin-primary); }
        .muted-text { color: #4b5563; font-size: 13px; }
        .fw-600 { font-weight: 600; color: var(--admin-text-main); display: block; margin-bottom: 2px;}
        .date-text { font-family: monospace; font-size: 13px; color: #4b5563; }

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
            .filter-actions { flex-wrap: wrap; }
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

            <?php if ($isDefaultFilter): ?>
                <div style="background-color: #eff6ff; color: #1e40af; padding: 12px 16px; border-radius: 8px; margin-bottom: 24px; border: 1px solid #bfdbfe; font-size: 14px; display: flex; gap: 8px; align-items: flex-start;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                    <div>Hệ thống đang chỉ hiển thị <strong>các đơn hàng CẦN XỬ LÝ ƯU TIÊN</strong> (Đã ẩn các đơn Hoàn thành, Đã hủy, Trả hàng, hoặc Đơn chưa chuyển khoản). Bạn có thể bấm <a href="?view_all=1" style="color: var(--admin-primary); font-weight: 700;">Hiển thị tất cả</a>.</div>
                </div>
            <?php endif; ?>

            <div class="admin-header">
                <div class="admin-header-title">
                    <h1>Quản lý đơn hàng</h1>
                    <p>Theo dõi và xử lý các đơn đặt hàng từ khách hàng.</p>
                    
                    <div class="color-legend">
                        <div class="legend-item"><span class="legend-dot" style="background:#fee2e2; border: 1px solid #dc2626;"></span> Cần xử lý gấp (Ưu tiên)</div>
                        <div class="legend-item"><span class="legend-dot" style="background:#e0f2fe; border: 1px solid #0284c7;"></span> Đang Ship</div>
                        <div class="legend-item"><span class="legend-dot" style="background:#ede9fe; border: 1px solid #7c3aed;"></span> Chưa hoàn tiền</div>
                        <div class="legend-item"><span class="legend-dot" style="background:#fef3c7; border: 1px solid #d97706;"></span> COD chờ xác nhận</div>
                        <div class="legend-item"><span class="legend-dot" style="background:#d1fae5; border: 1px solid #059669;"></span> Hoàn tất / Đã hủy</div>
                    </div>
                </div>
                
               <div style="display:flex; gap:10px; flex-wrap:wrap;">
    <a href="<?= route_url('/admin/statistics.php') ?>" class="btn-primary-action" style="background-color: var(--admin-info); box-shadow: 0 4px 12px rgba(14, 165, 233, 0.2);">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="20" x2="18" y2="10"></line>
            <line x1="12" y1="20" x2="12" y2="4"></line>
            <line x1="6" y1="20" x2="6" y2="14"></line>
        </svg>
        Xem thống kê
    </a>
    <a href="<?= route_url('/admin/order_create.php') ?>" class="btn-primary-action">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Tạo đơn thủ công
    </a>
</div>
            </div>

            <?php if ($missing): ?>
                <div style="padding:16px; border-radius:8px; background:var(--admin-danger-bg); border:1px solid var(--admin-danger-border); color:var(--admin-danger); margin-bottom: 24px;">
                    <strong>Lưu ý:</strong> Hệ thống phát hiện thiếu bảng CSDL: <?= e(implode(', ', $missing)) ?>.
                </div>
            <?php else: ?>
                <div class="admin-filters">
                    <form class="filter-form" method="get" id="filterForm">
                        <div class="filter-group search-box">
                            <label>Tìm kiếm đơn hàng</label>
                            <input type="text" name="q" id="searchInput" class="filter-control" value="<?= e($q) ?>" placeholder="Nhập Mã đơn / Tên khách / Số điện thoại...">
                        </div>
                        <div class="filter-group select-box">
                            <label>Trạng thái đơn hàng</label>
                            <select name="status" class="filter-control auto-submit">
                                <option value="">-- Tất cả trạng thái --</option>
                                <?php foreach ($statusMap as $key => $val): ?>
                                    <option value="<?= e($key) ?>" <?= $status === $key ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="filter-group select-box">
                            <label>Trạng thái thanh toán</label>
                            <select name="payment_status" class="filter-control auto-submit">
                                <option value="">-- Tất cả thanh toán --</option>
                                <?php foreach ($paymentMap as $key => $val): ?>
                                    <option value="<?= e($key) ?>" <?= $paymentStatus === $key ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="filter-actions">
                            <button class="btn btn-search" type="submit">Tìm kiếm</button>
                            <a href="<?= route_url('/admin/orders.php') ?>" class="btn btn-reset">Xóa lọc</a>
                            <?php if ($isDefaultFilter): ?>
                                <a href="?view_all=1" class="btn" style="background: #eef2ff; color: var(--admin-primary); border: 1px solid #c7d2fe;">Hiện tất cả</a>
                            <?php endif; ?>
                        </div>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Khách hàng</th>
                                <th>Nguồn</th>
                                <th>Tổng tiền / Tiền lãi</th>
                                <th>Thanh toán</th>
                                <th>Trạng thái</th>
                                <th>Ngày tạo</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php if (empty($orders)): ?>
                            <tr>
                                <td colspan="8" style="text-align: center; padding: 60px 20px; color: var(--admin-text-muted);">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom: 12px; color: #9ca3af;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                                    <br>Không tìm thấy đơn hàng nào cần xử lý.
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($orders as $order): ?>
                                <?php 
                                    $oStatus = $statusMap[$order['order_status']] ?? [$order['order_status'], 'primary'];
                                    $pStatus = $paymentMap[$order['payment_status']] ?? [$order['payment_status'], 'info'];

                                    $rowClass = '';
                                    if (in_array($order['order_status'], ['da_giao', 'da_huy', 'tra_hang']) || $order['payment_status'] === 'da_hoan_tien') {
                                        $rowClass = 'row-completed'; // Xanh lá
                                    } elseif ($order['payment_status'] === 'chua_hoan_tien') {
                                        $rowClass = 'row-money-issue'; // Tím
                                    } elseif (in_array($order['payment_status'], ['da_thanh_toan', 'da_dat_coc']) && in_array($order['order_status'], ['cho_xac_nhan', 'dang_chuan_bi'])) {
                                        $rowClass = 'row-urgent-paid'; // Đỏ (Ưu tiên 1 & 2)
                                    } elseif ($order['order_status'] === 'dang_giao') {
                                        $rowClass = 'row-shipping'; // Xanh dương
                                    } elseif ($order['order_status'] === 'cho_xac_nhan') {
                                        $rowClass = 'row-action-needed'; // Vàng
                                    } elseif ($order['payment_status'] === 'chua_thanh_toan') {
                                        $rowClass = 'row-unpaid'; // Xám
                                    }
                                    
                                    // TÍNH TOÁN TIỀN LÃI KHÔNG CẦN TRUY VẤN VÀO BẢNG ORDER_ITEMS (Tránh lỗi SQL)
                                    // Lãi = Tổng tiền (total_amount) - Tổng vốn (purchase_price) - Phí ship
                                    $profit = null;
                                    $totalAmount = (float)($order['total_amount'] ?? 0);
                                    $shippingFee = (float)($order['shipping_fee'] ?? 0);
                                    
                                    $orderItems = db()->prepare("
                                        SELECT oi.quantity, p.purchase_price 
                                        FROM order_items oi
                                        LEFT JOIN products p ON oi.product_id = p.id
                                        WHERE oi.order_id = ?
                                    ");
                                    $orderItems->execute([$order['id']]);
                                    $items = $orderItems->fetchAll();
                                    
                                    if (!empty($items)) {
                                        $totalPurchasePrice = 0;
                                        foreach ($items as $item) {
                                            $itemPurchasePrice = (float)($item['purchase_price'] ?? 0);
                                            $qty = (int)($item['quantity'] ?? 1);
                                            $totalPurchasePrice += $itemPurchasePrice * $qty;
                                        }
                                        $profit = $totalAmount - $totalPurchasePrice - $shippingFee;
                                    }
                                ?>
                                <tr class="<?= $rowClass ?>">
                                    <td><span style="font-family: monospace; font-weight: 800; color: #111827; font-size: 15px;">#<?= e($order['order_code']) ?></span></td>
                                    <td>
                                        <span class="fw-600"><?= e($order['customer_name'] ?: $order['contact_name']) ?></span>
                                        <span class="muted-text">SĐT: <?= e($order['contact_phone']) ?></span>
                                    </td>
                                    <td><span class="channel-pill"><?= e($order['purchase_channel']) ?></span></td>
                                    
                                    <td>
                                        <div style="font-weight: 800; color: #111827; font-size: 15px;">
                                            <?= format_price($totalAmount) ?>
                                        </div>
                                        <?php if ($profit !== null): ?>
                                            <?php 
                                                $profitColor = $profit >= 0 ? '#059669' : '#dc2626'; // Xanh lá nếu lãi, đỏ nếu lỗ
                                                $profitSign = $profit >= 0 ? '+' : '';
                                            ?>
                                            <div style="font-size: 13px; font-weight: 700; color: <?= $profitColor ?>; margin-top: 4px; display: flex; align-items: center; gap: 4px;">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20"></path><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                                                Lãi: <?= $profitSign . format_price($profit) ?>
                                            </div>
                                        <?php else: ?>
                                            <div style="font-size: 12px; color: #6b7280; font-style: italic; margin-top: 4px;">(Chưa tính được lãi)</div>
                                        <?php endif; ?>
                                    </td>
                                    
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

<script>
// ==========================================
// Quản lý Auto-Submit Bộ lọc
// ==========================================
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('filterForm');
    if (form) {
        const autoSubmitSelects = document.querySelectorAll('.auto-submit');
        autoSubmitSelects.forEach(select => {
            select.addEventListener('change', () => { showLoading(); form.submit(); });
        });
        form.addEventListener('submit', showLoading);
    }
});

function showLoading() {
    document.getElementById('loadingOverlay').classList.add('active');
}
</script>
