-- =========================================================
-- clothing_shop_full_schema.sql
-- Full MySQL/MariaDB schema for the upgraded clothing shop
-- Based on the current PHP project structure:
-- - keep existing catalog/admin foundation
-- - add customers, carts, orders, payments, wallet, webhooks, security logs
-- =========================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `clothing_shop`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `clothing_shop`;

-- ---------------------------------------------------------
-- OPTIONAL: drop in reverse dependency order for clean reinstall
-- ---------------------------------------------------------
DROP TABLE IF EXISTS `admin_audit_logs`;
DROP TABLE IF EXISTS `wallet_ledger`;
DROP TABLE IF EXISTS `wallet_topup_requests`;
DROP TABLE IF EXISTS `wallet_accounts`;
DROP TABLE IF EXISTS `payment_webhook_logs`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `payment_intents`;
DROP TABLE IF EXISTS `order_status_logs`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `order_addresses`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `cart_items`;
DROP TABLE IF EXISTS `carts`;
DROP TABLE IF EXISTS `customer_security_logs`;
DROP TABLE IF EXISTS `customer_auth_tokens`;
DROP TABLE IF EXISTS `customer_sessions`;
DROP TABLE IF EXISTS `customer_addresses`;
DROP TABLE IF EXISTS `customer_oauth_accounts`;
DROP TABLE IF EXISTS `inventory_movements`;
DROP TABLE IF EXISTS `product_variants`;
DROP TABLE IF EXISTS `product_condition_maps`;
DROP TABLE IF EXISTS `product_images`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `product_conditions`;
DROP TABLE IF EXISTS `product_types`;
DROP TABLE IF EXISTS `styles`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `admins`;
DROP TABLE IF EXISTS `app_settings`;

-- ---------------------------------------------------------
-- System/admin
-- ---------------------------------------------------------
CREATE TABLE `admins` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(150) DEFAULT NULL,
  `status` ENUM('active','locked','disabled') NOT NULL DEFAULT 'active',
  `last_login_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_admins_username` (`username`),
  KEY `idx_admins_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `app_settings` (
  `setting_key` VARCHAR(100) NOT NULL,
  `setting_value` TEXT NOT NULL,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------
-- Catalog
-- ---------------------------------------------------------
CREATE TABLE `categories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(120) DEFAULT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categories_slug` (`slug`),
  KEY `idx_categories_active_sort` (`is_active`,`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `styles` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(120) DEFAULT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_styles_slug` (`slug`),
  KEY `idx_styles_active_sort` (`is_active`,`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `product_conditions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(120) DEFAULT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_conditions_slug` (`slug`),
  KEY `idx_product_conditions_active_sort` (`is_active`,`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `product_types` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(120) DEFAULT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_types_slug` (`slug`),
  KEY `idx_product_types_category_active_sort` (`category_id`,`is_active`,`sort_order`),
  CONSTRAINT `fk_product_types_category`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `products` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(180) DEFAULT NULL,
  `product_code` VARCHAR(100) NOT NULL,
  `category_id` INT UNSIGNED NOT NULL,
  `product_type_id` INT UNSIGNED NOT NULL,
  `style_id` INT UNSIGNED DEFAULT NULL,
  `gender` ENUM('Nam','Nữ','Unisex') NOT NULL DEFAULT 'Unisex',
  `original_price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `sale_price` DECIMAL(12,2) DEFAULT NULL,
  `purchase_price` DECIMAL(12,2) DEFAULT NULL,
  `note` VARCHAR(500) DEFAULT NULL,
  `material` VARCHAR(255) DEFAULT NULL,
  `information` TEXT DEFAULT NULL,
  `short_description` VARCHAR(500) DEFAULT NULL,
  `quantity` INT NOT NULL DEFAULT 0,
  `track_inventory` TINYINT(1) NOT NULL DEFAULT 1,
  `allow_backorder` TINYINT(1) NOT NULL DEFAULT 0,
  `min_stock_alert` INT NOT NULL DEFAULT 0,
  `supplier_contact` VARCHAR(255) DEFAULT NULL,
  `import_link` VARCHAR(500) DEFAULT NULL,
  `thumbnail` VARCHAR(500) DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `published_at` DATETIME DEFAULT NULL,
  `deleted_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_products_slug` (`slug`),
  UNIQUE KEY `uq_products_product_code` (`product_code`),
  KEY `idx_products_category_active` (`category_id`,`is_active`),
  KEY `idx_products_product_type_active` (`product_type_id`,`is_active`),
  KEY `idx_products_style_active` (`style_id`,`is_active`),
  KEY `idx_products_gender_active` (`gender`,`is_active`),
  CONSTRAINT `fk_products_category`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_products_product_type`
    FOREIGN KEY (`product_type_id`) REFERENCES `product_types` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_products_style`
    FOREIGN KEY (`style_id`) REFERENCES `styles` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `product_images` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` INT UNSIGNED NOT NULL,
  `image_url` VARCHAR(500) NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_images_product_sort` (`product_id`,`sort_order`),
  CONSTRAINT `fk_product_images_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `product_condition_maps` (
  `product_id` INT UNSIGNED NOT NULL,
  `condition_id` INT UNSIGNED NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`,`condition_id`),
  KEY `idx_product_condition_maps_condition` (`condition_id`),
  CONSTRAINT `fk_product_condition_maps_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_product_condition_maps_condition`
    FOREIGN KEY (`condition_id`) REFERENCES `product_conditions` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `product_variants` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` INT UNSIGNED NOT NULL,
  `sku` VARCHAR(120) NOT NULL,
  `variant_name` VARCHAR(150) DEFAULT NULL,
  `size_value` VARCHAR(50) DEFAULT NULL,
  `color_value` VARCHAR(50) DEFAULT NULL,
  `original_price` DECIMAL(12,2) DEFAULT NULL,
  `sale_price` DECIMAL(12,2) DEFAULT NULL,
  `purchase_price` DECIMAL(12,2) DEFAULT NULL,
  `stock_qty` INT NOT NULL DEFAULT 0,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `is_default` TINYINT(1) NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_variants_sku` (`sku`),
  KEY `idx_product_variants_product_active` (`product_id`,`is_active`),
  KEY `idx_product_variants_product_default` (`product_id`,`is_default`),
  CONSTRAINT `fk_product_variants_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `inventory_movements` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` INT UNSIGNED NOT NULL,
  `variant_id` INT UNSIGNED DEFAULT NULL,
  `movement_type` ENUM('purchase','sale_reserve','sale_commit','sale_release','return_in','return_out','manual_adjustment') NOT NULL,
  `quantity_change` INT NOT NULL,
  `stock_after` INT DEFAULT NULL,
  `source_type` ENUM('order','admin','import','refund','system') DEFAULT NULL,
  `source_id` INT UNSIGNED DEFAULT NULL,
  `note` VARCHAR(255) DEFAULT NULL,
  `created_by_admin_id` INT UNSIGNED DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_inventory_movements_product_date` (`product_id`,`created_at`),
  KEY `idx_inventory_movements_variant_date` (`variant_id`,`created_at`),
  KEY `idx_inventory_movements_source` (`source_type`,`source_id`),
  CONSTRAINT `fk_inventory_movements_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_inventory_movements_variant`
    FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_inventory_movements_admin`
    FOREIGN KEY (`created_by_admin_id`) REFERENCES `admins` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------
-- Customers/auth
-- ---------------------------------------------------------
CREATE TABLE `customers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_code` VARCHAR(30) NOT NULL,
  `full_name` VARCHAR(150) NOT NULL,
  `email` VARCHAR(190) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `password_hash` VARCHAR(255) DEFAULT NULL,
  `avatar_url` VARCHAR(500) DEFAULT NULL,
  `birth_date` DATE DEFAULT NULL,
  `gender` VARCHAR(20) DEFAULT NULL,
  `status` ENUM('active','locked','disabled') NOT NULL DEFAULT 'active',
  `registered_via` ENUM('local','google','facebook','admin') NOT NULL DEFAULT 'local',
  `email_verified_at` DATETIME DEFAULT NULL,
  `phone_verified_at` DATETIME DEFAULT NULL,
  `last_login_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_customers_customer_code` (`customer_code`),
  UNIQUE KEY `uq_customers_email` (`email`),
  UNIQUE KEY `uq_customers_phone` (`phone`),
  KEY `idx_customers_status` (`status`),
  KEY `idx_customers_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `customer_oauth_accounts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `provider` ENUM('google','facebook') NOT NULL,
  `provider_user_id` VARCHAR(191) NOT NULL,
  `provider_email` VARCHAR(190) DEFAULT NULL,
  `provider_name` VARCHAR(150) DEFAULT NULL,
  `avatar_url` VARCHAR(500) DEFAULT NULL,
  `access_token_encrypted` TEXT DEFAULT NULL,
  `refresh_token_encrypted` TEXT DEFAULT NULL,
  `token_expires_at` DATETIME DEFAULT NULL,
  `linked_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_used_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_customer_oauth_provider_uid` (`provider`,`provider_user_id`),
  KEY `idx_customer_oauth_customer` (`customer_id`),
  CONSTRAINT `fk_customer_oauth_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `customer_addresses` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `label` VARCHAR(50) DEFAULT NULL,
  `receiver_name` VARCHAR(150) NOT NULL,
  `receiver_phone` VARCHAR(20) NOT NULL,
  `province_code` VARCHAR(20) DEFAULT NULL,
  `province_name` VARCHAR(100) NOT NULL,
  `district_code` VARCHAR(20) DEFAULT NULL,
  `district_name` VARCHAR(100) NOT NULL,
  `ward_code` VARCHAR(20) DEFAULT NULL,
  `ward_name` VARCHAR(100) NOT NULL,
  `address_line` VARCHAR(255) NOT NULL,
  `address_note` VARCHAR(255) DEFAULT NULL,
  `is_default_shipping` TINYINT(1) NOT NULL DEFAULT 0,
  `is_default_billing` TINYINT(1) NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customer_addresses_customer_active` (`customer_id`,`is_active`),
  KEY `idx_customer_addresses_default_shipping` (`customer_id`,`is_default_shipping`),
  KEY `idx_customer_addresses_default_billing` (`customer_id`,`is_default_billing`),
  CONSTRAINT `fk_customer_addresses_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `customer_sessions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `session_token_hash` CHAR(64) NOT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` VARCHAR(255) DEFAULT NULL,
  `last_seen_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` DATETIME NOT NULL,
  `revoked_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_customer_sessions_token` (`session_token_hash`),
  KEY `idx_customer_sessions_customer_expires` (`customer_id`,`expires_at`),
  CONSTRAINT `fk_customer_sessions_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `customer_auth_tokens` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `token_type` ENUM('password_reset','email_verify','phone_verify') NOT NULL,
  `token_hash` CHAR(64) NOT NULL,
  `expires_at` DATETIME NOT NULL,
  `used_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_customer_auth_tokens_hash` (`token_hash`),
  KEY `idx_customer_auth_tokens_customer_type` (`customer_id`,`token_type`),
  CONSTRAINT `fk_customer_auth_tokens_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `customer_security_logs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED DEFAULT NULL,
  `event_type` VARCHAR(50) NOT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` VARCHAR(255) DEFAULT NULL,
  `meta_text` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customer_security_logs_customer_date` (`customer_id`,`created_at`),
  KEY `idx_customer_security_logs_event_date` (`event_type`,`created_at`),
  CONSTRAINT `fk_customer_security_logs_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------
-- Cart
-- ---------------------------------------------------------
CREATE TABLE `carts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED DEFAULT NULL,
  `guest_token` CHAR(64) DEFAULT NULL,
  `status` ENUM('active','converted','abandoned') NOT NULL DEFAULT 'active',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expired_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_carts_guest_token` (`guest_token`),
  KEY `idx_carts_customer_status` (`customer_id`,`status`),
  CONSTRAINT `fk_carts_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cart_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cart_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `variant_id` INT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price_snapshot` DECIMAL(12,2) NOT NULL,
  `sale_price_snapshot` DECIMAL(12,2) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cart_items_cart_variant` (`cart_id`,`variant_id`),
  KEY `idx_cart_items_product` (`product_id`),
  CONSTRAINT `fk_cart_items_cart`
    FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_cart_items_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_cart_items_variant`
    FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------
-- Orders
-- ---------------------------------------------------------
CREATE TABLE `orders` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_code` VARCHAR(30) NOT NULL,
  `customer_id` INT UNSIGNED DEFAULT NULL,
  `cart_id` INT UNSIGNED DEFAULT NULL,
  `checkout_type` ENUM('guest','account') NOT NULL,
  `purchase_channel` ENUM('web','zalo','admin') NOT NULL,
  `order_source` ENUM('product','cart','manual') NOT NULL DEFAULT 'product',
  `contact_name` VARCHAR(150) NOT NULL,
  `contact_phone` VARCHAR(20) NOT NULL,
  `contact_email` VARCHAR(190) DEFAULT NULL,
  `customer_note` VARCHAR(500) DEFAULT NULL,
  `internal_note` TEXT DEFAULT NULL,
  `subtotal_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `shipping_fee` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `total_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `payment_plan` ENUM('full','deposit_30','zalo_manual') NOT NULL,
  `deposit_rate` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `deposit_required_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `paid_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `remaining_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `payment_status` ENUM('chua_thanh_toan','da_dat_coc','da_thanh_toan','cho_hoan_tien','da_hoan_tien') NOT NULL DEFAULT 'chua_thanh_toan',
  `order_status` ENUM('cho_xac_nhan','dang_chuan_bi','dang_giao','da_giao','da_huy','tra_hang') NOT NULL DEFAULT 'cho_xac_nhan',
  `guest_access_token` CHAR(64) DEFAULT NULL,
  `placed_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `confirmed_at` DATETIME DEFAULT NULL,
  `completed_at` DATETIME DEFAULT NULL,
  `cancelled_at` DATETIME DEFAULT NULL,
  `cancel_reason` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_orders_order_code` (`order_code`),
  UNIQUE KEY `uq_orders_guest_access_token` (`guest_access_token`),
  KEY `idx_orders_customer_date` (`customer_id`,`created_at`),
  KEY `idx_orders_statuses` (`order_status`,`payment_status`),
  KEY `idx_orders_channel_date` (`purchase_channel`,`created_at`),
  KEY `idx_orders_cart` (`cart_id`),
  CONSTRAINT `fk_orders_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_orders_cart`
    FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `order_addresses` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` INT UNSIGNED NOT NULL,
  `address_type` ENUM('shipping','billing') NOT NULL,
  `source_type` ENUM('manual','account_saved') NOT NULL,
  `source_address_id` INT UNSIGNED DEFAULT NULL,
  `receiver_name` VARCHAR(150) NOT NULL,
  `receiver_phone` VARCHAR(20) NOT NULL,
  `province_name` VARCHAR(100) NOT NULL,
  `district_name` VARCHAR(100) NOT NULL,
  `ward_name` VARCHAR(100) NOT NULL,
  `address_line` VARCHAR(255) NOT NULL,
  `address_note` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_addresses_order_type` (`order_id`,`address_type`),
  KEY `idx_order_addresses_source` (`source_address_id`),
  CONSTRAINT `fk_order_addresses_order`
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_order_addresses_source_address`
    FOREIGN KEY (`source_address_id`) REFERENCES `customer_addresses` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `order_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `variant_id` INT UNSIGNED NOT NULL,
  `product_name_snapshot` VARCHAR(255) NOT NULL,
  `product_code_snapshot` VARCHAR(100) NOT NULL,
  `sku_snapshot` VARCHAR(120) DEFAULT NULL,
  `variant_name_snapshot` VARCHAR(150) DEFAULT NULL,
  `size_snapshot` VARCHAR(50) DEFAULT NULL,
  `color_snapshot` VARCHAR(50) DEFAULT NULL,
  `thumbnail_snapshot` VARCHAR(500) DEFAULT NULL,
  `quantity` INT NOT NULL,
  `original_unit_price` DECIMAL(12,2) NOT NULL,
  `final_unit_price` DECIMAL(12,2) NOT NULL,
  `line_total` DECIMAL(12,2) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_items_order` (`order_id`),
  KEY `idx_order_items_product` (`product_id`),
  KEY `idx_order_items_variant` (`variant_id`),
  CONSTRAINT `fk_order_items_order`
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_order_items_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_order_items_variant`
    FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `order_status_logs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` INT UNSIGNED NOT NULL,
  `from_status` VARCHAR(30) DEFAULT NULL,
  `to_status` VARCHAR(30) NOT NULL,
  `note` VARCHAR(255) DEFAULT NULL,
  `changed_by_type` ENUM('system','admin','customer','webhook') NOT NULL,
  `changed_by_id` INT UNSIGNED DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_status_logs_order_date` (`order_id`,`created_at`),
  CONSTRAINT `fk_order_status_logs_order`
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------
-- Payments / SePay / callbacks
-- ---------------------------------------------------------
CREATE TABLE `payment_intents` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `intent_code` VARCHAR(40) NOT NULL,
  `customer_id` INT UNSIGNED DEFAULT NULL,
  `order_id` INT UNSIGNED DEFAULT NULL,
  `provider` ENUM('sepay','wallet','cod','manual') NOT NULL,
  `purpose` ENUM('order_full','order_deposit','order_remaining','wallet_topup') NOT NULL,
  `requested_amount` DECIMAL(12,2) NOT NULL,
  `currency_code` CHAR(3) NOT NULL DEFAULT 'VND',
  `status` ENUM('pending','waiting_payment','paid','failed','expired','cancelled') NOT NULL DEFAULT 'pending',
  `qr_content` TEXT DEFAULT NULL,
  `qr_image_url` VARCHAR(500) DEFAULT NULL,
  `transfer_note` VARCHAR(120) DEFAULT NULL,
  `expires_at` DATETIME DEFAULT NULL,
  `idempotency_key` VARCHAR(100) DEFAULT NULL,
  `metadata_text` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payment_intents_intent_code` (`intent_code`),
  UNIQUE KEY `uq_payment_intents_idempotency_key` (`idempotency_key`),
  KEY `idx_payment_intents_order_status` (`order_id`,`status`),
  KEY `idx_payment_intents_customer_status` (`customer_id`,`status`),
  CONSTRAINT `fk_payment_intents_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_payment_intents_order`
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `payment_intent_id` INT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED DEFAULT NULL,
  `order_id` INT UNSIGNED DEFAULT NULL,
  `provider` ENUM('sepay','wallet','cod','manual') NOT NULL,
  `provider_transaction_id` VARCHAR(100) NOT NULL,
  `provider_reference_code` VARCHAR(100) DEFAULT NULL,
  `transfer_type` ENUM('in','out') DEFAULT NULL,
  `paid_amount` DECIMAL(12,2) NOT NULL,
  `fee_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `net_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `payment_status` ENUM('success','failed','pending','reversed') NOT NULL,
  `raw_content` VARCHAR(500) DEFAULT NULL,
  `paid_at` DATETIME DEFAULT NULL,
  `confirmed_at` DATETIME DEFAULT NULL,
  `raw_payload_text` LONGTEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payments_provider_txn` (`provider`,`provider_transaction_id`),
  KEY `idx_payments_payment_intent` (`payment_intent_id`),
  KEY `idx_payments_order` (`order_id`),
  KEY `idx_payments_customer` (`customer_id`),
  CONSTRAINT `fk_payments_payment_intent`
    FOREIGN KEY (`payment_intent_id`) REFERENCES `payment_intents` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_payments_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_payments_order`
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payment_webhook_logs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `provider` ENUM('sepay') NOT NULL,
  `event_key` VARCHAR(150) NOT NULL,
  `provider_transaction_id` VARCHAR(100) DEFAULT NULL,
  `request_headers_text` LONGTEXT DEFAULT NULL,
  `request_body_text` LONGTEXT NOT NULL,
  `parsed_amount` DECIMAL(12,2) DEFAULT NULL,
  `parsed_reference_code` VARCHAR(100) DEFAULT NULL,
  `parsed_transfer_type` VARCHAR(20) DEFAULT NULL,
  `process_status` ENUM('received','ignored','processed','failed','duplicate') NOT NULL DEFAULT 'received',
  `linked_payment_id` INT UNSIGNED DEFAULT NULL,
  `error_message` TEXT DEFAULT NULL,
  `processed_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payment_webhook_logs_provider_event` (`provider`,`event_key`),
  KEY `idx_payment_webhook_logs_provider_txn` (`provider_transaction_id`),
  KEY `idx_payment_webhook_logs_status` (`process_status`),
  CONSTRAINT `fk_payment_webhook_logs_payment`
    FOREIGN KEY (`linked_payment_id`) REFERENCES `payments` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------
-- Wallet
-- ---------------------------------------------------------
CREATE TABLE `wallet_accounts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `status` ENUM('active','locked','disabled') NOT NULL DEFAULT 'active',
  `balance_cached` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `total_credited` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `total_debited` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_wallet_accounts_customer` (`customer_id`),
  KEY `idx_wallet_accounts_status` (`status`),
  CONSTRAINT `fk_wallet_accounts_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `wallet_topup_requests` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `topup_code` VARCHAR(40) NOT NULL,
  `requested_amount` DECIMAL(12,2) NOT NULL,
  `status` ENUM('pending','waiting_payment','confirmed','expired','cancelled','failed') NOT NULL DEFAULT 'pending',
  `payment_intent_id` INT UNSIGNED DEFAULT NULL,
  `note` VARCHAR(255) DEFAULT NULL,
  `expires_at` DATETIME DEFAULT NULL,
  `confirmed_at` DATETIME DEFAULT NULL,
  `cancelled_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_wallet_topup_requests_topup_code` (`topup_code`),
  UNIQUE KEY `uq_wallet_topup_requests_payment_intent` (`payment_intent_id`),
  KEY `idx_wallet_topup_requests_customer_status` (`customer_id`,`status`),
  CONSTRAINT `fk_wallet_topup_requests_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_wallet_topup_requests_payment_intent`
    FOREIGN KEY (`payment_intent_id`) REFERENCES `payment_intents` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `wallet_ledger` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `wallet_account_id` INT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED NOT NULL,
  `entry_type` ENUM('topup_credit','order_debit','refund_credit','admin_adjustment','reversal') NOT NULL,
  `source_type` ENUM('wallet_topup','order','refund','admin') NOT NULL,
  `source_id` INT UNSIGNED NOT NULL,
  `amount_change` DECIMAL(12,2) NOT NULL,
  `balance_before` DECIMAL(12,2) NOT NULL,
  `balance_after` DECIMAL(12,2) NOT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `related_payment_id` INT UNSIGNED DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_wallet_ledger_wallet_date` (`wallet_account_id`,`created_at`),
  KEY `idx_wallet_ledger_customer_date` (`customer_id`,`created_at`),
  KEY `idx_wallet_ledger_source` (`source_type`,`source_id`),
  KEY `idx_wallet_ledger_payment` (`related_payment_id`),
  CONSTRAINT `fk_wallet_ledger_wallet_account`
    FOREIGN KEY (`wallet_account_id`) REFERENCES `wallet_accounts` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_wallet_ledger_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_wallet_ledger_related_payment`
    FOREIGN KEY (`related_payment_id`) REFERENCES `payments` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------
-- Admin audit
-- ---------------------------------------------------------
CREATE TABLE `admin_audit_logs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_id` INT UNSIGNED DEFAULT NULL,
  `action` VARCHAR(50) NOT NULL,
  `target_table` VARCHAR(50) NOT NULL,
  `target_id` INT UNSIGNED NOT NULL,
  `before_data_text` LONGTEXT DEFAULT NULL,
  `after_data_text` LONGTEXT DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_admin_audit_logs_admin_date` (`admin_id`,`created_at`),
  KEY `idx_admin_audit_logs_target` (`target_table`,`target_id`),
  CONSTRAINT `fk_admin_audit_logs_admin`
    FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------
-- Default application settings
-- ---------------------------------------------------------
INSERT INTO `app_settings` (`setting_key`, `setting_value`) VALUES
('shop_name', 'Duong Mot Mi SHOP'),
('shop_tagline', 'Khám phá phong cách thời trang trẻ trung, hiện đại. Chúng tôi cam kết mang đến cho bạn những sản phẩm chất lượng với dịch vụ chốt đơn nhanh chóng, tận tâm.'),
('shop_logo', 'img/logo.jpg'),
('shop_phone', '0961.691.107'),
('shop_email', ''),
('shop_address', 'Sớm cập nhật'),
('shop_working_hours', '08:00 - 22:00 (T2 - CN)'),
('default_deposit_rate', '30'),
('enable_guest_checkout', '1'),
('enable_wallet', '1'),
('enable_social_login_google', '1'),
('enable_social_login_facebook', '1'),
('zalo_contact_link', 'https://zalo.me/0961691107'),
('zalo_group_link', ''),
('facebook_link', ''),
('instagram_link', ''),
('tiktok_link', ''),
('sepay_bank_name', ''),
('sepay_bank_account_no', ''),
('sepay_account_name', '');

SET FOREIGN_KEY_CHECKS = 1;
