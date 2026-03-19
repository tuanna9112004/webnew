SEPAY AUTO PAYMENT - BẢN ĐÃ GHÉP

Các file đã cập nhật:
- callback_atm.php
- webhooks/sepay.php
- includes/shop_upgrade.php
- order.php
- order_status.php (mới)

Cấu hình SePay nên dùng:
- URL webhook: https://ten-mien-cua-ban/webhooks/sepay.php
  hoặc giữ URL cũ callback_atm.php vì file này đã proxy sang webhook chính.
- Bắn webhook khi: Có tiền vào
- Lọc theo tài khoản ảo: bật
- Sub account / VA: VQRQAHSJJ1234
- Ngân hàng: MBBank
- Gọi lại webhook nếu HTTP status code ngoài 200-299: bật

App settings cần kiểm tra trong admin:
- sepay_bank_name = MBBank
- sepay_bank_code = MBBank
- sepay_bank_account_no = VQRQAHSJJ1234
- sepay_account_name = NGUYEN TUNG DUONG
- sepay_expected_sub_account = VQRQAHSJJ1234
- sepay_webhook_api_key = để trống nếu SePay không gửi Authorization, hoặc nhập đúng API key nếu SePay có chứng thực.

Luồng đã hỗ trợ:
1. Webhook VA/chuyển khoản ngân hàng của SePay
2. IPN Payment Gateway dạng ORDER_PAID
3. Trang order tự kiểm tra trạng thái thanh toán mỗi 5 giây
