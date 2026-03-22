<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

$pageTitle = 'Thống kê & Báo cáo';

// 1. Xử lý tham số bộ lọc thời gian
$timeRange = $_GET['time_range'] ?? 'month';
$customDate = $_GET['custom_date'] ?? date('Y-m-d');
$monthVal = $_GET['month_val'] ?? date('Y-m');

$startDate = '';
$endDate = '';
$displayTitle = '';

switch ($timeRange) {
    case 'today':
        $startDate = date('Y-m-d 00:00:00');
        $endDate = date('Y-m-d 23:59:59');
        $displayTitle = 'Hôm nay (' . date('d/m/Y') . ')';
        break;
    case 'yesterday':
        $yesterday = date('Y-m-d', strtotime('-1 day'));
        $startDate = $yesterday . ' 00:00:00';
        $endDate = $yesterday . ' 23:59:59';
        $displayTitle = 'Hôm qua (' . date('d/m/Y', strtotime('-1 day')) . ')';
        break;
    case 'custom':
        $startDate = $customDate . ' 00:00:00';
        $endDate = $customDate . ' 23:59:59';
        $displayTitle = 'Ngày ' . date('d/m/Y', strtotime($customDate));
        break;
    default: // month
        $startDate = $monthVal . '-01 00:00:00';
        $endDate = date('Y-m-t 23:59:59', strtotime($startDate));
        $displayTitle = 'Tháng ' . date('m/Y', strtotime($startDate));
        break;
}

// 2. Truy vấn Tổng quan (Chỉ tính đơn đã thanh toán hoặc đã cọc)
$stmtOverview = db()->prepare("
    SELECT 
        COUNT(id) as total_orders,
        SUM(total_amount) as total_revenue,
        SUM(shipping_fee) as total_shipping
    FROM orders
    WHERE order_status NOT IN ('da_huy', 'tra_hang')
    AND payment_status IN ('da_thanh_toan', 'da_dat_coc')
    AND placed_at BETWEEN ? AND ?
");
$stmtOverview->execute([$startDate, $endDate]);
$overview = $stmtOverview->fetch(PDO::FETCH_ASSOC);

$totalOrders = (int)($overview['total_orders'] ?? 0);
$totalRevenue = (float)($overview['total_revenue'] ?? 0);
$totalShipping = (float)($overview['total_shipping'] ?? 0);

// 3. Tính Tổng Vốn & Tiền Lãi (Chỉ tính đơn đã thanh toán hoặc đã cọc)
$stmtCost = db()->prepare("
    SELECT oi.quantity, p.purchase_price
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.id
    LEFT JOIN products p ON oi.product_id = p.id
    WHERE o.order_status NOT IN ('da_huy', 'tra_hang')
    AND o.payment_status IN ('da_thanh_toan', 'da_dat_coc')
    AND o.placed_at BETWEEN ? AND ?
");
$stmtCost->execute([$startDate, $endDate]);
$itemsForCost = $stmtCost->fetchAll();

$totalCost = 0;
foreach ($itemsForCost as $item) {
    $itemPurchasePrice = (float)($item['purchase_price'] ?? 0);
    $qty = (int)($item['quantity'] ?? 1);
    $totalCost += ($itemPurchasePrice * $qty);
}
$totalProfit = $totalRevenue - $totalCost - $totalShipping;

// 4. Dữ liệu cho Biểu đồ (Chart.js) (Chỉ tính đơn đã thanh toán hoặc đã cọc)
$isDaily = ($timeRange === 'month');
if ($isDaily) {
    $stmtChart = db()->prepare("
        SELECT DATE(placed_at) as label, SUM(total_amount) as revenue
        FROM orders
        WHERE order_status NOT IN ('da_huy', 'tra_hang') 
        AND payment_status IN ('da_thanh_toan', 'da_dat_coc')
        AND placed_at BETWEEN ? AND ?
        GROUP BY DATE(placed_at) ORDER BY DATE(placed_at) ASC
    ");
} else {
    $stmtChart = db()->prepare("
        SELECT HOUR(placed_at) as label, SUM(total_amount) as revenue
        FROM orders
        WHERE order_status NOT IN ('da_huy', 'tra_hang') 
        AND payment_status IN ('da_thanh_toan', 'da_dat_coc')
        AND placed_at BETWEEN ? AND ?
        GROUP BY HOUR(placed_at) ORDER BY HOUR(placed_at) ASC
    ");
}
$stmtChart->execute([$startDate, $endDate]);
$rawChartData = $stmtChart->fetchAll(PDO::FETCH_ASSOC);

$chartLabels = [];
$chartRevenues = [];

if ($isDaily) {
    $start = new DateTime(substr($startDate, 0, 10));
    $end = new DateTime(substr($endDate, 0, 10));
    $today = new DateTime();
    if ($end > $today && $monthVal == date('Y-m')) $end = $today; // Chặn mốc tương lai

    $interval = new DateInterval('P1D');
    $period = new DatePeriod($start, $interval, $end->modify('+1 day'));
    
    $dataMap = [];
    foreach($rawChartData as $row) $dataMap[$row['label']] = (float)$row['revenue'];
    
    foreach($period as $date) {
        $dateStr = $date->format('Y-m-d');
        $chartLabels[] = $date->format('d/m');
        $chartRevenues[] = $dataMap[$dateStr] ?? 0;
    }
} else {
    $dataMap = [];
    foreach($rawChartData as $row) $dataMap[(int)$row['label']] = (float)$row['revenue'];
    
    for ($i = 0; $i <= 23; $i++) {
        $chartLabels[] = str_pad($i, 2, '0', STR_PAD_LEFT) . ':00';
        $chartRevenues[] = $dataMap[$i] ?? 0;
    }
}

// 5. Top Sản Phẩm (Chỉ tính đơn đã thanh toán hoặc đã cọc)
$stmtTopProducts = db()->prepare("
    SELECT 
        p.id, p.product_name, p.product_code, p.thumbnail,
        SUM(oi.quantity) as total_sold
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.id
    JOIN products p ON oi.product_id = p.id
    WHERE o.order_status NOT IN ('da_huy', 'tra_hang') 
    AND o.payment_status IN ('da_thanh_toan', 'da_dat_coc')
    AND o.placed_at BETWEEN ? AND ?
    GROUP BY p.id ORDER BY total_sold DESC LIMIT 7
");
$stmtTopProducts->execute([$startDate, $endDate]);
$topProducts = $stmtTopProducts->fetchAll();

?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($pageTitle) ?></title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --admin-bg: #f8fafc; --admin-card: #ffffff; --admin-text-main: #0f172a; --admin-text-muted: #64748b;
            --admin-border: #e2e8f0; --admin-primary: #4f46e5; --admin-primary-hover: #4338ca;
            --admin-success: #10b981; --admin-danger: #ef4444; --admin-warning: #f59e0b; --admin-info: #0ea5e9;
            --sidebar-width: 260px;
        }
        * { box-sizing: border-box; }
        body { background-color: var(--admin-bg); color: var(--admin-text-main); font-family: 'Inter', sans-serif; margin: 0; padding: 0; }
        .admin-wrapper { display: flex; min-height: 100vh; }
        .admin-sidebar { width: var(--sidebar-width); background: var(--admin-card); border-right: 1px solid var(--admin-border); flex-shrink: 0; position: sticky; top: 0; height: 100vh; }
        .sidebar-header { padding: 24px; display: flex; align-items: center; gap: 12px; }
        .sidebar-header h2 { font-size: 22px; font-weight: 800; margin: 0; color: var(--admin-primary); letter-spacing: -0.5px;}
        .sidebar-menu { list-style: none; padding: 0 16px; margin: 0; }
        .sidebar-menu a { display: flex; align-items: center; gap: 12px; padding: 12px 16px; color: var(--admin-text-muted); text-decoration: none; font-size: 14.5px; font-weight: 500; border-radius: 10px; transition: 0.2s; margin-bottom: 4px; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background-color: #eef2ff; color: var(--admin-primary); font-weight: 600; }
        .admin-main { flex-grow: 1; padding: 32px; overflow-x: hidden; }
        
        .admin-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 32px; flex-wrap: wrap; gap: 16px;}
        .admin-header h1 { font-size: 28px; font-weight: 800; margin: 0 0 4px 0; letter-spacing: -0.02em; }
        .admin-header p { color: var(--admin-text-muted); font-size: 15px; margin: 0; }
        
        /* UI BUTTON GROUPS CHO FILTER */
        .filter-container { background: #fff; padding: 6px; border-radius: 12px; border: 1px solid var(--admin-border); box-shadow: 0 2px 4px rgba(0,0,0,0.02); display: inline-flex; flex-wrap: wrap; gap: 4px;}
        .filter-btn { padding: 10px 20px; border-radius: 8px; font-size: 14px; font-weight: 600; color: var(--admin-text-muted); cursor: pointer; transition: all 0.2s; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
        .filter-btn:hover { background: #f1f5f9; color: var(--admin-text-main); }
        .filter-btn.active { background: var(--admin-primary); color: #fff; box-shadow: 0 4px 10px rgba(79, 70, 229, 0.2); }

        .input-controls { display: flex; align-items: center; gap: 12px; margin-top: 16px; }
        .form-input { padding: 10px 14px; border: 1px solid var(--admin-border); border-radius: 8px; font-family: inherit; font-weight: 600; color: var(--admin-text-main); outline: none; background: #fff;}
        .form-input:focus { border-color: var(--admin-primary); }
        .btn-submit { background: var(--admin-text-main); color: #fff; border: none; padding: 0 20px; border-radius: 8px; font-weight: 600; cursor: pointer; height: 42px; transition: 0.2s;}
        .btn-submit:hover { background: #334155; }

        /* GRADIENT CARDS */
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 32px; }
        .stat-card { padding: 24px; border-radius: 20px; color: #fff; position: relative; overflow: hidden; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1); display: flex; flex-direction: column; justify-content: space-between; min-height: 140px;}
        .stat-card::after { content: ''; position: absolute; top: -50px; right: -20px; width: 120px; height: 120px; background: rgba(255,255,255,0.1); border-radius: 50%; }
        .card-orders { background: linear-gradient(135deg, #6366f1 0%, #4338ca 100%); }
        .card-revenue { background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%); }
        .card-profit { background: linear-gradient(135deg, #10b981 0%, #059669 100%); }
        .card-loss { background: linear-gradient(135deg, #f43f5e 0%, #be123c 100%); }
        
        .stat-top { display: flex; justify-content: space-between; align-items: flex-start; position: relative; z-index: 2;}
        .stat-label { font-size: 15px; font-weight: 600; opacity: 0.9; text-transform: uppercase; letter-spacing: 0.5px;}
        .stat-icon { background: rgba(255,255,255,0.2); padding: 10px; border-radius: 12px; backdrop-filter: blur(4px); }
        .stat-value { font-size: 32px; font-weight: 800; margin-top: 16px; position: relative; z-index: 2;}

        /* BỐ CỤC 2 CỘT (CHART & TOP) */
        .dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; }
        .panel { background: #fff; border-radius: 20px; border: 1px solid var(--admin-border); box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02); overflow: hidden; display: flex; flex-direction: column;}
        .panel-header { padding: 20px 24px; border-bottom: 1px solid var(--admin-border); font-weight: 700; font-size: 16px; display: flex; justify-content: space-between; align-items: center;}
        .panel-body { padding: 24px; flex-grow: 1;}

        /* TOP PRODUCTS TABLE */
        .admin-table { width: 100%; border-collapse: collapse; }
        .admin-table td { padding: 16px 24px; border-bottom: 1px solid var(--admin-border); }
        .admin-table tr:last-child td { border-bottom: none; }
        .admin-table tr:hover td { background-color: #f8fafc; }
        .product-info { display: flex; align-items: center; gap: 14px; }
        .product-img { width: 48px; height: 48px; border-radius: 10px; object-fit: cover; background: #f3f4f6; border: 1px solid var(--admin-border);}
        .product-link { font-weight: 600; color: var(--admin-text-main); text-decoration: none; display: block; margin-bottom: 4px; transition: 0.2s;}
        .product-link:hover { color: var(--admin-primary); }
        .product-code { font-family: monospace; font-size: 12px; color: var(--admin-text-muted); background: #f1f5f9; padding: 2px 6px; border-radius: 4px; font-weight: 600;}
        .sold-badge { background: #ecfdf5; color: #059669; padding: 6px 12px; border-radius: 8px; font-weight: 700; font-size: 14px;}

        @media (max-width: 1024px) {
            .dashboard-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: 1fr; }
            .admin-wrapper { flex-direction: column; }
            .admin-sidebar { width: 100%; height: auto; position: relative; border-bottom: 1px solid var(--admin-border);}
            .sidebar-menu { display: flex; overflow-x: auto; padding: 12px; gap: 8px; }
            .admin-main { padding: 20px; }
        }
    </style>
</head>
<body>

<div class="admin-wrapper">
    <aside class="admin-sidebar">
        <div class="sidebar-header">
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--admin-primary)"><path d="M12 2L2 7l10 5 10-5-10-5z"></path><path d="M2 17l10 5 10-5"></path><path d="M2 12l10 5 10-5"></path></svg>
            <h2>Quản lý</h2>
        </div>
        <ul class="sidebar-menu">
            <li><a href="<?= route_url('/admin/products.php') ?>"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg> Sản phẩm</a></li>
            <li><a href="<?= route_url('/admin/orders.php') ?>"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2l3 6"></path><path d="M18 2l-3 6"></path><path d="M3 10h18"></path><path d="M4 10l1 10h14l1-10"></path></svg> Đơn hàng</a></li>
            <li><a href="#" class="active"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg> Thống kê</a></li>
        </ul>
    </aside>

    <main class="admin-main">
        <div class="admin-header">
            <div>
                <h1>Dashboard Tổng Quan</h1>
                <p>Hiệu suất kinh doanh: <strong><?= e($displayTitle) ?></strong></p>
            </div>
            
            <div>
                <div class="filter-container">
                    <a href="?time_range=today" class="filter-btn <?= $timeRange === 'today' ? 'active' : '' ?>">Hôm nay</a>
                    <a href="?time_range=yesterday" class="filter-btn <?= $timeRange === 'yesterday' ? 'active' : '' ?>">Hôm qua</a>
                    <a href="?time_range=month" class="filter-btn <?= $timeRange === 'month' ? 'active' : '' ?>">Tháng này</a>
                    <a href="?time_range=custom" class="filter-btn <?= $timeRange === 'custom' ? 'active' : '' ?>">Tùy chọn</a>
                </div>

                <?php if (in_array($timeRange, ['month', 'custom'])): ?>
                <form method="GET" class="input-controls">
                    <input type="hidden" name="time_range" value="<?= e($timeRange) ?>">
                    <?php if ($timeRange === 'month'): ?>
                        <input type="month" name="month_val" class="form-input" value="<?= e($monthVal) ?>">
                    <?php else: ?>
                        <input type="date" name="custom_date" class="form-input" value="<?= e($customDate) ?>">
                    <?php endif; ?>
                    <button type="submit" class="btn-submit">Lọc</button>
                </form>
                <?php endif; ?>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card card-orders">
                <div class="stat-top">
                    <span class="stat-label">Tổng Đơn Hàng</span>
                    <div class="stat-icon"><svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path></svg></div>
                </div>
                <div class="stat-value"><?= number_format($totalOrders) ?></div>
            </div>
            
            <div class="stat-card card-revenue">
                <div class="stat-top">
                    <span class="stat-label">Doanh Thu Thực</span>
                    <div class="stat-icon"><svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg></div>
                </div>
                <div class="stat-value"><?= format_price($totalRevenue) ?></div>
            </div>
            
            <?php $isLoss = $totalProfit < 0; ?>
            <div class="stat-card <?= $isLoss ? 'card-loss' : 'card-profit' ?>">
                <div class="stat-top">
                    <span class="stat-label">Tiền Lãi (Sau phí ship)</span>
                    <div class="stat-icon">
                        <?php if ($isLoss): ?>
                            <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24"><polyline stroke-width="2" points="23 18 13.5 8.5 8.5 13.5 1 6"></polyline><polyline stroke-width="2" points="17 18 23 18 23 12"></polyline></svg>
                        <?php else: ?>
                            <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24"><polyline stroke-width="2" points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline stroke-width="2" points="17 6 23 6 23 12"></polyline></svg>
                        <?php endif; ?>
                    </div>
                </div>
                <div class="stat-value"><?= ($isLoss ? '-' : '+') . format_price(abs($totalProfit)) ?></div>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="panel">
                <div class="panel-header">
                    <span>Biểu đồ doanh thu</span>
                    <span style="font-size: 13px; font-weight: 500; color: var(--admin-text-muted); background: #f1f5f9; padding: 4px 10px; border-radius: 20px;">
                        <?= $isDaily ? 'Theo ngày' : 'Theo giờ' ?>
                    </span>
                </div>
                <div class="panel-body" style="position: relative; height: 380px; width: 100%;">
                    <canvas id="revenueChart"></canvas>
                </div>
            </div>

            <div class="panel">
                <div class="panel-header">
                    <span>Top bán chạy</span>
                </div>
                <div style="overflow-y: auto; max-height: 400px;">
                    <table class="admin-table">
                        <tbody>
                            <?php if (empty($topProducts)): ?>
                            <tr><td style="text-align:center; padding: 40px; color: var(--admin-text-muted);">Chưa có đơn hàng phát sinh.</td></tr>
                            <?php else: ?>
                                <?php foreach ($topProducts as $idx => $tp): ?>
                                <tr>
                                    <td style="padding: 12px 24px;">
                                        <div class="product-info">
                                            <div style="font-weight: 800; color: <?= $idx < 3 ? 'var(--admin-warning)' : 'var(--admin-text-muted)' ?>; font-size: 16px; min-width: 20px;">#<?= $idx + 1 ?></div>
                                            <img src="<?= e(resolve_media_url($tp['thumbnail'])) ?>" class="product-img" onerror="this.src='/assets/default-placeholder.png'">
                                            <div>
                                                <a href="<?= route_url('/admin/product_edit.php?id=' . $tp['id']) ?>" target="_blank" class="product-link">
                                                    <?= e($tp['product_name']) ?>
                                                </a>
                                                <span class="product-code"><?= e($tp['product_code']) ?></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="text-align: right; padding: 12px 24px;">
                                        <span class="sold-badge"><?= $tp['total_sold'] ?></span>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </main>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const ctx = document.getElementById('revenueChart').getContext('2d');
    
    // Tạo gradient cho biểu đồ đường
    let gradient = ctx.createLinearGradient(0, 0, 0, 400);
    gradient.addColorStop(0, 'rgba(79, 70, 229, 0.5)'); // Indigo
    gradient.addColorStop(1, 'rgba(79, 70, 229, 0.0)');

    const chartData = {
        labels: <?= json_encode($chartLabels) ?>,
        datasets: [{
            label: 'Doanh thu (VNĐ)',
            data: <?= json_encode($chartRevenues) ?>,
            borderColor: '#4f46e5',
            backgroundColor: gradient,
            borderWidth: 3,
            pointBackgroundColor: '#ffffff',
            pointBorderColor: '#4f46e5',
            pointBorderWidth: 2,
            pointRadius: 4,
            pointHoverRadius: 6,
            fill: true,
            tension: 0.4 // Làm cong đường line
        }]
    };

    new Chart(ctx, {
        type: 'line',
        data: chartData,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#111827',
                    padding: 12,
                    titleFont: { size: 14, family: 'Inter' },
                    bodyFont: { size: 14, family: 'Inter', weight: 'bold' },
                    callbacks: {
                        label: function(context) {
                            let value = context.raw || 0;
                            return ' ' + value.toLocaleString('vi-VN') + ' đ';
                        }
                    }
                }
            },
            scales: {
                x: {
                    grid: { display: false, drawBorder: false },
                    ticks: { font: { family: 'Inter' }, color: '#64748b' }
                },
                y: {
                    grid: { color: '#f1f5f9', drawBorder: false },
                    ticks: {
                        font: { family: 'Inter' }, color: '#64748b',
                        callback: function(value) {
                            if (value >= 1000000) return (value / 1000000) + ' Tr';
                            if (value >= 1000) return (value / 1000) + ' k';
                            return value;
                        }
                    }
                }
            },
            interaction: {
                intersect: false,
                mode: 'index',
            },
        }
    });
});
</script>

</body>
</html>