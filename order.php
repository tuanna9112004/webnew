<?php
require_once __DIR__ . '/includes/functions.php';

$orderCode = trim((string)($_GET['code'] ?? ''));
$guestToken = trim((string)($_GET['token'] ?? ''));
$lookupPhone = normalize_phone($_GET['phone'] ?? null);
$customer = current_customer();
$order = $orderCode !== '' ? get_order_by_code_for_view($orderCode, $customer['id'] ?? null, $guestToken !== '' ? $guestToken : null, $lookupPhone) : null;

if (!$order) {
    http_response_code(404);
    exit('Không tìm thấy đơn hàng hoặc bạn không có quyền xem thông tin đơn hàng này.');
}

// Xử lý Hủy đơn hàng từ phía khách hàng
if (is_post() && ($_POST['action'] ?? '') === 'cancel_order') {
    verify_public_or_customer_form_or_fail();

    $freshOrder = get_order_by_code_for_view($orderCode, $customer['id'] ?? null, $guestToken !== '' ? $guestToken : null, $lookupPhone);
    if ($freshOrder) {
        $checkOrderStatus = strtolower((string)$freshOrder['order_status']);
        $checkPaymentStatus = strtolower((string)$freshOrder['payment_status']);

        if ($checkOrderStatus === 'cho_xac_nhan' && $checkPaymentStatus === 'chua_thanh_toan') {
            $stmt = db()->prepare("UPDATE orders SET order_status = 'da_huy', cancelled_at = NOW(), updated_at = NOW() WHERE id = ?");
            $stmt->execute([(int)$freshOrder['id']]);
        }
    }

    header("Location: " . $_SERVER['REQUEST_URI']);
    exit;
}

// Xử lý Cập nhật địa chỉ nhận hàng
if (is_post() && ($_POST['action'] ?? '') === 'update_address') {
    verify_public_or_customer_form_or_fail();

    $freshOrder = get_order_by_code_for_view($orderCode, $customer['id'] ?? null, $guestToken !== '' ? $guestToken : null, $lookupPhone);
    if ($freshOrder) {
        $checkOrderStatus = strtolower((string)$freshOrder['order_status']);

        // Chỉ cho phép cập nhật khi đơn đang chờ xác nhận
        if ($checkOrderStatus === 'cho_xac_nhan') {
            $newName = trim($_POST['receiver_name'] ?? '');
            $newPhone = normalize_phone($_POST['receiver_phone'] ?? '');
            
            // Lấy thêm 3 trường địa chỉ mới
            $newProvince = trim($_POST['province_name'] ?? '');
            $newDistrict = trim($_POST['district_name'] ?? '');
            $newWard = trim($_POST['ward_name'] ?? '');
            
            $newLine = trim($_POST['address_line'] ?? '');
            $newNote = trim($_POST['address_note'] ?? '');

            if ($newName && $newPhone && $newProvince && $newDistrict && $newWard && $newLine) {
                $stmt = db()->prepare("UPDATE order_addresses SET receiver_name = ?, receiver_phone = ?, province_name = ?, district_name = ?, ward_name = ?, address_line = ?, address_note = ? WHERE order_id = ?");
                $stmt->execute([$newName, $newPhone, $newProvince, $newDistrict, $newWard, $newLine, $newNote, (int)$freshOrder['id']]);
            }
        }
    }

    header("Location: " . $_SERVER['REQUEST_URI']);
    exit;
}

$pageTitle = 'Chi tiết đơn hàng #' . $order['order_code'];
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$items = get_order_items((int)$order['id']);
$address = get_order_address((int)$order['id']);
$payments = get_order_payments((int)$order['id']);
$intent = get_latest_payment_intent_for_order((int)$order['id']);

$bankName = sepay_bank_name() ?: 'CẤU HÌNH TRONG app_settings';
$bankCode = sepay_bank_code();
$bankAccountNo = sepay_bank_account_no() ?: 'CHƯA_CẤU_HÌNH';
$bankAccountName = sepay_account_name() ?: shop_name();

require_once __DIR__ . '/includes/header.php';

$statusMap = order_status_options();
$paymentMap = payment_status_options();
$currentOrderStatus = strtolower((string)$order['order_status']);
$currentPaymentStatus = strtolower((string)$order['payment_status']);
$paymentPlan = strtolower((string)($order['payment_plan'] ?? ''));

$paymentClass = order_payment_pill_class($currentPaymentStatus);
$paymentStatusText = $paymentMap[$currentPaymentStatus][0] ?? $order['payment_status'];

$isCancelled = $currentOrderStatus === 'da_huy';
$isReturned = $currentOrderStatus === 'tra_hang';
$activeTimelineStatuses = ['cho_xac_nhan', 'dang_chuan_bi', 'dang_giao', 'da_giao'];
$timelineSteps = [
    'cho_xac_nhan'  => 'Chờ xác nhận',
    'dang_chuan_bi' => 'Đang chuẩn bị',
    'dang_giao'     => 'Đang giao hàng',
    'da_giao'       => 'Giao thành công',
];
$stepKeys = array_keys($timelineSteps);
$currentStepIndex = array_search($currentOrderStatus, $stepKeys, true);
if ($currentStepIndex === false) {
    $currentStepIndex = 0;
}

// --- LOGIC HIỂN THỊ MÃ QR ĐƯỢC FIX Ở ĐÂY ---
$totalAmount = (float)($order['total_amount'] ?? 0);
$depositRequiredAmount = (float)($order['deposit_required_amount'] ?? 0);
if ($depositRequiredAmount <= 0) {
    $depositRequiredAmount = round($totalAmount * 0.3); // Mặc định cọc 30%
}

$qrRequestedAmount = 0;
$qrTransferNote = (string)$order['order_code'];

if ($paymentPlan === 'deposit_30' && $currentPaymentStatus === 'chua_thanh_toan') {
    $qrRequestedAmount = $depositRequiredAmount;
    $qrTransferNote .= ' COC';
} else {
    $qrRequestedAmount = $totalAmount;
}

// Lấy thông tin từ Intent nếu có, nếu không thì tự sinh QR dựa trên số tiền cần thu
if ($intent && isset($intent['requested_amount'])) {
    $qrRequestedAmount = (float)$intent['requested_amount'];
    $qrTransferNote = (string)$intent['transfer_note'];
}

$qrImageUrl = $intent && !empty($intent['qr_image_url']) 
    ? $intent['qr_image_url'] 
    : sepay_qr_url($qrRequestedAmount, $qrTransferNote);

// Điều kiện hiển thị QR: 
// 1. Đơn đang chờ duyệt hoặc chuẩn bị
// 2. Tiền chưa thanh toán đủ HOẶC chọn cọc mà chưa cọc
$showPaymentQr = in_array($currentOrderStatus, ['cho_xac_nhan', 'dang_chuan_bi'], true) 
                 && ($currentPaymentStatus === 'chua_thanh_toan' || ($paymentPlan === 'deposit_30' && $currentPaymentStatus !== 'da_dat_coc' && $currentPaymentStatus !== 'da_thanh_toan'));

$paymentPlanText = payment_plan_label((string)$order['payment_plan']);
?>

<style>
    /* Reset & Khóa tràn viền */
    html, body { max-width: 100vw !important; overflow-x: hidden !important; }
    .order-shell, .order-shell *, .order-shell *::before, .order-shell *::after { box-sizing: border-box !important; }
    .word-break { word-break: break-word; overflow-wrap: break-word; }

    .order-shell { padding: 24px 16px; width: 100%; max-width: 100vw; overflow-x: hidden; margin: 0 auto; }

    /* CSS Tối ưu Timeline */
    .order-timeline-container { position: relative; margin: 30px 0 40px; width: 100%; }
    .order-timeline { display: flex; justify-content: space-between; position: relative; z-index: 1; }
    .timeline-line { position: absolute; top: 16px; left: 10%; right: 10%; height: 3px; background: #e2e8f0; z-index: 0; border-radius: 3px; }
    .timeline-line-progress { position: absolute; top: 0; left: 0; height: 100%; background: #3b82f6; border-radius: 3px; transition: width 0.3s ease; }
    
    .timeline-step { display: flex; flex-direction: column; align-items: center; text-align: center; flex: 1; z-index: 2; position: relative; }
    .timeline-icon { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: #e2e8f0; color: #64748b; font-weight: bold; margin-bottom: 10px; border: 3px solid #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.05); transition: all 0.3s ease; }
    .timeline-label { font-size: 13px; font-weight: 500; color: #64748b; line-height: 1.4; }
    
    .timeline-step.completed .timeline-icon { background: #3b82f6; color: #fff; }
    .timeline-step.completed .timeline-label { color: #1e293b; font-weight: 600; }
    
    .timeline-step.active .timeline-icon { background: #3b82f6; color: #fff; box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2); border-color: #fff; }
    .timeline-step.active .timeline-label { color: #2563eb; font-weight: 700; }

    .timeline-step.cancelled .timeline-icon { background: #ef4444; color: #fff; box-shadow: 0 0 0 4px rgba(239, 68, 68, 0.2); border-color: #fff; }
    .timeline-step.cancelled .timeline-label { color: #dc2626; font-weight: 700; }

    /* Hiển thị phân loại sản phẩm */
    .variant-badge { display: inline-block; background: #f1f5f9; color: #475569; font-size: 12px; padding: 3px 8px; border-radius: 6px; margin: 4px 0; border: 1px solid #e2e8f0; font-weight: 500; }
    
    /* Responsive Table mặc định */
    .table-responsive { width: 100%; border-radius: 8px; overflow: hidden; }
    .table-responsive table { width: 100%; border-collapse: collapse; }
    .data-table th, .data-table td { padding: 12px; border-bottom: 1px solid #e2e8f0; text-align: left; }
    .data-table th { background: #f8fafc; font-weight: 600; color: #475569; }

    /* 📱 TỐI ƯU HÓA CHO MOBILE 📱 */
    @media screen and (max-width: 768px) {
        .order-shell { padding: 16px 12px; }
        .grid-2 { display: flex; flex-direction: column; gap: 16px; }
        
        /* Chỉnh Header Đơn hàng */
        .section-title { font-size: 16px !important; margin-bottom: 6px; }
        .section-subtitle { font-size: 13px; }
        .status-pill { font-size: 12px; padding: 4px 10px; display: inline-block; }
        
        /* Timeline dọc trên Mobile */
        .order-timeline-container { margin: 20px 0; padding-left: 8px; }
        .order-timeline { flex-direction: column; align-items: flex-start; gap: 0; }
        .timeline-line { top: 0; left: 26px; height: 100%; width: 2px; right: auto; bottom: auto; background: #e2e8f0; }
        .timeline-line-progress { height: var(--mobile-progress); width: 100%; } 
        
        .timeline-step { flex-direction: row; gap: 16px; align-items: flex-start; width: 100%; text-align: left; margin-bottom: 24px; }
        .timeline-step:last-child { margin-bottom: 0; }
        .timeline-icon { width: 32px; height: 32px; font-size: 13px; margin-bottom: 0; z-index: 2; flex-shrink: 0; }
        .timeline-label { margin-top: 6px; font-size: 13px; }
        
        /* Tóm tắt & Thanh toán */
        .summary-box { font-size: 14px; }
        .summary-box .flex-between { flex-wrap: wrap; margin-top: 10px !important; justify-content: space-between; gap: 4px; }
        .address-card { padding: 12px !important; }

        /* Biến Bảng thành Danh sách Thẻ (Card) */
        .table-responsive { background: transparent; overflow: visible; }
        .data-table, .data-table tbody, .data-table tr, .data-table td { display: block; width: 100%; }
        .data-table thead { display: none; /* Ẩn thẻ head trên mobile */ }
        
        .data-table tbody tr { 
            background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; 
            margin-bottom: 16px; padding: 12px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); 
        }
        
        .data-table tbody td { 
            display: flex; justify-content: space-between; align-items: center; 
            padding: 8px 0; border-bottom: 1px dashed #e2e8f0; text-align: right !important; 
            font-size: 14px; gap: 8px;
        }
        
        .data-table tbody td:last-child { border-bottom: none; padding-bottom: 0; }
        
        .data-table tbody td:first-child { 
            flex-direction: column; align-items: flex-start; text-align: left !important; 
            background: #f8fafc; padding: 12px; border-radius: 6px; margin-bottom: 8px; border-bottom: none;
        }
        
        /* Gắn nhãn tự động cho ô dữ liệu dựa vào data-label */
        .data-table tbody td::before { 
            content: attr(data-label); font-weight: 500; color: #64748b; 
            font-size: 13px; flex-shrink: 0; 
        }
        .data-table tbody td:first-child::before { display: none; }
        
        .btn-primary, .btn-secondary, button.btn-primary { font-size: 14px; padding: 12px; width: 100%; display: block; text-align: center; margin-bottom: 8px; border: none; cursor: pointer; border-radius: 8px; }
    }
    
    @media screen and (min-width: 769px) {
        button.btn-primary { display: inline-block; padding: 12px 24px; font-size: 14px; border: none; border-radius: 8px; cursor: pointer; color: #fff; font-weight: 600; text-align: center;}
    }
</style>

<div class="order-shell" style="padding-top:24px;">
    <div class="grid-2">
        <div class="order-card">
            <div class="flex-between" style="align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 12px;">
                <div style="flex: 1; min-width: 100%;">
                    <h1 class="section-title word-break">Mã đơn: <?= e($order['order_code']) ?></h1>
                    <p class="section-subtitle">Ngày đặt: <?= e(date('d/m/Y - H:i', strtotime($order['placed_at']))) ?></p>
                </div>
                <div style="display:flex; gap:8px; flex-wrap:wrap; width: 100%;">
                    <span class="status-pill <?= e($paymentClass) ?>"><?= e($paymentStatusText) ?></span>
                </div>
            </div>

            <div class="order-timeline-container">
                <?php if ($isCancelled): ?>
                    <div class="order-timeline">
                        <div class="timeline-step cancelled">
                            <div class="timeline-icon">✕</div>
                            <div class="timeline-label">Đơn hàng đã bị hủy</div>
                        </div>
                    </div>
                <?php elseif ($isReturned): ?>
                    <div class="order-timeline">
                        <div class="timeline-step cancelled">
                            <div class="timeline-icon">↺</div>
                            <div class="timeline-label">Đơn hàng đang ở trạng thái trả hàng</div>
                        </div>
                    </div>
                <?php else: ?>
                    <?php 
                        $progressWidth = ($currentStepIndex > 0) ? ($currentStepIndex / (count($timelineSteps) - 1)) * 100 : 0; 
                    ?>
                    <div class="timeline-line" style="--mobile-progress: <?= $progressWidth ?>%;">
                        <div class="timeline-line-progress" style="width: <?= $progressWidth ?>%;"></div>
                    </div>
                    <div class="order-timeline">
                        <?php 
                        $i = 0;
                        foreach ($timelineSteps as $key => $label): 
                            $statusClass = '';
                            if ($i < $currentStepIndex) $statusClass = 'completed';
                            elseif ($i === $currentStepIndex) $statusClass = 'active';
                        ?>
                            <div class="timeline-step <?= $statusClass ?>">
                                <div class="timeline-icon">
                                    <?= ($i < $currentStepIndex) ? '✓' : ($i + 1) ?>
                                </div>
                                <div class="timeline-label"><?= e($label) ?></div>
                            </div>
                        <?php 
                            $i++;
                        endforeach; 
                        ?>
                    </div>
                <?php endif; ?>
            </div>

            <h2 class="section-title" style="font-size:18px; margin-bottom: 16px;">Chi tiết sản phẩm</h2>
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th style="text-align: center;">Số lượng</th>
                            <th style="text-align: right;">Đơn giá</th>
                            <th style="text-align: right;">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($items as $item): 
                            $variantInfo = $item['variant_name_snapshot'] ?? $item['variant_snapshot'] ?? $item['attributes'] ?? '';
                        ?>
                            <tr>
                                <td data-label="Sản phẩm">
                                    <strong style="color: #0f172a; display: block; margin-bottom: 4px;" class="word-break"><?= e($item['product_name_snapshot']) ?></strong>
                                    
                                    <?php if (!empty($variantInfo)): ?>
                                        <span class="variant-badge word-break">Phân loại: <?= e((string)$variantInfo) ?></span><br>
                                    <?php endif; ?>
                                    
                                    <span style="color:#64748b; font-size:13px; display: inline-block; margin-top: 4px;" class="word-break">Mã SP: <?= e($item['product_code_snapshot']) ?></span>
                                </td>
                                <td data-label="Số lượng" style="text-align: right; font-weight: 500;"><?= (int)$item['quantity'] ?></td>
                                <td data-label="Đơn giá" style="text-align: right;" class="word-break"><?= format_price($item['final_unit_price']) ?></td>
                                <td data-label="Thành tiền" style="text-align: right; font-weight: 600; color: #0f172a;" class="word-break"><?= format_price($item['line_total']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <div class="summary-box mt-24">
                <div class="flex-between"><span>Tổng tiền hàng:</span><strong class="word-break"><?= format_price($order['subtotal_amount']) ?></strong></div>
                <div class="flex-between mt-16"><span>Phí vận chuyển:</span><strong class="word-break"><?= format_price($order['shipping_fee']) ?></strong></div>
                <div class="flex-between mt-16" style="border-top: 1px dashed #cbd5e1; padding-top: 16px;">
                    <span>Tổng cộng:</span><strong style="font-size: 18px; color: #dc2626;" class="word-break"><?= format_price($order['total_amount']) ?></strong>
                </div>
                <div class="flex-between mt-16"><span>Đã thanh toán:</span><strong style="color: #10b981;" class="word-break"><?= format_price($order['paid_amount']) ?></strong></div>
                <div class="flex-between mt-16"><span>Số tiền còn lại:</span><strong class="word-break"><?= format_price($order['remaining_amount']) ?></strong></div>
            </div>

            <?php if ($address): ?>
                <div class="mt-24">
                    <h2 class="section-title" style="font-size:18px;">Địa chỉ nhận hàng</h2>
                    <div class="address-card" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px;">
                        
                        <div id="view-address-info">
                            <strong style="font-size: 15px; color: #0f172a;" class="word-break"><?= e($address['receiver_name']) ?> - <?= e($address['receiver_phone']) ?></strong>
                            <div style="margin-top:8px; color:#475569; line-height: 1.5;" class="word-break">
                                <?= e($address['address_line'] . ', ' . $address['ward_name'] . ', ' . $address['district_name'] . ', ' . $address['province_name']) ?>
                            </div>
                            <?php if (!empty($address['address_note'])): ?>
                                <div style="margin-top:8px; color:#ef4444; background: #fee2e2; padding: 8px 12px; border-radius: 6px; font-size: 13px;" class="word-break">
                                    <strong>Ghi chú:</strong> <?= e($address['address_note']) ?>
                                </div>
                            <?php endif; ?>
                            
                            <?php if ($currentOrderStatus === 'cho_xac_nhan'): ?>
                                <button type="button" class="btn-ghost" onclick="document.getElementById('edit-address-form').style.display='block'; document.getElementById('view-address-info').style.display='none';" style="margin-top: 12px; font-size: 13px; color: #3b82f6; padding: 6px 12px; background: #eff6ff; border-radius: 6px; border: 1px solid #bfdbfe;">
                                    ✎ Sửa địa chỉ nhận hàng
                                </button>
                            <?php endif; ?>
                        </div>

                        <?php if ($currentOrderStatus === 'cho_xac_nhan'): ?>
                            <form id="edit-address-form" method="post" style="display: none; margin-top: 8px;">
                                <?= function_exists('csrf_field') ? csrf_field() : '' ?>
                                <?= function_exists('public_form_field') ? public_form_field() : '' ?>
                                <input type="hidden" name="action" value="update_address">
                                
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 12px;">
                                    <div>
                                        <label class="form-label" style="font-size: 13px;">Tên người nhận <span style="color:red">*</span></label>
                                        <input type="text" name="receiver_name" class="form-control" value="<?= e($address['receiver_name']) ?>" required>
                                    </div>
                                    <div>
                                        <label class="form-label" style="font-size: 13px;">Số điện thoại <span style="color:red">*</span></label>
                                        <input type="tel" name="receiver_phone" class="form-control" value="<?= e($address['receiver_phone']) ?>" required>
                                    </div>
                                </div>

                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 12px;">
                                    <div>
                                        <label class="form-label" style="font-size: 13px;">Tỉnh / Thành phố <span style="color:red">*</span></label>
                                        <select name="province_name" id="select_province" class="form-control" required style="padding: 8px;">
                                            <option value="">Chọn Tỉnh/Thành phố</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label class="form-label" style="font-size: 13px;">Quận / Huyện <span style="color:red">*</span></label>
                                        <select name="district_name" id="select_district" class="form-control" required style="padding: 8px;">
                                            <option value="">Chọn Quận/Huyện</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label class="form-label" style="font-size: 13px;">Phường / Xã <span style="color:red">*</span></label>
                                        <select name="ward_name" id="select_ward" class="form-control" required style="padding: 8px;">
                                            <option value="">Chọn Phường/Xã</option>
                                        </select>
                                    </div>
                                </div>
                                
                                <div style="margin-bottom: 12px;">
                                    <label class="form-label" style="font-size: 13px;">Địa chỉ chi tiết (Số nhà, đường...) <span style="color:red">*</span></label>
                                    <input type="text" name="address_line" class="form-control" value="<?= e($address['address_line']) ?>" required>
                                </div>
                                <div style="margin-bottom: 16px;">
                                    <label class="form-label" style="font-size: 13px;">Ghi chú giao hàng</label>
                                    <textarea name="address_note" class="form-control" rows="2" placeholder="Giao giờ hành chính, gọi trước khi giao..."><?= e($address['address_note']) ?></textarea>
                                </div>
                                
                                <div style="display: flex; gap: 8px;">
                                    <button type="submit" class="btn-primary" style="padding: 8px 16px; font-size: 13px; flex: 1;">Lưu thay đổi</button>
                                    <button type="button" class="btn-secondary" style="padding: 8px 16px; font-size: 13px; flex: 1;" onclick="document.getElementById('edit-address-form').style.display='none'; document.getElementById('view-address-info').style.display='block';">Hủy</button>
                                </div>
                            </form>
                        <?php endif; ?>

                    </div>
                </div>
            <?php endif; ?>
        </div>

        <div class="order-card">
            <h2 class="section-title" style="font-size:20px;">Thông tin thanh toán</h2>

            <?php if ($currentPaymentStatus === 'chua_thanh_toan' && $currentOrderStatus === 'cho_xac_nhan'): ?>
                <div style="background: #fffbeb; border: 1px solid #fde68a; color: #d97706; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; display: flex; gap: 10px; align-items: flex-start; line-height: 1.5;">
                    <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="flex-shrink:0; margin-top:1px;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    <div><strong>Lưu ý quan trọng:</strong> Đơn hàng cần được <strong>thanh toán cọc hoặc toàn bộ</strong> để hệ thống tiến hành xác nhận và giao hàng cho bạn.</div>
                </div>
            <?php endif; ?>
            
            <?php if ($showPaymentQr): ?>
                <p class="section-subtitle" style="margin-bottom: 20px;">Vui lòng chuyển khoản đúng số tiền và nội dung để đơn hàng được tự động duyệt.</p>

                <div class="summary-box">
                    <div class="flex-between"><span>Phương thức:</span><strong class="word-break"><?= e($paymentPlanText) ?></strong></div>
                    <div class="flex-between mt-16"><span>Cần thanh toán:</span><strong style="font-size: 18px; color: #ef4444;" class="word-break"><?= format_price($qrRequestedAmount) ?></strong></div>
                    <div class="flex-between mt-16"><span>Ngân hàng:</span><strong class="word-break"><?= e($bankName) ?></strong></div>
                    <div class="flex-between mt-16"><span>Số tk:</span><strong style="font-size: 16px; color: #2563eb;" class="word-break"><?= e($bankAccountNo) ?></strong></div>
                    <div class="flex-between mt-16"><span>Chủ tk:</span><strong class="word-break"><?= e($bankAccountName) ?></strong></div>
                    
                    <div class="mt-16 p-4" style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px; text-align: center;">
                        <span style="color:#3b82f6; font-size: 13px; font-weight: 600;">NỘI DUNG CHUYỂN KHOẢN (BẮT BUỘC)</span>
                        <div class="word-break" style="font-weight:800; font-size:20px; color: #1e3a8a; margin-top:8px; letter-spacing: 1px;">
                            <?= e($qrTransferNote) ?>
                        </div>
                    </div>
                </div>

                <?php if ($qrImageUrl): ?>
                    <div class="address-card mt-24" style="text-align:center; background: #fff;">
                        <div style="font-weight:700; font-size:16px; margin-bottom:16px; color: #0f172a;">Quét mã QR để thanh toán</div>
                        
                        <img src="<?= e($qrImageUrl) ?>" alt="Mã QR Thanh Toán" style="max-width:200px; width:100%; border:2px solid #e2e8f0; border-radius:12px; padding:12px; box-shadow:0 8px 24px rgba(15,23,42,.06); margin: 0 auto; display: block;">
                        
                        <div style="margin-top: 16px;">
                            <button type="button" class="btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-size: 14px; padding: 8px 20px;" onclick="downloadQRCode('<?= e($qrImageUrl) ?>', 'Mã_QR_Thanh_Toan_<?= e($order['order_code']) ?>.png')">
                                <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path></svg>
                                Tải mã QR
                            </button>
                        </div>

                        <div style="margin-top:16px; color:#64748b; font-size:13px; line-height: 1.5;">
                            Quét mã QR qua ứng dụng ngân hàng hoặc ví điện tử. Tự động xác nhận sau 1-3 phút.
                        </div>
                    </div>
                <?php endif; ?>
            <?php else: ?>
                <?php
                    $paymentMessage = match ($currentPaymentStatus) {
                        'da_dat_coc' => ['#eff6ff', '#2563eb', 'Đơn hàng đã được ghi nhận tiền cọc. Phần còn lại sẽ thu khi giao hàng.'],
                        'da_thanh_toan' => ['#ecfdf5', '#10b981', 'Đơn hàng đã được thanh toán đầy đủ.'],
                        'cho_hoan_tien' => ['#fff7ed', '#ea580c', 'Đơn đã hủy/trả hàng và shop đang xử lý hoàn tiền.'],
                        'da_hoan_tien' => ['#eef2ff', '#4f46e5', 'Shop đã hoàn tiền xong cho đơn hàng này.'],
                        'chua_thanh_toan' => ['#f8fafc', '#64748b', 'Bạn đã chọn hình thức thanh toán khi nhận hàng (COD) hoặc thanh toán thủ công.'],
                        default => ['#f8fafc', '#64748b', 'Trạng thái thanh toán đang được cập nhật.'],
                    };
                ?>
                <div class="alert alert-success" style="display: flex; gap: 10px; padding: 16px; background: <?= e($paymentMessage[0]) ?>; border: 1px solid <?= e($paymentMessage[1]) ?>; color: <?= e($paymentMessage[1]) ?>; border-radius: 8px;">
                    <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="flex-shrink: 0;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    <div><strong><?= e($paymentStatusText) ?>.</strong> <?= e($paymentMessage[2]) ?></div>
                </div>
            <?php endif; ?>

            <div class="mt-32">
                <h3 class="section-title" style="font-size:16px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 16px;">Lịch sử giao dịch</h3>
                <?php if (!$payments): ?>
                    <div style="text-align: center; color: #94a3b8; padding: 20px 0; font-size: 14px;">Chưa có giao dịch thanh toán nào được ghi nhận.</div>
                <?php else: ?>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Mã GD</th>
                                    <th>Số tiền</th>
                                    <th>Kênh</th>
                                    <th style="text-align: right;">Thời gian</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($payments as $payment): ?>
                                    <tr>
                                        <td data-label="Mã GD" style="font-size: 13px; color: #475569;" class="word-break"><?= e($payment['provider_transaction_id']) ?></td>
                                        <td data-label="Số tiền" style="font-weight: 600; color: #10b981; text-align: right;" class="word-break"><?= format_price($payment['paid_amount']) ?></td>
                                        <td data-label="Kênh" style="text-align: right;"><span class="variant-badge"><?= e($payment['provider']) ?></span></td>
                                        <td data-label="Thời gian" style="text-align: right; font-size: 13px; color: #64748b;" class="word-break"><?= e(date('d/m/Y H:i', strtotime($payment['created_at']))) ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php endif; ?>
            </div>

            <div class="mt-24" style="display:flex; flex-direction: column; gap:12px; flex-wrap:wrap;">
                <a class="btn-secondary" href="<?= route_url('/index.php') ?>" style="text-align: center;">Tiếp tục mua sắm</a>
                <a class="btn-primary" target="_blank" rel="noopener noreferrer" href="<?= e(shop_zalo_link()) ?>" style="text-align: center; background: #0068ff; border-color: #0068ff; text-decoration: none;">Hỗ trợ qua Zalo</a>
                
                <?php if ($currentPaymentStatus === 'chua_thanh_toan' && $currentOrderStatus === 'cho_xac_nhan'): ?>
                    <form method="post" style="width: 100%; margin: 0;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này không? Thao tác này không thể hoàn tác.');">
                        <input type="hidden" name="action" value="cancel_order">
                        <?= function_exists('csrf_field') ? csrf_field() : '' ?>
                        <?= function_exists('public_form_field') ? public_form_field() : '' ?>
                        <button type="submit" class="btn-primary" style="background: #ef4444; border-color: #ef4444; width: 100%;">Hủy đơn hàng</button>
                    </form>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<script>
// Logic xử lý tải mã QR
async function downloadQRCode(imageUrl, fileName) {
    try {
        const response = await fetch(imageUrl);
        const blob = await response.blob();
        const blobUrl = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.style.display = 'none';
        a.href = blobUrl;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(blobUrl);
        document.body.removeChild(a);
    } catch (e) {
        window.open(imageUrl, '_blank');
    }
}

// Logic chọn Tỉnh / Huyện / Xã động
document.addEventListener('DOMContentLoaded', function() {
    const provinceSel = document.getElementById('select_province');
    const districtSel = document.getElementById('select_district');
    const wardSel = document.getElementById('select_ward');
    
    if (provinceSel && districtSel && wardSel) {
        let apiData = [];
        let isFirstLoad = true;
        
        // Lấy thông tin hiện tại từ database để tự động chọn lại
        const currentProv = <?= json_encode($address['province_name'] ?? '') ?>;
        const currentDist = <?= json_encode($address['district_name'] ?? '') ?>;
        const currentWard = <?= json_encode($address['ward_name'] ?? '') ?>;

        // Fetch toàn bộ dữ liệu từ Open API
        fetch('https://provinces.open-api.vn/api/?depth=3')
            .then(res => res.json())
            .then(data => {
                apiData = data;
                
                // Đổ dữ liệu Tỉnh
                data.forEach(p => {
                    let opt = new Option(p.name, p.name);
                    if (p.name === currentProv) opt.selected = true;
                    provinceSel.add(opt);
                });
                
                // Kích hoạt sự kiện change để tải danh sách Huyện
                provinceSel.dispatchEvent(new Event('change'));
            })
            .catch(err => console.error("Lỗi tải API Hành Chính:", err));

        // Khi đổi Tỉnh
        provinceSel.addEventListener('change', function() {
            districtSel.length = 1; // Reset Huyện
            wardSel.length = 1;     // Reset Xã
            
            const selectedProvince = apiData.find(x => x.name === this.value);
            if (selectedProvince && selectedProvince.districts) {
                selectedProvince.districts.forEach(d => {
                    let opt = new Option(d.name, d.name);
                    districtSel.add(opt);
                });
                
                if (isFirstLoad && currentDist) {
                    districtSel.value = currentDist;
                }
            }
            // Kích hoạt tiếp sự kiện change để tải Xã
            districtSel.dispatchEvent(new Event('change'));
        });

        // Khi đổi Huyện
        districtSel.addEventListener('change', function() {
            wardSel.length = 1; // Reset Xã
            
            const selectedProvince = apiData.find(x => x.name === provinceSel.value);
            if (selectedProvince) {
                const selectedDistrict = selectedProvince.districts.find(x => x.name === this.value);
                if (selectedDistrict && selectedDistrict.wards) {
                    selectedDistrict.wards.forEach(w => {
                        let opt = new Option(w.name, w.name);
                        wardSel.add(opt);
                    });
                    
                    if (isFirstLoad && currentWard) {
                        wardSel.value = currentWard;
                    }
                }
            }
            // Tắt cờ FirstLoad sau khi chuỗi auto-select chạy xong
            isFirstLoad = false;
        });
    }
});

<?php if ($showPaymentQr): ?>
(() => {
    const statusUrl = <?= json_encode(
        route_url('/order_status.php?code=' . urlencode($order['order_code']) .
        ($guestToken !== '' ? '&token=' . urlencode($guestToken) : ''))
    ) ?>;

    let lastPaymentStatus = <?= json_encode((string)$order['payment_status']) ?>;
    let isChecking = false;

    const checkPaymentStatus = async () => {
        if (isChecking) return;
        isChecking = true;

        try {
            const response = await fetch(statusUrl, {
                method: 'GET',
                cache: 'no-store',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });

            if (!response.ok) return;

            const data = await response.json();
            if (!data || !data.ok) return;

            if (data.payment_status !== lastPaymentStatus) {
                window.location.reload();
            }
        } catch (error) {
            console.warn('Đang chờ hệ thống ghi nhận thanh toán...', error);
        } finally {
            isChecking = false;
        }
    };

    setInterval(checkPaymentStatus, 5000);
})();
<?php endif; ?>
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>