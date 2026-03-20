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
                    'name' => trim($vName),
                    'price' => $price
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

        // Bắt đầu Transaction
        db()->beginTransaction();

        // --- BƯỚC 1: LƯU VÀO BẢNG orders ---
        $orderCode = 'DH' . date('YmdHi') . rand(10, 99); 
        $totalAmount = (float)($_POST['total_amount'] ?? 0);
        $paymentStatus = $_POST['payment_status'] ?? 'chua_thanh_toan';
        
        // Tính tiền đã trả dựa trên trạng thái thanh toán
        $paidAmount = 0;
        if ($paymentStatus === 'da_thanh_toan') {
            $paidAmount = $totalAmount;
        } elseif ($paymentStatus === 'da_dat_coc') {
            $paidAmount = $totalAmount * 0.3; // Mặc định ghi nhận cọc 30%
        }

        $stmtOrder = db()->prepare("
            INSERT INTO orders (
                order_code, contact_name, contact_phone, total_amount, paid_amount, 
                payment_status, order_status, purchase_channel, note, customer_note, placed_at, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
        ");
        
        $stmtOrder->execute([
            $orderCode,
            trim($_POST['customer_name'] ?? ''), 
            trim($_POST['contact_phone'] ?? ''),
            $totalAmount,
            $paidAmount,
            $paymentStatus,
            $_POST['order_status'] ?? 'cho_xac_nhan',
            $_POST['purchase_channel'] ?? 'offline',
            trim($_POST['admin_note'] ?? ''),
            trim($_POST['customer_note'] ?? '') // Lưu thêm trường ghi chú của khách
        ]);
        
        $orderId = db()->lastInsertId();

        // --- BƯỚC 2: LƯU VÀO BẢNG order_addresses ---
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

        // --- BƯỚC 3: LƯU VÀO BẢNG order_items ---
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

        // Cam kết lưu dữ liệu vĩnh viễn
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
    --admin-bg: #f3f4f6;
    --admin-card: #ffffff;
    --admin-text-main: #111827;
    --admin-text-muted: #6b7280;
    --admin-border: #e5e7eb;
    --admin-primary: #4f46e5;
    --admin-danger: #ef4444;
    --admin-success: #10b981;
}

.create-order-shell { max-width: 1200px; margin: 0 auto; padding: 32px 16px; }
.admin-card { background: var(--admin-card); border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid var(--admin-border); padding: 24px; margin-bottom: 24px; }

.section-title { font-size: 18px; font-weight: 700; color: var(--admin-text-main); margin-bottom: 16px; display: flex; align-items: center; gap: 8px; border-bottom: 2px solid #eef2ff; padding-bottom: 8px; }
.form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 16px; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group.full-width { grid-column: 1 / -1; }
.form-label { font-size: 13px; font-weight: 600; color: var(--admin-text-main); }
.form-control, .form-select { padding: 10px 14px; border: 1px solid var(--admin-border); border-radius: 8px; font-size: 14px; width: 100%; box-sizing: border-box; background: #fff;}
.form-control:focus, .form-select:focus { outline: none; border-color: var(--admin-primary); box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1); }
select.form-select { appearance: auto; -webkit-appearance: auto; cursor: pointer; }

/* CSS Tìm kiếm sản phẩm */
.search-wrapper { position: relative; margin-bottom: 20px; }
.search-dropdown { position: absolute; top: 100%; left: 0; right: 0; background: #fff; border: 1px solid var(--admin-border); border-radius: 8px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); z-index: 100; max-height: 450px; overflow-y: auto; display: none; margin-top: 4px; padding: 12px; }

/* Grid cho chế độ Quick Pick */
.quick-pick-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 12px; }
.quick-pick-item { border: 1px solid #f3f4f6; border-radius: 10px; overflow: hidden; transition: all 0.2s; background: #fff; display: flex; flex-direction: column; position: relative;}
.quick-pick-item:hover { border-color: var(--admin-primary); box-shadow: 0 4px 12px rgba(79, 70, 229, 0.15); transform: translateY(-2px); }
.quick-pick-img { width: 100%; aspect-ratio: 1; object-fit: cover; border-bottom: 1px solid #f3f4f6; }
.quick-pick-info { padding: 10px; flex-grow: 1; display: flex; flex-direction: column; justify-content: space-between; }
.quick-pick-name { font-size: 12px; font-weight: 600; color: var(--admin-text-main); margin-bottom: 6px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; text-overflow: ellipsis; line-height: 1.4;}
.quick-pick-price { font-size: 13px; color: var(--admin-danger); font-weight: 700; margin-bottom: 6px;}

/* List cho chế độ Search Gõ Text */
.search-item { padding: 12px 14px; border: 1px solid #f3f4f6; display: flex; align-items: center; gap: 12px; border-radius: 8px; margin-bottom: 8px; transition: all 0.2s;}
.search-item:hover { background: #f9fafb; border-color: var(--admin-primary); }
.search-item img { width: 50px; height: 50px; object-fit: cover; border-radius: 6px; border: 1px solid #e5e7eb;}
.search-item-info { flex: 1; display: flex; flex-direction: column; gap: 4px; }
.search-item-name { font-size: 14px; font-weight: 600; color: var(--admin-text-main); margin-bottom: 6px; }
.search-item-price { font-size: 13px; color: var(--admin-danger); font-weight: 700; }

/* CSS Combo box chọn biến thể & Nút thêm */
.variant-select-box { width: 100%; padding: 6px; font-size: 12px; border-radius: 6px; border: 1px solid #d1d5db; margin-bottom: 8px; outline: none; background: #f9fafb; cursor: pointer; }
.variant-select-box:focus { border-color: var(--admin-primary); }
.btn-add-cart { width: 100%; background: var(--admin-primary); color: #fff; border: none; border-radius: 6px; padding: 6px; font-size: 12px; font-weight: 600; cursor: pointer; transition: 0.2s;}
.btn-add-cart:hover { background: #4338ca; }
.btn-add-cart-list { background: var(--admin-primary); color: #fff; border: none; border-radius: 6px; padding: 8px 16px; font-size: 13px; font-weight: 600; cursor: pointer; transition: 0.2s; white-space: nowrap; height: 36px;}
.btn-add-cart-list:hover { background: #4338ca; }

/* Bảng giỏ hàng */
.mini-cart-table { width: 100%; border-collapse: collapse; border: 1px solid var(--admin-border); border-radius: 8px; overflow: hidden; }
.mini-cart-table th { background: #f9fafb; padding: 12px; text-align: left; font-size: 12px; text-transform: uppercase; color: var(--admin-text-muted); border-bottom: 1px solid var(--admin-border); }
.mini-cart-table td { padding: 12px; border-bottom: 1px solid #f3f4f6; vertical-align: middle; }
.qty-input { width: 60px; padding: 6px; text-align: center; border: 1px solid var(--admin-border); border-radius: 6px; font-weight: 600; }
.cart-variant-select { padding: 6px 8px; font-size: 12px; border-radius: 6px; border: 1px solid var(--admin-border); background: #f9fafb; margin-top: 4px; width: 100%; max-width: 200px; outline: none; cursor: pointer;}
.cart-variant-select:focus { border-color: var(--admin-primary); }
.btn-remove { background: #fee2e2; color: #ef4444; border: none; padding: 6px 10px; border-radius: 6px; cursor: pointer; font-weight: 600;}
.btn-remove:hover { background: #fecaca; }

.action-bar { display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; padding-top: 24px; border-top: 1px solid var(--admin-border); }
.btn-primary { background: var(--admin-primary); color: #fff; border: none; padding: 12px 24px; border-radius: 8px; font-weight: 600; cursor: pointer; }
.btn-secondary { background: #f3f4f6; color: var(--admin-text-main); border: none; padding: 12px 24px; border-radius: 8px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center;}

@media (min-width: 992px) {
    .create-layout { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: start; }
}
</style>

<div class="create-order-shell">
    <div style="margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between;">
        <div>
            <h1 style="margin:0; font-size: 24px; color: var(--admin-text-main);">Tạo đơn hàng thủ công</h1>
            <p style="margin: 4px 0 0 0; color: var(--admin-text-muted);">Ghi nhận đơn đặt hàng trực tiếp hoặc qua điện thoại.</p>
        </div>
        <a href="<?= route_url('/admin/orders.php') ?>" class="btn-secondary">← Quay lại</a>
    </div>

    <?php if (isset($_SESSION['error_msg'])): ?>
        <div style="padding:16px; background:#fef2f2; color:#ef4444; border:1px solid #fecaca; border-radius:8px; margin-bottom:20px;">
            <?= e($_SESSION['error_msg']); unset($_SESSION['error_msg']); ?>
        </div>
    <?php endif; ?>

    <form method="post" id="createOrderForm" onsubmit="return validateForm()">
        <?= csrf_field() ?>
        <input type="hidden" name="action" value="create_order">
        <input type="hidden" name="order_items_json" id="orderItemsJson">

        <div class="create-layout">
            <div>
                <div class="admin-card" style="overflow: visible;">
                    <h2 class="section-title">Chọn Sản Phẩm</h2>
                    
                    <div class="search-wrapper">
                        <input type="text" id="searchProductInput" class="form-control" placeholder="🔍 Click vào đây để chọn nhanh, hoặc gõ tên SP..." autocomplete="off">
                        <div id="searchDropdown" class="search-dropdown"></div>
                    </div>

                    <div style="overflow-x: auto;">
                        <table class="mini-cart-table">
                            <thead>
                                <tr>
                                    <th>Sản phẩm</th>
                                    <th style="width: 80px; text-align: center;">SL</th>
                                    <th style="text-align: right;">Đơn giá</th>
                                    <th style="text-align: right;">Thành tiền</th>
                                    <th style="width: 50px; text-align: center;">Xóa</th>
                                </tr>
                            </thead>
                            <tbody id="cartBody">
                                <tr id="emptyRow"><td colspan="5" style="text-align:center; color:var(--admin-text-muted); padding:30px;">Chưa chọn sản phẩm nào</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="admin-card">
                    <h2 class="section-title">Thanh toán & Trạng thái</h2>
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Tổng tiền thu (VNĐ)</label>
                            <input type="number" id="totalAmountInput" name="total_amount" class="form-control" required min="0" value="0">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Trạng thái thanh toán</label>
                            <select name="payment_status" class="form-select">
                                <?php foreach ($paymentMap as $key => $val): ?>
                                    <option value="<?= e($key) ?>" <?= $key === 'chua_thanh_toan' ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Trạng thái xử lý</label>
                            <select name="order_status" class="form-select">
                                <?php foreach ($statusMap as $key => $val): ?>
                                    <option value="<?= e($key) ?>" <?= $key === 'cho_xac_nhan' ? 'selected' : '' ?>><?= e($val[0]) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Kênh bán hàng</label>
                            <select name="purchase_channel" class="form-select">
                                <option value="offline">Tại cửa hàng</option>
                                <option value="facebook">Facebook / Messenger</option>
                                <option value="zalo">Zalo</option>
                                <option value="phone">Điện thoại</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="admin-card">
                <h2 class="section-title">Thông tin giao hàng</h2>
                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label">Tên khách hàng <span style="color:var(--admin-danger);">*</span></label>
                    <input type="text" name="customer_name" class="form-control" required>
                </div>
                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label">Số điện thoại <span style="color:var(--admin-danger);">*</span></label>
                    <input type="tel" name="contact_phone" class="form-control" required>
                </div>
                
                <div class="form-group full-width" style="margin-bottom: 16px;">
                    <label class="form-label">Tỉnh / Thành phố <span style="color:var(--admin-danger);">*</span></label>
                    <select class="form-select" name="province_name" id="province_select" required>
                        <option value="">-- Đang tải dữ liệu... --</option>
                    </select>
                </div>
                
                <div class="form-grid" style="margin-bottom: 16px; gap: 12px;">
                    <div class="form-group">
                        <label class="form-label">Quận / Huyện <span style="color:var(--admin-danger);">*</span></label>
                        <select class="form-select" name="district_name" id="district_select" required>
                            <option value="">-- Chọn Quận/Huyện --</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Phường / Xã <span style="color:var(--admin-danger);">*</span></label>
                        <select class="form-select" name="ward_name" id="ward_select" required>
                            <option value="">-- Chọn Phường/Xã --</option>
                        </select>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label">Số nhà, Tên đường <span style="color:var(--admin-danger);">*</span></label>
                    <input type="text" name="address_line" class="form-control" required>
                </div>
                
                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label">Ghi chú của khách hàng</label>
                    <textarea name="customer_note" class="form-control" style="min-height: 60px;" placeholder="Yêu cầu riêng từ khách..."></textarea>
                </div>
                
                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label">Ghi chú đơn hàng (Nội bộ Admin)</label>
                    <textarea name="admin_note" class="form-control" style="min-height: 80px;" placeholder="Thông tin cần lưu ý cho shop..."></textarea>
                </div>

                <div class="action-bar" style="margin-top: 16px; padding-top: 16px;">
                    <button type="submit" class="btn-primary" style="width: 100%;">Tạo đơn hàng ngay</button>
                </div>
            </div>
        </div>
    </form>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

<script>
// =========================================================================
// 1. HỆ THỐNG SELECT ĐỊA GIỚI HÀNH CHÍNH VIỆT NAM
// =========================================================================
$(document).ready(function() {
    $.getJSON('https://esgoo.net/api-tinhthanh/1/0.htm', function(data_tinh) {
        if (data_tinh.error === 0) {
            $("#province_select").html('<option value="">-- Chọn Tỉnh / Thành phố --</option>');
            $.each(data_tinh.data, function (key, val) {
                $("#province_select").append('<option value="'+val.full_name+'" data-id="'+val.id+'">'+val.full_name+'</option>');
            });
        }
    });

    $("#province_select").change(function() {
        var idtinh = $(this).find(':selected').data('id');
        $("#district_select").html('<option value="">-- Đang tải... --</option>');
        $("#ward_select").html('<option value="">-- Chọn Phường / Xã --</option>');
        if (idtinh) {
            $.getJSON('https://esgoo.net/api-tinhthanh/2/'+idtinh+'.htm', function(data_quan) {
                if (data_quan.error === 0) {
                    $("#district_select").html('<option value="">-- Chọn Quận / Huyện --</option>');
                    $.each(data_quan.data, function (key, val) {
                        $("#district_select").append('<option value="'+val.full_name+'" data-id="'+val.id+'">'+val.full_name+'</option>');
                    });
                }
            });
        }
    });

    $("#district_select").change(function() {
        var idquan = $(this).find(':selected').data('id');
        $("#ward_select").html('<option value="">-- Đang tải... --</option>');
        if (idquan) {
            $.getJSON('https://esgoo.net/api-tinhthanh/3/'+idquan+'.htm', function(data_phuong) {
                if (data_phuong.error === 0) {
                    $("#ward_select").html('<option value="">-- Chọn Phường / Xã --</option>');
                    $.each(data_phuong.data, function (key, val) {
                        $("#ward_select").append('<option value="'+val.full_name+'">'+val.full_name+'</option>');
                    });
                }
            });
        }
    });
});

// =========================================================================
// 2. HỆ THỐNG TÌM KIẾM GOM NHÓM & GIỎ HÀNG (CẬP NHẬT ĐỔI BIẾN THỂ TRONG GIỎ)
// =========================================================================
let selectedItems = [];
let currentLoadedProducts = [];

const searchInput = document.getElementById('searchProductInput');
const searchDropdown = document.getElementById('searchDropdown');
const cartBody = document.getElementById('cartBody');
const totalInput = document.getElementById('totalAmountInput');
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
                        <button type="button" class="btn-add-cart" onclick="triggerAddProduct(this, ${item.product_id}, event)">Thêm</button>
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
                <button type="button" class="btn-add-cart-list" onclick="triggerAddProduct(this, ${item.product_id}, event)">Thêm</button>
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
                searchDropdown.innerHTML = '<div style="padding:12px; text-align:center; color:var(--admin-text-muted);">Không tìm thấy sản phẩm</div>';
                searchDropdown.style.display = 'block';
                return;
            }

            if (q === '') {
                const title = document.createElement('div');
                title.style.cssText = "font-size:12px; font-weight:700; color:var(--admin-text-muted); margin-bottom:12px; text-transform:uppercase;";
                title.textContent = "Sản phẩm mới nhất";
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

// LOGIC THÊM SẢN PHẨM VÀO GIỎ TỪ TÌM KIẾM
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

// LOGIC ĐỔI SỐ LƯỢNG TRONG GIỎ
window.updateItemQty = function(index, newQty) {
    newQty = parseInt(newQty);
    if (newQty < 1) newQty = 1;
    selectedItems[index].qty = newQty;
    renderCart();
};

// LOGIC ĐỔI BIẾN THỂ TRỰC TIẾP TRONG GIỎ 
window.changeCartVariant = function(index, newVariantId) {
    const item = selectedItems[index];
    const newVariant = item.available_variants.find(v => v.variant_id == newVariantId);
    
    if (newVariant) {
        item.variant_id = newVariant.variant_id;
        item.variant_name = newVariant.name;
        item.price = newVariant.price;
        
        const duplicateIndex = selectedItems.findIndex((i, idx) => i.variant_id == newVariant.variant_id && i.product_id == item.product_id && idx !== index);
        
        if (duplicateIndex > -1) {
            selectedItems[duplicateIndex].qty += item.qty; 
            selectedItems.splice(index, 1); 
        }
        
        renderCart();
    }
};

window.removeItem = function(index) {
    selectedItems.splice(index, 1);
    renderCart();
};

// RENDER GIAO DIỆN GIỎ HÀNG
function renderCart() {
    if (selectedItems.length === 0) {
        cartBody.innerHTML = '<tr id="emptyRow"><td colspan="5" style="text-align:center; color:var(--admin-text-muted); padding:30px;">Chưa chọn sản phẩm nào</td></tr>';
        totalInput.value = 0;
        jsonInput.value = '[]';
        return;
    }
    
    let html = '';
    let grandTotal = 0;
    
    selectedItems.forEach((item, index) => {
        const lineTotal = item.price * item.qty;
        grandTotal += lineTotal;

        let variantHtml = '';
        if (item.available_variants && item.available_variants.length > 1) {
            let options = item.available_variants.map(v => 
                `<option value="${v.variant_id}" ${v.variant_id == item.variant_id ? 'selected' : ''}>${v.name} - ${new Intl.NumberFormat('vi-VN').format(v.price)}đ</option>`
            ).join('');
            variantHtml = `<select class="cart-variant-select" onchange="changeCartVariant(${index}, this.value)">${options}</select>`;
        } else {
            variantHtml = `<div style="font-size: 12px; color: var(--admin-text-muted); margin-top: 4px;">Phân loại: ${item.variant_name}</div>`;
        }

        html += `
            <tr>
                <td>
                    <div style="display:flex; align-items:flex-start; gap:10px;">
                        <img src="${item.image}" onerror="this.src='/assets/default-placeholder.png'" style="width:48px; height:48px; border-radius:6px; object-fit:cover; border: 1px solid #e5e7eb; flex-shrink:0;">
                        <div style="flex:1;">
                            <div style="font-weight:600; font-size:13px; color:var(--admin-text-main); margin-bottom:4px;">${item.name}</div>
                            ${variantHtml}
                        </div>
                    </div>
                </td>
                <td style="text-align:center; vertical-align:middle;">
                    <input type="number" class="qty-input" min="1" value="${item.qty}" onchange="updateItemQty(${index}, this.value)">
                </td>
                <td style="text-align:right; vertical-align:middle; font-size:13px; color:var(--admin-text-muted);">${new Intl.NumberFormat('vi-VN').format(item.price)}đ</td>
                <td style="text-align:right; vertical-align:middle; font-weight:600; color:var(--admin-danger);">${new Intl.NumberFormat('vi-VN').format(lineTotal)}đ</td>
                <td style="text-align:center; vertical-align:middle;">
                    <button type="button" class="btn-remove" onclick="removeItem(${index})">X</button>
                </td>
            </tr>
        `;
    });
    
    cartBody.innerHTML = html;
    totalInput.value = grandTotal; 
    jsonInput.value = JSON.stringify(selectedItems);
}

function validateForm() {
    if (selectedItems.length === 0) {
        alert("Vui lòng chọn ít nhất 1 sản phẩm vào giỏ!");
        return false;
    }
    return true;
}
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>