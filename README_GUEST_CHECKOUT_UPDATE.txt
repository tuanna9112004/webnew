BẢN UPDATE 2026-03-20

Các thay đổi chính:
- Thêm public_form_token cho flow guest/cart/checkout để giảm lỗi session CSRF trong webview.
- Dựng mới checkout.php cho 2 mode: checkout từ giỏ và mua ngay 1 sản phẩm.
- Thêm request_id chống tạo trùng đơn khi khách bấm nhiều lần.
- Thêm order_lookup.php tra cứu đơn bằng mã đơn + số điện thoại.
- Vá CSRF cho action hủy đơn trong order.php.
- Gắn đơn guest vào tài khoản sau khi khách đăng nhập/đăng ký.
- Cập nhật schema orders có cột request_id.

Lưu ý database:
- Nếu database hiện tại chưa có cột request_id ở bảng orders, hãy chạy lại database/taobang.sql
  hoặc tự ALTER:
    ALTER TABLE orders ADD COLUMN request_id VARCHAR(64) NULL AFTER guest_access_token;
    ALTER TABLE orders ADD UNIQUE KEY uq_orders_request_id (request_id);
