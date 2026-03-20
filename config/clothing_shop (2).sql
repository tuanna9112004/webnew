-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th3 19, 2026 lúc 11:40 AM
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

--
-- Đang đổ dữ liệu cho bảng `admin_audit_logs`
--

INSERT INTO `admin_audit_logs` (`id`, `admin_id`, `action`, `target_table`, `target_id`, `before_data_text`, `after_data_text`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1, 'create_product', 'products', 6, NULL, '{\"product_code\":\"TUI_001\",\"product_name\":\"Túi tote canvas mini\"}', '127.0.0.1', 'Mozilla/5.0 Admin', '2026-03-19 13:16:41'),
(2, 1, 'update_order', 'orders', 2, '{\"payment_status\":\"unpaid\"}', '{\"payment_status\":\"deposit_paid\"}', '127.0.0.1', 'Mozilla/5.0 Admin', '2026-03-19 13:16:41'),
(3, 1, 'manual_wallet_adjustment', 'wallet_accounts', 1, '{\"balance_cached\":500000}', '{\"balance_cached\":350000}', '127.0.0.1', 'Mozilla/5.0 Admin', '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `carts`
--

INSERT INTO `carts` (`id`, `customer_id`, `guest_token`, `status`, `created_at`, `updated_at`, `expired_at`) VALUES
(1, 1, NULL, 'active', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-26 13:16:41'),
(2, NULL, 'd7ccbec5b3eae46c605aaa2778ccd1d1fa329fa8d8c7dddaccad9ce4c5fe3100', 'active', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-21 13:16:41'),
(3, NULL, '1c309039ecd10b2b99b35d32e0e0f4a546804c4420c24f94', 'converted', '2026-03-19 13:17:09', '2026-03-19 13:17:42', NULL),
(4, NULL, '9b567640d8445332366271abc378e2665d0fdcf935e1be94', 'converted', '2026-03-19 13:21:37', '2026-03-19 13:21:57', NULL),
(5, 4, NULL, 'converted', '2026-03-19 13:39:19', '2026-03-19 13:39:36', NULL),
(6, 4, NULL, 'converted', '2026-03-19 14:15:28', '2026-03-19 14:15:44', NULL),
(7, NULL, '9cc555c9bb2273a0bb71a1d16b789c356c002fa239c2b4da', 'active', '2026-03-19 14:40:28', '2026-03-19 14:40:28', NULL),
(8, NULL, 'a84a899ee7188c998fd2260047534d2588ef001f15cddd54', 'converted', '2026-03-19 16:43:02', '2026-03-19 16:43:19', NULL),
(9, 4, NULL, 'converted', '2026-03-19 17:32:20', '2026-03-19 17:32:43', NULL);

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

--
-- Đang đổ dữ liệu cho bảng `cart_items`
--

INSERT INTO `cart_items` (`id`, `cart_id`, `product_id`, `variant_id`, `quantity`, `unit_price_snapshot`, `sale_price_snapshot`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 5, 2, 120000.00, 99000.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 1, 6, 25, 1, 210000.00, 179000.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 2, 3, 15, 1, 320000.00, 289000.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 3, 6, 26, 1, 179000.00, 179000.00, '2026-03-19 13:17:21', '2026-03-19 13:17:21'),
(5, 4, 4, 19, 1, 315000.00, 315000.00, '2026-03-19 13:21:37', '2026-03-19 13:21:37'),
(6, 5, 5, 21, 1, 520000.00, 520000.00, '2026-03-19 13:39:19', '2026-03-19 13:39:19'),
(7, 6, 1, 11, 1, 99000.00, 99000.00, '2026-03-19 14:15:28', '2026-03-19 14:15:28'),
(8, 8, 4, 18, 1, 315000.00, 315000.00, '2026-03-19 16:43:02', '2026-03-19 16:43:02'),
(9, 9, 3, 15, 1, 289000.00, 289000.00, '2026-03-19 17:32:25', '2026-03-19 17:32:25');

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

--
-- Đang đổ dữ liệu cho bảng `customers`
--

INSERT INTO `customers` (`id`, `customer_code`, `full_name`, `email`, `phone`, `password_hash`, `avatar_url`, `birth_date`, `gender`, `status`, `registered_via`, `email_verified_at`, `phone_verified_at`, `last_login_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'CUS0001', 'Nguyễn Thị Linh', 'linh@example.com', '0901234567', '$2y$12$0gWqytWtQW9yx1zcx9SpWOfUnzMhWDgZ2k85SzcoudJkaZyF6oMWm', '/uploads/avatars/linh.jpg', '1998-05-12', 'Nữ', 'active', 'local', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-18 20:00:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41', NULL),
(2, 'CUS0002', 'Trần Hoàng Nam', 'nam@example.com', '0912345678', '$2y$12$0gWqytWtQW9yx1zcx9SpWOfUnzMhWDgZ2k85SzcoudJkaZyF6oMWm', '/uploads/avatars/nam.jpg', '1996-10-21', 'Nam', 'active', 'local', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-18 22:00:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41', NULL),
(3, 'CUS0003', 'Lê Minh Anh', 'minhanh@example.com', '0988765432', NULL, '/uploads/avatars/minhanh.jpg', '2000-03-07', 'Nữ', 'active', 'google', '2026-03-19 13:16:41', '2026-03-19 13:16:41', '2026-03-17 19:30:00', '2026-03-19 13:16:41', '2026-03-19 13:16:41', NULL),
(4, 'CUS000004', 'Anh Tuấn', 'tuanna9112004@gmail.com', '0876726201', '$2y$10$ucqAqsOZ.ZtWkMlzlsQNDu4BDuk5wURaJHs4nBrCyY4cTLr4Jjto.', NULL, NULL, NULL, 'active', 'local', NULL, NULL, '2026-03-19 17:30:54', '2026-03-19 13:22:39', '2026-03-19 17:30:54', NULL),
(5, 'CUS000005', 'Anh Tuấn', 'nguyngialam1101@gmail.com', '0876726202', '$2y$10$HTEskQs11/hK08PcknwfM.X52suLShDC95kW/FweLnefl0dml9hiS', NULL, NULL, NULL, 'active', 'local', NULL, NULL, '2026-03-19 14:17:14', '2026-03-19 14:17:14', '2026-03-19 14:17:14', NULL),
(6, 'CUS000006', 'Anh Tuấn', 'nguyenanhtuan4831@gmail.com', '012345678', '$2y$10$xu.D7imcCPDoYNS3KsJaOOUyNOBEKg2M4mrKYZXRoL/rdFhmekkcu', NULL, NULL, NULL, 'active', 'local', NULL, NULL, '2026-03-19 14:17:51', '2026-03-19 14:17:51', '2026-03-19 14:17:51', NULL);

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

--
-- Đang đổ dữ liệu cho bảng `customer_addresses`
--

INSERT INTO `customer_addresses` (`id`, `customer_id`, `label`, `receiver_name`, `receiver_phone`, `province_code`, `province_name`, `district_code`, `district_name`, `ward_code`, `ward_name`, `address_line`, `address_note`, `is_default_shipping`, `is_default_billing`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Nhà riêng', 'Nguyễn Thị Linh', '0901234567', '79', 'TP. Hồ Chí Minh', '760', 'Quận 1', '26734', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', 1, 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 1, 'Công ty', 'Nguyễn Thị Linh', '0901234567', '79', 'TP. Hồ Chí Minh', '769', 'Quận 7', '27160', 'Phường Tân Phú', '25 Nguyễn Lương Bằng', 'Giao giờ hành chính', 0, 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 2, 'Nhà riêng', 'Trần Hoàng Nam', '0912345678', '79', 'TP. Hồ Chí Minh', '770', 'Quận Bình Thạnh', '27433', 'Phường 25', '88 D5', 'Gọi trước khi giao', 1, 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 3, 'Nhà riêng', 'Lê Minh Anh', '0988765432', '48', 'Đà Nẵng', '490', 'Quận Hải Châu', '20194', 'Phường Thạch Thang', '56 Trần Phú', 'Nhận hàng buổi chiều', 1, 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(5, 4, 'nhà riêng', 'Anh Tuấn', '0876726201', NULL, 'Tỉnh Vĩnh Phúc', NULL, 'Huyện Sông Lô', NULL, 'Xã Đồng Thịnh', 'làng lục liễu', NULL, 1, 0, 1, '2026-03-19 16:52:13', '2026-03-19 17:31:06'),
(6, 4, 'sdsd', 'Anh Tuấn', '0876726201', NULL, 'Tỉnh Hà Nam', NULL, 'Thị xã Duy Tiên', NULL, 'Xã Yên Nam', 'abc', NULL, 0, 0, 1, '2026-03-19 16:52:22', '2026-03-19 17:31:06');

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

--
-- Đang đổ dữ liệu cho bảng `customer_auth_tokens`
--

INSERT INTO `customer_auth_tokens` (`id`, `customer_id`, `token_type`, `token_hash`, `expires_at`, `used_at`, `created_at`) VALUES
(1, 1, 'email_verify', '1312e947b5297e966bbfb43cf6776c79b771b9640b356433a8f82fe100abb2cd', '2026-03-21 13:16:41', '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 2, 'phone_verify', 'e50238896609858f83f4ca3f06228685221b12f5c1c2820bdc0cff74c678d034', '2026-03-21 13:16:41', '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 2, 'password_reset', 'c17e4f3004f06953109ea710deea87593059677b97a1c78b7050b1cdb3f80324', '2026-03-20 13:16:41', NULL, '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `customer_oauth_accounts`
--

INSERT INTO `customer_oauth_accounts` (`id`, `customer_id`, `provider`, `provider_user_id`, `provider_email`, `provider_name`, `avatar_url`, `access_token_encrypted`, `refresh_token_encrypted`, `token_expires_at`, `linked_at`, `last_used_at`) VALUES
(1, 3, 'google', 'google_109876543210987654321', 'minhanh@example.com', 'Lê Minh Anh', '/uploads/avatars/minhanh.jpg', NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `customer_security_logs`
--

INSERT INTO `customer_security_logs` (`id`, `customer_id`, `event_type`, `ip_address`, `user_agent`, `meta_text`, `created_at`) VALUES
(1, 1, 'login_success', '113.161.10.10', 'Mozilla/5.0 Demo Browser', '{\"method\":\"password\"}', '2026-03-19 13:16:41'),
(2, 2, 'login_failed', '14.162.1.1', 'Mozilla/5.0 Demo Browser', '{\"reason\":\"wrong_password\"}', '2026-03-19 13:16:41'),
(3, 3, 'oauth_linked', '118.69.40.40', 'Mozilla/5.0 Demo Browser', '{\"provider\":\"google\"}', '2026-03-19 13:16:41'),
(4, 4, 'register_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng ký tài khoản', '2026-03-19 13:22:39'),
(5, 4, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 13:22:39'),
(6, 4, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 13:39:12'),
(7, 4, 'logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng xuất', '2026-03-19 14:16:46'),
(8, 5, 'register_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng ký tài khoản', '2026-03-19 14:17:14'),
(9, 5, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 14:17:14'),
(10, 5, 'logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng xuất', '2026-03-19 14:17:21'),
(11, 6, 'register_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng ký tài khoản', '2026-03-19 14:17:51'),
(12, 6, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 14:17:51'),
(13, 6, 'logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng xuất', '2026-03-19 14:18:12'),
(14, 4, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 16:47:45'),
(15, 4, 'logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng xuất', '2026-03-19 16:59:41'),
(16, 4, 'login_success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'Đăng nhập thành công', '2026-03-19 17:30:54');

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

--
-- Đang đổ dữ liệu cho bảng `customer_sessions`
--

INSERT INTO `customer_sessions` (`id`, `customer_id`, `session_token_hash`, `ip_address`, `user_agent`, `last_seen_at`, `expires_at`, `revoked_at`, `created_at`) VALUES
(1, 1, 'b3d0d394cba486fc44e72cc86f375d32dfd56b30ddc329b7ef61da4e61139309', '113.161.10.10', 'Mozilla/5.0 Demo Browser', '2026-03-19 13:16:41', '2026-03-26 13:16:41', NULL, '2026-03-19 13:16:41'),
(2, 2, '697ae39ef451389561987a2f706de0c5d7a5302778fcc687d3fd00236f383132', '14.162.1.1', 'Mozilla/5.0 Demo Browser', '2026-03-19 13:16:41', '2026-03-26 13:16:41', NULL, '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `inventory_movements`
--

INSERT INTO `inventory_movements` (`id`, `product_id`, `variant_id`, `movement_type`, `quantity_change`, `stock_after`, `source_type`, `source_id`, `note`, `created_by_admin_id`, `created_at`) VALUES
(1, 1, 1, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size S', 1, '2026-03-19 13:16:41'),
(2, 1, 2, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size M', 1, '2026-03-19 13:16:41'),
(3, 1, 3, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu xanh size L', 1, '2026-03-19 13:16:41'),
(4, 1, 4, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size S', 1, '2026-03-19 13:16:41'),
(5, 1, 5, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size M', 1, '2026-03-19 13:16:41'),
(6, 1, 6, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu đỏ size L', 1, '2026-03-19 13:16:41'),
(7, 1, 7, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size S', 1, '2026-03-19 13:16:41'),
(8, 1, 8, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size M', 1, '2026-03-19 13:16:41'),
(9, 1, 9, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu tím size L', 1, '2026-03-19 13:16:41'),
(10, 1, 10, 'purchase', 4, 4, 'import', 1001, 'Nhập áo màu vàng size S', 1, '2026-03-19 13:16:41'),
(11, 1, 11, 'purchase', 4, 4, 'import', 1001, 'Nhập áo màu vàng size M', 1, '2026-03-19 13:16:41'),
(12, 1, 12, 'purchase', 3, 3, 'import', 1001, 'Nhập áo màu vàng size L', 1, '2026-03-19 13:16:41'),
(13, 2, 13, 'purchase', 10, 10, 'import', 1002, 'Nhập sơ mi be', 1, '2026-03-19 13:16:41'),
(14, 2, 14, 'purchase', 8, 8, 'import', 1002, 'Nhập sơ mi xanh nhạt', 1, '2026-03-19 13:16:41'),
(15, 3, 15, 'purchase', 9, 9, 'import', 1003, 'Nhập jean xanh đậm size M', 1, '2026-03-19 13:16:41'),
(16, 3, 16, 'purchase', 8, 8, 'import', 1003, 'Nhập jean xanh nhạt size L', 1, '2026-03-19 13:16:41'),
(17, 3, 17, 'purchase', 9, 9, 'import', 1003, 'Nhập jean xanh đậm size XL', 1, '2026-03-19 13:16:41'),
(18, 4, 18, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size S', 1, '2026-03-19 13:16:41'),
(19, 4, 19, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size M', 1, '2026-03-19 13:16:41'),
(20, 4, 20, 'purchase', 4, 4, 'import', 1004, 'Nhập váy size L', 1, '2026-03-19 13:16:41'),
(21, 5, 21, 'purchase', 3, 3, 'import', 1005, 'Nhập giày size 39', 1, '2026-03-19 13:16:41'),
(22, 5, 22, 'purchase', 4, 4, 'import', 1005, 'Nhập giày size 40', 1, '2026-03-19 13:16:41'),
(23, 5, 23, 'purchase', 4, 4, 'import', 1005, 'Nhập giày size 41', 1, '2026-03-19 13:16:41'),
(24, 5, 24, 'purchase', 3, 3, 'import', 1005, 'Nhập giày size 42', 1, '2026-03-19 13:16:41'),
(25, 6, 25, 'purchase', 11, 11, 'import', 1006, 'Nhập túi tote màu kem', 1, '2026-03-19 13:16:41'),
(26, 6, 26, 'purchase', 11, 11, 'import', 1006, 'Nhập túi tote màu đen', 1, '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`id`, `order_code`, `customer_id`, `cart_id`, `checkout_type`, `purchase_channel`, `order_source`, `contact_name`, `contact_phone`, `contact_email`, `customer_note`, `internal_note`, `subtotal_amount`, `discount_amount`, `shipping_fee`, `total_amount`, `payment_plan`, `deposit_rate`, `deposit_required_amount`, `paid_amount`, `remaining_amount`, `payment_status`, `order_status`, `guest_access_token`, `placed_at`, `confirmed_at`, `completed_at`, `cancelled_at`, `cancel_reason`, `created_at`, `updated_at`) VALUES
(1, 'ODR000001', 1, 1, 'account', 'web', 'cart', 'Nguyễn Thị Linh', '0901234567', 'linh@example.com', 'Giao sau 18h', 'Khách VIP tháng 3', 377000.00, 0.00, 25000.00, 402000.00, 'full', 0.00, 0.00, 402000.00, 0.00, 'da_thanh_toan', 'dang_chuan_bi', NULL, '2026-03-17 14:00:00', '2026-03-17 14:30:00', NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'ODR000002', 2, NULL, 'account', 'web', 'product', 'Trần Hoàng Nam', '0912345678', 'nam@example.com', 'Cần giao nhanh', NULL, 520000.00, 0.00, 30000.00, 550000.00, 'deposit_30', 30.00, 165000.00, 165000.00, 385000.00, 'da_dat_coc', 'dang_chuan_bi', NULL, '2026-03-18 09:30:00', '2026-03-18 10:00:00', NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'ODR000003', NULL, NULL, 'guest', 'zalo', 'product', 'Phạm Gia Hân', '0933456789', 'giahan@example.com', 'Liên hệ qua Zalo trước khi ship', 'Lead từ TikTok', 315000.00, 0.00, 25000.00, 340000.00, 'zalo_manual', 0.00, 0.00, 0.00, 340000.00, 'chua_thanh_toan', 'cho_xac_nhan', '1cb1be5e5b14382fa923e58e2f62164d0e2d8682d8629bb249b30a3c928d533d', '2026-03-18 11:15:00', NULL, NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 'ODR000004', NULL, 2, 'guest', 'web', 'cart', 'Lưu Quang Huy', '0944567890', 'quanghuy@example.com', 'Ship tới văn phòng', NULL, 289000.00, 0.00, 25000.00, 314000.00, 'full', 0.00, 0.00, 314000.00, 0.00, 'da_thanh_toan', 'dang_chuan_bi', '3b534f7708825ff575d3c20f0aa12263bf445ff8b8d23b9c3880e97aba065619', '2026-03-18 15:30:00', '2026-03-18 15:45:00', NULL, NULL, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(5, 'DH26031900005', NULL, 3, 'guest', 'web', 'cart', 'Nguyễn Anh Tuấn', '0876726201', 'nguyenanhtuan4831@gmail.com', 'làng lục liễu\r\nlàng lục liễu\r\nlàng lục liễu', NULL, 179000.00, 0.00, 0.00, 179000.00, 'full', 0.00, 179000.00, 0.00, 179000.00, 'chua_thanh_toan', 'cho_xac_nhan', 'cd239ee4563224a6434d76c82bf904d288099e21892e8f00e23c4d700bdb0f39', '2026-03-19 13:17:42', NULL, NULL, NULL, NULL, '2026-03-19 13:17:42', '2026-03-19 13:17:42'),
(6, 'DH26031900006', NULL, 4, 'guest', 'web', 'cart', 'Nguyễn Anh Tuấn', '0876726201', 'nguyenanhtuan4831@gmail.com', 'làng lục liễu\r\nlàng lục liễu\r\nlàng lục liễu', NULL, 315000.00, 0.00, 0.00, 315000.00, 'full', 0.00, 315000.00, 0.00, 315000.00, 'chua_thanh_toan', 'cho_xac_nhan', '9f0302d8d426ff26df1bad28b0588cb54b9491b76924d73f6e8ef7d9c623003c', '2026-03-19 13:21:57', NULL, NULL, NULL, NULL, '2026-03-19 13:21:57', '2026-03-19 13:21:57'),
(7, 'DH26031900007', 4, 5, 'account', 'web', 'cart', 'Anh Tuấn', '0876726201', 'tuanna9112004@gmail.com', 'alo', NULL, 520000.00, 0.00, 0.00, 520000.00, 'full', 0.00, 520000.00, 520000.00, 0.00, 'da_thanh_toan', 'cho_xac_nhan', '325a6caeb40cd50b7eb82f8f4fec90ff7bbfbf091d5dfde468926bb18c7f0e81', '2026-03-19 13:39:36', NULL, NULL, NULL, NULL, '2026-03-19 13:39:36', '2026-03-19 14:04:36'),
(8, 'DH26031900008', 4, NULL, 'account', 'web', 'product', 'Anh Tuấn', '0876726201', 'tuanna9112004@gmail.com', 'abc', NULL, 315000.00, 0.00, 0.00, 315000.00, 'full', 0.00, 315000.00, 0.00, 315000.00, 'chua_thanh_toan', 'cho_xac_nhan', '8c6a7225fc85ed018a089e060a473d67b104f26dc5d921ce8398457df1a018f4', '2026-03-19 14:10:04', NULL, NULL, NULL, NULL, '2026-03-19 14:10:04', '2026-03-19 14:10:04'),
(9, 'DH26031900009', 4, 6, 'account', 'web', 'cart', 'Anh Tuấn', '0876726201', 'tuanna9112004@gmail.com', NULL, NULL, 99000.00, 0.00, 0.00, 99000.00, 'deposit_30', 30.00, 29700.00, 99000.00, 0.00, 'da_thanh_toan', 'da_giao', '60ba50a4e0d1b0400b508e6ed231f3d507a19d0e38c0c0a30dd828d3fc03ccfe', '2026-03-19 14:15:44', NULL, '2026-03-19 14:21:15', NULL, NULL, '2026-03-19 14:15:44', '2026-03-19 14:21:15'),
(10, 'DH26031900010', NULL, 8, 'guest', 'web', 'cart', 'Nguyễn Anh Tuấn', '0876726201', 'nguyenanhtuan4831@gmail.com', NULL, NULL, 315000.00, 0.00, 0.00, 315000.00, 'full', 0.00, 315000.00, 315000.00, 0.00, 'da_hoan_tien', 'tra_hang', '75c790277852a188b0a124e7f40e85df5a407e3e91fe1c712dc5d4c709326e6a', '2026-03-19 16:43:19', '2026-03-19 16:44:29', '2026-03-19 16:44:35', NULL, NULL, '2026-03-19 16:43:19', '2026-03-19 16:44:57'),
(11, 'DH26031900011', 4, 9, 'account', 'web', 'cart', 'Anh Tuấn', '0876726201', 'tuanna9112004@gmail.com', NULL, NULL, 289000.00, 0.00, 0.00, 289000.00, 'full', 0.00, 289000.00, 0.00, 289000.00, 'chua_thanh_toan', 'cho_xac_nhan', 'cb78df5d6c853334518c33cd16698723c315e3e5efe3a6c479ef13e7aca0e9a8', '2026-03-19 17:32:43', NULL, NULL, NULL, NULL, '2026-03-19 17:32:43', '2026-03-19 17:32:43');

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

--
-- Đang đổ dữ liệu cho bảng `order_addresses`
--

INSERT INTO `order_addresses` (`id`, `order_id`, `address_type`, `source_type`, `source_address_id`, `receiver_name`, `receiver_phone`, `province_name`, `district_name`, `ward_name`, `address_line`, `address_note`, `created_at`) VALUES
(1, 1, 'shipping', 'account_saved', 1, 'Nguyễn Thị Linh', '0901234567', 'TP. Hồ Chí Minh', 'Quận 1', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', '2026-03-19 13:16:41'),
(2, 1, 'billing', 'account_saved', 1, 'Nguyễn Thị Linh', '0901234567', 'TP. Hồ Chí Minh', 'Quận 1', 'Phường Bến Nghé', '12 Nguyễn Huệ', 'Chung cư tầng 8', '2026-03-19 13:16:41'),
(3, 2, 'shipping', 'account_saved', 3, 'Trần Hoàng Nam', '0912345678', 'TP. Hồ Chí Minh', 'Quận Bình Thạnh', 'Phường 25', '88 D5', 'Gọi trước khi giao', '2026-03-19 13:16:41'),
(4, 3, 'shipping', 'manual', NULL, 'Phạm Gia Hân', '0933456789', 'Khánh Hòa', 'Nha Trang', 'Phường Lộc Thọ', '15 Trần Phú', 'Liên hệ Zalo', '2026-03-19 13:16:41'),
(5, 4, 'shipping', 'manual', NULL, 'Lưu Quang Huy', '0944567890', 'TP. Hồ Chí Minh', 'Quận 3', 'Phường Võ Thị Sáu', '120 Cách Mạng Tháng 8', 'Ship giờ hành chính', '2026-03-19 13:16:41'),
(6, 5, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 13:17:42'),
(7, 6, 'shipping', 'manual', NULL, 'Nguyễn Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 13:21:57'),
(8, 7, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 13:39:36'),
(9, 8, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 14:10:04'),
(10, 9, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 14:15:44'),
(11, 10, 'shipping', 'manual', NULL, 'Anh Tuấn', '0876726201', 'Vĩnh phúc', 'tam đảo', 'đạo trù', 'làng lục liễu', 'làng lục liễu', '2026-03-19 16:43:19'),
(12, 11, 'shipping', 'account_saved', 5, 'Anh Tuấn', '0876726201', 'Tỉnh Vĩnh Phúc', 'Huyện Sông Lô', 'Xã Đồng Thịnh', 'làng lục liễu', NULL, '2026-03-19 17:32:43');

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

--
-- Đang đổ dữ liệu cho bảng `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `variant_id`, `product_name_snapshot`, `product_code_snapshot`, `sku_snapshot`, `variant_name_snapshot`, `size_snapshot`, `color_snapshot`, `thumbnail_snapshot`, `quantity`, `original_unit_price`, `final_unit_price`, `line_total`, `created_at`) VALUES
(1, 1, 1, 5, 'Áo thun gân tăm basic', 'AO_001', 'AO001-DO-M', 'Đỏ / M', 'M', 'Đỏ', '/uploads/products/ao_001_2.jpg', 2, 120000.00, 99000.00, 198000.00, '2026-03-19 13:16:41'),
(2, 1, 6, 25, 'Túi tote canvas mini', 'TUI_001', 'TUI001-KEM-FS', 'Kem / Free size', 'Free size', 'Kem', '/uploads/products/tui_001_main.jpg', 1, 210000.00, 179000.00, 179000.00, '2026-03-19 13:16:41'),
(3, 2, 5, 22, 'Sneaker trắng tối giản', 'GIAY_001', 'GIAY001-40', 'Trắng / 40', '40', 'Trắng', '/uploads/products/giay_001_main.jpg', 1, 590000.00, 520000.00, 520000.00, '2026-03-19 13:16:41'),
(4, 3, 4, 19, 'Váy midi hoa vintage', 'VAY_001', 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', '/uploads/products/vay_001_main.jpg', 1, 350000.00, 315000.00, 315000.00, '2026-03-19 13:16:41'),
(5, 4, 3, 15, 'Quần jean ống suông cạp cao', 'QUAN_001', 'QUAN001-XD-M', 'Xanh đậm / M', 'M', 'Xanh đậm', '/uploads/products/quan_001_main.jpg', 1, 320000.00, 289000.00, 289000.00, '2026-03-19 13:16:41'),
(6, 5, 6, 26, 'Túi tote canvas mini', 'TUI_001', 'TUI001-DEN-FS', 'Đen / Free size', 'Free size', 'Đen', '/uploads/products/tui_001_main.jpg', 1, 210000.00, 179000.00, 179000.00, '2026-03-19 13:17:42'),
(7, 6, 4, 19, 'Váy midi hoa vintage', 'VAY_001', 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', '/uploads/products/vay_001_main.jpg', 1, 350000.00, 315000.00, 315000.00, '2026-03-19 13:21:57'),
(8, 7, 5, 21, 'Sneaker trắng tối giản', 'GIAY_001', 'GIAY001-39', 'Trắng / 39', '39', 'Trắng', '/uploads/products/giay_001_main.jpg', 1, 590000.00, 520000.00, 520000.00, '2026-03-19 13:39:36'),
(9, 8, 4, 19, 'Váy midi hoa vintage', 'VAY_001', 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', '/uploads/products/vay_001_main.jpg', 1, 350000.00, 315000.00, 315000.00, '2026-03-19 14:10:04'),
(10, 9, 1, 11, 'Áo thun gân tăm basic', 'AO_001', 'AO001-VANG-M', 'Vàng / M', 'M', 'Vàng', '/uploads/products/ao_001_main.jpg', 1, 120000.00, 99000.00, 99000.00, '2026-03-19 14:15:44'),
(11, 10, 4, 18, 'Váy midi hoa vintage', 'VAY_001', 'VAY001-KEM-S', 'Kem hoa nhí / S', 'S', 'Kem hoa nhí', 'uploads/img_69bb9efa5af234.09565613.png', 1, 350000.00, 315000.00, 315000.00, '2026-03-19 16:43:19'),
(12, 11, 3, 15, 'Quần jean ống suông cạp cao', 'QUAN_001', 'QUAN001-XD-M', 'Xanh đậm / M', 'M', 'Xanh đậm', '/uploads/products/quan_001_main.jpg', 1, 320000.00, 289000.00, 289000.00, '2026-03-19 17:32:43');

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

--
-- Đang đổ dữ liệu cho bảng `order_status_logs`
--

INSERT INTO `order_status_logs` (`id`, `order_id`, `from_status`, `to_status`, `note`, `changed_by_type`, `changed_by_id`, `created_at`) VALUES
(1, 1, NULL, 'cho_xac_nhan', 'Tạo đơn từ giỏ hàng', 'customer', 1, '2026-03-17 14:00:00'),
(2, 1, 'cho_xac_nhan', 'dang_chuan_bi', 'Đã thanh toán đủ, admin xác nhận', 'admin', 1, '2026-03-17 14:30:00'),
(3, 2, NULL, 'cho_xac_nhan', 'Khách chọn cọc 30%', 'customer', 2, '2026-03-18 09:30:00'),
(4, 2, 'cho_xac_nhan', 'dang_chuan_bi', 'Đã nhận tiền cọc', 'webhook', NULL, '2026-03-18 10:00:00'),
(5, 3, NULL, 'cho_xac_nhan', 'Lead đặt hàng qua Zalo', 'customer', NULL, '2026-03-18 11:15:00'),
(6, 4, NULL, 'cho_xac_nhan', 'Guest checkout web', 'customer', NULL, '2026-03-18 15:30:00'),
(7, 4, 'cho_xac_nhan', 'dang_chuan_bi', 'Thanh toán đủ, chuẩn bị đóng gói', 'admin', 1, '2026-03-18 16:00:00'),
(8, 5, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'system', NULL, '2026-03-19 13:17:42'),
(9, 6, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'system', NULL, '2026-03-19 13:21:57'),
(10, 7, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'customer', 4, '2026-03-19 13:39:36'),
(11, 7, 'cho_xac_nhan', 'cho_xac_nhan', NULL, 'admin', 1, '2026-03-19 14:04:36'),
(12, 8, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới', 'customer', 4, '2026-03-19 14:10:04'),
(13, 9, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'customer', 4, '2026-03-19 14:15:44'),
(14, 9, 'cho_xac_nhan', 'da_giao', NULL, 'admin', 1, '2026-03-19 14:20:18'),
(15, 9, 'da_giao', 'da_giao', NULL, 'admin', 1, '2026-03-19 14:21:15'),
(16, 10, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'system', NULL, '2026-03-19 16:43:19'),
(17, 10, 'cho_xac_nhan', 'cho_xac_nhan', NULL, 'admin', 1, '2026-03-19 16:44:08'),
(18, 10, 'cho_xac_nhan', 'cho_xac_nhan', NULL, 'admin', 1, '2026-03-19 16:44:18'),
(19, 10, 'cho_xac_nhan', 'cho_xac_nhan', NULL, 'admin', 1, '2026-03-19 16:44:23'),
(20, 10, 'cho_xac_nhan', 'dang_chuan_bi', NULL, 'admin', 1, '2026-03-19 16:44:29'),
(21, 10, 'dang_chuan_bi', 'da_giao', NULL, 'admin', 1, '2026-03-19 16:44:35'),
(22, 10, 'da_giao', 'tra_hang', NULL, 'admin', 1, '2026-03-19 16:44:41'),
(23, 10, 'tra_hang', 'tra_hang', NULL, 'admin', 1, '2026-03-19 16:44:57'),
(24, 11, NULL, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', 'customer', 4, '2026-03-19 17:32:43');

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

--
-- Đang đổ dữ liệu cho bảng `payments`
--

INSERT INTO `payments` (`id`, `payment_intent_id`, `customer_id`, `order_id`, `provider`, `provider_transaction_id`, `provider_reference_code`, `transfer_type`, `paid_amount`, `fee_amount`, `net_amount`, `payment_status`, `raw_content`, `paid_at`, `confirmed_at`, `raw_payload_text`, `created_at`) VALUES
(1, 1, 1, 1, 'sepay', 'SPTXN000001', 'MBREF0001', 'in', 402000.00, 0.00, 402000.00, 'success', 'ODR000001', '2026-03-17 14:18:00', '2026-03-17 14:19:00', '{\"id\":\"SPTXN000001\",\"content\":\"ODR000001\",\"transferAmount\":402000}', '2026-03-19 13:16:41'),
(2, 2, 2, 2, 'sepay', 'SPTXN000002', 'MBREF0002', 'in', 165000.00, 0.00, 165000.00, 'success', 'ODR000002-COC', '2026-03-18 09:52:00', '2026-03-18 09:53:00', '{\"id\":\"SPTXN000002\",\"content\":\"ODR000002-COC\",\"transferAmount\":165000}', '2026-03-19 13:16:41'),
(3, 3, NULL, 4, 'sepay', 'SPTXN000003', 'MBREF0003', 'in', 314000.00, 0.00, 314000.00, 'success', 'ODR000004', '2026-03-18 15:38:00', '2026-03-18 15:39:00', '{\"id\":\"SPTXN000003\",\"content\":\"ODR000004\",\"transferAmount\":314000}', '2026-03-19 13:16:41'),
(4, 4, 1, NULL, 'sepay', 'SPTXN000004', 'MBREF0004', 'in', 500000.00, 0.00, 500000.00, 'success', 'NAPTOPUP001', '2026-03-18 17:05:00', '2026-03-18 17:06:00', '{\"id\":\"SPTXN000004\",\"content\":\"NAPTOPUP001\",\"transferAmount\":500000}', '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `payment_intents`
--

INSERT INTO `payment_intents` (`id`, `intent_code`, `customer_id`, `order_id`, `wallet_topup_request_id`, `provider`, `purpose`, `requested_amount`, `currency_code`, `status`, `qr_content`, `qr_image_url`, `transfer_note`, `expires_at`, `idempotency_key`, `metadata_text`, `created_at`, `updated_at`) VALUES
(1, 'PI000001', 1, 1, NULL, 'sepay', 'order_full', 402000.00, 'VND', 'paid', 'bank=MB&acc=123456789&amount=402000&addInfo=ODR000001', '/qrs/PI000001.png', 'ODR000001', '2026-03-18 23:59:59', 'idem-order-1', '{\"order_code\":\"ODR000001\"}', '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'PI000002', 2, 2, NULL, 'sepay', 'order_deposit', 165000.00, 'VND', 'paid', 'bank=MB&acc=123456789&amount=165000&addInfo=ODR000002-COC', '/qrs/PI000002.png', 'ODR000002-COC', '2026-03-19 23:59:59', 'idem-order-2', '{\"order_code\":\"ODR000002\",\"payment_plan\":\"deposit_30\"}', '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'PI000003', NULL, 4, NULL, 'sepay', 'order_full', 314000.00, 'VND', 'paid', 'bank=MB&acc=123456789&amount=314000&addInfo=ODR000004', '/qrs/PI000003.png', 'ODR000004', '2026-03-19 23:59:59', 'idem-order-4', '{\"order_code\":\"ODR000004\"}', '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 'PI000004', 1, NULL, 1, 'sepay', 'wallet_topup', 500000.00, 'VND', 'paid', 'bank=MB&acc=123456789&amount=500000&addInfo=NAPTOPUP001', '/qrs/PI000004.png', 'NAPTOPUP001', '2026-03-20 23:59:59', 'idem-topup-1', '{\"topup_code\":\"TOPUP0001\"}', '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(5, 'PAYFF25CCDB9A93', NULL, 5, NULL, 'sepay', 'order_full', 179000.00, 'VND', 'waiting_payment', 'TT DH26031900005 PAYFF25CCDB9A93', '', 'TT DH26031900005 PAYFF25CCDB9A93', '2026-03-20 13:17:42', NULL, NULL, '2026-03-19 13:17:42', '2026-03-19 13:17:42'),
(6, 'PAY901EA204D6C6', NULL, 6, NULL, 'sepay', 'order_full', 315000.00, 'VND', 'waiting_payment', 'TT DH26031900006 PAY901EA204D6C6', 'https://qr.sepay.vn/img?acc=0896038072&bank=MBBank&amount=315000&des=TT+DH26031900006+PAY901EA204D6C6', 'TT DH26031900006 PAY901EA204D6C6', '2026-03-20 13:21:57', NULL, NULL, '2026-03-19 13:21:57', '2026-03-19 13:21:57'),
(7, 'PAY1D7A3535A99A', 4, 7, NULL, 'sepay', 'order_full', 520000.00, 'VND', 'waiting_payment', 'TT DH26031900007 PAY1D7A3535A99A', 'https://qr.sepay.vn/img?acc=0896038072&bank=MBBank&amount=520000&des=TT+DH26031900007+PAY1D7A3535A99A', 'TT DH26031900007 PAY1D7A3535A99A', '2026-03-20 13:39:36', NULL, NULL, '2026-03-19 13:39:36', '2026-03-19 13:39:36'),
(8, 'PAY344A4A2D92DD', 4, 8, NULL, 'sepay', 'order_full', 315000.00, 'VND', 'waiting_payment', 'TT DH26031900008 PAY344A4A2D92DD', 'https://qr.sepay.vn/img?acc=0896038072&bank=MBBank&amount=315000&des=TT+DH26031900008+PAY344A4A2D92DD', 'TT DH26031900008 PAY344A4A2D92DD', '2026-03-20 14:10:04', NULL, NULL, '2026-03-19 14:10:04', '2026-03-19 14:10:04'),
(9, 'PAYC6196C41BFA4', 4, 9, NULL, 'sepay', 'order_deposit', 29700.00, 'VND', 'waiting_payment', 'TT DH26031900009 PAYC6196C41BFA4', 'https://qr.sepay.vn/img?acc=0896038072&bank=MBBank&amount=29700&des=TT+DH26031900009+PAYC6196C41BFA4', 'TT DH26031900009 PAYC6196C41BFA4', '2026-03-20 14:15:44', NULL, NULL, '2026-03-19 14:15:44', '2026-03-19 14:15:44'),
(10, 'PAYD99537579AF6', NULL, 10, NULL, 'sepay', 'order_full', 315000.00, 'VND', 'waiting_payment', 'TT DH26031900010 PAYD99537579AF6', 'https://qr.sepay.vn/img?acc=VQRQAHSJJ1234&bank=MBBank&amount=315000&des=TT+DH26031900010+PAYD99537579AF6', 'TT DH26031900010 PAYD99537579AF6', '2026-03-20 16:43:19', NULL, NULL, '2026-03-19 16:43:19', '2026-03-19 16:43:19'),
(11, 'PAYD46960E25024', 4, 11, NULL, 'sepay', 'order_full', 289000.00, 'VND', 'waiting_payment', 'TT DH26031900011 PAYD46960E25024', 'https://qr.sepay.vn/img?acc=VQRQAHSJJ1234&bank=MBBank&amount=289000&des=TT+DH26031900011+PAYD46960E25024', 'TT DH26031900011 PAYD46960E25024', '2026-03-20 17:32:43', NULL, NULL, '2026-03-19 17:32:43', '2026-03-19 17:32:43');

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

--
-- Đang đổ dữ liệu cho bảng `payment_webhook_logs`
--

INSERT INTO `payment_webhook_logs` (`id`, `provider`, `event_key`, `provider_transaction_id`, `request_headers_text`, `request_body_text`, `parsed_amount`, `parsed_reference_code`, `parsed_transfer_type`, `process_status`, `linked_payment_id`, `error_message`, `processed_at`, `created_at`) VALUES
(1, 'sepay', 'sepay_event_000001', 'SPTXN000001', '{\"authorization\":\"Apikey demo\"}', '{\"id\":\"SPTXN000001\",\"content\":\"ODR000001\",\"transferAmount\":402000}', 402000.00, 'MBREF0001', 'in', 'processed', 1, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 'sepay', 'sepay_event_000002', 'SPTXN000002', '{\"authorization\":\"Apikey demo\"}', '{\"id\":\"SPTXN000002\",\"content\":\"ODR000002-COC\",\"transferAmount\":165000}', 165000.00, 'MBREF0002', 'in', 'processed', 2, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 'sepay', 'sepay_event_000003', 'SPTXN000003', '{\"authorization\":\"Apikey demo\"}', '{\"id\":\"SPTXN000003\",\"content\":\"ODR000004\",\"transferAmount\":314000}', 314000.00, 'MBREF0003', 'in', 'processed', 3, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 'sepay', 'sepay_event_000004', 'SPTXN000004', '{\"authorization\":\"Apikey demo\"}', '{\"id\":\"SPTXN000004\",\"content\":\"NAPTOPUP001\",\"transferAmount\":500000}', 500000.00, 'MBREF0004', 'in', 'processed', 4, NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

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
(1, 'Áo thun gân tăm basic', 'ao-thun-gan-tam-basic', 'AO_001', 1, 1, 1, 'Nữ', 120000.00, 99000.00, 55000.00, 'Mẫu bán chạy quanh năm', 'Thun gân', 'Áo thun gân tăm co giãn tốt, form ôm nhẹ, dễ phối với chân váy hoặc quần jean.', 'Áo thun nữ form ôm basic, dễ phối đồ.', 38, 1, 0, 5, 'Kho sỉ Quận 5', 'https://zalo.me/0961691107', '/uploads/products/ao_001_main.jpg', 1, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:56:15', 0),
(2, 'Áo sơ mi linen oversize', 'ao-so-mi-linen-oversize', 'AO_002', 1, 2, 4, 'Unisex', 280000.00, 249000.00, 145000.00, 'Mát, dễ lên ảnh', 'Linen pha cotton', 'Áo sơ mi tay dài form rộng, chất vải thoáng, phù hợp đi làm hoặc đi chơi.', 'Sơ mi linen form rộng thanh lịch.', 18, 1, 0, 3, 'Xưởng Bình Tân', 'https://zalo.me/0961691107', '/uploads/products/ao_002_main.jpg', 1, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:56:18', 0),
(3, 'Quần jean ống suông cạp cao', 'quan-jean-ong-suong-cap-cao', 'QUAN_001', 2, 4, 2, 'Nữ', 320000.00, 289000.00, 180000.00, 'Tôn dáng, dễ bán online', 'Jean cotton', 'Quần jean ống suông cạp cao, tôn dáng, hợp với nhiều kiểu áo basic.', 'Jean ống suông cạp cao, hack dáng.', 26, 1, 0, 4, 'Kho sỉ Tân Bình', 'https://zalo.me/0961691107', '/uploads/products/quan_001_main.jpg', 1, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:37:08', 0),
(4, 'Váy midi hoa vintage', 'vay-midi-hoa-vintage', 'VAY_001', 2, 6, 3, 'Nữ', 350000.00, 315000.00, 190000.00, 'Ảnh lookbook đẹp', 'Voan lót cotton', 'Váy midi họa tiết hoa nhí phong cách vintage, thích hợp dạo phố và đi biển.', 'Váy midi nữ tính, phong cách vintage.', 12, 1, 0, 2, 'Kho Đà Lạt', 'https://zalo.me/0961691107', '/uploads/products/vay_001_main.jpg', 1, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 14:00:10', 0),
(5, 'Sneaker trắng tối giản', 'sneaker-trang-toi-gian', 'GIAY_001', 3, 7, 1, 'Unisex', 590000.00, 520000.00, 340000.00, 'Mẫu dễ bán cho cả nam nữ', 'Da tổng hợp', 'Sneaker trắng thiết kế tối giản, dễ phối đồ, đế êm và nhẹ.', 'Sneaker trắng basic cho outfit hằng ngày.', 14, 1, 0, 2, 'Kho Giày Bình Dương', 'https://zalo.me/0961691107', '/uploads/products/giay_001_main.jpg', 0, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:58:38', 0),
(6, 'Túi tote canvas mini', 'tui-tote-canvas-mini', 'TUI_001', 4, 9, 1, 'Nữ', 210000.00, 179000.00, 95000.00, 'Phụ kiện mua kèm tốt', 'Canvas dày', 'Túi tote canvas mini gọn nhẹ, phù hợp đi học và đi chơi.', 'Túi tote mini dễ phối đồ.', 22, 1, 0, 3, 'Kho phụ kiện Q10', 'https://zalo.me/0961691107', '/uploads/products/tui_001_main.jpg', 0, '2026-03-19 13:16:41', NULL, '2026-03-19 13:16:41', '2026-03-19 13:58:22', 0);

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

--
-- Đang đổ dữ liệu cho bảng `product_condition_maps`
--

INSERT INTO `product_condition_maps` (`product_id`, `condition_id`, `sort_order`, `created_at`) VALUES
(2, 1, 1, '2026-03-19 13:16:41'),
(3, 2, 1, '2026-03-19 13:16:41'),
(4, 1, 1, '2026-03-19 13:16:41'),
(5, 2, 1, '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image_url`, `sort_order`, `created_at`) VALUES
(4, 2, '/uploads/products/ao_002_main.jpg', 1, '2026-03-19 13:16:41'),
(5, 2, '/uploads/products/ao_002_2.jpg', 2, '2026-03-19 13:16:41'),
(6, 3, '/uploads/products/quan_001_main.jpg', 1, '2026-03-19 13:16:41'),
(7, 3, '/uploads/products/quan_001_2.jpg', 2, '2026-03-19 13:16:41'),
(8, 4, '/uploads/products/vay_001_main.jpg', 1, '2026-03-19 13:16:41'),
(9, 5, '/uploads/products/giay_001_main.jpg', 1, '2026-03-19 13:16:41'),
(10, 5, '/uploads/products/giay_001_2.jpg', 2, '2026-03-19 13:16:41');

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
(1, 1, 'AO001-XANH-S', 'Xanh / S', 'S', 'Xanh', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 1, 'AO001-XANH-M', 'Xanh / M', 'M', 'Xanh', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 1, 'AO001-XANH-L', 'Xanh / L', 'L', 'Xanh', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(4, 1, 'AO001-DO-S', 'Đỏ / S', 'S', 'Đỏ', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(5, 1, 'AO001-DO-M', 'Đỏ / M', 'M', 'Đỏ', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(6, 1, 'AO001-DO-L', 'Đỏ / L', 'L', 'Đỏ', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(7, 1, 'AO001-TIM-S', 'Tím / S', 'S', 'Tím', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_3.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(8, 1, 'AO001-TIM-M', 'Tím / M', 'M', 'Tím', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_3.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(9, 1, 'AO001-TIM-L', 'Tím / L', 'L', 'Tím', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_3.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(10, 1, 'AO001-VANG-S', 'Vàng / S', 'S', 'Vàng', 120000.00, 99000.00, 55000.00, 4, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(11, 1, 'AO001-VANG-M', 'Vàng / M', 'M', 'Vàng', 120000.00, 99000.00, 55000.00, 4, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(12, 1, 'AO001-VANG-L', 'Vàng / L', 'L', 'Vàng', 120000.00, 99000.00, 55000.00, 3, '/uploads/products/ao_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(13, 2, 'AO002-BE-M', 'Be / M', 'M', 'Be', 280000.00, 249000.00, 145000.00, 10, '/uploads/products/ao_002_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(14, 2, 'AO002-XANHNHAT-L', 'Xanh nhạt / L', 'L', 'Xanh nhạt', 280000.00, 249000.00, 145000.00, 8, '/uploads/products/ao_002_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(15, 3, 'QUAN001-XD-M', 'Xanh đậm / M', 'M', 'Xanh đậm', 320000.00, 289000.00, 180000.00, 9, '/uploads/products/quan_001_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(16, 3, 'QUAN001-XN-L', 'Xanh nhạt / L', 'L', 'Xanh nhạt', 320000.00, 289000.00, 180000.00, 8, '/uploads/products/quan_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(17, 3, 'QUAN001-XD-XL', 'Xanh đậm / XL', 'XL', 'Xanh đậm', 320000.00, 289000.00, 180000.00, 9, '/uploads/products/quan_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(18, 4, 'VAY001-KEM-S', 'Kem hoa nhí / S', 'S', 'Kem hoa nhí', 350000.00, 315000.00, 190000.00, 4, 'uploads/img_69bb9efa5af234.09565613.png', 1, 1, '2026-03-19 13:16:41', '2026-03-19 14:00:10'),
(19, 4, 'VAY001-KEM-M', 'Kem hoa nhí / M', 'M', 'Kem hoa nhí', 350000.00, 315000.00, 190000.00, 4, '/uploads/products/vay_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(20, 4, 'VAY001-KEM-L', 'Kem hoa nhí / L', 'L', 'Kem hoa nhí', 350000.00, 315000.00, 190000.00, 4, '/uploads/products/vay_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(21, 5, 'GIAY001-39', 'Trắng / 39', '39', 'Trắng', 590000.00, 520000.00, 340000.00, 3, '/uploads/products/giay_001_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(22, 5, 'GIAY001-40', 'Trắng / 40', '40', 'Trắng', 590000.00, 520000.00, 340000.00, 4, '/uploads/products/giay_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(23, 5, 'GIAY001-41', 'Trắng / 41', '41', 'Trắng', 590000.00, 520000.00, 340000.00, 4, '/uploads/products/giay_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(24, 5, 'GIAY001-42', 'Trắng / 42', '42', 'Trắng', 590000.00, 520000.00, 340000.00, 3, '/uploads/products/giay_001_2.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(25, 6, 'TUI001-KEM-FS', 'Kem / Free size', 'Free size', 'Kem', 210000.00, 179000.00, 95000.00, 11, '/uploads/products/tui_001_main.jpg', 1, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(26, 6, 'TUI001-DEN-FS', 'Đen / Free size', 'Free size', 'Đen', 210000.00, 179000.00, 95000.00, 11, '/uploads/products/tui_001_main.jpg', 0, 1, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `wallet_accounts`
--

INSERT INTO `wallet_accounts` (`id`, `customer_id`, `status`, `balance_cached`, `total_credited`, `total_debited`, `created_at`, `updated_at`) VALUES
(1, 1, 'active', 350000.00, 500000.00, 150000.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(2, 2, 'active', 0.00, 0.00, 0.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41'),
(3, 3, 'active', 0.00, 0.00, 0.00, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

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

--
-- Đang đổ dữ liệu cho bảng `wallet_ledger`
--

INSERT INTO `wallet_ledger` (`id`, `wallet_account_id`, `customer_id`, `entry_type`, `source_type`, `source_id`, `amount_change`, `balance_before`, `balance_after`, `description`, `related_payment_id`, `created_at`) VALUES
(1, 1, 1, 'topup_credit', 'wallet_topup', 1, 500000.00, 0.00, 500000.00, 'Nạp ví qua SePay TOPUP0001', 4, '2026-03-18 17:06:00'),
(2, 1, 1, 'order_debit', 'order', 1, -150000.00, 500000.00, 350000.00, 'Trừ ví cho đơn hàng demo ODR000001', NULL, '2026-03-18 18:00:00');

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
-- Đang đổ dữ liệu cho bảng `wallet_topup_requests`
--

INSERT INTO `wallet_topup_requests` (`id`, `customer_id`, `topup_code`, `requested_amount`, `status`, `payment_intent_id`, `note`, `expires_at`, `confirmed_at`, `cancelled_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'TOPUP0001', 500000.00, 'confirmed', 4, 'Khách nạp ví để mua sau', '2026-03-20 23:59:59', '2026-03-18 17:06:00', NULL, '2026-03-19 13:16:41', '2026-03-19 13:16:41');

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `carts`
--
ALTER TABLE `carts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `customer_addresses`
--
ALTER TABLE `customer_addresses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `customer_auth_tokens`
--
ALTER TABLE `customer_auth_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `customer_oauth_accounts`
--
ALTER TABLE `customer_oauth_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `customer_security_logs`
--
ALTER TABLE `customer_security_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT cho bảng `customer_sessions`
--
ALTER TABLE `customer_sessions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `inventory_movements`
--
ALTER TABLE `inventory_movements`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `order_addresses`
--
ALTER TABLE `order_addresses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT cho bảng `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT cho bảng `order_status_logs`
--
ALTER TABLE `order_status_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT cho bảng `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `payment_intents`
--
ALTER TABLE `payment_intents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `payment_webhook_logs`
--
ALTER TABLE `payment_webhook_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `product_conditions`
--
ALTER TABLE `product_conditions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `product_types`
--
ALTER TABLE `product_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT cho bảng `styles`
--
ALTER TABLE `styles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `wallet_ledger`
--
ALTER TABLE `wallet_ledger`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `wallet_topup_requests`
--
ALTER TABLE `wallet_topup_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
