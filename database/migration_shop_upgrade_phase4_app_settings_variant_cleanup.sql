-- PHASE 4: app_settings đầy đủ + dọn legacy size/color nếu còn tồn tại
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS app_settings (
  setting_key VARCHAR(100) NOT NULL,
  setting_value TEXT NOT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO app_settings (setting_key, setting_value, updated_at) VALUES
('shop_name', 'Duong Mot Mi SHOP', NOW()),
('shop_tagline', 'Khám phá phong cách thời trang trẻ trung, hiện đại. Chúng tôi cam kết mang đến cho bạn những sản phẩm chất lượng với dịch vụ chốt đơn nhanh chóng, tận tâm.', NOW()),
('shop_logo', 'img/logo.jpg', NOW()),
('shop_phone', '0961.691.107', NOW()),
('shop_email', '', NOW()),
('shop_address', 'Sớm cập nhật', NOW()),
('shop_working_hours', '08:00 - 22:00 (T2 - CN)', NOW()),
('default_deposit_rate', '30', NOW()),
('enable_guest_checkout', '1', NOW()),
('enable_wallet', '1', NOW()),
('enable_social_login_google', '1', NOW()),
('enable_social_login_facebook', '1', NOW()),
('zalo_contact_link', 'https://zalo.me/0961691107', NOW()),
('zalo_group_link', '', NOW()),
('facebook_link', '', NOW()),
('instagram_link', '', NOW()),
('tiktok_link', '', NOW()),
('sepay_bank_name', '', NOW()),
('sepay_bank_account_no', '', NOW()),
('sepay_account_name', '', NOW())
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_at = NOW();

-- xóa cột size/color legacy nếu còn tồn tại trong DB cũ
SET @has_size := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'products' AND COLUMN_NAME = 'size');
SET @sql := IF(@has_size > 0, 'ALTER TABLE products DROP COLUMN size', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @has_color := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'products' AND COLUMN_NAME = 'color');
SET @sql := IF(@has_color > 0, 'ALTER TABLE products DROP COLUMN color', 'SELECT 1');
PREPARE stmt2 FROM @sql; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;

SET FOREIGN_KEY_CHECKS = 1;
