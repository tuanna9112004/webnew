-- Migration nâng cấp từ project catalog hiện tại lên phase 1: customer + checkout + order + payment callback
-- Khuyên backup DB trước khi chạy.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE products
    ADD COLUMN IF NOT EXISTS slug VARCHAR(180) NULL AFTER product_name,
    ADD COLUMN IF NOT EXISTS track_inventory TINYINT(1) NOT NULL DEFAULT 1 AFTER quantity,
    ADD COLUMN IF NOT EXISTS allow_backorder TINYINT(1) NOT NULL DEFAULT 0 AFTER track_inventory,
    ADD COLUMN IF NOT EXISTS min_stock_alert INT NOT NULL DEFAULT 0 AFTER allow_backorder,
    ADD COLUMN IF NOT EXISTS supplier_contact VARCHAR(255) NULL AFTER import_link,
    ADD COLUMN IF NOT EXISTS published_at DATETIME NULL AFTER is_active,
    ADD COLUMN IF NOT EXISTS deleted_at DATETIME NULL AFTER published_at;

CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_code VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(190) NULL UNIQUE,
    phone VARCHAR(20) NULL UNIQUE,
    password_hash VARCHAR(255) NULL,
    avatar_url VARCHAR(500) NULL,
    birth_date DATE NULL,
    gender VARCHAR(20) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    registered_via VARCHAR(20) NOT NULL DEFAULT 'local',
    email_verified_at DATETIME NULL,
    phone_verified_at DATETIME NULL,
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS customer_oauth_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    provider VARCHAR(20) NOT NULL,
    provider_user_id VARCHAR(191) NOT NULL,
    provider_email VARCHAR(190) NULL,
    provider_name VARCHAR(150) NULL,
    avatar_url VARCHAR(500) NULL,
    access_token_encrypted TEXT NULL,
    refresh_token_encrypted TEXT NULL,
    token_expires_at DATETIME NULL,
    linked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_used_at DATETIME NULL,
    UNIQUE KEY uq_customer_oauth_provider_user (provider, provider_user_id),
    KEY idx_customer_oauth_customer (customer_id),
    CONSTRAINT fk_customer_oauth_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS customer_addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    label VARCHAR(50) NULL,
    receiver_name VARCHAR(150) NOT NULL,
    receiver_phone VARCHAR(20) NOT NULL,
    province_code VARCHAR(20) NULL,
    province_name VARCHAR(100) NOT NULL,
    district_code VARCHAR(20) NULL,
    district_name VARCHAR(100) NOT NULL,
    ward_code VARCHAR(20) NULL,
    ward_name VARCHAR(100) NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    address_note VARCHAR(255) NULL,
    is_default_shipping TINYINT(1) NOT NULL DEFAULT 0,
    is_default_billing TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_customer_addresses_customer (customer_id),
    CONSTRAINT fk_customer_addresses_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS customer_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    session_token_hash CHAR(64) NOT NULL UNIQUE,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    last_seen_at DATETIME NOT NULL,
    expires_at DATETIME NOT NULL,
    revoked_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_customer_sessions_customer (customer_id),
    CONSTRAINT fk_customer_sessions_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS customer_auth_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    token_type VARCHAR(30) NOT NULL,
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_customer_auth_tokens_customer (customer_id),
    CONSTRAINT fk_customer_auth_tokens_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS customer_security_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    event_type VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    meta_text TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_customer_security_logs_customer (customer_id),
    CONSTRAINT fk_customer_security_logs_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS carts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    guest_token CHAR(64) NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expired_at DATETIME NULL,
    KEY idx_carts_customer (customer_id),
    CONSTRAINT fk_carts_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT NULL,
    quantity INT NOT NULL,
    unit_price_snapshot DECIMAL(12,2) NOT NULL,
    sale_price_snapshot DECIMAL(12,2) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_cart_item (cart_id, product_id, variant_id),
    KEY idx_cart_items_product (product_id),
    CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_code VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NULL,
    cart_id INT NULL,
    checkout_type VARCHAR(20) NOT NULL,
    purchase_channel VARCHAR(20) NOT NULL,
    order_source VARCHAR(30) NOT NULL DEFAULT 'product',
    contact_name VARCHAR(150) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    contact_email VARCHAR(190) NULL,
    customer_note VARCHAR(500) NULL,
    internal_note TEXT NULL,
    subtotal_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    shipping_fee DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    payment_plan VARCHAR(20) NOT NULL,
    deposit_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
    deposit_required_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    paid_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    remaining_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'chua_thanh_toan',
    order_status VARCHAR(30) NOT NULL DEFAULT 'cho_xac_nhan',
    guest_access_token CHAR(64) NULL UNIQUE,
    placed_at DATETIME NOT NULL,
    confirmed_at DATETIME NULL,
    completed_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    cancel_reason VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_orders_customer (customer_id, created_at),
    KEY idx_orders_status (order_status, payment_status),
    KEY idx_orders_channel (purchase_channel, created_at),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    CONSTRAINT fk_orders_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    address_type VARCHAR(20) NOT NULL,
    source_type VARCHAR(20) NOT NULL,
    source_address_id INT NULL,
    receiver_name VARCHAR(150) NOT NULL,
    receiver_phone VARCHAR(20) NOT NULL,
    province_name VARCHAR(100) NOT NULL,
    district_name VARCHAR(100) NOT NULL,
    ward_name VARCHAR(100) NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    address_note VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_order_addresses_order (order_id),
    CONSTRAINT fk_order_addresses_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_addresses_source FOREIGN KEY (source_address_id) REFERENCES customer_addresses(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT NULL,
    product_name_snapshot VARCHAR(255) NOT NULL,
    product_code_snapshot VARCHAR(100) NOT NULL,
    sku_snapshot VARCHAR(120) NULL,
    variant_name_snapshot VARCHAR(150) NULL,
    size_snapshot VARCHAR(50) NULL,
    color_snapshot VARCHAR(50) NULL,
    thumbnail_snapshot VARCHAR(500) NULL,
    quantity INT NOT NULL,
    original_unit_price DECIMAL(12,2) NOT NULL,
    final_unit_price DECIMAL(12,2) NOT NULL,
    line_total DECIMAL(12,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_order_items_order (order_id),
    KEY idx_order_items_product (product_id),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_status_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    from_status VARCHAR(30) NULL,
    to_status VARCHAR(30) NOT NULL,
    note VARCHAR(255) NULL,
    changed_by_type VARCHAR(20) NOT NULL,
    changed_by_id INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_order_status_logs_order (order_id),
    CONSTRAINT fk_order_status_logs_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payment_intents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    intent_code VARCHAR(40) NOT NULL UNIQUE,
    customer_id INT NULL,
    order_id INT NULL,
    wallet_topup_request_id INT NULL,
    provider VARCHAR(20) NOT NULL,
    purpose VARCHAR(30) NOT NULL,
    requested_amount DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'VND',
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    qr_content TEXT NULL,
    qr_image_url VARCHAR(500) NULL,
    transfer_note VARCHAR(120) NULL,
    expires_at DATETIME NULL,
    idempotency_key VARCHAR(100) NULL UNIQUE,
    metadata_text TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_payment_intents_order (order_id, status),
    CONSTRAINT fk_payment_intents_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    CONSTRAINT fk_payment_intents_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payment_intent_id INT NOT NULL,
    customer_id INT NULL,
    order_id INT NULL,
    provider VARCHAR(20) NOT NULL,
    provider_transaction_id VARCHAR(100) NOT NULL,
    provider_reference_code VARCHAR(100) NULL,
    transfer_type VARCHAR(20) NULL,
    paid_amount DECIMAL(12,2) NOT NULL,
    fee_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    net_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    payment_status VARCHAR(20) NOT NULL,
    raw_content VARCHAR(500) NULL,
    paid_at DATETIME NULL,
    confirmed_at DATETIME NULL,
    raw_payload_text LONGTEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_payments_provider_txn (provider, provider_transaction_id),
    KEY idx_payments_intent (payment_intent_id),
    KEY idx_payments_order (order_id),
    CONSTRAINT fk_payments_intent FOREIGN KEY (payment_intent_id) REFERENCES payment_intents(id) ON DELETE CASCADE,
    CONSTRAINT fk_payments_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payment_webhook_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provider VARCHAR(20) NOT NULL,
    event_key VARCHAR(150) NOT NULL,
    provider_transaction_id VARCHAR(100) NULL,
    request_headers_text LONGTEXT NULL,
    request_body_text LONGTEXT NOT NULL,
    parsed_amount DECIMAL(12,2) NULL,
    parsed_reference_code VARCHAR(100) NULL,
    parsed_transfer_type VARCHAR(20) NULL,
    process_status VARCHAR(20) NOT NULL DEFAULT 'received',
    linked_payment_id INT NULL,
    error_message TEXT NULL,
    processed_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_webhook_event (provider, event_key),
    KEY idx_webhook_transaction (provider_transaction_id),
    KEY idx_webhook_status (process_status),
    CONSTRAINT fk_webhook_payment FOREIGN KEY (linked_payment_id) REFERENCES payments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wallet_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    balance_cached DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_credited DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_debited DECIMAL(12,2) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_wallet_accounts_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wallet_topup_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    topup_code VARCHAR(40) NOT NULL UNIQUE,
    requested_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    payment_intent_id INT NULL UNIQUE,
    note VARCHAR(255) NULL,
    expires_at DATETIME NULL,
    confirmed_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_wallet_topups_customer (customer_id, status),
    CONSTRAINT fk_wallet_topups_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CONSTRAINT fk_wallet_topups_intent FOREIGN KEY (payment_intent_id) REFERENCES payment_intents(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wallet_ledger (
    id INT AUTO_INCREMENT PRIMARY KEY,
    wallet_account_id INT NOT NULL,
    customer_id INT NOT NULL,
    entry_type VARCHAR(30) NOT NULL,
    source_type VARCHAR(30) NOT NULL,
    source_id INT NOT NULL,
    amount_change DECIMAL(12,2) NOT NULL,
    balance_before DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    description VARCHAR(255) NULL,
    related_payment_id INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_wallet_ledger_wallet (wallet_account_id, created_at),
    KEY idx_wallet_ledger_customer (customer_id, created_at),
    CONSTRAINT fk_wallet_ledger_wallet FOREIGN KEY (wallet_account_id) REFERENCES wallet_accounts(id) ON DELETE CASCADE,
    CONSTRAINT fk_wallet_ledger_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CONSTRAINT fk_wallet_ledger_payment FOREIGN KEY (related_payment_id) REFERENCES payments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS product_variants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sku VARCHAR(120) NOT NULL UNIQUE,
    variant_name VARCHAR(150) NULL,
    size_value VARCHAR(50) NULL,
    color_value VARCHAR(50) NULL,
    original_price DECIMAL(12,2) NULL,
    sale_price DECIMAL(12,2) NULL,
    purchase_price DECIMAL(12,2) NULL,
    stock_qty INT NOT NULL DEFAULT 0,
    image_url VARCHAR(500) NULL,
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_product_variants_product (product_id, is_active),
    CONSTRAINT fk_product_variants_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS inventory_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    variant_id INT NULL,
    movement_type VARCHAR(30) NOT NULL,
    quantity_change INT NOT NULL,
    stock_after INT NULL,
    source_type VARCHAR(30) NULL,
    source_id INT NULL,
    note VARCHAR(255) NULL,
    created_by_admin_id INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_inventory_movements_product (product_id, created_at),
    CONSTRAINT fk_inventory_movements_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_movements_variant FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL,
    CONSTRAINT fk_inventory_movements_admin FOREIGN KEY (created_by_admin_id) REFERENCES admins(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS admin_audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NULL,
    action VARCHAR(50) NOT NULL,
    target_table VARCHAR(50) NOT NULL,
    target_id INT NOT NULL,
    before_data_text LONGTEXT NULL,
    after_data_text LONGTEXT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_admin_audit_admin (admin_id),
    CONSTRAINT fk_admin_audit_admin FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS app_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT NOT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO app_settings (setting_key, setting_value) VALUES
('default_deposit_rate', '30'),
('enable_guest_checkout', '1'),
('enable_wallet', '1'),
('zalo_contact_link', 'https://zalo.me/0961691107'),
('sepay_bank_name', 'Cau hinh ten ngan hang'),
('sepay_bank_account_no', 'Cau hinh so tai khoan'),
('sepay_account_name', 'DUONG MOT MI SHOP')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_at = CURRENT_TIMESTAMP;

SET FOREIGN_KEY_CHECKS = 1;
