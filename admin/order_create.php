<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

$pageTitle = 'Tạo đơn hàng mới';

$statusMap = order_status_options();
$paymentMap = payment_status_options();

// =========================================================================
// 1. XỬ LÝ AJAX TÌM KIẾM SẢN PHẨM & QUICK PICK
// =========================================================================
if (isset($_GET['ajax_search_product'])) {
    header('Content-Type: application/json');
    $q = trim($_GET['q'] ?? '');
    
    try {
        if ($q === '') {
            $stmt = db()->prepare("
                SELECT p.id as product_id, p.product_name, p.thumbnail,
                       v.id as variant_id, v.variant_name, v.sku, v.sale_price, v.original_price, v.color_value, v.size_value
                FROM products p
                LEFT JOIN product_variants v ON p.id = v.product_id
                WHERE p.is_active = 1
                ORDER BY p.id DESC
                LIMIT 200
            ");
            $stmt->execute();
        } else {
            $lk = "%$q%";
            $stmt = db()->prepare("
                SELECT p.id as product_id, p.product_name, p.thumbnail,
                       v.id as variant_id, v.variant_name, v.sku, v.sale_price, v.original_price, v.color_value, v.size_value
                FROM products p
                LEFT JOIN product_variants v ON p.id = v.product_id
                WHERE p.is_active = 1 AND (p.product_name LIKE ? OR v.variant_name LIKE ? OR v.sku LIKE ?)
                ORDER BY p.id DESC
                LIMIT 200
            ");
            $stmt->execute([$lk, $lk, $lk]);
        }

        $groupedProducts = [];
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $pid = (int)$row['product_id'];
            
            if (!isset($groupedProducts[$pid])) {
                $imgUrl = resolve_media_url($row['thumbnail']);
                $groupedProducts[$pid] = [
                    'product_id' => $pid,
                    'name' => trim($row['product_name']),
                    'image' => $imgUrl ?: '/assets/default-placeholder.png',
                    'variants' => []
                ];
            }
            
            if ($row['variant_id']) {
                $price = (float)($row['sale_price'] > 0 ? $row['sale_price'] : $row['original_price']);
                
                $vName = $row['variant_name'] ?: trim($row['color_value'] . ' ' . $row['size_value']);
                if (!$vName) $vName = 'Mặc định';
                if ($row['sku']) $vName .= ' (' . $row['sku'] . ')';

                $groupedProducts[$pid]['variants'][] = [
                    'variant_id' => (int)$row['variant_id'],
                    'name'       => trim($vName),
                    'color'      => trim((string)$row['color_value']),
                    'size'       => trim((string)$row['size_value']),
                    'price'      => $price
                ];
            }
        }
        
        echo json_encode(array_slice(array_values($groupedProducts), 0, 30));
    } catch (Exception $e) {
        echo json_encode([]);
    }
    exit;
}

// =========================================================================
// 2. XỬ LÝ FORM LƯU ĐƠN HÀNG 
// =========================================================================
if (is_post() && ($_POST['action'] ?? '') === 'create_order') {
    verify_csrf_or_fail();
    try {
        $orderItemsData = json_decode($_POST['order_items_json'] ?? '[]', true);
        
        if (empty($orderItemsData)) {
            throw new Exception("Vui lòng chọn ít nhất 1 sản phẩm để lên đơn!");
        }

        db()->beginTransaction();

        $orderCode = 'DH' . date('YmdHi') . rand(10, 99); 
        
        // Loại bỏ dấu chấm ngăn cách hàng nghìn trước khi ép kiểu float
        $totalAmountStr = str_replace('.', '', $_POST['total_amount'] ?? '0');
        $shippingFeeStr = str_replace('.', '', $_POST['shipping_fee'] ?? '0');
        
        $totalAmount = (float)$totalAmountStr;
        $shippingFee = (float)$shippingFeeStr;
        
        $paymentStatus = $_POST['payment_status'] ?? 'chua_thanh_toan';
        $paymentPlan = $_POST['payment_plan'] ?? 'full';
        
        $paidAmount = 0;
        if ($paymentStatus === 'da_thanh_toan') {
            $paidAmount = $totalAmount;
        } elseif ($paymentStatus === 'da_dat_coc') {
            $paidAmount = $totalAmount * 0.3; 
        }

        // Đã cập nhật thêm shipping_fee vào câu lệnh INSERT
        $stmtOrder = db()->prepare("
            INSERT INTO orders (
                order_code, contact_name, contact_phone, total_amount, shipping_fee, paid_amount, 
                payment_status, payment_plan, order_status, purchase_channel, note, customer_note, placed_at, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
        ");
        
        $stmtOrder->execute([
            $orderCode,
            trim($_POST['customer_name'] ?? ''), 
            trim($_POST['contact_phone'] ?? ''),
            $totalAmount,
            $shippingFee,
            $paidAmount,
            $paymentStatus,
            $paymentPlan,
            $_POST['order_status'] ?? 'cho_xac_nhan',
            $_POST['purchase_channel'] ?? 'web',
            trim($_POST['admin_note'] ?? ''),
            trim($_POST['customer_note'] ?? '') 
        ]);
        
        $orderId = db()->lastInsertId();

        $stmtAddress = db()->prepare("
            INSERT INTO order_addresses (
                order_id, receiver_name, receiver_phone, province_name, district_name, ward_name, address_line
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ");
        $stmtAddress->execute([
            $orderId,
            trim($_POST['customer_name'] ?? ''), 
            trim($_POST['contact_phone'] ?? ''), 
            trim($_POST['province_name'] ?? ''),
            trim($_POST['district_name'] ?? ''),
            trim($_POST['ward_name'] ?? ''),
            trim($_POST['address_line'] ?? '')
        ]);

        $stmtItem = db()->prepare("
            INSERT INTO order_items (
                order_id, product_id, variant_id, product_name_snapshot, variant_name_snapshot, 
                quantity, final_unit_price, line_total
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");

        foreach ($orderItemsData as $item) {
            $qty = max(1, (int)($item['qty'] ?? 1));
            $price = (float)($item['price'] ?? 0);
            $lineTotal = $qty * $price;

            $stmtItem->execute([
                $orderId,
                $item['product_id'] ?? null,
                $item['variant_id'] ?? null,
                $item['name'] ?? '',
                $item['variant_name'] ?? '',
                $qty,
                $price,
                $lineTotal
            ]);
        }

        db()->commit(); 

        $_SESSION['success_msg'] = "Lên đơn hàng thành công (Mã đơn: $orderCode)!";
        header('Location: ' . route_url('/admin/orders.php'));
        exit;

    } catch (Exception $e) {
        db()->rollBack(); 
        $_SESSION['error_msg'] = "Lỗi khi tạo đơn: " . $e->getMessage();
    }
}

require_once __DIR__ . '/../includes/header.php';
?>

<style>
:root {
    --admin-bg: #f8fafc;
    --admin-card: #ffffff;
    --admin-text-main: #0f172a;
    --admin-text-muted: #64748b;
    --admin-border: #e2e8f0;
    --admin-primary: #3b82f6;
    --admin-primary-hover: #2563eb;
    --admin-danger: #ef4444;
    --admin-success: #10b981;
}

body { background-color: var(--admin-bg); font-family: 'Inter', sans-serif; }

.create-order-shell { max-width: 1280px; margin: 0 auto; padding: 32px 20px; }

.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.page-title { font-size: 24px; font-weight: 800; color: var(--admin-text-main); margin: 0; }
.page-subtitle { font-size: 14px; color: var(--admin-text-muted); margin-top: 4px; }

.admin-card { background: var(--admin-card); border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -1px rgba(0,0,0,0.03); border: 1px solid var(--admin-border); padding: 24px; margin-bottom: 24px; }

.card-header { display: flex; align-items: center; gap: 10px; margin-bottom: 20px; border-bottom: 1px solid var(--admin-border); padding-bottom: 16px; }
.card-header svg { color: var(--admin-primary); width: 22px; height: 22px; }
.section-title { font-size: 18px; font-weight: 700; color: var(--admin-text-main); margin: 0; }

.form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 16px; }
.form-grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 16px; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group.full-width { grid-column: 1 / -1; }
.form-label { font-size: 13px; font-weight: 700; color: var(--admin-text-main); }
.form-control, .form-select { padding: 12px 14px; border: 1px solid #cbd5e1; border-radius: 10px; font-size: 14px; width: 100%; box-sizing: border-box; background: #fff; transition: all 0.2s;}
.form-control:focus, .form-select:focus { outline: none; border-color: var(--admin-primary); box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15); }
select.form-select { appearance: auto; -webkit-appearance: auto; cursor: pointer; }

/* CSS TÌM KIẾM */
.search-wrapper { position: relative; margin-bottom: 24px; }
.search-input-wrapper { position: relative; }
.search-input-wrapper svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94a3b8; width: 20px; height: 20px; }
.search-input-wrapper input { padding-left: 44px; height: 48px; border-radius: 12px; font-size: 15px; }

.search-dropdown { position: absolute; top: 100%; left: 0; right: 0; background: #fff; border: 1px solid var(--admin-border); border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); z-index: 100; max-height: 400px; overflow-y: auto; display: none; margin-top: 8px; padding: 16px; }

.quick-pick-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 16px; }
.quick-pick-item { border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; transition: all 0.2s; background: #fff; display: flex; flex-direction: column; }
.quick-pick-item:hover { border-color: var(--admin-primary); box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.1); transform: translateY(-3px); }
.quick-pick-img { width: 100%; aspect-ratio: 1; object-fit: cover; border-bottom: 1px solid #e2e8f0; }
.quick-pick-info { padding: 12px; flex-grow: 1; display: flex; flex-direction: column; justify-content: space-between; }
.quick-pick-name { font-size: 13px; font-weight: 700; color: var(--admin-text-main); margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.4;}
.quick-pick-price { font-size: 14px; color: var(--admin-danger); font-weight: 800; margin-bottom: 10px;}

.search-item { padding: 12px; border: 1px solid #e2e8f0; display: flex; align-items: center; gap: 16px; border-radius: 12px; margin-bottom: 10px; transition: all 0.2s;}
.search-item:hover { background: #f8fafc; border-color: var(--admin-primary); }
.search-item img { width: 56px; height: 56px; object-fit: cover; border-radius: 8px; border: 1px solid #e2e8f0;}
.search-item-info { flex: 1; display: flex; flex-direction: column; gap: 6px; }
.search-item-name { font-size: 14px; font-weight: 700; color: var(--admin-text-main); }
.search-item-price { font-size: 14px; color: var(--admin-danger); font-weight: 800; }

.variant-select-box { width: 100%; padding: 8px; font-size: 13px; border-radius: 8px; border: 1px solid #cbd5e1; margin-bottom: 10px; outline: none; background: #f8fafc; cursor: pointer; }
.variant-select-box:focus { border-color: var(--admin-primary); }

.btn-add-cart, .btn-add-cart-list { background: var(--admin-primary); color: #fff; border: none; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 6px;}
.btn-add-cart { width: 100%; padding: 8px; font-size: 13px;}
.btn-add-cart-list { padding: 10px 20px; font-size: 14px; }
.btn-add-cart:hover, .btn-add-cart-list:hover { background: var(--admin-primary-hover); transform: scale(1.02); }

/* Bảng giỏ hàng */
.mini-cart-table { width: 100%; border-collapse: collapse; }
.mini-cart-table th { background: #f8fafc; padding: 14px; text-align: left; font-size: 12px; font-weight: 800; text-transform: uppercase; color: var(--admin-text-muted); border-bottom: 2px solid var(--admin-border); }
.mini-cart-table td { padding: 16px 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
.qty-input { width: 64px; padding: 8px; text-align: center; border: 1px solid #cbd5e1; border-radius: 8px; font-weight: 700; font-size: 14px;}
.cart-variant-select { padding: 6px 8px; font-size: 12px; border-radius: 6px; border: 1px solid #cbd5e1; background: #fff; width: 100%; outline: none; cursor: pointer;}
.btn-remove { background: #fef2f2; color: #ef4444; border: 1px solid #fecaca; padding: 8px 12px; border-radius: 8px; cursor: pointer; font-weight: 700; transition: 0.2s;}
.btn-remove:hover { background: #fee2e2; }

/* Các nút Thanh Toán */
.payment-methods { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.payment-card { border: 2px solid #e2e8f0; border-radius: 12px; padding: 14px; cursor: pointer; background: #fff; transition: all 0.2s ease; display: flex; flex-direction: column; gap: 6px; position: relative;}
.payment-card:hover { border-color: #cbd5e1; background: #f8fafc; }
.payment-card.active { border-color: var(--admin-primary); background: #eff6ff; }
.payment-card-title { font-size: 14px; font-weight: 700; color: var(--admin-text-main); }
.payment-card.active .payment-card-title { color: #1d4ed8; }
.payment-card-desc { font-size: 12px; color: var(--admin-text-muted); line-height: 1.4; }

.btn-primary { background: var(--admin-primary); color: #fff; border: none; padding: 14px 28px; border-radius: 12px; font-size: 16px; font-weight: 800; cursor: pointer; transition: 0.2s; width: 100%; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 4px 6px rgba(59,130,246,0.2);}
.btn-primary:hover { background: var(--admin-primary-hover); transform: translateY(-2px); box-shadow: 0 6px 12px rgba(59,130,246,0.3);}
.btn-secondary { background: #fff; color: var(--admin-text-main); border: 1px solid #cbd5e1; padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; transition: 0.2s; box-shadow: 0 1px 2px rgba(0,0,0,0.05);}
.btn-secondary:hover { background: #f8fafc; border-color: #94a3b8; }

.total-amount-box { background: #f0fdf4; border: 1px dashed #22c55e; border-radius: 12px; padding: 16px; text-align: center; margin-bottom: 20px;}
.total-amount-box label { display: block; font-size: 13px; color: #166534; font-weight: 700; margin-bottom: 8px; text-transform: uppercase; }
.total-amount-box input { background: transparent; border: none; font-size: 28px; font-weight: 800; color: #15803d; text-align: center; width: 100%; outline: none; }

@media (min-width: 1024px) {
    .create-layout { display: grid; grid-template-columns: 1.8fr 1fr; gap: 24px; align-items: start; }
}
</style>

<div class="create-order-shell">
    <div class="page-header">
        <div>
            <h1 class="page-title">Tạo đơn hàng thủ công</h1>
            <p class="page-subtitle">Thêm sản phẩm, nhập thông tin và ghi nhận đơn hàng mới.</p>
        </div>
        <a href="<?= route_url('/admin/orders.php') ?>" class="btn-secondary">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
            Quay lại
        </a>
    </div>

    <?php if (isset($_SESSION['error_msg'])): ?>
        <div style="padding:16px; background:#fef2f2; color:#ef4444; border:1px solid #fecaca; border-radius:12px; margin-bottom:24px; font-weight:600;">
            <?= e($_SESSION['error_msg']); unset($_SESSION['error_msg']); ?>
        </div>
    <?php endif; ?>

    <form method="post" id="createOrderForm" onsubmit="return validateForm()">
        <?= csrf_field() ?>
        <input type="hidden" name="action" value="create_order">
        <input type="hidden" name="order_items_json" id="orderItemsJson">

        <div class="create-layout">
            <div class="layout-left">
                <div class="admin-card" style="overflow: visible;">
                    <div class="card-header">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>
                        <h2 class="section-title">Chọn Sản Phẩm</h2>
                    </div>
                    
                    <div class="search-wrapper">
                        <div class="search-input-wrapper">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                            <input type="text" id="searchProductInput" class="form-control" placeholder="Tìm kiếm theo tên, mã SKU để thêm..." autocomplete="off">
                        </div>
                        <div id="searchDropdown" class="search-dropdown"></div>
                    </div>

                    <div style="border: 1px solid var(--admin-border); border-radius: 12px; overflow-x: auto;">
                        <table class="mini-cart-table">
                            <thead>
                                <tr>
                                    <th>Sản phẩm</th>
                                    <th style="width: 90px; text-align: center;">SL</th>
                                    <th style="text-align: right;">Đơn giá</th>
                                    <th style="text-align: right;">Thành tiền</th>
                                    <th style="width: 60px; text-align: center;">Xóa</th>
                                </tr>
                            </thead>
                            <tbody id="cartBody">
                                <tr id="emptyRow"><td colspan="5" style="text-align:center; color:var(--admin-text-muted); padding:40px; font-size: 14px;">Chưa chọn sản phẩm nào vào giỏ hàng</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="admin-card">
                    <div class="card-header">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                        <h2 class="section-title">Khách hàng & Giao hàng</h2>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Tên người nhận <span style="color:var(--admin-danger);">*</span></label>
                            <input type="text" name="customer_name" class="form-control" placeholder="Nhập họ và tên..." required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Số điện thoại <span style="color:var(--admin-danger);">*</span></label>
                            <input type="tel" name="contact_phone" class="form-control" placeholder="Nhập SĐT..." required>
                        </div>
                    </div>

                    <div class="form-grid-3">
                        <div class="form-group">
                            <label class="form-label">Tỉnh / Thành phố <span style="color:var(--admin-danger);">*</span></label>
                            <select class="form-select" name="province_name" id="province_select" required>
                                <option value="">-- Chọn --</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Quận / Huyện <span style="color:var(--admin-danger);">*</span></label>
                            <select class="form-select" name="district_name" id="district_select" required disabled>
                                <option value="">-- Chọn --</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Phường / Xã <span style="color:var(--admin-danger);">*</span></label>
                            <select class="form-select" name="ward_name" id="ward_select" required disabled>
                                <option value="">-- Chọn --</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group full-width" style="margin-bottom: 16px;">
                        <label class="form-label">Số nhà, Tên đường <span style="color:var(--admin-danger);">*</span></label>
                        <input type="text" name="address_line" class="form-control" placeholder="Ví dụ: Số 12, Ngõ 34..." required>
                    </div>

                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label">Yêu cầu từ khách hàng</label>
                        <textarea name="customer_note" class="form-control" style="min-height: 80px;" placeholder="Ví dụ: Gọi trước khi giao, giao trong giờ hành chính..."></textarea>
                    </div>
                </div>
            </div>

            <div class="layout-right">
                <div class="admin-card">
                    <div class="card-header">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
                        <h2 class="section-title">Thanh toán & Phân loại</h2>
                    </div>

                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label">Phí vận chuyển (VNĐ)</label>
                        <input type="text" id="shippingFeeInput" name="shipping_fee" class="form-control" value="0" style="font-weight: 700; color: var(--admin-primary);">
                    </div>

                    <div class="total-amount-box">
                        <label>TỔNG TIỀN THU (VNĐ)</label>
                        <input type="text" id="totalAmountInput" name="total_amount" required value="0">
                    </div>

                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label">Phương thức thanh toán</label>
                        <input type="hidden" name="payment_plan" id="payment_plan_input" value="full">
                        <div class="payment-methods">
                            <div class="payment-card active" data-value="full">
                                <div class="payment-card-title">💳 Thanh toán toàn bộ</div>
                                <div class="payment-card-desc">Thu tiền 100% giá trị đơn hàng.</div>
                            </div>
                            <div class="payment-card" data-value="deposit_30">
                                <div class="payment-card-title">💸 Chuyển khoản cọc</div>
                                <div class="payment-card-desc">Cọc trước <?= (int)shop_deposit_rate() ?>%, còn lại trả sau (COD).</div>
                            </div>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label">Trạng thái thanh toán</label>
                        <select name="payment_status" class="form-select">
                            <?php foreach ($paymentMap as $key => $val): ?>
                                <option value="<?= e($key) ?>" <?= $key === 'chua_thanh_toan' ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label">Trạng thái xử lý</label>
                        <select name="order_status" class="form-select">
                            <?php foreach ($statusMap as $key => $val): ?>
                                <option value="<?= e($key) ?>" <?= $key === 'cho_xac_nhan' ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label">Nguồn đơn (Kênh bán)</label>
                        <select name="purchase_channel" class="form-select">
                            <option value="web" selected>Website</option>
                            <option value="offline">Tại cửa hàng</option>
                            <option value="facebook">Facebook / Messenger</option>
                            <option value="zalo">Zalo</option>
                            <option value="phone">Điện thoại</option>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label">Ghi chú nội bộ (Chỉ Admin thấy)</label>
                        <textarea name="admin_note" class="form-control" style="min-height: 100px;" placeholder="Lưu ý nội bộ cho đơn hàng này..."></textarea>
                    </div>

                    <div style="margin-top: 24px;">
                        <button type="submit" class="btn-primary" id="btnSubmit">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                            Tạo Đơn Hàng Mới
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

<script>
// =========================================================================
// 0. FORMAT TIỀN TỆ (THÊM DẤU CHẤM HÀNG NGHÌN)
// =========================================================================
const shippingInput = document.getElementById('shippingFeeInput');
const totalInput = document.getElementById('totalAmountInput');

function formatCurrencyInput(input) {
    let val = input.value.replace(/[^0-9]/g, '');
    if (val === '') val = '0';
    input.value = new Intl.NumberFormat('vi-VN').format(parseInt(val));
}

function getNumericValue(input) {
    let val = input.value.replace(/[^0-9]/g, '');
    return parseInt(val) || 0;
}

shippingInput.addEventListener('input', function() {
    formatCurrencyInput(this);
    calculateGrandTotal();
});

totalInput.addEventListener('input', function() {
    formatCurrencyInput(this);
});

function calculateGrandTotal() {
    if (selectedItems.length === 0) {
        totalInput.value = '0';
        return;
    }
    let itemsTotal = 0;
    selectedItems.forEach(item => {
        itemsTotal += item.price * item.qty;
    });
    let shipFee = getNumericValue(shippingInput);
    let finalTotal = itemsTotal + shipFee;
    totalInput.value = new Intl.NumberFormat('vi-VN').format(finalTotal);
}

// =========================================================================
// 1. GIAO DIỆN CHỌN PHƯƠNG THỨC THANH TOÁN (PAYMENT PLAN)
// =========================================================================
const paymentCards = document.querySelectorAll('.payment-card');
const paymentInput = document.getElementById('payment_plan_input');

paymentCards.forEach(card => {
    card.addEventListener('click', function() {
        paymentCards.forEach(c => c.classList.remove('active'));
        this.classList.add('active');
        paymentInput.value = this.dataset.value;
    });
});

// =========================================================================
// 2. HỆ THỐNG SELECT ĐỊA GIỚI HÀNH CHÍNH VIỆT NAM (ESGOO API)
// =========================================================================
$(document).ready(function() {
    $.getJSON('https://esgoo.net/api-tinhthanh/1/0.htm', function(data_tinh) {
        if (data_tinh.error === 0) {
            $("#province_select").html('<option value="">-- Chọn Tỉnh/Thành --</option>');
            $.each(data_tinh.data, function (key, val) {
                $("#province_select").append('<option value="'+val.full_name+'" data-id="'+val.id+'">'+val.full_name+'</option>');
            });
        }
    });

    $("#province_select").change(function() {
        var idtinh = $(this).find(':selected').data('id');
        $("#district_select").html('<option value="">-- Đang tải... --</option>');
        $("#ward_select").html('<option value="">-- Chọn Phường/Xã --</option>');
        
        if (idtinh) {
            $.getJSON('https://esgoo.net/api-tinhthanh/2/'+idtinh+'.htm', function(data_quan) {
                if (data_quan.error === 0) {
                    $("#district_select").html('<option value="">-- Chọn Quận/Huyện --</option>');
                    $.each(data_quan.data, function (key, val) {
                        $("#district_select").append('<option value="'+val.full_name+'" data-id="'+val.id+'">'+val.full_name+'</option>');
                    });
                    $("#district_select").prop('disabled', false);
                }
            });
        } else {
            $("#district_select").prop('disabled', true);
            $("#ward_select").prop('disabled', true);
        }
    });

    $("#district_select").change(function() {
        var idquan = $(this).find(':selected').data('id');
        $("#ward_select").html('<option value="">-- Đang tải... --</option>');
        if (idquan) {
            $.getJSON('https://esgoo.net/api-tinhthanh/3/'+idquan+'.htm', function(data_phuong) {
                if (data_phuong.error === 0) {
                    $("#ward_select").html('<option value="">-- Chọn Phường/Xã --</option>');
                    $.each(data_phuong.data, function (key, val) {
                        $("#ward_select").append('<option value="'+val.full_name+'">'+val.full_name+'</option>');
                    });
                    $("#ward_select").prop('disabled', false);
                }
            });
        } else {
            $("#ward_select").prop('disabled', true);
        }
    });
});

// =========================================================================
// 3. HỆ THỐNG TÌM KIẾM GOM NHÓM & GIỎ HÀNG 
// =========================================================================
let selectedItems = [];
let currentLoadedProducts = [];

const searchInput = document.getElementById('searchProductInput');
const searchDropdown = document.getElementById('searchDropdown');
const cartBody = document.getElementById('cartBody');
const jsonInput = document.getElementById('orderItemsJson');
let searchTimeout;

function buildProductHTML(item, isGrid) {
    if (!item.variants || item.variants.length === 0) return '';
    
    let variantHtml = '';
    if (item.variants.length === 1) {
        let v = item.variants[0];
        variantHtml = `
            <div class="${isGrid ? 'quick-pick-price' : 'search-item-price'}">${new Intl.NumberFormat('vi-VN').format(v.price)}đ</div>
            <input type="hidden" class="variant-select-hidden" value="${v.variant_id}">
        `;
    } else {
        let options = item.variants.map(v => `<option value="${v.variant_id}">${v.name} - ${new Intl.NumberFormat('vi-VN').format(v.price)}đ</option>`).join('');
        variantHtml = `
            <select class="variant-select-box" onclick="event.stopPropagation()">
                ${options}
            </select>
        `;
    }

    if (isGrid) {
        return `
            <div class="quick-pick-item product-item-wrapper">
                <img src="${item.image}" onerror="this.src='/assets/default-placeholder.png'" class="quick-pick-img">
                <div class="quick-pick-info">
                    <div class="quick-pick-name" title="${item.name}">${item.name}</div>
                    <div>
                        ${variantHtml}
                        <button type="button" class="btn-add-cart" onclick="triggerAddProduct(this, ${item.product_id}, event)">
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                            Thêm
                        </button>
                    </div>
                </div>
            </div>
        `;
    } else {
        return `
            <div class="search-item product-item-wrapper">
                <img src="${item.image}" onerror="this.src='/assets/default-placeholder.png'">
                <div class="search-item-info">
                    <div class="search-item-name">${item.name}</div>
                    ${variantHtml}
                </div>
                <button type="button" class="btn-add-cart-list" onclick="triggerAddProduct(this, ${item.product_id}, event)">
                    Thêm SP
                </button>
            </div>
        `;
    }
}

function fetchProducts(q) {
    fetch(`?ajax_search_product=1&q=${encodeURIComponent(q)}`)
        .then(res => res.json())
        .then(data => {
            currentLoadedProducts = data; 
            searchDropdown.innerHTML = '';
            
            if(data.length === 0) {
                searchDropdown.innerHTML = '<div style="padding:20px; text-align:center; color:var(--admin-text-muted); font-weight:600;">Không tìm thấy sản phẩm nào</div>';
                searchDropdown.style.display = 'block';
                return;
            }

            if (q === '') {
                const title = document.createElement('div');
                title.style.cssText = "font-size:12px; font-weight:800; color:var(--admin-text-muted); margin-bottom:16px; text-transform:uppercase; letter-spacing:0.5px;";
                title.textContent = "Sản phẩm gợi ý";
                searchDropdown.appendChild(title);

                const gridDiv = document.createElement('div');
                gridDiv.className = 'quick-pick-grid';
                data.forEach(item => {
                    gridDiv.innerHTML += buildProductHTML(item, true);
                });
                searchDropdown.appendChild(gridDiv);
            } 
            else {
                data.forEach(item => {
                    searchDropdown.innerHTML += buildProductHTML(item, false);
                });
            }
            
            searchDropdown.style.display = 'block';
        });
}

searchInput.addEventListener('focus', function() {
    if (this.value.trim() === '') fetchProducts('');
});

searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    const q = this.value.trim();
    if (q.length === 1) { searchDropdown.style.display = 'none'; return; }
    
    searchTimeout = setTimeout(() => {
        fetchProducts(q);
    }, 300);
});

document.addEventListener('click', (e) => {
    if (!searchInput.contains(e.target) && !searchDropdown.contains(e.target)) {
        searchDropdown.style.display = 'none';
    }
});

window.triggerAddProduct = function(btnElement, productId, event) {
    if(event) event.stopPropagation(); 
    
    const wrapper = btnElement.closest('.product-item-wrapper');
    if (!wrapper) return;

    const product = currentLoadedProducts.find(p => p.product_id == productId);
    if (!product) {
        alert("Không tải được dữ liệu sản phẩm, vui lòng thử lại.");
        return;
    }

    let variantId;
    const selectEl = wrapper.querySelector('.variant-select-box');
    const hiddenEl = wrapper.querySelector('.variant-select-hidden');
    
    if (selectEl) {
        variantId = selectEl.value;
    } else if (hiddenEl) {
        variantId = hiddenEl.value;
    }

    if (!variantId) {
        alert("Vui lòng chọn phân loại!");
        return;
    }

    const variant = product.variants.find(v => v.variant_id == variantId);
    if (variant) {
        const cartItem = {
            product_id: product.product_id,
            variant_id: variant.variant_id,
            name: product.name,
            variant_name: variant.name, 
            color: variant.color,
            size: variant.size,
            price: variant.price,
            image: product.image,
            available_variants: product.variants 
        };
        
        addItemToCart(cartItem);
    }
}

function addItemToCart(item) {
    searchDropdown.style.display = 'none';
    searchInput.value = '';
    
    const existingIndex = selectedItems.findIndex(i => i.variant_id == item.variant_id && i.product_id == item.product_id);
    if (existingIndex > -1) {
        selectedItems[existingIndex].qty += 1;
    } else {
        selectedItems.push({ ...item, qty: 1 });
    }
    renderCart();
}

window.updateItemQty = function(index, newQty) {
    newQty = parseInt(newQty);
    if (newQty < 1) newQty = 1;
    selectedItems[index].qty = newQty;
    renderCart();
};

// Cập nhật khi chọn MÀU trong giỏ
window.changeCartColor = function(index, newColor) {
    const item = selectedItems[index];
    const newVariant = item.available_variants.find(v => v.color === newColor);
    
    if (newVariant) {
        item.color = newVariant.color;
        item.size = newVariant.size;
        item.variant_id = newVariant.variant_id;
        item.variant_name = newVariant.name;
        item.price = newVariant.price;
        
        mergeDuplicateItem(index);
        renderCart();
    }
};

// Cập nhật khi chọn SIZE trong giỏ
window.changeCartSize = function(index, newSize) {
    const item = selectedItems[index];
    const newVariant = item.available_variants.find(v => v.color === item.color && v.size === newSize);
    
    if (newVariant) {
        item.size = newVariant.size;
        item.variant_id = newVariant.variant_id;
        item.variant_name = newVariant.name;
        item.price = newVariant.price;
        
        mergeDuplicateItem(index);
        renderCart();
    }
};

// Gộp các sản phẩm giống nhau
function mergeDuplicateItem(index) {
    const item = selectedItems[index];
    const duplicateIndex = selectedItems.findIndex((i, idx) => i.variant_id == item.variant_id && i.product_id == item.product_id && idx !== index);
    
    if (duplicateIndex > -1) {
        selectedItems[duplicateIndex].qty += item.qty; 
        selectedItems.splice(index, 1); 
    }
}

// Cập nhật theo variant duy nhất
window.changeCartVariant = function(index, newVariantId) {
    const item = selectedItems[index];
    const newVariant = item.available_variants.find(v => v.variant_id == newVariantId);
    
    if (newVariant) {
        item.variant_id = newVariant.variant_id;
        item.variant_name = newVariant.name;
        item.price = newVariant.price;
        
        mergeDuplicateItem(index);
        renderCart();
    }
};

window.removeItem = function(index) {
    selectedItems.splice(index, 1);
    renderCart();
};

function renderCart() {
    if (selectedItems.length === 0) {
        cartBody.innerHTML = '<tr id="emptyRow"><td colspan="5" style="text-align:center; color:var(--admin-text-muted); padding:40px; font-size:14px;">Chưa chọn sản phẩm nào vào giỏ hàng</td></tr>';
        totalInput.value = '0';
        jsonInput.value = '[]';
        return;
    }
    
    let html = '';
    
    selectedItems.forEach((item, index) => {
        const lineTotal = item.price * item.qty;

        let variantHtml = '';
        if (item.available_variants && item.available_variants.length > 1) {
            let colors = [...new Set(item.available_variants.map(v => v.color).filter(c => c))];
            
            if (colors.length > 0) {
                let colorOptions = colors.map(c => `<option value="${c}" ${c === item.color ? 'selected' : ''}>Màu: ${c}</option>`).join('');
                
                let sizesForColor = [...new Set(item.available_variants.filter(v => v.color === item.color).map(v => v.size).filter(s => s))];
                let sizeOptions = sizesForColor.map(s => `<option value="${s}" ${s === item.size ? 'selected' : ''}>Size: ${s}</option>`).join('');
                
                variantHtml = `
                    <div style="display:flex; gap:8px; margin-top:6px;">
                        <select class="cart-variant-select" onchange="changeCartColor(${index}, this.value)" style="margin-top:0; min-width: 100px;">
                            ${colorOptions}
                        </select>
                        ${sizesForColor.length > 0 ? `
                        <select class="cart-variant-select" onchange="changeCartSize(${index}, this.value)" style="margin-top:0; min-width: 80px;">
                            ${sizeOptions}
                        </select>
                        ` : ''}
                    </div>
                `;
            } else {
                let options = item.available_variants.map(v => 
                    `<option value="${v.variant_id}" ${v.variant_id == item.variant_id ? 'selected' : ''}>${v.name}</option>`
                ).join('');
                variantHtml = `<select class="cart-variant-select" onchange="changeCartVariant(${index}, this.value)">${options}</select>`;
            }
        } else {
            variantHtml = `<div style="font-size: 13px; color: var(--admin-text-muted); margin-top: 6px; font-weight: 500;">Phân loại: ${item.variant_name}</div>`;
        }

        html += `
            <tr>
                <td>
                    <div style="display:flex; align-items:center; gap:12px;">
                        <img src="${item.image}" onerror="this.src='/assets/default-placeholder.png'" style="width:56px; height:56px; border-radius:8px; object-fit:cover; border: 1px solid #e2e8f0; flex-shrink:0;">
                        <div style="flex:1;">
                            <div style="font-weight:700; font-size:14px; color:var(--admin-text-main); margin-bottom:2px;">${item.name}</div>
                            ${variantHtml}
                        </div>
                    </div>
                </td>
                <td style="text-align:center; vertical-align:middle;">
                    <input type="number" class="qty-input" min="1" value="${item.qty}" onchange="updateItemQty(${index}, this.value)">
                </td>
                <td style="text-align:right; vertical-align:middle; font-size:14px; font-weight:600; color:var(--admin-text-muted);">${new Intl.NumberFormat('vi-VN').format(item.price)}đ</td>
                <td style="text-align:right; vertical-align:middle; font-weight:800; font-size:15px; color:var(--admin-danger);">${new Intl.NumberFormat('vi-VN').format(lineTotal)}đ</td>
                <td style="text-align:center; vertical-align:middle;">
                    <button type="button" class="btn-remove" onclick="removeItem(${index})" title="Xóa">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                    </button>
                </td>
            </tr>
        `;
    });
    
    cartBody.innerHTML = html;
    jsonInput.value = JSON.stringify(selectedItems);
    
    // Gọi tính tổng cuối cùng (bao gồm cả phí ship)
    calculateGrandTotal();
}

function validateForm() {
    if (selectedItems.length === 0) {
        alert("Vui lòng chọn ít nhất 1 sản phẩm vào giỏ!");
        return false;
    }
    
    const btn = document.getElementById('btnSubmit');
    btn.innerHTML = 'Đang xử lý...';
    btn.disabled = true;
    btn.style.opacity = '0.7';

    return true;
}
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>