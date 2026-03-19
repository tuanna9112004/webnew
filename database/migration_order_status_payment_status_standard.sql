-- Chuẩn hóa trạng thái đơn hàng + thanh toán theo luồng vận hành mới
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE orders
  MODIFY payment_status ENUM('chua_thanh_toan','da_dat_coc','da_thanh_toan','cho_hoan_tien','da_hoan_tien') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'chua_thanh_toan',
  MODIFY order_status ENUM('cho_xac_nhan','dang_chuan_bi','dang_giao','da_giao','da_huy','tra_hang') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cho_xac_nhan';

UPDATE orders
SET order_status = CASE order_status
    WHEN 'pending_confirmation' THEN 'cho_xac_nhan'
    WHEN 'confirmed' THEN 'dang_chuan_bi'
    WHEN 'processing' THEN 'dang_chuan_bi'
    WHEN 'shipping' THEN 'dang_giao'
    WHEN 'completed' THEN 'da_giao'
    WHEN 'cancelled' THEN 'da_huy'
    ELSE order_status
END;

UPDATE orders
SET payment_status = CASE
    WHEN payment_status = 'refunded' THEN 'da_hoan_tien'
    WHEN order_status IN ('da_huy', 'tra_hang') AND payment_status IN ('paid', 'deposit_paid', 'partially_paid') THEN 'cho_hoan_tien'
    WHEN payment_status = 'paid' THEN 'da_thanh_toan'
    WHEN payment_status IN ('deposit_paid', 'partially_paid') THEN 'da_dat_coc'
    ELSE 'chua_thanh_toan'
END;

UPDATE orders
SET remaining_amount = CASE
    WHEN payment_status IN ('da_thanh_toan', 'cho_hoan_tien', 'da_hoan_tien') THEN 0
    WHEN payment_status = 'da_dat_coc' THEN GREATEST(total_amount - paid_amount, 0)
    WHEN order_status IN ('da_huy', 'tra_hang') THEN 0
    ELSE total_amount
END;

UPDATE order_status_logs
SET from_status = CASE from_status
    WHEN 'pending_confirmation' THEN 'cho_xac_nhan'
    WHEN 'confirmed' THEN 'dang_chuan_bi'
    WHEN 'processing' THEN 'dang_chuan_bi'
    WHEN 'shipping' THEN 'dang_giao'
    WHEN 'completed' THEN 'da_giao'
    WHEN 'cancelled' THEN 'da_huy'
    ELSE from_status
END,
    to_status = CASE to_status
    WHEN 'pending_confirmation' THEN 'cho_xac_nhan'
    WHEN 'confirmed' THEN 'dang_chuan_bi'
    WHEN 'processing' THEN 'dang_chuan_bi'
    WHEN 'shipping' THEN 'dang_giao'
    WHEN 'completed' THEN 'da_giao'
    WHEN 'cancelled' THEN 'da_huy'
    ELSE to_status
END;

SET FOREIGN_KEY_CHECKS = 1;
