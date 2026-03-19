<?php
require_once __DIR__ . '/includes/functions.php';

$orderCode = trim((string)($_GET['code'] ?? ''));
$guestToken = trim((string)($_GET['token'] ?? ''));
$customer = current_customer();
$order = $orderCode !== '' ? get_order_by_code_for_view($orderCode, $customer['id'] ?? null, $guestToken !== '' ? $guestToken : null) : null;

if (!$order) {
    http_response_code(404);
    exit('Không tìm thấy đơn hàng hoặc bạn không có quyền xem thông tin đơn hàng này.');
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
$qrImageUrl = $intent ? ($intent['qr_image_url'] ?: sepay_qr_url((float)$intent['requested_amount'], (string)$intent['transfer_note'])) : '';

require_once __DIR__ . '/includes/header.php';

$statusMap = order_status_options();
$paymentMap = payment_status_options();
$currentOrderStatus = strtolower((string)$order['order_status']);
$currentPaymentStatus = strtolower((string)$order['payment_status']);
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

$intentStatus = strtolower((string)($intent['status'] ?? ''));
$showPaymentQr = $intent
    && $currentPaymentStatus === 'chua_thanh_toan'
    && in_array($intentStatus, ['pending', 'waiting_payment'], true)
    && in_array($currentOrderStatus, ['cho_xac_nhan', 'dang_chuan_bi'], true);

$paymentPlanText = payment_plan_label((string)$order['payment_plan']);
?>

<style>
    /* CSS Tối ưu Timeline & Mobile */
    .order-timeline-container { position: relative; margin: 30px 0 40px; }
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
    
    /* Responsive Table */
    .table-responsive { width: 100%; overflow-x: auto; -webkit-overflow-scrolling: touch; border-radius: 8px; }
    .table-responsive table { width: 100%; min-width: 500px; }

    /* Mobile Optimization */
    @media (max-width: 768px) {
        .grid-2 { grid-template-columns: 1fr; gap: 20px; }
        .order-timeline-container { margin: 20px 0; }
        .order-timeline { flex-direction: column; align-items: flex-start; gap: 20px; }
        .timeline-line { width: 3px; height: auto; top: 10px; bottom: 10px; left: 17px; right: auto; }
        .timeline-line-progress { width: 100%; height: 0; } /* Chiều cao tiến trình sẽ được tính toán qua JS nếu cần, nhưng ở Mobile ta dùng flex-direction column nên bỏ line cũng được */
        
        .timeline-step { flex-direction: row; gap: 16px; align-items: center; width: 100%; text-align: left; }
        .timeline-icon { margin-bottom: 0; }
        
        .summary-box .flex-between { flex-wrap: wrap; }
    }
</style>

<div class="order-shell" style="padding-top:24px;">
    <div class="grid-2">
        <div class="order-card">
            <div class="flex-between" style="align-items: flex-start; margin-bottom: 24px;">
                <div>
                    <h1 class="section-title">Mã đơn: <?= e($order['order_code']) ?></h1>
                    <p class="section-subtitle">Ngày đặt: <?= e(date('d/m/Y - H:i', strtotime($order['placed_at']))) ?></p>
                </div>
                <div style="display:flex; gap:8px; flex-wrap:wrap; justify-content:flex-end;">
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
                    <div class="timeline-line">
                        <?php 
                            $progressWidth = ($currentStepIndex > 0) ? ($currentStepIndex / (count($timelineSteps) - 1)) * 100 : 0; 
                        ?>
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
                            // Thử lấy thông tin biến thể từ các cấu trúc dữ liệu phổ biến
                            $variantInfo = $item['variant_name_snapshot'] ?? $item['variant_snapshot'] ?? $item['attributes'] ?? '';
                        ?>
                            <tr>
                                <td>
                                    <strong style="color: #0f172a;"><?= e($item['product_name_snapshot']) ?></strong><br>
                                    
                                    <?php if (!empty($variantInfo)): ?>
                                        <span class="variant-badge">Phân loại: <?= e((string)$variantInfo) ?></span><br>
                                    <?php endif; ?>
                                    
                                    <span style="color:#64748b; font-size:13px;">Mã SP: <?= e($item['product_code_snapshot']) ?></span>
                                </td>
                                <td style="text-align: center; font-weight: 500;"><?= (int)$item['quantity'] ?></td>
                                <td style="text-align: right;"><?= format_price($item['final_unit_price']) ?></td>
                                <td style="text-align: right; font-weight: 600; color: #0f172a;"><?= format_price($item['line_total']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <div class="summary-box mt-24">
                <div class="flex-between"><span>Tổng tiền hàng:</span><strong><?= format_price($order['subtotal_amount']) ?></strong></div>
                <div class="flex-between mt-16"><span>Phí vận chuyển:</span><strong><?= format_price($order['shipping_fee']) ?></strong></div>
                <div class="flex-between mt-16" style="border-top: 1px dashed #cbd5e1; padding-top: 16px;">
                    <span>Tổng cộng:</span><strong style="font-size: 18px; color: #dc2626;"><?= format_price($order['total_amount']) ?></strong>
                </div>
                <div class="flex-between mt-16"><span>Đã thanh toán:</span><strong style="color: #10b981;"><?= format_price($order['paid_amount']) ?></strong></div>
                <div class="flex-between mt-16"><span>Số tiền còn lại:</span><strong><?= format_price($order['remaining_amount']) ?></strong></div>
            </div>

            <?php if ($address): ?>
                <div class="mt-24">
                    <h2 class="section-title" style="font-size:18px;">Địa chỉ nhận hàng</h2>
                    <div class="address-card" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px;">
                        <strong style="font-size: 15px; color: #0f172a;"><?= e($address['receiver_name']) ?> - <?= e($address['receiver_phone']) ?></strong>
                        <div style="margin-top:8px; color:#475569; line-height: 1.5;">
                            <?= e($address['address_line'] . ', ' . $address['ward_name'] . ', ' . $address['district_name'] . ', ' . $address['province_name']) ?>
                        </div>
                        <?php if (!empty($address['address_note'])): ?>
                            <div style="margin-top:8px; color:#ef4444; background: #fee2e2; padding: 8px 12px; border-radius: 6px; font-size: 13px;">
                                <strong>Ghi chú:</strong> <?= e($address['address_note']) ?>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>
            <?php endif; ?>
        </div>

        <div class="order-card">
            <h2 class="section-title" style="font-size:20px;">Thông tin thanh toán</h2>
            
            <?php if ($showPaymentQr): ?>
                <p class="section-subtitle" style="margin-bottom: 20px;">Hệ thống đã tạo mã thanh toán tự động, vui lòng chuyển khoản đúng nội dung để đơn hàng được duyệt tự động.</p>

                <div class="summary-box">
                    <div class="flex-between"><span>Phương thức:</span><strong><?= e($paymentPlanText) ?></strong></div>
                    <div class="flex-between mt-16"><span>Cần thanh toán:</span><strong style="font-size: 18px; color: #ef4444;"><?= format_price($intent['requested_amount']) ?></strong></div>
                    <div class="flex-between mt-16"><span>Ngân hàng:</span><strong><?= e($bankName) ?></strong></div>
                    <div class="flex-between mt-16"><span>Số tài khoản:</span><strong style="font-size: 16px; color: #2563eb;"><?= e($bankAccountNo) ?></strong></div>
                    <div class="flex-between mt-16"><span>Chủ tài khoản:</span><strong><?= e($bankAccountName) ?></strong></div>
                    
                    <div class="mt-16 p-4" style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px; text-align: center;">
                        <span style="color:#3b82f6; font-size: 13px; font-weight: 600;">NỘI DUNG CHUYỂN KHOẢN (BẮT BUỘC)</span>
                        <div style="font-weight:800; font-size:20px; color: #1e3a8a; margin-top:8px; letter-spacing: 1px;">
                            <?= e($intent['transfer_note']) ?>
                        </div>
                    </div>
                </div>

                <?php if ($qrImageUrl): ?>
                    <div class="address-card mt-24" style="text-align:center; background: #fff;">
                        <div style="font-weight:700; font-size:16px; margin-bottom:16px; color: #0f172a;">Quét mã QR để thanh toán nhanh</div>
                        <img src="<?= e($qrImageUrl) ?>" alt="Mã QR Thanh Toán" style="max-width:250px; width:100%; border:2px solid #e2e8f0; border-radius:12px; padding:12px; box-shadow:0 8px 24px rgba(15,23,42,.06);">
                        <div style="margin-top:16px; color:#64748b; font-size:13px; line-height: 1.5;">
                            Quét mã QR qua ứng dụng ngân hàng hoặc ví điện tử. Hệ thống sẽ tự động xác nhận đơn hàng sau 1-3 phút kể từ khi bạn chuyển khoản thành công.
                        </div>
                    </div>
                <?php endif; ?>
            <?php else: ?>
                <?php
                    $paymentMessage = match ($currentPaymentStatus) {
                        'da_dat_coc' => ['#eff6ff', '#2563eb', 'Đơn hàng đã được ghi nhận tiền cọc. Phần còn lại sẽ thu khi giao hàng hoặc theo cách shop xác nhận với bạn.'],
                        'da_thanh_toan' => ['#ecfdf5', '#10b981', 'Đơn hàng đã được ghi nhận thanh toán 100%.'],
                        'cho_hoan_tien' => ['#fff7ed', '#ea580c', 'Đơn đã hủy/trả hàng và shop đang xử lý hoàn tiền cho bạn.'],
                        'da_hoan_tien' => ['#eef2ff', '#4f46e5', 'Shop đã hoàn tiền xong cho đơn hàng này.'],
                        default => ['#f8fafc', '#64748b', 'Đơn hiện chưa có yêu cầu thanh toán trực tuyến đang chờ xử lý.'],
                    };
                ?>
                <div class="alert alert-success" style="display: flex; align-items: center; gap: 10px; padding: 16px; background: <?= e($paymentMessage[0]) ?>; border: 1px solid <?= e($paymentMessage[1]) ?>; color: <?= e($paymentMessage[1]) ?>; border-radius: 8px;">
                    <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    <strong><?= e($paymentStatusText) ?>.</strong> <?= e($paymentMessage[2]) ?>
                </div>
            <?php endif; ?>

            <div class="mt-32">
                <h3 class="section-title" style="font-size:16px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 16px;">Lịch sử giao dịch</h3>
                <?php if (!$payments): ?>
                    <div style="text-align: center; color: #94a3b8; padding: 20px 0; font-size: 14px;">Chưa có giao dịch thanh toán nào.</div>
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
                                        <td style="font-size: 13px; color: #475569;"><?= e($payment['provider_transaction_id']) ?></td>
                                        <td style="font-weight: 600; color: #10b981;"><?= format_price($payment['paid_amount']) ?></td>
                                        <td><span class="variant-badge"><?= e($payment['provider']) ?></span></td>
                                        <td style="text-align: right; font-size: 13px; color: #64748b;"><?= e(date('d/m/Y H:i', strtotime($payment['created_at']))) ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php endif; ?>
            </div>

            <div class="mt-24" style="display:flex; gap:12px; flex-wrap:wrap;">
                <a class="btn-secondary" href="<?= route_url('/index.php') ?>" style="flex: 1; text-align: center;">Tiếp tục mua sắm</a>
                <a class="btn-primary" target="_blank" rel="noopener noreferrer" href="<?= e(shop_zalo_link()) ?>" style="flex: 1; text-align: center; background: #0068ff; border-color: #0068ff;">Hỗ trợ qua Zalo</a>
            </div>
        </div>
    </div>
</div>

<?php if ($showPaymentQr): ?>
<script>
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

            // Nếu trạng thái thanh toán thay đổi (ví dụ: đang chờ -> đã thanh toán)
            if (data.payment_status !== lastPaymentStatus) {
                // Tải lại trang để cập nhật toàn bộ giao diện mới nhất
                window.location.reload();
            }
        } catch (error) {
            console.warn('Đang chờ hệ thống ghi nhận thanh toán...', error);
        } finally {
            isChecking = false;
        }
    };

    // Tự động kiểm tra trạng thái mỗi 5 giây
    setInterval(checkPaymentStatus, 5000);
})();
</script>
<?php endif; ?>

<?php require_once __DIR__ . '/includes/footer.php'; ?>