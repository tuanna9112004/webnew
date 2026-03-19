/*
 Database full import đã cập nhật sẵn cấu hình SePay VA + webhook matching cho project Duong Mot Mi.
 Import file này vào MySQL/MariaDB trước khi chạy project.
*/

/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 100432
 Source Host           : localhost:3306
 Source Schema         : clothing_shop

 Target Server Type    : MySQL
 Target Server Version : 100432
 File Encoding         : 65001

 Date: 19/03/2026 14:53:23
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin_audit_logs
-- ----------------------------
DROP TABLE IF EXISTS `admin_audit_logs`;
CREATE TABLE `admin_audit_logs`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_id` int UNSIGNED NULL DEFAULT NULL,
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_table` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_id` int UNSIGNED NOT NULL,
  `before_data_text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `after_data_text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_admin_audit_logs_admin_date`(`admin_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_admin_audit_logs_target`(`target_table` ASC, `target_id` ASC) USING BTREE,
  CONSTRAINT `fk_admin_audit_logs_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin_audit_logs
-- ----------------------------
INSERT INTO `admin_audit_logs` VALUES (1, 1, 'create_product', 'products', 6, NULL, '{\"product_code\":\"TUI_001\",\"product_name\":\"Túi tote canvas mini\"}', '127.0.0.1', 'Mozilla/5.0 Admin', '2026-03-19 13:16:41');
INSERT INTO `admin_audit_logs` VALUES (2, 1, 'update_order', 'orders', 2, '{\"payment_status\":\"unpaid\"}', '{\"payment_status\":\"deposit_paid\"}', '127.0.0.1', 'Mozilla/5.0 Admin', '2026-03-19 13:16:41');
INSERT INTO `admin_audit_logs` VALUES (3, 1, 'manual_wallet_adjustment', 'wallet_accounts', 1, '{\"balance_cached\":500000}', '{\"balance_cached\":350000}', '127.0.0.1', 'Mozilla/5.0 Admin', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for admins
-- ----------------------------
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` enum('active','locked','disabled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `last_login_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_admins_username`(`username` ASC) USING BTREE,
  INDEX `idx_admins_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admins
-- ----------------------------
INSERT INTO `admins` VALUES (1, 'admin', '$2y$12$UVlOTrXu8r6UE0iwlrFp6usIvPbRlE7/uZA4klsEs3KZ/5AVxZmiO', 'Quản trị viên', 'active', '2026-03-18 21:00:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for app_settings
-- ----------------------------
DROP TABLE IF EXISTS `app_settings`;
CREATE TABLE `app_settings`  (
  `setting_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`setting_key`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of app_settings
-- ----------------------------
INSERT INTO `app_settings` VALUES ('default_deposit_rate', '30', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('enable_guest_checkout', '1', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('enable_social_login_facebook', '1', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('enable_social_login_google', '1', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('enable_wallet', '1', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('facebook_link', 'https://www.facebook.com/duongdangyeunhatthegioi', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('instagram_link', 'https://www.instagram.com/giuong_tung/', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('sepay_account_name', 'NGUYEN TUNG DUONG', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('sepay_bank_account_no', 'VQRQAHSJJ1234', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('sepay_bank_code', 'MBBank', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('sepay_bank_name', 'MBBank', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('sepay_expected_sub_account', 'VQRQAHSJJ1234', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('sepay_webhook_api_key', '', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_address', 'Hà Nội', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_email', '', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_logo', 'img/logo.jpg', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_name', 'Duong Mot Mi', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_phone', '0961.691.107', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_tagline', 'Khám phá phong cách thời trang trẻ trung, hiện đại. Chúng tôi cam kết mang đến cho bạn những sản phẩm chất lượng với dịch vụ chốt đơn nhanh chóng, tận tâm.', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_working_hours', '08:00 - 22:00 (T2 - CN)', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('tiktok_link', '', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('zalo_contact_link', 'https://zalo.me/0961691107', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('zalo_group_link', 'https://zalo.me/g/bjazlwfwqlsmruqdnxqr', '2026-03-19 13:41:49');

-- ----------------------------
-- Table structure for cart_items
-- ----------------------------
DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE `cart_items`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `cart_id` int UNSIGNED NOT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `variant_id` int UNSIGNED NULL DEFAULT NULL,
  `quantity` int NOT NULL,
  `unit_price_snapshot` decimal(12, 2) NOT NULL,
  `sale_price_snapshot` decimal(12, 2) NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_cart_items_cart_variant`(`cart_id` ASC, `variant_id` ASC) USING BTREE,
  INDEX `idx_cart_items_product`(`product_id` ASC) USING BTREE,
  INDEX `fk_cart_items_variant`(`variant_id` ASC) USING BTREE,
  CONSTRAINT `fk_cart_items_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cart_items
-- ----------------------------
INSERT INTO `cart_items` VALUES (1, 1, 1, 5, 2, 120000.00, 99000.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `cart_items` VALUES (2, 1, 6, 25, 1, 210000.00, 179000.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `cart_items` VALUES (3, 2, 3, 15, 1, 320000.00, 289000.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `cart_items` VALUES (4, 3, 6, 26, 1, 179000.00, 179000.00, '2026-03-19 13:17:21', '2026-03-19 13:17:21');
INSERT INTO `cart_items` VALUES (5, 4, 4, 19, 1, 315000.00, 315000.00, '2026-03-19 13:21:37', '2026-03-19 13:21:37');
INSERT INTO `cart_items` VALUES (6, 5, 5, 21, 1, 520000.00, 520000.00, '2026-03-19 13:39:19', '2026-03-19 13:39:19');
INSERT INTO `cart_items` VALUES (7, 6, 1, 11, 1, 99000.00, 99000.00, '2026-03-19 14:15:28', '2026-03-19 14:15:28');

-- ----------------------------
-- Table structure for carts
-- ----------------------------
DROP TABLE IF EXISTS `carts`;
CREATE TABLE `carts`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NULL DEFAULT NULL,
  `guest_token` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` enum('active','converted','abandoned') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  `expired_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_carts_guest_token`(`guest_token` ASC) USING BTREE,
  INDEX `idx_carts_customer_status`(`customer_id` ASC, `status` ASC) USING BTREE,
  CONSTRAINT `fk_carts_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of carts
-- ----------------------------
INSERT INTO `carts` VALUES (1, 1, NULL, 'active', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-26 13:16:41');
INSERT INTO `carts` VALUES (2, NULL, 'd7ccbec5b3eae46c605aaa2778ccd1d1fa329fa8d8c7dddaccad9ce4c5fe3100', 'active', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-21 13:16:41');
INSERT INTO `carts` VALUES (3, NULL, '1c309039ecd10b2b99b35d32e0e0f4a546804c4420c24f94', 'converted', '2026-03-19 13:17:09', '2026-03-19 13:17:42', NULL);
INSERT INTO `carts` VALUES (4, NULL, '9b567640d8445332366271abc378e2665d0fdcf935e1be94', 'converted', '2026-03-19 13:21:37', '2026-03-19 13:21:57', NULL);
INSERT INTO `carts` VALUES (5, 4, NULL, 'converted', '2026-03-19 13:39:19', '2026-03-19 13:39:36', NULL);
INSERT INTO `carts` VALUES (6, 4, NULL, 'converted', '2026-03-19 14:15:28', '2026-03-19 14:15:44', NULL);
INSERT INTO `carts` VALUES (7, NULL, '9cc555c9bb2273a0bb71a1d16b789c356c002fa239c2b4da', 'active', '2026-03-19 14:40:28', '2026-03-19 14:40:28', NULL);

-- ----------------------------
-- Table structure for categories
-- ----------------------------
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_categories_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_categories_active_sort`(`is_active` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of categories
-- ----------------------------
INSERT INTO `categories` VALUES (1, 'Áo', 'ao', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `categories` VALUES (2, 'Quần', 'quan', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `categories` VALUES (3, 'Giày', 'giay', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `categories` VALUES (4, 'Túi xách', 'tui-xach', 4, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for customer_addresses
-- ----------------------------
DROP TABLE IF EXISTS `customer_addresses`;
CREATE TABLE `customer_addresses`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NOT NULL,
  `label` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `receiver_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `province_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `district_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `district_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ward_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ward_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_default_shipping` tinyint(1) NOT NULL DEFAULT 0,
  `is_default_billing` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer_addresses_customer_active`(`customer_id` ASC, `is_active` ASC) USING BTREE,
  INDEX `idx_customer_addresses_default_shipping`(`customer_id` ASC, `is_default_shipping` ASC) USING BTREE,
  INDEX `idx_customer_addresses_default_billing`(`customer_id` ASC, `is_default_billing` ASC) USING BTREE,
  CONSTRAINT `fk_customer_addresses_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer_addresses
-- ----------------------------
INSERT INTO `customer_addresses` VALUES (1, 1, 'Nhà riêng', 'Nguyễn Thị Linh', '0901234567', '79', 'TP. Hồ Chí Minh', '760', 'Quận 1', '26734', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', 1, 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `customer_addresses` VALUES (2, 1, 'Công ty', 'Nguyễn Thị Linh', '0901234567', '79', 'TP. Hồ Chí Minh', '769', 'Quận 7', '27160', 'Phường Tân Phú', '25 Nguyễn Lương Bằng', 'Giao giờ hành chính', 0, 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `customer_addresses` VALUES (3, 2, 'Nhà riêng', 'Trần Hoàng Nam', '0912345678', '79', 'TP. Hồ Chí Minh', '770', 'Quận Bình Thạnh', '27433', 'Phường 25', '88 D5', 'Gọi trước khi giao', 1, 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `customer_addresses` VALUES (4, 3, 'Nhà riêng', 'Lê Minh Anh', '0988765432', '48', 'Đà Nẵng', '490', 'Quận Hải Châu', '20194', 'Phường Thạch Thang', '56 Trần Phú', 'Nhận hàng buổi chiều', 1, 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for customer_auth_tokens
-- ----------------------------
DROP TABLE IF EXISTS `customer_auth_tokens`;
CREATE TABLE `customer_auth_tokens`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NOT NULL,
  `token_type` enum('password_reset','email_verify','phone_verify') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_customer_auth_tokens_hash`(`token_hash` ASC) USING BTREE,
  INDEX `idx_customer_auth_tokens_customer_type`(`customer_id` ASC, `token_type` ASC) USING BTREE,
  CONSTRAINT `fk_customer_auth_tokens_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer_auth_tokens
-- ----------------------------
INSERT INTO `customer_auth_tokens` VALUES (1, 1, 'email_verify', '1312e947b5297e966bbfb43cf6776c79b771b9640b356433a8f82fe100abb2cd', '2026-03-21 13:16:41', '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `customer_auth_tokens` VALUES (2, 2, 'phone_verify', 'e50238896609858f83f4ca3f06228685221b12f5c1c2820bdc0cff74c678d034', '2026-03-21 13:16:41', '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `customer_auth_tokens` VALUES (3, 2, 'password_reset', 'c17e4f3004f06953109ea710deea87593059677b97a1c78b7050b1cdb3f80324', '2026-03-20 13:16:41', NULL, '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for customer_oauth_accounts
-- ----------------------------
DROP TABLE IF EXISTS `customer_oauth_accounts`;
CREATE TABLE `customer_oauth_accounts`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NOT NULL,
  `provider` enum('google','facebook') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_user_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_email` varchar(190) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `provider_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `access_token_encrypted` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `refresh_token_encrypted` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `token_expires_at` datetime NULL DEFAULT NULL,
  `linked_at` datetime NOT NULL DEFAULT current_timestamp,
  `last_used_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_customer_oauth_provider_uid`(`provider` ASC, `provider_user_id` ASC) USING BTREE,
  INDEX `idx_customer_oauth_customer`(`customer_id` ASC) USING BTREE,
  CONSTRAINT `fk_customer_oauth_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer_oauth_accounts
-- ----------------------------
INSERT INTO `customer_oauth_accounts` VALUES (1, 3, 'google', 'google_109876543210987654321', 'minhanh@example.com', 'Lê Minh Anh', '/uploads/avatars/minhanh.jpg', NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for customer_security_logs
-- ----------------------------
DROP TABLE IF EXISTS `customer_security_logs`;
CREATE TABLE `customer_security_logs`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NULL DEFAULT NULL,
  `event_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `meta_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer_security_logs_customer_date`(`customer_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_customer_security_logs_event_date`(`event_type` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `fk_customer_security_logs_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer_security_logs
-- ----------------------------
INSERT INTO `customer_security_logs` VALUES (1, 1, 'login_success', '113.161.10.10', 'Mozilla/5.0 Demo Browser', '{\"method\":\"password\"}', '2026-03-19 13:16:41');
INSERT INTO `customer_security_logs` VALUES (2, 2, 'login_failed', '14.162.1.1', 'Mozilla/5.0 Demo Browser', '{\"reason\":\"wrong_password\"}', '2026-03-19 13:16:41');
INSERT INTO `customer_security_logs` VALUES (3, 3, 'oauth_linked', '118.69.40.40', 'Mozilla/5.0 Demo Browser', '{\"provider\":\"google\"}', '2026-03-19 13:16:41');
INSERT INTO `customer_security_logs` VALUES (4, 4, 'register_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng ký tài khoản', '2026-03-19 13:22:39');
INSERT INTO `customer_security_logs` VALUES (5, 4, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 13:22:39');
INSERT INTO `customer_security_logs` VALUES (6, 4, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 13:39:12');
INSERT INTO `customer_security_logs` VALUES (7, 4, 'logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng xuất', '2026-03-19 14:16:46');
INSERT INTO `customer_security_logs` VALUES (8, 5, 'register_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng ký tài khoản', '2026-03-19 14:17:14');
INSERT INTO `customer_security_logs` VALUES (9, 5, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 14:17:14');
INSERT INTO `customer_security_logs` VALUES (10, 5, 'logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng xuất', '2026-03-19 14:17:21');
INSERT INTO `customer_security_logs` VALUES (11, 6, 'register_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng ký tài khoản', '2026-03-19 14:17:51');
INSERT INTO `customer_security_logs` VALUES (12, 6, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 14:17:51');
INSERT INTO `customer_security_logs` VALUES (13, 6, 'logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng xuất', '2026-03-19 14:18:12');

-- ----------------------------
-- Table structure for customer_sessions
-- ----------------------------
DROP TABLE IF EXISTS `customer_sessions`;
CREATE TABLE `customer_sessions`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NOT NULL,
  `session_token_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `last_seen_at` datetime NOT NULL DEFAULT current_timestamp,
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_customer_sessions_token`(`session_token_hash` ASC) USING BTREE,
  INDEX `idx_customer_sessions_customer_expires`(`customer_id` ASC, `expires_at` ASC) USING BTREE,
  CONSTRAINT `fk_customer_sessions_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer_sessions
-- ----------------------------
INSERT INTO `customer_sessions` VALUES (1, 1, 'b3d0d394cba486fc44e72cc86f375d32dfd56b30ddc329b7ef61da4e61139309', '113.161.10.10', 'Mozilla/5.0 Demo Browser', '2026-03-19 13:16:41', '2026-03-26 13:16:41', NULL, '2026-03-19 13:16:41');
INSERT INTO `customer_sessions` VALUES (2, 2, '697ae39ef451389561987a2f706de0c5d7a5302778fcc687d3fd00236f383132', '14.162.1.1', 'Mozilla/5.0 Demo Browser', '2026-03-19 13:16:41', '2026-03-26 13:16:41', NULL, '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for customers
-- ----------------------------
DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `birth_date` date NULL DEFAULT NULL,
  `gender` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` enum('active','locked','disabled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `registered_via` enum('local','google','facebook','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'local',
  `email_verified_at` datetime NULL DEFAULT NULL,
  `phone_verified_at` datetime NULL DEFAULT NULL,
  `last_login_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_customers_customer_code`(`customer_code` ASC) USING BTREE,
  UNIQUE INDEX `uq_customers_email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `uq_customers_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_customers_status`(`status` ASC) USING BTREE,
  INDEX `idx_customers_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customers
-- ----------------------------
INSERT INTO `customers` VALUES (1, 'CUS0001', 'Nguyễn Thị Linh', 'linh@example.com', '0901234567', '$2y$12$0gWqytWtQW9yx1zcx9SpWOfUnzMhWDgZ2k85SzcoudJkaZyF6oMWm', '/uploads/avatars/linh.jpg', '1998-05-12', 'Nữ', 'active', 'local', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-18 20:00:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41', NULL);
INSERT INTO `customers` VALUES (2, 'CUS0002', 'Trần Hoàng Nam', 'nam@example.com', '0912345678', '$2y$12$0gWqytWtQW9yx1zcx9SpWOfUnzMhWDgZ2k85SzcoudJkaZyF6oMWm', '/uploads/avatars/nam.jpg', '1996-10-21', 'Nam', 'active', 'local', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-18 22:00:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41', NULL);
INSERT INTO `customers` VALUES (3, 'CUS0003', 'Lê Minh Anh', 'minhanh@example.com', '0988765432', NULL, '/uploads/avatars/minhanh.jpg', '2000-03-07', 'Nữ', 'active', 'google', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-17 19:30:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41', NULL);
INSERT INTO `customers` VALUES (4, 'CUS000004', 'Anh Tuấn', 'tuanna9112004@gmail.com', '0876726201', '$2y$10$ucqAqsOZ.ZtWkMlzlsQNDu4BDuk5wURaJHs4nBrCyY4cTLr4Jjto.', NULL, NULL, NULL, 'active', 'local', NULL, NULL, '2026-03-19 13:39:12', '2026-03-19 13:22:39', '2026-03-19 13:39:12', NULL);
INSERT INTO `customers` VALUES (5, 'CUS000005', 'Anh Tuấn', 'nguyngialam1101@gmail.com', '0876726202', '$2y$10$HTEskQs11/hK08PcknwfM.X52suLShDC95kW/FweLnefl0dml9hiS', NULL, NULL, NULL, 'active', 'local', NULL, NULL, '2026-03-19 14:17:14', '2026-03-19 14:17:14', '2026-03-19 14:17:14', NULL);
INSERT INTO `customers` VALUES (6, 'CUS000006', 'Anh Tuấn', 'nguyenanhtuan4831@gmail.com', '012345678', '$2y$10$xu.D7imcCPDoYNS3KsJaOOUyNOBEKg2M4mrKYZXRoL/rdFhmekkcu', NULL, NULL, NULL, 'active', 'local', NULL, NULL, '2026-03-19 14:17:51', '2026-03-19 14:17:51', '2026-03-19 14:17:51', NULL);

-- ----------------------------
-- Table structure for inventory_movements
-- ----------------------------
DROP TABLE IF EXISTS `inventory_movements`;
CREATE TABLE `inventory_movements`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` int UNSIGNED NOT NULL,
  `variant_id` int UNSIGNED NULL DEFAULT NULL,
  `movement_type` enum('purchase','sale_reserve','sale_commit','sale_release','return_in','return_out','manual_adjustment') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity_change` int NOT NULL,
  `stock_after` int NULL DEFAULT NULL,
  `source_type` enum('order','admin','import','refund','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `source_id` int UNSIGNED NULL DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_by_admin_id` int UNSIGNED NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_inventory_movements_product_date`(`product_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_inventory_movements_variant_date`(`variant_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_inventory_movements_source`(`source_type` ASC, `source_id` ASC) USING BTREE,
  INDEX `fk_inventory_movements_admin`(`created_by_admin_id` ASC) USING BTREE,
  CONSTRAINT `fk_inventory_movements_admin` FOREIGN KEY (`created_by_admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_inventory_movements_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_inventory_movements_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of inventory_movements
-- ----------------------------
INSERT INTO `inventory_movements` VALUES (1, 1, 1, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size S', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (2, 1, 2, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size M', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (3, 1, 3, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size L', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (4, 1, 4, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size S', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (5, 1, 5, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size M', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (6, 1, 6, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size L', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (7, 1, 7, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size S', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (8, 1, 8, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size M', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (9, 1, 9, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size L', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (10, 1, 10, 'purchase', 4, 4, 'import', 1001, 'Nhập áo màu vàng size S', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (11, 1, 11, 'purchase', 4, 4, 'import', 1001, 'Nhập áo màu vàng size M', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (12, 1, 12, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu vàng size L', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (13, 2, 13, 'purchase', 10, 10, 'import', 1002, 'Nhập sơ mi be', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (14, 2, 14, 'purchase', 8, 8, 'import', 1002, 'Nhập sơ mi xanh nhạt', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (15, 3, 15, 'purchase', 9, 9, 'import', 1003, 'Nhập jean xanh đậm size M', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (16, 3, 16, 'purchase', 8, 8, 'import', 1003, 'Nhập jean xanh nhạt size L', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (17, 3, 17, 'purchase', 9, 9, 'import', 1003, 'Nhập jean xanh đậm size XL', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (18, 4, 18, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size S', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (19, 4, 19, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size M', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (20, 4, 20, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size L', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (21, 5, 21, 'purchase', 3, 3, 'import', 1005, 'Nhập giày size 39', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (22, 5, 22, 'purchase', 4, 4, 'import', 1005, 'Nhập giày size 40', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (23, 5, 23, 'purchase', 4, 4, 'import', 1005, 'Nhập giày size 41', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (24, 5, 24, 'purchase', 3, 3, 'import', 1005, 'Nhập giày size 42', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (25, 6, 25, 'purchase', 11, 11, 'import', 1006, 'Nhập túi tote màu kem', 1, '2026-03-19 13:16:41');
INSERT INTO `inventory_movements` VALUES (26, 6, 26, 'purchase', 11, 11, 'import', 1006, 'Nhập túi tote màu đen', 1, '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for order_addresses
-- ----------------------------
DROP TABLE IF EXISTS `order_addresses`;
CREATE TABLE `order_addresses`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` int UNSIGNED NOT NULL,
  `address_type` enum('shipping','billing') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_type` enum('manual','account_saved') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_address_id` int UNSIGNED NULL DEFAULT NULL,
  `receiver_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `province_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `district_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ward_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_addresses_order_type`(`order_id` ASC, `address_type` ASC) USING BTREE,
  INDEX `idx_order_addresses_source`(`source_address_id` ASC) USING BTREE,
  CONSTRAINT `fk_order_addresses_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_addresses_source_address` FOREIGN KEY (`source_address_id`) REFERENCES `customer_addresses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_addresses
-- ----------------------------
INSERT INTO `order_addresses` VALUES (1, 1, 'shipping', 'account_saved', 1, 'Nguyễn Thị Linh', '0901234567', 'TP. Hồ Chí Minh', 'Quận 1', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', '2026-03-19 13:16:41');
INSERT INTO `order_addresses` VALUES (2, 1, 'billing', 'account_saved', 1, 'Nguyễn Thị Linh', '0901234567', 'TP. Hồ Chí Minh', 'Quận 1', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', '2026-03-19 13:16:41');
INSERT INTO `order_addresses` VALUES (3, 2, 'shipping', 'account_saved', 3, 'Trần Hoàng Nam', '0912345678', 'TP. Hồ Chí Minh', 'Quận Bình Thạnh', 'Phường 25', '88 D5', 'Gọi trước khi giao', '2026-03-19 13:16:41');
INSERT INTO `order_addresses` VALUES (4, 3, 'shipping', 'manual', NULL, 'Phạm Gia Hân', '0933456789', 'Khánh Hòa', 'Nha Trang', 'Phường Lộc Thọ', '15 Trần Phú', 'Liên hệ Zalo', '2026-03-19 13:16:41');
INSERT INTO `order_addresses` VALUES (5, 4, 'shipping', 'manual', NULL, 'Lưu Quang Huy', '0944567890', 'TP. Hồ Chí Minh', 'Quận 3', 'Phường Võ Thị Sáu', '120 Cách Mạng Tháng 8', 'Ship giờ hành chính', '2026-03-19 13:16:41');
INSERT INTO `order_addresses` VALUES (6, 5, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 13:17:42');
INSERT INTO `order_addresses` VALUES (7, 6, 'shipping', 'manual', NULL, 'Nguyễn Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 13:21:57');
INSERT INTO `order_addresses` VALUES (8, 7, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 13:39:36');
INSERT INTO `order_addresses` VALUES (9, 8, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 14:10:04');
INSERT INTO `order_addresses` VALUES (10, 9, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 14:15:44');

-- ----------------------------
-- Table structure for order_items
-- ----------------------------
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` int UNSIGNED NOT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `variant_id` int UNSIGNED NULL DEFAULT NULL,
  `product_name_snapshot` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_code_snapshot` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sku_snapshot` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `variant_name_snapshot` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `size_snapshot` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `color_snapshot` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `thumbnail_snapshot` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `quantity` int NOT NULL,
  `original_unit_price` decimal(12, 2) NOT NULL,
  `final_unit_price` decimal(12, 2) NOT NULL,
  `line_total` decimal(12, 2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_items_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_order_items_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_order_items_variant`(`variant_id` ASC) USING BTREE,
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_items
-- ----------------------------
INSERT INTO `order_items` VALUES (1, 1, 1, 5, 'Áo thun gân tăm basic', 'AO_001', 'AO001-DO-M', 'Đỏ / M', 'M', 'Đỏ', '/uploads/products/ao_001_2.jpg', 2, 120000.00, 99000.00, 198000.00, '2026-03-19 13:16:41');
INSERT INTO `order_items` VALUES (2, 1, 6, 25, 'Túi tote canvas mini', 'TUI_001', 'TUI001-KEM-FS', 'Kem / Free size', 'Free size', 'Kem', '/uploads/products/tui_001_main.jpg', 1, 210000.00, 179000.00, 179000.00, '2026-03-19 13:16:41');
INSERT INTO `order_items` VALUES (3, 2, 5, 22, 'Sneaker trắng tối giản', 'GIAY_001', 'GIAY001-40', 'Trắng / 40', '40', 'Trắng', '/uploads/products/giay_001_main.jpg', 1, 590000.00, 520000.00, 520000.00, '2026-03-19 13:16:41');
INSERT INTO `order_items` VALUES (4, 3, 4, 19, 'Váy midi hoa vintage', 'VAY_001', 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', '/uploads/products/vay_001_main.jpg', 1, 350000.00, 315000.00, 315000.00, '2026-03-19 13:16:41');
INSERT INTO `order_items` VALUES (5, 4, 3, 15, 'Quần jean ống suông cạp cao', 'QUAN_001', 'QUAN001-XD-M', 'Xanh đậm / M', 'M', 'Xanh đậm', '/uploads/products/quan_001_main.jpg', 1, 320000.00, 289000.00, 289000.00, '2026-03-19 13:16:41');
INSERT INTO `order_items` VALUES (6, 5, 6, 26, 'Túi tote canvas mini', 'TUI_001', 'TUI001-DEN-FS', 'Đen / Free size', 'Free size', 'Đen', '/uploads/products/tui_001_main.jpg', 1, 210000.00, 179000.00, 179000.00, '2026-03-19 13:17:42');
INSERT INTO `order_items` VALUES (7, 6, 4, 19, 'Váy midi hoa vintage', 'VAY_001', 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', '/uploads/products/vay_001_main.jpg', 1, 350000.00, 315000.00, 315000.00, '2026-03-19 13:21:57');
INSERT INTO `order_items` VALUES (8, 7, 5, 21, 'Sneaker trắng tối giản', 'GIAY_001', 'GIAY001-39', 'Trắng / 39', '39', 'Trắng', '/uploads/products/giay_001_main.jpg', 1, 590000.00, 520000.00, 520000.00, '2026-03-19 13:39:36');
INSERT INTO `order_items` VALUES (9, 8, 4, 19, 'Váy midi hoa vintage', 'VAY_001', 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', '/uploads/products/vay_001_main.jpg', 1, 350000.00, 315000.00, 315000.00, '2026-03-19 14:10:04');
INSERT INTO `order_items` VALUES (10, 9, 1, 11, 'Áo thun gân tăm basic', 'AO_001', 'AO001-VANG-M', 'Vàng / M', 'M', 'Vàng', '/uploads/products/ao_001_main.jpg', 1, 120000.00, 99000.00, 99000.00, '2026-03-19 14:15:44');

-- ----------------------------
-- Table structure for order_status_logs
-- ----------------------------
DROP TABLE IF EXISTS `order_status_logs`;
CREATE TABLE `order_status_logs`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` int UNSIGNED NOT NULL,
  `from_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `to_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `changed_by_type` enum('system','admin','customer','webhook') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_by_id` int UNSIGNED NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_status_logs_order_date`(`order_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `fk_order_status_logs_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_status_logs
-- ----------------------------
INSERT INTO `order_status_logs` VALUES (1, 1, NULL, 'cho_xac_nhan', 'Tạo đơn từ giỏ hàng', 'customer', 1, '2026-03-17 14:00:00');
INSERT INTO `order_status_logs` VALUES (2, 1, 'cho_xac_nhan', 'dang_chuan_bi', 'Đã thanh toán đủ, admin xác nhận', 'admin', 1, '2026-03-17 14:30:00');
INSERT INTO `order_status_logs` VALUES (3, 2, NULL, 'cho_xac_nhan', 'Khách chọn cọc 30%', 'customer', 2, '2026-03-18 09:30:00');
INSERT INTO `order_status_logs` VALUES (4, 2, 'cho_xac_nhan', 'dang_chuan_bi', 'Đã nhận tiền cọc', 'webhook', NULL, '2026-03-18 10:00:00');
INSERT INTO `order_status_logs` VALUES (5, 3, NULL, 'cho_xac_nhan', 'Lead đặt hàng qua Zalo', 'customer', NULL, '2026-03-18 11:15:00');
INSERT INTO `order_status_logs` VALUES (6, 4, NULL, 'cho_xac_nhan', 'Guest checkout web', 'customer', NULL, '2026-03-18 15:30:00');
INSERT INTO `order_status_logs` VALUES (7, 4, 'cho_xac_nhan', 'dang_chuan_bi', 'Thanh toán đủ, chuẩn bị đóng gói', 'admin', 1, '2026-03-18 16:00:00');
INSERT INTO `order_status_logs` VALUES (8, 5, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'system', NULL, '2026-03-19 13:17:42');
INSERT INTO `order_status_logs` VALUES (9, 6, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'system', NULL, '2026-03-19 13:21:57');
INSERT INTO `order_status_logs` VALUES (10, 7, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'customer', 4, '2026-03-19 13:39:36');
INSERT INTO `order_status_logs` VALUES (11, 7, 'cho_xac_nhan', 'cho_xac_nhan', NULL, 'admin', 1, '2026-03-19 14:04:36');
INSERT INTO `order_status_logs` VALUES (12, 8, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới', 'customer', 4, '2026-03-19 14:10:04');
INSERT INTO `order_status_logs` VALUES (13, 9, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'customer', 4, '2026-03-19 14:15:44');
INSERT INTO `order_status_logs` VALUES (14, 9, 'cho_xac_nhan', 'da_giao', NULL, 'admin', 1, '2026-03-19 14:20:18');
INSERT INTO `order_status_logs` VALUES (15, 9, 'da_giao', 'da_giao', NULL, 'admin', 1, '2026-03-19 14:21:15');

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_id` int UNSIGNED NULL DEFAULT NULL,
  `cart_id` int UNSIGNED NULL DEFAULT NULL,
  `checkout_type` enum('guest','account') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `purchase_channel` enum('web','zalo','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_source` enum('product','cart','manual') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'product',
  `contact_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_email` varchar(190) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `customer_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `internal_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `subtotal_amount` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `shipping_fee` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `payment_plan` enum('full','deposit_30','zalo_manual') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `deposit_rate` decimal(5, 2) NOT NULL DEFAULT 0.00,
  `deposit_required_amount` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `paid_amount` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `remaining_amount` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `payment_status` enum('chua_thanh_toan','da_dat_coc','da_thanh_toan','cho_hoan_tien','da_hoan_tien') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'chua_thanh_toan',
  `order_status` enum('cho_xac_nhan','dang_chuan_bi','dang_giao','da_giao','da_huy','tra_hang') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cho_xac_nhan',
  `guest_access_token` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `placed_at` datetime NOT NULL DEFAULT current_timestamp,
  `confirmed_at` datetime NULL DEFAULT NULL,
  `completed_at` datetime NULL DEFAULT NULL,
  `cancelled_at` datetime NULL DEFAULT NULL,
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_orders_order_code`(`order_code` ASC) USING BTREE,
  UNIQUE INDEX `uq_orders_guest_access_token`(`guest_access_token` ASC) USING BTREE,
  INDEX `idx_orders_customer_date`(`customer_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_orders_statuses`(`order_status` ASC, `payment_status` ASC) USING BTREE,
  INDEX `idx_orders_channel_date`(`purchase_channel` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_orders_cart`(`cart_id` ASC) USING BTREE,
  CONSTRAINT `fk_orders_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (1, 'ODR000001', 1, 1, 'account', 'web', 'cart', 'Nguyễn Thị Linh', '0901234567', 'linh@example.com', 'Giao sau 18h', 'Khách VIP tháng 3', 377000.00, 0.00, 25000.00, 402000.00, 'full', 0.00, 0.00, 402000.00, 0.00, 'da_thanh_toan', 'dang_chuan_bi', NULL, '2026-03-17 14:00:00', '2026-03-17 14:30:00', NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `orders` VALUES (2, 'ODR000002', 2, NULL, 'account', 'web', 'product', 'Trần Hoàng Nam', '0912345678', 'nam@example.com', 'Cần giao nhanh', NULL, 520000.00, 0.00, 30000.00, 550000.00, 'deposit_30', 30.00, 165000.00, 165000.00, 385000.00, 'da_dat_coc', 'dang_chuan_bi', NULL, '2026-03-18 09:30:00', '2026-03-18 10:00:00', NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `orders` VALUES (3, 'ODR000003', NULL, NULL, 'guest', 'zalo', 'product', 'Phạm Gia Hân', '0933456789', 'giahan@example.com', 'Liên hệ qua Zalo trước khi ship', 'Lead từ TikTok', 315000.00, 0.00, 25000.00, 340000.00, 'zalo_manual', 0.00, 0.00, 0.00, 340000.00, 'chua_thanh_toan', 'cho_xac_nhan', '1cb1be5e5b14382fa923e58e2f62164d0e2d8682d8629bb249b30a3c928d533d', '2026-03-18 11:15:00', NULL, NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `orders` VALUES (4, 'ODR000004', NULL, 2, 'guest', 'web', 'cart', 'Lưu Quang Huy', '0944567890', 'quanghuy@example.com', 'Ship tới văn phòng', NULL, 289000.00, 0.00, 25000.00, 314000.00, 'full', 0.00, 0.00, 314000.00, 0.00, 'da_thanh_toan', 'dang_chuan_bi', '3b534f7708825ff575d3c20f0aa12263bf445ff8b8d23b9c3880e97aba065619', '2026-03-18 15:30:00', '2026-03-18 15:45:00', NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `orders` VALUES (5, 'DH26031900005', NULL, 3, 'guest', 'web', 'cart', 'Nguyễn Anh Tuấn', '0876726201', 'nguyenanhtuan4831@gmail.com', 'làng lục liễu\r\nlàng lục liễu\r\nlàng lục liễu', NULL, 179000.00, 0.00, 0.00, 179000.00, 'full', 0.00, 179000.00, 0.00, 179000.00, 'chua_thanh_toan', 'cho_xac_nhan', 'cd239ee4563224a6434d76c82bf904d288099e21892e8f00e23c4d700bdb0f39', '2026-03-19 13:17:42', NULL, NULL, NULL, NULL, '2026-03-19 13:17:42', '2026-03-19 13:17:42');
INSERT INTO `orders` VALUES (6, 'DH26031900006', NULL, 4, 'guest', 'web', 'cart', 'Nguyễn Anh Tuấn', '0876726201', 'nguyenanhtuan4831@gmail.com', 'làng lục liễu\r\nlàng lục liễu\r\nlàng lục liễu', NULL, 315000.00, 0.00, 0.00, 315000.00, 'full', 0.00, 315000.00, 0.00, 315000.00, 'chua_thanh_toan', 'cho_xac_nhan', '9f0302d8d426ff26df1bad28b0588cb54b9491b76924d73f6e8ef7d9c623003c', '2026-03-19 13:21:57', NULL, NULL, NULL, NULL, '2026-03-19 13:21:57', '2026-03-19 13:21:57');
INSERT INTO `orders` VALUES (7, 'DH26031900007', 4, 5, 'account', 'web', 'cart', 'Anh Tuấn', '0876726201', 'tuanna9112004@gmail.com', 'alo', NULL, 520000.00, 0.00, 0.00, 520000.00, 'full', 0.00, 520000.00, 520000.00, 0.00, 'da_thanh_toan', 'cho_xac_nhan', '325a6caeb40cd50b7eb82f8f4fec90ff7bbfbf091d5dfde468926bb18c7f0e81', '2026-03-19 13:39:36', NULL, NULL, NULL, NULL, '2026-03-19 13:39:36', '2026-03-19 14:04:36');
INSERT INTO `orders` VALUES (8, 'DH26031900008', 4, NULL, 'account', 'web', 'product', 'Anh Tuấn', '0876726201', 'tuanna9112004@gmail.com', 'abc', NULL, 315000.00, 0.00, 0.00, 315000.00, 'full', 0.00, 315000.00, 0.00, 315000.00, 'chua_thanh_toan', 'cho_xac_nhan', '8c6a7225fc85ed018a089e060a473d67b104f26dc5d921ce8398457df1a018f4', '2026-03-19 14:10:04', NULL, NULL, NULL, NULL, '2026-03-19 14:10:04', '2026-03-19 14:10:04');
INSERT INTO `orders` VALUES (9, 'DH26031900009', 4, 6, 'account', 'web', 'cart', 'Anh Tuấn', '0876726201', 'tuanna9112004@gmail.com', NULL, NULL, 99000.00, 0.00, 0.00, 99000.00, 'deposit_30', 30.00, 29700.00, 99000.00, 0.00, 'da_thanh_toan', 'da_giao', '60ba50a4e0d1b0400b508e6ed231f3d507a19d0e38c0c0a30dd828d3fc03ccfe', '2026-03-19 14:15:44', NULL, '2026-03-19 14:21:15', NULL, NULL, '2026-03-19 14:15:44', '2026-03-19 14:21:15');

-- ----------------------------
-- Table structure for payment_intents
-- ----------------------------
DROP TABLE IF EXISTS `payment_intents`;
CREATE TABLE `payment_intents`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `intent_code` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_id` int UNSIGNED NULL DEFAULT NULL,
  `order_id` int UNSIGNED NULL DEFAULT NULL,
  `wallet_topup_request_id` int UNSIGNED NULL DEFAULT NULL,
  `provider` enum('sepay','wallet','cod','manual') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `purpose` enum('order_full','order_deposit','order_remaining','wallet_topup') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requested_amount` decimal(12, 2) NOT NULL,
  `currency_code` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'VND',
  `status` enum('pending','waiting_payment','paid','failed','expired','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `qr_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `qr_image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `transfer_note` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `expires_at` datetime NULL DEFAULT NULL,
  `idempotency_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `metadata_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_payment_intents_intent_code`(`intent_code` ASC) USING BTREE,
  UNIQUE INDEX `uq_payment_intents_idempotency_key`(`idempotency_key` ASC) USING BTREE,
  INDEX `idx_payment_intents_order_status`(`order_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_payment_intents_customer_status`(`customer_id` ASC, `status` ASC) USING BTREE,
  CONSTRAINT `fk_payment_intents_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_payment_intents_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payment_intents
-- ----------------------------
INSERT INTO `payment_intents` VALUES (1, 'PI000001', 1, 1, NULL, 'sepay', 'order_full', 402000.00, 'VND', 'paid', 'bank=MB&acc=123456789&amount=402000&addInfo=ODR000001', '/qrs/PI000001.png', 'ODR000001', '2026-03-18 23:59:59', 'idem-order-1', '{\"order_code\":\"ODR000001\"}', '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `payment_intents` VALUES (2, 'PI000002', 2, 2, NULL, 'sepay', 'order_deposit', 165000.00, 'VND', 'paid', 'bank=MB&acc=123456789&amount=165000&addInfo=ODR000002-COC', '/qrs/PI000002.png', 'ODR000002-COC', '2026-03-19 23:59:59', 'idem-order-2', '{\"order_code\":\"ODR000002\",\"payment_plan\":\"deposit_30\"}', '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `payment_intents` VALUES (3, 'PI000003', NULL, 4, NULL, 'sepay', 'order_full', 314000.00, 'VND', 'paid', 'bank=MB&acc=123456789&amount=314000&addInfo=ODR000004', '/qrs/PI000003.png', 'ODR000004', '2026-03-19 23:59:59', 'idem-order-4', '{\"order_code\":\"ODR000004\"}', '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `payment_intents` VALUES (4, 'PI000004', 1, NULL, 1, 'sepay', 'wallet_topup', 500000.00, 'VND', 'paid', 'bank=MB&acc=123456789&amount=500000&addInfo=NAPTOPUP001', '/qrs/PI000004.png', 'NAPTOPUP001', '2026-03-20 23:59:59', 'idem-topup-1', '{\"topup_code\":\"TOPUP0001\"}', '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `payment_intents` VALUES (5, 'PAYFF25CCDB9A93', NULL, 5, NULL, 'sepay', 'order_full', 179000.00, 'VND', 'waiting_payment', 'TT DH26031900005 PAYFF25CCDB9A93', '', 'TT DH26031900005 PAYFF25CCDB9A93', '2026-03-20 13:17:42', NULL, NULL, '2026-03-19 13:17:42', '2026-03-19 13:17:42');
INSERT INTO `payment_intents` VALUES (6, 'PAY901EA204D6C6', NULL, 6, NULL, 'sepay', 'order_full', 315000.00, 'VND', 'waiting_payment', 'TT DH26031900006 PAY901EA204D6C6', 'https://qr.sepay.vn/img?acc=0896038072&bank=MBBank&amount=315000&des=TT+DH26031900006+PAY901EA204D6C6', 'TT DH26031900006 PAY901EA204D6C6', '2026-03-20 13:21:57', NULL, NULL, '2026-03-19 13:21:57', '2026-03-19 13:21:57');
INSERT INTO `payment_intents` VALUES (7, 'PAY1D7A3535A99A', 4, 7, NULL, 'sepay', 'order_full', 520000.00, 'VND', 'waiting_payment', 'TT DH26031900007 PAY1D7A3535A99A', 'https://qr.sepay.vn/img?acc=0896038072&bank=MBBank&amount=520000&des=TT+DH26031900007+PAY1D7A3535A99A', 'TT DH26031900007 PAY1D7A3535A99A', '2026-03-20 13:39:36', NULL, NULL, '2026-03-19 13:39:36', '2026-03-19 13:39:36');
INSERT INTO `payment_intents` VALUES (8, 'PAY344A4A2D92DD', 4, 8, NULL, 'sepay', 'order_full', 315000.00, 'VND', 'waiting_payment', 'TT DH26031900008 PAY344A4A2D92DD', 'https://qr.sepay.vn/img?acc=0896038072&bank=MBBank&amount=315000&des=TT+DH26031900008+PAY344A4A2D92DD', 'TT DH26031900008 PAY344A4A2D92DD', '2026-03-20 14:10:04', NULL, NULL, '2026-03-19 14:10:04', '2026-03-19 14:10:04');
INSERT INTO `payment_intents` VALUES (9, 'PAYC6196C41BFA4', 4, 9, NULL, 'sepay', 'order_deposit', 29700.00, 'VND', 'waiting_payment', 'TT DH26031900009 PAYC6196C41BFA4', 'https://qr.sepay.vn/img?acc=0896038072&bank=MBBank&amount=29700&des=TT+DH26031900009+PAYC6196C41BFA4', 'TT DH26031900009 PAYC6196C41BFA4', '2026-03-20 14:15:44', NULL, NULL, '2026-03-19 14:15:44', '2026-03-19 14:15:44');

-- ----------------------------
-- Table structure for payment_webhook_logs
-- ----------------------------
DROP TABLE IF EXISTS `payment_webhook_logs`;
CREATE TABLE `payment_webhook_logs`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `provider` enum('sepay') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_key` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_transaction_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `request_headers_text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `request_body_text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parsed_amount` decimal(12, 2) NULL DEFAULT NULL,
  `parsed_reference_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `parsed_transfer_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `process_status` enum('received','ignored','processed','failed','duplicate') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'received',
  `linked_payment_id` int UNSIGNED NULL DEFAULT NULL,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `processed_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_payment_webhook_logs_provider_event`(`provider` ASC, `event_key` ASC) USING BTREE,
  INDEX `idx_payment_webhook_logs_provider_txn`(`provider_transaction_id` ASC) USING BTREE,
  INDEX `idx_payment_webhook_logs_status`(`process_status` ASC) USING BTREE,
  INDEX `fk_payment_webhook_logs_payment`(`linked_payment_id` ASC) USING BTREE,
  CONSTRAINT `fk_payment_webhook_logs_payment` FOREIGN KEY (`linked_payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payment_webhook_logs
-- ----------------------------
INSERT INTO `payment_webhook_logs` VALUES (1, 'sepay', 'sepay_event_000001', 'SPTXN000001', '{\"authorization\":\"Apikey demo\"}', '{\"id\":\"SPTXN000001\",\"content\":\"ODR000001\",\"transferAmount\":402000}', 402000.00, 'MBREF0001', 'in', 'processed', 1, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `payment_webhook_logs` VALUES (2, 'sepay', 'sepay_event_000002', 'SPTXN000002', '{\"authorization\":\"Apikey demo\"}', '{\"id\":\"SPTXN000002\",\"content\":\"ODR000002-COC\",\"transferAmount\":165000}', 165000.00, 'MBREF0002', 'in', 'processed', 2, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `payment_webhook_logs` VALUES (3, 'sepay', 'sepay_event_000003', 'SPTXN000003', '{\"authorization\":\"Apikey demo\"}', '{\"id\":\"SPTXN000003\",\"content\":\"ODR000004\",\"transferAmount\":314000}', 314000.00, 'MBREF0003', 'in', 'processed', 3, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `payment_webhook_logs` VALUES (4, 'sepay', 'sepay_event_000004', 'SPTXN000004', '{\"authorization\":\"Apikey demo\"}', '{\"id\":\"SPTXN000004\",\"content\":\"NAPTOPUP001\",\"transferAmount\":500000}', 500000.00, 'MBREF0004', 'in', 'processed', 4, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for payments
-- ----------------------------
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `payment_intent_id` int UNSIGNED NOT NULL,
  `customer_id` int UNSIGNED NULL DEFAULT NULL,
  `order_id` int UNSIGNED NULL DEFAULT NULL,
  `provider` enum('sepay','wallet','cod','manual') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_transaction_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_reference_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `transfer_type` enum('in','out') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paid_amount` decimal(12, 2) NOT NULL,
  `fee_amount` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `payment_status` enum('success','failed','pending','reversed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `raw_content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paid_at` datetime NULL DEFAULT NULL,
  `confirmed_at` datetime NULL DEFAULT NULL,
  `raw_payload_text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_payments_provider_txn`(`provider` ASC, `provider_transaction_id` ASC) USING BTREE,
  INDEX `idx_payments_payment_intent`(`payment_intent_id` ASC) USING BTREE,
  INDEX `idx_payments_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_payments_customer`(`customer_id` ASC) USING BTREE,
  CONSTRAINT `fk_payments_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_payments_payment_intent` FOREIGN KEY (`payment_intent_id`) REFERENCES `payment_intents` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payments
-- ----------------------------
INSERT INTO `payments` VALUES (1, 1, 1, 1, 'sepay', 'SPTXN000001', 'MBREF0001', 'in', 402000.00, 0.00, 402000.00, 'success', 'ODR000001', '2026-03-17 14:18:00', '2026-03-17 14:19:00', '{\"id\":\"SPTXN000001\",\"content\":\"ODR000001\",\"transferAmount\":402000}', '2026-03-19 13:16:41');
INSERT INTO `payments` VALUES (2, 2, 2, 2, 'sepay', 'SPTXN000002', 'MBREF0002', 'in', 165000.00, 0.00, 165000.00, 'success', 'ODR000002-COC', '2026-03-18 09:52:00', '2026-03-18 09:53:00', '{\"id\":\"SPTXN000002\",\"content\":\"ODR000002-COC\",\"transferAmount\":165000}', '2026-03-19 13:16:41');
INSERT INTO `payments` VALUES (3, 3, NULL, 4, 'sepay', 'SPTXN000003', 'MBREF0003', 'in', 314000.00, 0.00, 314000.00, 'success', 'ODR000004', '2026-03-18 15:38:00', '2026-03-18 15:39:00', '{\"id\":\"SPTXN000003\",\"content\":\"ODR000004\",\"transferAmount\":314000}', '2026-03-19 13:16:41');
INSERT INTO `payments` VALUES (4, 4, 1, NULL, 'sepay', 'SPTXN000004', 'MBREF0004', 'in', 500000.00, 0.00, 500000.00, 'success', 'NAPTOPUP001', '2026-03-18 17:05:00', '2026-03-18 17:06:00', '{\"id\":\"SPTXN000004\",\"content\":\"NAPTOPUP001\",\"transferAmount\":500000}', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for product_condition_maps
-- ----------------------------
DROP TABLE IF EXISTS `product_condition_maps`;
CREATE TABLE `product_condition_maps`  (
  `product_id` int UNSIGNED NOT NULL,
  `condition_id` int UNSIGNED NOT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`product_id`, `condition_id`) USING BTREE,
  INDEX `idx_product_condition_maps_condition`(`condition_id` ASC) USING BTREE,
  CONSTRAINT `fk_product_condition_maps_condition` FOREIGN KEY (`condition_id`) REFERENCES `product_conditions` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_product_condition_maps_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_condition_maps
-- ----------------------------
INSERT INTO `product_condition_maps` VALUES (2, 1, 1, '2026-03-19 13:16:41');
INSERT INTO `product_condition_maps` VALUES (3, 2, 1, '2026-03-19 13:16:41');
INSERT INTO `product_condition_maps` VALUES (4, 1, 1, '2026-03-19 13:16:41');
INSERT INTO `product_condition_maps` VALUES (5, 2, 1, '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for product_conditions
-- ----------------------------
DROP TABLE IF EXISTS `product_conditions`;
CREATE TABLE `product_conditions`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_product_conditions_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_product_conditions_active_sort`(`is_active` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_conditions
-- ----------------------------
INSERT INTO `product_conditions` VALUES (1, 'Hàng mới', 'hang-moi', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_conditions` VALUES (2, 'Best seller', 'best-seller', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_conditions` VALUES (3, 'Flash sale', 'flash-sale', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for product_images
-- ----------------------------
DROP TABLE IF EXISTS `product_images`;
CREATE TABLE `product_images`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` int UNSIGNED NOT NULL,
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_product_images_product_sort`(`product_id` ASC, `sort_order` ASC) USING BTREE,
  CONSTRAINT `fk_product_images_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_images
-- ----------------------------
INSERT INTO `product_images` VALUES (4, 2, '/uploads/products/ao_002_main.jpg', 1, '2026-03-19 13:16:41');
INSERT INTO `product_images` VALUES (5, 2, '/uploads/products/ao_002_2.jpg', 2, '2026-03-19 13:16:41');
INSERT INTO `product_images` VALUES (6, 3, '/uploads/products/quan_001_main.jpg', 1, '2026-03-19 13:16:41');
INSERT INTO `product_images` VALUES (7, 3, '/uploads/products/quan_001_2.jpg', 2, '2026-03-19 13:16:41');
INSERT INTO `product_images` VALUES (8, 4, '/uploads/products/vay_001_main.jpg', 1, '2026-03-19 13:16:41');
INSERT INTO `product_images` VALUES (9, 5, '/uploads/products/giay_001_main.jpg', 1, '2026-03-19 13:16:41');
INSERT INTO `product_images` VALUES (10, 5, '/uploads/products/giay_001_2.jpg', 2, '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for product_types
-- ----------------------------
DROP TABLE IF EXISTS `product_types`;
CREATE TABLE `product_types`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_id` int UNSIGNED NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_product_types_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_product_types_category_active_sort`(`category_id` ASC, `is_active` ASC, `sort_order` ASC) USING BTREE,
  CONSTRAINT `fk_product_types_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_types
-- ----------------------------
INSERT INTO `product_types` VALUES (1, 1, 'Áo thun', 'ao-thun', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (2, 1, 'Áo sơ mi', 'ao-so-mi', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (3, 1, 'Áo khoác', 'ao-khoac', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (4, 2, 'Quần jean', 'quan-jean', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (5, 2, 'Quần short', 'quan-short', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (6, 2, 'Chân váy', 'chan-vay', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (7, 3, 'Sneaker', 'sneaker', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (8, 3, 'Giày búp bê', 'giay-bup-be', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (9, 4, 'Túi tote', 'tui-tote', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_types` VALUES (10, 4, 'Túi đeo chéo', 'tui-deo-cheo', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for product_variants
-- ----------------------------
DROP TABLE IF EXISTS `product_variants`;
CREATE TABLE `product_variants`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` int UNSIGNED NOT NULL,
  `sku` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `variant_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `size_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `color_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `original_price` decimal(12, 2) NULL DEFAULT NULL,
  `sale_price` decimal(12, 2) NULL DEFAULT NULL,
  `purchase_price` decimal(12, 2) NULL DEFAULT NULL,
  `stock_qty` int NOT NULL DEFAULT 0,
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_product_variants_sku`(`sku` ASC) USING BTREE,
  INDEX `idx_product_variants_product_active`(`product_id` ASC, `is_active` ASC) USING BTREE,
  INDEX `idx_product_variants_product_default`(`product_id` ASC, `is_default` ASC) USING BTREE,
  CONSTRAINT `fk_product_variants_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_variants
-- ----------------------------
INSERT INTO `product_variants` VALUES (1, 1, 'AO001-XANH-S', 'Xanh / S', 'S', 'Xanh', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (2, 1, 'AO001-XANH-M', 'Xanh / M', 'M', 'Xanh', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (3, 1, 'AO001-XANH-L', 'Xanh / L', 'L', 'Xanh', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (4, 1, 'AO001-DO-S', 'Đỏ / S', 'S', 'Đỏ', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (5, 1, 'AO001-DO-M', 'Đỏ / M', 'M', 'Đỏ', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (6, 1, 'AO001-DO-L', 'Đỏ / L', 'L', 'Đỏ', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (7, 1, 'AO001-TIM-S', 'Tím / S', 'S', 'Tím', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_3.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (8, 1, 'AO001-TIM-M', 'Tím / M', 'M', 'Tím', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_3.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (9, 1, 'AO001-TIM-L', 'Tím / L', 'L', 'Tím', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_3.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (10, 1, 'AO001-VANG-S', 'Vàng / S', 'S', 'Vàng', 120000.00, 99000.00, 55000.00, 4, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (11, 1, 'AO001-VANG-M', 'Vàng / M', 'M', 'Vàng', 120000.00, 99000.00, 55000.00, 4, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (12, 1, 'AO001-VANG-L', 'Vàng / L', 'L', 'Vàng', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (13, 2, 'AO002-BE-M', 'Be / M', 'M', 'Be', 280000.00, 249000.00, 145000.00, 10, '/uploads/products/ao_002_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (14, 2, 'AO002-XANHNHAT-L', 'Xanh nhạt / L', 'L', 'Xanh nhạt', 280000.00, 249000.00, 145000.00, 8, '/uploads/products/ao_002_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (15, 3, 'QUAN001-XD-M', 'Xanh đậm / M', 'M', 'Xanh đậm', 320000.00, 289000.00, 180000.00, 9, '/uploads/products/quan_001_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (16, 3, 'QUAN001-XN-L', 'Xanh nhạt / L', 'L', 'Xanh nhạt', 320000.00, 289000.00, 180000.00, 8, '/uploads/products/quan_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (17, 3, 'QUAN001-XD-XL', 'Xanh đậm / XL', 'XL', 'Xanh đậm', 320000.00, 289000.00, 180000.00, 9, '/uploads/products/quan_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (18, 4, 'VAY001-KEM-S', 'Kem hoa nhí / S', 'S', 'Kem hoa nhí', 350000.00, 315000.00, 190000.00, 4, 'uploads/img_69bb9efa5af234.09565613.png', 1, 1, '2026-03-19 13:16:41', '2026-03-19 14:00:10');
INSERT INTO `product_variants` VALUES (19, 4, 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', 350000.00, 315000.00, 190000.00, 4, '/uploads/products/vay_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (20, 4, 'VAY001-KEM-L', 'Kem hoa nhí / L', 'L', 'Kem hoa nhí', 350000.00, 315000.00, 190000.00, 4, '/uploads/products/vay_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (21, 5, 'GIAY001-39', 'Trắng / 39', '39', 'Trắng', 590000.00, 520000.00, 340000.00, 3, '/uploads/products/giay_001_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (22, 5, 'GIAY001-40', 'Trắng / 40', '40', 'Trắng', 590000.00, 520000.00, 340000.00, 4, '/uploads/products/giay_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (23, 5, 'GIAY001-41', 'Trắng / 41', '41', 'Trắng', 590000.00, 520000.00, 340000.00, 4, '/uploads/products/giay_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (24, 5, 'GIAY001-42', 'Trắng / 42', '42', 'Trắng', 590000.00, 520000.00, 340000.00, 3, '/uploads/products/giay_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (25, 6, 'TUI001-KEM-FS', 'Kem / Free size', 'Free size', 'Kem', 210000.00, 179000.00, 95000.00, 11, '/uploads/products/tui_001_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `product_variants` VALUES (26, 6, 'TUI001-DEN-FS', 'Đen / Free size', 'Free size', 'Đen', 210000.00, 179000.00, 95000.00, 11, '/uploads/products/tui_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for products
-- ----------------------------
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` int UNSIGNED NOT NULL,
  `product_type_id` int UNSIGNED NOT NULL,
  `style_id` int UNSIGNED NULL DEFAULT NULL,
  `gender` enum('Nam','Nữ','Unisex') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Unisex',
  `original_price` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `sale_price` decimal(12, 2) NULL DEFAULT NULL,
  `purchase_price` decimal(12, 2) NULL DEFAULT NULL,
  `note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `material` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `information` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `short_description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `quantity` int NOT NULL DEFAULT 0,
  `track_inventory` tinyint(1) NOT NULL DEFAULT 1,
  `allow_backorder` tinyint(1) NOT NULL DEFAULT 0,
  `min_stock_alert` int NOT NULL DEFAULT 0,
  `supplier_contact` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `import_link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `thumbnail` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `published_at` datetime NULL DEFAULT NULL,
  `deleted_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  `is_hidden` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_products_product_code`(`product_code` ASC) USING BTREE,
  UNIQUE INDEX `uq_products_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_products_category_active`(`category_id` ASC, `is_active` ASC) USING BTREE,
  INDEX `idx_products_product_type_active`(`product_type_id` ASC, `is_active` ASC) USING BTREE,
  INDEX `idx_products_style_active`(`style_id` ASC, `is_active` ASC) USING BTREE,
  INDEX `idx_products_gender_active`(`gender` ASC, `is_active` ASC) USING BTREE,
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_products_product_type` FOREIGN KEY (`product_type_id`) REFERENCES `product_types` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_products_style` FOREIGN KEY (`style_id`) REFERENCES `styles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of products
-- ----------------------------
INSERT INTO `products` VALUES (1, 'Áo thun gân tăm basic', 'ao-thun-gan-tam-basic', 'AO_001', 1, 1, 1, 'Nữ', 120000.00, 99000.00, 55000.00, 'Mẫu bán chạy quanh năm', 'Thun gân', 'Áo thun gân tăm co giãn tốt, form ôm nhẹ, dễ phối với chân váy hoặc quần jean.', 'Áo thun nữ form ôm basic, dễ phối đồ.', 38, 1, 0, 5, 'Kho sỉ Quận 5', 'https://zalo.me/0961691107', '/uploads/products/ao_001_main.jpg', 1, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:56:15', 0);
INSERT INTO `products` VALUES (2, 'Áo sơ mi linen oversize', 'ao-so-mi-linen-oversize', 'AO_002', 1, 2, 4, 'Unisex', 280000.00, 249000.00, 145000.00, 'Mát, dễ lên ảnh', 'Linen pha cotton', 'Áo sơ mi tay dài form rộng, chất vải thoáng, phù hợp đi làm hoặc đi chơi.', 'Sơ mi linen form rộng thanh lịch.', 18, 1, 0, 3, 'Xưởng Bình Tân', 'https://zalo.me/0961691107', '/uploads/products/ao_002_main.jpg', 1, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:56:18', 0);
INSERT INTO `products` VALUES (3, 'Quần jean ống suông cạp cao', 'quan-jean-ong-suong-cap-cao', 'QUAN_001', 2, 4, 2, 'Nữ', 320000.00, 289000.00, 180000.00, 'Tôn dáng, dễ bán online', 'Jean cotton', 'Quần jean ống suông cạp cao, tôn dáng, hợp với nhiều kiểu áo basic.', 'Jean ống suông cạp cao, hack dáng.', 26, 1, 0, 4, 'Kho sỉ Tân Bình', 'https://zalo.me/0961691107', '/uploads/products/quan_001_main.jpg', 1, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:37:08', 0);
INSERT INTO `products` VALUES (4, 'Váy midi hoa vintage', 'vay-midi-hoa-vintage', 'VAY_001', 2, 6, 3, 'Nữ', 350000.00, 315000.00, 190000.00, 'Ảnh lookbook đẹp', 'Voan lót cotton', 'Váy midi họa tiết hoa nhí phong cách vintage, thích hợp dạo phố và đi biển.', 'Váy midi nữ tính, phong cách vintage.', 12, 1, 0, 2, 'Kho Đà Lạt', 'https://zalo.me/0961691107', '/uploads/products/vay_001_main.jpg', 1, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 14:00:10', 0);
INSERT INTO `products` VALUES (5, 'Sneaker trắng tối giản', 'sneaker-trang-toi-gian', 'GIAY_001', 3, 7, 1, 'Unisex', 590000.00, 520000.00, 340000.00, 'Mẫu dễ bán cho cả nam nữ', 'Da tổng hợp', 'Sneaker trắng thiết kế tối giản, dễ phối đồ, đế êm và nhẹ.', 'Sneaker trắng basic cho outfit hằng ngày.', 14, 1, 0, 2, 'Kho Giày Bình Dương', 'https://zalo.me/0961691107', '/uploads/products/giay_001_main.jpg', 0, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:58:38', 0);
INSERT INTO `products` VALUES (6, 'Túi tote canvas mini', 'tui-tote-canvas-mini', 'TUI_001', 4, 9, 1, 'Nữ', 210000.00, 179000.00, 95000.00, 'Phụ kiện mua kèm tốt', 'Canvas dày', 'Túi tote canvas mini gọn nhẹ, phù hợp đi học và đi chơi.', 'Túi tote mini dễ phối đồ.', 22, 1, 0, 3, 'Kho phụ kiện Q10', 'https://zalo.me/0961691107', '/uploads/products/tui_001_main.jpg', 0, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:58:22', 0);

-- ----------------------------
-- Table structure for styles
-- ----------------------------
DROP TABLE IF EXISTS `styles`;
CREATE TABLE `styles`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_styles_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_styles_active_sort`(`is_active` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of styles
-- ----------------------------
INSERT INTO `styles` VALUES (1, 'Basic', 'basic', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `styles` VALUES (2, 'Streetwear', 'streetwear', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `styles` VALUES (3, 'Vintage', 'vintage', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `styles` VALUES (4, 'Thanh lịch', 'thanh-lich', 4, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for wallet_accounts
-- ----------------------------
DROP TABLE IF EXISTS `wallet_accounts`;
CREATE TABLE `wallet_accounts`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NOT NULL,
  `status` enum('active','locked','disabled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `balance_cached` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `total_credited` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `total_debited` decimal(12, 2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_wallet_accounts_customer`(`customer_id` ASC) USING BTREE,
  INDEX `idx_wallet_accounts_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_wallet_accounts_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallet_accounts
-- ----------------------------
INSERT INTO `wallet_accounts` VALUES (1, 1, 'active', 350000.00, 500000.00, 150000.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `wallet_accounts` VALUES (2, 2, 'active', 0.00, 0.00, 0.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `wallet_accounts` VALUES (3, 3, 'active', 0.00, 0.00, 0.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for wallet_ledger
-- ----------------------------
DROP TABLE IF EXISTS `wallet_ledger`;
CREATE TABLE `wallet_ledger`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `wallet_account_id` int UNSIGNED NOT NULL,
  `customer_id` int UNSIGNED NOT NULL,
  `entry_type` enum('topup_credit','order_debit','refund_credit','admin_adjustment','reversal') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_type` enum('wallet_topup','order','refund','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_id` int UNSIGNED NOT NULL,
  `amount_change` decimal(12, 2) NOT NULL,
  `balance_before` decimal(12, 2) NOT NULL,
  `balance_after` decimal(12, 2) NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `related_payment_id` int UNSIGNED NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_wallet_ledger_wallet_date`(`wallet_account_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_wallet_ledger_customer_date`(`customer_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_wallet_ledger_source`(`source_type` ASC, `source_id` ASC) USING BTREE,
  INDEX `idx_wallet_ledger_payment`(`related_payment_id` ASC) USING BTREE,
  CONSTRAINT `fk_wallet_ledger_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_wallet_ledger_related_payment` FOREIGN KEY (`related_payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_wallet_ledger_wallet_account` FOREIGN KEY (`wallet_account_id`) REFERENCES `wallet_accounts` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallet_ledger
-- ----------------------------
INSERT INTO `wallet_ledger` VALUES (1, 1, 1, 'topup_credit', 'wallet_topup', 1, 500000.00, 0.00, 500000.00, 'Nạp ví qua SePay TOPUP0001', 4, '2026-03-18 17:06:00');
INSERT INTO `wallet_ledger` VALUES (2, 1, 1, 'order_debit', 'order', 1, -150000.00, 500000.00, 350000.00, 'Trừ ví cho đơn hàng demo ODR000001', NULL, '2026-03-18 18:00:00');

-- ----------------------------
-- Table structure for wallet_topup_requests
-- ----------------------------
DROP TABLE IF EXISTS `wallet_topup_requests`;
CREATE TABLE `wallet_topup_requests`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NOT NULL,
  `topup_code` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requested_amount` decimal(12, 2) NOT NULL,
  `status` enum('pending','waiting_payment','confirmed','expired','cancelled','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `payment_intent_id` int UNSIGNED NULL DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `expires_at` datetime NULL DEFAULT NULL,
  `confirmed_at` datetime NULL DEFAULT NULL,
  `cancelled_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_wallet_topup_requests_topup_code`(`topup_code` ASC) USING BTREE,
  UNIQUE INDEX `uq_wallet_topup_requests_payment_intent`(`payment_intent_id` ASC) USING BTREE,
  INDEX `idx_wallet_topup_requests_customer_status`(`customer_id` ASC, `status` ASC) USING BTREE,
  CONSTRAINT `fk_wallet_topup_requests_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_wallet_topup_requests_payment_intent` FOREIGN KEY (`payment_intent_id`) REFERENCES `payment_intents` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallet_topup_requests
-- ----------------------------
INSERT INTO `wallet_topup_requests` VALUES (1, 1, 'TOPUP0001', 500000.00, 'confirmed', 4, 'Khách nạp ví để mua sau', '2026-03-20 23:59:59', '2026-03-18 17:06:00', NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

SET FOREIGN_KEY_CHECKS = 1;


-- --------------------------------------------------------
-- URL đẹp cho chi tiết sản phẩm: /{category-slug}/{product-slug}.html
-- Bổ sung chuẩn hoá slug cho dữ liệu hiện có
-- --------------------------------------------------------
UPDATE products SET slug = 'ao-thun-gan-tam-basic' WHERE id = 1;
UPDATE products SET slug = 'ao-so-mi-linen-oversize' WHERE id = 2;
UPDATE products SET slug = 'quan-jean-ong-suong-cap-cao' WHERE id = 3;
UPDATE products SET slug = 'vay-midi-hoa-vintage' WHERE id = 4;
UPDATE products SET slug = 'sneaker-trang-toi-gian' WHERE id = 5;
UPDATE products SET slug = 'tui-tote-canvas-mini' WHERE id = 6;

UPDATE categories SET slug = 'ao' WHERE id = 1;
UPDATE categories SET slug = 'quan' WHERE id = 2;
UPDATE categories SET slug = 'giay' WHERE id = 3;
UPDATE categories SET slug = 'tui-xach' WHERE id = 4;
