-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th3 20, 2026 lúc 03:25 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `clothing_shop`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `admins`
--

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

--
-- Đang đổ dữ liệu cho bảng `admins`
--

INSERT INTO `admins` (`id`, `username`, `password_hash`, `full_name`, `status`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'admin', '$2y$12$UVlOTrXu8r6UE0iwlrFp6usIvPbRlE7/uZA4klsEs3KZ/5AVxZmiO', 'Quản trị viên', 'active', '2026-03-18 21:00:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `admin_audit_logs`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `app_settings`
--

CREATE TABLE `app_settings` (
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Đang đổ dữ liệu cho bảng `app_settings`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `carts`
--

CREATE TABLE `carts` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `guest_token` char(64) DEFAULT NULL,
  `status` enum('active','converted','abandoned') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `expired_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cart_items`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

CREATE TABLE `categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Áo', 'ao', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'Quần', 'quan', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'Giày', 'giay', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 'Túi xách', 'tui-xach', 4, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customers`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customer_addresses`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customer_auth_tokens`
--

CREATE TABLE `customer_auth_tokens` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `token_type` enum('password_reset','email_verify','phone_verify') NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customer_oauth_accounts`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customer_security_logs`
--

CREATE TABLE `customer_security_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `event_type` varchar(50) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `meta_text` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customer_sessions`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `inventory_movements`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

CREATE TABLE `orders` (
  `id` int(10) UNSIGNED NOT NULL,
  `order_code` varchar(30) NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `cart_id` int(10) UNSIGNED DEFAULT NULL,
  `checkout_type` enum('guest','account') NOT NULL,
  `purchase_channel` enum('web','zalo','admin') NOT NULL,
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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_addresses`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_items`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_status_logs`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `payments`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `payment_intents`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `payment_webhook_logs`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `products`
--

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

--
-- Đang đổ dữ liệu cho bảng `products`
--

INSERT INTO `products` (`id`, `product_name`, `slug`, `product_code`, `category_id`, `product_type_id`, `style_id`, `gender`, `original_price`, `sale_price`, `purchase_price`, `note`, `material`, `information`, `short_description`, `quantity`, `track_inventory`, `allow_backorder`, `min_stock_alert`, `supplier_contact`, `import_link`, `thumbnail`, `is_active`, `published_at`, `deleted_at`, `created_at`, `updated_at`, `is_hidden`) VALUES
(1, 'POLO  BURBERRY', 'polo-burberry-ao-001', 'AO_001', 1, 1, 1, 'Unisex', 340000.00, 269000.00, 190000.00, 'Đức buôn', 'Cotton, Mềm Mịn', 'Mô tả bán hàng\r\n\r\nPOLO BBR – BẢN MỚI NHẤT 2026\r\n\r\nHàng mới về cực đẹp cho anh em bán Tết 🔥\r\nThiết kế đơn giản – basic – sang xịn, dễ mặc, dễ phối đồ nên cực kỳ dễ bán.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nForm polo nam chuẩn đẹp\r\n\r\nTúi ngực da nổi bật tạo điểm nhấn sang trọng\r\n\r\nPhong cách basic nam tính, mặc đi chơi – đi làm đều hợp\r\n\r\nChất vải mềm mịn, thoáng mát, mặc cực thoải mái\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\nĐen\r\n\r\nXanh navy\r\n\r\nXanh rêu\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n⚜️ Phù hợp:\r\n✔ Đi chơi\r\n✔ Đi làm\r\n✔ Dạo phố\r\n✔ Mặc Tết cực đẹp\r\n\r\n🔥 Mẫu polo basic dễ bán – shop nào cũng nên có', 'Polo BBR bản mới 2026 – thiết kế basic sang trọng, dễ mặc dễ bán. Chất vải cao cấp, form chuẩn nam, phối túi da nổi bật cực trend.', 0, 1, 0, 0, 'Đức buôn', 'https://zalo.me/g/sscwqk872', 'uploads/img_69bacba61c3899.07412088.jpg', 1, '2026-03-18 15:58:30', NULL, '2026-03-18 15:58:30', '2026-03-20 09:24:24', 0),
(2, 'T-SHIRT LOUIS VUITTON FULL HOẠ TIẾT THÊU', 't-shirt-louis-vuitton-full-hoa-tiet-theu-ao-002', 'AO_002', 1, 1, 1, 'Nam', 425000.00, 299000.00, 225000.00, 'Đức buôn', 'Cotton, Mềm Mịn', '🔥 T-SHIRT LV – BẢN MỚI NHẤT 2026\r\n\r\nMẫu mới về cho anh em bán cực đẹp, form chuẩn – thêu full cao cấp nhìn rất sang.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo LV thêu nổi cao cấp trước ngực\r\n\r\nHọa tiết chữ Louis Vuitton thêu full sau lưng cực đẹp\r\n\r\nForm áo nam chuẩn, mặc đứng dáng\r\n\r\nChất vải cotton mềm, thoáng mát\r\n\r\n⚜️ Phong cách:\r\nBasic – nam tính – dễ phối đồ\r\nMặc đi chơi, đi làm, đi cafe đều đẹp.\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\nĐen\r\n\r\nXanh navy\r\n\r\nĐỏ đô\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nDạo phố\r\n\r\nĐi làm\r\n\r\nMặc hằng ngày\r\n\r\n🔥 Mẫu hot dễ bán – form đẹp – logo thêu sang', 'T-Shirt LV thêu full bản mới 2026 – thiết kế nam tính, form đẹp, chất vải cao cấp, logo thêu sắc nét cực sang.', 0, 1, 0, 0, 'Đức buôn', 'https://zalo.me/g/sscwqk872', 'uploads/img_69bace5f364be7.60575138.jpg', 1, '2026-03-18 16:10:07', NULL, '2026-03-18 16:10:07', '2026-03-20 09:24:24', 0),
(3, 'T-SHIRT LOUIS VUITTON FULL HOẠ TIẾT THÊU', 't-shirt-louis-vuitton-full-hoa-tiet-theu-ao-003', 'AO_003', 1, 1, 1, 'Nam', 410000.00, 279000.00, 205000.00, 'Đức buôn', NULL, '🔥 T-SHIRT LV – HÀNG MỚI 2026\r\n\r\nMẫu mới về cho anh em bán Tết cực đẹp\r\nThiết kế trông chiến – form chuẩn – dễ bán.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết thêu nổi cao cấp trước ngực\r\n\r\nPhong cách trẻ trung, cá tính\r\n\r\nForm áo nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải cotton mềm, thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nĐen\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi chơi\r\n\r\nĐi làm\r\n\r\nDạo phố\r\n\r\nMặc Tết cực đẹp\r\n\r\n🔥 Mẫu basic dễ bán – nhìn là chốt đơn', 'T-Shirt LOUIS VUITTON bản mới 2026 – thiết kế trẻ trung, họa tiết thêu nổi bật, form đẹp dễ bán dịp Tết.', 0, 1, 0, 0, 'Đức buôn', 'https://zalo.me/g/sscwqk872', 'uploads/img_69bacef3567289.66223327.jpg', 1, '2026-03-18 16:12:35', NULL, '2026-03-18 16:12:35', '2026-03-20 09:24:25', 0),
(4, 'SƠ MI BURBERRY TAG ĐÁ 2 BÊN', 'so-mi-burberry-tag-da-2-ben-ao-004', 'AO_004', 1, 2, 1, 'Nam', 420000.00, 299000.00, 220000.00, 'Nhà Xung Nga', 'Cotton, Mềm Mịn', '✨ SƠ MI BBR CAO CẤP\r\n\r\nĐi tiệc – đám cưới – sự kiện thì sơ mi trắng vẫn luôn là chân ái 😍\r\n\r\nMẫu Sơ Mi BBR mới nhất với thiết kế sang trọng, điểm nhấn đính đá ở cổ áo cực nổi bật và lịch lãm.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nForm sơ mi nam chuẩn đẹp\r\n\r\nCổ áo đính họa tiết đá sang trọng\r\n\r\nVải mềm mịn, mặc thoáng mát\r\n\r\nThiết kế thanh lịch, cực hợp đi tiệc\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n⚜️ Phù hợp:\r\n✔ Đi tiệc\r\n✔ Đi cưới\r\n✔ Đi làm\r\n✔ Sự kiện – gặp đối tác', 'Sơ Mi Burbbery cao cấp – thiết kế lịch lãm, form chuẩn nam, cổ áo đính họa tiết nổi bật, cực phù hợp mặc tiệc – cưới – sự kiện.', 0, 1, 0, 0, 'Nhà Xung Nga', 'https://zalo.me/g/isptip699', 'uploads/img_69bad0f899b036.13945093.jpg', 1, '2026-03-18 16:21:12', NULL, '2026-03-18 16:21:12', '2026-03-20 09:24:26', 0),
(5, 'SƠ MI Dolce & Gabbana', 'so-mi-dolce-gabbana-ao-005', 'AO_005', 1, 2, 3, 'Nam', 380000.00, 260000.00, 180000.00, 'Xung Nga', 'Cotton, Mềm Mịn', '✨ SƠ MI DOLCE & GABBANA – BẢN NEW\r\n\r\nMẫu sơ mi mới về cực đẹp cho anh em bán.\r\nThiết kế lịch lãm – sang trọng – chuẩn form nam, mặc đi làm hay đi tiệc đều rất hợp.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nLogo Dolce & Gabbana nổi bật ở cổ áo\r\n\r\nForm sơ mi nam đứng dáng\r\n\r\nChất vải mềm mịn, mặc thoáng mát\r\n\r\nThiết kế đơn giản nhưng cực sang\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi tiệc\r\n\r\nĐi sự kiện\r\n\r\nGặp đối tác', 'Sơ Mi Dolce & Gabbana bản new – thiết kế sang trọng, form chuẩn nam, điểm nhấn logo cổ áo cực nổi bật.', 0, 1, 0, 0, 'Xung Nga', 'https://zalo.me/g/isptip699', 'uploads/img_69bad1f28468b7.97462758.jpg', 1, '2026-03-18 16:25:22', NULL, '2026-03-18 16:25:22', '2026-03-20 09:24:27', 0),
(6, 'SƠ MI DIOR', 'so-mi-dior-ao-006', 'AO_006', 1, 2, 1, 'Nam', 420000.00, 299000.00, 220000.00, 'Xung Nga', 'Cotton, Mềm Mịn', 'SƠ MI DIOR CAO CẤP\r\n\r\nMẫu sơ mi mới về phục vụ mùa lễ – tiệc – Tết, thiết kế đơn giản nhưng cực kỳ sang và lịch lãm.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nTag ong Dior đính ở cổ áo tạo điểm nhấn cao cấp\r\n\r\nForm sơ mi nam chuẩn đẹp, mặc đứng dáng\r\n\r\nChất vải mềm mịn, thoáng mát\r\n\r\nPhong cách thanh lịch, dễ phối đồ\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi làm\r\n\r\nĐi tiệc\r\n\r\nĐi sự kiện\r\n\r\nMặc dịp lễ Tết', 'Sơ Mi Dior cao cấp – thiết kế thanh lịch, form chuẩn nam, cổ áo đính tag ong sang trọng.', 0, 1, 0, 0, 'Xung Nga', 'https://zalo.me/g/isptip699', 'uploads/img_69bad2c8c96680.21163453.jpg', 1, '2026-03-18 16:28:56', NULL, '2026-03-18 16:28:56', '2026-03-20 09:24:28', 0),
(7, 'SƠ MI MCQUEEN', 'so-mi-mcqueen-ao-007', 'AO_007', 1, 2, 1, 'Nam', 420000.00, 299000.00, 220000.00, 'Xung Nga', 'Cotton, Mềm Mịn', '✨ SƠ MI MCQ – HÀNG MỚI\r\n\r\nMẫu sơ mi mới cực đẹp dành cho anh em bán.\r\nThiết kế sang trọng – độc đáo – khác biệt, mặc lên rất nổi bật.\r\n\r\n⚜️ Điểm nổi bật:\r\n\r\nHọa tiết thêu nghệ thuật tinh xảo trước ngực\r\n\r\nPhong cách thời trang cao cấp, cá tính\r\n\r\nForm sơ mi nam chuẩn đẹp\r\n\r\nChất vải lụa cao cấp mềm mịn, mặc thoáng mát\r\n\r\n⚜️ Màu sắc:\r\n\r\nTrắng\r\n\r\n⚜️ Size:\r\nS / M / L / XL / XXL\r\n\r\n✔ Phù hợp:\r\n\r\nĐi tiệc\r\n\r\nĐi chơi\r\n\r\nSự kiện\r\n\r\nMặc dịp lễ Tết', 'Sơ Mi MCQ (McQueen) cao cấp – thiết kế họa tiết thêu tinh xảo, form chuẩn nam, phong cách sang trọng và nổi bật.', 0, 1, 0, 0, 'Xung Nga', 'https://zalo.me/g/isptip699', 'uploads/img_69bad37a4ef684.46263257.jpg', 1, '2026-03-18 16:31:54', NULL, '2026-03-18 16:31:54', '2026-03-20 09:24:29', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_conditions`
--

CREATE TABLE `product_conditions` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Đang đổ dữ liệu cho bảng `product_conditions`
--

INSERT INTO `product_conditions` (`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Hàng mới', 'hang-moi', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'Best seller', 'best-seller', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'Flash sale', 'flash-sale', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_condition_maps`
--

CREATE TABLE `product_condition_maps` (
  `product_id` int(10) UNSIGNED NOT NULL,
  `condition_id` int(10) UNSIGNED NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_images`
--

CREATE TABLE `product_images` (
  `id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `image_url` varchar(500) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_types`
--

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

--
-- Đang đổ dữ liệu cho bảng `product_types`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_variants`
--

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

--
-- Đang đổ dữ liệu cho bảng `product_variants`
--

INSERT INTO `product_variants` (`id`, `product_id`, `sku`, `variant_name`, `size_value`, `color_value`, `original_price`, `sale_price`, `purchase_price`, `stock_qty`, `image_url`, `is_default`, `is_active`, `created_at`, `updated_at`) VALUES
(27, 1, 'AO001-DEN-S', 'Đen / S', 'S', 'Đen', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 1, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(28, 1, 'AO001-DEN-M', 'Đen / M', 'M', 'Đen', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(29, 1, 'AO001-DEN-L', 'Đen / L', 'L', 'Đen', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(30, 1, 'AO001-DEN-XL', 'Đen / XL', 'XL', 'Đen', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(31, 1, 'AO001-TRANG-S', 'Trắng / S', 'S', 'Trắng', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(32, 1, 'AO001-TRANG-M', 'Trắng / M', 'M', 'Trắng', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(33, 1, 'AO001-TRANG-L', 'Trắng / L', 'L', 'Trắng', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(34, 1, 'AO001-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(35, 1, 'AO001-XANHREU-S', 'Xanh Rêu / S', 'S', 'Xanh Rêu', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(36, 1, 'AO001-XANHREU-M', 'Xanh Rêu / M', 'M', 'Xanh Rêu', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(37, 1, 'AO001-XANHREU-L', 'Xanh Rêu / L', 'L', 'Xanh Rêu', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(38, 1, 'AO001-XANHREU-XL', 'Xanh Rêu / XL', 'XL', 'Xanh Rêu', 340000.00, 269000.00, 190000.00, 0, 'uploads/img_69bacba61c3899.07412088.jpg', 0, 1, '2026-03-18 15:58:30', '2026-03-18 16:21:45'),
(39, 2, 'AO002-DEN-S', 'Đen / S', 'S', 'Đen', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 1, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(40, 2, 'AO002-DEN-M', 'Đen / M', 'M', 'Đen', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(41, 2, 'AO002-DEN-L', 'Đen / L', 'L', 'Đen', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(42, 2, 'AO002-DEN-XL', 'Đen / XL', 'XL', 'Đen', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(43, 2, 'AO002-TRANG-S', 'Trắng / S', 'S', 'Trắng', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(44, 2, 'AO002-TRANG-M', 'Trắng / M', 'M', 'Trắng', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(45, 2, 'AO002-TRANG-L', 'Trắng / L', 'L', 'Trắng', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(46, 2, 'AO002-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(47, 2, 'AO002-XANHNAVY-S', 'Xanh Navy / S', 'S', 'Xanh Navy', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(48, 2, 'AO002-XANHNAVY-M', 'Xanh Navy / M', 'M', 'Xanh Navy', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(49, 2, 'AO002-XANHNAVY-L', 'Xanh Navy / L', 'L', 'Xanh Navy', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(50, 2, 'AO002-XANHNAVY-XL', 'Xanh Navy / XL', 'XL', 'Xanh Navy', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(51, 2, 'AO002-DOMAN-S', 'Đỏ Mận / S', 'S', 'Đỏ Mận', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(52, 2, 'AO002-DOMAN-M', 'Đỏ Mận / M', 'M', 'Đỏ Mận', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(53, 2, 'AO002-DOMAN-L', 'Đỏ Mận / L', 'L', 'Đỏ Mận', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(54, 2, 'AO002-DOMAN-XL', 'Đỏ Mận / XL', 'XL', 'Đỏ Mận', 425000.00, 299000.00, 225000.00, 0, 'uploads/img_69bace5f364be7.60575138.jpg', 0, 1, '2026-03-18 16:10:07', '2026-03-18 16:21:36'),
(55, 3, 'AO003-DEN-S', 'Đen / S', 'S', 'Đen', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 1, 1, '2026-03-18 16:12:35', '2026-03-18 16:21:26'),
(56, 3, 'AO003-DEN-M', 'Đen / M', 'M', 'Đen', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-18 16:21:26'),
(57, 3, 'AO003-DEN-L', 'Đen / L', 'L', 'Đen', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-18 16:21:26'),
(58, 3, 'AO003-DEN-XL', 'Đen / XL', 'XL', 'Đen', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-18 16:21:26'),
(59, 3, 'AO003-TRANG-S', 'Trắng / S', 'S', 'Trắng', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-18 16:21:26'),
(60, 3, 'AO003-TRANG-M', 'Trắng / M', 'M', 'Trắng', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-18 16:21:26'),
(61, 3, 'AO003-TRANG-L', 'Trắng / L', 'L', 'Trắng', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-18 16:21:26'),
(62, 3, 'AO003-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 410000.00, 279000.00, 205000.00, 0, 'uploads/img_69bacef3567289.66223327.jpg', 0, 1, '2026-03-18 16:12:35', '2026-03-18 16:21:26'),
(63, 4, 'AO004-TRANG-S', 'Trắng / S', 'S', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 1, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12'),
(64, 4, 'AO004-TRANG-M', 'Trắng / M', 'M', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 0, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12'),
(65, 4, 'AO004-TRANG-L', 'Trắng / L', 'L', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 0, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12'),
(66, 4, 'AO004-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 0, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12'),
(67, 4, 'AO004-TRANG-XXL', 'Trắng / XXL', 'XXL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad0f899b036.13945093.jpg', 0, 1, '2026-03-18 16:21:12', '2026-03-18 16:21:12'),
(68, 5, 'AO005-TRANG-S', 'Trắng / S', 'S', 'Trắng', 380000.00, 260000.00, 180000.00, 0, 'uploads/img_69bad1f28468b7.97462758.jpg', 1, 1, '2026-03-18 16:25:22', '2026-03-18 16:25:22'),
(69, 5, 'AO005-TRANG-M', 'Trắng / M', 'M', 'Trắng', 380000.00, 260000.00, 180000.00, 0, 'uploads/img_69bad1f28468b7.97462758.jpg', 0, 1, '2026-03-18 16:25:22', '2026-03-18 16:25:22'),
(70, 5, 'AO005-TRANG-L', 'Trắng / L', 'L', 'Trắng', 380000.00, 260000.00, 180000.00, 0, 'uploads/img_69bad1f28468b7.97462758.jpg', 0, 1, '2026-03-18 16:25:22', '2026-03-18 16:25:22'),
(71, 5, 'AO005-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 380000.00, 260000.00, 180000.00, 0, 'uploads/img_69bad1f28468b7.97462758.jpg', 0, 1, '2026-03-18 16:25:22', '2026-03-18 16:25:22'),
(72, 6, 'AO006-TRANG-S', 'Trắng / S', 'S', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 1, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10'),
(73, 6, 'AO006-TRANG-M', 'Trắng / M', 'M', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 0, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10'),
(74, 6, 'AO006-TRANG-L', 'Trắng / L', 'L', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 0, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10'),
(75, 6, 'AO006-TRANG-XL', 'Trắng / XL', 'XL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 0, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10'),
(76, 6, 'AO006-TRANG-XXL', 'Trắng / XXL', 'XXL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad2c8c96680.21163453.jpg', 0, 1, '2026-03-18 16:28:56', '2026-03-18 16:29:10'),
(77, 7, 'AO007-TRANG-S', 'Trắng / S', 'S', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad37a4ef684.46263257.jpg', 1, 1, '2026-03-18 16:31:54', '2026-03-19 01:18:07'),
(78, 7, 'AO007-TRANG-M', 'Trắng / M', 'M', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad37a4ef684.46263257.jpg', 0, 1, '2026-03-18 16:31:54', '2026-03-19 01:18:07'),
(79, 7, 'AO007-TRANG-L', 'Trắng / L', 'L', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad37a4ef684.46263257.jpg', 0, 1, '2026-03-18 16:31:54', '2026-03-19 01:18:07'),
(80, 7, 'AO007-TRANG-XXL', 'Trắng / XXL', 'XXL', 'Trắng', 420000.00, 299000.00, 220000.00, 0, 'uploads/img_69bad37a4ef684.46263257.jpg', 0, 1, '2026-03-18 16:31:54', '2026-03-19 01:18:07');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `styles`
--

CREATE TABLE `styles` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Đang đổ dữ liệu cho bảng `styles`
--

INSERT INTO `styles` (`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Basic', 'basic', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'Streetwear', 'streetwear', 2, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'Vintage', 'vintage', 3, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 'Thanh lịch', 'thanh-lich', 4, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallet_accounts`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallet_ledger`
--

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallet_topup_requests`
--

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

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_admins_username` (`username`) USING BTREE,
  ADD KEY `idx_admins_status` (`status`) USING BTREE;

--
-- Chỉ mục cho bảng `admin_audit_logs`
--
ALTER TABLE `admin_audit_logs`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_admin_audit_logs_admin_date` (`admin_id`,`created_at`) USING BTREE,
  ADD KEY `idx_admin_audit_logs_target` (`target_table`,`target_id`) USING BTREE;

--
-- Chỉ mục cho bảng `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`setting_key`) USING BTREE;

--
-- Chỉ mục cho bảng `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_carts_guest_token` (`guest_token`) USING BTREE,
  ADD KEY `idx_carts_customer_status` (`customer_id`,`status`) USING BTREE;

--
-- Chỉ mục cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_cart_items_cart_variant` (`cart_id`,`variant_id`) USING BTREE,
  ADD KEY `idx_cart_items_product` (`product_id`) USING BTREE,
  ADD KEY `fk_cart_items_variant` (`variant_id`) USING BTREE;

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_categories_slug` (`slug`) USING BTREE,
  ADD KEY `idx_categories_active_sort` (`is_active`,`sort_order`) USING BTREE;

--
-- Chỉ mục cho bảng `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_customers_customer_code` (`customer_code`) USING BTREE,
  ADD UNIQUE KEY `uq_customers_email` (`email`) USING BTREE,
  ADD UNIQUE KEY `uq_customers_phone` (`phone`) USING BTREE,
  ADD KEY `idx_customers_status` (`status`) USING BTREE,
  ADD KEY `idx_customers_created_at` (`created_at`) USING BTREE;

--
-- Chỉ mục cho bảng `customer_addresses`
--
ALTER TABLE `customer_addresses`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_customer_addresses_customer_active` (`customer_id`,`is_active`) USING BTREE,
  ADD KEY `idx_customer_addresses_default_shipping` (`customer_id`,`is_default_shipping`) USING BTREE,
  ADD KEY `idx_customer_addresses_default_billing` (`customer_id`,`is_default_billing`) USING BTREE;

--
-- Chỉ mục cho bảng `customer_auth_tokens`
--
ALTER TABLE `customer_auth_tokens`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_customer_auth_tokens_hash` (`token_hash`) USING BTREE,
  ADD KEY `idx_customer_auth_tokens_customer_type` (`customer_id`,`token_type`) USING BTREE;

--
-- Chỉ mục cho bảng `customer_oauth_accounts`
--
ALTER TABLE `customer_oauth_accounts`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_customer_oauth_provider_uid` (`provider`,`provider_user_id`) USING BTREE,
  ADD KEY `idx_customer_oauth_customer` (`customer_id`) USING BTREE;

--
-- Chỉ mục cho bảng `customer_security_logs`
--
ALTER TABLE `customer_security_logs`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_customer_security_logs_customer_date` (`customer_id`,`created_at`) USING BTREE,
  ADD KEY `idx_customer_security_logs_event_date` (`event_type`,`created_at`) USING BTREE;

--
-- Chỉ mục cho bảng `customer_sessions`
--
ALTER TABLE `customer_sessions`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_customer_sessions_token` (`session_token_hash`) USING BTREE,
  ADD KEY `idx_customer_sessions_customer_expires` (`customer_id`,`expires_at`) USING BTREE;

--
-- Chỉ mục cho bảng `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_inventory_movements_product_date` (`product_id`,`created_at`) USING BTREE,
  ADD KEY `idx_inventory_movements_variant_date` (`variant_id`,`created_at`) USING BTREE,
  ADD KEY `idx_inventory_movements_source` (`source_type`,`source_id`) USING BTREE,
  ADD KEY `fk_inventory_movements_admin` (`created_by_admin_id`) USING BTREE;

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_orders_order_code` (`order_code`) USING BTREE,
  ADD UNIQUE KEY `uq_orders_guest_access_token` (`guest_access_token`) USING BTREE,
  ADD KEY `idx_orders_customer_date` (`customer_id`,`created_at`) USING BTREE,
  ADD KEY `idx_orders_statuses` (`order_status`,`payment_status`) USING BTREE,
  ADD KEY `idx_orders_channel_date` (`purchase_channel`,`created_at`) USING BTREE,
  ADD KEY `idx_orders_cart` (`cart_id`) USING BTREE;

--
-- Chỉ mục cho bảng `order_addresses`
--
ALTER TABLE `order_addresses`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_order_addresses_order_type` (`order_id`,`address_type`) USING BTREE,
  ADD KEY `idx_order_addresses_source` (`source_address_id`) USING BTREE;

--
-- Chỉ mục cho bảng `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_order_items_order` (`order_id`) USING BTREE,
  ADD KEY `idx_order_items_product` (`product_id`) USING BTREE,
  ADD KEY `idx_order_items_variant` (`variant_id`) USING BTREE;

--
-- Chỉ mục cho bảng `order_status_logs`
--
ALTER TABLE `order_status_logs`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_order_status_logs_order_date` (`order_id`,`created_at`) USING BTREE;

--
-- Chỉ mục cho bảng `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_payments_provider_txn` (`provider`,`provider_transaction_id`) USING BTREE,
  ADD KEY `idx_payments_payment_intent` (`payment_intent_id`) USING BTREE,
  ADD KEY `idx_payments_order` (`order_id`) USING BTREE,
  ADD KEY `idx_payments_customer` (`customer_id`) USING BTREE;

--
-- Chỉ mục cho bảng `payment_intents`
--
ALTER TABLE `payment_intents`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_payment_intents_intent_code` (`intent_code`) USING BTREE,
  ADD UNIQUE KEY `uq_payment_intents_idempotency_key` (`idempotency_key`) USING BTREE,
  ADD KEY `idx_payment_intents_order_status` (`order_id`,`status`) USING BTREE,
  ADD KEY `idx_payment_intents_customer_status` (`customer_id`,`status`) USING BTREE;

--
-- Chỉ mục cho bảng `payment_webhook_logs`
--
ALTER TABLE `payment_webhook_logs`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_payment_webhook_logs_provider_event` (`provider`,`event_key`) USING BTREE,
  ADD KEY `idx_payment_webhook_logs_provider_txn` (`provider_transaction_id`) USING BTREE,
  ADD KEY `idx_payment_webhook_logs_status` (`process_status`) USING BTREE,
  ADD KEY `fk_payment_webhook_logs_payment` (`linked_payment_id`) USING BTREE;

--
-- Chỉ mục cho bảng `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_products_product_code` (`product_code`) USING BTREE,
  ADD UNIQUE KEY `uq_products_slug` (`slug`) USING BTREE,
  ADD KEY `idx_products_category_active` (`category_id`,`is_active`) USING BTREE,
  ADD KEY `idx_products_product_type_active` (`product_type_id`,`is_active`) USING BTREE,
  ADD KEY `idx_products_style_active` (`style_id`,`is_active`) USING BTREE,
  ADD KEY `idx_products_gender_active` (`gender`,`is_active`) USING BTREE;

--
-- Chỉ mục cho bảng `product_conditions`
--
ALTER TABLE `product_conditions`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_product_conditions_slug` (`slug`) USING BTREE,
  ADD KEY `idx_product_conditions_active_sort` (`is_active`,`sort_order`) USING BTREE;

--
-- Chỉ mục cho bảng `product_condition_maps`
--
ALTER TABLE `product_condition_maps`
  ADD PRIMARY KEY (`product_id`,`condition_id`) USING BTREE,
  ADD KEY `idx_product_condition_maps_condition` (`condition_id`) USING BTREE;

--
-- Chỉ mục cho bảng `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_product_images_product_sort` (`product_id`,`sort_order`) USING BTREE;

--
-- Chỉ mục cho bảng `product_types`
--
ALTER TABLE `product_types`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_product_types_slug` (`slug`) USING BTREE,
  ADD KEY `idx_product_types_category_active_sort` (`category_id`,`is_active`,`sort_order`) USING BTREE;

--
-- Chỉ mục cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_product_variants_sku` (`sku`) USING BTREE,
  ADD KEY `idx_product_variants_product_active` (`product_id`,`is_active`) USING BTREE,
  ADD KEY `idx_product_variants_product_default` (`product_id`,`is_default`) USING BTREE;

--
-- Chỉ mục cho bảng `styles`
--
ALTER TABLE `styles`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_styles_slug` (`slug`) USING BTREE,
  ADD KEY `idx_styles_active_sort` (`is_active`,`sort_order`) USING BTREE;

--
-- Chỉ mục cho bảng `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_wallet_accounts_customer` (`customer_id`) USING BTREE,
  ADD KEY `idx_wallet_accounts_status` (`status`) USING BTREE;

--
-- Chỉ mục cho bảng `wallet_ledger`
--
ALTER TABLE `wallet_ledger`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_wallet_ledger_wallet_date` (`wallet_account_id`,`created_at`) USING BTREE,
  ADD KEY `idx_wallet_ledger_customer_date` (`customer_id`,`created_at`) USING BTREE,
  ADD KEY `idx_wallet_ledger_source` (`source_type`,`source_id`) USING BTREE,
  ADD KEY `idx_wallet_ledger_payment` (`related_payment_id`) USING BTREE;

--
-- Chỉ mục cho bảng `wallet_topup_requests`
--
ALTER TABLE `wallet_topup_requests`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_wallet_topup_requests_topup_code` (`topup_code`) USING BTREE,
  ADD UNIQUE KEY `uq_wallet_topup_requests_payment_intent` (`payment_intent_id`) USING BTREE,
  ADD KEY `idx_wallet_topup_requests_customer_status` (`customer_id`,`status`) USING BTREE;

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `admin_audit_logs`
--
ALTER TABLE `admin_audit_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `carts`
--
ALTER TABLE `carts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `customer_addresses`
--
ALTER TABLE `customer_addresses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `customer_auth_tokens`
--
ALTER TABLE `customer_auth_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `customer_oauth_accounts`
--
ALTER TABLE `customer_oauth_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `customer_security_logs`
--
ALTER TABLE `customer_security_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `customer_sessions`
--
ALTER TABLE `customer_sessions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `inventory_movements`
--
ALTER TABLE `inventory_movements`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `order_addresses`
--
ALTER TABLE `order_addresses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `order_status_logs`
--
ALTER TABLE `order_status_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `payment_intents`
--
ALTER TABLE `payment_intents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `payment_webhook_logs`
--
ALTER TABLE `payment_webhook_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `product_conditions`
--
ALTER TABLE `product_conditions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `product_types`
--
ALTER TABLE `product_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT cho bảng `styles`
--
ALTER TABLE `styles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `wallet_ledger`
--
ALTER TABLE `wallet_ledger`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `wallet_topup_requests`
--
ALTER TABLE `wallet_topup_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `admin_audit_logs`
--
ALTER TABLE `admin_audit_logs`
  ADD CONSTRAINT `fk_admin_audit_logs_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `fk_carts_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `fk_cart_items_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cart_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cart_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `customer_addresses`
--
ALTER TABLE `customer_addresses`
  ADD CONSTRAINT `fk_customer_addresses_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `customer_auth_tokens`
--
ALTER TABLE `customer_auth_tokens`
  ADD CONSTRAINT `fk_customer_auth_tokens_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `customer_oauth_accounts`
--
ALTER TABLE `customer_oauth_accounts`
  ADD CONSTRAINT `fk_customer_oauth_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `customer_security_logs`
--
ALTER TABLE `customer_security_logs`
  ADD CONSTRAINT `fk_customer_security_logs_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `customer_sessions`
--
ALTER TABLE `customer_sessions`
  ADD CONSTRAINT `fk_customer_sessions_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD CONSTRAINT `fk_inventory_movements_admin` FOREIGN KEY (`created_by_admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_inventory_movements_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_inventory_movements_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `order_addresses`
--
ALTER TABLE `order_addresses`
  ADD CONSTRAINT `fk_order_addresses_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_addresses_source_address` FOREIGN KEY (`source_address_id`) REFERENCES `customer_addresses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `order_status_logs`
--
ALTER TABLE `order_status_logs`
  ADD CONSTRAINT `fk_order_status_logs_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payments_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payments_payment_intent` FOREIGN KEY (`payment_intent_id`) REFERENCES `payment_intents` (`id`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `payment_intents`
--
ALTER TABLE `payment_intents`
  ADD CONSTRAINT `fk_payment_intents_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payment_intents_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `payment_webhook_logs`
--
ALTER TABLE `payment_webhook_logs`
  ADD CONSTRAINT `fk_payment_webhook_logs_payment` FOREIGN KEY (`linked_payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_product_type` FOREIGN KEY (`product_type_id`) REFERENCES `product_types` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_style` FOREIGN KEY (`style_id`) REFERENCES `styles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `product_condition_maps`
--
ALTER TABLE `product_condition_maps`
  ADD CONSTRAINT `fk_product_condition_maps_condition` FOREIGN KEY (`condition_id`) REFERENCES `product_conditions` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_product_condition_maps_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `fk_product_images_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `product_types`
--
ALTER TABLE `product_types`
  ADD CONSTRAINT `fk_product_types_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `fk_product_variants_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  ADD CONSTRAINT `fk_wallet_accounts_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `wallet_ledger`
--
ALTER TABLE `wallet_ledger`
  ADD CONSTRAINT `fk_wallet_ledger_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_wallet_ledger_related_payment` FOREIGN KEY (`related_payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_wallet_ledger_wallet_account` FOREIGN KEY (`wallet_account_id`) REFERENCES `wallet_accounts` (`id`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `wallet_topup_requests`
--
ALTER TABLE `wallet_topup_requests`
  ADD CONSTRAINT `fk_wallet_topup_requests_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_wallet_topup_requests_payment_intent` FOREIGN KEY (`payment_intent_id`) REFERENCES `payment_intents` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
