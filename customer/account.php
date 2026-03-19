<?php
require_once __DIR__ . '/../includes/functions.php';
customer_require_login();

$customer = current_customer();
$pageTitle = 'Tài khoản của tôi';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$missing = require_upgrade_tables(['customers', 'customer_addresses', 'orders']);
$message = null;
$error = null;

// Ánh xạ trạng thái đơn hàng và thanh toán sang tiếng Việt chuẩn
const ORDER_STATUS_LABELS = [
    'cho_xac_nhan' => ['Chờ xác nhận', 'warning'],
    'dang_chuan_bi' => ['Đang chuẩn bị', 'info'],
    'dang_giao' => ['Đang giao hàng', 'primary'],
    'da_giao' => ['Đã giao hàng', 'success'],
    'da_huy' => ['Đã hủy', 'danger'],
    'tra_hang' => ['Trả hàng/Hoàn tiền', 'danger']
];

const PAYMENT_STATUS_LABELS = [
    'chua_thanh_toan' => ['Chưa thanh toán', 'warning'],
    'da_dat_coc' => ['Đã đặt cọc', 'info'],
    'da_thanh_toan' => ['Đã thanh toán', 'success'],
    'chua_hoan_tien' => ['Chưa hoàn tiền', 'danger'],
    'da_hoan_tien' => ['Đã hoàn tiền', 'primary']
];

if (!$missing && is_post()) {
    verify_csrf_or_fail();
    $formType = $_POST['form_type'] ?? '';
    
    if ($formType === 'profile') {
        $safePost = $_POST;
        unset($safePost['email'], $safePost['phone']); 
        
        $result = update_customer_profile((int)$customer['id'], $safePost);
        if ($result['ok']) {
            $message = $result['message'];
            $customer = current_customer();
        } else {
            $error = $result['message'];
        }
    } 
    // Thêm địa chỉ mới
    elseif ($formType === 'address') {
        $result = save_customer_address((int)$customer['id'], $_POST);
        if ($result['ok']) {
            $message = "Đã thêm địa chỉ mới thành công.";
        } else {
            $error = $result['message'];
        }
    } 
    // Sửa địa chỉ
    elseif ($formType === 'edit_address') {
        $addressId = (int)$_POST['address_id'];
        $isDefault = !empty($_POST['is_default_shipping']) ? 1 : 0;
        try {
            // Cập nhật thông tin địa chỉ
            $stmt = db()->prepare("UPDATE customer_addresses SET receiver_name=?, receiver_phone=?, province_name=?, district_name=?, ward_name=?, address_line=?, label=?, is_default_shipping=? WHERE id=? AND customer_id=?");
            $stmt->execute([
                $_POST['receiver_name'], $_POST['receiver_phone'], 
                $_POST['province_name'], $_POST['district_name'], $_POST['ward_name'], 
                $_POST['address_line'], $_POST['label'] ?? '', 
                $isDefault, $addressId, $customer['id']
            ]);
            
            // Nếu đánh dấu là mặc định, gỡ mặc định các địa chỉ khác
            if ($isDefault) {
                db()->prepare("UPDATE customer_addresses SET is_default_shipping = 0 WHERE customer_id = ? AND id != ?")->execute([$customer['id'], $addressId]);
            }
            
            $message = "Đã cập nhật địa chỉ thành công.";
        } catch (Exception $e) {
            $error = "Lỗi khi cập nhật địa chỉ.";
        }
    }
    // Xóa địa chỉ
    elseif ($formType === 'delete_address') {
        $addressId = (int)$_POST['address_id'];
        try {
            db()->prepare("DELETE FROM customer_addresses WHERE id = ? AND customer_id = ?")->execute([$addressId, $customer['id']]);
            $message = "Đã xóa địa chỉ thành công.";
        } catch (Exception $e) {
            $error = "Lỗi khi xóa địa chỉ.";
        }
    }
    // Set địa chỉ mặc định (Nút 1 chạm)
    elseif ($formType === 'set_default_address') {
        $addressId = (int)$_POST['address_id'];
        try {
            db()->prepare("UPDATE customer_addresses SET is_default_shipping = 0 WHERE customer_id = ?")->execute([$customer['id']]);
            db()->prepare("UPDATE customer_addresses SET is_default_shipping = 1 WHERE id = ? AND customer_id = ?")->execute([$addressId, $customer['id']]);
            $message = "Đã cập nhật địa chỉ mặc định.";
        } catch (Exception $e) {
            $error = "Lỗi khi cập nhật địa chỉ mặc định.";
        }
    }
}

$flash = flash_get('customer_auth');
$addresses = $missing ? [] : get_customer_addresses((int)$customer['id']);
$orders = $missing ? [] : array_slice(get_customer_orders((int)$customer['id']), 0, 5);
require_once __DIR__ . '/../includes/header.php';
?>

<style>
/* Tối ưu giao diện & Responsive Mobile */
.account-shell { max-width: 1200px; margin: 0 auto; padding: 24px 15px; font-family: system-ui, -apple-system, sans-serif; }
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
@media (max-width: 768px) { .grid-2 { grid-template-columns: 1fr; } }

.account-card { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #f3f4f6; }
.section-title { font-size: 20px; font-weight: 700; color: #1f2937; margin-bottom: 6px; }
.section-subtitle { font-size: 14px; color: #6b7280; margin-bottom: 20px; }

.form-group { margin-bottom: 16px; }
.form-label { display: block; font-size: 14px; font-weight: 600; color: #374151; margin-bottom: 6px; }
.form-control { width: 100%; padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 15px; transition: border-color 0.2s; outline: none; }
.form-control:focus { border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
.form-control:disabled, .form-control[readonly] { background-color: #f3f4f6; color: #6b7280; cursor: not-allowed; }

.btn-primary { background: #2563eb; color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; display: inline-flex; justify-content: center; width: auto; text-decoration: none; }
.btn-secondary { background: #f1f5f9; color: #1e293b; border: none; padding: 8px 16px; border-radius: 8px; font-weight: 600; cursor: pointer; text-decoration: none; font-size: 14px; }
.btn-ghost { background: transparent; border: 1px solid #cbd5e1; color: #475569; padding: 6px 12px; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer; transition: 0.2s; }
.btn-ghost:hover { background: #f8fafc; color: #111827; }

/* Thẻ địa chỉ */
.address-card { border: 1px solid #e5e7eb; border-radius: 10px; padding: 16px; background: #fafafa; position: relative; display: flex; flex-direction: column; justify-content: space-between;}
.address-card.is-default { border-color: #3b82f6; background: #eff6ff; }
.status-pill { background: #dbeafe; color: #1e40af; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
.address-actions { display: flex; gap: 8px; border-top: 1px dashed #d1d5db; padding-top: 12px; margin-top: 12px; }

/* Bảng đơn hàng (Responsive) */
.table-responsive { overflow-x: auto; margin-top: 16px; }
.data-table { width: 100%; border-collapse: collapse; min-width: 600px; }
.data-table th, .data-table td { padding: 12px 16px; border-bottom: 1px solid #e5e7eb; text-align: left; font-size: 14px; }
.data-table th { background: #f9fafb; font-weight: 600; color: #4b5563; }
.badge { padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; white-space: nowrap; }
.badge-warning { background: #fef08a; color: #854d0e; }
.badge-info { background: #e0f2fe; color: #0369a1; }
.badge-primary { background: #dbeafe; color: #1e40af; }
.badge-success { background: #dcfce3; color: #166534; }
.badge-danger { background: #fee2e2; color: #b91c1c; }

@media (max-width: 640px) {
    .hide-mobile { display: none; }
    .data-table th, .data-table td { padding: 10px 8px; }
    .btn-primary { width: 100%; }
}
</style>

<div class="account-shell">
    <?php if ($flash): ?>
        <div class="alert alert-<?= e($flash['type']) ?> mb-4"><?= e($flash['message']) ?></div>
    <?php endif; ?>
    <?php if ($missing): ?>
        <div class="alert alert-warning mb-4">Bạn cần import file migration nâng cấp CSDL: <?= e(implode(', ', $missing)) ?>.</div>
    <?php endif; ?>
    <?php if ($message): ?>
        <div class="alert alert-success mb-4" style="background:#dcfce3; color:#166534; padding:12px; border-radius:8px;"><?= e($message) ?></div>
    <?php endif; ?>
    <?php if ($error): ?>
        <div class="alert alert-danger mb-4" style="background:#fee2e2; color:#b91c1c; padding:12px; border-radius:8px;"><?= e($error) ?></div>
    <?php endif; ?>

    <div class="grid-2">
        <div class="account-card">
            <h1 class="section-title">Hồ sơ tài khoản</h1>
            <p class="section-subtitle">Cập nhật thông tin cá nhân của bạn.</p>
            <form method="post">
                <?= csrf_field() ?>
                <input type="hidden" name="form_type" value="profile">
                <div class="form-group">
                    <label class="form-label">Họ và tên</label>
                    <input class="form-control" name="full_name" value="<?= e($customer['full_name'] ?? '') ?>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Email <span style="color:#ef4444; font-weight:normal; font-size:12px;">(Không thể thay đổi)</span></label>
                    <input type="email" class="form-control" value="<?= e($customer['email'] ?? '') ?>" readonly>
                </div>
                <div class="form-group">
                    <label class="form-label">Số điện thoại <span style="color:#ef4444; font-weight:normal; font-size:12px;">(Không thể thay đổi)</span></label>
                    <input type="tel" class="form-control" value="<?= e($customer['phone'] ?? '') ?>" readonly>
                </div>
                <button class="btn-primary" type="submit">Lưu thông tin</button>
            </form>
        </div>

        <div class="account-card">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 20px;">
                <div>
                    <h2 class="section-title">Tổng quan</h2>
                    <p class="section-subtitle" style="margin-bottom:0;">Truy cập nhanh những gì bạn cần.</p>
                </div>
                <a class="btn-secondary" href="<?= route_url('/customer/orders.php') ?>">Xem tất cả đơn</a>
            </div>
            
            <div style="display:flex; flex-direction:column; gap:12px; background:#f9fafb; padding:16px; border-radius:8px;">
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:#4b5563; font-weight:500;">Mã khách hàng</span>
                    <strong style="font-family:monospace;"><?= e($customer['customer_code'] ?? '—') ?></strong>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:#4b5563; font-weight:500;">Đăng ký bằng</span>
                    <strong style="text-transform:capitalize;"><?= e($customer['registered_via'] ?? 'Website') ?></strong>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:#4b5563; font-weight:500;">Số địa chỉ đã lưu</span>
                    <strong><?= count($addresses) ?></strong>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:#4b5563; font-weight:500;">Số đơn gần đây</span>
                    <strong><?= count($orders) ?></strong>
                </div>
            </div>
        </div>
    </div>

    <div class="grid-2" style="margin-top: 24px;">
        <div class="account-card">
            <h2 class="section-title">Địa chỉ đã lưu</h2>
            <p class="section-subtitle">Dùng để chọn nhanh khi thanh toán.</p>
            
            <?php if (!$addresses): ?>
                <div style="padding: 20px; background: #f3f4f6; text-align: center; border-radius: 8px; color: #6b7280;">Bạn chưa lưu địa chỉ nào.</div>
            <?php else: ?>
                <div style="display:grid; gap:16px;">
                    <?php foreach ($addresses as $address): ?>
                        <div class="address-card <?= !empty($address['is_default_shipping']) ? 'is-default' : '' ?>">
                            <div>
                                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                    <div style="font-weight: 700; color: #1f2937; font-size: 15px; margin-bottom:4px;">
                                        <?= e($address['receiver_name']) ?> - <?= e($address['receiver_phone']) ?>
                                    </div>
                                    <?php if (!empty($address['is_default_shipping'])): ?>
                                        <span class="status-pill">📍 Mặc định</span>
                                    <?php else: ?>
                                        <form method="post" style="margin:0;">
                                            <?= csrf_field() ?>
                                            <input type="hidden" name="form_type" value="set_default_address">
                                            <input type="hidden" name="address_id" value="<?= $address['id'] ?>">
                                            <button type="submit" class="btn-ghost">Đặt mặc định</button>
                                        </form>
                                    <?php endif; ?>
                                </div>
                                
                                <div style="color:#475569; font-size:14px; line-height: 1.5; margin-top: 6px;">
                                    <?php if($address['label']): ?><strong style="color:#111827; background:#e5e7eb; padding:2px 6px; border-radius:4px; font-size:12px; margin-right:4px;"><?= e($address['label']) ?></strong><?php endif; ?>
                                    <?= e(trim(($address['address_line'] ?? '') . ', ' . ($address['ward_name'] ?? '') . ', ' . ($address['district_name'] ?? '') . ', ' . ($address['province_name'] ?? ''))) ?>
                                </div>
                            </div>
                            
                            <div class="address-actions">
                                <button type="button" class="btn-ghost" style="flex: 1;"
                                    data-id="<?= $address['id'] ?>"
                                    data-name="<?= e($address['receiver_name']) ?>"
                                    data-phone="<?= e($address['receiver_phone']) ?>"
                                    data-province="<?= e($address['province_name']) ?>"
                                    data-district="<?= e($address['district_name']) ?>"
                                    data-ward="<?= e($address['ward_name']) ?>"
                                    data-line="<?= e($address['address_line']) ?>"
                                    data-label="<?= e($address['label']) ?>"
                                    data-default="<?= $address['is_default_shipping'] ? 1 : 0 ?>"
                                    onclick="editAddress(this)">✏️ Sửa</button>
                                
                                <form method="post" style="margin:0; flex: 1;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?');">
                                    <?= csrf_field() ?>
                                    <input type="hidden" name="form_type" value="delete_address">
                                    <input type="hidden" name="address_id" value="<?= $address['id'] ?>">
                                    <button type="submit" class="btn-ghost" style="width: 100%; color: #ef4444; border-color: #fca5a5;">🗑️ Xóa</button>
                                </form>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>

        <div class="account-card" id="address-form-container">
            <h2 class="section-title" id="address-form-title">Thêm địa chỉ mới</h2>
            <form method="post" id="address-form">
                <?= csrf_field() ?>
                <input type="hidden" name="form_type" id="address-form-type" value="address">
                <input type="hidden" name="address_id" id="edit_address_id" value="">
                
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                    <div class="form-group">
                        <label class="form-label">Tên người nhận</label>
                        <input class="form-control" name="receiver_name" value="<?= e($customer['full_name'] ?? '') ?>" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số điện thoại</label>
                        <input class="form-control" name="receiver_phone" value="<?= e($customer['phone'] ?? '') ?>" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Tỉnh / Thành phố</label>
                    <input class="form-control" type="text" name="province_name" placeholder="VD: Hà Nội" required>
                </div>
                
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                    <div class="form-group">
                        <label class="form-label">Quận / Huyện</label>
                        <input class="form-control" type="text" name="district_name" placeholder="VD: Cầu Giấy" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Phường / Xã</label>
                        <input class="form-control" type="text" name="ward_name" placeholder="VD: Dịch Vọng" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Địa chỉ chi tiết (Số nhà, Tên đường)</label>
                    <input class="form-control" name="address_line" placeholder="VD: Số 12, Ngõ 34, Phố X" required>
                </div>
                
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 12px; align-items: end;">
                    <div class="form-group" style="margin:0;">
                        <label class="form-label">Nhãn (Không bắt buộc)</label>
                        <input class="form-control" name="label" placeholder="VD: Nhà riêng, Công ty">
                    </div>
                    <div class="form-group" style="margin:0; padding-bottom:10px;">
                        <label style="display:flex; align-items:center; gap:8px; font-size:14px; cursor:pointer;">
                            <input type="checkbox" name="is_default_shipping" value="1" style="width:18px; height:18px;"> Đặt làm mặc định
                        </label>
                    </div>
                </div>
                
                <div style="display: flex; gap: 12px; margin-top: 20px;">
                    <button class="btn-primary" type="submit" id="btn-save-address" style="flex: 2;">Lưu địa chỉ</button>
                    <button type="button" class="btn-secondary" id="btn-cancel-edit" style="display: none; flex: 1; text-align: center;" onclick="cancelEdit()">Hủy</button>
                </div>
            </form>
        </div>
    </div>

    <div class="account-card" style="margin-top: 24px;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
            <h2 class="section-title">Đơn hàng gần đây</h2>
            <a class="btn-secondary" href="<?= route_url('/customer/orders.php') ?>">Xem tất cả</a>
        </div>
        
        <?php if (!$orders): ?>
            <div style="padding: 20px; background: #f3f4f6; text-align: center; border-radius: 8px; color: #6b7280; margin-top: 16px;">Bạn chưa có đơn hàng nào.</div>
        <?php else: ?>
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Ngày đặt</th>
                            <th class="hide-mobile">Tổng tiền</th>
                            <th>Thanh toán</th>
                            <th>Trạng thái</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($orders as $order): ?>
                            <?php
                                $orderStat = ORDER_STATUS_LABELS[$order['order_status']] ?? ['Không rõ', 'info'];
                                $payStat = PAYMENT_STATUS_LABELS[$order['payment_status']] ?? ['Không rõ', 'info'];
                            ?>
                            <tr>
                                <td style="font-family: monospace; font-weight: 600;"><?= e($order['order_code']) ?></td>
                                <td><?= e(date('d/m/Y', strtotime($order['placed_at']))) ?></td>
                                <td class="hide-mobile" style="font-weight: 600; color: #ef4444;"><?= format_price($order['total_amount'] ?? 0) ?></td>
                                
                                <td><span class="badge badge-<?= $payStat[1] ?>"><?= e($payStat[0]) ?></span></td>
                                <td><span class="badge badge-<?= $orderStat[1] ?>"><?= e($orderStat[0]) ?></span></td>
                                
                                <td style="text-align:right;">
                                    <a style="color: #2563eb; font-weight: 600; text-decoration: none; font-size: 13px;" href="<?= route_url('/order.php') ?>?code=<?= urlencode($order['order_code']) ?>">Chi tiết &rarr;</a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</div>

<script>
// Logic JavaScript đổ dữ liệu vào Form Sửa
function editAddress(btn) {
    const form = document.getElementById('address-form');
    
    // Đổi tiêu đề và type
    document.getElementById('address-form-title').innerText = '✏️ Sửa địa chỉ';
    document.getElementById('address-form-type').value = 'edit_address';
    document.getElementById('edit_address_id').value = btn.dataset.id;
    
    // Điền dữ liệu
    form.elements['receiver_name'].value = btn.dataset.name;
    form.elements['receiver_phone'].value = btn.dataset.phone;
    form.elements['province_name'].value = btn.dataset.province;
    form.elements['district_name'].value = btn.dataset.district;
    form.elements['ward_name'].value = btn.dataset.ward;
    form.elements['address_line'].value = btn.dataset.line;
    form.elements['label'].value = btn.dataset.label;
    form.elements['is_default_shipping'].checked = btn.dataset.default == '1';
    
    // Hiện nút Hủy và đổi text nút Lưu
    document.getElementById('btn-save-address').innerText = 'Cập nhật địa chỉ';
    document.getElementById('btn-cancel-edit').style.display = 'block';
    
    // Cuộn trang mượt mà tới form
    document.getElementById('address-form-container').scrollIntoView({ behavior: 'smooth', block: 'center' });
}

// Logic Hủy sửa -> Quay về form thêm mới
function cancelEdit() {
    const form = document.getElementById('address-form');
    
    document.getElementById('address-form-title').innerText = 'Thêm địa chỉ mới';
    document.getElementById('address-form-type').value = 'address';
    document.getElementById('edit_address_id').value = '';
    
    // Reset form
    form.reset();
    
    // Giữ nguyên Tên và SĐT mặc định của khách
    form.elements['receiver_name'].value = "<?= e($customer['full_name'] ?? '') ?>";
    form.elements['receiver_phone'].value = "<?= e($customer['phone'] ?? '') ?>";
    
    document.getElementById('btn-save-address').innerText = 'Lưu địa chỉ';
    document.getElementById('btn-cancel-edit').style.display = 'none';
}
</script>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>