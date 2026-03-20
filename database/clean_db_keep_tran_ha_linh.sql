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

 Date: 20/03/2026 23:32:13
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_audit_logs
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `app_settings` VALUES ('sepay_webhook_api_key', 'DMM_SEPAY_2026_SECRET_8899', '2026-03-20 21:07:49');
INSERT INTO `app_settings` VALUES ('shipping_default_fee', '30000', '2026-03-20 21:49:15');
INSERT INTO `app_settings` VALUES ('shipping_freeship_threshold', '500000', '2026-03-20 21:49:54');
INSERT INTO `app_settings` VALUES ('shop_address', 'Hà Nội', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_email', '', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_logo', 'img/logo.jpg', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_name', 'Duong Mot Mi', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_phone', '0961.691.107', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_tagline', 'Khám phá phong cách thời trang trẻ trung, hiện đại. Chúng tôi cam kết mang đến cho bạn những sản phẩm chất lượng với dịch vụ chốt đơn nhanh chóng, tận tâm.', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('shop_working_hours', '08:00 - 22:00 (T2 - CN)', '2026-03-19 13:41:49');
INSERT INTO `app_settings` VALUES ('telegram_bot_token', '8676269115:AAGCfwgTUcZUwry6jdh5hpHEptX5Tnhapi8', '2026-03-20 15:29:16');
INSERT INTO `app_settings` VALUES ('telegram_bot_username', 'DuongMotMIshop_notify_bot', '2026-03-20 15:29:18');
INSERT INTO `app_settings` VALUES ('telegram_chat_id', '-5274178899', '2026-03-20 15:29:28');
INSERT INTO `app_settings` VALUES ('telegram_notify_enabled', '1', '2026-03-20 15:29:30');
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cart_items
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of carts
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of categories
-- ----------------------------
INSERT INTO `categories` VALUES (1, 'Áo', 'ao', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `categories` VALUES (2, 'Quần', 'quan', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `categories` VALUES (3, 'Giày', 'giay', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `categories` VALUES (4, 'Túi xách', 'tui-xach', 4, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `categories` VALUES (6, 'FULL BỘ', 'full-bo', 5, 1, '2026-03-20 16:49:10', '2026-03-20 16:49:10');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customer_addresses
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customer_auth_tokens
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customer_oauth_accounts
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customer_security_logs
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customer_sessions
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customers
-- ----------------------------
INSERT INTO `customers` VALUES (2, 'CUS000002', 'Trần Hà Linh', 'tranhalingg@gmail.com', NULL, '$2y$10$NZdGOxCq35qdwTD8YXK8VuzrxYNM5ZFe8C1o7/8ws1D/VZM1.TMs.', NULL, NULL, NULL, 'active', 'local', NULL, NULL, '2026-03-20 21:02:58', '2026-03-20 21:02:58', '2026-03-20 21:03:04', NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of inventory_movements
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_addresses
-- ----------------------------
INSERT INTO `order_addresses` VALUES (10, 10, 'shipping', 'manual', NULL, 'Trần Hà Linh', '0971450251', 'Tỉnh Vĩnh Phúc', 'Huyện Tam Đảo', 'Xã Đạo Trù', 'K1 Trại giam Vĩnh Quang', NULL, '2026-03-20 21:10:47');

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
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_items
-- ----------------------------
INSERT INTO `order_items` VALUES (24, 10, 28, 222, 'SƠ MI LOUIS VUITTON', 'AO_014', 'AO014-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 'uploads/img_69bd2027914880.70605348.jpg', 1, 530000.00, 279000.00, 279000.00, '2026-03-20 21:10:47');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_status_logs
-- ----------------------------

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
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
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
  `request_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
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
  UNIQUE INDEX `uq_orders_request_id`(`request_id` ASC) USING BTREE,
  CONSTRAINT `fk_orders_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (10, 'DH26032000010', 2, NULL, 'account', 'web', NULL, 'product', 'Trần Hà Linh', '0971450251', 'tranhalingg@gmail.com', NULL, NULL, 279000.00, 0.00, 0.00, 279000.00, 'deposit_30', 30.00, 83700.00, 83700.00, 195300.00, 'da_dat_coc', 'cho_xac_nhan', '05fecfb69d612e522ee7fc4dd7c30e1a9e9061fd5550228da87c32c8d4416438', NULL, '2026-03-20 21:10:47', NULL, NULL, NULL, NULL, '2026-03-20 21:10:47', '2026-03-20 21:11:27');

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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of payment_intents
-- ----------------------------
INSERT INTO `payment_intents` VALUES (9, 'PAYAC5204E8F895', 2, 10, NULL, 'sepay', 'order_deposit', 83700.00, 'VND', 'paid', 'TT DH26032000010 PAYAC5204E8F895', 'https://qr.sepay.vn/img?acc=VQRQAHSJJ1234&bank=MBBank&amount=83700&des=TT+DH26032000010+PAYAC5204E8F895', 'TT DH26032000010 PAYAC5204E8F895', '2026-03-21 21:10:47', NULL, NULL, '2026-03-20 21:10:47', '2026-03-20 21:11:27');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of payment_webhook_logs
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of payments
-- ----------------------------
INSERT INTO `payments` VALUES (9, 9, 2, 10, 'sepay', '46130744', 'FT26079502046957', 'in', 83700.00, 0.00, 83700.00, 'success', 'QAHSJJ1234  SEPAY12022 1  TT DH26032000010 PAYAC5204E8F895', '2026-03-20 21:11:27', '2026-03-20 21:11:27', '{\"gateway\":\"MBBank\",\"transactionDate\":\"2026-03-20 21:11:27\",\"accountNumber\":\"0961691107\",\"subAccount\":\"VQRQAHSJJ1234\",\"code\":\"DH2603200001\",\"content\":\"QAHSJJ1234  SEPAY12022 1  TT DH26032000010 PAYAC5204E8F895\",\"transferType\":\"in\",\"description\":\"BankAPINotify QAHSJJ1234  SEPAY12022 1  TT DH26032000010 PAYAC5204E8F895\",\"transferAmount\":83700,\"referenceCode\":\"FT26079502046957\",\"accumulated\":0,\"id\":46130744}', '2026-03-20 21:11:27');

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product_condition_maps
-- ----------------------------
INSERT INTO `product_condition_maps` VALUES (8, 1, 1, '2026-03-20 15:51:56');
INSERT INTO `product_condition_maps` VALUES (9, 1, 1, '2026-03-20 15:57:27');
INSERT INTO `product_condition_maps` VALUES (10, 1, 1, '2026-03-20 16:04:51');
INSERT INTO `product_condition_maps` VALUES (11, 1, 1, '2026-03-20 16:12:20');
INSERT INTO `product_condition_maps` VALUES (12, 1, 1, '2026-03-20 16:15:45');
INSERT INTO `product_condition_maps` VALUES (13, 1, 1, '2026-03-20 16:18:35');
INSERT INTO `product_condition_maps` VALUES (14, 1, 1, '2026-03-20 16:32:02');
INSERT INTO `product_condition_maps` VALUES (15, 1, 1, '2026-03-20 16:31:54');
INSERT INTO `product_condition_maps` VALUES (16, 1, 1, '2026-03-20 16:30:46');
INSERT INTO `product_condition_maps` VALUES (17, 1, 1, '2026-03-20 16:37:24');
INSERT INTO `product_condition_maps` VALUES (18, 1, 1, '2026-03-20 19:47:44');
INSERT INTO `product_condition_maps` VALUES (19, 1, 1, '2026-03-20 16:44:17');
INSERT INTO `product_condition_maps` VALUES (20, 1, 1, '2026-03-20 16:47:38');
INSERT INTO `product_condition_maps` VALUES (21, 1, 1, '2026-03-20 16:52:09');
INSERT INTO `product_condition_maps` VALUES (22, 1, 1, '2026-03-20 17:02:16');
INSERT INTO `product_condition_maps` VALUES (23, 1, 1, '2026-03-20 17:07:30');
INSERT INTO `product_condition_maps` VALUES (24, 1, 1, '2026-03-20 17:10:28');
INSERT INTO `product_condition_maps` VALUES (25, 1, 1, '2026-03-20 17:14:19');
INSERT INTO `product_condition_maps` VALUES (26, 1, 1, '2026-03-20 17:18:59');
INSERT INTO `product_condition_maps` VALUES (27, 1, 1, '2026-03-20 17:21:12');
INSERT INTO `product_condition_maps` VALUES (28, 1, 1, '2026-03-20 17:24:00');
INSERT INTO `product_condition_maps` VALUES (29, 1, 1, '2026-03-20 17:36:10');
INSERT INTO `product_condition_maps` VALUES (30, 1, 1, '2026-03-20 17:41:01');
INSERT INTO `product_condition_maps` VALUES (32, 1, 1, '2026-03-20 17:47:28');
INSERT INTO `product_condition_maps` VALUES (33, 1, 1, '2026-03-20 17:52:08');
INSERT INTO `product_condition_maps` VALUES (34, 1, 1, '2026-03-20 17:55:54');
INSERT INTO `product_condition_maps` VALUES (35, 1, 1, '2026-03-20 17:59:31');

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 451 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product_images
-- ----------------------------
INSERT INTO `product_images` VALUES (1, 8, 'uploads/img_69bd0aac4cdb85.83013757.jpg', 1, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (2, 8, 'uploads/img_69bd0aac4c9838.23589989.jpg', 2, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (3, 8, 'uploads/img_69bd0aac4cb722.67750291.jpg', 3, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (4, 8, 'uploads/img_69bd0aac4d0f00.60463156.jpg', 4, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (5, 8, 'uploads/img_69bd0aac4d4442.06071792.jpg', 5, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (6, 8, 'uploads/img_69bd0aac4d76d9.62919279.jpg', 6, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (7, 8, 'uploads/img_69bd0aac4d9cc2.26546214.jpg', 7, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (8, 8, 'uploads/img_69bd0aac4dc580.11309611.jpg', 8, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (9, 8, 'uploads/img_69bd0aac4de677.30769984.jpg', 9, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (10, 8, 'uploads/img_69bd0aac4e0551.97643257.jpg', 10, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (11, 8, 'uploads/img_69bd0aac4e2887.82543027.jpg', 11, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (12, 8, 'uploads/img_69bd0aac4e3dc2.16528911.jpg', 12, '2026-03-20 15:51:56');
INSERT INTO `product_images` VALUES (13, 9, 'uploads/img_69bd0bf77d2b65.71813569.jpg', 1, '2026-03-20 15:57:27');
INSERT INTO `product_images` VALUES (14, 9, 'uploads/img_69bd0bf77d4f32.81228545.jpg', 2, '2026-03-20 15:57:27');
INSERT INTO `product_images` VALUES (15, 9, 'uploads/img_69bd0bf77d6660.23047888.jpg', 3, '2026-03-20 15:57:27');
INSERT INTO `product_images` VALUES (16, 9, 'uploads/img_69bd0bf77d7c67.80621108.jpg', 4, '2026-03-20 15:57:27');
INSERT INTO `product_images` VALUES (17, 9, 'uploads/img_69bd0bf77d91e3.86278483.jpg', 5, '2026-03-20 15:57:27');
INSERT INTO `product_images` VALUES (18, 9, 'uploads/img_69bd0bf77da5d1.96173278.jpg', 6, '2026-03-20 15:57:27');
INSERT INTO `product_images` VALUES (19, 9, 'uploads/img_69bd0bf77dba11.52150164.jpg', 7, '2026-03-20 15:57:27');
INSERT INTO `product_images` VALUES (20, 9, 'uploads/img_69bd0bf77dcda6.62187701.jpg', 8, '2026-03-20 15:57:27');
INSERT INTO `product_images` VALUES (21, 10, 'uploads/img_69bd0db3cf6ee9.62724580.jpg', 1, '2026-03-20 16:04:51');
INSERT INTO `product_images` VALUES (22, 10, 'uploads/img_69bd0db3cf46e7.21413484.jpg', 2, '2026-03-20 16:04:51');
INSERT INTO `product_images` VALUES (23, 10, 'uploads/img_69bd0db3cf92f1.48431985.jpg', 3, '2026-03-20 16:04:51');
INSERT INTO `product_images` VALUES (24, 10, 'uploads/img_69bd0db3cfdd89.92174603.jpg', 4, '2026-03-20 16:04:51');
INSERT INTO `product_images` VALUES (25, 10, 'uploads/img_69bd0db3d00829.69279947.jpg', 5, '2026-03-20 16:04:51');
INSERT INTO `product_images` VALUES (26, 10, 'uploads/img_69bd0db3d02755.03321668.jpg', 6, '2026-03-20 16:04:51');
INSERT INTO `product_images` VALUES (27, 10, 'uploads/img_69bd0db3d041a6.50222583.jpg', 7, '2026-03-20 16:04:51');
INSERT INTO `product_images` VALUES (28, 11, 'uploads/img_69bd0f7470e496.60229307.jpg', 1, '2026-03-20 16:12:20');
INSERT INTO `product_images` VALUES (29, 11, 'uploads/img_69bd0f747137e9.82674560.jpg', 2, '2026-03-20 16:12:20');
INSERT INTO `product_images` VALUES (30, 11, 'uploads/img_69bd0f74718530.76073142.jpg', 3, '2026-03-20 16:12:20');
INSERT INTO `product_images` VALUES (31, 11, 'uploads/img_69bd0f7471b392.91985470.jpg', 4, '2026-03-20 16:12:20');
INSERT INTO `product_images` VALUES (32, 11, 'uploads/img_69bd0f7471cf70.72404049.jpg', 5, '2026-03-20 16:12:20');
INSERT INTO `product_images` VALUES (33, 11, 'uploads/img_69bd0f7471e971.90157491.jpg', 6, '2026-03-20 16:12:20');
INSERT INTO `product_images` VALUES (34, 11, 'uploads/img_69bd0f74721750.19878380.jpg', 7, '2026-03-20 16:12:20');
INSERT INTO `product_images` VALUES (35, 12, 'uploads/img_69bd1041c01701.58585412.jpg', 1, '2026-03-20 16:15:45');
INSERT INTO `product_images` VALUES (36, 12, 'uploads/img_69bd1041bfd7c0.40639321.jpg', 2, '2026-03-20 16:15:45');
INSERT INTO `product_images` VALUES (37, 12, 'uploads/img_69bd1041bffb80.79376462.jpg', 3, '2026-03-20 16:15:45');
INSERT INTO `product_images` VALUES (38, 12, 'uploads/img_69bd1041c030f1.75542985.jpg', 4, '2026-03-20 16:15:45');
INSERT INTO `product_images` VALUES (39, 12, 'uploads/img_69bd1041c04914.98056678.jpg', 5, '2026-03-20 16:15:45');
INSERT INTO `product_images` VALUES (40, 12, 'uploads/img_69bd1041c06094.70578931.jpg', 6, '2026-03-20 16:15:45');
INSERT INTO `product_images` VALUES (41, 12, 'uploads/img_69bd1041c07966.46405219.jpg', 7, '2026-03-20 16:15:45');
INSERT INTO `product_images` VALUES (42, 13, 'uploads/img_69bd10eba43375.72503824.jpg', 1, '2026-03-20 16:18:35');
INSERT INTO `product_images` VALUES (43, 13, 'uploads/img_69bd10eba496b7.92576444.jpg', 2, '2026-03-20 16:18:35');
INSERT INTO `product_images` VALUES (44, 13, 'uploads/img_69bd10eba4b505.54756598.jpg', 3, '2026-03-20 16:18:35');
INSERT INTO `product_images` VALUES (45, 13, 'uploads/img_69bd10eba4d4e4.03639701.jpg', 4, '2026-03-20 16:18:35');
INSERT INTO `product_images` VALUES (46, 13, 'uploads/img_69bd10eba4ee60.07716245.jpg', 5, '2026-03-20 16:18:35');
INSERT INTO `product_images` VALUES (47, 13, 'uploads/img_69bd10eba507d8.49128061.jpg', 6, '2026-03-20 16:18:35');
INSERT INTO `product_images` VALUES (48, 13, 'uploads/img_69bd10eba521e0.65392130.jpg', 7, '2026-03-20 16:18:35');
INSERT INTO `product_images` VALUES (49, 13, 'uploads/img_69bd10eba53ab8.62093132.jpg', 8, '2026-03-20 16:18:35');
INSERT INTO `product_images` VALUES (61, 16, 'uploads/img_69bd13c640ac34.82330259.jpg', 1, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (62, 16, 'uploads/img_69bd13c6410fa2.77528959.jpg', 2, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (63, 16, 'uploads/img_69bd13c6412c89.25807295.jpg', 3, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (64, 16, 'uploads/img_69bd13c6414717.47585107.jpg', 4, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (65, 16, 'uploads/img_69bd13c6415ff3.94545171.jpg', 5, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (66, 16, 'uploads/img_69bd13c6417a58.34830965.jpg', 6, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (67, 16, 'uploads/img_69bd13c6419515.15953777.jpg', 7, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (68, 16, 'uploads/img_69bd13c641ada5.04778799.jpg', 8, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (69, 16, 'uploads/img_69bd13c641c6d8.35713909.jpg', 9, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (70, 16, 'uploads/img_69bd13c641df85.44123453.jpg', 10, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (71, 16, 'uploads/img_69bd13c6421404.38447730.jpg', 11, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (72, 16, 'uploads/img_69bd13c6426cb4.72990220.jpg', 12, '2026-03-20 16:30:46');
INSERT INTO `product_images` VALUES (73, 15, 'uploads/img_69bd1304aeff58.59603043.jpg', 1, '2026-03-20 16:31:54');
INSERT INTO `product_images` VALUES (74, 15, 'uploads/img_69bd1304af26f2.46006930.jpg', 2, '2026-03-20 16:31:54');
INSERT INTO `product_images` VALUES (75, 15, 'uploads/img_69bd1304af4535.70868766.jpg', 3, '2026-03-20 16:31:54');
INSERT INTO `product_images` VALUES (76, 15, 'uploads/img_69bd1304af60e3.83161260.jpg', 4, '2026-03-20 16:31:54');
INSERT INTO `product_images` VALUES (77, 15, 'uploads/img_69bd1304af79b3.88078334.jpg', 5, '2026-03-20 16:31:54');
INSERT INTO `product_images` VALUES (78, 15, 'uploads/img_69bd1304af9d26.16922939.jpg', 6, '2026-03-20 16:31:54');
INSERT INTO `product_images` VALUES (79, 14, 'uploads/img_69bd11bc0f9047.69231849.jpg', 1, '2026-03-20 16:32:02');
INSERT INTO `product_images` VALUES (80, 14, 'uploads/img_69bd11bc0fc0a5.71211549.jpg', 2, '2026-03-20 16:32:02');
INSERT INTO `product_images` VALUES (81, 14, 'uploads/img_69bd11bc0fdd26.97325570.jpg', 3, '2026-03-20 16:32:02');
INSERT INTO `product_images` VALUES (82, 14, 'uploads/img_69bd11bc0ff614.61038727.jpg', 4, '2026-03-20 16:32:02');
INSERT INTO `product_images` VALUES (83, 14, 'uploads/img_69bd11bc101e46.56521590.jpg', 5, '2026-03-20 16:32:02');
INSERT INTO `product_images` VALUES (84, 17, 'uploads/img_69bd15549edf44.03742521.jpg', 1, '2026-03-20 16:37:24');
INSERT INTO `product_images` VALUES (85, 17, 'uploads/img_69bd15549f0b05.37997053.jpg', 2, '2026-03-20 16:37:24');
INSERT INTO `product_images` VALUES (86, 17, 'uploads/img_69bd15549f31e8.17092037.jpg', 3, '2026-03-20 16:37:24');
INSERT INTO `product_images` VALUES (87, 17, 'uploads/img_69bd15549f4c62.89251853.jpg', 4, '2026-03-20 16:37:24');
INSERT INTO `product_images` VALUES (88, 17, 'uploads/img_69bd15549f64c5.10616785.jpg', 5, '2026-03-20 16:37:24');
INSERT INTO `product_images` VALUES (89, 17, 'uploads/img_69bd15549f7ca0.45293426.jpg', 6, '2026-03-20 16:37:24');
INSERT INTO `product_images` VALUES (105, 19, 'uploads/img_69bd16f1d0dbd3.31103403.jpg', 1, '2026-03-20 16:44:17');
INSERT INTO `product_images` VALUES (106, 19, 'uploads/img_69bd16f1d0a5e7.79479137.jpg', 2, '2026-03-20 16:44:17');
INSERT INTO `product_images` VALUES (107, 19, 'uploads/img_69bd16f1d10738.19798057.jpg', 3, '2026-03-20 16:44:17');
INSERT INTO `product_images` VALUES (108, 19, 'uploads/img_69bd16f1d12b42.19800098.jpg', 4, '2026-03-20 16:44:17');
INSERT INTO `product_images` VALUES (109, 19, 'uploads/img_69bd16f1d14397.47534706.jpg', 5, '2026-03-20 16:44:17');
INSERT INTO `product_images` VALUES (110, 19, 'uploads/img_69bd16f1d15aa7.00225869.jpg', 6, '2026-03-20 16:44:17');
INSERT INTO `product_images` VALUES (111, 19, 'uploads/img_69bd16f1d17073.53345224.jpg', 7, '2026-03-20 16:44:17');
INSERT INTO `product_images` VALUES (112, 19, 'uploads/img_69bd16f1d18897.01492545.jpg', 8, '2026-03-20 16:44:17');
INSERT INTO `product_images` VALUES (113, 20, 'uploads/img_69bd17bacd1b95.97881465.jpg', 1, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (114, 20, 'uploads/img_69bd17bacd4344.40274952.jpg', 2, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (115, 20, 'uploads/img_69bd17bacd6690.57996529.jpg', 3, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (116, 20, 'uploads/img_69bd17bacd94d6.35289182.jpg', 4, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (117, 20, 'uploads/img_69bd17bacdca31.08831943.jpg', 5, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (118, 20, 'uploads/img_69bd17bace02c7.58859361.jpg', 6, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (119, 20, 'uploads/img_69bd17bace3e57.63018881.jpg', 7, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (120, 20, 'uploads/img_69bd17bace6214.82753621.jpg', 8, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (121, 20, 'uploads/img_69bd17bace8b32.06107418.jpg', 9, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (122, 20, 'uploads/img_69bd17bacebb89.91945702.jpg', 10, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (123, 20, 'uploads/img_69bd17bacef260.26689699.jpg', 11, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (124, 20, 'uploads/img_69bd17bacf1976.40140723.jpg', 12, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (125, 20, 'uploads/img_69bd17bacf38b9.19725906.jpg', 13, '2026-03-20 16:47:38');
INSERT INTO `product_images` VALUES (126, 21, 'uploads/img_69bd18c9437386.47184303.jpg', 1, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (127, 21, 'uploads/img_69bd18c943a401.32118597.jpg', 2, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (128, 21, 'uploads/img_69bd18c943d068.94615922.jpg', 3, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (129, 21, 'uploads/img_69bd18c943f437.32191869.jpg', 4, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (130, 21, 'uploads/img_69bd18c94419a8.27810870.jpg', 5, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (131, 21, 'uploads/img_69bd18c94437b9.70441423.jpg', 6, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (132, 21, 'uploads/img_69bd18c94472e9.95699765.jpg', 7, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (133, 21, 'uploads/img_69bd18c944be38.78109695.jpg', 8, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (134, 21, 'uploads/img_69bd18c944e990.01995645.jpg', 9, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (135, 21, 'uploads/img_69bd18c9450b08.65065750.jpg', 10, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (136, 21, 'uploads/img_69bd18c94528d4.94783794.jpg', 11, '2026-03-20 16:52:09');
INSERT INTO `product_images` VALUES (137, 22, 'uploads/img_69bd1b27f04574.45135916.jpg', 1, '2026-03-20 17:02:15');
INSERT INTO `product_images` VALUES (138, 22, 'uploads/img_69bd1b27f07133.50175719.jpg', 2, '2026-03-20 17:02:15');
INSERT INTO `product_images` VALUES (139, 22, 'uploads/img_69bd1b27f09471.09864051.jpg', 3, '2026-03-20 17:02:16');
INSERT INTO `product_images` VALUES (140, 22, 'uploads/img_69bd1b27f0cca5.82746756.jpg', 4, '2026-03-20 17:02:16');
INSERT INTO `product_images` VALUES (141, 22, 'uploads/img_69bd1b27f12a07.10872839.jpg', 5, '2026-03-20 17:02:16');
INSERT INTO `product_images` VALUES (142, 22, 'uploads/img_69bd1b27f15ef6.58333696.jpg', 6, '2026-03-20 17:02:16');
INSERT INTO `product_images` VALUES (143, 22, 'uploads/img_69bd1b27f1a812.93215259.jpg', 7, '2026-03-20 17:02:16');
INSERT INTO `product_images` VALUES (144, 22, 'uploads/img_69bd1b27f1c6b6.20844614.jpg', 8, '2026-03-20 17:02:16');
INSERT INTO `product_images` VALUES (145, 22, 'uploads/img_69bd1b27f1e2c9.83768620.jpg', 9, '2026-03-20 17:02:16');
INSERT INTO `product_images` VALUES (146, 23, 'uploads/img_69bd1c620f87e6.02642423.jpg', 1, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (147, 23, 'uploads/img_69bd1c620fdc64.73760754.jpg', 2, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (148, 23, 'uploads/img_69bd1c621035c9.53956843.jpg', 3, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (149, 23, 'uploads/img_69bd1c62107a76.74152036.jpg', 4, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (150, 23, 'uploads/img_69bd1c6210a2f8.55834281.jpg', 5, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (151, 23, 'uploads/img_69bd1c6210bf38.98874561.jpg', 6, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (152, 23, 'uploads/img_69bd1c6210dbc3.32776949.jpg', 7, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (153, 23, 'uploads/img_69bd1c6210f5a5.03643866.jpg', 8, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (154, 23, 'uploads/img_69bd1c62111277.00331884.jpg', 9, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (155, 23, 'uploads/img_69bd1c62112c19.57980844.jpg', 10, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (156, 23, 'uploads/img_69bd1c62114840.21950489.jpg', 11, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (157, 23, 'uploads/img_69bd1c621161b9.58820201.jpg', 12, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (158, 23, 'uploads/img_69bd1c62117a70.36541566.jpg', 13, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (159, 23, 'uploads/img_69bd1c62119b75.94971296.jpg', 14, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (160, 23, 'uploads/img_69bd1c6211bae4.48321842.jpg', 15, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (161, 23, 'uploads/img_69bd1c6211dd22.26499978.jpg', 16, '2026-03-20 17:07:30');
INSERT INTO `product_images` VALUES (162, 24, 'uploads/img_69bd1d14098e12.19106422.jpg', 1, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (163, 24, 'uploads/img_69bd1d1409af85.62705775.jpg', 2, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (164, 24, 'uploads/img_69bd1d1409c979.91621515.jpg', 3, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (165, 24, 'uploads/img_69bd1d1409e3b5.32663667.jpg', 4, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (166, 24, 'uploads/img_69bd1d1409fcd7.72665735.jpg', 5, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (167, 24, 'uploads/img_69bd1d140a1572.76696733.jpg', 6, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (168, 24, 'uploads/img_69bd1d140a2e18.62831148.jpg', 7, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (169, 24, 'uploads/img_69bd1d140a4575.56683237.jpg', 8, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (170, 24, 'uploads/img_69bd1d140a5c52.15511294.jpg', 9, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (171, 24, 'uploads/img_69bd1d140a7369.13267947.jpg', 10, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (172, 24, 'uploads/img_69bd1d140a8964.44881089.jpg', 11, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (173, 24, 'uploads/img_69bd1d140abb01.69317532.jpg', 12, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (174, 24, 'uploads/img_69bd1d140af082.90862592.jpg', 13, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (175, 24, 'uploads/img_69bd1d140b17d2.17889255.jpg', 14, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (176, 24, 'uploads/img_69bd1d140b4ab6.02480226.jpg', 15, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (177, 24, 'uploads/img_69bd1d140b71b9.31774085.jpg', 16, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (178, 24, 'uploads/img_69bd1d140bacb6.83056425.jpg', 17, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (179, 24, 'uploads/img_69bd1d140bcf14.46754475.jpg', 18, '2026-03-20 17:10:28');
INSERT INTO `product_images` VALUES (180, 25, 'uploads/img_69bd1dfbc94b08.13368581.jpg', 1, '2026-03-20 17:14:19');
INSERT INTO `product_images` VALUES (181, 25, 'uploads/img_69bd1dfbc916a4.48552007.jpg', 2, '2026-03-20 17:14:19');
INSERT INTO `product_images` VALUES (182, 25, 'uploads/img_69bd1dfbc998a1.26569116.jpg', 3, '2026-03-20 17:14:19');
INSERT INTO `product_images` VALUES (183, 25, 'uploads/img_69bd1dfbc9ed49.66298992.jpg', 4, '2026-03-20 17:14:19');
INSERT INTO `product_images` VALUES (184, 25, 'uploads/img_69bd1dfbca1366.67377297.jpg', 5, '2026-03-20 17:14:19');
INSERT INTO `product_images` VALUES (185, 25, 'uploads/img_69bd1dfbca2fa1.05267015.jpg', 6, '2026-03-20 17:14:19');
INSERT INTO `product_images` VALUES (186, 25, 'uploads/img_69bd1dfbca4c04.24455076.jpg', 7, '2026-03-20 17:14:19');
INSERT INTO `product_images` VALUES (187, 26, 'uploads/img_69bd1f1331eaf0.70785659.jpg', 1, '2026-03-20 17:18:59');
INSERT INTO `product_images` VALUES (188, 26, 'uploads/img_69bd1f133242c8.41107514.jpg', 2, '2026-03-20 17:18:59');
INSERT INTO `product_images` VALUES (189, 26, 'uploads/img_69bd1f13326eb2.81664041.jpg', 3, '2026-03-20 17:18:59');
INSERT INTO `product_images` VALUES (190, 26, 'uploads/img_69bd1f13328dd2.60526336.jpg', 4, '2026-03-20 17:18:59');
INSERT INTO `product_images` VALUES (191, 26, 'uploads/img_69bd1f1332a793.33765973.jpg', 5, '2026-03-20 17:18:59');
INSERT INTO `product_images` VALUES (192, 26, 'uploads/img_69bd1f1332be14.95300826.jpg', 6, '2026-03-20 17:18:59');
INSERT INTO `product_images` VALUES (193, 26, 'uploads/img_69bd1f1332d6f4.65883386.jpg', 7, '2026-03-20 17:18:59');
INSERT INTO `product_images` VALUES (194, 27, 'uploads/img_69bd1f98cc6c15.17496498.jpg', 1, '2026-03-20 17:21:12');
INSERT INTO `product_images` VALUES (195, 27, 'uploads/img_69bd1f98cc0452.46539487.jpg', 2, '2026-03-20 17:21:12');
INSERT INTO `product_images` VALUES (196, 27, 'uploads/img_69bd1f98cc2bc0.80581613.jpg', 3, '2026-03-20 17:21:12');
INSERT INTO `product_images` VALUES (197, 27, 'uploads/img_69bd1f98cc4810.81026879.jpg', 4, '2026-03-20 17:21:12');
INSERT INTO `product_images` VALUES (198, 27, 'uploads/img_69bd1f98cc84f0.58793413.jpg', 5, '2026-03-20 17:21:12');
INSERT INTO `product_images` VALUES (199, 27, 'uploads/img_69bd1f98cc9bd0.00389013.jpg', 6, '2026-03-20 17:21:12');
INSERT INTO `product_images` VALUES (200, 27, 'uploads/img_69bd1f98ccb281.36358435.jpg', 7, '2026-03-20 17:21:12');
INSERT INTO `product_images` VALUES (201, 27, 'uploads/img_69bd1f98ccc956.73643733.jpg', 8, '2026-03-20 17:21:12');
INSERT INTO `product_images` VALUES (209, 28, 'uploads/img_69bd202790d513.00141508.jpg', 1, '2026-03-20 17:24:00');
INSERT INTO `product_images` VALUES (210, 28, 'uploads/img_69bd20279111c2.17100182.jpg', 2, '2026-03-20 17:24:00');
INSERT INTO `product_images` VALUES (211, 28, 'uploads/img_69bd2027914880.70605348.jpg', 3, '2026-03-20 17:24:00');
INSERT INTO `product_images` VALUES (212, 28, 'uploads/img_69bd2027918262.79706764.jpg', 4, '2026-03-20 17:24:00');
INSERT INTO `product_images` VALUES (213, 28, 'uploads/img_69bd202791ae36.48743850.jpg', 5, '2026-03-20 17:24:00');
INSERT INTO `product_images` VALUES (214, 28, 'uploads/img_69bd202791d9d2.37917203.jpg', 6, '2026-03-20 17:24:00');
INSERT INTO `product_images` VALUES (215, 28, 'uploads/img_69bd2027920474.87566529.jpg', 7, '2026-03-20 17:24:00');
INSERT INTO `product_images` VALUES (216, 29, 'uploads/img_69bd231aaddc54.41680954.jpg', 1, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (217, 29, 'uploads/img_69bd231aad15d7.31531703.jpg', 2, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (218, 29, 'uploads/img_69bd231aad90c3.75244411.jpg', 3, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (219, 29, 'uploads/img_69bd231aae1267.64464111.jpg', 4, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (220, 29, 'uploads/img_69bd231aae33b4.61466490.jpg', 5, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (221, 29, 'uploads/img_69bd231aae5477.95513568.jpg', 6, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (222, 29, 'uploads/img_69bd231aae71d8.12672197.jpg', 7, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (223, 29, 'uploads/img_69bd231aae8d36.74707847.jpg', 8, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (224, 29, 'uploads/img_69bd231aaeac08.65900191.jpg', 9, '2026-03-20 17:36:10');
INSERT INTO `product_images` VALUES (232, 30, 'uploads/img_69bd24353fc750.77363180.jpg', 1, '2026-03-20 17:41:01');
INSERT INTO `product_images` VALUES (233, 30, 'uploads/img_69bd24353fa130.64292090.jpg', 2, '2026-03-20 17:41:01');
INSERT INTO `product_images` VALUES (234, 30, 'uploads/img_69bd24353fe3a9.07999473.jpg', 3, '2026-03-20 17:41:01');
INSERT INTO `product_images` VALUES (235, 30, 'uploads/img_69bd2435400131.81866423.jpg', 4, '2026-03-20 17:41:01');
INSERT INTO `product_images` VALUES (236, 30, 'uploads/img_69bd2435401a44.46005037.jpg', 5, '2026-03-20 17:41:01');
INSERT INTO `product_images` VALUES (237, 30, 'uploads/img_69bd24354030c3.68042541.jpg', 6, '2026-03-20 17:41:01');
INSERT INTO `product_images` VALUES (238, 30, 'uploads/img_69bd24354046f5.87724299.jpg', 7, '2026-03-20 17:41:01');
INSERT INTO `product_images` VALUES (246, 31, 'uploads/img_69bd24c51c7291.87179480.jpg', 1, '2026-03-20 17:43:38');
INSERT INTO `product_images` VALUES (247, 31, 'uploads/img_69bd24c51c0ba9.17310929.jpg', 2, '2026-03-20 17:43:38');
INSERT INTO `product_images` VALUES (248, 31, 'uploads/img_69bd24c51c3c09.31172708.jpg', 3, '2026-03-20 17:43:38');
INSERT INTO `product_images` VALUES (249, 31, 'uploads/img_69bd24c51c5973.94169799.jpg', 4, '2026-03-20 17:43:38');
INSERT INTO `product_images` VALUES (250, 31, 'uploads/img_69bd24c51caec7.93688684.jpg', 5, '2026-03-20 17:43:38');
INSERT INTO `product_images` VALUES (251, 31, 'uploads/img_69bd24c51d0c43.97111363.jpg', 6, '2026-03-20 17:43:38');
INSERT INTO `product_images` VALUES (252, 31, 'uploads/img_69bd24c51d45f4.07494449.jpg', 7, '2026-03-20 17:43:38');
INSERT INTO `product_images` VALUES (253, 32, 'uploads/img_69bd25c067a1d0.51295744.jpg', 1, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (254, 32, 'uploads/img_69bd25c0672d65.58440335.jpg', 2, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (255, 32, 'uploads/img_69bd25c067d683.92811496.jpg', 3, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (256, 32, 'uploads/img_69bd25c067f853.42206031.jpg', 4, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (257, 32, 'uploads/img_69bd25c0682365.94533744.jpg', 5, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (258, 32, 'uploads/img_69bd25c0685289.35371836.jpg', 6, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (259, 32, 'uploads/img_69bd25c0687c59.73801357.jpg', 7, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (260, 32, 'uploads/img_69bd25c068a3b1.94148922.jpg', 8, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (261, 32, 'uploads/img_69bd25c068c3d7.29415713.jpg', 9, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (262, 32, 'uploads/img_69bd25c068e2b4.96993837.jpg', 10, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (263, 32, 'uploads/img_69bd25c0690613.83957343.jpg', 11, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (264, 32, 'uploads/img_69bd25c0692722.70354369.jpg', 12, '2026-03-20 17:47:28');
INSERT INTO `product_images` VALUES (265, 33, 'uploads/img_69bd26d82e5b68.50136403.jpg', 1, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (266, 33, 'uploads/img_69bd26d82e83f2.25679653.jpg', 2, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (267, 33, 'uploads/img_69bd26d82ea6f5.45115357.jpg', 3, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (268, 33, 'uploads/img_69bd26d82ec509.55819721.jpg', 4, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (269, 33, 'uploads/img_69bd26d82ee238.16099819.jpg', 5, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (270, 33, 'uploads/img_69bd26d82effb4.42099630.jpg', 6, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (271, 33, 'uploads/img_69bd26d82f1a87.85246173.jpg', 7, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (272, 33, 'uploads/img_69bd26d82f3664.40910828.jpg', 8, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (273, 33, 'uploads/img_69bd26d82f5009.94389438.jpg', 9, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (274, 33, 'uploads/img_69bd26d82f6c49.72315855.jpg', 10, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (275, 33, 'uploads/img_69bd26d82f8668.67411194.jpg', 11, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (276, 33, 'uploads/img_69bd26d82fa229.06594545.jpg', 12, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (277, 33, 'uploads/img_69bd26d82fc0f9.24840614.jpg', 13, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (278, 33, 'uploads/img_69bd26d83006e2.20537691.jpg', 14, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (279, 33, 'uploads/img_69bd26d8305026.07162839.jpg', 15, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (280, 33, 'uploads/img_69bd26d8307bc4.82108158.jpg', 16, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (281, 33, 'uploads/img_69bd26d830a264.74716190.jpg', 17, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (282, 33, 'uploads/img_69bd26d830c462.52183365.jpg', 18, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (283, 33, 'uploads/img_69bd26d830e0d8.84790612.jpg', 19, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (284, 33, 'uploads/img_69bd26d830fd28.67352996.jpg', 20, '2026-03-20 17:52:08');
INSERT INTO `product_images` VALUES (295, 34, 'uploads/img_69bd2779309f03.56982459.jpg', 1, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (296, 34, 'uploads/img_69bd277930c286.73820473.jpg', 2, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (297, 34, 'uploads/img_69bd277930dd07.53103134.jpg', 3, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (298, 34, 'uploads/img_69bd277930fc86.28970117.jpg', 4, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (299, 34, 'uploads/img_69bd27793114b6.42684717.jpg', 5, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (300, 34, 'uploads/img_69bd2779312fc5.72372827.jpg', 6, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (301, 34, 'uploads/img_69bd27793146e8.88199638.jpg', 7, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (302, 34, 'uploads/img_69bd2779315d34.69138954.jpg', 8, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (303, 34, 'uploads/img_69bd27793175a4.14826823.jpg', 9, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (304, 34, 'uploads/img_69bd2779318c15.99766929.jpg', 10, '2026-03-20 17:55:54');
INSERT INTO `product_images` VALUES (305, 35, 'uploads/img_69bd2893992228.59930355.jpg', 1, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (306, 35, 'uploads/img_69bd28939946f7.18911932.jpg', 2, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (307, 35, 'uploads/img_69bd2893996429.65685756.jpg', 3, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (308, 35, 'uploads/img_69bd2893997cb1.94290864.jpg', 4, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (309, 35, 'uploads/img_69bd2893999494.10404418.jpg', 5, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (310, 35, 'uploads/img_69bd289399aca6.64314813.jpg', 6, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (311, 35, 'uploads/img_69bd289399c3a7.84406693.jpg', 7, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (312, 35, 'uploads/img_69bd289399db20.06488082.jpg', 8, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (313, 35, 'uploads/img_69bd289399f2a4.21500476.jpg', 9, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (314, 35, 'uploads/img_69bd28939a0a61.72582774.jpg', 10, '2026-03-20 17:59:31');
INSERT INTO `product_images` VALUES (330, 18, 'uploads/img_69bd16322da762.54716206.jpg', 1, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (331, 18, 'uploads/img_69bd16322d67d6.88865795.jpg', 2, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (332, 18, 'uploads/img_69bd16322d8bb5.49018267.jpg', 3, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (333, 18, 'uploads/img_69bd16322dc1c4.76958239.jpg', 4, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (334, 18, 'uploads/img_69bd16322dd9b7.30451778.jpg', 5, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (335, 18, 'uploads/img_69bd16322df0e3.74782148.jpg', 6, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (336, 18, 'uploads/img_69bd16322e0b19.21624866.jpg', 7, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (337, 18, 'uploads/img_69bd16322e21c6.92967871.jpg', 8, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (338, 18, 'uploads/img_69bd16322e3990.49596257.jpg', 9, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (339, 18, 'uploads/img_69bd16322e5295.44232808.jpg', 10, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (340, 18, 'uploads/img_69bd16322e6957.44005440.jpg', 11, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (341, 18, 'uploads/img_69bd16322e8060.54187247.jpg', 12, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (342, 18, 'uploads/img_69bd16322e9634.71349336.jpg', 13, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (343, 18, 'uploads/img_69bd16322eaeb0.13741538.jpg', 14, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (344, 18, 'uploads/img_69bd16322ec5f0.95248412.jpg', 15, '2026-03-20 19:47:44');
INSERT INTO `product_images` VALUES (384, 4, 'uploads/img_69bd42a94900a7.25065381.jpg', 1, '2026-03-20 19:50:49');
INSERT INTO `product_images` VALUES (385, 4, 'uploads/img_69bd42a948b148.17723713.jpg', 2, '2026-03-20 19:50:49');
INSERT INTO `product_images` VALUES (386, 4, 'uploads/img_69bd42a948daa8.90926883.jpg', 3, '2026-03-20 19:50:49');
INSERT INTO `product_images` VALUES (387, 4, 'uploads/img_69bd42a9492075.20970845.jpg', 4, '2026-03-20 19:50:49');
INSERT INTO `product_images` VALUES (388, 4, 'uploads/img_69bd42a9494164.48716117.jpg', 5, '2026-03-20 19:50:49');
INSERT INTO `product_images` VALUES (389, 4, 'uploads/img_69bd42a9496033.35336401.jpg', 6, '2026-03-20 19:50:49');
INSERT INTO `product_images` VALUES (390, 4, 'uploads/img_69bd42a94981f5.70428304.jpg', 7, '2026-03-20 19:50:49');
INSERT INTO `product_images` VALUES (391, 5, 'uploads/img_69bd42bb7c0306.92031856.jpg', 1, '2026-03-20 19:51:07');
INSERT INTO `product_images` VALUES (392, 5, 'uploads/img_69bd42bb7be195.19719409.jpg', 2, '2026-03-20 19:51:07');
INSERT INTO `product_images` VALUES (393, 5, 'uploads/img_69bd42bb7c1882.30965132.jpg', 3, '2026-03-20 19:51:07');
INSERT INTO `product_images` VALUES (394, 5, 'uploads/img_69bd42bb7c2c45.07906802.jpg', 4, '2026-03-20 19:51:07');
INSERT INTO `product_images` VALUES (395, 5, 'uploads/img_69bd42bb7c4184.62334061.jpg', 5, '2026-03-20 19:51:07');
INSERT INTO `product_images` VALUES (396, 5, 'uploads/img_69bd42bb7c54c2.60582137.jpg', 6, '2026-03-20 19:51:07');
INSERT INTO `product_images` VALUES (397, 5, 'uploads/img_69bd42bb7c66f0.75505400.jpg', 7, '2026-03-20 19:51:07');
INSERT INTO `product_images` VALUES (398, 3, 'uploads/img_69bd4291612e06.84097889.jpg', 1, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (399, 3, 'uploads/img_69bd4291610a62.53740977.jpg', 2, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (400, 3, 'uploads/img_69bd42916145f1.34920230.jpg', 3, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (401, 3, 'uploads/img_69bd4291615f79.64378143.jpg', 4, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (402, 3, 'uploads/img_69bd4291617900.54333525.jpg', 5, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (403, 3, 'uploads/img_69bd429161a043.87758558.jpg', 6, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (404, 3, 'uploads/img_69bd429161bdb4.80625573.jpg', 7, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (405, 3, 'uploads/img_69bd429161d745.87467427.jpg', 8, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (406, 3, 'uploads/img_69bd429161ef24.30412285.jpg', 9, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (407, 3, 'uploads/img_69bd42916210b1.19196744.jpg', 10, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (408, 3, 'uploads/img_69bd4291624cd5.02446304.jpg', 11, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (409, 3, 'uploads/img_69bd4291629321.48682460.jpg', 12, '2026-03-20 19:51:18');
INSERT INTO `product_images` VALUES (410, 2, 'uploads/img_69bd426cc331b4.30040811.jpg', 1, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (411, 2, 'uploads/img_69bd426cc35325.35790672.jpg', 2, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (412, 2, 'uploads/img_69bd426cc36a64.32179905.jpg', 3, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (413, 2, 'uploads/img_69bd426cc37fa3.99483398.jpg', 4, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (414, 2, 'uploads/img_69bd426cc39370.56237874.jpg', 5, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (415, 2, 'uploads/img_69bd426cc3a873.36064868.jpg', 6, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (416, 2, 'uploads/img_69bd426cc3bef4.27464835.jpg', 7, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (417, 2, 'uploads/img_69bd426cc3d915.20072839.jpg', 8, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (418, 2, 'uploads/img_69bd426cc40863.91166307.jpg', 9, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (419, 2, 'uploads/img_69bd426cc43299.56815843.jpg', 10, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (420, 2, 'uploads/img_69bd426cc45733.64045522.jpg', 11, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (421, 2, 'uploads/img_69bd426cc47de4.14742133.jpg', 12, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (422, 2, 'uploads/img_69bd426cc49977.54225280.jpg', 13, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (423, 2, 'uploads/img_69bd426cc4ad95.61844984.jpg', 14, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (424, 2, 'uploads/img_69bd426cc4c132.69839022.jpg', 15, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (425, 2, 'uploads/img_69bd426cc4d414.21152588.jpg', 16, '2026-03-20 19:51:27');
INSERT INTO `product_images` VALUES (426, 1, 'uploads/img_69bd4231ee9f96.82671328.jpg', 1, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (427, 1, 'uploads/img_69bd4231eec181.16066863.jpg', 2, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (428, 1, 'uploads/img_69bd4231eee843.72660552.jpg', 3, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (429, 1, 'uploads/img_69bd4231ef0043.15767634.jpg', 4, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (430, 1, 'uploads/img_69bd4231ef15e2.28330596.jpg', 5, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (431, 1, 'uploads/img_69bd4231ef2aa5.11474677.jpg', 6, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (432, 1, 'uploads/img_69bd4231ef40b2.23810771.jpg', 7, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (433, 1, 'uploads/img_69bd4231ef5675.81929798.jpg', 8, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (434, 1, 'uploads/img_69bd4231ef6ff7.56342619.jpg', 9, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (435, 1, 'uploads/img_69bd4231ef92e3.60778646.jpg', 10, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (436, 1, 'uploads/img_69bd4231efb504.80849870.jpg', 11, '2026-03-20 19:51:36');
INSERT INTO `product_images` VALUES (437, 6, 'uploads/img_69bd42f57d2ae9.92151229.jpg', 1, '2026-03-20 19:52:05');
INSERT INTO `product_images` VALUES (438, 6, 'uploads/img_69bd42f57d81c8.57207296.jpg', 2, '2026-03-20 19:52:05');
INSERT INTO `product_images` VALUES (439, 6, 'uploads/img_69bd42f57d9b97.12268086.jpg', 3, '2026-03-20 19:52:05');
INSERT INTO `product_images` VALUES (440, 6, 'uploads/img_69bd42f57daff0.75977880.jpg', 4, '2026-03-20 19:52:05');
INSERT INTO `product_images` VALUES (441, 6, 'uploads/img_69bd42f57dc5f8.49310565.jpg', 5, '2026-03-20 19:52:05');
INSERT INTO `product_images` VALUES (442, 6, 'uploads/img_69bd42f57dd997.21986572.jpg', 6, '2026-03-20 19:52:05');
INSERT INTO `product_images` VALUES (443, 6, 'uploads/img_69bd42f57dec71.65972457.jpg', 7, '2026-03-20 19:52:05');
INSERT INTO `product_images` VALUES (444, 7, 'uploads/img_69bd4315a31261.75578140.jpg', 1, '2026-03-20 19:52:37');
INSERT INTO `product_images` VALUES (445, 7, 'uploads/img_69bd4315a2f536.80353973.jpg', 2, '2026-03-20 19:52:37');
INSERT INTO `product_images` VALUES (446, 7, 'uploads/img_69bd4315a33120.84443813.jpg', 3, '2026-03-20 19:52:37');
INSERT INTO `product_images` VALUES (447, 7, 'uploads/img_69bd4315a34979.38127485.jpg', 4, '2026-03-20 19:52:37');
INSERT INTO `product_images` VALUES (448, 7, 'uploads/img_69bd4315a35ee3.28335785.jpg', 5, '2026-03-20 19:52:37');
INSERT INTO `product_images` VALUES (449, 7, 'uploads/img_69bd4315a372a5.53508226.jpg', 6, '2026-03-20 19:52:37');
INSERT INTO `product_images` VALUES (450, 7, 'uploads/img_69bd4315a385f4.85944646.jpg', 7, '2026-03-20 19:52:37');

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `product_types` VALUES (11, 1, 'Áo Phông', 'ao-phong', 4, 1, '2026-03-20 15:47:35', '2026-03-20 15:47:35');
INSERT INTO `product_types` VALUES (12, 6, 'BỘ HÈ', 'bo-he', 1, 1, '2026-03-20 16:49:52', '2026-03-20 16:49:52');
INSERT INTO `product_types` VALUES (13, 6, 'BỘ ĐÔNG', 'bo-dong', 2, 1, '2026-03-20 16:49:59', '2026-03-20 16:49:59');
INSERT INTO `product_types` VALUES (14, 1, 'ÁO POLO', 'ao-polo', 5, 1, '2026-03-20 17:38:19', '2026-03-20 17:38:19');

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
) ENGINE = InnoDB AUTO_INCREMENT = 326 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product_variants
-- ----------------------------
INSERT INTO `product_variants` VALUES (1, 1, 'AO001-DEN-S', 'Đen / S', 'S', 'Đen', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cfbd4.45632576.jpg', 1, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:12');
INSERT INTO `product_variants` VALUES (2, 1, 'AO001-DEN-M', 'Đen / M', 'M', 'Đen', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cfbd4.45632576.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:12');
INSERT INTO `product_variants` VALUES (3, 1, 'AO001-DEN-L', 'Đen / L', 'L', 'Đen', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cfbd4.45632576.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:12');
INSERT INTO `product_variants` VALUES (4, 1, 'AO001-DEN-XL', 'Đen / XL', 'XL', 'Đen', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cfbd4.45632576.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:12');
INSERT INTO `product_variants` VALUES (5, 1, 'AO001-TRANG-S', 'Trắng / S', 'S', 'Trắng', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cac20.87892482.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:16');
INSERT INTO `product_variants` VALUES (6, 1, 'AO001-TRANG-M', 'Trắng / M', 'M', 'Trắng', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cac20.87892482.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:16');
INSERT INTO `product_variants` VALUES (7, 1, 'AO001-TRANG-L', 'Trắng / L', 'L', 'Trắng', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cac20.87892482.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:16');
INSERT INTO `product_variants` VALUES (8, 1, 'AO001-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cac20.87892482.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:16');
INSERT INTO `product_variants` VALUES (9, 1, 'AO001-XANHREU-S', 'Xanh Rêu / S', 'S', 'Xanh Rêu', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cc790.83531667.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:20');
INSERT INTO `product_variants` VALUES (10, 1, 'AO001-XANHREU-M', 'Xanh Rêu / M', 'M', 'Xanh Rêu', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cc790.83531667.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:20');
INSERT INTO `product_variants` VALUES (11, 1, 'AO001-XANHREU-L', 'Xanh Rêu / L', 'L', 'Xanh Rêu', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cc790.83531667.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:20');
INSERT INTO `product_variants` VALUES (12, 1, 'AO001-XANHREU-XL', 'Xanh Rêu / XL', 'XL', 'Xanh Rêu', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61cc790.83531667.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-20 11:08:20');
INSERT INTO `product_variants` VALUES (13, 2, 'AO002-DEN-S', 'Đen / S', 'S', 'Đen', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f36d1d0.55545252.jpg', 1, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:27');
INSERT INTO `product_variants` VALUES (14, 2, 'AO002-DEN-M', 'Đen / M', 'M', 'Đen', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f36d1d0.55545252.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:27');
INSERT INTO `product_variants` VALUES (15, 2, 'AO002-DEN-L', 'Đen / L', 'L', 'Đen', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f36d1d0.55545252.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:27');
INSERT INTO `product_variants` VALUES (16, 2, 'AO002-DEN-XL', 'Đen / XL', 'XL', 'Đen', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f36d1d0.55545252.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:27');
INSERT INTO `product_variants` VALUES (17, 2, 'AO002-TRANG-S', 'Trắng / S', 'S', 'Trắng', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:40');
INSERT INTO `product_variants` VALUES (18, 2, 'AO002-TRANG-M', 'Trắng / M', 'M', 'Trắng', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:40');
INSERT INTO `product_variants` VALUES (19, 2, 'AO002-TRANG-L', 'Trắng / L', 'L', 'Trắng', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:40');
INSERT INTO `product_variants` VALUES (20, 2, 'AO002-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:40');
INSERT INTO `product_variants` VALUES (21, 2, 'AO002-XANHNAVY-S', 'Xanh Navy / S', 'S', 'Xanh Navy', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f374601.29233527.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:45');
INSERT INTO `product_variants` VALUES (22, 2, 'AO002-XANHNAVY-M', 'Xanh Navy / M', 'M', 'Xanh Navy', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f374601.29233527.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:45');
INSERT INTO `product_variants` VALUES (23, 2, 'AO002-XANHNAVY-L', 'Xanh Navy / L', 'L', 'Xanh Navy', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f374601.29233527.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:45');
INSERT INTO `product_variants` VALUES (24, 2, 'AO002-XANHNAVY-XL', 'Xanh Navy / XL', 'XL', 'Xanh Navy', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f374601.29233527.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:45');
INSERT INTO `product_variants` VALUES (25, 2, 'AO002-DOMAN-S', 'Đỏ Mận / S', 'S', 'Đỏ Mận', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f36e5c2.33901105.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:32');
INSERT INTO `product_variants` VALUES (26, 2, 'AO002-DOMAN-M', 'Đỏ Mận / M', 'M', 'Đỏ Mận', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f36e5c2.33901105.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:32');
INSERT INTO `product_variants` VALUES (27, 2, 'AO002-DOMAN-L', 'Đỏ Mận / L', 'L', 'Đỏ Mận', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f36e5c2.33901105.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:32');
INSERT INTO `product_variants` VALUES (28, 2, 'AO002-DOMAN-XL', 'Đỏ Mận / XL', 'XL', 'Đỏ Mận', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f36e5c2.33901105.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-20 11:07:32');
INSERT INTO `product_variants` VALUES (29, 3, 'AO003-DEN-S', 'Đen / S', 'S', 'Đen', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 1, 1, '2026-03-18 16:12:35', '2026-03-20 11:06:54');
INSERT INTO `product_variants` VALUES (30, 3, 'AO003-DEN-M', 'Đen / M', 'M', 'Đen', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-20 11:06:54');
INSERT INTO `product_variants` VALUES (31, 3, 'AO003-DEN-L', 'Đen / L', 'L', 'Đen', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-20 11:06:54');
INSERT INTO `product_variants` VALUES (32, 3, 'AO003-DEN-XL', 'Đen / XL', 'XL', 'Đen', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-20 11:06:54');
INSERT INTO `product_variants` VALUES (33, 3, 'AO003-TRANG-S', 'Trắng / S', 'S', 'Trắng', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3568e05.63481601.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-20 11:06:59');
INSERT INTO `product_variants` VALUES (34, 3, 'AO003-TRANG-M', 'Trắng / M', 'M', 'Trắng', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3568e05.63481601.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-20 11:06:59');
INSERT INTO `product_variants` VALUES (35, 3, 'AO003-TRANG-L', 'Trắng / L', 'L', 'Trắng', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3568e05.63481601.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-20 11:06:59');
INSERT INTO `product_variants` VALUES (36, 3, 'AO003-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3568e05.63481601.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-20 11:06:59');
INSERT INTO `product_variants` VALUES (37, 4, 'AO004-TRANG-S', 'Trắng / S', 'S', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 1, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12');
INSERT INTO `product_variants` VALUES (38, 4, 'AO004-TRANG-M', 'Trắng / M', 'M', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 0, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12');
INSERT INTO `product_variants` VALUES (39, 4, 'AO004-TRANG-L', 'Trắng / L', 'L', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 0, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12');
INSERT INTO `product_variants` VALUES (40, 4, 'AO004-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 0, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12');
INSERT INTO `product_variants` VALUES (41, 4, 'AO004-TRANG-XXL', 'Trắng / XXL', 'XXL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 0, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12');
INSERT INTO `product_variants` VALUES (42, 5, 'AO005-TRANG-S', 'Trắng / S', 'S', 'Trắng', 380000.00, 260000.00, 180000.00, 0, 'uploads/img_69bad1f28468b7.97462758.jpg', 1, 1, '2026-03-18 16:25:22', '2026-03-18 16:25:22');
INSERT INTO `product_variants` VALUES (43, 5, 'AO005-TRANG-M', 'Trắng / M', 'M', 'Trắng', 380000.00, 260000.00, 180000.00, 0, 'uploads/img_69bad1f28468b7.97462758.jpg', 0, 1, '2026-03-18 16:25:22', '2026-03-18 16:25:22');
INSERT INTO `product_variants` VALUES (44, 5, 'AO005-TRANG-L', 'Trắng / L', 'L', 'Trắng', 380000.00, 260000.00, 180000.00, 0, 'uploads/img_69bad1f28468b7.97462758.jpg', 0, 1, '2026-03-18 16:25:22', '2026-03-18 16:25:22');
INSERT INTO `product_variants` VALUES (45, 5, 'AO005-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 380000.00, 260000.00, 180000.00, 0, 'uploads/img_69bad1f28468b7.97462758.jpg', 0, 1, '2026-03-18 16:25:22', '2026-03-18 16:25:22');
INSERT INTO `product_variants` VALUES (46, 6, 'AO006-TRANG-S', 'Trắng / S', 'S', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 1, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10');
INSERT INTO `product_variants` VALUES (47, 6, 'AO006-TRANG-M', 'Trắng / M', 'M', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 0, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10');
INSERT INTO `product_variants` VALUES (48, 6, 'AO006-TRANG-L', 'Trắng / L', 'L', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 0, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10');
INSERT INTO `product_variants` VALUES (49, 6, 'AO006-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 0, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10');
INSERT INTO `product_variants` VALUES (50, 6, 'AO006-TRANG-XXL', 'Trắng / XXL', 'XXL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 0, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10');
INSERT INTO `product_variants` VALUES (51, 7, 'AO007-TRANG-S', 'Trắng / S', 'S', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad37a4ef684.46263257.jpg', 1, 1, '2026-03-18 16:31:54', '2026-03-19 01:18:07');
INSERT INTO `product_variants` VALUES (52, 7, 'AO007-TRANG-M', 'Trắng / M', 'M', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad37a4ef684.46263257.jpg', 0, 1, '2026-03-18 16:31:54', '2026-03-19 01:18:07');
INSERT INTO `product_variants` VALUES (53, 7, 'AO007-TRANG-L', 'Trắng / L', 'L', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad37a4ef684.46263257.jpg', 0, 1, '2026-03-18 16:31:54', '2026-03-19 01:18:07');
INSERT INTO `product_variants` VALUES (54, 7, 'AO007-TRANG-XXL', 'Trắng / XXL', 'XXL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad37a4ef684.46263257.jpg', 0, 1, '2026-03-18 16:31:54', '2026-03-19 01:18:07');
INSERT INTO `product_variants` VALUES (55, 8, 'AO008-DEN-S', 'Đen / S', 'S', 'Đen', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4de677.30769984.jpg', 1, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:34');
INSERT INTO `product_variants` VALUES (56, 8, 'AO008-DEN-L', 'Đen / L', 'L', 'Đen', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4de677.30769984.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:34');
INSERT INTO `product_variants` VALUES (57, 8, 'AO008-DEN-M', 'Đen / M', 'M', 'Đen', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4de677.30769984.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:34');
INSERT INTO `product_variants` VALUES (58, 8, 'AO008-DEN-XL', 'Đen / XL', 'XL', 'Đen', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4de677.30769984.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:34');
INSERT INTO `product_variants` VALUES (59, 8, 'AO008-TRANG-S', 'Trắng / S', 'S', 'Trắng', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4cb722.67750291.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:47');
INSERT INTO `product_variants` VALUES (60, 8, 'AO008-TRANG-L', 'Trắng / L', 'L', 'Trắng', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4cb722.67750291.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:47');
INSERT INTO `product_variants` VALUES (61, 8, 'AO008-TRANG-M', 'Trắng / M', 'M', 'Trắng', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4cb722.67750291.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:47');
INSERT INTO `product_variants` VALUES (62, 8, 'AO008-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4cb722.67750291.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:47');
INSERT INTO `product_variants` VALUES (63, 8, 'AO008-XANHNAVY-S', 'Xanh Navy / S', 'S', 'Xanh Navy', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4dc580.11309611.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:58');
INSERT INTO `product_variants` VALUES (64, 8, 'AO008-XANHNAVY-L', 'Xanh Navy / L', 'L', 'Xanh Navy', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4dc580.11309611.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:58');
INSERT INTO `product_variants` VALUES (65, 8, 'AO008-XANHNAVY-M', 'Xanh Navy / M', 'M', 'Xanh Navy', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4dc580.11309611.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:58');
INSERT INTO `product_variants` VALUES (66, 8, 'AO008-XANHNAVY-XL', 'Xanh Navy / XL', 'XL', 'Xanh Navy', 410000.00, 289000.00, 210000.00, 0, 'uploads/img_69bd0aac4dc580.11309611.jpg', 0, 1, '2026-03-20 15:51:56', '2026-03-20 15:52:58');
INSERT INTO `product_variants` VALUES (68, 9, 'QU001-DEN-S', 'Đen / S', 'S', 'Đen', 405000.00, 265000.00, 205000.00, 0, 'uploads/img_69bd0bf77d2b65.71813569.jpg', 1, 1, '2026-03-20 15:57:27', '2026-03-20 15:57:42');
INSERT INTO `product_variants` VALUES (69, 9, 'QU001-DEN-L', 'Đen / L', 'L', 'Đen', 405000.00, 265000.00, 205000.00, 0, 'uploads/img_69bd0bf77d2b65.71813569.jpg', 0, 1, '2026-03-20 15:57:27', '2026-03-20 15:57:42');
INSERT INTO `product_variants` VALUES (70, 9, 'QU001-DEN-M', 'Đen / M', 'M', 'Đen', 405000.00, 265000.00, 205000.00, 0, 'uploads/img_69bd0bf77d2b65.71813569.jpg', 0, 1, '2026-03-20 15:57:27', '2026-03-20 15:57:42');
INSERT INTO `product_variants` VALUES (71, 9, 'QU001-DEN-XL', 'Đen / XL', 'XL', 'Đen', 405000.00, 265000.00, 205000.00, 0, 'uploads/img_69bd0bf77d2b65.71813569.jpg', 0, 1, '2026-03-20 15:57:27', '2026-03-20 15:57:42');
INSERT INTO `product_variants` VALUES (72, 9, 'QU001-TRANG-S', 'Trắng / S', 'S', 'Trắng', 405000.00, 265000.00, 205000.00, 0, 'uploads/img_69bd0bf77da5d1.96173278.jpg', 0, 1, '2026-03-20 15:57:27', '2026-03-20 15:57:50');
INSERT INTO `product_variants` VALUES (73, 9, 'QU001-TRANG-L', 'Trắng / L', 'L', 'Trắng', 405000.00, 265000.00, 205000.00, 0, 'uploads/img_69bd0bf77da5d1.96173278.jpg', 0, 1, '2026-03-20 15:57:27', '2026-03-20 15:57:50');
INSERT INTO `product_variants` VALUES (74, 9, 'QU001-TRANG-M', 'Trắng / M', 'M', 'Trắng', 405000.00, 265000.00, 205000.00, 0, 'uploads/img_69bd0bf77da5d1.96173278.jpg', 0, 1, '2026-03-20 15:57:27', '2026-03-20 15:57:50');
INSERT INTO `product_variants` VALUES (75, 9, 'QU001-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 405000.00, 265000.00, 205000.00, 0, 'uploads/img_69bd0bf77da5d1.96173278.jpg', 0, 1, '2026-03-20 15:57:27', '2026-03-20 15:57:50');
INSERT INTO `product_variants` VALUES (77, 10, 'SP00010-MIXMAU-S', 'MIX MÀU / S', 'S', 'MIX MÀU', 395000.00, 255000.00, 195000.00, 0, 'uploads/img_69bd0db3cf92f1.48431985.jpg', 1, 1, '2026-03-20 16:04:51', '2026-03-20 16:05:07');
INSERT INTO `product_variants` VALUES (78, 10, 'SP00010-MIXMAU-L', 'MIX MÀU / L', 'L', 'MIX MÀU', 395000.00, 255000.00, 195000.00, 0, 'uploads/img_69bd0db3cf92f1.48431985.jpg', 0, 1, '2026-03-20 16:04:51', '2026-03-20 16:05:07');
INSERT INTO `product_variants` VALUES (79, 10, 'SP00010-MIXMAU-M', 'MIX MÀU / M', 'M', 'MIX MÀU', 395000.00, 255000.00, 195000.00, 0, 'uploads/img_69bd0db3cf92f1.48431985.jpg', 0, 1, '2026-03-20 16:04:51', '2026-03-20 16:05:07');
INSERT INTO `product_variants` VALUES (80, 10, 'SP00010-MIXMAU-XL', 'MIX MÀU / XL', 'XL', 'MIX MÀU', 395000.00, 255000.00, 195000.00, 0, 'uploads/img_69bd0db3cf92f1.48431985.jpg', 0, 1, '2026-03-20 16:04:51', '2026-03-20 16:05:07');
INSERT INTO `product_variants` VALUES (82, 11, 'QU002-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 369000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd0f747137e9.82674560.jpg', 1, 1, '2026-03-20 16:12:20', '2026-03-20 16:12:28');
INSERT INTO `product_variants` VALUES (83, 11, 'QU002-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 369000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd0f747137e9.82674560.jpg', 0, 1, '2026-03-20 16:12:20', '2026-03-20 16:12:28');
INSERT INTO `product_variants` VALUES (84, 11, 'QU002-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 369000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd0f747137e9.82674560.jpg', 0, 1, '2026-03-20 16:12:20', '2026-03-20 16:12:28');
INSERT INTO `product_variants` VALUES (85, 11, 'QU002-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 369000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd0f747137e9.82674560.jpg', 0, 1, '2026-03-20 16:12:20', '2026-03-20 16:12:28');
INSERT INTO `product_variants` VALUES (86, 12, 'QU003-DEN-S', 'Đen / S', 'S', 'Đen', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1041c06094.70578931.jpg', 1, 1, '2026-03-20 16:15:45', '2026-03-20 16:15:59');
INSERT INTO `product_variants` VALUES (87, 12, 'QU003-DEN-L', 'Đen / L', 'L', 'Đen', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1041c06094.70578931.jpg', 0, 1, '2026-03-20 16:15:45', '2026-03-20 16:15:59');
INSERT INTO `product_variants` VALUES (88, 12, 'QU003-DEN-M', 'Đen / M', 'M', 'Đen', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1041c06094.70578931.jpg', 0, 1, '2026-03-20 16:15:45', '2026-03-20 16:15:59');
INSERT INTO `product_variants` VALUES (89, 12, 'QU003-DEN-XL', 'Đen / XL', 'XL', 'Đen', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1041c06094.70578931.jpg', 0, 1, '2026-03-20 16:15:45', '2026-03-20 16:15:59');
INSERT INTO `product_variants` VALUES (90, 12, 'QU003-TRANG-S', 'Trắng / S', 'S', 'Trắng', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1041bffb80.79376462.jpg', 0, 1, '2026-03-20 16:15:45', '2026-03-20 16:16:08');
INSERT INTO `product_variants` VALUES (91, 12, 'QU003-TRANG-L', 'Trắng / L', 'L', 'Trắng', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1041bffb80.79376462.jpg', 0, 1, '2026-03-20 16:15:45', '2026-03-20 16:16:08');
INSERT INTO `product_variants` VALUES (92, 12, 'QU003-TRANG-M', 'Trắng / M', 'M', 'Trắng', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1041bffb80.79376462.jpg', 0, 1, '2026-03-20 16:15:45', '2026-03-20 16:16:08');
INSERT INTO `product_variants` VALUES (93, 12, 'QU003-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1041bffb80.79376462.jpg', 0, 1, '2026-03-20 16:15:45', '2026-03-20 16:16:08');
INSERT INTO `product_variants` VALUES (95, 13, 'QU004-DEN-S', 'Đen / S', 'S', 'Đen', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd10eba4d4e4.03639701.jpg', 1, 1, '2026-03-20 16:18:35', '2026-03-20 16:18:57');
INSERT INTO `product_variants` VALUES (96, 13, 'QU004-DEN-L', 'Đen / L', 'L', 'Đen', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd10eba4d4e4.03639701.jpg', 0, 1, '2026-03-20 16:18:35', '2026-03-20 16:18:57');
INSERT INTO `product_variants` VALUES (97, 13, 'QU004-DEN-M', 'Đen / M', 'M', 'Đen', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd10eba4d4e4.03639701.jpg', 0, 1, '2026-03-20 16:18:35', '2026-03-20 16:18:57');
INSERT INTO `product_variants` VALUES (98, 13, 'QU004-DEN-XL', 'Đen / XL', 'XL', 'Đen', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd10eba4d4e4.03639701.jpg', 0, 1, '2026-03-20 16:18:35', '2026-03-20 16:18:57');
INSERT INTO `product_variants` VALUES (99, 13, 'QU004-TRANG-S', 'Trắng / S', 'S', 'Trắng', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd10eba43375.72503824.jpg', 0, 1, '2026-03-20 16:18:35', '2026-03-20 16:19:02');
INSERT INTO `product_variants` VALUES (100, 13, 'QU004-TRANG-L', 'Trắng / L', 'L', 'Trắng', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd10eba43375.72503824.jpg', 0, 1, '2026-03-20 16:18:35', '2026-03-20 16:19:02');
INSERT INTO `product_variants` VALUES (101, 13, 'QU004-TRANG-M', 'Trắng / M', 'M', 'Trắng', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd10eba43375.72503824.jpg', 0, 1, '2026-03-20 16:18:35', '2026-03-20 16:19:02');
INSERT INTO `product_variants` VALUES (102, 13, 'QU004-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd10eba43375.72503824.jpg', 0, 1, '2026-03-20 16:18:35', '2026-03-20 16:19:02');
INSERT INTO `product_variants` VALUES (104, 14, 'QU005-DEN-S', 'Đen / S', 'S', 'Đen', 405000.00, 269000.00, 205000.00, 0, 'uploads/img_69bd11bc0fc0a5.71211549.jpg', 1, 1, '2026-03-20 16:22:04', '2026-03-20 16:22:23');
INSERT INTO `product_variants` VALUES (105, 14, 'QU005-DEN-L', 'Đen / L', 'L', 'Đen', 405000.00, 269000.00, 205000.00, 0, 'uploads/img_69bd11bc0fc0a5.71211549.jpg', 0, 1, '2026-03-20 16:22:04', '2026-03-20 16:22:23');
INSERT INTO `product_variants` VALUES (106, 14, 'QU005-DEN-M', 'Đen / M', 'M', 'Đen', 405000.00, 269000.00, 205000.00, 0, 'uploads/img_69bd11bc0fc0a5.71211549.jpg', 0, 1, '2026-03-20 16:22:04', '2026-03-20 16:22:23');
INSERT INTO `product_variants` VALUES (107, 14, 'QU005-DEN-XL', 'Đen / XL', 'XL', 'Đen', 405000.00, 269000.00, 205000.00, 0, 'uploads/img_69bd11bc0fc0a5.71211549.jpg', 0, 1, '2026-03-20 16:22:04', '2026-03-20 16:22:23');
INSERT INTO `product_variants` VALUES (108, 14, 'QU005-TRANG-S', 'Trắng / S', 'S', 'Trắng', 405000.00, 269000.00, 205000.00, 0, 'uploads/img_69bd11bc0f9047.69231849.jpg', 0, 1, '2026-03-20 16:22:04', '2026-03-20 16:22:28');
INSERT INTO `product_variants` VALUES (109, 14, 'QU005-TRANG-L', 'Trắng / L', 'L', 'Trắng', 405000.00, 269000.00, 205000.00, 0, 'uploads/img_69bd11bc0f9047.69231849.jpg', 0, 1, '2026-03-20 16:22:04', '2026-03-20 16:22:28');
INSERT INTO `product_variants` VALUES (110, 14, 'QU005-TRANG-M', 'Trắng / M', 'M', 'Trắng', 405000.00, 269000.00, 205000.00, 0, 'uploads/img_69bd11bc0f9047.69231849.jpg', 0, 1, '2026-03-20 16:22:04', '2026-03-20 16:22:28');
INSERT INTO `product_variants` VALUES (111, 14, 'QU005-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 405000.00, 269000.00, 205000.00, 0, 'uploads/img_69bd11bc0f9047.69231849.jpg', 0, 1, '2026-03-20 16:22:04', '2026-03-20 16:22:28');
INSERT INTO `product_variants` VALUES (112, 15, 'QU006-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1304af26f2.46006930.jpg', 1, 1, '2026-03-20 16:27:32', '2026-03-20 16:27:47');
INSERT INTO `product_variants` VALUES (113, 15, 'QU006-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1304af26f2.46006930.jpg', 0, 1, '2026-03-20 16:27:32', '2026-03-20 16:27:47');
INSERT INTO `product_variants` VALUES (114, 15, 'QU006-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1304af26f2.46006930.jpg', 0, 1, '2026-03-20 16:27:32', '2026-03-20 16:27:47');
INSERT INTO `product_variants` VALUES (115, 15, 'QU006-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 390000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd1304af26f2.46006930.jpg', 0, 1, '2026-03-20 16:27:32', '2026-03-20 16:27:47');
INSERT INTO `product_variants` VALUES (116, 16, 'QU007-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6415ff3.94545171.jpg', 1, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:00');
INSERT INTO `product_variants` VALUES (117, 16, 'QU007-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6415ff3.94545171.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:00');
INSERT INTO `product_variants` VALUES (118, 16, 'QU007-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6415ff3.94545171.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:00');
INSERT INTO `product_variants` VALUES (119, 16, 'QU007-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6415ff3.94545171.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:00');
INSERT INTO `product_variants` VALUES (120, 16, 'QU007-XAM-S', 'XÁM / S', 'S', 'XÁM', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6421404.38447730.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:16');
INSERT INTO `product_variants` VALUES (121, 16, 'QU007-XAM-L', 'XÁM / L', 'L', 'XÁM', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6421404.38447730.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:16');
INSERT INTO `product_variants` VALUES (122, 16, 'QU007-XAM-M', 'XÁM / M', 'M', 'XÁM', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6421404.38447730.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:16');
INSERT INTO `product_variants` VALUES (123, 16, 'QU007-XAM-XL', 'XÁM / XL', 'XL', 'XÁM', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6421404.38447730.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:16');
INSERT INTO `product_variants` VALUES (124, 16, 'QU007-XANHNAVY-S', 'XANH NAVY / S', 'S', 'XANH NAVY', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6417a58.34830965.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:23');
INSERT INTO `product_variants` VALUES (125, 16, 'QU007-XANHNAVY-L', 'XANH NAVY / L', 'L', 'XANH NAVY', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6417a58.34830965.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:23');
INSERT INTO `product_variants` VALUES (126, 16, 'QU007-XANHNAVY-M', 'XANH NAVY / M', 'M', 'XANH NAVY', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6417a58.34830965.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:23');
INSERT INTO `product_variants` VALUES (127, 16, 'QU007-XANHNAVY-XL', 'XANH NAVY / XL', 'XL', 'XANH NAVY', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c6417a58.34830965.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:23');
INSERT INTO `product_variants` VALUES (128, 16, 'QU007-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c641ada5.04778799.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:11');
INSERT INTO `product_variants` VALUES (129, 16, 'QU007-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c641ada5.04778799.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:11');
INSERT INTO `product_variants` VALUES (130, 16, 'QU007-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c641ada5.04778799.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:11');
INSERT INTO `product_variants` VALUES (131, 16, 'QU007-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd13c641ada5.04778799.jpg', 0, 1, '2026-03-20 16:30:46', '2026-03-20 16:31:11');
INSERT INTO `product_variants` VALUES (132, 17, 'AO009-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f31e8.17092037.jpg', 1, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:31');
INSERT INTO `product_variants` VALUES (133, 17, 'AO009-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f31e8.17092037.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:31');
INSERT INTO `product_variants` VALUES (134, 17, 'AO009-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f31e8.17092037.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:31');
INSERT INTO `product_variants` VALUES (135, 17, 'AO009-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f31e8.17092037.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:31');
INSERT INTO `product_variants` VALUES (136, 17, 'AO009-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f0b05.37997053.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:39');
INSERT INTO `product_variants` VALUES (137, 17, 'AO009-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f0b05.37997053.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:39');
INSERT INTO `product_variants` VALUES (138, 17, 'AO009-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f0b05.37997053.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:39');
INSERT INTO `product_variants` VALUES (139, 17, 'AO009-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f0b05.37997053.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:39');
INSERT INTO `product_variants` VALUES (140, 17, 'AO009-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f7ca0.45293426.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:35');
INSERT INTO `product_variants` VALUES (141, 17, 'AO009-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f7ca0.45293426.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:35');
INSERT INTO `product_variants` VALUES (142, 17, 'AO009-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f7ca0.45293426.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:35');
INSERT INTO `product_variants` VALUES (143, 17, 'AO009-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 355000.00, 229000.00, 155000.00, 0, 'uploads/img_69bd15549f7ca0.45293426.jpg', 0, 1, '2026-03-20 16:37:24', '2026-03-20 16:37:35');
INSERT INTO `product_variants` VALUES (144, 18, 'AO010-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322da762.54716206.jpg', 1, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:13');
INSERT INTO `product_variants` VALUES (145, 18, 'AO010-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322da762.54716206.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:13');
INSERT INTO `product_variants` VALUES (146, 18, 'AO010-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322da762.54716206.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:13');
INSERT INTO `product_variants` VALUES (147, 18, 'AO010-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322da762.54716206.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:13');
INSERT INTO `product_variants` VALUES (148, 18, 'AO010-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322ec5f0.95248412.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:26');
INSERT INTO `product_variants` VALUES (149, 18, 'AO010-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322ec5f0.95248412.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:26');
INSERT INTO `product_variants` VALUES (150, 18, 'AO010-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322ec5f0.95248412.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:26');
INSERT INTO `product_variants` VALUES (151, 18, 'AO010-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322ec5f0.95248412.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:26');
INSERT INTO `product_variants` VALUES (152, 18, 'AO010-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322dd9b7.30451778.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:20');
INSERT INTO `product_variants` VALUES (153, 18, 'AO010-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322dd9b7.30451778.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:20');
INSERT INTO `product_variants` VALUES (154, 18, 'AO010-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322dd9b7.30451778.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:20');
INSERT INTO `product_variants` VALUES (155, 18, 'AO010-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 420000.00, 289000.00, 220000.00, 0, 'uploads/img_69bd16322dd9b7.30451778.jpg', 0, 1, '2026-03-20 16:41:06', '2026-03-20 16:41:20');
INSERT INTO `product_variants` VALUES (156, 19, 'QU008-DEN-S', 'Đen / S', 'S', 'Đen', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd16f1d0dbd3.31103403.jpg', 1, 1, '2026-03-20 16:44:17', '2026-03-20 16:44:24');
INSERT INTO `product_variants` VALUES (157, 19, 'QU008-DEN-L', 'Đen / L', 'L', 'Đen', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd16f1d0dbd3.31103403.jpg', 0, 1, '2026-03-20 16:44:17', '2026-03-20 16:44:24');
INSERT INTO `product_variants` VALUES (158, 19, 'QU008-DEN-M', 'Đen / M', 'M', 'Đen', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd16f1d0dbd3.31103403.jpg', 0, 1, '2026-03-20 16:44:17', '2026-03-20 16:44:24');
INSERT INTO `product_variants` VALUES (159, 19, 'QU008-DEN-XL', 'Đen / XL', 'XL', 'Đen', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd16f1d0dbd3.31103403.jpg', 0, 1, '2026-03-20 16:44:17', '2026-03-20 16:44:24');
INSERT INTO `product_variants` VALUES (160, 19, 'QU008-TRANG-S', 'Trắng / S', 'S', 'Trắng', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd16f1d0a5e7.79479137.jpg', 0, 1, '2026-03-20 16:44:17', '2026-03-20 16:44:27');
INSERT INTO `product_variants` VALUES (161, 19, 'QU008-TRANG-L', 'Trắng / L', 'L', 'Trắng', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd16f1d0a5e7.79479137.jpg', 0, 1, '2026-03-20 16:44:17', '2026-03-20 16:44:27');
INSERT INTO `product_variants` VALUES (162, 19, 'QU008-TRANG-M', 'Trắng / M', 'M', 'Trắng', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd16f1d0a5e7.79479137.jpg', 0, 1, '2026-03-20 16:44:17', '2026-03-20 16:44:27');
INSERT INTO `product_variants` VALUES (163, 19, 'QU008-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 400000.00, 259000.00, 200000.00, 0, 'uploads/img_69bd16f1d0a5e7.79479137.jpg', 0, 1, '2026-03-20 16:44:17', '2026-03-20 16:44:27');
INSERT INTO `product_variants` VALUES (164, 20, 'QU009-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bacd6690.57996529.jpg', 1, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:44');
INSERT INTO `product_variants` VALUES (165, 20, 'QU009-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bacd6690.57996529.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:44');
INSERT INTO `product_variants` VALUES (166, 20, 'QU009-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bacd6690.57996529.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:44');
INSERT INTO `product_variants` VALUES (167, 20, 'QU009-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bacd6690.57996529.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:44');
INSERT INTO `product_variants` VALUES (168, 20, 'QU009-XANHREU-S', 'XANH RÊU / S', 'S', 'XANH RÊU', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bace3e57.63018881.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:56');
INSERT INTO `product_variants` VALUES (169, 20, 'QU009-XANHREU-L', 'XANH RÊU / L', 'L', 'XANH RÊU', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bace3e57.63018881.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:56');
INSERT INTO `product_variants` VALUES (170, 20, 'QU009-XANHREU-M', 'XANH RÊU / M', 'M', 'XANH RÊU', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bace3e57.63018881.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:56');
INSERT INTO `product_variants` VALUES (171, 20, 'QU009-XANHREU-XL', 'XANH RÊU / XL', 'XL', 'XANH RÊU', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bace3e57.63018881.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:56');
INSERT INTO `product_variants` VALUES (172, 20, 'QU009-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bace6214.82753621.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:51');
INSERT INTO `product_variants` VALUES (173, 20, 'QU009-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bace6214.82753621.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:51');
INSERT INTO `product_variants` VALUES (174, 20, 'QU009-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bace6214.82753621.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:51');
INSERT INTO `product_variants` VALUES (175, 20, 'QU009-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 430000.00, 289000.00, 230000.00, 0, 'uploads/img_69bd17bace6214.82753621.jpg', 0, 1, '2026-03-20 16:47:38', '2026-03-20 16:47:51');
INSERT INTO `product_variants` VALUES (176, 21, 'FB001-TRANGKEM-S', 'TRẮNG KEM / S', 'S', 'TRẮNG KEM', 580000.00, 409000.00, 330000.00, 0, 'uploads/img_69bd18c943d068.94615922.jpg', 1, 1, '2026-03-20 16:52:09', '2026-03-20 16:52:18');
INSERT INTO `product_variants` VALUES (177, 21, 'FB001-TRANGKEM-L', 'TRẮNG KEM / L', 'L', 'TRẮNG KEM', 580000.00, 409000.00, 330000.00, 0, 'uploads/img_69bd18c943d068.94615922.jpg', 0, 1, '2026-03-20 16:52:09', '2026-03-20 16:52:18');
INSERT INTO `product_variants` VALUES (178, 21, 'FB001-TRANGKEM-M', 'TRẮNG KEM / M', 'M', 'TRẮNG KEM', 580000.00, 409000.00, 330000.00, 0, 'uploads/img_69bd18c943d068.94615922.jpg', 0, 1, '2026-03-20 16:52:09', '2026-03-20 16:52:18');
INSERT INTO `product_variants` VALUES (179, 21, 'FB001-TRANGKEM-XL', 'TRẮNG KEM / XL', 'XL', 'TRẮNG KEM', 580000.00, 409000.00, 330000.00, 0, 'uploads/img_69bd18c943d068.94615922.jpg', 0, 1, '2026-03-20 16:52:09', '2026-03-20 16:52:18');
INSERT INTO `product_variants` VALUES (180, 22, 'FB002-XANHTHAN-S', 'XANH THAN / S', 'S', 'XANH THAN', 590000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd1b27f07133.50175719.jpg', 1, 1, '2026-03-20 17:02:16', '2026-03-20 17:02:25');
INSERT INTO `product_variants` VALUES (181, 22, 'FB002-XANHTHAN-L', 'XANH THAN / L', 'L', 'XANH THAN', 590000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd1b27f07133.50175719.jpg', 0, 1, '2026-03-20 17:02:16', '2026-03-20 17:02:25');
INSERT INTO `product_variants` VALUES (182, 22, 'FB002-XANHTHAN-M', 'XANH THAN / M', 'M', 'XANH THAN', 590000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd1b27f07133.50175719.jpg', 0, 1, '2026-03-20 17:02:16', '2026-03-20 17:02:25');
INSERT INTO `product_variants` VALUES (183, 22, 'FB002-XANHTHAN-XL', 'XANH THAN / XL', 'XL', 'XANH THAN', 590000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd1b27f07133.50175719.jpg', 0, 1, '2026-03-20 17:02:16', '2026-03-20 17:02:25');
INSERT INTO `product_variants` VALUES (184, 23, 'FB003-XANHREU-S', 'XANH RÊU / S', 'S', 'XANH RÊU', 599000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1c620f87e6.02642423.jpg', 1, 1, '2026-03-20 17:07:30', '2026-03-20 17:07:49');
INSERT INTO `product_variants` VALUES (185, 23, 'FB003-XANHREU-L', 'XANH RÊU / L', 'L', 'XANH RÊU', 599000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1c620f87e6.02642423.jpg', 0, 1, '2026-03-20 17:07:30', '2026-03-20 17:07:49');
INSERT INTO `product_variants` VALUES (186, 23, 'FB003-XANHREU-M', 'XANH RÊU / M', 'M', 'XANH RÊU', 599000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1c620f87e6.02642423.jpg', 0, 1, '2026-03-20 17:07:30', '2026-03-20 17:07:49');
INSERT INTO `product_variants` VALUES (187, 23, 'FB003-XANHREU-XL', 'XANH RÊU / XL', 'XL', 'XANH RÊU', 599000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1c620f87e6.02642423.jpg', 0, 1, '2026-03-20 17:07:30', '2026-03-20 17:07:49');
INSERT INTO `product_variants` VALUES (188, 23, 'FB003-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 599000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1c62111277.00331884.jpg', 0, 1, '2026-03-20 17:07:30', '2026-03-20 17:07:55');
INSERT INTO `product_variants` VALUES (189, 23, 'FB003-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 599000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1c62111277.00331884.jpg', 0, 1, '2026-03-20 17:07:30', '2026-03-20 17:07:55');
INSERT INTO `product_variants` VALUES (190, 23, 'FB003-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 599000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1c62111277.00331884.jpg', 0, 1, '2026-03-20 17:07:30', '2026-03-20 17:07:55');
INSERT INTO `product_variants` VALUES (191, 23, 'FB003-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 599000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1c62111277.00331884.jpg', 0, 1, '2026-03-20 17:07:30', '2026-03-20 17:07:55');
INSERT INTO `product_variants` VALUES (192, 24, 'FB004-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 690000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1d14098e12.19106422.jpg', 1, 1, '2026-03-20 17:10:28', '2026-03-20 17:10:35');
INSERT INTO `product_variants` VALUES (193, 24, 'FB004-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 690000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1d14098e12.19106422.jpg', 0, 1, '2026-03-20 17:10:28', '2026-03-20 17:10:35');
INSERT INTO `product_variants` VALUES (194, 24, 'FB004-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 690000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1d14098e12.19106422.jpg', 0, 1, '2026-03-20 17:10:28', '2026-03-20 17:10:35');
INSERT INTO `product_variants` VALUES (195, 24, 'FB004-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 690000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1d14098e12.19106422.jpg', 0, 1, '2026-03-20 17:10:28', '2026-03-20 17:10:35');
INSERT INTO `product_variants` VALUES (196, 24, 'FB004-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 690000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1d1409c979.91621515.jpg', 0, 1, '2026-03-20 17:10:28', '2026-03-20 17:10:39');
INSERT INTO `product_variants` VALUES (197, 24, 'FB004-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 690000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1d1409c979.91621515.jpg', 0, 1, '2026-03-20 17:10:28', '2026-03-20 17:10:39');
INSERT INTO `product_variants` VALUES (198, 24, 'FB004-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 690000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1d1409c979.91621515.jpg', 0, 1, '2026-03-20 17:10:28', '2026-03-20 17:10:39');
INSERT INTO `product_variants` VALUES (199, 24, 'FB004-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 690000.00, 399000.00, 325000.00, 0, 'uploads/img_69bd1d1409c979.91621515.jpg', 0, 1, '2026-03-20 17:10:28', '2026-03-20 17:10:39');
INSERT INTO `product_variants` VALUES (200, 25, 'AO011-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 389000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1dfbc998a1.26569116.jpg', 1, 1, '2026-03-20 17:14:19', '2026-03-20 17:14:33');
INSERT INTO `product_variants` VALUES (201, 25, 'AO011-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 389000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1dfbc998a1.26569116.jpg', 0, 1, '2026-03-20 17:14:19', '2026-03-20 17:14:33');
INSERT INTO `product_variants` VALUES (202, 25, 'AO011-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 389000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1dfbc998a1.26569116.jpg', 0, 1, '2026-03-20 17:14:19', '2026-03-20 17:14:33');
INSERT INTO `product_variants` VALUES (203, 25, 'AO011-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 389000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1dfbc998a1.26569116.jpg', 0, 1, '2026-03-20 17:14:19', '2026-03-20 17:14:33');
INSERT INTO `product_variants` VALUES (204, 25, 'AO011-TRANG-XXL', 'TRẮNG / XXL', 'XXL', 'TRẮNG', 389000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1dfbc998a1.26569116.jpg', 0, 1, '2026-03-20 17:14:19', '2026-03-20 17:14:33');
INSERT INTO `product_variants` VALUES (205, 26, 'AO012-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 379000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1f1332a793.33765973.jpg', 1, 1, '2026-03-20 17:18:59', '2026-03-20 17:19:08');
INSERT INTO `product_variants` VALUES (206, 26, 'AO012-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 379000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1f1332a793.33765973.jpg', 0, 1, '2026-03-20 17:18:59', '2026-03-20 17:19:08');
INSERT INTO `product_variants` VALUES (207, 26, 'AO012-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 379000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1f1332a793.33765973.jpg', 0, 1, '2026-03-20 17:18:59', '2026-03-20 17:19:08');
INSERT INTO `product_variants` VALUES (208, 26, 'AO012-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 379000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1f1332a793.33765973.jpg', 0, 1, '2026-03-20 17:18:59', '2026-03-20 17:19:08');
INSERT INTO `product_variants` VALUES (209, 26, 'AO012-TRANG-XXL', 'TRẮNG / XXL', 'XXL', 'TRẮNG', 379000.00, 259000.00, 175000.00, 0, 'uploads/img_69bd1f1332a793.33765973.jpg', 0, 1, '2026-03-20 17:18:59', '2026-03-20 17:19:08');
INSERT INTO `product_variants` VALUES (210, 27, 'AO013-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 420000.00, 249000.00, 170000.00, 0, 'uploads/img_69bd1f98cc84f0.58793413.jpg', 1, 1, '2026-03-20 17:21:12', '2026-03-20 17:21:21');
INSERT INTO `product_variants` VALUES (211, 27, 'AO013-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 420000.00, 249000.00, 170000.00, 0, 'uploads/img_69bd1f98cc84f0.58793413.jpg', 0, 1, '2026-03-20 17:21:12', '2026-03-20 17:21:21');
INSERT INTO `product_variants` VALUES (212, 27, 'AO013-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 420000.00, 249000.00, 170000.00, 0, 'uploads/img_69bd1f98cc84f0.58793413.jpg', 0, 1, '2026-03-20 17:21:12', '2026-03-20 17:21:21');
INSERT INTO `product_variants` VALUES (213, 27, 'AO013-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 420000.00, 249000.00, 170000.00, 0, 'uploads/img_69bd1f98cc84f0.58793413.jpg', 0, 1, '2026-03-20 17:21:12', '2026-03-20 17:21:21');
INSERT INTO `product_variants` VALUES (214, 27, 'AO013-TRANG-XXL', 'TRẮNG / XXL', 'XXL', 'TRẮNG', 420000.00, 249000.00, 170000.00, 0, 'uploads/img_69bd1f98cc84f0.58793413.jpg', 0, 1, '2026-03-20 17:21:12', '2026-03-20 17:21:21');
INSERT INTO `product_variants` VALUES (220, 28, 'AO014-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 530000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2027914880.70605348.jpg', 0, 1, '2026-03-20 17:23:35', '2026-03-20 17:24:28');
INSERT INTO `product_variants` VALUES (221, 28, 'AO014-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 530000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2027914880.70605348.jpg', 0, 1, '2026-03-20 17:23:35', '2026-03-20 17:24:28');
INSERT INTO `product_variants` VALUES (222, 28, 'AO014-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 530000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2027914880.70605348.jpg', 0, 1, '2026-03-20 17:23:35', '2026-03-20 17:24:28');
INSERT INTO `product_variants` VALUES (223, 28, 'AO014-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 530000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2027914880.70605348.jpg', 0, 1, '2026-03-20 17:23:35', '2026-03-20 17:24:28');
INSERT INTO `product_variants` VALUES (224, 28, 'AO014-TRANG-XXL', 'TRẮNG / XXL', 'XXL', 'TRẮNG', 530000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2027914880.70605348.jpg', 0, 1, '2026-03-20 17:23:35', '2026-03-20 17:24:28');
INSERT INTO `product_variants` VALUES (226, 29, 'AO015-MAU1-M', 'MÀU 1 / M', 'M', 'MÀU 1', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aaddc54.41680954.jpg', 1, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:19');
INSERT INTO `product_variants` VALUES (227, 29, 'AO015-MAU1-L', 'MÀU 1 / L', 'L', 'MÀU 1', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aaddc54.41680954.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:19');
INSERT INTO `product_variants` VALUES (228, 29, 'AO015-MAU1-XL', 'MÀU 1 / XL', 'XL', 'MÀU 1', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aaddc54.41680954.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:19');
INSERT INTO `product_variants` VALUES (229, 29, 'AO015-MAU1-XXL', 'MÀU 1 / XXL', 'XXL', 'MÀU 1', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aaddc54.41680954.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:19');
INSERT INTO `product_variants` VALUES (230, 29, 'AO015-MAU2-M', 'MÀU 2 / M', 'M', 'MÀU 2', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aad15d7.31531703.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:25');
INSERT INTO `product_variants` VALUES (231, 29, 'AO015-MAU2-L', 'MÀU 2 / L', 'L', 'MÀU 2', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aad15d7.31531703.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:25');
INSERT INTO `product_variants` VALUES (232, 29, 'AO015-MAU2-XL', 'MÀU 2 / XL', 'XL', 'MÀU 2', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aad15d7.31531703.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:25');
INSERT INTO `product_variants` VALUES (233, 29, 'AO015-MAU2-XXL', 'MÀU 2 / XXL', 'XXL', 'MÀU 2', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aad15d7.31531703.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:25');
INSERT INTO `product_variants` VALUES (234, 29, 'AO015-MAU3-M', 'MÀU 3 / M', 'M', 'MÀU 3', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aad90c3.75244411.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:30');
INSERT INTO `product_variants` VALUES (235, 29, 'AO015-MAU3-L', 'MÀU 3 / L', 'L', 'MÀU 3', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aad90c3.75244411.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:30');
INSERT INTO `product_variants` VALUES (236, 29, 'AO015-MAU3-XL', 'MÀU 3 / XL', 'XL', 'MÀU 3', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aad90c3.75244411.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:30');
INSERT INTO `product_variants` VALUES (237, 29, 'AO015-MAU3-XXL', 'MÀU 3 / XXL', 'XXL', 'MÀU 3', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aad90c3.75244411.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:30');
INSERT INTO `product_variants` VALUES (238, 29, 'AO015-MAU4-M', 'MÀU 4 / M', 'M', 'MÀU 4', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae1267.64464111.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:35');
INSERT INTO `product_variants` VALUES (239, 29, 'AO015-MAU4-L', 'MÀU 4 / L', 'L', 'MÀU 4', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae1267.64464111.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:35');
INSERT INTO `product_variants` VALUES (240, 29, 'AO015-MAU4-XL', 'MÀU 4 / XL', 'XL', 'MÀU 4', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae1267.64464111.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:35');
INSERT INTO `product_variants` VALUES (241, 29, 'AO015-MAU4-XXL', 'MÀU 4 / XXL', 'XXL', 'MÀU 4', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae1267.64464111.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:35');
INSERT INTO `product_variants` VALUES (242, 29, 'AO015-MAU5-M', 'MÀU 5 / M', 'M', 'MÀU 5', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae33b4.61466490.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:45');
INSERT INTO `product_variants` VALUES (243, 29, 'AO015-MAU5-L', 'MÀU 5 / L', 'L', 'MÀU 5', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae33b4.61466490.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:45');
INSERT INTO `product_variants` VALUES (244, 29, 'AO015-MAU5-XL', 'MÀU 5 / XL', 'XL', 'MÀU 5', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae33b4.61466490.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:45');
INSERT INTO `product_variants` VALUES (245, 29, 'AO015-MAU5-XXL', 'MÀU 5 / XXL', 'XXL', 'MÀU 5', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae33b4.61466490.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:45');
INSERT INTO `product_variants` VALUES (246, 29, 'AO015-MAU6-M', 'MÀU 6 / M', 'M', 'MÀU 6', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae5477.95513568.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:51');
INSERT INTO `product_variants` VALUES (247, 29, 'AO015-MAU6-L', 'MÀU 6 / L', 'L', 'MÀU 6', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae5477.95513568.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:51');
INSERT INTO `product_variants` VALUES (248, 29, 'AO015-MAU6-XL', 'MÀU 6 / XL', 'XL', 'MÀU 6', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae5477.95513568.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:51');
INSERT INTO `product_variants` VALUES (249, 29, 'AO015-MAU6-XXL', 'MÀU 6 / XXL', 'XXL', 'MÀU 6', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae5477.95513568.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:51');
INSERT INTO `product_variants` VALUES (250, 29, 'AO015-MAU7-M', 'MÀU 7 / M', 'M', 'MÀU 7', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae71d8.12672197.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:58');
INSERT INTO `product_variants` VALUES (251, 29, 'AO015-MAU7-L', 'MÀU 7 / L', 'L', 'MÀU 7', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae71d8.12672197.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:58');
INSERT INTO `product_variants` VALUES (252, 29, 'AO015-MAU7-XL', 'MÀU 7 / XL', 'XL', 'MÀU 7', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae71d8.12672197.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:58');
INSERT INTO `product_variants` VALUES (253, 29, 'AO015-MAU7-XXL', 'MÀU 7 / XXL', 'XXL', 'MÀU 7', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae71d8.12672197.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:36:58');
INSERT INTO `product_variants` VALUES (254, 29, 'AO015-MAU8-M', 'MÀU 8 / M', 'M', 'MÀU 8', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae8d36.74707847.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:37:05');
INSERT INTO `product_variants` VALUES (255, 29, 'AO015-MAU8-L', 'MÀU 8 / L', 'L', 'MÀU 8', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae8d36.74707847.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:37:05');
INSERT INTO `product_variants` VALUES (256, 29, 'AO015-MAU8-XL', 'MÀU 8 / XL', 'XL', 'MÀU 8', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae8d36.74707847.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:37:05');
INSERT INTO `product_variants` VALUES (257, 29, 'AO015-MAU8-XXL', 'MÀU 8 / XXL', 'XXL', 'MÀU 8', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aae8d36.74707847.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:37:05');
INSERT INTO `product_variants` VALUES (258, 29, 'AO015-MAU9-M', 'MÀU 9 / M', 'M', 'MÀU 9', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aaeac08.65900191.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:37:13');
INSERT INTO `product_variants` VALUES (259, 29, 'AO015-MAU9-L', 'MÀU 9 / L', 'L', 'MÀU 9', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aaeac08.65900191.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:37:13');
INSERT INTO `product_variants` VALUES (260, 29, 'AO015-MAU9-XL', 'MÀU 9 / XL', 'XL', 'MÀU 9', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aaeac08.65900191.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:37:13');
INSERT INTO `product_variants` VALUES (261, 29, 'AO015-MAU9-XXL', 'MÀU 9 / XXL', 'XXL', 'MÀU 9', 460000.00, 269000.00, 180000.00, 0, 'uploads/img_69bd231aaeac08.65900191.jpg', 0, 1, '2026-03-20 17:36:10', '2026-03-20 17:37:13');
INSERT INTO `product_variants` VALUES (262, 30, 'AO016-DEN-S', 'Đen / S', 'S', 'Đen', 499000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24353fe3a9.07999473.jpg', 1, 1, '2026-03-20 17:40:53', '2026-03-20 17:41:10');
INSERT INTO `product_variants` VALUES (263, 30, 'AO016-DEN-M', 'Đen / M', 'M', 'Đen', 499000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24353fe3a9.07999473.jpg', 0, 1, '2026-03-20 17:40:53', '2026-03-20 17:41:10');
INSERT INTO `product_variants` VALUES (264, 30, 'AO016-DEN-L', 'Đen / L', 'L', 'Đen', 499000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24353fe3a9.07999473.jpg', 0, 1, '2026-03-20 17:40:53', '2026-03-20 17:41:10');
INSERT INTO `product_variants` VALUES (265, 30, 'AO016-DEN-XL', 'Đen / XL', 'XL', 'Đen', 499000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24353fe3a9.07999473.jpg', 0, 1, '2026-03-20 17:40:53', '2026-03-20 17:41:10');
INSERT INTO `product_variants` VALUES (266, 30, 'AO016-TRANG-S', 'Trắng / S', 'S', 'Trắng', 499000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd2435400131.81866423.jpg', 0, 1, '2026-03-20 17:40:53', '2026-03-20 17:41:15');
INSERT INTO `product_variants` VALUES (267, 30, 'AO016-TRANG-M', 'Trắng / M', 'M', 'Trắng', 499000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd2435400131.81866423.jpg', 0, 1, '2026-03-20 17:40:53', '2026-03-20 17:41:15');
INSERT INTO `product_variants` VALUES (268, 30, 'AO016-TRANG-L', 'Trắng / L', 'L', 'Trắng', 499000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd2435400131.81866423.jpg', 0, 1, '2026-03-20 17:40:53', '2026-03-20 17:41:15');
INSERT INTO `product_variants` VALUES (269, 30, 'AO016-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 499000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd2435400131.81866423.jpg', 0, 1, '2026-03-20 17:40:53', '2026-03-20 17:41:15');
INSERT INTO `product_variants` VALUES (270, 31, 'AO017-DEN', 'Đen', NULL, 'Đen', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51c3c09.31172708.jpg', 1, 1, '2026-03-20 17:43:17', '2026-03-20 17:44:27');
INSERT INTO `product_variants` VALUES (271, 31, 'AO017-TRANG', 'Trắng', NULL, 'Trắng', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51d45f4.07494449.jpg', 0, 1, '2026-03-20 17:43:17', '2026-03-20 17:44:32');
INSERT INTO `product_variants` VALUES (272, 31, 'AO017-DEN-S', 'Đen / S', 'S', 'Đen', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51c3c09.31172708.jpg', 0, 1, '2026-03-20 17:43:38', '2026-03-20 17:44:27');
INSERT INTO `product_variants` VALUES (273, 31, 'AO017-DEN-M', 'Đen / M', 'M', 'Đen', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51c3c09.31172708.jpg', 0, 1, '2026-03-20 17:43:38', '2026-03-20 17:44:27');
INSERT INTO `product_variants` VALUES (274, 31, 'AO017-DEN-L', 'Đen / L', 'L', 'Đen', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51c3c09.31172708.jpg', 0, 1, '2026-03-20 17:43:38', '2026-03-20 17:44:27');
INSERT INTO `product_variants` VALUES (275, 31, 'AO017-DEN-XL', 'Đen / XL', 'XL', 'Đen', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51c3c09.31172708.jpg', 0, 1, '2026-03-20 17:43:38', '2026-03-20 17:44:27');
INSERT INTO `product_variants` VALUES (276, 31, 'AO017-TRANG-S', 'Trắng / S', 'S', 'Trắng', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51d45f4.07494449.jpg', 0, 1, '2026-03-20 17:43:38', '2026-03-20 17:44:32');
INSERT INTO `product_variants` VALUES (277, 31, 'AO017-TRANG-M', 'Trắng / M', 'M', 'Trắng', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51d45f4.07494449.jpg', 0, 1, '2026-03-20 17:43:38', '2026-03-20 17:44:32');
INSERT INTO `product_variants` VALUES (278, 31, 'AO017-TRANG-L', 'Trắng / L', 'L', 'Trắng', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51d45f4.07494449.jpg', 0, 1, '2026-03-20 17:43:38', '2026-03-20 17:44:32');
INSERT INTO `product_variants` VALUES (279, 31, 'AO017-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 489000.00, 269000.00, 195000.00, 0, 'uploads/img_69bd24c51d45f4.07494449.jpg', 0, 1, '2026-03-20 17:43:38', '2026-03-20 17:44:32');
INSERT INTO `product_variants` VALUES (280, 31, 'AO017-DFT', 'Mặc định', NULL, NULL, 489000.00, 269000.00, 195000.00, 0, NULL, 0, 1, '2026-03-20 17:44:34', '2026-03-20 17:44:34');
INSERT INTO `product_variants` VALUES (281, 32, 'AO018-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c0685289.35371836.jpg', 1, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:35');
INSERT INTO `product_variants` VALUES (282, 32, 'AO018-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c0685289.35371836.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:35');
INSERT INTO `product_variants` VALUES (283, 32, 'AO018-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c0685289.35371836.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:35');
INSERT INTO `product_variants` VALUES (284, 32, 'AO018-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c0685289.35371836.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:35');
INSERT INTO `product_variants` VALUES (285, 32, 'AO018-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c068e2b4.96993837.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:44');
INSERT INTO `product_variants` VALUES (286, 32, 'AO018-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c068e2b4.96993837.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:44');
INSERT INTO `product_variants` VALUES (287, 32, 'AO018-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c068e2b4.96993837.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:44');
INSERT INTO `product_variants` VALUES (288, 32, 'AO018-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c068e2b4.96993837.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:44');
INSERT INTO `product_variants` VALUES (289, 32, 'AO018-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c0687c59.73801357.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:41');
INSERT INTO `product_variants` VALUES (290, 32, 'AO018-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c0687c59.73801357.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:41');
INSERT INTO `product_variants` VALUES (291, 32, 'AO018-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c0687c59.73801357.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:41');
INSERT INTO `product_variants` VALUES (292, 32, 'AO018-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 460000.00, 259000.00, 190000.00, 0, 'uploads/img_69bd25c0687c59.73801357.jpg', 0, 1, '2026-03-20 17:47:28', '2026-03-20 17:47:41');
INSERT INTO `product_variants` VALUES (293, 33, 'FB005-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d82ea6f5.45115357.jpg', 1, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:15');
INSERT INTO `product_variants` VALUES (294, 33, 'FB005-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d82ea6f5.45115357.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:15');
INSERT INTO `product_variants` VALUES (295, 33, 'FB005-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d82ea6f5.45115357.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:15');
INSERT INTO `product_variants` VALUES (296, 33, 'FB005-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d82ea6f5.45115357.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:15');
INSERT INTO `product_variants` VALUES (297, 33, 'FB005-DO-S', 'ĐỎ / S', 'S', 'ĐỎ', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d830e0d8.84790612.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:30');
INSERT INTO `product_variants` VALUES (298, 33, 'FB005-DO-M', 'ĐỎ / M', 'M', 'ĐỎ', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d830e0d8.84790612.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:30');
INSERT INTO `product_variants` VALUES (299, 33, 'FB005-DO-L', 'ĐỎ / L', 'L', 'ĐỎ', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d830e0d8.84790612.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:30');
INSERT INTO `product_variants` VALUES (300, 33, 'FB005-DO-XL', 'ĐỎ / XL', 'XL', 'ĐỎ', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d830e0d8.84790612.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:30');
INSERT INTO `product_variants` VALUES (301, 33, 'FB005-XANH-S', 'XANH / S', 'S', 'XANH', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d830fd28.67352996.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:25');
INSERT INTO `product_variants` VALUES (302, 33, 'FB005-XANH-M', 'XANH / M', 'M', 'XANH', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d830fd28.67352996.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:25');
INSERT INTO `product_variants` VALUES (303, 33, 'FB005-XANH-L', 'XANH / L', 'L', 'XANH', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d830fd28.67352996.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:25');
INSERT INTO `product_variants` VALUES (304, 33, 'FB005-XANH-XL', 'XANH / XL', 'XL', 'XANH', 680000.00, 399000.00, 320000.00, 0, 'uploads/img_69bd26d830fd28.67352996.jpg', 0, 1, '2026-03-20 17:52:08', '2026-03-20 17:52:25');
INSERT INTO `product_variants` VALUES (305, 34, 'AO019-TRANG-S', 'TRẮNG / S', 'S', 'TRẮNG', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd277930dd07.53103134.jpg', 1, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:03');
INSERT INTO `product_variants` VALUES (306, 34, 'AO019-TRANG-M', 'TRẮNG / M', 'M', 'TRẮNG', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd277930dd07.53103134.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:03');
INSERT INTO `product_variants` VALUES (307, 34, 'AO019-TRANG-L', 'TRẮNG / L', 'L', 'TRẮNG', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd277930dd07.53103134.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:03');
INSERT INTO `product_variants` VALUES (308, 34, 'AO019-TRANG-XL', 'TRẮNG / XL', 'XL', 'TRẮNG', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd277930dd07.53103134.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:03');
INSERT INTO `product_variants` VALUES (309, 34, 'AO019-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2779318c15.99766929.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:12');
INSERT INTO `product_variants` VALUES (310, 34, 'AO019-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2779318c15.99766929.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:12');
INSERT INTO `product_variants` VALUES (311, 34, 'AO019-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2779318c15.99766929.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:12');
INSERT INTO `product_variants` VALUES (312, 34, 'AO019-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2779318c15.99766929.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:12');
INSERT INTO `product_variants` VALUES (313, 34, 'AO019-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2779312fc5.72372827.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:15');
INSERT INTO `product_variants` VALUES (314, 34, 'AO019-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2779312fc5.72372827.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:15');
INSERT INTO `product_variants` VALUES (315, 34, 'AO019-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2779312fc5.72372827.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:15');
INSERT INTO `product_variants` VALUES (316, 34, 'AO019-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 450000.00, 279000.00, 200000.00, 0, 'uploads/img_69bd2779312fc5.72372827.jpg', 0, 1, '2026-03-20 17:54:49', '2026-03-20 17:56:15');
INSERT INTO `product_variants` VALUES (317, 35, 'FB006-DEN-S', 'ĐEN / S', 'S', 'ĐEN', 640000.00, 420000.00, 340000.00, 0, 'uploads/img_69bd2893992228.59930355.jpg', 1, 1, '2026-03-20 17:59:31', '2026-03-20 17:59:45');
INSERT INTO `product_variants` VALUES (318, 35, 'FB006-DEN-L', 'ĐEN / L', 'L', 'ĐEN', 640000.00, 420000.00, 340000.00, 0, 'uploads/img_69bd2893992228.59930355.jpg', 0, 1, '2026-03-20 17:59:31', '2026-03-20 17:59:45');
INSERT INTO `product_variants` VALUES (319, 35, 'FB006-DEN-M', 'ĐEN / M', 'M', 'ĐEN', 640000.00, 420000.00, 340000.00, 0, 'uploads/img_69bd2893992228.59930355.jpg', 0, 1, '2026-03-20 17:59:31', '2026-03-20 17:59:45');
INSERT INTO `product_variants` VALUES (320, 35, 'FB006-DEN-XL', 'ĐEN / XL', 'XL', 'ĐEN', 640000.00, 420000.00, 340000.00, 0, 'uploads/img_69bd2893992228.59930355.jpg', 0, 1, '2026-03-20 17:59:31', '2026-03-20 17:59:45');
INSERT INTO `product_variants` VALUES (321, 35, 'FB006-DOMAN-S', 'ĐỎ MẬN / S', 'S', 'ĐỎ MẬN', 640000.00, 420000.00, 340000.00, 0, 'uploads/img_69bd289399f2a4.21500476.jpg', 0, 1, '2026-03-20 17:59:31', '2026-03-20 17:59:51');
INSERT INTO `product_variants` VALUES (322, 35, 'FB006-DOMAN-L', 'ĐỎ MẬN / L', 'L', 'ĐỎ MẬN', 640000.00, 420000.00, 340000.00, 0, 'uploads/img_69bd289399f2a4.21500476.jpg', 0, 1, '2026-03-20 17:59:31', '2026-03-20 17:59:51');
INSERT INTO `product_variants` VALUES (323, 35, 'FB006-DOMAN-M', 'ĐỎ MẬN / M', 'M', 'ĐỎ MẬN', 640000.00, 420000.00, 340000.00, 0, 'uploads/img_69bd289399f2a4.21500476.jpg', 0, 1, '2026-03-20 17:59:31', '2026-03-20 17:59:51');
INSERT INTO `product_variants` VALUES (324, 35, 'FB006-DOMAN-XL', 'ĐỎ MẬN / XL', 'XL', 'ĐỎ MẬN', 640000.00, 420000.00, 340000.00, 0, 'uploads/img_69bd289399f2a4.21500476.jpg', 0, 1, '2026-03-20 17:59:31', '2026-03-20 17:59:51');
INSERT INTO `product_variants` VALUES (325, 35, 'FB006-DFT', 'Mặc định', NULL, NULL, 640000.00, 420000.00, 340000.00, 0, NULL, 0, 1, '2026-03-20 17:59:55', '2026-03-20 17:59:55');

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
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of products
-- ----------------------------
INSERT INTO `products` VALUES (1, 'POLO  BURBERRY', 'polo-burberry', 'AO_001', 1, 11, 1, 'Unisex', 340000.00, 269000.00, 190000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'Mô tả bán hàng\r\n\r\nPOLO BBR – BẢN MỚI NHẤT 2026\r\n\r\nHàng mới về cực đẹp cho anh em bán Tết 🔥\r\nThiết kế đơn giản – basic – sang xịn, dễ mặc, dễ phối đồ nên cực kỳ dễ bán.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nForm polo nam chuẩn đẹp\r\n\r\nTúi ngực da nổi bật tạo điểm nhấn sang trọng\r\n\r\nPhong cách basic nam tính, mặc đi chơi – đi làm đều hợp\r\n\r\nChất vải mềm mịn, thoáng mát, mặc cực thoải mái\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\nĐen\r\n\r\nXanh navy\r\n\r\nXanh rêu\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n⚜️ Phù hợp:\r\n✔ Đi chơi\r\n✔ Đi làm\r\n✔ Dạo phố\r\n✔ Mặc Tết cực đẹp\r\n\r\n🔥 Mẫu polo basic dễ bán – shop nào cũng nên có', 'Polo BBR bản mới 2026 – thiết kế basic sang trọng, dễ mặc dễ bán. Chất vải cao cấp, form chuẩn nam, phối túi da nổi bật cực trend.', 0, 1, 0, 0, 'Đức buôn', 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd4231ee9f96.82671328.jpg', 1, '2026-03-18 15:58:30', NULL, '2026-03-18 15:58:30', '2026-03-20 19:51:36', 0);
INSERT INTO `products` VALUES (2, 'T-SHIRT LOUIS VUITTON FULL HOẠ TIẾT THÊU', 't-shirt-louis-vuitton-full-hoa-tiet-theu-1', 'AO_002', 1, 11, 1, 'Nam', 425000.00, 299000.00, 225000.00, 'Đức buôn', 'Cotton, Mềm Mịn', '🔥 T-SHIRT LV – BẢN MỚI NHẤT 2026\r\n\r\nMẫu mới về cho anh em bán cực đẹp, form chuẩn – thêu full cao cấp nhìn rất sang.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo LV thêu nổi cao cấp trước ngực\r\n\r\nHọa tiết chữ Louis Vuitton thêu full sau lưng cực đẹp\r\n\r\nForm áo nam chuẩn, mặc đứng dáng\r\n\r\nChất vải cotton mềm, thoáng mát\r\n\r\n⚜️ Phong cách:\r\nBasic – nam tính – dễ phối đồ\r\nMặc đi chơi, đi làm, đi cafe đều đẹp.\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\nĐen\r\n\r\nXanh navy\r\n\r\nĐỏ đô\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nĐi làm\r\n\r\nMặc hằng ngày\r\n\r\n🔥 Mẫu hot dễ bán – form đẹp – logo thêu sang', 'T-Shirt LV thêu full bản mới 2026 – thiết kế nam tính, form đẹp, chất vải cao cấp, logo thêu sắc nét cực sang.', 0, 1, 0, 0, 'Đức buôn', 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd426cc331b4.30040811.jpg', 1, '2026-03-18 16:10:07', NULL, '2026-03-18 16:10:07', '2026-03-20 19:51:27', 0);
INSERT INTO `products` VALUES (3, 'T-SHIRT LOUIS VUITTON FULL HOẠ TIẾT THÊU', 't-shirt-louis-vuitton-full-hoa-tiet-theu-2', 'AO_003', 1, 11, 1, 'Nam', 410000.00, 279000.00, 205000.00, 'Đức buôn', 'Cotton, Mềm Mịn', '🔥 T-SHIRT LV – HÀNG MỚI 2026\r\n\r\nMẫu mới về cho anh em bán Tết cực đẹp\r\nThiết kế trông chiến – form chuẩn – dễ bán.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết thêu nổi cao cấp trước ngực\r\n\r\nPhong cách trẻ trung, cá tính\r\n\r\nForm áo nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải cotton mềm, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nĐi làm\r\n\r\nDạo phố\r\n\r\nMặc Tết cực đẹp\r\n\r\n🔥 Mẫu basic dễ bán – nhìn là chốt đơn', 'T-Shirt LOUIS VUITTON bản mới 2026 – thiết kế trẻ trung, họa tiết thêu nổi bật, form đẹp dễ bán dịp Tết.', 0, 1, 0, 0, 'Đức buôn', 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd4291612e06.84097889.jpg', 1, '2026-03-18 16:12:35', NULL, '2026-03-18 16:12:35', '2026-03-20 19:51:18', 0);
INSERT INTO `products` VALUES (4, 'SƠ MI BURBERRY TAG ĐÁ 2 BÊN', 'so-mi-burberry-tag-da-2-ben', 'AO_004', 1, 2, 1, 'Nam', 420000.00, 299000.00, 220000.00, 'Nhà Xung Nga', 'Cotton, Mềm Mịn', '✨ SƠ MI BBR CAO CẤP\r\n\r\nĐi tiệc – đám cưới – sự kiện thì sơ mi trắng vẫn luôn là chân ái 😍\r\n\r\nMẫu Sơ Mi BBR mới nhất với thiết kế sang trọng, điểm nhấn đính đá ở cổ áo cực nổi bật và lịch lãm.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nForm sơ mi nam chuẩn đẹp\r\n\r\nCổ áo đính họa tiết đá sang trọng\r\n\r\nVải mềm mịn, mặc thoáng mát\r\n\r\nThiết kế thanh lịch, cực hợp đi tiệc\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n⚜️ Phù hợp:\r\n✔ Đi tiệc\r\n✔ Đi cưới\r\n✔ Đi làm\r\n✔ Sự kiện – gặp đối tác', 'Sơ Mi Burbbery cao cấp – thiết kế lịch lãm, form chuẩn nam, cổ áo đính họa tiết nổi bật, cực phù hợp mặc tiệc – cưới – sự kiện.', 0, 1, 0, 0, 'Nhà Xung Nga', 'https://zalo.me/g/isptip699', 'uploads/img_69bd42a94900a7.25065381.jpg', 1, '2026-03-18 16:21:12', NULL, '2026-03-18 16:21:12', '2026-03-20 19:50:49', 0);
INSERT INTO `products` VALUES (5, 'SƠ MI Dolce & Gabbana', 'so-mi-dolce-gabbana-3', 'AO_005', 1, 2, 3, 'Nam', 380000.00, 260000.00, 180000.00, 'Xung Nga', 'Cotton, Mềm Mịn', '✨ SƠ MI DOLCE & GABBANA – BẢN NEW\r\n\r\nMẫu sơ mi mới về cực đẹp cho anh em bán.\r\nThiết kế lịch lãm – sang trọng – chuẩn form nam, mặc đi làm hay đi tiệc đều rất hợp.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Dolce & Gabbana nổi bật ở cổ áo\r\n\r\nForm sơ mi nam đứng dáng\r\n\r\nChất vải mềm mịn, mặc thoáng mát\r\n\r\nThiết kế đơn giản nhưng cực sang\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi tiệc\r\n\r\nĐi sự kiện\r\n\r\nGặp đối tác', 'Sơ Mi Dolce & Gabbana bản new – thiết kế sang trọng, form chuẩn nam, điểm nhấn logo cổ áo cực nổi bật.', 0, 1, 0, 0, 'Xung Nga', 'https://zalo.me/g/isptip699', 'uploads/img_69bd42bb7c0306.92031856.jpg', 1, '2026-03-18 16:25:22', NULL, '2026-03-18 16:25:22', '2026-03-20 19:51:07', 0);
INSERT INTO `products` VALUES (6, 'SƠ MI DIOR', 'so-mi-dior', 'AO_006', 1, 2, 1, 'Nam', 420000.00, 299000.00, 220000.00, 'Xung Nga', 'Cotton, Mềm Mịn', 'SƠ MI DIOR CAO CẤP\r\n\r\nMẫu sơ mi mới về phục vụ mùa lễ – tiệc – Tết, thiết kế đơn giản nhưng cực kỳ sang và lịch lãm.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nTag ong Dior đính ở cổ áo tạo điểm nhấn cao cấp\r\n\r\nForm sơ mi nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\nPhong cách thanh lịch, dễ phối đồ\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi tiệc\r\n\r\nĐi sự kiện\r\n\r\nMặc dịp lễ Tết', 'Sơ Mi Dior cao cấp – thiết kế thanh lịch, form chuẩn nam, cổ áo đính tag ong sang trọng.', 0, 1, 0, 0, 'Xung Nga', 'https://zalo.me/g/isptip699', 'uploads/img_69bd42f57d2ae9.92151229.jpg', 1, '2026-03-18 16:28:56', NULL, '2026-03-18 16:28:56', '2026-03-20 19:52:05', 0);
INSERT INTO `products` VALUES (7, 'SƠ MI MCQUEEN', 'so-mi-mcqueen', 'AO_007', 1, 2, 1, 'Nam', 420000.00, 299000.00, 220000.00, 'Xung Nga', 'Cotton, Mềm Mịn', '✨ SƠ MI MCQ – HÀNG MỚI\r\n\r\nMẫu sơ mi mới cực đẹp dành cho anh em bán.\r\nThiết kế sang trọng – độc đáo – khác biệt, mặc lên rất nổi bật.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết thêu nghệ thuật tinh xảo trước ngực\r\n\r\nPhong cách thời trang cao cấp, cá tính\r\n\r\nForm sơ mi nam chuẩn đẹp\r\n\r\nChất vải lụa cao cấp mềm mịn, mặc thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi tiệc\r\n\r\nĐi chơi\r\n\r\nSự kiện\r\n\r\nMặc dịp lễ Tết', 'Sơ Mi MCQ (McQueen) cao cấp – thiết kế họa tiết thêu tinh xảo, form chuẩn nam, phong cách sang trọng và nổi bật.', 0, 1, 0, 0, 'Xung Nga', 'https://zalo.me/g/isptip699', 'uploads/img_69bd4315a31261.75578140.jpg', 1, '2026-03-18 16:31:54', NULL, '2026-03-18 16:31:54', '2026-03-20 19:52:37', 0);
INSERT INTO `products` VALUES (8, 'T-SHIRT LOUIS VUITTON FULL HOẠ TIẾT THÊU', 't-shirt-louis-vuitton-full-hoa-tiet-theu', 'AO_008', 1, 11, 1, 'Nam', 410000.00, 289000.00, 210000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'Mô tả bán hàng\r\n\r\n🔥 T-SHIRT LV THÊU FULL – HOT SEASON\r\n\r\nMẫu áo đang cực hot, về full màu cho anh em dễ bán 🔥\r\nThiết kế trẻ trung – nổi bật – mặc lên cực có gu.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết Louis Vuitton thêu nổi cao cấp\r\n\r\nLogo trải dài cổ và trước ngực cực bắt mắt\r\n\r\nForm áo nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\nXanh navy\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nĐi làm\r\n\r\nMặc hằng ngày', 'T-Shirt Louis Vuitton thêu full – thiết kế nổi bật, họa tiết thêu cao cấp, form đẹp dễ mặc', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd0aac4cdb85.83013757.jpg', 1, NULL, NULL, '2026-03-20 15:51:56', '2026-03-20 15:53:10', 1);
INSERT INTO `products` VALUES (9, 'QUẦN SHORT LOUIS VUITTON', 'quan-short-louis-vuitton', 'QU_001', 2, 5, 1, 'Nam', 405000.00, 265000.00, 205000.00, 'Đức buôn', 'Cotton, Mềm Mịn', '🔥 SHORT GIÓ LV – HÀNG MỚI\r\n\r\nMẫu short gió vừa về, số lượng không nhiều, anh em nhanh tay chốt 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nChất gió nhẹ, mặc mát – nhanh khô\r\n\r\nLogo LV in/thêu nổi bật cực đẹp\r\n\r\nCạp chun co giãn + dây rút chắc chắn\r\n\r\nForm thể thao, mặc thoải mái vận động\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nTập gym / thể thao\r\n\r\nDu lịch\r\n\r\nMặc ở nhà vẫn đẹp', 'Short gió LV cao cấp – thiết kế thể thao, chất liệu nhẹ thoáng, logo nổi bật, mặc cực mát.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd0bf77d2b65.71813569.jpg', 1, NULL, NULL, '2026-03-20 15:57:27', '2026-03-20 15:57:59', 1);
INSERT INTO `products` VALUES (10, 'SHORT GIÓ DSQ', 'short-gio-dsq', 'SP00010', 2, 5, 1, 'Nam', 395000.00, 255000.00, 195000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SHORT GIÓ DSQ2 – HÀNG NEW\r\n\r\nMẫu short hot cho mùa hè, thiết kế màu sắc nổi bật – cực kỳ bắt mắt, lên đồ là nổi ngay 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết DSQ2 full quần cực chất\r\n\r\nChất gió 2 lớp dày dặn, mặc mát, không lộ\r\n\r\nForm thể thao, mặc thoải mái\r\n\r\nCạp chun co giãn + dây rút chắc chắn\r\n\r\n⚜️ Màu sắc:\r\n\r\nFull họa tiết nhiều màu (như hình)\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDu lịch\r\n\r\nĐi biển\r\n\r\nTập gym / thể thao', 'Quần Short DSQ2 (Dsquared2) – thiết kế họa tiết nổi bật, chất gió 2 lớp cao cấp, mặc mát và cực kỳ thời trang.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd0db3cf6ee9.62724580.jpg', 1, NULL, NULL, '2026-03-20 16:04:51', '2026-03-20 16:05:12', 1);
INSERT INTO `products` VALUES (11, 'SHORT GIÓ MONCLER', 'short-gio-moncler', 'QU_002', 2, 5, 1, 'Nam', 369000.00, 259000.00, 190000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SHORT GIÓ MONCLER – HÀNG HOT\r\n\r\nMẫu short basic nhưng cực kỳ sang – mặc lên nhìn xịn hẳn, anh em bán mùa hè rất chạy 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Moncler thêu/in nổi bật phía sau cực đẹp\r\n\r\nForm short nam chuẩn, mặc đứng dáng\r\n\r\nChất gió nhẹ, mát – nhanh khô\r\n\r\nCạp chun co giãn + dây rút tiện lợi\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nDu lịch\r\n\r\nMặc hằng ngày', 'Short gió Moncler cao cấp – thiết kế thể thao, form đẹp, logo nổi bật, chất vải mát nhẹ cực kỳ thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd0f7470e496.60229307.jpg', 1, NULL, NULL, '2026-03-20 16:12:20', '2026-03-20 16:12:28', 1);
INSERT INTO `products` VALUES (12, 'SHORT DOLCE & GABBANA', 'short-dolce-gabbana', 'QU_003', 2, 5, 1, 'Nam', 390000.00, 259000.00, 190000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SHORT DOLCE & GABBANA – HÀNG MỚI\r\n\r\nMẫu short mới về cực đẹp, thiết kế đơn giản nhưng rất sang, lên đồ là thấy khác biệt 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Dolce & Gabbana nổi bật phía sau\r\n\r\nPatch hình in cao cấp tạo điểm nhấn độc đáo\r\n\r\nForm short nam chuẩn đẹp, mặc gọn gàng\r\n\r\nChất gió nhẹ, mát – nhanh khô – mặc cực thích\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nDu lịch\r\n\r\nMặc hằng ngày', 'Short Dolce & Gabbana cao cấp – thiết kế nổi bật, form thể thao, chất gió nhẹ mát, mặc cực thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd1041c01701.58585412.jpg', 1, NULL, NULL, '2026-03-20 16:15:45', '2026-03-20 16:16:13', 1);
INSERT INTO `products` VALUES (13, 'SHORT DIOR', 'short-dior', 'QU_004', 2, 5, 1, 'Nam', 400000.00, 259000.00, 200000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SHORT GIÓ DIOR – HÀNG HOT\r\n\r\nMẫu short đang cực hot, về là anh em bán chạy ngay 🔥\r\nThiết kế đơn giản nhưng sang – mặc lên rất có gu.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Dior dệt ở cạp cực nổi bật\r\n\r\nThêu logo tinh tế phía trước\r\n\r\nChất gió nhẹ, mát – nhanh khô – mặc cực thích\r\n\r\nCạp chun co giãn + dây rút chắc chắn\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\nĐen\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nTập gym / thể thao\r\n\r\nDu lịch\r\n\r\nMặc hằng ngày', 'Short gió Dior cao cấp – thiết kế thể thao, logo nổi bật, chất mát nhẹ, mặc cực thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd10eba43375.72503824.jpg', 1, NULL, NULL, '2026-03-20 16:18:35', '2026-03-20 16:19:09', 1);
INSERT INTO `products` VALUES (14, 'SHORT GIÓ MONCLER', 'short-gio-moncler-1', 'QU_005', 2, 5, 1, 'Nam', 405000.00, 269000.00, 205000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SHORT GIÓ MONCLER – HÀNG HOT\r\n\r\nMẫu short basic nhưng cực kỳ sang – mặc lên nhìn xịn hẳn, anh em bán mùa hè rất chạy 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Moncler thêu/in nổi bật phía sau cực đẹp\r\n\r\nForm short nam chuẩn, mặc đứng dáng\r\n\r\nChất gió nhẹ, mát – nhanh khô\r\n\r\nCạp chun co giãn + dây rút tiện lợi\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nDu lịch\r\n\r\nMặc hằng ngày', 'Short gió Moncler cao cấp – thiết kế thể thao, form đẹp, logo nổi bật, chất vải mát nhẹ cực kỳ thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd11bc0f9047.69231849.jpg', 1, NULL, NULL, '2026-03-20 16:22:04', '2026-03-20 16:32:02', 1);
INSERT INTO `products` VALUES (15, 'QUẦN SHORT DSQUARED2', 'quan-short-dsquared2', 'QU_006', 2, 5, 1, 'Nam', 390000.00, 259000.00, 190000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SHORT DSQ2 – BẢN NEW 2026\r\n\r\nHàng mới về cho anh em bán, mẫu này màu nổi – họa tiết lạ mắt, khách nhìn là thích ngay 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết DSQ2 full quần cực nổi bật\r\n\r\nChất gió 2 lớp có lót trong, mặc êm và không lộ\r\n\r\nForm short thể thao, mặc thoải mái\r\n\r\nCạp chun co giãn + dây rút chắc chắn\r\n\r\n⚜️ Màu sắc:\r\n\r\nHọa tiết đỏ đô mix chữ (như hình)\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDu lịch\r\n\r\nĐi biển\r\n\r\nMặc hằng ngày', 'Short DSQ2 bản new 2026 – thiết kế họa tiết nổi bật, chất gió 2 lớp cao cấp, mặc mát và cực kỳ thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd1304aeff58.59603043.jpg', 1, NULL, NULL, '2026-03-20 16:27:32', '2026-03-20 16:31:54', 1);
INSERT INTO `products` VALUES (16, 'SHORT GIÓ MONCLER', 'short-gio-moncler-2', 'QU_007', 2, 5, 1, 'Nam', 400000.00, 259000.00, 200000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SHORT GIÓ MONCLER – BẢN NEW\r\n\r\nMẫu mới về cực đẹp cho anh em bán, phối màu nổi bật – nhìn là ưng ngay 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết thêu logo Moncler tinh tế\r\n\r\nPhối màu cực đẹp, dễ phối đồ\r\n\r\nChất gió 2 lớp dày dặn, mặc mát và không lộ\r\n\r\nForm short thể thao, mặc thoải mái\r\n\r\nCạp chun co giãn + dây rút chắc chắn\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nXanh navy\r\n\r\nXanh rêu\r\n\r\nĐỏ đô\r\n\r\nGhi\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nTập gym / thể thao\r\n\r\nDu lịch\r\n\r\nMặc hằng ngày', 'Short gió Moncler bản new – thiết kế thể thao, phối màu cực đẹp, chất gió 2 lớp dày dặn, mặc mát thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd13c640ac34.82330259.jpg', 1, NULL, NULL, '2026-03-20 16:30:46', '2026-03-20 16:31:23', 1);
INSERT INTO `products` VALUES (17, 'ÁO PHÔNG LOUIS VUITTON', 'ao-phong-louis-vuitton', 'AO_009', 1, 11, 1, 'Nam', 355000.00, 229000.00, 155000.00, 'MINH NHẬT B28', 'Cotton, Mềm Mịn', 'PHÔNG LOUIS VUITTON – BẢN NEW 2026\r\n\r\nMẫu phông mới về cho anh em bán, basic nhưng cực sang, khách mặc lên nhìn rất có gu 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nThiết kế đơn giản – tinh tế – chuẩn LV\r\n\r\nLogo nhỏ trước ngực tạo điểm nhấn\r\n\r\nForm áo nam chuẩn đẹp, dễ mặc\r\n\r\nChất vải cotton mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\nĐỏ đô\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n👉 Fit: 50kg – 80kg\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nĐi làm\r\n\r\nDạo phố\r\n\r\nMặc hằng ngày', 'T-Shirt Louis Vuitton 2026 – thiết kế basic cao cấp, form đẹp, dễ mặc', 0, 1, 0, 0, NULL, 'https://zalo.me/g/jvyfgs633', 'uploads/img_69bd15549edf44.03742521.jpg', 1, NULL, NULL, '2026-03-20 16:37:24', '2026-03-20 16:37:39', 1);
INSERT INTO `products` VALUES (18, 'T-SHIRT BALENCIAGA FULL THÊU', 't-shirt-balenciaga-full-theu', 'AO_010', 1, 11, 1, 'Nam', 420000.00, 289000.00, 220000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'T-SHIRT BALENCIAGA – BẢN NEW 2026\r\n\r\nMẫu mới về cực chất cho anh em bán, thiết kế trông chiến – mặc lên nổi bật ngay 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết Balenciaga thêu kiểu mới cực đẹp\r\n\r\nThiết kế chữ chạy dọc độc đáo, rất bắt mắt\r\n\r\nForm áo nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải cotton mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\nĐỏ đô\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nĐi làm\r\n\r\nMặc hằng ngày', 'T-Shirt Balenciaga 2026 – thiết kế họa tiết thêu mới, form đẹp, phong cách trẻ trung cá tính.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd16322da762.54716206.jpg', 1, NULL, NULL, '2026-03-20 16:41:06', '2026-03-20 19:47:44', 1);
INSERT INTO `products` VALUES (19, 'SHORT GIÓ LOUIS VUITTON', 'short-gio-louis-vuitton', 'QU_008', 2, 5, 1, 'Nam', 400000.00, 259000.00, 200000.00, 'ĐỨC BUÔN', 'Cotton, Mềm Mịn', 'SHORT GIÓ LV THÊU THUYỀN – HÀNG MỚI\r\n\r\nMẫu short mới về cực đẹp, thiết kế đơn giản nhưng rất sang, anh em bán cực chạy 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Louis Vuitton thêu nổi + hình thuyền độc đáo\r\n\r\nCạp dệt chữ LV nổi bật\r\n\r\nForm short thể thao, mặc thoải mái\r\n\r\nChất gió nhẹ, mát – nhanh khô – mặc cực thích\r\n\r\nDây rút chắc chắn, tiện lợi\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nDu lịch\r\n\r\nMặc hằng ngày', 'Short gió Louis Vuitton thêu thuyền – thiết kế nổi bật, form thể thao, chất mát nhẹ, mặc cực thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd16f1d0dbd3.31103403.jpg', 1, NULL, NULL, '2026-03-20 16:44:17', '2026-03-20 16:44:27', 1);
INSERT INTO `products` VALUES (20, 'SHORT TÚI HỘP', 'short-tui-hop', 'QU_009', 2, 5, 1, 'Nam', 430000.00, 289000.00, 230000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SHORT TÚI HỘP – CARGO HOT TREND\r\n\r\nMẫu short đang cực hot, thiết kế bụi bặm – cá tính – mặc lên rất ngầu, anh em bán mùa hè cực chạy 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nThiết kế nhiều túi hộp tiện lợi\r\n\r\nForm rộng thoải mái, dễ mặc\r\n\r\nPhong cách cargo streetwear cực trend\r\n\r\nChất vải dày dặn, mặc đứng form\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nXám\r\n\r\nXanh rêu\r\n\r\nĐỏ đô\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nDu lịch\r\n\r\nPhối đồ street style', 'Quần short túi hộp – thiết kế cargo cá tính, nhiều túi tiện lợi, form rộng thoải mái, cực hợp đi chơi – dạo phố.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd17bacd1b95.97881465.jpg', 1, NULL, NULL, '2026-03-20 16:47:38', '2026-03-20 16:47:56', 1);
INSERT INTO `products` VALUES (21, 'HOT SET FULL BỘ RẰN RI ADIDAS', 'hot-set-full-bo-ran-ri-adidas', 'FB_001', 6, 12, 1, 'Nam', 580000.00, 409000.00, 330000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SET BỘ ADIDAS TRẮNG KEM – HÀNG HOT\r\n\r\nMẫu set mới về cực đẹp, phối màu trắng kem nhẹ nhàng nhưng vẫn nổi bật, mặc lên rất có gu 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nSet gồm áo + quần đồng bộ\r\n\r\nHọa tiết camo phối tinh tế\r\n\r\nForm thể thao, mặc thoải mái\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng kem phối họa tiết\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nDu lịch\r\n\r\nTập thể thao nhẹ', 'Set bộ Adidas trắng kem – thiết kế thể thao hiện đại, phối họa tiết camo nhẹ, mặc cực mát và thời trang.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd18c9437386.47184303.jpg', 1, NULL, NULL, '2026-03-20 16:52:09', '2026-03-20 16:52:18', 1);
INSERT INTO `products` VALUES (22, 'HOT SET FULL BỘ ADIDAS', 'hot-set-full-bo-adidas', 'FB_002', 6, 12, 1, 'Nam', 590000.00, 399000.00, 320000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'FULL BỘ ADIDAS – HÀNG HOT\r\n\r\nSet bộ mới về cực đẹp, phối màu xanh navy – trắng đơn giản nhưng rất sang, mặc lên cực gọn gàng 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nSet gồm áo + quần đồng bộ\r\n\r\nLogo Adidas nổi bật trước ngực\r\n\r\nForm thể thao chuẩn, mặc thoải mái\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nXanh navy phối trắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nTập thể thao\r\n\r\nMặc hằng ngày', 'Set bộ Adidas thể thao – thiết kế trẻ trung, form đẹp, mặc thoải mái, phù hợp đi chơi và vận động.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd1b27f04574.45135916.jpg', 1, NULL, NULL, '2026-03-20 17:02:15', '2026-03-20 17:02:25', 1);
INSERT INTO `products` VALUES (23, 'HOT SET FULL BỘ THỂ THAO HOT TREND', 'hot-set-full-bo-the-thao-hot-trend', 'FB_003', 6, 12, 1, 'Nam', 599000.00, 399000.00, 325000.00, 'ĐỨC BUÔN', 'Cotton, Mềm Mịn', 'SET BỘ ĐỘI TUYỂN BỒ ĐÀO NHA – HÀNG HOT\r\n\r\nMẫu set mới về cực đẹp, lấy cảm hứng từ đội tuyển Bồ Đào Nha, mặc lên cực sporty và nam tính 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nSet gồm áo + quần đồng bộ\r\n\r\nLogo đội tuyển + hãng nổi bật trước ngực\r\n\r\nForm thể thao chuẩn, mặc thoải mái vận động\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nXanh đậm\r\n\r\nĐen\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nTập thể thao\r\n\r\nĐá bóng\r\n\r\nMặc hằng ngày', 'Set bộ đội tuyển Bồ Đào Nha (Adidas) – thiết kế thể thao, form đẹp, chất vải mịn mát, mặc cực thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd1c620f87e6.02642423.jpg', 1, NULL, NULL, '2026-03-20 17:07:30', '2026-03-20 17:07:55', 1);
INSERT INTO `products` VALUES (24, 'HOT SET FULL BỘ THỂ THAO HOT TREND', 'hot-set-full-bo-the-thao-hot-trend-1', 'FB_004', 6, 12, 1, 'Nam', 690000.00, 399000.00, 325000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SET BỘ ARSENAL \r\n\r\nMẫu set mới về cực đẹp, lấy cảm hứng từ CLB Arsenal, phối màu trắng – đỏ đô nhìn rất nổi bật 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nSet gồm áo + quần đồng bộ\r\n\r\nLogo CLB + hãng nổi bật trước ngực\r\n\r\nForm thể thao chuẩn, mặc thoải mái\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng phối đỏ đô\r\n\r\nFull đỏ đô\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nTập thể thao\r\n\r\nĐá bóng\r\n\r\nMặc hằng ngày', 'Set bộ Arsenal  – thiết kế thể thao, form đẹp, phối màu trẻ trung, mặc thoải mái và cực dễ bán.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd1d14098e12.19106422.jpg', 1, NULL, NULL, '2026-03-20 17:10:28', '2026-03-20 17:10:39', 1);
INSERT INTO `products` VALUES (25, 'SƠ MI Dolce & Gabbana', 'so-mi-dolce-gabbana', 'AO_011', 1, 2, 1, 'Nam', 389000.00, 259000.00, 175000.00, 'Xung Nga', 'Cotton, Mềm Mịn', 'SƠ MI DOLCE & GABBANA – HÀNG MỚI\r\n\r\nThời tiết này lên sơ mi là chuẩn bài, mẫu D&G mới về cực đẹp cho anh em bán 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Dolce & Gabbana thêu + tag gương cao cấp\r\n\r\nThiết kế sang trọng, mặc lên cực lịch lãm\r\n\r\nForm sơ mi nam chuẩn đẹp, đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi tiệc\r\n\r\nĐi sự kiện\r\n\r\nMặc hằng ngày', 'Sơ mi Dolce & Gabbana thêu tag gương – thiết kế thanh lịch, form chuẩn, chi tiết cao cấp cực sang.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/isptip699', 'uploads/img_69bd1dfbc94b08.13368581.jpg', 1, NULL, NULL, '2026-03-20 17:14:19', '2026-03-20 17:14:33', 1);
INSERT INTO `products` VALUES (26, 'SƠ MI Dolce & Gabbana', 'so-mi-dolce-gabbana-1', 'AO_012', 1, 2, 1, 'Nam', 379000.00, 259000.00, 175000.00, 'Xung Nga', 'Cotton, Mềm Mịn', 'SƠ MI DOLCE & GABBANA – HÀNG HOT\r\n\r\nMẫu sơ mi đơn giản nhưng cực dễ bán, lên form rất đẹp cho anh em triển 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết Dolce thêu sắc nét, tinh xảo\r\n\r\nThiết kế basic, dễ mặc nhiều độ tuổi\r\n\r\nForm sơ mi nam chuẩn đẹp, đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi tiệc\r\n\r\nGặp đối tác\r\n\r\nMặc hằng ngày', 'Sơ mi Dolce & Gabbana thêu cao cấp – thiết kế đơn giản, form chuẩn, chi tiết thêu sắc nét cực sang.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/isptip699', 'uploads/img_69bd1f1331eaf0.70785659.jpg', 1, NULL, NULL, '2026-03-20 17:18:59', '2026-03-20 17:19:08', 1);
INSERT INTO `products` VALUES (27, 'SƠ MI Dolce & Gabbana', 'so-mi-dolce-gabbana-2', 'AO_013', 1, 2, 1, 'Nam', 420000.00, 249000.00, 170000.00, 'Xung Nga', 'Cotton, Mềm Mịn', 'SƠ MI DOLCE & GABBANA – BẢN MỚI\r\n\r\nMẫu mới cập bến cực đẹp, thiết kế đơn giản nhưng tinh tế, anh em bán rất dễ ra đơn 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Dolce & Gabbana thêu sắc nét trước ngực\r\n\r\nChi tiết tay áo phối sao độc đáo tạo điểm nhấn\r\n\r\nForm sơ mi nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi tiệc\r\n\r\nGặp đối tác\r\n\r\nMặc hằng ngày', 'Sơ mi Dolce & Gabbana 2026 – thiết kế thêu cao cấp, form chuẩn nam, phong cách lịch lãm hiện đại.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/isptip699', 'uploads/img_69bd1f98cc6c15.17496498.jpg', 1, NULL, NULL, '2026-03-20 17:21:12', '2026-03-20 17:21:21', 1);
INSERT INTO `products` VALUES (28, 'SƠ MI LOUIS VUITTON', 'so-mi-louis-vuitton', 'AO_014', 1, 2, 1, 'Nam', 530000.00, 279000.00, 200000.00, 'Xung Nga', 'Cotton, Mềm Mịn', 'SƠ MI LOUIS VUITTON – BẢN NEW 2026\r\n\r\nThời tiết này lên sơ mi là chuẩn bài, mẫu LV mới về cực đẹp, anh em bán rất dễ ra đơn 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Louis Vuitton thêu tinh tế trước ngực\r\n\r\nTag kim loại cao cấp tạo điểm nhấn sang trọng\r\n\r\nForm sơ mi nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải cao cấp, mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi tiệc\r\n\r\nGặp đối tác\r\n\r\nMặc hằng ngày', 'Sơ mi Louis Vuitton 2026 – thiết kế thanh lịch, thêu cao cấp, điểm nhấn tag kim loại sang trọng.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/isptip699', 'uploads/img_69bd202790d513.00141508.jpg', 1, NULL, NULL, '2026-03-20 17:23:35', '2026-03-20 17:24:32', 1);
INSERT INTO `products` VALUES (29, 'SƠ MI BURBBERY', 'so-mi-burbbery', 'AO_015', 1, 2, 1, 'Nam', 460000.00, 269000.00, 180000.00, 'Xung Nga', 'Cotton, Mềm Mịn', 'SƠ MI BURBERRY CARO – HÀNG HOT\r\n\r\nMẫu sơ mi Burberry full màu cực đẹp, họa tiết kinh điển – mặc lên rất có gu, anh em bán cực chạy 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết caro Burberry đặc trưng\r\n\r\nĐường may tỉ mỉ, chuẩn form cao cấp\r\n\r\nForm sơ mi nam đẹp, mặc đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nBe caro\r\n\r\nĐen caro\r\n\r\nNâu caro\r\n\r\nXám caro\r\n\r\n⚜️ Size:\r\nM / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi chơi\r\n\r\nĐi tiệc nhẹ\r\n\r\nMặc hằng ngày', 'Sơ mi Burberry caro cao cấp – thiết kế họa tiết đặc trưng, form chuẩn nam, mặc lên cực sang và nổi bật.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/isptip699', 'uploads/img_69bd231aaddc54.41680954.jpg', 1, NULL, NULL, '2026-03-20 17:36:10', '2026-03-20 17:37:13', 1);
INSERT INTO `products` VALUES (30, 'POLO LOUIS VUITTON', 'polo-louis-vuitton', 'AO_016', 1, 14, 1, 'Nam', 499000.00, 269000.00, 195000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'POLO LOUIS VUITTON CỔ CHECK – HÀNG HOT\r\n\r\nMẫu polo mới về cực đẹp, điểm nhấn cổ LV họa tiết cực sang, anh em bán rất dễ ra đơn 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nCổ áo LV check nổi bật, nhận diện cao\r\n\r\nThiết kế polo basic, dễ mặc nhiều độ tuổi\r\n\r\nForm áo nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi chơi\r\n\r\nĐi gặp đối tác\r\n\r\nMặc hằng ngày', 'Áo Polo Louis Vuitton cổ check – thiết kế basic sang trọng, điểm nhấn cổ LV nổi bật, dễ mặc dễ bán.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd24353fc750.77363180.jpg', 1, NULL, NULL, '2026-03-20 17:40:53', '2026-03-20 17:41:15', 1);
INSERT INTO `products` VALUES (31, 'POLO DIOR', 'polo-dior', 'AO_017', 1, 14, 1, 'Nam', 489000.00, 269000.00, 195000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'POLO DIOR TAG ONG – HÀNG HOT\r\n\r\nMẫu polo mới về cực đẹp, thiết kế đơn giản nhưng rất sang, anh em bán cực dễ ra đơn 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo ong Dior thêu tinh tế trước ngực\r\n\r\nCổ áo phối viền nổi bật, tạo điểm nhấn\r\n\r\nForm polo nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi chơi\r\n\r\nGặp đối tác\r\n\r\nMặc hằng ngày', 'Áo Polo Dior tag ong – thiết kế thanh lịch, form chuẩn nam, điểm nhấn logo ong tinh tế.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd24c51c7291.87179480.jpg', 1, NULL, NULL, '2026-03-20 17:43:17', '2026-03-20 17:44:34', 1);
INSERT INTO `products` VALUES (32, 'ÁO PHÔNG LOUIS VUITTON', 'ao-phong-louis-vuitton-1', 'AO_018', 1, 11, 1, 'Nam', 460000.00, 259000.00, 190000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'T-SHIRT LV HỌA TIẾT – BẢN NEW 2026\r\n\r\nMẫu mới về cực chất, thiết kế họa tiết nổi bật – mặc lên trông rất có gu, anh em bán cực chạy 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết LV in/thêu sắc nét, nổi bật\r\n\r\nThiết kế trẻ trung, phong cách hiện đại\r\n\r\nForm áo nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải cotton mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\nĐỏ đô\r\n\r\nXanh navy\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nĐi làm\r\n\r\nMặc hằng ngày', 'T-Shirt Louis Vuitton họa tiết mới 2026 – thiết kế nổi bật, form đẹp, chất vải cao cấp, dễ mặc', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd25c067a1d0.51295744.jpg', 1, NULL, NULL, '2026-03-20 17:47:28', '2026-03-20 17:47:44', 1);
INSERT INTO `products` VALUES (33, 'HOT SET FULL BỘ ADIDAS', 'hot-set-full-bo-adidas-1', 'FB_005', 6, 12, 1, 'Nam', 680000.00, 399000.00, 320000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'SET BỘ ADIDAS – BẢN NEW SS26\r\n\r\nMẫu set mới về cực đẹp, thiết kế đơn giản – thể thao – dễ mặc, anh em bán cực chạy 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nSet gồm áo + quần đồng bộ\r\n\r\nHọa tiết in dập nổi 2 lớp độc đáo\r\n\r\nForm thể thao chuẩn, mặc thoải mái\r\n\r\nChất vải co giãn, mềm mịn, mặc cực mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nXanh rêu\r\n\r\nĐỏ đô\r\n\r\nXanh navy\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nTập thể thao\r\n\r\nDạo phố\r\n\r\nMặc hằng ngày', 'Set bộ Adidas – thiết kế thể thao hiện đại, form đẹp, chất vải co giãn thoải mái, mặc cực mát.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd26d82e5b68.50136403.jpg', 1, NULL, NULL, '2026-03-20 17:52:08', '2026-03-20 17:52:30', 1);
INSERT INTO `products` VALUES (34, 'ÁO PHÔNG BURBBERY', 'ao-phong-burbbery', 'AO_019', 1, 11, 1, 'Nam', 450000.00, 279000.00, 200000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'T-SHIRT BURBERRY DECAL – HÀNG HOT\r\n\r\nMẫu phông Burberry mới về, thiết kế đơn giản nhưng cực kỳ dễ bán, khách nào cũng mặc được 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Burberry in decal sắc nét, rõ chi tiết\r\n\r\nThiết kế basic, dễ phối đồ\r\n\r\nForm áo nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải cotton mềm mịn, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\nĐen\r\n\r\nĐỏ đô\r\n\r\nBe\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nĐi làm\r\n\r\nMặc hằng ngày', 'T-Shirt Burberry decal cao cấp – thiết kế basic, logo sắc nét, form đẹp dễ mặc.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd2779309f03.56982459.jpg', 1, NULL, NULL, '2026-03-20 17:54:49', '2026-03-20 17:56:15', 1);
INSERT INTO `products` VALUES (35, 'HOT SET FULL BỘ ADIDAS', 'hot-set-full-bo-adidas-2', 'FB_006', 6, 12, 1, 'Nam', 640000.00, 420000.00, 340000.00, 'MINH NHẬT B28', 'Cotton, Mềm Mịn', 'SET BỘ ADIDAS LOGO TO – HÀNG HOT\r\n\r\nMẫu set mới về cực chất, logo Adidas in to nổi bật, mặc lên cực kỳ cá tính và dễ bán 🔥\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nSet gồm áo + quần đồng bộ\r\n\r\nLogo Adidas in lớn nổi bật trước ngực & quần\r\n\r\nForm thể thao chuẩn, mặc gọn gàng\r\n\r\nChất vải mềm mịn, co giãn nhẹ, mặc mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen logo đỏ\r\n\r\nĐỏ logo trắng\r\n\r\nĐen logo trắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nTập thể thao\r\n\r\nDạo phố\r\n\r\nMặc hằng ngày', 'Set bộ Adidas in logo lớn – thiết kế thể thao cá tính, form đẹp, mặc cực thoải mái.', 0, 1, 0, 0, NULL, 'https://zalo.me/g/sscwqk872', 'uploads/img_69bd2893992228.59930355.jpg', 1, NULL, NULL, '2026-03-20 17:59:31', '2026-03-20 17:59:55', 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of styles
-- ----------------------------
INSERT INTO `styles` VALUES (1, 'Basic', 'basic', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `styles` VALUES (2, 'Streetwear', 'streetwear', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `styles` VALUES (3, 'Vintage', 'vintage', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');
INSERT INTO `styles` VALUES (4, 'Thanh lịch', 'thanh-lich', 4, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- ----------------------------
-- Table structure for telegram_notification_logs
-- ----------------------------
DROP TABLE IF EXISTS `telegram_notification_logs`;
CREATE TABLE `telegram_notification_logs`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` int UNSIGNED NOT NULL,
  `event_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `chat_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_telegram_order_event_chat`(`order_id` ASC, `event_key` ASC, `chat_id` ASC) USING BTREE,
  INDEX `idx_telegram_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of telegram_notification_logs
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallet_accounts
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallet_ledger
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallet_topup_requests
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
