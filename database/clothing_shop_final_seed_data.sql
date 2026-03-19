SET NAMES utf8mb4;
USE `clothing_shop`;

-- =========================================================
-- clothing_shop_phase4_seed_data.sql
-- Demo seed data for phase 4 schema (settings + variants + cart + checkout)
-- Import after clothing_shop_phase4_full_create_database.sql
-- Best used on a fresh database.
-- =========================================================

SET NAMES utf8mb4;
USE `clothing_shop`;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------
-- Optional cleanup for repeat imports
-- ---------------------------------------------------------
DELETE FROM `admin_audit_logs`;
DELETE FROM `wallet_ledger`;
DELETE FROM `wallet_topup_requests`;
DELETE FROM `wallet_accounts`;
DELETE FROM `payment_webhook_logs`;
DELETE FROM `payments`;
DELETE FROM `payment_intents`;
DELETE FROM `order_status_logs`;
DELETE FROM `order_items`;
DELETE FROM `order_addresses`;
DELETE FROM `orders`;
DELETE FROM `cart_items`;
DELETE FROM `carts`;
DELETE FROM `customer_security_logs`;
DELETE FROM `customer_auth_tokens`;
DELETE FROM `customer_sessions`;
DELETE FROM `customer_addresses`;
DELETE FROM `customer_oauth_accounts`;
DELETE FROM `customers`;
DELETE FROM `inventory_movements`;
DELETE FROM `product_variants`;
DELETE FROM `product_condition_maps`;
DELETE FROM `product_images`;
DELETE FROM `products`;
DELETE FROM `product_conditions`;
DELETE FROM `product_types`;
DELETE FROM `styles`;
DELETE FROM `categories`;
DELETE FROM `admins`;

ALTER TABLE `admins` AUTO_INCREMENT = 1;
ALTER TABLE `categories` AUTO_INCREMENT = 1;
ALTER TABLE `styles` AUTO_INCREMENT = 1;
ALTER TABLE `product_conditions` AUTO_INCREMENT = 1;
ALTER TABLE `product_types` AUTO_INCREMENT = 1;
ALTER TABLE `products` AUTO_INCREMENT = 1;
ALTER TABLE `product_images` AUTO_INCREMENT = 1;
ALTER TABLE `product_variants` AUTO_INCREMENT = 1;
ALTER TABLE `inventory_movements` AUTO_INCREMENT = 1;
ALTER TABLE `customers` AUTO_INCREMENT = 1;
ALTER TABLE `customer_oauth_accounts` AUTO_INCREMENT = 1;
ALTER TABLE `customer_addresses` AUTO_INCREMENT = 1;
ALTER TABLE `customer_sessions` AUTO_INCREMENT = 1;
ALTER TABLE `customer_auth_tokens` AUTO_INCREMENT = 1;
ALTER TABLE `customer_security_logs` AUTO_INCREMENT = 1;
ALTER TABLE `carts` AUTO_INCREMENT = 1;
ALTER TABLE `cart_items` AUTO_INCREMENT = 1;
ALTER TABLE `orders` AUTO_INCREMENT = 1;
ALTER TABLE `order_addresses` AUTO_INCREMENT = 1;
ALTER TABLE `order_items` AUTO_INCREMENT = 1;
ALTER TABLE `order_status_logs` AUTO_INCREMENT = 1;
ALTER TABLE `payment_intents` AUTO_INCREMENT = 1;
ALTER TABLE `payments` AUTO_INCREMENT = 1;
ALTER TABLE `payment_webhook_logs` AUTO_INCREMENT = 1;
ALTER TABLE `wallet_accounts` AUTO_INCREMENT = 1;
ALTER TABLE `wallet_topup_requests` AUTO_INCREMENT = 1;
ALTER TABLE `wallet_ledger` AUTO_INCREMENT = 1;
ALTER TABLE `admin_audit_logs` AUTO_INCREMENT = 1;

-- ---------------------------------------------------------
-- Admin
-- login: admin / admin123
-- ---------------------------------------------------------
INSERT INTO `admins`
(`id`, `username`, `password_hash`, `full_name`, `status`, `last_login_at`, `created_at`, `updated_at`)
VALUES
(1, 'admin', '$2y$12$UVlOTrXu8r6UE0iwlrFp6usIvPbRlE7/uZA4klsEs3KZ/5AVxZmiO', 'Quản trị viên', 'active', '2026-03-18 21:00:00', NOW(), NOW());

-- ---------------------------------------------------------
-- Catalog master data
-- ---------------------------------------------------------
INSERT INTO `categories`
(`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`)
VALUES
(1, 'Áo', 'ao', 1, 1, NOW(), NOW()),
(2, 'Quần', 'quan', 2, 1, NOW(), NOW()),
(3, 'Giày', 'giay', 3, 1, NOW(), NOW()),
(4, 'Túi xách', 'tui-xach', 4, 1, NOW(), NOW());

INSERT INTO `styles`
(`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`)
VALUES
(1, 'Basic', 'basic', 1, 1, NOW(), NOW()),
(2, 'Streetwear', 'streetwear', 2, 1, NOW(), NOW()),
(3, 'Vintage', 'vintage', 3, 1, NOW(), NOW()),
(4, 'Thanh lịch', 'thanh-lich', 4, 1, NOW(), NOW());

INSERT INTO `product_conditions`
(`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`)
VALUES
(1, 'Hàng mới', 'hang-moi', 1, 1, NOW(), NOW()),
(2, 'Best seller', 'best-seller', 2, 1, NOW(), NOW()),
(3, 'Flash sale', 'flash-sale', 3, 1, NOW(), NOW());

INSERT INTO `product_types`
(`id`, `category_id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`)
VALUES
(1, 1, 'Áo thun', 'ao-thun', 1, 1, NOW(), NOW()),
(2, 1, 'Áo sơ mi', 'ao-so-mi', 2, 1, NOW(), NOW()),
(3, 1, 'Áo khoác', 'ao-khoac', 3, 1, NOW(), NOW()),
(4, 2, 'Quần jean', 'quan-jean', 1, 1, NOW(), NOW()),
(5, 2, 'Quần short', 'quan-short', 2, 1, NOW(), NOW()),
(6, 2, 'Chân váy', 'chan-vay', 3, 1, NOW(), NOW()),
(7, 3, 'Sneaker', 'sneaker', 1, 1, NOW(), NOW()),
(8, 3, 'Giày búp bê', 'giay-bup-be', 2, 1, NOW(), NOW()),
(9, 4, 'Túi tote', 'tui-tote', 1, 1, NOW(), NOW()),
(10, 4, 'Túi đeo chéo', 'tui-deo-cheo', 2, 1, NOW(), NOW());

-- ---------------------------------------------------------
-- Products
-- ---------------------------------------------------------
INSERT INTO `products`
(`id`, `product_name`, `slug`, `product_code`, `category_id`, `product_type_id`, `style_id`, `gender`, `original_price`, `sale_price`, `purchase_price`, `note`, `material`, `information`, `short_description`, `quantity`, `track_inventory`, `allow_backorder`, `min_stock_alert`, `supplier_contact`, `import_link`, `thumbnail`, `is_active`, `published_at`, `deleted_at`, `created_at`, `updated_at`)
VALUES
(1, 'Áo thun gân tăm basic', 'ao-thun-gan-tam-basic', 'AO_001', 1, 1, 1, 'Nữ', 120000, 99000, 55000, 'Mẫu bán chạy quanh năm', 'Thun gân', 'Áo thun gân tăm co giãn tốt, form ôm nhẹ, dễ phối với chân váy hoặc quần jean.', 'Áo thun nữ form ôm basic, dễ phối đồ.', 38, 1, 0, 5, 'Kho sỉ Quận 5', 'https://zalo.me/0961691107', '/uploads/products/ao_001_main.jpg', 1, NOW(), NULL, NOW(), NOW()),
(2, 'Áo sơ mi linen oversize', 'ao-so-mi-linen-oversize', 'AO_002', 1, 2, 4, 'Unisex', 280000, 249000, 145000, 'Mát, dễ lên ảnh', 'Linen pha cotton', 'Áo sơ mi tay dài form rộng, chất vải thoáng, phù hợp đi làm hoặc đi chơi.', 'Sơ mi linen form rộng thanh lịch.', 18, 1, 0, 3, 'Xưởng Bình Tân', 'https://zalo.me/0961691107', '/uploads/products/ao_002_main.jpg', 1, NOW(), NULL, NOW(), NOW()),
(3, 'Quần jean ống suông cạp cao', 'quan-jean-ong-suong-cap-cao', 'QUAN_001', 2, 4, 2, 'Nữ', 320000, 289000, 180000, 'Tôn dáng, dễ bán online', 'Jean cotton', 'Quần jean ống suông cạp cao, tôn dáng, hợp với nhiều kiểu áo basic.', 'Jean ống suông cạp cao, hack dáng.', 26, 1, 0, 4, 'Kho sỉ Tân Bình', 'https://zalo.me/0961691107', '/uploads/products/quan_001_main.jpg', 1, NOW(), NULL, NOW(), NOW()),
(4, 'Váy midi hoa vintage', 'vay-midi-hoa-vintage', 'VAY_001', 2, 6, 3, 'Nữ', 350000, 315000, 190000, 'Ảnh lookbook đẹp', 'Voan lót cotton', 'Váy midi họa tiết hoa nhí phong cách vintage, thích hợp dạo phố và đi biển.', 'Váy midi nữ tính, phong cách vintage.', 12, 1, 0, 2, 'Kho Đà Lạt', 'https://zalo.me/0961691107', '/uploads/products/vay_001_main.jpg', 1, NOW(), NULL, NOW(), NOW()),
(5, 'Sneaker trắng tối giản', 'sneaker-trang-toi-gian', 'GIAY_001', 3, 7, 1, 'Unisex', 590000, 520000, 340000, 'Mẫu dễ bán cho cả nam nữ', 'Da tổng hợp', 'Sneaker trắng thiết kế tối giản, dễ phối đồ, đế êm và nhẹ.', 'Sneaker trắng basic cho outfit hằng ngày.', 14, 1, 0, 2, 'Kho Giày Bình Dương', 'https://zalo.me/0961691107', '/uploads/products/giay_001_main.jpg', 1, NOW(), NULL, NOW(), NOW()),
(6, 'Túi tote canvas mini', 'tui-tote-canvas-mini', 'TUI_001', 4, 9, 1, 'Nữ', 210000, 179000, 95000, 'Phụ kiện mua kèm tốt', 'Canvas dày', 'Túi tote canvas mini gọn nhẹ, phù hợp đi học và đi chơi.', 'Túi tote mini dễ phối đồ.', 22, 1, 0, 3, 'Kho phụ kiện Q10', 'https://zalo.me/0961691107', '/uploads/products/tui_001_main.jpg', 1, NOW(), NULL, NOW(), NOW());

INSERT INTO `product_images`
(`id`, `product_id`, `image_url`, `sort_order`, `created_at`)
VALUES
(1, 1, '/uploads/products/ao_001_main.jpg', 1, NOW()),
(2, 1, '/uploads/products/ao_001_2.jpg', 2, NOW()),
(3, 1, '/uploads/products/ao_001_3.jpg', 3, NOW()),
(4, 2, '/uploads/products/ao_002_main.jpg', 1, NOW()),
(5, 2, '/uploads/products/ao_002_2.jpg', 2, NOW()),
(6, 3, '/uploads/products/quan_001_main.jpg', 1, NOW()),
(7, 3, '/uploads/products/quan_001_2.jpg', 2, NOW()),
(8, 4, '/uploads/products/vay_001_main.jpg', 1, NOW()),
(9, 5, '/uploads/products/giay_001_main.jpg', 1, NOW()),
(10, 5, '/uploads/products/giay_001_2.jpg', 2, NOW()),
(11, 6, '/uploads/products/tui_001_main.jpg', 1, NOW());

INSERT INTO `product_condition_maps`
(`product_id`, `condition_id`, `sort_order`, `created_at`)
VALUES
(1, 2, 1, NOW()),
(1, 3, 2, NOW()),
(2, 1, 1, NOW()),
(3, 2, 1, NOW()),
(4, 1, 1, NOW()),
(5, 2, 1, NOW()),
(6, 3, 1, NOW());

-- Phase 4: sample variants include full color x size matrix for product 1
INSERT INTO `product_variants`
(`id`, `product_id`, `sku`, `variant_name`, `size_value`, `color_value`, `original_price`, `sale_price`, `purchase_price`, `stock_qty`, `image_url`, `is_default`, `is_active`, `created_at`, `updated_at`)
VALUES
(1, 1, 'AO001-XANH-S', 'Xanh / S', 'S', 'Xanh', 120000, 99000, 55000, 3, '/uploads/products/ao_001_main.jpg', 1, 1, NOW(), NOW()),
(2, 1, 'AO001-XANH-M', 'Xanh / M', 'M', 'Xanh', 120000, 99000, 55000, 3, '/uploads/products/ao_001_main.jpg', 0, 1, NOW(), NOW()),
(3, 1, 'AO001-XANH-L', 'Xanh / L', 'L', 'Xanh', 120000, 99000, 55000, 3, '/uploads/products/ao_001_main.jpg', 0, 1, NOW(), NOW()),
(4, 1, 'AO001-DO-S', 'Đỏ / S', 'S', 'Đỏ', 120000, 99000, 55000, 3, '/uploads/products/ao_001_2.jpg', 0, 1, NOW(), NOW()),
(5, 1, 'AO001-DO-M', 'Đỏ / M', 'M', 'Đỏ', 120000, 99000, 55000, 3, '/uploads/products/ao_001_2.jpg', 0, 1, NOW(), NOW()),
(6, 1, 'AO001-DO-L', 'Đỏ / L', 'L', 'Đỏ', 120000, 99000, 55000, 3, '/uploads/products/ao_001_2.jpg', 0, 1, NOW(), NOW()),
(7, 1, 'AO001-TIM-S', 'Tím / S', 'S', 'Tím', 120000, 99000, 55000, 3, '/uploads/products/ao_001_3.jpg', 0, 1, NOW(), NOW()),
(8, 1, 'AO001-TIM-M', 'Tím / M', 'M', 'Tím', 120000, 99000, 55000, 3, '/uploads/products/ao_001_3.jpg', 0, 1, NOW(), NOW()),
(9, 1, 'AO001-TIM-L', 'Tím / L', 'L', 'Tím', 120000, 99000, 55000, 3, '/uploads/products/ao_001_3.jpg', 0, 1, NOW(), NOW()),
(10, 1, 'AO001-VANG-S', 'Vàng / S', 'S', 'Vàng', 120000, 99000, 55000, 4, '/uploads/products/ao_001_main.jpg', 0, 1, NOW(), NOW()),
(11, 1, 'AO001-VANG-M', 'Vàng / M', 'M', 'Vàng', 120000, 99000, 55000, 4, '/uploads/products/ao_001_main.jpg', 0, 1, NOW(), NOW()),
(12, 1, 'AO001-VANG-L', 'Vàng / L', 'L', 'Vàng', 120000, 99000, 55000, 3, '/uploads/products/ao_001_main.jpg', 0, 1, NOW(), NOW()),
(13, 2, 'AO002-BE-M', 'Be / M', 'M', 'Be', 280000, 249000, 145000, 10, '/uploads/products/ao_002_main.jpg', 1, 1, NOW(), NOW()),
(14, 2, 'AO002-XANHNHAT-L', 'Xanh nhạt / L', 'L', 'Xanh nhạt', 280000, 249000, 145000, 8, '/uploads/products/ao_002_2.jpg', 0, 1, NOW(), NOW()),
(15, 3, 'QUAN001-XD-M', 'Xanh đậm / M', 'M', 'Xanh đậm', 320000, 289000, 180000, 9, '/uploads/products/quan_001_main.jpg', 1, 1, NOW(), NOW()),
(16, 3, 'QUAN001-XN-L', 'Xanh nhạt / L', 'L', 'Xanh nhạt', 320000, 289000, 180000, 8, '/uploads/products/quan_001_2.jpg', 0, 1, NOW(), NOW()),
(17, 3, 'QUAN001-XD-XL', 'Xanh đậm / XL', 'XL', 'Xanh đậm', 320000, 289000, 180000, 9, '/uploads/products/quan_001_main.jpg', 0, 1, NOW(), NOW()),
(18, 4, 'VAY001-KEM-S', 'Kem hoa nhí / S', 'S', 'Kem hoa nhí', 350000, 315000, 190000, 4, '/uploads/products/vay_001_main.jpg', 1, 1, NOW(), NOW()),
(19, 4, 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', 350000, 315000, 190000, 4, '/uploads/products/vay_001_main.jpg', 0, 1, NOW(), NOW()),
(20, 4, 'VAY001-KEM-L', 'Kem hoa nhí / L', 'L', 'Kem hoa nhí', 350000, 315000, 190000, 4, '/uploads/products/vay_001_main.jpg', 0, 1, NOW(), NOW()),
(21, 5, 'GIAY001-39', 'Trắng / 39', '39', 'Trắng', 590000, 520000, 340000, 3, '/uploads/products/giay_001_main.jpg', 1, 1, NOW(), NOW()),
(22, 5, 'GIAY001-40', 'Trắng / 40', '40', 'Trắng', 590000, 520000, 340000, 4, '/uploads/products/giay_001_main.jpg', 0, 1, NOW(), NOW()),
(23, 5, 'GIAY001-41', 'Trắng / 41', '41', 'Trắng', 590000, 520000, 340000, 4, '/uploads/products/giay_001_2.jpg', 0, 1, NOW(), NOW()),
(24, 5, 'GIAY001-42', 'Trắng / 42', '42', 'Trắng', 590000, 520000, 340000, 3, '/uploads/products/giay_001_2.jpg', 0, 1, NOW(), NOW()),
(25, 6, 'TUI001-KEM-FS', 'Kem / Free size', 'Free size', 'Kem', 210000, 179000, 95000, 11, '/uploads/products/tui_001_main.jpg', 1, 1, NOW(), NOW()),
(26, 6, 'TUI001-DEN-FS', 'Đen / Free size', 'Free size', 'Đen', 210000, 179000, 95000, 11, '/uploads/products/tui_001_main.jpg', 0, 1, NOW(), NOW());

INSERT INTO `inventory_movements`
(`id`, `product_id`, `variant_id`, `movement_type`, `quantity_change`, `stock_after`, `source_type`, `source_id`, `note`, `created_by_admin_id`, `created_at`)
VALUES
(1, 1, 1, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size S', 1, NOW()),
(2, 1, 2, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size M', 1, NOW()),
(3, 1, 3, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size L', 1, NOW()),
(4, 1, 4, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size S', 1, NOW()),
(5, 1, 5, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size M', 1, NOW()),
(6, 1, 6, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size L', 1, NOW()),
(7, 1, 7, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size S', 1, NOW()),
(8, 1, 8, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size M', 1, NOW()),
(9, 1, 9, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size L', 1, NOW()),
(10, 1, 10, 'purchase', 4, 4, 'import', 1001, 'Nhập áo màu vàng size S', 1, NOW()),
(11, 1, 11, 'purchase', 4, 4, 'import', 1001, 'Nhập áo màu vàng size M', 1, NOW()),
(12, 1, 12, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu vàng size L', 1, NOW()),
(13, 2, 13, 'purchase', 10, 10, 'import', 1002, 'Nhập sơ mi be', 1, NOW()),
(14, 2, 14, 'purchase', 8, 8, 'import', 1002, 'Nhập sơ mi xanh nhạt', 1, NOW()),
(15, 3, 15, 'purchase', 9, 9, 'import', 1003, 'Nhập jean xanh đậm size M', 1, NOW()),
(16, 3, 16, 'purchase', 8, 8, 'import', 1003, 'Nhập jean xanh nhạt size L', 1, NOW()),
(17, 3, 17, 'purchase', 9, 9, 'import', 1003, 'Nhập jean xanh đậm size XL', 1, NOW()),
(18, 4, 18, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size S', 1, NOW()),
(19, 4, 19, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size M', 1, NOW()),
(20, 4, 20, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size L', 1, NOW()),
(21, 5, 21, 'purchase', 3, 3, 'import', 1005, 'Nhập giày size 39', 1, NOW()),
(22, 5, 22, 'purchase', 4, 4, 'import', 1005, 'Nhập giày size 40', 1, NOW()),
(23, 5, 23, 'purchase', 4, 4, 'import', 1005, 'Nhập giày size 41', 1, NOW()),
(24, 5, 24, 'purchase', 3, 3, 'import', 1005, 'Nhập giày size 42', 1, NOW()),
(25, 6, 25, 'purchase', 11, 11, 'import', 1006, 'Nhập túi tote màu kem', 1, NOW()),
(26, 6, 26, 'purchase', 11, 11, 'import', 1006, 'Nhập túi tote màu đen', 1, NOW());

-- ---------------------------------------------------------
-- Customers
-- login local: linh@example.com / customer123
-- login local: nam@example.com / customer123
-- ---------------------------------------------------------
INSERT INTO `customers`
(`id`, `customer_code`, `full_name`, `email`, `phone`, `password_hash`, `avatar_url`, `birth_date`, `gender`, `status`, `registered_via`, `email_verified_at`, `phone_verified_at`, `last_login_at`, `created_at`, `updated_at`, `deleted_at`)
VALUES
(1, 'CUS0001', 'Nguyễn Thị Linh', 'linh@example.com', '0901234567', '$2y$12$0gWqytWtQW9yx1zcx9SpWOfUnzMhWDgZ2k85SzcoudJkaZyF6oMWm', '/uploads/avatars/linh.jpg', '1998-05-12', 'Nữ', 'active', 'local', NOW(), NOW(), '2026-03-18 20:00:00', NOW(), NOW(), NULL),
(2, 'CUS0002', 'Trần Hoàng Nam', 'nam@example.com', '0912345678', '$2y$12$0gWqytWtQW9yx1zcx9SpWOfUnzMhWDgZ2k85SzcoudJkaZyF6oMWm', '/uploads/avatars/nam.jpg', '1996-10-21', 'Nam', 'active', 'local', NOW(), NOW(), '2026-03-18 22:00:00', NOW(), NOW(), NULL),
(3, 'CUS0003', 'Lê Minh Anh', 'minhanh@example.com', '0988765432', NULL, '/uploads/avatars/minhanh.jpg', '2000-03-07', 'Nữ', 'active', 'google', NOW(), NOW(), '2026-03-17 19:30:00', NOW(), NOW(), NULL);

INSERT INTO `customer_oauth_accounts`
(`id`, `customer_id`, `provider`, `provider_user_id`, `provider_email`, `provider_name`, `avatar_url`, `access_token_encrypted`, `refresh_token_encrypted`, `token_expires_at`, `linked_at`, `last_used_at`)
VALUES
(1, 3, 'google', 'google_109876543210987654321', 'minhanh@example.com', 'Lê Minh Anh', '/uploads/avatars/minhanh.jpg', NULL, NULL, NULL, NOW(), NOW());

INSERT INTO `customer_addresses`
(`id`, `customer_id`, `label`, `receiver_name`, `receiver_phone`, `province_code`, `province_name`, `district_code`, `district_name`, `ward_code`, `ward_name`, `address_line`, `address_note`, `is_default_shipping`, `is_default_billing`, `is_active`, `created_at`, `updated_at`)
VALUES
(1, 1, 'Nhà riêng', 'Nguyễn Thị Linh', '0901234567', '79', 'TP. Hồ Chí Minh', '760', 'Quận 1', '26734', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', 1, 1, 1, NOW(), NOW()),
(2, 1, 'Công ty', 'Nguyễn Thị Linh', '0901234567', '79', 'TP. Hồ Chí Minh', '769', 'Quận 7', '27160', 'Phường Tân Phú', '25 Nguyễn Lương Bằng', 'Giao giờ hành chính', 0, 0, 1, NOW(), NOW()),
(3, 2, 'Nhà riêng', 'Trần Hoàng Nam', '0912345678', '79', 'TP. Hồ Chí Minh', '770', 'Quận Bình Thạnh', '27433', 'Phường 25', '88 D5', 'Gọi trước khi giao', 1, 1, 1, NOW(), NOW()),
(4, 3, 'Nhà riêng', 'Lê Minh Anh', '0988765432', '48', 'Đà Nẵng', '490', 'Quận Hải Châu', '20194', 'Phường Thạch Thang', '56 Trần Phú', 'Nhận hàng buổi chiều', 1, 1, 1, NOW(), NOW());

INSERT INTO `customer_sessions`
(`id`, `customer_id`, `session_token_hash`, `ip_address`, `user_agent`, `last_seen_at`, `expires_at`, `revoked_at`, `created_at`)
VALUES
(1, 1, SHA2('session_linh_active', 256), '113.161.10.10', 'Mozilla/5.0 Demo Browser', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), NULL, NOW()),
(2, 2, SHA2('session_nam_active', 256), '14.162.1.1', 'Mozilla/5.0 Demo Browser', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), NULL, NOW());

INSERT INTO `customer_auth_tokens`
(`id`, `customer_id`, `token_type`, `token_hash`, `expires_at`, `used_at`, `created_at`)
VALUES
(1, 1, 'email_verify', SHA2('verify_linh_email', 256), DATE_ADD(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
(2, 2, 'phone_verify', SHA2('verify_nam_phone', 256), DATE_ADD(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
(3, 2, 'password_reset', SHA2('reset_nam_password_old', 256), DATE_ADD(NOW(), INTERVAL 1 DAY), NULL, NOW());

INSERT INTO `customer_security_logs`
(`id`, `customer_id`, `event_type`, `ip_address`, `user_agent`, `meta_text`, `created_at`)
VALUES
(1, 1, 'login_success', '113.161.10.10', 'Mozilla/5.0 Demo Browser', '{"method":"password"}', NOW()),
(2, 2, 'login_failed', '14.162.1.1', 'Mozilla/5.0 Demo Browser', '{"reason":"wrong_password"}', NOW()),
(3, 3, 'oauth_linked', '118.69.40.40', 'Mozilla/5.0 Demo Browser', '{"provider":"google"}', NOW());

-- ---------------------------------------------------------
-- Cart
-- ---------------------------------------------------------
INSERT INTO `carts`
(`id`, `customer_id`, `guest_token`, `status`, `created_at`, `updated_at`, `expired_at`)
VALUES
(1, 1, NULL, 'active', NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(2, NULL, SHA2('guest_cart_checkout_001', 256), 'active', NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 2 DAY));

INSERT INTO `cart_items`
(`id`, `cart_id`, `product_id`, `variant_id`, `quantity`, `unit_price_snapshot`, `sale_price_snapshot`, `created_at`, `updated_at`)
VALUES
(1, 1, 1, 5, 2, 120000, 99000, NOW(), NOW()),
(2, 1, 6, 25, 1, 210000, 179000, NOW(), NOW()),
(3, 2, 3, 15, 1, 320000, 289000, NOW(), NOW());

-- ---------------------------------------------------------
-- Orders
-- ---------------------------------------------------------
INSERT INTO `orders`
(`id`, `order_code`, `customer_id`, `cart_id`, `checkout_type`, `purchase_channel`, `order_source`, `contact_name`, `contact_phone`, `contact_email`, `customer_note`, `internal_note`, `subtotal_amount`, `discount_amount`, `shipping_fee`, `total_amount`, `payment_plan`, `deposit_rate`, `deposit_required_amount`, `paid_amount`, `remaining_amount`, `payment_status`, `order_status`, `guest_access_token`, `placed_at`, `confirmed_at`, `completed_at`, `cancelled_at`, `cancel_reason`, `created_at`, `updated_at`)
VALUES
(1, 'ODR000001', 1, 1, 'account', 'web', 'cart', 'Nguyễn Thị Linh', '0901234567', 'linh@example.com', 'Giao sau 18h', 'Khách VIP tháng 3', 377000, 0, 25000, 402000, 'full', 0, 0, 402000, 0, 'paid', 'confirmed', NULL, '2026-03-17 14:00:00', '2026-03-17 14:30:00', NULL, NULL, NULL, NOW(), NOW()),
(2, 'ODR000002', 2, NULL, 'account', 'web', 'product', 'Trần Hoàng Nam', '0912345678', 'nam@example.com', 'Cần giao nhanh', NULL, 520000, 0, 30000, 550000, 'deposit_30', 30.00, 165000, 165000, 385000, 'deposit_paid', 'confirmed', NULL, '2026-03-18 09:30:00', '2026-03-18 10:00:00', NULL, NULL, NULL, NOW(), NOW()),
(3, 'ODR000003', NULL, NULL, 'guest', 'zalo', 'product', 'Phạm Gia Hân', '0933456789', 'giahan@example.com', 'Liên hệ qua Zalo trước khi ship', 'Lead từ TikTok', 315000, 0, 25000, 340000, 'zalo_manual', 0, 0, 0, 340000, 'unpaid', 'pending_confirmation', SHA2('guest_order_003', 256), '2026-03-18 11:15:00', NULL, NULL, NULL, NULL, NOW(), NOW()),
(4, 'ODR000004', NULL, 2, 'guest', 'web', 'cart', 'Lưu Quang Huy', '0944567890', 'quanghuy@example.com', 'Ship tới văn phòng', NULL, 289000, 0, 25000, 314000, 'full', 0, 0, 314000, 0, 'paid', 'processing', SHA2('guest_order_004', 256), '2026-03-18 15:30:00', '2026-03-18 15:45:00', NULL, NULL, NULL, NOW(), NOW());

INSERT INTO `order_addresses`
(`id`, `order_id`, `address_type`, `source_type`, `source_address_id`, `receiver_name`, `receiver_phone`, `province_name`, `district_name`, `ward_name`, `address_line`, `address_note`, `created_at`)
VALUES
(1, 1, 'shipping', 'account_saved', 1, 'Nguyễn Thị Linh', '0901234567', 'TP. Hồ Chí Minh', 'Quận 1', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', NOW()),
(2, 1, 'billing', 'account_saved', 1, 'Nguyễn Thị Linh', '0901234567', 'TP. Hồ Chí Minh', 'Quận 1', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', NOW()),
(3, 2, 'shipping', 'account_saved', 3, 'Trần Hoàng Nam', '0912345678', 'TP. Hồ Chí Minh', 'Quận Bình Thạnh', 'Phường 25', '88 D5', 'Gọi trước khi giao', NOW()),
(4, 3, 'shipping', 'manual', NULL, 'Phạm Gia Hân', '0933456789', 'Khánh Hòa', 'Nha Trang', 'Phường Lộc Thọ', '15 Trần Phú', 'Liên hệ Zalo', NOW()),
(5, 4, 'shipping', 'manual', NULL, 'Lưu Quang Huy', '0944567890', 'TP. Hồ Chí Minh', 'Quận 3', 'Phường Võ Thị Sáu', '120 Cách Mạng Tháng 8', 'Ship giờ hành chính', NOW());

INSERT INTO `order_items`
(`id`, `order_id`, `product_id`, `variant_id`, `product_name_snapshot`, `product_code_snapshot`, `sku_snapshot`, `variant_name_snapshot`, `size_snapshot`, `color_snapshot`, `thumbnail_snapshot`, `quantity`, `original_unit_price`, `final_unit_price`, `line_total`, `created_at`)
VALUES
(1, 1, 1, 5, 'Áo thun gân tăm basic', 'AO_001', 'AO001-DO-M', 'Đỏ / M', 'M', 'Đỏ', '/uploads/products/ao_001_2.jpg', 2, 120000, 99000, 198000, NOW()),
(2, 1, 6, 25, 'Túi tote canvas mini', 'TUI_001', 'TUI001-KEM-FS', 'Kem / Free size', 'Free size', 'Kem', '/uploads/products/tui_001_main.jpg', 1, 210000, 179000, 179000, NOW()),
(3, 2, 5, 22, 'Sneaker trắng tối giản', 'GIAY_001', 'GIAY001-40', 'Trắng / 40', '40', 'Trắng', '/uploads/products/giay_001_main.jpg', 1, 590000, 520000, 520000, NOW()),
(4, 3, 4, 19, 'Váy midi hoa vintage', 'VAY_001', 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', '/uploads/products/vay_001_main.jpg', 1, 350000, 315000, 315000, NOW()),
(5, 4, 3, 15, 'Quần jean ống suông cạp cao', 'QUAN_001', 'QUAN001-XD-M', 'Xanh đậm / M', 'M', 'Xanh đậm', '/uploads/products/quan_001_main.jpg', 1, 320000, 289000, 289000, NOW());

INSERT INTO `order_status_logs`
(`id`, `order_id`, `from_status`, `to_status`, `note`, `changed_by_type`, `changed_by_id`, `created_at`)
VALUES
(1, 1, NULL, 'pending_confirmation', 'Tạo đơn từ giỏ hàng', 'customer', 1, '2026-03-17 14:00:00'),
(2, 1, 'pending_confirmation', 'confirmed', 'Đã thanh toán đủ, admin xác nhận', 'admin', 1, '2026-03-17 14:30:00'),
(3, 2, NULL, 'pending_confirmation', 'Khách chọn cọc 30%', 'customer', 2, '2026-03-18 09:30:00'),
(4, 2, 'pending_confirmation', 'confirmed', 'Đã nhận tiền cọc', 'webhook', NULL, '2026-03-18 10:00:00'),
(5, 3, NULL, 'pending_confirmation', 'Lead đặt hàng qua Zalo', 'customer', NULL, '2026-03-18 11:15:00'),
(6, 4, NULL, 'pending_confirmation', 'Guest checkout web', 'customer', NULL, '2026-03-18 15:30:00'),
(7, 4, 'pending_confirmation', 'processing', 'Thanh toán đủ, chuẩn bị đóng gói', 'admin', 1, '2026-03-18 16:00:00');

-- ---------------------------------------------------------
-- Payment intents / payments / webhook logs
-- ---------------------------------------------------------
INSERT INTO `payment_intents`
(`id`, `intent_code`, `customer_id`, `order_id`, `wallet_topup_request_id`, `provider`, `purpose`, `requested_amount`, `currency_code`, `status`, `qr_content`, `qr_image_url`, `transfer_note`, `expires_at`, `idempotency_key`, `metadata_text`, `created_at`, `updated_at`)
VALUES
(1, 'PI000001', 1, 1, NULL, 'sepay', 'order_full', 402000, 'VND', 'paid', 'bank=MB&acc=123456789&amount=402000&addInfo=ODR000001', '/qrs/PI000001.png', 'ODR000001', '2026-03-18 23:59:59', 'idem-order-1', '{"order_code":"ODR000001"}', NOW(), NOW()),
(2, 'PI000002', 2, 2, NULL, 'sepay', 'order_deposit', 165000, 'VND', 'paid', 'bank=MB&acc=123456789&amount=165000&addInfo=ODR000002-COC', '/qrs/PI000002.png', 'ODR000002-COC', '2026-03-19 23:59:59', 'idem-order-2', '{"order_code":"ODR000002","payment_plan":"deposit_30"}', NOW(), NOW()),
(3, 'PI000003', NULL, 4, NULL, 'sepay', 'order_full', 314000, 'VND', 'paid', 'bank=MB&acc=123456789&amount=314000&addInfo=ODR000004', '/qrs/PI000003.png', 'ODR000004', '2026-03-19 23:59:59', 'idem-order-4', '{"order_code":"ODR000004"}', NOW(), NOW()),
(4, 'PI000004', 1, NULL, 1, 'sepay', 'wallet_topup', 500000, 'VND', 'paid', 'bank=MB&acc=123456789&amount=500000&addInfo=NAPTOPUP001', '/qrs/PI000004.png', 'NAPTOPUP001', '2026-03-20 23:59:59', 'idem-topup-1', '{"topup_code":"TOPUP0001"}', NOW(), NOW());

INSERT INTO `payments`
(`id`, `payment_intent_id`, `customer_id`, `order_id`, `provider`, `provider_transaction_id`, `provider_reference_code`, `transfer_type`, `paid_amount`, `fee_amount`, `net_amount`, `payment_status`, `raw_content`, `paid_at`, `confirmed_at`, `raw_payload_text`, `created_at`)
VALUES
(1, 1, 1, 1, 'sepay', 'SPTXN000001', 'MBREF0001', 'in', 402000, 0, 402000, 'success', 'ODR000001', '2026-03-17 14:18:00', '2026-03-17 14:19:00', '{"id":"SPTXN000001","content":"ODR000001","transferAmount":402000}', NOW()),
(2, 2, 2, 2, 'sepay', 'SPTXN000002', 'MBREF0002', 'in', 165000, 0, 165000, 'success', 'ODR000002-COC', '2026-03-18 09:52:00', '2026-03-18 09:53:00', '{"id":"SPTXN000002","content":"ODR000002-COC","transferAmount":165000}', NOW()),
(3, 3, NULL, 4, 'sepay', 'SPTXN000003', 'MBREF0003', 'in', 314000, 0, 314000, 'success', 'ODR000004', '2026-03-18 15:38:00', '2026-03-18 15:39:00', '{"id":"SPTXN000003","content":"ODR000004","transferAmount":314000}', NOW()),
(4, 4, 1, NULL, 'sepay', 'SPTXN000004', 'MBREF0004', 'in', 500000, 0, 500000, 'success', 'NAPTOPUP001', '2026-03-18 17:05:00', '2026-03-18 17:06:00', '{"id":"SPTXN000004","content":"NAPTOPUP001","transferAmount":500000}', NOW());

INSERT INTO `payment_webhook_logs`
(`id`, `provider`, `event_key`, `provider_transaction_id`, `request_headers_text`, `request_body_text`, `parsed_amount`, `parsed_reference_code`, `parsed_transfer_type`, `process_status`, `linked_payment_id`, `error_message`, `processed_at`, `created_at`)
VALUES
(1, 'sepay', 'sepay_event_000001', 'SPTXN000001', '{"authorization":"Apikey demo"}', '{"id":"SPTXN000001","content":"ODR000001","transferAmount":402000}', 402000, 'MBREF0001', 'in', 'processed', 1, NULL, NOW(), NOW()),
(2, 'sepay', 'sepay_event_000002', 'SPTXN000002', '{"authorization":"Apikey demo"}', '{"id":"SPTXN000002","content":"ODR000002-COC","transferAmount":165000}', 165000, 'MBREF0002', 'in', 'processed', 2, NULL, NOW(), NOW()),
(3, 'sepay', 'sepay_event_000003', 'SPTXN000003', '{"authorization":"Apikey demo"}', '{"id":"SPTXN000003","content":"ODR000004","transferAmount":314000}', 314000, 'MBREF0003', 'in', 'processed', 3, NULL, NOW(), NOW()),
(4, 'sepay', 'sepay_event_000004', 'SPTXN000004', '{"authorization":"Apikey demo"}', '{"id":"SPTXN000004","content":"NAPTOPUP001","transferAmount":500000}', 500000, 'MBREF0004', 'in', 'processed', 4, NULL, NOW(), NOW());

-- ---------------------------------------------------------
-- Wallet
-- ---------------------------------------------------------
INSERT INTO `wallet_accounts`
(`id`, `customer_id`, `status`, `balance_cached`, `total_credited`, `total_debited`, `created_at`, `updated_at`)
VALUES
(1, 1, 'active', 350000, 500000, 150000, NOW(), NOW()),
(2, 2, 'active', 0, 0, 0, NOW(), NOW()),
(3, 3, 'active', 0, 0, 0, NOW(), NOW());

INSERT INTO `wallet_topup_requests`
(`id`, `customer_id`, `topup_code`, `requested_amount`, `status`, `payment_intent_id`, `note`, `expires_at`, `confirmed_at`, `cancelled_at`, `created_at`, `updated_at`)
VALUES
(1, 1, 'TOPUP0001', 500000, 'confirmed', 4, 'Khách nạp ví để mua sau', '2026-03-20 23:59:59', '2026-03-18 17:06:00', NULL, NOW(), NOW());

INSERT INTO `wallet_ledger`
(`id`, `wallet_account_id`, `customer_id`, `entry_type`, `source_type`, `source_id`, `amount_change`, `balance_before`, `balance_after`, `description`, `related_payment_id`, `created_at`)
VALUES
(1, 1, 1, 'topup_credit', 'wallet_topup', 1, 500000, 0, 500000, 'Nạp ví qua SePay TOPUP0001', 4, '2026-03-18 17:06:00'),
(2, 1, 1, 'order_debit', 'order', 1, -150000, 500000, 350000, 'Trừ ví cho đơn hàng demo ODR000001', NULL, '2026-03-18 18:00:00');

-- ---------------------------------------------------------
-- Admin audit
-- ---------------------------------------------------------
INSERT INTO `admin_audit_logs`
(`id`, `admin_id`, `action`, `target_table`, `target_id`, `before_data_text`, `after_data_text`, `ip_address`, `user_agent`, `created_at`)
VALUES
(1, 1, 'create_product', 'products', 6, NULL, '{"product_code":"TUI_001","product_name":"Túi tote canvas mini"}', '127.0.0.1', 'Mozilla/5.0 Admin', NOW()),
(2, 1, 'update_order', 'orders', 2, '{"payment_status":"unpaid"}', '{"payment_status":"deposit_paid"}', '127.0.0.1', 'Mozilla/5.0 Admin', NOW()),
(3, 1, 'manual_wallet_adjustment', 'wallet_accounts', 1, '{"balance_cached":500000}', '{"balance_cached":350000}', '127.0.0.1', 'Mozilla/5.0 Admin', NOW());

-- ---------------------------------------------------------
-- Update app settings to usable demo values for phase 4
-- ---------------------------------------------------------
INSERT INTO `app_settings` (`setting_key`, `setting_value`, `updated_at`) VALUES
('shop_name', 'Duong Mot Mi SHOP', NOW()),
('shop_tagline', 'Shop thời trang nữ phong cách trẻ trung, hỗ trợ mua nhanh qua web hoặc Zalo.', NOW()),
('shop_logo', 'img/logo.jpg', NOW()),
('shop_phone', '0961691107', NOW()),
('shop_email', 'support@duongmotmi.vn', NOW()),
('shop_address', 'TP. Hồ Chí Minh', NOW()),
('shop_working_hours', '08:00 - 22:00 (T2 - CN)', NOW()),
('default_deposit_rate', '30', NOW()),
('enable_guest_checkout', '1', NOW()),
('enable_wallet', '1', NOW()),
('enable_social_login_google', '1', NOW()),
('enable_social_login_facebook', '1', NOW()),
('zalo_contact_link', 'https://zalo.me/0961691107', NOW()),
('zalo_group_link', 'https://zalo.me/g/demo-shop', NOW()),
('facebook_link', 'https://facebook.com/duongmotmishop', NOW()),
('instagram_link', 'https://instagram.com/duongmotmishop', NOW()),
('tiktok_link', 'https://tiktok.com/@duongmotmishop', NOW()),
('sepay_bank_name', 'MB Bank', NOW()),
('sepay_bank_account_no', '123456789', NOW()),
('sepay_account_name', 'DUONG MOT MI SHOP', NOW()),

('sepay_bank_code', 'MBBank', NOW()),
('sepay_webhook_api_key', 'demo-sepay-api-key', NOW()),
('sepay_expected_sub_account', '123456789', NOW()),
('facebook_link', 'https://facebook.com/duongmotmishop', NOW()),
('instagram_link', 'https://instagram.com/duongmotmishop', NOW()),
('tiktok_link', 'https://tiktok.com/@duongmotmishop', NOW()),
('zalo_group_link', 'https://zalo.me/g/example', NOW()),
('enable_guest_checkout', '1', NOW()),
('enable_wallet', '1', NOW()),
('enable_social_login_google', '0', NOW()),
('enable_social_login_facebook', '0', NOW()),
ON DUPLICATE KEY UPDATE
`setting_value` = VALUES(`setting_value`),
`updated_at` = VALUES(`updated_at`);

SET FOREIGN_KEY_CHECKS = 1;
