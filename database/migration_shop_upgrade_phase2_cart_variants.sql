-- Phase 2: giỏ hàng nhiều sản phẩm + biến thể màu/size
-- Chạy sau migration_shop_upgrade_phase1.sql

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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

ALTER TABLE cart_items
    MODIFY COLUMN variant_id INT NULL;

ALTER TABLE order_items
    MODIFY COLUMN variant_id INT NULL;

CREATE INDEX idx_cart_items_variant ON cart_items (variant_id);
CREATE INDEX idx_order_items_variant ON order_items (variant_id);

INSERT INTO product_variants (
    product_id, sku, variant_name, size_value, color_value,
    original_price, sale_price, purchase_price, stock_qty,
    image_url, is_default, is_active, created_at, updated_at
)
SELECT
    p.id,
    CONCAT(UPPER(REPLACE(REPLACE(REPLACE(p.product_code, ' ', ''), '-', ''), '/', '')), '-DFT-', p.id),
    CONCAT_WS(' / ', NULLIF(TRIM(p.color), ''), NULLIF(TRIM(p.size), '')),
    NULLIF(TRIM(p.size), ''),
    NULLIF(TRIM(p.color), ''),
    p.original_price,
    p.sale_price,
    p.purchase_price,
    COALESCE(p.quantity, 0),
    p.thumbnail,
    1,
    1,
    NOW(),
    NOW()
FROM products p
LEFT JOIN product_variants pv ON pv.product_id = p.id
WHERE pv.id IS NULL;

UPDATE products p
JOIN (
    SELECT
        product_id,
        COALESCE(SUM(stock_qty), 0) AS total_qty,
        GROUP_CONCAT(DISTINCT NULLIF(TRIM(size_value), '') ORDER BY size_value ASC SEPARATOR ', ') AS size_list,
        GROUP_CONCAT(DISTINCT NULLIF(TRIM(color_value), '') ORDER BY color_value ASC SEPARATOR ', ') AS color_list
    FROM product_variants
    WHERE is_active = 1
    GROUP BY product_id
) v ON v.product_id = p.id
SET p.quantity = v.total_qty,
    p.size = COALESCE(NULLIF(v.size_list, ''), p.size),
    p.color = COALESCE(NULLIF(v.color_list, ''), p.color);

SET FOREIGN_KEY_CHECKS = 1;
