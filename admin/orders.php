<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

$pageTitle = 'Quản lý đơn hàng';
$missing = require_upgrade_tables(['orders', 'order_items', 'order_addresses']);
$status = trim((string)($_GET['status'] ?? ''));
$paymentStatus = trim((string)($_GET['payment_status'] ?? ''));
$q = trim((string)($_GET['q'] ?? ''));

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

            // 1. TOP Ưu tiên: Tiền đã vào (Thanh toán/Cọc) nhưng chưa xử lý (Chờ xác nhận)
            if (in_array($ps, ['da_thanh_toan', 'da_dat_coc']) && $os === 'cho_xac_nhan') return 1;
            
            // 2. Tiền đã vào (Thanh toán/Cọc) đang đóng gói (Đang chuẩn bị)
            if (in_array($ps, ['da_thanh_toan', 'da_dat_coc']) && $os === 'dang_chuan_bi') return 2;
            
            // 3. Các vấn đề rủi ro cao: Khách hủy/trả hàng yêu cầu hoàn tiền (Cần xử lý để tránh khiếu nại)
            if ($ps === 'chua_hoan_tien') return 3;
            
            // 4. Đơn đang trên đường giao (Đang theo dõi)
            if ($os === 'dang_giao') return 4;
            
            // 5. Đơn COD (Chưa thanh toán) - Mới đặt (Chờ xác nhận) -> Kém ưu tiên hơn đơn đã trả tiền
            if ($ps === 'chua_thanh_toan' && $os === 'cho_xac_nhan') return 5;
            
            // 6. Đơn COD (Chưa thanh toán) - Đang đóng gói
            if ($ps === 'chua_thanh_toan' && $os === 'dang_chuan_bi') return 6;

            // 10. Chót bảng: Các đơn đã hoàn thành chu kỳ sống (Đã giao xong, Hủy xong, Đã hoàn tiền)
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
        .legend-item { display: flex; align-items: center; font-size: 13px; color: var(--admin-text-main); font-weight: 500; }
        .legend-dot { display: inline-block; width: 12px; height: 12px; border-radius: 3px; margin-right: 6px; }

        .admin-filters { background: #f9fafb; border: 1px solid var(--admin-border); border-radius: 10px; padding: 20px; margin-bottom: 24px; }
        .filter-form { display: flex; flex-wrap: wrap; gap: 16px; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 200px; }
        .filter-group label { font-size: 13px; font-weight: 600; color: var(--admin-text-main); }
        .filter-control { padding: 10px 14px; border: 1px solid var(--admin-border); border-radius: 8px; font-size: 14px; background: #fff; outline: none; transition: all 0.2s ease; font-family: 'Inter', sans-serif; width: 100%; box-sizing: border-box; }
        .filter-control:focus { border-color: var(--admin-primary); box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1); }
        .filter-actions { display: flex; gap: 12px; flex: 1; min-width: 180px; }
        .btn { padding: 10px 20px; height: 42px; font-size: 14px; border-radius: 8px; font-weight: 600; cursor: pointer; border: none; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; box-sizing: border-box; }
        .btn-search { background: var(--admin-text-main); color: #fff; }
        .btn-search:hover { background: #374151; }
        .btn-reset { background: #e5e7eb; color: var(--admin-text-main); }
        .btn-reset:hover { background: #d1d5db; }

        /* BẢNG DỮ LIỆU ĐƠN HÀNG */
        .table-responsive { width: 100%; overflow-x: auto; border-radius: 10px; border: 1px solid var(--admin-border); background: #fff; }
        .admin-table { width: 100%; border-collapse: separate; border-spacing: 0; text-align: left; min-width: 1000px; }
        .admin-table th { background-color: #f9fafb; color: var(--admin-text-muted); font-weight: 600; font-size: 12px; text-transform: uppercase; padding: 16px 14px; border-bottom: 1px solid var(--admin-border); white-space: nowrap; }
        .admin-table td { padding: 16px 14px; vertical-align: middle; border-bottom: 1px solid var(--admin-border); font-size: 14px; transition: background-color 0.2s; }
        .admin-table tr:last-child td { border-bottom: none; }

        /* SMART ROWS */
        .admin-table tr { transition: opacity 0.3s, filter 0.3s; }
        .row-completed { opacity: 0.55; background-color: #f9fafb; filter: grayscale(30%); }
        .row-completed:hover { opacity: 1; filter: grayscale(0%); background-color: #fff; }
        
        .row-urgent-paid td:first-child { border-left: 4px solid var(--admin-success); }
        .row-urgent-paid { background-color: var(--admin-success-bg); } 
        
        .row-money-issue td:first-child { border-left: 4px solid #8b5cf6; }
        .row-money-issue { background-color: #f5f3ff; } 

        .row-shipping td:first-child { border-left: 4px solid var(--admin-info); }
        .row-action-needed td:first-child { border-left: 4px solid var(--admin-warning); } 
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
                        <div class="legend-item"><span class="legend-dot" style="background:var(--admin-success);"></span> Khách đã chuyển tiền (Cần duyệt ngay)</div>
                        <div class="legend-item"><span class="legend-dot" style="background:var(--admin-warning);"></span> Đơn COD (Chờ xác nhận)</div>
                        <div class="legend-item"><span class="legend-dot" style="background:#8b5cf6;"></span> Cần hoàn tiền gấp</div>
                        <div class="legend-item"><span class="legend-dot" style="background:var(--admin-info);"></span> Đang Ship</div>
                        <div class="legend-item" style="opacity:0.6;"><span class="legend-dot" style="background:#9ca3af;"></span> Hoàn tất / Đã hủy</div>
                    </div>
                </div>
                
                <div style="display:flex; gap:10px; flex-wrap:wrap;">
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
                                <td colspan="8" style="text-align: center; padding: 60px 20px; color: var(--admin-text-muted);">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom: 12px; color: #9ca3af;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                                    <br>Không tìm thấy đơn hàng nào.
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($orders as $order): ?>
                                <?php 
                                    $oStatus = $statusMap[$order['order_status']] ?? [$order['order_status'], 'primary'];
                                    $pStatus = $paymentMap[$order['payment_status']] ?? [$order['payment_status'], 'info'];

                                    $rowClass = '';
                                    if (in_array($order['order_status'], ['da_giao', 'da_huy', 'tra_hang']) || $order['payment_status'] === 'da_hoan_tien') {
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
                                    <td><span class="channel-pill"><?= e($order['purchase_channel']) ?></span></td>
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

<script>
// ==========================================
// Quản lý Auto-Submit Bộ lọc
// ==========================================
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
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>