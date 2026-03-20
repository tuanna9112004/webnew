<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

$pageTitle = 'Tạo đơn hàng mới';

// =========================================================================
// 1. XỬ LÝ AJAX TÌM KIẾM SẢN PHẨM
// =========================================================================
if (isset($_GET['ajax_search_product'])) {
    header('Content-Type: application/json');
    $q = trim($_GET['q'] ?? '');
    if (strlen($q) < 2) { echo json_encode([]); exit; }
    
    try {
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

        // === VIẾT LOGIC INSERT VÀO DATABASE TẠI ĐÂY ===
        // 1. Tạo order mới trong bảng orders
        // 2. Insert các sản phẩm vào bảng order_items
        // 3. Insert địa chỉ vào order_addresses
        // Ví dụ: admin_create_manual_order($_POST, $orderItemsData);
        
        $_SESSION['success_msg'] = "Đã lên đơn hàng thủ công thành công!";
        header('Location: ' . route_url('/admin/orders.php'));
        exit;
    } catch (Exception $e) {
        $_SESSION['error_msg'] = "Lỗi tạo đơn: " . $e->getMessage();
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

/* Tìm kiếm sản phẩm */
.search-wrapper { position: relative; margin-bottom: 20px; }
.search-dropdown { position: absolute; top: 100%; left: 0; right: 0; background: #fff; border: 1px solid var(--admin-border); border-radius: 8px; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1); z-index: 100; max-height: 300px; overflow-y: auto; display: none; margin-top: 4px; }
.search-item { padding: 10px 14px; border-bottom: 1px solid #f3f4f6; cursor: pointer; display: flex; align-items: center; gap: 12px; }
.search-item:hover { background: #f9fafb; }
.search-item img { width: 40px; height: 40px; object-fit: cover; border-radius: 6px; }
.search-item-info { flex: 1; }
.search-item-name { font-size: 14px; font-weight: 600; color: var(--admin-text-main); margin-bottom: 4px; }
.search-item-price { font-size: 13px; color: var(--admin-danger); font-weight: 600; }

/* Bảng giỏ hàng */
.mini-cart-table { width: 100%; border-collapse: collapse; border: 1px solid var(--admin-border); border-radius: 8px; overflow: hidden; }
.mini-cart-table th { background: #f9fafb; padding: 12px; text-align: left; font-size: 12px; text-transform: uppercase; color: var(--admin-text-muted); border-bottom: 1px solid var(--admin-border); }
.mini-cart-table td { padding: 12px; border-bottom: 1px solid #f3f4f6; vertical-align: middle; }
.qty-input { width: 60px; padding: 6px; text-align: center; border: 1px solid var(--admin-border); border-radius: 6px; }
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
                <div class="admin-card">
                    <h2 class="section-title">Chọn Sản Phẩm</h2>
                    
                    <div class="search-wrapper">
                        <input type="text" id="searchProductInput" class="form-control" placeholder="🔍 Gõ tên, phân loại hoặc mã SKU..." autocomplete="off">
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
                                <option value="chua_thanh_toan">Chưa thanh toán</option>
                                <option value="da_dat_coc">Đã đặt cọc</option>
                                <option value="da_thanh_toan">Đã thanh toán đủ</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Trạng thái xử lý</label>
                            <select name="order_status" class="form-select">
                                <option value="cho_xac_nhan">Chờ xác nhận (Cần giao)</option>
                                <option value="dang_chuan_bi">Đang chuẩn bị hàng</option>
                                <option value="da_giao">Đã giao xong (Mua tại quầy)</option>
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
                    <label class="form-label">Ghi chú đơn hàng (Nội bộ)</label>
                    <textarea name="admin_note" class="form-control" style="min-height: 80px;"></textarea>
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
// 1. HỆ THỐNG SELECT ĐỊA GIỚI HÀNH CHÍNH VIỆT NAM (TỐC ĐỘ CAO)
// =========================================================================
$(document).ready(function() {
    // Gọi API lấy danh sách Tỉnh/Thành lúc tải trang
    $.getJSON('https://esgoo.net/api-tinhthanh/1/0.htm', function(data_tinh) {
        if (data_tinh.error === 0) {
            $("#province_select").html('<option value="">-- Chọn Tỉnh / Thành phố --</option>');
            $.each(data_tinh.data, function (key, val) {
                $("#province_select").append('<option value="'+val.full_name+'" data-id="'+val.id+'">'+val.full_name+'</option>');
            });
        }
    });

    // Khi chọn Tỉnh -> Xổ danh sách Quận/Huyện
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
        } else {
            $("#district_select").html('<option value="">-- Chọn Quận / Huyện --</option>');
        }
    });

    // Khi chọn Quận -> Xổ danh sách Phường/Xã
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
        } else {
            $("#ward_select").html('<option value="">-- Chọn Phường / Xã --</option>');
        }
    });
});

// =========================================================================
// 2. HỆ THỐNG TÌM KIẾM SẢN PHẨM & GIỎ HÀNG
// =========================================================================
let selectedItems = [];
const searchInput = document.getElementById('searchProductInput');
const searchDropdown = document.getElementById('searchDropdown');
const cartBody = document.getElementById('cartBody');
const totalInput = document.getElementById('totalAmountInput');
const jsonInput = document.getElementById('orderItemsJson');

let searchTimeout;

// Tìm kiếm sản phẩm (Ajax)
searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    const q = this.value.trim();
    if (q.length < 2) { searchDropdown.style.display = 'none'; return; }
    
    searchTimeout = setTimeout(() => {
        fetch(`?ajax_search_product=1&q=${encodeURIComponent(q)}`)
            .then(res => res.json())
            .then(data => {
                searchDropdown.innerHTML = '';
                if(data.length === 0) {
                    searchDropdown.innerHTML = '<div style="padding:12px; text-align:center; color:var(--admin-text-muted);">Không tìm thấy sản phẩm</div>';
                } else {
                    data.forEach(item => {
                        const div = document.createElement('div');
                        div.className = 'search-item';
                        div.innerHTML = `
                            <img src="${item.image || '/assets/default-placeholder.png'}">
                            <div class="search-item-info">
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

// Thêm vào giỏ
function addItemToCart(item) {
    searchDropdown.style.display = 'none';
    searchInput.value = '';
    
    const existingIndex = selectedItems.findIndex(i => i.variant_id === item.variant_id && i.product_id === item.product_id);
    if (existingIndex > -1) {
        selectedItems[existingIndex].qty += 1;
    } else {
        selectedItems.push({ ...item, qty: 1 });
    }
    renderCart();
}

// Đổi số lượng
window.updateItemQty = function(index, newQty) {
    newQty = parseInt(newQty);
    if (newQty < 1) newQty = 1;
    selectedItems[index].qty = newQty;
    renderCart();
};

// Xóa khỏi giỏ
window.removeItem = function(index) {
    selectedItems.splice(index, 1);
    renderCart();
};

// Render bảng & Tính tổng tiền
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
        html += `
            <tr>
                <td>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <img src="${item.image || '/assets/default-placeholder.png'}" style="width:36px; height:36px; border-radius:4px; object-fit:cover; border: 1px solid #e5e7eb;">
                        <span style="font-weight:600; font-size:13px;">${item.name}</span>
                    </div>
                </td>
                <td style="text-align:center;">
                    <input type="number" class="qty-input" min="1" value="${item.qty}" onchange="updateItemQty(${index}, this.value)">
                </td>
                <td style="text-align:right; font-size:13px; color:var(--admin-text-muted);">${new Intl.NumberFormat('vi-VN').format(item.price)}</td>
                <td style="text-align:right; font-weight:600; color:var(--admin-danger);">${new Intl.NumberFormat('vi-VN').format(lineTotal)}</td>
                <td style="text-align:center;">
                    <button type="button" class="btn-remove" onclick="removeItem(${index})">X</button>
                </td>
            </tr>
        `;
    });
    
    cartBody.innerHTML = html;
    totalInput.value = grandTotal; 
    jsonInput.value = JSON.stringify(selectedItems);
}

// 3. VALIDATE TRƯỚC KHI SUBMIT
function validateForm() {
    if (selectedItems.length === 0) {
        alert("Vui lòng chọn ít nhất 1 sản phẩm vào giỏ!");
        return false;
    }
    return true;
}
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>