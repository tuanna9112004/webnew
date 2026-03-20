-- Clean database schema + seed data (no products, customers, carts, orders, payments)

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
/*!40101 SET NAMES utf8mb4 */;
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS `clothing_shop`;
CREATE DATABASE `clothing_shop` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `clothing_shop`;

START TRANSACTION;

CREATE TABLE `admins` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(150) DEFAULT NULL,
  `status` enum('active','locked','disabled') NOT NULL DEFAULT 'active',
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `admin_audit_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `target_table` varchar(50) NOT NULL,
  `target_id` int(10) UNSIGNED NOT NULL,
  `before_data_text` longtext DEFAULT NULL,
  `after_data_text` longtext DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `app_settings` (
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `carts` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `guest_token` char(64) DEFAULT NULL,
  `status` enum('active','converted','abandoned') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `expired_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `cart_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `cart_id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `variant_id` int(10) UNSIGNED DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price_snapshot` decimal(12,2) NOT NULL,
  `sale_price_snapshot` decimal(12,2) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `customers` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_code` varchar(30) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `status` enum('active','locked','disabled') NOT NULL DEFAULT 'active',
  `registered_via` enum('local','google','facebook','admin') NOT NULL DEFAULT 'local',
  `email_verified_at` datetime DEFAULT NULL,
  `phone_verified_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `customer_addresses` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `label` varchar(50) DEFAULT NULL,
  `receiver_name` varchar(150) NOT NULL,
  `receiver_phone` varchar(20) NOT NULL,
  `province_code` varchar(20) DEFAULT NULL,
  `province_name` varchar(100) NOT NULL,
  `district_code` varchar(20) DEFAULT NULL,
  `district_name` varchar(100) NOT NULL,
  `ward_code` varchar(20) DEFAULT NULL,
  `ward_name` varchar(100) NOT NULL,
  `address_line` varchar(255) NOT NULL,
  `address_note` varchar(255) DEFAULT NULL,
  `is_default_shipping` tinyint(1) NOT NULL DEFAULT 0,
  `is_default_billing` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `customer_auth_tokens` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `token_type` enum('password_reset','email_verify','phone_verify') NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `customer_oauth_accounts` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `provider` enum('google','facebook') NOT NULL,
  `provider_user_id` varchar(191) NOT NULL,
  `provider_email` varchar(190) DEFAULT NULL,
  `provider_name` varchar(150) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `access_token_encrypted` text DEFAULT NULL,
  `refresh_token_encrypted` text DEFAULT NULL,
  `token_expires_at` datetime DEFAULT NULL,
  `linked_at` datetime NOT NULL DEFAULT current_timestamp(),
  `last_used_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `customer_security_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `event_type` varchar(50) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `meta_text` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `customer_sessions` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `session_token_hash` char(64) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `last_seen_at` datetime NOT NULL DEFAULT current_timestamp(),
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `inventory_movements` (
  `id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `variant_id` int(10) UNSIGNED DEFAULT NULL,
  `movement_type` enum('purchase','sale_reserve','sale_commit','sale_release','return_in','return_out','manual_adjustment') NOT NULL,
  `quantity_change` int(11) NOT NULL,
  `stock_after` int(11) DEFAULT NULL,
  `source_type` enum('order','admin','import','refund','system') DEFAULT NULL,
  `source_id` int(10) UNSIGNED DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_by_admin_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `orders` (
  `id` int(10) UNSIGNED NOT NULL,
  `order_code` varchar(30) NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `cart_id` int(10) UNSIGNED DEFAULT NULL,
  `checkout_type` enum('guest','account') NOT NULL,
  `purchase_channel` enum('web','zalo','admin') NOT NULL,
  `note` text DEFAULT NULL,
  `order_source` enum('product','cart','manual') NOT NULL DEFAULT 'product',
  `contact_name` varchar(150) NOT NULL,
  `contact_phone` varchar(20) NOT NULL,
  `contact_email` varchar(190) DEFAULT NULL,
  `customer_note` varchar(500) DEFAULT NULL,
  `internal_note` text DEFAULT NULL,
  `subtotal_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `shipping_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payment_plan` enum('full','deposit_30','zalo_manual') NOT NULL,
  `deposit_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `deposit_required_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `paid_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `remaining_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payment_status` enum('chua_thanh_toan','da_dat_coc','da_thanh_toan','cho_hoan_tien','da_hoan_tien') NOT NULL DEFAULT 'chua_thanh_toan',
  `order_status` enum('cho_xac_nhan','dang_chuan_bi','dang_giao','da_giao','da_huy','tra_hang') NOT NULL DEFAULT 'cho_xac_nhan',
  `guest_access_token` char(64) DEFAULT NULL,
  `placed_at` datetime NOT NULL DEFAULT current_timestamp(),
  `confirmed_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `cancel_reason` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `order_addresses` (
  `id` int(10) UNSIGNED NOT NULL,
  `order_id` int(10) UNSIGNED NOT NULL,
  `address_type` enum('shipping','billing') NOT NULL,
  `source_type` enum('manual','account_saved') NOT NULL,
  `source_address_id` int(10) UNSIGNED DEFAULT NULL,
  `receiver_name` varchar(150) NOT NULL,
  `receiver_phone` varchar(20) NOT NULL,
  `province_name` varchar(100) NOT NULL,
  `district_name` varchar(100) NOT NULL,
  `ward_name` varchar(100) NOT NULL,
  `address_line` varchar(255) NOT NULL,
  `address_note` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `order_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `order_id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `variant_id` int(10) UNSIGNED DEFAULT NULL,
  `product_name_snapshot` varchar(255) NOT NULL,
  `product_code_snapshot` varchar(100) NOT NULL,
  `sku_snapshot` varchar(120) DEFAULT NULL,
  `variant_name_snapshot` varchar(150) DEFAULT NULL,
  `size_snapshot` varchar(50) DEFAULT NULL,
  `color_snapshot` varchar(50) DEFAULT NULL,
  `thumbnail_snapshot` varchar(500) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `original_unit_price` decimal(12,2) NOT NULL,
  `final_unit_price` decimal(12,2) NOT NULL,
  `line_total` decimal(12,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `order_status_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `order_id` int(10) UNSIGNED NOT NULL,
  `from_status` varchar(30) DEFAULT NULL,
  `to_status` varchar(30) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `changed_by_type` enum('system','admin','customer','webhook') NOT NULL,
  `changed_by_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `payments` (
  `id` int(10) UNSIGNED NOT NULL,
  `payment_intent_id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `order_id` int(10) UNSIGNED DEFAULT NULL,
  `provider` enum('sepay','wallet','cod','manual') NOT NULL,
  `provider_transaction_id` varchar(100) NOT NULL,
  `provider_reference_code` varchar(100) DEFAULT NULL,
  `transfer_type` enum('in','out') DEFAULT NULL,
  `paid_amount` decimal(12,2) NOT NULL,
  `fee_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payment_status` enum('success','failed','pending','reversed') NOT NULL,
  `raw_content` varchar(500) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `raw_payload_text` longtext DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `payment_intents` (
  `id` int(10) UNSIGNED NOT NULL,
  `intent_code` varchar(40) NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `order_id` int(10) UNSIGNED DEFAULT NULL,
  `wallet_topup_request_id` int(10) UNSIGNED DEFAULT NULL,
  `provider` enum('sepay','wallet','cod','manual') NOT NULL,
  `purpose` enum('order_full','order_deposit','order_remaining','wallet_topup') NOT NULL,
  `requested_amount` decimal(12,2) NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'VND',
  `status` enum('pending','waiting_payment','paid','failed','expired','cancelled') NOT NULL DEFAULT 'pending',
  `qr_content` text DEFAULT NULL,
  `qr_image_url` varchar(500) DEFAULT NULL,
  `transfer_note` varchar(120) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `idempotency_key` varchar(100) DEFAULT NULL,
  `metadata_text` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `payment_webhook_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `provider` enum('sepay') NOT NULL,
  `event_key` varchar(150) NOT NULL,
  `provider_transaction_id` varchar(100) DEFAULT NULL,
  `request_headers_text` longtext DEFAULT NULL,
  `request_body_text` longtext NOT NULL,
  `parsed_amount` decimal(12,2) DEFAULT NULL,
  `parsed_reference_code` varchar(100) DEFAULT NULL,
  `parsed_transfer_type` varchar(20) DEFAULT NULL,
  `process_status` enum('received','ignored','processed','failed','duplicate') NOT NULL DEFAULT 'received',
  `linked_payment_id` int(10) UNSIGNED DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `products` (
  `id` int(10) UNSIGNED NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `slug` varchar(180) DEFAULT NULL,
  `product_code` varchar(100) NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `product_type_id` int(10) UNSIGNED NOT NULL,
  `style_id` int(10) UNSIGNED DEFAULT NULL,
  `gender` enum('Nam','Nữ','Unisex') NOT NULL DEFAULT 'Unisex',
  `original_price` decimal(12,2) NOT NULL DEFAULT 0.00,
  `sale_price` decimal(12,2) DEFAULT NULL,
  `purchase_price` decimal(12,2) DEFAULT NULL,
  `note` varchar(500) DEFAULT NULL,
  `material` varchar(255) DEFAULT NULL,
  `information` text DEFAULT NULL,
  `short_description` varchar(500) DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `track_inventory` tinyint(1) NOT NULL DEFAULT 1,
  `allow_backorder` tinyint(1) NOT NULL DEFAULT 0,
  `min_stock_alert` int(11) NOT NULL DEFAULT 0,
  `supplier_contact` varchar(255) DEFAULT NULL,
  `import_link` varchar(500) DEFAULT NULL,
  `thumbnail` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `published_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_hidden` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `product_conditions` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `product_condition_maps` (
  `product_id` int(10) UNSIGNED NOT NULL,
  `condition_id` int(10) UNSIGNED NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `product_images` (
  `id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `image_url` varchar(500) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `product_types` (
  `id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `product_variants` (
  `id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `sku` varchar(120) NOT NULL,
  `variant_name` varchar(150) DEFAULT NULL,
  `size_value` varchar(50) DEFAULT NULL,
  `color_value` varchar(50) DEFAULT NULL,
  `original_price` decimal(12,2) DEFAULT NULL,
  `sale_price` decimal(12,2) DEFAULT NULL,
  `purchase_price` decimal(12,2) DEFAULT NULL,
  `stock_qty` int(11) NOT NULL DEFAULT 0,
  `image_url` varchar(500) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `styles` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `wallet_accounts` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `status` enum('active','locked','disabled') NOT NULL DEFAULT 'active',
  `balance_cached` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_credited` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_debited` decimal(12,2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `wallet_ledger` (
  `id` int(10) UNSIGNED NOT NULL,
  `wallet_account_id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `entry_type` enum('topup_credit','order_debit','refund_credit','admin_adjustment','reversal') NOT NULL,
  `source_type` enum('wallet_topup','order','refund','admin') NOT NULL,
  `source_id` int(10) UNSIGNED NOT NULL,
  `amount_change` decimal(12,2) NOT NULL,
  `balance_before` decimal(12,2) NOT NULL,
  `balance_after` decimal(12,2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `related_payment_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `wallet_topup_requests` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `topup_code` varchar(40) NOT NULL,
  `requested_amount` decimal(12,2) NOT NULL,
  `status` enum('pending','waiting_payment','confirmed','expired','cancelled','failed') NOT NULL DEFAULT 'pending',
  `payment_intent_id` int(10) UNSIGNED DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Seed/master data
INSERT INTO `admins` (`id`, `username`, `password_hash`, `full_name`, `status`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'admin', '$2y$12$UVlOTrXu8r6UE0iwlrFp6usIvPbRlE7/uZA4klsEs3KZ/5AVxZmiO', 'Quản trị viên', 'active', '2026-03-18 21:00:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41');

INSERT INTO `app_settings` (`setting_key`, `setting_value`, `updated_at`) VALUES
('default_deposit_rate', '30', '2026-03-19 13:41:49'),
('enable_guest_checkout', '1', '2026-03-19 13:41:49'),
('enable_social_login_facebook', '1', '2026-03-19 13:41:49'),
('enable_social_login_google', '1', '2026-03-19 13:41:49'),
('enable_wallet', '1', '2026-03-19 13:41:49'),
('facebook_link', 'https://www.facebook.com/duongdangyeunhatthegioi', '2026-03-19 13:41:49'),
('instagram_link', 'https://www.instagram.com/giuong_tung/', '2026-03-19 13:41:49'),
('sepay_account_name', 'NGUYEN TUNG DUONG', '2026-03-19 13:41:49'),
('sepay_bank_account_no', 'VQRQAHSJJ1234', '2026-03-19 13:41:49'),
('sepay_bank_code', 'MBBank', '2026-03-19 13:41:49'),
('sepay_bank_name', 'MBBank', '2026-03-19 13:41:49'),
('sepay_expected_sub_account', 'VQRQAHSJJ1234', '2026-03-19 13:41:49'),
('sepay_webhook_api_key', '', '2026-03-19 13:41:49'),
('shop_address', 'Hà Nội', '2026-03-19 13:41:49'),
('shop_email', '', '2026-03-19 13:41:49'),
('shop_logo', 'img/logo.jpg', '2026-03-19 13:41:49'),
('shop_name', 'Duong Mot Mi', '2026-03-19 13:41:49'),
('shop_phone', '0961.691.107', '2026-03-19 13:41:49'),
('shop_tagline', 'Khám phá phong cách thời trang trẻ trung, hiện đại. Chúng tôi cam kết mang đến cho bạn những sản phẩm chất lượng với dịch vụ chốt đơn nhanh chóng, tận tâm.', '2026-03-19 13:41:49'),
('shop_working_hours', '08:00 - 22:00 (T2 - CN)', '2026-03-19 13:41:49'),
('tiktok_link', '', '2026-03-19 13:41:49'),
('zalo_contact_link', 'https://zalo.me/0961691107', '2026-03-19 13:41:49'),
('zalo_group_link', 'https://zalo.me/g/bjazlwfwqlsmruqdnxqr', '2026-03-19 13:41:49');

INSERT INTO `categories` (`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Áo', 'ao', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'Quần', 'quan', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'Giày', 'giay', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 'Túi xách', 'tui-xach', 4, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

INSERT INTO `product_conditions` (`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Hàng mới', 'hang-moi', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'Best seller', 'best-seller', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'Flash sale', 'flash-sale', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

INSERT INTO `product_types` (`id`, `category_id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Áo thun', 'ao-thun', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 1, 'Áo sơ mi', 'ao-so-mi', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 1, 'Áo khoác', 'ao-khoac', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 2, 'Quần jean', 'quan-jean', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(5, 2, 'Quần short', 'quan-short', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(6, 2, 'Chân váy', 'chan-vay', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(7, 3, 'Sneaker', 'sneaker', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(8, 3, 'Giày búp bê', 'giay-bup-be', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(9, 4, 'Túi tote', 'tui-tote', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(10, 4, 'Túi đeo chéo', 'tui-deo-cheo', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

INSERT INTO `styles` (`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Basic', 'basic', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'Streetwear', 'streetwear', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'Vintage', 'vintage', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 'Thanh lịch', 'thanh-lich', 4, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- Indexes, auto increment and foreign keys
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_admins_username` (`username`) USING BTREE,
  ADD KEY `idx_admins_status` (`status`) USING BTREE;

ALTER TABLE `admin_audit_logs`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_admin_audit_logs_admin_date` (`admin_id`,`created_at`) USING BTREE,
  ADD KEY `idx_admin_audit_logs_target` (`target_table`,`target_id`) USING BTREE;

ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`setting_key`) USING BTREE;

ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_carts_guest_token` (`guest_token`) USING BTREE,
  ADD KEY `idx_carts_customer_status` (`customer_id`,`status`) USING BTREE;

ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_cart_items_cart_variant` (`cart_id`,`variant_id`) USING BTREE,
  ADD KEY `idx_cart_items_product` (`product_id`) USING BTREE,
  ADD KEY `fk_cart_items_variant` (`variant_id`) USING BTREE;

ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_categories_slug` (`slug`) USING BTREE,
  ADD KEY `idx_categories_active_sort` (`is_active`,`sort_order`) USING BTREE;

ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_customers_customer_code` (`customer_code`) USING BTREE,
  ADD UNIQUE KEY `uq_customers_email` (`email`) USING BTREE,
  ADD UNIQUE KEY `uq_customers_phone` (`phone`) USING BTREE,
  ADD KEY `idx_customers_status` (`status`) USING BTREE,
  ADD KEY `idx_customers_created_at` (`created_at`) USING BTREE;

ALTER TABLE `customer_addresses`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_customer_addresses_customer_active` (`customer_id`,`is_active`) USING BTREE,
  ADD KEY `idx_customer_addresses_default_shipping` (`customer_id`,`is_default_shipping`) USING BTREE,
  ADD KEY `idx_customer_addresses_default_billing` (`customer_id`,`is_default_billing`) USING BTREE;

ALTER TABLE `customer_auth_tokens`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_customer_auth_tokens_hash` (`token_hash`) USING BTREE,
  ADD KEY `idx_customer_auth_tokens_customer_type` (`customer_id`,`token_type`) USING BTREE;

ALTER TABLE `customer_oauth_accounts`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_customer_oauth_provider_uid` (`provider`,`provider_user_id`) USING BTREE,
  ADD KEY `idx_customer_oauth_customer` (`customer_id`) USING BTREE;

ALTER TABLE `customer_security_logs`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_customer_security_logs_customer_date` (`customer_id`,`created_at`) USING BTREE,
  ADD KEY `idx_customer_security_logs_event_date` (`event_type`,`created_at`) USING BTREE;

ALTER TABLE `customer_sessions`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_customer_sessions_token` (`session_token_hash`) USING BTREE,
  ADD KEY `idx_customer_sessions_customer_expires` (`customer_id`,`expires_at`) USING BTREE;

ALTER TABLE `inventory_movements`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_inventory_movements_product_date` (`product_id`,`created_at`) USING BTREE,
  ADD KEY `idx_inventory_movements_variant_date` (`variant_id`,`created_at`) USING BTREE,
  ADD KEY `idx_inventory_movements_source` (`source_type`,`source_id`) USING BTREE,
  ADD KEY `fk_inventory_movements_admin` (`created_by_admin_id`) USING BTREE;

ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_orders_order_code` (`order_code`) USING BTREE,
  ADD UNIQUE KEY `uq_orders_guest_access_token` (`guest_access_token`) USING BTREE,
  ADD KEY `idx_orders_customer_date` (`customer_id`,`created_at`) USING BTREE,
  ADD KEY `idx_orders_statuses` (`order_status`,`payment_status`) USING BTREE,
  ADD KEY `idx_orders_channel_date` (`purchase_channel`,`created_at`) USING BTREE,
  ADD KEY `idx_orders_cart` (`cart_id`) USING BTREE;

ALTER TABLE `order_addresses`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_order_addresses_order_type` (`order_id`,`address_type`) USING BTREE,
  ADD KEY `idx_order_addresses_source` (`source_address_id`) USING BTREE;

ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_order_items_order` (`order_id`) USING BTREE,
  ADD KEY `idx_order_items_product` (`product_id`) USING BTREE,
  ADD KEY `idx_order_items_variant` (`variant_id`) USING BTREE;

ALTER TABLE `order_status_logs`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_order_status_logs_order_date` (`order_id`,`created_at`) USING BTREE;

ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_payments_provider_txn` (`provider`,`provider_transaction_id`) USING BTREE,
  ADD KEY `idx_payments_payment_intent` (`payment_intent_id`) USING BTREE,
  ADD KEY `idx_payments_order` (`order_id`) USING BTREE,
  ADD KEY `idx_payments_customer` (`customer_id`) USING BTREE;

ALTER TABLE `payment_intents`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_payment_intents_intent_code` (`intent_code`) USING BTREE,
  ADD UNIQUE KEY `uq_payment_intents_idempotency_key` (`idempotency_key`) USING BTREE,
  ADD KEY `idx_payment_intents_order_status` (`order_id`,`status`) USING BTREE,
  ADD KEY `idx_payment_intents_customer_status` (`customer_id`,`status`) USING BTREE;

ALTER TABLE `payment_webhook_logs`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_payment_webhook_logs_provider_event` (`provider`,`event_key`) USING BTREE,
  ADD KEY `idx_payment_webhook_logs_provider_txn` (`provider_transaction_id`) USING BTREE,
  ADD KEY `idx_payment_webhook_logs_status` (`process_status`) USING BTREE,
  ADD KEY `fk_payment_webhook_logs_payment` (`linked_payment_id`) USING BTREE;

ALTER TABLE `products`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_products_product_code` (`product_code`) USING BTREE,
  ADD UNIQUE KEY `uq_products_slug` (`slug`) USING BTREE,
  ADD KEY `idx_products_category_active` (`category_id`,`is_active`) USING BTREE,
  ADD KEY `idx_products_product_type_active` (`product_type_id`,`is_active`) USING BTREE,
  ADD KEY `idx_products_style_active` (`style_id`,`is_active`) USING BTREE,
  ADD KEY `idx_products_gender_active` (`gender`,`is_active`) USING BTREE;

ALTER TABLE `product_conditions`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_product_conditions_slug` (`slug`) USING BTREE,
  ADD KEY `idx_product_conditions_active_sort` (`is_active`,`sort_order`) USING BTREE;

ALTER TABLE `product_condition_maps`
  ADD PRIMARY KEY (`product_id`,`condition_id`) USING BTREE,
  ADD KEY `idx_product_condition_maps_condition` (`condition_id`) USING BTREE;

ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_product_images_product_sort` (`product_id`,`sort_order`) USING BTREE;

ALTER TABLE `product_types`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_product_types_slug` (`slug`) USING BTREE,
  ADD KEY `idx_product_types_category_active_sort` (`category_id`,`is_active`,`sort_order`) USING BTREE;

ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_product_variants_sku` (`sku`) USING BTREE,
  ADD KEY `idx_product_variants_product_active` (`product_id`,`is_active`) USING BTREE,
  ADD KEY `idx_product_variants_product_default` (`product_id`,`is_default`) USING BTREE;

ALTER TABLE `styles`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_styles_slug` (`slug`) USING BTREE,
  ADD KEY `idx_styles_active_sort` (`is_active`,`sort_order`) USING BTREE;

ALTER TABLE `wallet_accounts`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_wallet_accounts_customer` (`customer_id`) USING BTREE,
  ADD KEY `idx_wallet_accounts_status` (`status`) USING BTREE;

ALTER TABLE `wallet_ledger`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_wallet_ledger_wallet_date` (`wallet_account_id`,`created_at`) USING BTREE,
  ADD KEY `idx_wallet_ledger_customer_date` (`customer_id`,`created_at`) USING BTREE,
  ADD KEY `idx_wallet_ledger_source` (`source_type`,`source_id`) USING BTREE,
  ADD KEY `idx_wallet_ledger_payment` (`related_payment_id`) USING BTREE;

ALTER TABLE `wallet_topup_requests`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_wallet_topup_requests_topup_code` (`topup_code`) USING BTREE,
  ADD UNIQUE KEY `uq_wallet_topup_requests_payment_intent` (`payment_intent_id`) USING BTREE,
  ADD KEY `idx_wallet_topup_requests_customer_status` (`customer_id`,`status`) USING BTREE;

ALTER TABLE `admins`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `admin_audit_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `carts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `cart_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

ALTER TABLE `customers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `customer_addresses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `customer_auth_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `customer_oauth_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `customer_security_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `customer_sessions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `inventory_movements`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `orders`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `order_addresses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `order_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `order_status_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `payment_intents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `payment_webhook_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `product_conditions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

ALTER TABLE `product_images`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `product_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

ALTER TABLE `product_variants`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `styles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

ALTER TABLE `wallet_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `wallet_ledger`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `wallet_topup_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `admin_audit_logs`
  ADD CONSTRAINT `fk_admin_audit_logs_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `carts`
  ADD CONSTRAINT `fk_carts_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `cart_items`
  ADD CONSTRAINT `fk_cart_items_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cart_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cart_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON UPDATE CASCADE;

ALTER TABLE `customer_addresses`
  ADD CONSTRAINT `fk_customer_addresses_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `customer_auth_tokens`
  ADD CONSTRAINT `fk_customer_auth_tokens_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `customer_oauth_accounts`
  ADD CONSTRAINT `fk_customer_oauth_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `customer_security_logs`
  ADD CONSTRAINT `fk_customer_security_logs_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `customer_sessions`
  ADD CONSTRAINT `fk_customer_sessions_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `inventory_movements`
  ADD CONSTRAINT `fk_inventory_movements_admin` FOREIGN KEY (`created_by_admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_inventory_movements_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_inventory_movements_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `order_addresses`
  ADD CONSTRAINT `fk_order_addresses_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_addresses_source_address` FOREIGN KEY (`source_address_id`) REFERENCES `customer_addresses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `order_status_logs`
  ADD CONSTRAINT `fk_order_status_logs_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payments_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payments_payment_intent` FOREIGN KEY (`payment_intent_id`) REFERENCES `payment_intents` (`id`) ON UPDATE CASCADE;

ALTER TABLE `payment_intents`
  ADD CONSTRAINT `fk_payment_intents_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payment_intents_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `payment_webhook_logs`
  ADD CONSTRAINT `fk_payment_webhook_logs_payment` FOREIGN KEY (`linked_payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_product_type` FOREIGN KEY (`product_type_id`) REFERENCES `product_types` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_style` FOREIGN KEY (`style_id`) REFERENCES `styles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `product_condition_maps`
  ADD CONSTRAINT `fk_product_condition_maps_condition` FOREIGN KEY (`condition_id`) REFERENCES `product_conditions` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_product_condition_maps_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `product_images`
  ADD CONSTRAINT `fk_product_images_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `product_types`
  ADD CONSTRAINT `fk_product_types_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE CASCADE;

ALTER TABLE `product_variants`
  ADD CONSTRAINT `fk_product_variants_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `wallet_accounts`
  ADD CONSTRAINT `fk_wallet_accounts_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `wallet_ledger`
  ADD CONSTRAINT `fk_wallet_ledger_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_wallet_ledger_related_payment` FOREIGN KEY (`related_payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_wallet_ledger_wallet_account` FOREIGN KEY (`wallet_account_id`) REFERENCES `wallet_accounts` (`id`) ON UPDATE CASCADE;

ALTER TABLE `wallet_topup_requests`
  ADD CONSTRAINT `fk_wallet_topup_requests_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_wallet_topup_requests_payment_intent` FOREIGN KEY (`payment_intent_id`) REFERENCES `payment_intents` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
