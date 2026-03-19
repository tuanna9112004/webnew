-- PHASE 3: giao diện chọn biến thể kiểu app + ma trận màu/size + app_settings
USE `clothing_shop`;

-- 1) Nếu sản phẩm cũ chưa có biến thể nào, tạo một biến thể mặc định để giữ dữ liệu trước khi bỏ cột size/color
INSERT INTO product_variants (
    product_id, sku, variant_name, size_value, color_value,
    original_price, sale_price, purchase_price, stock_qty, image_url,
    is_default, is_active, created_at, updated_at
)
SELECT
    p.id,
    CONCAT(UPPER(REPLACE(REPLACE(p.product_code, ' ', ''), '-', '')), '-DFT'),
    'Mặc định',
    NULLIF(TRIM(p.size), ''),
    NULLIF(TRIM(p.color), ''),
    p.original_price,
    p.sale_price,
    p.purchase_price,
    p.quantity,
    p.thumbnail,
    1,
    1,
    NOW(),
    NOW()
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM product_variants pv WHERE pv.product_id = p.id
);

-- 2) Đồng bộ lại tổng tồn kho từ biến thể
UPDATE products p
JOIN (
    SELECT product_id, COALESCE(SUM(stock_qty), 0) AS total_qty
    FROM product_variants
    WHERE is_active = 1
    GROUP BY product_id
) x ON x.product_id = p.id
SET p.quantity = x.total_qty;

-- 3) Bỏ cột size và color khỏi products vì từ nay dùng product_variants
ALTER TABLE products
    DROP COLUMN size,
    DROP COLUMN color;

-- 4) Áp dụng app_settings thay cho hard-code
INSERT INTO app_settings (setting_key, setting_value) VALUES
('shop_name', 'Duong Mot Mi SHOP'),
('shop_tagline', 'Khám phá phong cách thời trang trẻ trung, hiện đại. Chúng tôi cam kết mang đến cho bạn những sản phẩm chất lượng với dịch vụ chốt đơn nhanh chóng, tận tâm.'),
('shop_logo', 'img/logo.jpg'),
('shop_phone', '0961.691.107'),
('shop_address', 'Sớm cập nhật'),
('shop_working_hours', '08:00 - 22:00 (T2 - CN)'),
('default_deposit_rate', '30'),
('zalo_contact_link', 'https://zalo.me/0961691107')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);
