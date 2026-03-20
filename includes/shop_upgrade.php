<?php

function table_exists(string $tableName): bool
{
    static $cache = [];
    if (array_key_exists($tableName, $cache)) {
        return $cache[$tableName];
    }

    $stmt = db()->prepare('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?');
    $stmt->execute([$tableName]);
    $cache[$tableName] = (bool)$stmt->fetchColumn();
    return $cache[$tableName];
}

function require_upgrade_tables(array $tables): array
{
    $missing = [];
    foreach ($tables as $table) {
        if (!table_exists($table)) {
            $missing[] = $table;
        }
    }
    return $missing;
}

function column_exists(string $tableName, string $columnName): bool
{
    static $cache = [];
    $key = $tableName . '.' . $columnName;
    if (array_key_exists($key, $cache)) {
        return $cache[$key];
    }

    $stmt = db()->prepare('SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ?');
    $stmt->execute([$tableName, $columnName]);
    $cache[$key] = (bool)$stmt->fetchColumn();
    return $cache[$key];
}

function app_setting(string $key, ?string $default = null): ?string
{
    static $cache = [];
    if (!table_exists('app_settings')) {
        return $default;
    }
    if (array_key_exists($key, $cache)) {
        return $cache[$key];
    }
    $stmt = db()->prepare('SELECT setting_value FROM app_settings WHERE setting_key = ? LIMIT 1');
    $stmt->execute([$key]);
    $value = $stmt->fetchColumn();
    $cache[$key] = ($value === false || $value === null) ? $default : (string)$value;
    return $cache[$key];
}

function shop_setting(string $key, ?string $default = null): ?string
{
    return app_setting($key, $default);
}

function shop_name(): string
{
    return (string)shop_setting('shop_name', 'Duong Mot Mi SHOP');
}

function shop_tagline(): string
{
    return (string)shop_setting('shop_tagline', 'Thời trang tối giản, chốt đơn nhanh');
}

function shop_logo_url(): string
{
    return resolve_media_url((string)shop_setting('shop_logo', 'img/logoduongmotmi.jpg'));
}

function shop_zalo_link(): string
{
    return (string)shop_setting('zalo_contact_link', defined('ZALO_LINK') ? ZALO_LINK : 'https://zalo.me/');
}

function shop_setting_bool(string $key, bool $default = false): bool
{
    $fallback = $default ? '1' : '0';
    $value = strtolower((string)shop_setting($key, $fallback));
    return in_array($value, ['1', 'true', 'yes', 'on'], true);
}

function shop_social_link(string $platform, string $default = '#'): string
{
    $map = [
        'facebook' => 'facebook_link',
        'instagram' => 'instagram_link',
        'tiktok' => 'tiktok_link',
        'zalo_group' => 'zalo_group_link',
    ];
    $key = $map[$platform] ?? $platform;
    return (string)shop_setting($key, $default);
}

function shop_contact_email(): string
{
    return (string)shop_setting('shop_email', '');
}

function shop_deposit_rate(): int
{
    $fallback = defined('ORDER_DEPOSIT_RATE') ? (int)ORDER_DEPOSIT_RATE : 30;
    $value = (int)shop_setting('default_deposit_rate', (string)$fallback);
    if ($value <= 0 || $value > 100) {
        return $fallback;
    }
    return $value;
}

function sepay_bank_code(): string
{
    $code = trim((string)shop_setting('sepay_bank_code', ''));
    if ($code !== '') {
        return $code;
    }
    return trim((string)shop_setting('sepay_bank_name', 'MBBank')) ?: 'MBBank';
}

function sepay_bank_name(): string
{
    $name = trim((string)shop_setting('sepay_bank_name', ''));
    return $name !== '' ? $name : sepay_bank_code();
}

function sepay_bank_account_no(): string
{
    return trim((string)shop_setting('sepay_bank_account_no', ''));
}

function sepay_account_name(): string
{
    return trim((string)shop_setting('sepay_account_name', shop_name()));
}

function sepay_webhook_api_key(): string
{
    return trim((string)shop_setting('sepay_webhook_api_key', ''));
}

function sepay_expected_sub_account(): string
{
    return trim((string)shop_setting('sepay_expected_sub_account', sepay_bank_account_no()));
}

function sepay_qr_url(float $amount, string $transferNote): string
{
    $account = sepay_bank_account_no();
    if ($account === '') {
        return '';
    }

    $bankCode = sepay_bank_code();
    $params = http_build_query([
        'acc' => $account,
        'bank' => $bankCode,
        'amount' => (int)round($amount),
        'des' => $transferNote,
    ]);

    return 'https://qr.sepay.vn/img?' . $params;
}

function get_header_case_insensitive(array $headers, string $name): ?string
{
    foreach ($headers as $key => $value) {
        if (strcasecmp((string)$key, $name) === 0) {
            if (is_array($value)) {
                return (string)($value[0] ?? '');
            }
            return (string)$value;
        }
    }
    return null;
}

function split_variant_terms(string $input): array
{
    $input = str_replace(["\r\n", "\n", "\r"], ',', $input);
    $input = preg_replace('#\s*/\s*#u', ',', $input);
    $parts = array_map('trim', explode(',', $input));
    $result = [];
    foreach ($parts as $part) {
        if ($part === '') {
            continue;
        }
        $lower = mb_strtolower($part, 'UTF-8');
        if (!isset($result[$lower])) {
            $result[$lower] = $part;
        }
    }
    return array_values($result);
}

function get_product_variant_dimensions(int $productId): array
{
    $variants = get_product_variants($productId, false);
    $colors = [];
    $sizes = [];
    foreach ($variants as $variant) {
        $color = trim((string)($variant['color_value'] ?? ''));
        $size = trim((string)($variant['size_value'] ?? ''));
        if ($color !== '') {
            $colors[mb_strtolower($color, 'UTF-8')] = $color;
        }
        if ($size !== '') {
            $sizes[mb_strtolower($size, 'UTF-8')] = $size;
        }
    }
    return [
        'colors' => array_values($colors),
        'sizes' => array_values($sizes),
    ];
}

function build_variant_matrix_payload(array $variants): array
{
    $colors = [];
    $sizes = [];
    $items = [];
    foreach ($variants as $variant) {
        $color = trim((string)($variant['color_value'] ?? ''));
        $size = trim((string)($variant['size_value'] ?? ''));
        if ($color !== '') {
            $colors[mb_strtolower($color, 'UTF-8')] = $color;
        }
        if ($size !== '') {
            $sizes[mb_strtolower($size, 'UTF-8')] = $size;
        }
        $items[] = [
            'id' => (int)$variant['id'],
            'color' => $color,
            'size' => $size,
            'label' => build_variant_label($variant),
            'price' => calculate_variant_display_price(['original_price' => 0, 'sale_price' => 0], $variant),
            'original_price' => calculate_variant_original_price(['original_price' => 0, 'sale_price' => 0], $variant),
            'stock_qty' => (int)($variant['stock_qty'] ?? 0),
            'image_url' => $variant['image_url'] ?? null,
            'is_default' => !empty($variant['is_default']),
        ];
    }
    return [
        'colors' => array_values($colors),
        'sizes' => array_values($sizes),
        'items' => $items,
    ];
}

function normalize_variant_sku_part(string $value): string
{
    $value = strtoupper(slugify($value));
    $value = preg_replace('/[^A-Z0-9]+/', '', $value);
    return substr($value ?: 'X', 0, 8);
}

function generate_variant_sku_by_values(array $product, string $colorValue = '', string $sizeValue = ''): string
{
    $base = strtoupper(preg_replace('/[^A-Z0-9]+/', '', (string)($product['product_code'] ?? ('SKU' . ($product['id'] ?? '1')))));
    if ($base === '') {
        $base = 'SKU' . (int)($product['id'] ?? 1);
    }
    $parts = [];
    if ($colorValue !== '') {
        $parts[] = normalize_variant_sku_part($colorValue);
    }
    if ($sizeValue !== '') {
        $parts[] = normalize_variant_sku_part($sizeValue);
    }
    if (!$parts) {
        $parts[] = 'DFT';
    }
    $candidateBase = $base . '-' . implode('-', $parts);
    $candidate = $candidateBase;
    $index = 1;
    while (true) {
        $stmt = db()->prepare('SELECT id FROM product_variants WHERE sku = ? LIMIT 1');
        $stmt->execute([$candidate]);
        if (!$stmt->fetch()) {
            return $candidate;
        }
        $candidate = $candidateBase . '-' . $index;
        $index++;
    }
}

function create_product_variants_from_matrix(int $productId, array $product, string $colorsInput = '', string $sizesInput = ''): int
{
    if (!table_exists('product_variants')) {
        return 0;
    }

    $colors = split_variant_terms($colorsInput);
    $sizes = split_variant_terms($sizesInput);

    if (!$colors && !$sizes) {
        return 0;
    }
    if (!$colors) {
        $colors = [''];
    }
    if (!$sizes) {
        $sizes = [''];
    }

    $stmtFind = db()->prepare('SELECT id FROM product_variants WHERE product_id = ? AND COALESCE(color_value, "") = ? AND COALESCE(size_value, "") = ? LIMIT 1');
    $stmtInsert = db()->prepare('INSERT INTO product_variants (product_id, sku, variant_name, size_value, color_value, original_price, sale_price, purchase_price, stock_qty, image_url, is_default, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())');
    $created = 0;
    $setDefault = !get_product_variants($productId, false);

    foreach ($colors as $color) {
        foreach ($sizes as $size) {
            $stmtFind->execute([$productId, (string)$color, (string)$size]);
            if ($stmtFind->fetchColumn()) {
                continue;
            }
            $label = build_variant_label([
                'color_value' => $color !== '' ? $color : null,
                'size_value' => $size !== '' ? $size : null,
                'variant_name' => null,
            ]);
            $stmtInsert->execute([
                $productId,
                generate_variant_sku_by_values($product, $color, $size),
                $label,
                $size !== '' ? $size : null,
                $color !== '' ? $color : null,
                $product['original_price'] ?? 0,
                $product['sale_price'] ?? null,
                $product['purchase_price'] ?? null,
                0,
                null,
                $setDefault ? 1 : 0,
            ]);
            $setDefault = false;
            $created++;
        }
    }

    if ($created > 0) {
        sync_product_variant_summary($productId);
    }
    return $created;
}

function variant_color_style(string $colorName): string
{
    $map = [
        'đen' => '#111111', 'den' => '#111111',
        'trắng' => '#f5f5f4', 'trang' => '#f5f5f4', 'white' => '#f5f5f4',
        'đỏ' => '#dc2626', 'do' => '#dc2626', 'red' => '#dc2626',
        'xanh' => '#2563eb', 'xanh dương' => '#2563eb', 'blue' => '#2563eb',
        'xanh navy' => '#1e3a8a', 'navy' => '#1e3a8a',
        'xanh lá' => '#16a34a', 'green' => '#16a34a',
        'vàng' => '#facc15', 'vang' => '#facc15', 'yellow' => '#facc15',
        'tím' => '#9333ea', 'tim' => '#9333ea', 'purple' => '#9333ea',
        'hồng' => '#ec4899', 'hong' => '#ec4899', 'pink' => '#ec4899',
        'xám' => '#9ca3af', 'xam' => '#9ca3af', 'gray' => '#9ca3af', 'grey' => '#9ca3af',
        'be' => '#d6c3a3', 'kem' => '#eee7da', 'nâu' => '#8b5e3c', 'nau' => '#8b5e3c',
        'cam' => '#f97316',
    ];
    $key = mb_strtolower(trim($colorName), 'UTF-8');
    return $map[$key] ?? 'linear-gradient(135deg,#e5e7eb,#cbd5e1)';
}

function is_post(): bool
{
    return strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST';
}

function client_ip_address(): string
{
    $candidates = [
        $_SERVER['HTTP_CF_CONNECTING_IP'] ?? null,
        $_SERVER['HTTP_X_FORWARDED_FOR'] ?? null,
        $_SERVER['REMOTE_ADDR'] ?? null,
    ];
    foreach ($candidates as $candidate) {
        if (!$candidate) {
            continue;
        }
        $parts = array_map('trim', explode(',', $candidate));
        foreach ($parts as $part) {
            if (filter_var($part, FILTER_VALIDATE_IP)) {
                return $part;
            }
        }
    }
    return '0.0.0.0';
}

function current_user_agent(): string
{
    return substr((string)($_SERVER['HTTP_USER_AGENT'] ?? 'unknown'), 0, 255);
}

function flash_set(string $key, string $message, string $type = 'info'): void
{
    $_SESSION['_flash'][$key] = ['message' => $message, 'type' => $type];
}

function flash_get(string $key): ?array
{
    if (!isset($_SESSION['_flash'][$key])) {
        return null;
    }
    $value = $_SESSION['_flash'][$key];
    unset($_SESSION['_flash'][$key]);
    return $value;
}

function old_input(string $key, $default = '')
{
    return $_POST[$key] ?? $default;
}

function csrf_token(): string
{
    if (empty($_SESSION['_csrf_token']) || !is_string($_SESSION['_csrf_token'])) {
        $_SESSION['_csrf_token'] = bin2hex(random_bytes(32));
    }
    return (string)$_SESSION['_csrf_token'];
}

function refresh_csrf_token(): string
{
    $_SESSION['_csrf_token'] = bin2hex(random_bytes(32));
    return (string)$_SESSION['_csrf_token'];
}

function csrf_field(): string
{
    return '<input type="hidden" name="csrf_token" value="' . e(csrf_token()) . '">';
}

function csrf_is_valid(bool $allowBootstrapIfSessionMissing = false): bool
{
    $token = trim((string)($_POST['csrf_token'] ?? ''));
    $expected = trim((string)($_SESSION['_csrf_token'] ?? ''));

    if ($token === '') {
        return false;
    }

    if ($expected !== '' && hash_equals($expected, $token)) {
        return true;
    }

    if (
        $allowBootstrapIfSessionMissing
        && $expected === ''
        && preg_match('/^[a-f0-9]{64}$/i', $token)
    ) {
        $_SESSION['_csrf_token'] = $token;
        return true;
    }

    return false;
}

function verify_csrf_or_fail(bool $allowBootstrapIfSessionMissing = false): void
{
    if (csrf_is_valid($allowBootstrapIfSessionMissing)) {
        return;
    }

    refresh_csrf_token();
    http_response_code(419);
    exit('Phiên làm việc đã hết hạn hoặc token không hợp lệ. Vui lòng tải lại trang và thử lại.');
}


function public_form_token(): string
{
    $current = trim((string)($_COOKIE['public_form_token'] ?? ''));
    if ($current !== '' && preg_match('/^[a-f0-9]{64}$/i', $current)) {
        return $current;
    }

    $token = bin2hex(random_bytes(32));
    $httpsEnabled = (
        (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['SERVER_PORT'] ?? null) == 443)
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https')
    );

    if (!headers_sent()) {
        setcookie('public_form_token', $token, [
            'expires' => time() + 60 * 60 * 24 * 30,
            'path' => '/',
            'httponly' => true,
            'samesite' => 'Lax',
            'secure' => $httpsEnabled,
        ]);
    }

    $_COOKIE['public_form_token'] = $token;
    return $token;
}

function refresh_public_form_token(): string
{
    unset($_COOKIE['public_form_token']);

    $httpsEnabled = (
        (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['SERVER_PORT'] ?? null) == 443)
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https')
    );

    if (!headers_sent()) {
        setcookie('public_form_token', '', [
            'expires' => time() - 3600,
            'path' => '/',
            'httponly' => true,
            'samesite' => 'Lax',
            'secure' => $httpsEnabled,
        ]);
    }

    return public_form_token();
}

function public_form_field(): string
{
    return '<input type="hidden" name="public_form_token" value="' . e(public_form_token()) . '">';
}

function public_form_is_valid(): bool
{
    $cookie = trim((string)($_COOKIE['public_form_token'] ?? ''));
    $posted = trim((string)($_POST['public_form_token'] ?? ''));

    if ($cookie === '' || $posted === '') {
        return false;
    }

    return hash_equals($cookie, $posted);
}

function verify_public_or_customer_form_or_fail(bool $allowBootstrapIfSessionMissing = true): void
{
    if (csrf_is_valid($allowBootstrapIfSessionMissing) || public_form_is_valid()) {
        return;
    }

    refresh_csrf_token();
    refresh_public_form_token();

    if (
        (($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') === 'XMLHttpRequest')
        || (($_POST['is_ajax'] ?? '') === '1')
    ) {
        http_response_code(419);
        header('Content-Type: application/json; charset=UTF-8');
        echo json_encode([
            'ok' => false,
            'message' => 'Phiên mua hàng đã được làm mới. Vui lòng thử lại.',
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    http_response_code(419);
    exit('Phiên mua hàng đã được làm mới. Vui lòng tải lại trang và thử lại.');
}

function checkout_submit_request_id(array $input = []): string
{
    return trim((string)($input['request_id'] ?? $_POST['request_id'] ?? ''));
}

function checkout_request_field(?string $requestId = null): string
{
    $requestId = trim((string)$requestId);
    if ($requestId === '') {
        $requestId = bin2hex(random_bytes(16));
    }
    return '<input type="hidden" name="request_id" value="' . e($requestId) . '">';
}

function find_order_by_request_id(string $requestId): ?array
{
    $requestId = trim($requestId);
    if ($requestId === '' || !table_exists('orders') || !column_exists('orders', 'request_id')) {
        return null;
    }

    $stmt = db()->prepare('SELECT * FROM orders WHERE request_id = ? LIMIT 1');
    $stmt->execute([$requestId]);
    $row = $stmt->fetch();
    return $row ?: null;
}

function guest_checkout_enabled(): bool
{
    return shop_setting_bool('enable_guest_checkout', true);
}

function get_order_by_code_and_phone(string $orderCode, ?string $phone): ?array
{
    $orderCode = trim($orderCode);
    $phone = normalize_phone($phone);

    if ($orderCode === '' || !$phone || !table_exists('orders')) {
        return null;
    }

    $stmt = db()->prepare('SELECT * FROM orders WHERE order_code = ? AND contact_phone = ? LIMIT 1');
    $stmt->execute([$orderCode, $phone]);
    $row = $stmt->fetch();
    return $row ?: null;
}

function attach_guest_orders_to_customer(int $customerId, ?string $phone = null, ?string $email = null): void
{
    if ($customerId <= 0 || !table_exists('orders')) {
        return;
    }

    $phone = normalize_phone($phone);
    $email = normalize_email($email);

    if (!$phone && !$email) {
        return;
    }

    $conditions = [];
    $params = [$customerId];

    if ($phone) {
        $conditions[] = 'contact_phone = ?';
        $params[] = $phone;
    }

    if ($email) {
        $conditions[] = 'contact_email = ?';
        $params[] = $email;
    }

    if (!$conditions) {
        return;
    }

    $sql = 'UPDATE orders SET customer_id = ?, checkout_type = "account", updated_at = NOW() WHERE customer_id IS NULL AND (' . implode(' OR ', $conditions) . ')';
    db()->prepare($sql)->execute($params);
}

function customer_session_bootstrap(): void
{
    if (!isset($_SESSION['customer_auth'])) {
        return;
    }

    $auth = $_SESSION['customer_auth'];
    $now = time();
    $lastActivity = (int)($auth['last_activity'] ?? $now);
    $loginAt = (int)($auth['login_at'] ?? $now);

    if (($now - $lastActivity) > CUSTOMER_SESSION_IDLE_TIMEOUT || ($now - $loginAt) > CUSTOMER_SESSION_ABSOLUTE_TIMEOUT) {
        customer_logout(false);
        flash_set('customer_auth', 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.', 'warning');
        return;
    }

    $_SESSION['customer_auth']['last_activity'] = $now;
}

function is_customer_logged_in(): bool
{
    customer_session_bootstrap();
    return !empty($_SESSION['customer_auth']['customer_id']);
}

function current_customer_id(): ?int
{
    return is_customer_logged_in() ? (int)$_SESSION['customer_auth']['customer_id'] : null;
}

function current_customer(): ?array
{
    $customerId = current_customer_id();
    if (!$customerId || !table_exists('customers')) {
        return null;
    }

    $stmt = db()->prepare('SELECT * FROM customers WHERE id = ? AND deleted_at IS NULL LIMIT 1');
    $stmt->execute([$customerId]);
    $customer = $stmt->fetch();
    return $customer ?: null;
}

function customer_log_security_event(?int $customerId, string $eventType, ?string $metaText = null): void
{
    if (!table_exists('customer_security_logs')) {
        return;
    }
    $stmt = db()->prepare('INSERT INTO customer_security_logs (customer_id, event_type, ip_address, user_agent, meta_text, created_at) VALUES (?, ?, ?, ?, ?, NOW())');
    $stmt->execute([$customerId, $eventType, client_ip_address(), current_user_agent(), $metaText]);
}

function customer_login(array $customer): void
{
    session_regenerate_id(true);
    $_SESSION['customer_auth'] = [
        'customer_id' => (int)$customer['id'],
        'login_at' => time(),
        'last_activity' => time(),
    ];
    if (table_exists('customers')) {
        db()->prepare('UPDATE customers SET last_login_at = NOW(), updated_at = NOW() WHERE id = ?')->execute([(int)$customer['id']]);
    }
    if (table_exists('carts')) {
        merge_guest_cart_into_customer_cart((int)$customer['id']);
    }
    attach_guest_orders_to_customer((int)$customer['id'], $customer['phone'] ?? null, $customer['email'] ?? null);
    customer_log_security_event((int)$customer['id'], 'login_success', 'Đăng nhập thành công');
}

function customer_logout(bool $regenerate = true): void
{
    $customerId = $_SESSION['customer_auth']['customer_id'] ?? null;
    unset($_SESSION['customer_auth']);
    if ($customerId) {
        customer_log_security_event((int)$customerId, 'logout', 'Đăng xuất');
    }
    if ($regenerate) {
        session_regenerate_id(true);
    }
}

function customer_require_login(): void
{
    if (!is_customer_logged_in()) {
        $returnTo = $_SERVER['REQUEST_URI'] ?? '/customer/account.php';
        redirect('/customer/login.php?redirect=' . urlencode($returnTo));
    }
}

function normalize_email(?string $value): ?string
{
    $value = trim((string)$value);
    if ($value === '') {
        return null;
    }
    $email = filter_var(mb_strtolower($value), FILTER_VALIDATE_EMAIL);
    return $email ?: null;
}

function normalize_phone(?string $value): ?string
{
    $value = preg_replace('/[^0-9]/', '', (string)$value);
    return $value !== '' ? $value : null;
}

function generate_customer_code(): string
{
    $nextId = (int)db()->query('SELECT COALESCE(MAX(id), 0) + 1 FROM customers')->fetchColumn();
    return 'CUS' . str_pad((string)max(1, $nextId), 6, '0', STR_PAD_LEFT);
}

function customer_find_by_login(string $login): ?array
{
    if (!table_exists('customers')) {
        return null;
    }
    $email = normalize_email($login);
    $phone = normalize_phone($login);
    $stmt = db()->prepare('SELECT * FROM customers WHERE (email = ? OR phone = ?) AND deleted_at IS NULL LIMIT 1');
    $stmt->execute([$email, $phone]);
    $customer = $stmt->fetch();
    return $customer ?: null;
}

function customer_register_local(array $input): array
{
    $requiredTables = require_upgrade_tables(['customers']);
    if ($requiredTables) {
        return ['ok' => false, 'message' => 'Thiếu bảng hệ thống mới: ' . implode(', ', $requiredTables)];
    }

    $fullName = trim((string)($input['full_name'] ?? ''));
    $email = normalize_email($input['email'] ?? null);
    $phone = normalize_phone($input['phone'] ?? null);
    $password = (string)($input['password'] ?? '');
    $passwordConfirm = (string)($input['password_confirm'] ?? '');

    if ($fullName === '' || (!$email && !$phone) || $password === '') {
        return ['ok' => false, 'message' => 'Vui lòng nhập họ tên, email hoặc số điện thoại và mật khẩu.'];
    }
    if (strlen($password) < 8) {
        return ['ok' => false, 'message' => 'Mật khẩu cần ít nhất 8 ký tự.'];
    }
    if ($password !== $passwordConfirm) {
        return ['ok' => false, 'message' => 'Mật khẩu xác nhận không khớp.'];
    }

    $stmt = db()->prepare('SELECT id FROM customers WHERE (email = ? AND ? IS NOT NULL) OR (phone = ? AND ? IS NOT NULL) LIMIT 1');
    $stmt->execute([$email, $email, $phone, $phone]);
    if ($stmt->fetchColumn()) {
        return ['ok' => false, 'message' => 'Email hoặc số điện thoại đã được sử dụng.'];
    }

    $hash = password_hash($password, PASSWORD_DEFAULT);
    $stmt = db()->prepare('INSERT INTO customers (customer_code, full_name, email, phone, password_hash, status, registered_via, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())');
    $stmt->execute([
        generate_customer_code(),
        $fullName,
        $email,
        $phone,
        $hash,
        'active',
        'local',
    ]);
    $customerId = (int)db()->lastInsertId();
    $customer = db()->prepare('SELECT * FROM customers WHERE id = ?');
    $customer->execute([$customerId]);
    $record = $customer->fetch();
    customer_log_security_event($customerId, 'register_success', 'Đăng ký tài khoản');
    customer_login($record);
    return ['ok' => true, 'customer' => $record];
}

function get_customer_addresses(int $customerId): array
{
    if (!table_exists('customer_addresses')) {
        return [];
    }
    $stmt = db()->prepare('SELECT * FROM customer_addresses WHERE customer_id = ? AND is_active = 1 ORDER BY is_default_shipping DESC, id DESC');
    $stmt->execute([$customerId]);
    return $stmt->fetchAll();
}

function get_customer_address(int $customerId, int $addressId): ?array
{
    $stmt = db()->prepare('SELECT * FROM customer_addresses WHERE id = ? AND customer_id = ? AND is_active = 1 LIMIT 1');
    $stmt->execute([$addressId, $customerId]);
    $address = $stmt->fetch();
    return $address ?: null;
}

function save_customer_address(int $customerId, array $input): array
{
    $receiverName = trim((string)($input['receiver_name'] ?? ''));
    $receiverPhone = normalize_phone($input['receiver_phone'] ?? null);
    $provinceName = trim((string)($input['province_name'] ?? ''));
    $districtName = trim((string)($input['district_name'] ?? ''));
    $wardName = trim((string)($input['ward_name'] ?? ''));
    $addressLine = trim((string)($input['address_line'] ?? ''));
    $addressNote = trim((string)($input['address_note'] ?? ''));
    $label = trim((string)($input['label'] ?? ''));
    $isDefault = !empty($input['is_default_shipping']) ? 1 : 0;

    if ($receiverName === '' || !$receiverPhone || $provinceName === '' || $districtName === '' || $wardName === '' || $addressLine === '') {
        return ['ok' => false, 'message' => 'Vui lòng nhập đầy đủ người nhận, số điện thoại và địa chỉ.'];
    }

    db()->beginTransaction();
    try {
        if ($isDefault) {
            db()->prepare('UPDATE customer_addresses SET is_default_shipping = 0, updated_at = NOW() WHERE customer_id = ?')->execute([$customerId]);
        }
        $stmt = db()->prepare('INSERT INTO customer_addresses (customer_id, label, receiver_name, receiver_phone, province_name, district_name, ward_name, address_line, address_note, is_default_shipping, is_default_billing, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 1, NOW(), NOW())');
        $stmt->execute([$customerId, $label ?: null, $receiverName, $receiverPhone, $provinceName, $districtName, $wardName, $addressLine, $addressNote ?: null, $isDefault]);
        db()->commit();
        return ['ok' => true, 'message' => 'Đã thêm địa chỉ mới.'];
    } catch (Throwable $e) {
        db()->rollBack();
        return ['ok' => false, 'message' => 'Không thể lưu địa chỉ: ' . $e->getMessage()];
    }
}

function update_customer_profile(int $customerId, array $input): array
{
    $fullName = trim((string)($input['full_name'] ?? ''));
    $phone = normalize_phone($input['phone'] ?? null);
    if ($fullName === '') {
        return ['ok' => false, 'message' => 'Họ tên không được để trống.'];
    }
    $stmt = db()->prepare('SELECT id FROM customers WHERE phone = ? AND id <> ? AND deleted_at IS NULL LIMIT 1');
    $stmt->execute([$phone, $customerId]);
    if ($phone && $stmt->fetchColumn()) {
        return ['ok' => false, 'message' => 'Số điện thoại này đã được dùng cho tài khoản khác.'];
    }
    db()->prepare('UPDATE customers SET full_name = ?, phone = ?, updated_at = NOW() WHERE id = ?')->execute([$fullName, $phone, $customerId]);
    customer_log_security_event($customerId, 'profile_updated', 'Cập nhật hồ sơ');
    return ['ok' => true, 'message' => 'Đã cập nhật thông tin tài khoản.'];
}

function format_order_money($value): float
{
    return round((float)$value, 2);
}

function calculate_checkout_shipping_fee(float $subtotal): float
{
    if (!function_exists('calculate_shipping_fee')) {
        return 0.0;
    }
    return format_order_money(calculate_shipping_fee($subtotal));
}

function generate_order_code(): string
{
    $prefix = 'DH' . date('ymd');
    for ($i = 0; $i < 20; $i++) {
        $candidate = $prefix . strtoupper(substr(bin2hex(random_bytes(4)), 0, 6));
        $stmt = db()->prepare('SELECT id FROM orders WHERE order_code = ? LIMIT 1');
        $stmt->execute([$candidate]);
        if (!$stmt->fetch()) {
            return $candidate;
        }
    }

    return $prefix . strtoupper(substr(bin2hex(random_bytes(6)), 0, 8));
}

function generate_payment_intent_code(): string
{
    return 'PAY' . strtoupper(bin2hex(random_bytes(6)));
}

function build_payment_transfer_note(string $orderCode, string $intentCode): string
{
    return substr('TT ' . $orderCode . ' ' . $intentCode, 0, 120);
}

function calculate_product_display_price(array $product): float
{
    $sale = (float)($product['sale_price'] ?? 0);
    $origin = (float)($product['original_price'] ?? 0);
    return $sale > 0 ? $sale : $origin;
}

function create_payment_intent_record(?int $customerId, ?int $orderId, string $purpose, float $requestedAmount, array $options = []): int
{
    $intentCode = generate_payment_intent_code();
    $transferNote = build_payment_transfer_note($options['order_code'] ?? ('ORD' . ($orderId ?: 'TOPUP')), $intentCode);
    $expiresAt = date('Y-m-d H:i:s', time() + 60 * 60 * 24);
    $provider = $options['provider'] ?? 'sepay';
    $qrContent = $transferNote;
    $qrImageUrl = $provider === 'sepay' ? sepay_qr_url($requestedAmount, $transferNote) : null;

    $columns = [
        'intent_code', 'customer_id', 'order_id'
    ];
    $values = [
        $intentCode,
        $customerId,
        $orderId,
    ];

    if (column_exists('payment_intents', 'wallet_topup_request_id')) {
        $columns[] = 'wallet_topup_request_id';
        $values[] = $options['wallet_topup_request_id'] ?? null;
    }

    $columns = array_merge($columns, [
        'provider', 'purpose', 'requested_amount', 'currency_code', 'status', 'qr_content', 'qr_image_url', 'transfer_note', 'expires_at', 'idempotency_key', 'metadata_text', 'created_at', 'updated_at'
    ]);
    $values = array_merge($values, [
        $provider,
        $purpose,
        format_order_money($requestedAmount),
        'VND',
        'waiting_payment',
        $qrContent,
        $qrImageUrl,
        $transferNote,
        $expiresAt,
        $options['idempotency_key'] ?? null,
        $options['metadata_text'] ?? null,
    ]);

    $placeholders = array_fill(0, count($columns) - 2, '?');
    $sql = 'INSERT INTO payment_intents (' . implode(', ', $columns) . ') VALUES (' . implode(', ', $placeholders) . ', NOW(), NOW())';
    $stmt = db()->prepare($sql);
    $stmt->execute($values);
    return (int)db()->lastInsertId();
}

function get_product_variants(int $productId, bool $onlyActive = true): array
{
    if (!table_exists('product_variants')) {
        return [];
    }

    $sql = 'SELECT * FROM product_variants WHERE product_id = ?';
    $params = [$productId];
    if ($onlyActive) {
        $sql .= ' AND is_active = 1';
    }
    $sql .= ' ORDER BY is_default DESC, color_value ASC, size_value ASC, id ASC';

    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

function get_product_variant(int $variantId, ?int $productId = null): ?array
{
    if (!table_exists('product_variants')) {
        return null;
    }

    $sql = 'SELECT * FROM product_variants WHERE id = ?';
    $params = [$variantId];
    if ($productId !== null) {
        $sql .= ' AND product_id = ?';
        $params[] = $productId;
    }
    $sql .= ' LIMIT 1';

    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    $variant = $stmt->fetch();
    return $variant ?: null;
}

function build_variant_label(array $variant, ?array $product = null): string
{
    $parts = [];
    if (!empty($variant['color_value'])) {
        $parts[] = trim((string)$variant['color_value']);
    }
    if (!empty($variant['size_value'])) {
        $parts[] = trim((string)$variant['size_value']);
    }
    if (!$parts && !empty($variant['variant_name'])) {
        $parts[] = trim((string)$variant['variant_name']);
    }
    return $parts ? implode(' / ', $parts) : 'Mặc định';
}

function calculate_variant_display_price(array $product, ?array $variant = null): float
{
    if ($variant) {
        $sale = (float)($variant['sale_price'] ?? 0);
        $origin = (float)($variant['original_price'] ?? 0);
        if ($sale > 0) {
            return $sale;
        }
        if ($origin > 0) {
            return $origin;
        }
    }
    return calculate_product_display_price($product);
}

function calculate_variant_original_price(array $product, ?array $variant = null): float
{
    if ($variant && (float)($variant['original_price'] ?? 0) > 0) {
        return (float)$variant['original_price'];
    }
    return (float)($product['original_price'] ?? calculate_product_display_price($product));
}

function generate_variant_sku_for_product(array $product): string
{
    $base = strtoupper(preg_replace('/[^A-Z0-9]+/', '', (string)($product['product_code'] ?? ('SKU' . ($product['id'] ?? '1')))));
    if ($base === '') {
        $base = 'SKU' . (int)($product['id'] ?? 1);
    }
    $candidate = $base . '-DFT';
    $index = 1;
    while (true) {
        $stmt = db()->prepare('SELECT id FROM product_variants WHERE sku = ? LIMIT 1');
        $stmt->execute([$candidate]);
        if (!$stmt->fetch()) {
            return $candidate;
        }
        $candidate = $base . '-DFT' . $index;
        $index++;
    }
}

function sync_product_variant_summary(int $productId): void
{
    if (!table_exists('product_variants')) {
        return;
    }

    $stmt = db()->prepare('SELECT COALESCE(SUM(stock_qty), 0) AS total_qty
        FROM product_variants
        WHERE product_id = ? AND is_active = 1');
    $stmt->execute([$productId]);
    $summary = $stmt->fetch() ?: [];

    db()->prepare('UPDATE products SET quantity = ?, updated_at = NOW() WHERE id = ?')
        ->execute([
            (int)($summary['total_qty'] ?? 0),
            $productId,
        ]);
}

function ensure_default_product_variant($productOrId): ?array
{
    if (!table_exists('product_variants')) {
        return null;
    }

    $product = is_array($productOrId) ? $productOrId : get_product((int)$productOrId);
    if (!$product) {
        return null;
    }

    $variants = get_product_variants((int)$product['id'], false);
    if ($variants) {
        foreach ($variants as $variant) {
            if (!empty($variant['is_default'])) {
                return $variant;
            }
        }
        return $variants[0];
    }

    $variantName = build_variant_label([
        'color_value' => null,
        'size_value' => null,
        'variant_name' => 'Mặc định',
    ]);

    $stmt = db()->prepare('INSERT INTO product_variants (product_id, sku, variant_name, size_value, color_value, original_price, sale_price, purchase_price, stock_qty, image_url, is_default, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 1, NOW(), NOW())');
    $stmt->execute([
        (int)$product['id'],
        generate_variant_sku_for_product($product),
        $variantName,
        null,
        null,
        $product['original_price'] ?? 0,
        $product['sale_price'] ?? null,
        $product['purchase_price'] ?? null,
        (int)($product['quantity'] ?? 0),
        $product['thumbnail'] ?? null,
    ]);

    sync_product_variant_summary((int)$product['id']);
    return get_product_variant((int)db()->lastInsertId(), (int)$product['id']);
}

function current_guest_cart_token(): string
{
    if (!empty($_SESSION['guest_cart_token'])) {
        return (string)$_SESSION['guest_cart_token'];
    }

    if (!empty($_COOKIE['guest_cart_token'])) {
        $_SESSION['guest_cart_token'] = (string)$_COOKIE['guest_cart_token'];
        return (string)$_SESSION['guest_cart_token'];
    }

    $token = bin2hex(random_bytes(24));
    $_SESSION['guest_cart_token'] = $token;

    if (!headers_sent()) {
        $httpsEnabled = (
            (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
            || (($_SERVER['SERVER_PORT'] ?? null) == 443)
            || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https')
        );
        setcookie(
            'guest_cart_token',
            $token,
            [
                'expires' => time() + 60 * 60 * 24 * 30,
                'path' => '/',
                'httponly' => true,
                'samesite' => 'Lax',
                'secure' => $httpsEnabled,
            ]
        );
    }

    return $token;
}

function clear_guest_cart_token(): void
{
    unset($_SESSION['guest_cart_token']);
    if (isset($_COOKIE['guest_cart_token'])) {
        if (!headers_sent()) {
            $httpsEnabled = (
                (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
                || (($_SERVER['SERVER_PORT'] ?? null) == 443)
                || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https')
            );
            setcookie('guest_cart_token', '', [
                'expires' => time() - 3600,
                'path' => '/',
                'httponly' => true,
                'samesite' => 'Lax',
                'secure' => $httpsEnabled,
            ]);
        }
        unset($_COOKIE['guest_cart_token']);
    }
}

function get_active_cart_for_customer(int $customerId): ?array
{
    if (!table_exists('carts')) {
        return null;
    }
    $stmt = db()->prepare('SELECT * FROM carts WHERE customer_id = ? AND status = "active" ORDER BY id DESC LIMIT 1');
    $stmt->execute([$customerId]);
    $cart = $stmt->fetch();
    return $cart ?: null;
}

function get_active_guest_cart(): ?array
{
    if (!table_exists('carts')) {
        return null;
    }
    $stmt = db()->prepare('SELECT * FROM carts WHERE guest_token = ? ORDER BY id DESC LIMIT 1');
    $stmt->execute([current_guest_cart_token()]);
    $cart = $stmt->fetch();
    return $cart ?: null;
}

function get_current_cart(bool $createIfMissing = true): ?array
{
    if (!table_exists('carts')) {
        return null;
    }

    $customerId = current_customer_id();
    if ($customerId) {
        $cart = get_active_cart_for_customer($customerId);
        if ($cart) {
            return $cart;
        }
    } else {
        $cart = get_active_guest_cart();
        if ($cart) {
            if (($cart['status'] ?? '') !== 'active') {
                db()->prepare('UPDATE carts SET status = "active", updated_at = NOW() WHERE id = ?')
                    ->execute([(int)$cart['id']]);
                $cart['status'] = 'active';
            }
            return $cart;
        }
    }

    if (!$createIfMissing) {
        return null;
    }

    try {
        $stmt = db()->prepare('INSERT INTO carts (customer_id, guest_token, status, created_at, updated_at) VALUES (?, ?, "active", NOW(), NOW())');
        $stmt->execute([
            $customerId ?: null,
            $customerId ? null : current_guest_cart_token(),
        ]);

        $cartId = (int)db()->lastInsertId();
        $stmt = db()->prepare('SELECT * FROM carts WHERE id = ? LIMIT 1');
        $stmt->execute([$cartId]);
        return $stmt->fetch() ?: null;
    } catch (PDOException $e) {
        if (isset($e->errorInfo[1]) && (int)$e->errorInfo[1] === 1062 && !$customerId) {
            $stmt = db()->prepare('SELECT * FROM carts WHERE guest_token = ? ORDER BY id DESC LIMIT 1');
            $stmt->execute([current_guest_cart_token()]);
            $cart = $stmt->fetch();
            if ($cart) {
                if (($cart['status'] ?? '') !== 'active') {
                    db()->prepare('UPDATE carts SET status = "active", updated_at = NOW() WHERE id = ?')
                        ->execute([(int)$cart['id']]);
                    $cart['status'] = 'active';
                }
                return $cart;
            }
        }
        throw $e;
    }
}

function get_cart_items_detailed(int $cartId): array
{
    if (!table_exists('cart_items')) {
        return [];
    }

    $sql = 'SELECT ci.*,
            p.product_name,
            p.product_code,
            p.thumbnail,
            p.original_price AS product_original_price,
            p.sale_price AS product_sale_price,
            pv.sku,
            pv.variant_name,
            pv.size_value,
            pv.color_value,
            pv.image_url AS variant_image_url,
            pv.original_price AS variant_original_price,
            pv.sale_price AS variant_sale_price,
            pv.stock_qty,
            COALESCE(NULLIF(pv.image_url, ""), p.thumbnail) AS effective_image
        FROM cart_items ci
        INNER JOIN products p ON p.id = ci.product_id
        LEFT JOIN product_variants pv ON pv.id = ci.variant_id
        WHERE ci.cart_id = ?
        ORDER BY ci.id ASC';
    $stmt = db()->prepare($sql);
    $stmt->execute([$cartId]);
    return $stmt->fetchAll();
}

function get_cart_item_count(): int
{
    $cart = get_current_cart(false);
    if (!$cart || !table_exists('cart_items')) {
        return 0;
    }
    $stmt = db()->prepare('SELECT COALESCE(SUM(quantity), 0) FROM cart_items WHERE cart_id = ?');
    $stmt->execute([(int)$cart['id']]);
    return (int)$stmt->fetchColumn();
}

function get_cart_totals(int $cartId): array
{
    $items = get_cart_items_detailed($cartId);
    $subtotal = 0.0;
    $quantity = 0;

    foreach ($items as $item) {
        $subtotal += (float)$item['unit_price_snapshot'] * (int)$item['quantity'];
        $quantity += (int)$item['quantity'];
    }

    $subtotal = format_order_money($subtotal);
    $shippingFee = calculate_checkout_shipping_fee($subtotal);
    $discountAmount = 0.0;
    $total = format_order_money($subtotal - $discountAmount + $shippingFee);

    return [
        'items' => $items,
        'item_count' => $quantity,
        'subtotal' => $subtotal,
        'shipping_fee' => $shippingFee,
        'discount_amount' => $discountAmount,
        'total' => $total,
    ];
}

function add_item_to_cart(int $productId, ?int $variantId, int $quantity = 1, ?array $existingCart = null): array
{
    $required = require_upgrade_tables(['carts', 'cart_items']);
    if ($required) {
        return ['ok' => false, 'message' => 'Thiếu bảng hệ thống mới: ' . implode(', ', $required)];
    }

    $product = get_product($productId);
    if (!$product || (isset($product['is_active']) && !(int)$product['is_active'])) {
        return ['ok' => false, 'message' => 'Sản phẩm không tồn tại hoặc đang bị ẩn.'];
    }

    $quantity = max(1, $quantity);
    $variants = get_product_variants($productId);
    $variant = null;

    if ($variantId) {
        $variant = get_product_variant($variantId, $productId);
        if (!$variant || (int)($variant['is_active'] ?? 1) !== 1) {
            return ['ok' => false, 'message' => 'Biến thể sản phẩm không hợp lệ.'];
        }
    } elseif ($variants) {
        $variant = count($variants) === 1 ? $variants[0] : null;
        if (!$variant) {
            foreach ($variants as $candidate) {
                if (!empty($candidate['is_default'])) {
                    $variant = $candidate;
                    break;
                }
            }
        }
        if (!$variant) {
            return ['ok' => false, 'message' => 'Vui lòng chọn màu / size trước khi thêm vào giỏ.'];
        }
    } else {
        $variant = ensure_default_product_variant($product);
    }

    if ($variant && isset($variant['stock_qty']) && (int)$variant['stock_qty'] > 0 && $quantity > (int)$variant['stock_qty']) {
        $quantity = (int)$variant['stock_qty'];
    }

    $cart = $existingCart ?: get_current_cart(true);
    if (!$cart) {
        return ['ok' => false, 'message' => 'Không thể khởi tạo giỏ hàng.'];
    }

    $price = calculate_variant_display_price($product, $variant);
    $saleSnapshot = $variant ? ($variant['sale_price'] ?? null) : ($product['sale_price'] ?? null);

    if ($variant) {
        $stmt = db()->prepare('SELECT * FROM cart_items WHERE cart_id = ? AND product_id = ? AND variant_id = ? LIMIT 1');
        $stmt->execute([(int)$cart['id'], $productId, (int)$variant['id']]);
    } else {
        $stmt = db()->prepare('SELECT * FROM cart_items WHERE cart_id = ? AND product_id = ? AND variant_id IS NULL LIMIT 1');
        $stmt->execute([(int)$cart['id'], $productId]);
    }
    $existingItem = $stmt->fetch();

    if ($existingItem) {
        $newQty = (int)$existingItem['quantity'] + $quantity;
        if ($variant && isset($variant['stock_qty']) && (int)$variant['stock_qty'] > 0) {
            $newQty = min($newQty, (int)$variant['stock_qty']);
        }
        db()->prepare('UPDATE cart_items SET quantity = ?, unit_price_snapshot = ?, sale_price_snapshot = ?, updated_at = NOW() WHERE id = ?')
            ->execute([$newQty, $price, $saleSnapshot, (int)$existingItem['id']]);
    } else {
        db()->prepare('INSERT INTO cart_items (cart_id, product_id, variant_id, quantity, unit_price_snapshot, sale_price_snapshot, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())')
            ->execute([(int)$cart['id'], $productId, $variant['id'] ?? null, $quantity, $price, $saleSnapshot]);
    }

    db()->prepare('UPDATE carts SET updated_at = NOW() WHERE id = ?')->execute([(int)$cart['id']]);

    return [
        'ok' => true,
        'cart_id' => (int)$cart['id'],
        'variant_id' => $variant['id'] ?? null,
        'message' => 'Đã thêm sản phẩm vào giỏ hàng.',
    ];
}

function update_cart_item_quantity(int $itemId, int $quantity): void
{
    $cart = get_current_cart(false);
    if (!$cart || !table_exists('cart_items')) {
        return;
    }

    if ($quantity <= 0) {
        db()->prepare('DELETE FROM cart_items WHERE id = ? AND cart_id = ?')->execute([$itemId, (int)$cart['id']]);
        return;
    }

    $stmt = db()->prepare('SELECT ci.*, pv.stock_qty FROM cart_items ci LEFT JOIN product_variants pv ON pv.id = ci.variant_id WHERE ci.id = ? AND ci.cart_id = ? LIMIT 1');
    $stmt->execute([$itemId, (int)$cart['id']]);
    $item = $stmt->fetch();
    if (!$item) {
        return;
    }

    if (!empty($item['stock_qty']) && (int)$item['stock_qty'] > 0) {
        $quantity = min($quantity, (int)$item['stock_qty']);
    }

    db()->prepare('UPDATE cart_items SET quantity = ?, updated_at = NOW() WHERE id = ? AND cart_id = ?')->execute([$quantity, $itemId, (int)$cart['id']]);
    db()->prepare('UPDATE carts SET updated_at = NOW() WHERE id = ?')->execute([(int)$cart['id']]);
}

function remove_cart_item(int $itemId): void
{
    $cart = get_current_cart(false);
    if (!$cart || !table_exists('cart_items')) {
        return;
    }
    db()->prepare('DELETE FROM cart_items WHERE id = ? AND cart_id = ?')->execute([$itemId, (int)$cart['id']]);
    db()->prepare('UPDATE carts SET updated_at = NOW() WHERE id = ?')->execute([(int)$cart['id']]);
}

function clear_current_cart(): void
{
    $cart = get_current_cart(false);
    if (!$cart || !table_exists('cart_items')) {
        return;
    }
    db()->prepare('DELETE FROM cart_items WHERE cart_id = ?')->execute([(int)$cart['id']]);
    db()->prepare('UPDATE carts SET updated_at = NOW() WHERE id = ?')->execute([(int)$cart['id']]);
}

function merge_guest_cart_into_customer_cart(int $customerId): void
{
    if (!table_exists('carts') || !table_exists('cart_items')) {
        return;
    }

    $guestCart = get_active_guest_cart();
    if (!$guestCart) {
        return;
    }

    $customerCart = get_active_cart_for_customer($customerId);
    if (!$customerCart) {
        db()->prepare('UPDATE carts SET customer_id = ?, guest_token = NULL, status = "active", updated_at = NOW() WHERE id = ?')
            ->execute([$customerId, (int)$guestCart['id']]);
        clear_guest_cart_token();
        return;
    }

    if ((int)$customerCart['id'] === (int)$guestCart['id']) {
        return;
    }

    $items = get_cart_items_detailed((int)$guestCart['id']);
    foreach ($items as $item) {
        add_item_to_cart((int)$item['product_id'], !empty($item['variant_id']) ? (int)$item['variant_id'] : null, (int)$item['quantity'], $customerCart);
    }

    db()->prepare('DELETE FROM cart_items WHERE cart_id = ?')->execute([(int)$guestCart['id']]);
    db()->prepare('UPDATE carts SET status = "converted", guest_token = NULL, updated_at = NOW() WHERE id = ?')->execute([(int)$guestCart['id']]);
    clear_guest_cart_token();
}

function order_status_options(): array
{
    return [
        'cho_xac_nhan'   => ['Chờ xác nhận', 'warning'],
        'dang_chuan_bi'  => ['Đang chuẩn bị hàng', 'info'],
        'dang_giao'      => ['Đang giao hàng', 'primary'],
        'da_giao'        => ['Giao thành công', 'success'],
        'da_huy'         => ['Đã hủy', 'danger'],
        'tra_hang'       => ['Trả hàng', 'danger'],
    ];
}

function payment_status_options(): array
{
    return [
        'chua_thanh_toan' => ['Chưa thanh toán', 'warning'],
        'da_dat_coc'      => ['Đã cọc', 'info'],
        'da_thanh_toan'   => ['Đã thanh toán', 'success'],
        'cho_hoan_tien'   => ['Chờ hoàn tiền', 'danger'],
        'da_hoan_tien'    => ['Đã hoàn tiền', 'danger'],
    ];
}

function payment_plan_label(string $paymentPlan): string
{
    return match ($paymentPlan) {
        'deposit_30' => 'Đặt cọc trước',
        'zalo_manual' => 'Chốt đơn thủ công',
        default => 'Thanh toán toàn bộ',
    };
}

function order_payment_pill_class(string $paymentStatus): string
{
    return match ($paymentStatus) {
        'da_thanh_toan', 'da_hoan_tien' => 'status-paid',
        'da_dat_coc', 'cho_hoan_tien' => 'status-partial',
        default => 'status-unpaid',
    };
}

function calculate_order_payment_snapshot(array $order, string $paymentStatus): array
{
    $paidAmount = format_order_money((float)($order['paid_amount'] ?? 0));
    $totalAmount = format_order_money((float)($order['total_amount'] ?? 0));
    $depositAmount = format_order_money((float)($order['deposit_required_amount'] ?? 0));

    switch ($paymentStatus) {
        case 'da_thanh_toan':
            $paidAmount = $totalAmount;
            $remainingAmount = 0.0;
            break;
        case 'da_dat_coc':
            if ($paidAmount <= 0 && $depositAmount > 0) {
                $paidAmount = $depositAmount;
            }
            $remainingAmount = max(0, $totalAmount - $paidAmount);
            break;
        case 'cho_hoan_tien':
        case 'da_hoan_tien':
            if ($paidAmount <= 0) {
                $paidAmount = $depositAmount > 0 ? $depositAmount : $totalAmount;
            }
            $remainingAmount = 0.0;
            break;
        default:
            if ($paidAmount <= 0) {
                $paidAmount = 0.0;
                $remainingAmount = $totalAmount;
            } else {
                $remainingAmount = max(0, $totalAmount - $paidAmount);
            }
            break;
    }

    return [
        'paid_amount' => format_order_money($paidAmount),
        'remaining_amount' => format_order_money($remainingAmount),
    ];
}

function create_order_from_cart_checkout(array $cart, array $input, ?array $customer = null): array
{
    $required = require_upgrade_tables(['orders', 'order_items', 'order_addresses', 'order_status_logs', 'payment_intents', 'cart_items']);
    if ($required) {
        return ['ok' => false, 'message' => 'Thiếu bảng hệ thống mới: ' . implode(', ', $required)];
    }

    $cartTotals = get_cart_totals((int)$cart['id']);
    $items = $cartTotals['items'];
    if (!$items) {
        return ['ok' => false, 'message' => 'Giỏ hàng đang trống.'];
    }

    $paymentPlan = ($input['payment_plan'] ?? 'full') === 'deposit_30' ? 'deposit_30' : 'full';
    $checkoutType = $customer ? 'account' : 'guest';

    if (!$customer) {
        $contactName = trim((string)($input['contact_name'] ?? ''));
        $contactPhone = normalize_phone($input['contact_phone'] ?? null);
        $contactEmail = normalize_email($input['contact_email'] ?? null);
    } else {
        $contactName = trim((string)($input['contact_name'] ?? ($customer['full_name'] ?? '')));
        $contactPhone = normalize_phone($input['contact_phone'] ?? ($customer['phone'] ?? null));
        $contactEmail = normalize_email($input['contact_email'] ?? ($customer['email'] ?? null));
    }

    $addressSource = $input['address_source'] ?? 'manual';
    $address = null;
    $savedAddressId = !empty($input['saved_address_id']) ? (int)$input['saved_address_id'] : 0;
    if ($customer && $addressSource === 'saved' && $savedAddressId > 0) {
        $address = get_customer_address((int)$customer['id'], $savedAddressId);
    }

    if (!$address) {
        $address = [
            'receiver_name' => trim((string)($input['receiver_name'] ?? $contactName)),
            'receiver_phone' => normalize_phone($input['receiver_phone'] ?? $contactPhone),
            'province_name' => trim((string)($input['province_name'] ?? '')),
            'district_name' => trim((string)($input['district_name'] ?? '')),
            'ward_name' => trim((string)($input['ward_name'] ?? '')),
            'address_line' => trim((string)($input['address_line'] ?? '')),
            'address_note' => trim((string)($input['address_note'] ?? '')),
            'source_type' => 'manual',
            'source_address_id' => null,
        ];
    } else {
        $address['source_type'] = 'account_saved';
        $address['source_address_id'] = (int)$address['id'];
    }

    if ($contactName === '' || !$contactPhone) {
        return ['ok' => false, 'message' => 'Vui lòng nhập họ tên và số điện thoại.'];
    }
    if (empty($address['receiver_name']) || empty($address['receiver_phone']) || empty($address['province_name']) || empty($address['district_name']) || empty($address['ward_name']) || empty($address['address_line'])) {
        return ['ok' => false, 'message' => 'Vui lòng nhập đầy đủ địa chỉ giao hàng.'];
    }

    $subtotal = format_order_money((float)($cartTotals['subtotal'] ?? 0));
    $shippingFee = format_order_money((float)($cartTotals['shipping_fee'] ?? calculate_checkout_shipping_fee($subtotal)));
    $discountAmount = 0.0;
    $totalAmount = format_order_money($subtotal - $discountAmount + $shippingFee);
    $depositRate = $paymentPlan === 'deposit_30' ? shop_deposit_rate() : 0;
    $depositRequired = $paymentPlan === 'deposit_30' ? format_order_money(ceil($totalAmount * shop_deposit_rate() / 100)) : $totalAmount;
    $remainingAmount = $totalAmount;
    $customerNote = trim((string)($input['customer_note'] ?? ''));
    $guestAccessToken = bin2hex(random_bytes(32));
    $requestId = checkout_submit_request_id($input);
    if ($requestId !== '' && ($existingOrder = find_order_by_request_id($requestId))) {
        return [
            'ok' => true,
            'order_id' => (int)$existingOrder['id'],
            'order_code' => (string)$existingOrder['order_code'],
            'guest_access_token' => (string)($existingOrder['guest_access_token'] ?? ''),
            'payment_intent_id' => (int)(get_latest_payment_intent_for_order((int)$existingOrder['id'])['id'] ?? 0),
            'deduplicated' => true,
        ];
    }
    $orderCode = generate_order_code();

    db()->beginTransaction();
    try {
        $orderColumns = 'order_code, customer_id, cart_id, checkout_type, purchase_channel, order_source, contact_name, contact_phone, contact_email, customer_note, internal_note, subtotal_amount, discount_amount, shipping_fee, total_amount, payment_plan, deposit_rate, deposit_required_amount, paid_amount, remaining_amount, payment_status, order_status, guest_access_token';
        $orderPlaceholders = '?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?';
        $orderParams = [
            $orderCode,
            $customer['id'] ?? null,
            (int)$cart['id'],
            $checkoutType,
            'web',
            'cart',
            $contactName,
            $contactPhone,
            $contactEmail,
            $customerNote ?: null,
            $subtotal,
            $discountAmount,
            $shippingFee,
            $totalAmount,
            $paymentPlan,
            $depositRate,
            $depositRequired,
            $remainingAmount,
            'chua_thanh_toan',
            'cho_xac_nhan',
            $guestAccessToken,
        ];

        if (column_exists('orders', 'request_id')) {
            $orderColumns .= ', request_id';
            $orderPlaceholders .= ', ?';
            $orderParams[] = $requestId !== '' ? $requestId : null;
        }

        $stmt = db()->prepare('INSERT INTO orders (' . $orderColumns . ', placed_at, created_at, updated_at) VALUES (' . $orderPlaceholders . ', NOW(), NOW(), NOW())');
        $stmt->execute($orderParams);
        $orderId = (int)db()->lastInsertId();

        $addressStmt = db()->prepare('INSERT INTO order_addresses (order_id, address_type, source_type, source_address_id, receiver_name, receiver_phone, province_name, district_name, ward_name, address_line, address_note, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())');
        $addressStmt->execute([
            $orderId,
            'shipping',
            $address['source_type'],
            $address['source_address_id'],
            $address['receiver_name'],
            $address['receiver_phone'],
            $address['province_name'],
            $address['district_name'],
            $address['ward_name'],
            $address['address_line'],
            $address['address_note'] ?: null,
        ]);

        $itemStmt = db()->prepare('INSERT INTO order_items (order_id, product_id, variant_id, product_name_snapshot, product_code_snapshot, sku_snapshot, variant_name_snapshot, size_snapshot, color_snapshot, thumbnail_snapshot, quantity, original_unit_price, final_unit_price, line_total, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())');
        foreach ($items as $item) {
            $lineTotal = format_order_money((float)$item['unit_price_snapshot'] * (int)$item['quantity']);
            $variantLabel = build_variant_label([
                'variant_name' => $item['variant_name'],
                'size_value' => $item['size_value'],
                'color_value' => $item['color_value'],
            ]);
            $itemStmt->execute([
                $orderId,
                (int)$item['product_id'],
                !empty($item['variant_id']) ? (int)$item['variant_id'] : null,
                $item['product_name'],
                $item['product_code'],
                $item['sku'] ?: null,
                $variantLabel,
                $item['size_value'] ?: null,
                $item['color_value'] ?: null,
                $item['effective_image'] ?: ($item['thumbnail'] ?: null),
                (int)$item['quantity'],
                calculate_variant_original_price([
                    'original_price' => $item['product_original_price'],
                    'sale_price' => $item['product_sale_price'],
                ], [
                    'original_price' => $item['variant_original_price'],
                    'sale_price' => $item['variant_sale_price'],
                ]),
                (float)$item['unit_price_snapshot'],
                $lineTotal,
            ]);
        }

        db()->prepare('INSERT INTO order_status_logs (order_id, from_status, to_status, note, changed_by_type, changed_by_id, created_at) VALUES (?, NULL, ?, ?, ?, ?, NOW())')
            ->execute([$orderId, 'cho_xac_nhan', 'Tạo đơn hàng mới từ giỏ hàng', $customer ? 'customer' : 'system', $customer['id'] ?? null]);

        $paymentIntentId = create_payment_intent_record(
            $customer['id'] ?? null,
            $orderId,
            $paymentPlan === 'deposit_30' ? 'order_deposit' : 'order_full',
            $depositRequired,
            ['order_code' => $orderCode]
        );

        db()->prepare('UPDATE carts SET status = "converted", updated_at = NOW() WHERE id = ?')->execute([(int)$cart['id']]);
        if (!$customer) {
            clear_guest_cart_token();
        }

        db()->commit();
        return [
            'ok' => true,
            'order_id' => $orderId,
            'order_code' => $orderCode,
            'guest_access_token' => $guestAccessToken,
            'payment_intent_id' => $paymentIntentId,
        ];
    } catch (Throwable $e) {
        db()->rollBack();
        return ['ok' => false, 'message' => 'Không thể tạo đơn hàng: ' . $e->getMessage()];
    }
}

function create_order_from_product_checkout(array $product, array $input, ?array $customer = null): array
{
    $required = require_upgrade_tables(['orders', 'order_items', 'order_addresses', 'order_status_logs', 'payment_intents']);
    if ($required) {
        return ['ok' => false, 'message' => 'Thiếu bảng hệ thống mới: ' . implode(', ', $required)];
    }

    $quantity = max(1, (int)($input['quantity'] ?? 1));
    $paymentPlan = ($input['payment_plan'] ?? 'full') === 'deposit_30' ? 'deposit_30' : 'full';
    $checkoutType = $customer ? 'account' : 'guest';

    $availableVariants = get_product_variants((int)$product['id']);
    $selectedVariant = !empty($input['variant_id']) ? get_product_variant((int)$input['variant_id'], (int)$product['id']) : null;
    if (!$selectedVariant && count($availableVariants) > 1) {
        return ['ok' => false, 'message' => 'Vui lòng chọn đúng màu và size trước khi mua ngay.'];
    }
    if (!$selectedVariant) {
        $selectedVariant = $availableVariants[0] ?? ensure_default_product_variant($product);
    }

    if (!$customer) {
        $contactName = trim((string)($input['contact_name'] ?? ''));
        $contactPhone = normalize_phone($input['contact_phone'] ?? null);
        $contactEmail = normalize_email($input['contact_email'] ?? null);
    } else {
        $contactName = trim((string)($input['contact_name'] ?? ($customer['full_name'] ?? '')));
        $contactPhone = normalize_phone($input['contact_phone'] ?? ($customer['phone'] ?? null));
        $contactEmail = normalize_email($input['contact_email'] ?? ($customer['email'] ?? null));
    }

    $addressSource = $input['address_source'] ?? 'manual';
    $address = null;
    $savedAddressId = !empty($input['saved_address_id']) ? (int)$input['saved_address_id'] : 0;
    if ($customer && $addressSource === 'saved' && $savedAddressId > 0) {
        $address = get_customer_address((int)$customer['id'], $savedAddressId);
    }

    if (!$address) {
        $address = [
            'receiver_name' => trim((string)($input['receiver_name'] ?? $contactName)),
            'receiver_phone' => normalize_phone($input['receiver_phone'] ?? $contactPhone),
            'province_name' => trim((string)($input['province_name'] ?? '')),
            'district_name' => trim((string)($input['district_name'] ?? '')),
            'ward_name' => trim((string)($input['ward_name'] ?? '')),
            'address_line' => trim((string)($input['address_line'] ?? '')),
            'address_note' => trim((string)($input['address_note'] ?? '')),
            'source_type' => 'manual',
            'source_address_id' => null,
        ];
    } else {
        $address['source_type'] = 'account_saved';
        $address['source_address_id'] = (int)$address['id'];
    }

    if ($contactName === '' || !$contactPhone) {
        return ['ok' => false, 'message' => 'Vui lòng nhập họ tên và số điện thoại.'];
    }
    if (empty($address['receiver_name']) || empty($address['receiver_phone']) || empty($address['province_name']) || empty($address['district_name']) || empty($address['ward_name']) || empty($address['address_line'])) {
        return ['ok' => false, 'message' => 'Vui lòng nhập đầy đủ địa chỉ giao hàng.'];
    }

    $unitPrice = calculate_variant_display_price($product, $selectedVariant);
    $subtotal = format_order_money($unitPrice * $quantity);
    $shippingFee = calculate_checkout_shipping_fee($subtotal);
    $discountAmount = 0.0;
    $totalAmount = format_order_money($subtotal - $discountAmount + $shippingFee);
    $depositRate = $paymentPlan === 'deposit_30' ? shop_deposit_rate() : 0;
    $depositRequired = $paymentPlan === 'deposit_30' ? format_order_money(ceil($totalAmount * shop_deposit_rate() / 100)) : $totalAmount;
    $remainingAmount = $totalAmount;
    $customerNote = trim((string)($input['customer_note'] ?? ''));
    $guestAccessToken = bin2hex(random_bytes(32));
    $requestId = checkout_submit_request_id($input);
    if ($requestId !== '' && ($existingOrder = find_order_by_request_id($requestId))) {
        return [
            'ok' => true,
            'order_id' => (int)$existingOrder['id'],
            'order_code' => (string)$existingOrder['order_code'],
            'guest_access_token' => (string)($existingOrder['guest_access_token'] ?? ''),
            'payment_intent_id' => (int)(get_latest_payment_intent_for_order((int)$existingOrder['id'])['id'] ?? 0),
            'deduplicated' => true,
        ];
    }
    $orderCode = generate_order_code();

    db()->beginTransaction();
    try {
        $orderColumns = 'order_code, customer_id, cart_id, checkout_type, purchase_channel, order_source, contact_name, contact_phone, contact_email, customer_note, internal_note, subtotal_amount, discount_amount, shipping_fee, total_amount, payment_plan, deposit_rate, deposit_required_amount, paid_amount, remaining_amount, payment_status, order_status, guest_access_token';
        $orderPlaceholders = '?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?';
        $orderParams = [
            $orderCode,
            $customer['id'] ?? null,
            $checkoutType,
            'web',
            'product',
            $contactName,
            $contactPhone,
            $contactEmail,
            $customerNote ?: null,
            $subtotal,
            $discountAmount,
            $shippingFee,
            $totalAmount,
            $paymentPlan,
            $depositRate,
            $depositRequired,
            $remainingAmount,
            'chua_thanh_toan',
            'cho_xac_nhan',
            $guestAccessToken,
        ];

        if (column_exists('orders', 'request_id')) {
            $orderColumns .= ', request_id';
            $orderPlaceholders .= ', ?';
            $orderParams[] = $requestId !== '' ? $requestId : null;
        }

        $stmt = db()->prepare('INSERT INTO orders (' . $orderColumns . ', placed_at, created_at, updated_at) VALUES (' . $orderPlaceholders . ', NOW(), NOW(), NOW())');
        $stmt->execute($orderParams);
        $orderId = (int)db()->lastInsertId();

        $addressStmt = db()->prepare('INSERT INTO order_addresses (order_id, address_type, source_type, source_address_id, receiver_name, receiver_phone, province_name, district_name, ward_name, address_line, address_note, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())');
        $addressStmt->execute([
            $orderId,
            'shipping',
            $address['source_type'],
            $address['source_address_id'],
            $address['receiver_name'],
            $address['receiver_phone'],
            $address['province_name'],
            $address['district_name'],
            $address['ward_name'],
            $address['address_line'],
            $address['address_note'] ?: null,
        ]);

        $itemStmt = db()->prepare('INSERT INTO order_items (order_id, product_id, variant_id, product_name_snapshot, product_code_snapshot, sku_snapshot, variant_name_snapshot, size_snapshot, color_snapshot, thumbnail_snapshot, quantity, original_unit_price, final_unit_price, line_total, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())');
        $itemStmt->execute([
            $orderId,
            (int)$product['id'],
            $selectedVariant['id'] ?? null,
            $product['product_name'],
            $product['product_code'],
            $selectedVariant['sku'] ?? null,
            $selectedVariant ? build_variant_label($selectedVariant, $product) : null,
            $selectedVariant['size_value'] ?? null,
            $selectedVariant['color_value'] ?? null,
            $selectedVariant['image_url'] ?? ($product['thumbnail'] ?? null),
            $quantity,
            calculate_variant_original_price($product, $selectedVariant),
            $unitPrice,
            $subtotal,
        ]);

        db()->prepare('INSERT INTO order_status_logs (order_id, from_status, to_status, note, changed_by_type, changed_by_id, created_at) VALUES (?, NULL, ?, ?, ?, ?, NOW())')
            ->execute([$orderId, 'cho_xac_nhan', 'Tạo đơn hàng mới', $customer ? 'customer' : 'system', $customer['id'] ?? null]);

        $paymentIntentId = create_payment_intent_record(
            $customer['id'] ?? null,
            $orderId,
            $paymentPlan === 'deposit_30' ? 'order_deposit' : 'order_full',
            $depositRequired,
            ['order_code' => $orderCode]
        );

        db()->commit();
        return [
            'ok' => true,
            'order_id' => $orderId,
            'order_code' => $orderCode,
            'guest_access_token' => $guestAccessToken,
            'payment_intent_id' => $paymentIntentId,
        ];
    } catch (Throwable $e) {
        db()->rollBack();
        return ['ok' => false, 'message' => 'Không thể tạo đơn hàng: ' . $e->getMessage()];
    }
}

function get_order_by_code_for_view(string $orderCode, ?int $customerId = null, ?string $guestToken = null, ?string $phone = null): ?array
{
    $stmt = db()->prepare('SELECT * FROM orders WHERE order_code = ? LIMIT 1');
    $stmt->execute([$orderCode]);
    $order = $stmt->fetch();
    if (!$order) {
        return null;
    }
    if ($customerId && (int)$order['customer_id'] === $customerId) {
        return $order;
    }
    if ($guestToken && hash_equals((string)$order['guest_access_token'], (string)$guestToken)) {
        return $order;
    }
    $normalizedPhone = normalize_phone($phone);
    if ($normalizedPhone && hash_equals((string)$order['contact_phone'], (string)$normalizedPhone)) {
        return $order;
    }
    return null;
}

function get_order_items(int $orderId): array
{
    $stmt = db()->prepare('SELECT * FROM order_items WHERE order_id = ? ORDER BY id ASC');
    $stmt->execute([$orderId]);
    return $stmt->fetchAll();
}

function get_order_address(int $orderId): ?array
{
    $stmt = db()->prepare('SELECT * FROM order_addresses WHERE order_id = ? AND address_type = ? ORDER BY id DESC LIMIT 1');
    $stmt->execute([$orderId, 'shipping']);
    $address = $stmt->fetch();
    return $address ?: null;
}

function get_order_payments(int $orderId): array
{
    if (!table_exists('payments')) {
        return [];
    }
    $stmt = db()->prepare('SELECT * FROM payments WHERE order_id = ? ORDER BY id DESC');
    $stmt->execute([$orderId]);
    return $stmt->fetchAll();
}

function get_latest_payment_intent_for_order(int $orderId): ?array
{
    $stmt = db()->prepare('SELECT * FROM payment_intents WHERE order_id = ? ORDER BY id DESC LIMIT 1');
    $stmt->execute([$orderId]);
    $intent = $stmt->fetch();
    return $intent ?: null;
}

function get_customer_orders(int $customerId): array
{
    $stmt = db()->prepare('SELECT * FROM orders WHERE customer_id = ? ORDER BY id DESC');
    $stmt->execute([$customerId]);
    return $stmt->fetchAll();
}

function admin_get_orders(array $filters = []): array
{
    $filters = array_merge([
        'status' => '',
        'payment_status' => '',
        'q' => '',
    ], $filters);

    $sql = 'SELECT o.*, c.full_name AS customer_name FROM orders o LEFT JOIN customers c ON c.id = o.customer_id WHERE 1=1';
    $params = [];

    if ($filters['status'] !== '') {
        $sql .= ' AND o.order_status = ?';
        $params[] = $filters['status'];
    }
    if ($filters['payment_status'] !== '') {
        $sql .= ' AND o.payment_status = ?';
        $params[] = $filters['payment_status'];
    }
    if ($filters['q'] !== '') {
        $q = '%' . trim($filters['q']) . '%';
        $sql .= ' AND (o.order_code LIKE ? OR o.contact_name LIKE ? OR o.contact_phone LIKE ?)';
        $params[] = $q;
        $params[] = $q;
        $params[] = $q;
    }

    $sql .= ' ORDER BY o.id DESC';
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

function admin_get_order(int $orderId): ?array
{
    $stmt = db()->prepare('SELECT o.*, c.full_name AS customer_name FROM orders o LEFT JOIN customers c ON c.id = o.customer_id WHERE o.id = ? LIMIT 1');
    $stmt->execute([$orderId]);
    $row = $stmt->fetch();
    return $row ?: null;
}

function admin_update_order_status(int $orderId, string $newStatus, ?string $note = null): void
{
    $order = admin_get_order($orderId);
    if (!$order) {
        return;
    }

    $allowed = array_keys(order_status_options());
    if (!in_array($newStatus, $allowed, true)) {
        return;
    }

    db()->beginTransaction();
    try {
        db()->prepare('UPDATE orders SET order_status = ?, updated_at = NOW(), confirmed_at = CASE WHEN ? = "dang_chuan_bi" AND confirmed_at IS NULL THEN NOW() ELSE confirmed_at END, completed_at = CASE WHEN ? = "da_giao" THEN NOW() ELSE completed_at END, cancelled_at = CASE WHEN ? = "da_huy" THEN NOW() ELSE cancelled_at END WHERE id = ?')
            ->execute([$newStatus, $newStatus, $newStatus, $newStatus, $orderId]);

        if (in_array($newStatus, ['da_huy', 'tra_hang'], true) && (string)$order['payment_status'] === 'chua_thanh_toan') {
            db()->prepare('UPDATE orders SET remaining_amount = 0, updated_at = NOW() WHERE id = ?')->execute([$orderId]);
        }

        if ($newStatus === 'da_giao' && (string)$order['payment_status'] === 'chua_thanh_toan') {
            $snapshot = calculate_order_payment_snapshot($order, 'da_thanh_toan');
            db()->prepare('UPDATE orders SET payment_status = ?, paid_amount = ?, remaining_amount = ?, updated_at = NOW() WHERE id = ?')
                ->execute(['da_thanh_toan', $snapshot['paid_amount'], $snapshot['remaining_amount'], $orderId]);
        } elseif (in_array($newStatus, ['da_huy', 'tra_hang'], true) && in_array((string)$order['payment_status'], ['da_dat_coc', 'da_thanh_toan'], true)) {
            $snapshot = calculate_order_payment_snapshot($order, 'cho_hoan_tien');
            db()->prepare('UPDATE orders SET payment_status = ?, paid_amount = ?, remaining_amount = ?, updated_at = NOW() WHERE id = ?')
                ->execute(['cho_hoan_tien', $snapshot['paid_amount'], $snapshot['remaining_amount'], $orderId]);
        }

        db()->prepare('INSERT INTO order_status_logs (order_id, from_status, to_status, note, changed_by_type, changed_by_id, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())')
            ->execute([$orderId, $order['order_status'], $newStatus, $note, 'admin', $_SESSION['admin_id'] ?? null]);
        db()->commit();
    } catch (Throwable $e) {
        db()->rollBack();
        throw $e;
    }
}

function admin_update_order_payment_status(int $orderId, string $newStatus): void
{
    $order = admin_get_order($orderId);
    if (!$order) {
        return;
    }

    $allowed = array_keys(payment_status_options());
    if (!in_array($newStatus, $allowed, true)) {
        return;
    }

    $snapshot = calculate_order_payment_snapshot($order, $newStatus);
    db()->prepare('UPDATE orders SET payment_status = ?, paid_amount = ?, remaining_amount = ?, updated_at = NOW() WHERE id = ?')
        ->execute([$newStatus, $snapshot['paid_amount'], $snapshot['remaining_amount'], $orderId]);

    if ((string)$order['payment_status'] !== $newStatus && telegram_should_notify_payment_status($newStatus)) {
        notify_order_payment_status_via_telegram($orderId);
    }
}

function sync_order_payment_status(int $orderId): void
{
    $order = admin_get_order($orderId);
    if (!$order) {
        return;
    }

    $paidAmountStmt = db()->prepare('SELECT COALESCE(SUM(paid_amount), 0) FROM payments WHERE order_id = ? AND payment_status = ?');
    $paidAmountStmt->execute([$orderId, 'success']);
    $paidAmount = (float)$paidAmountStmt->fetchColumn();
    $totalAmount = (float)$order['total_amount'];
    $depositAmount = (float)$order['deposit_required_amount'];
    $paymentPlan = (string)$order['payment_plan'];
    $refundFlow = in_array((string)$order['order_status'], ['da_huy', 'tra_hang'], true);

    if ($paidAmount >= $totalAmount && $totalAmount > 0) {
        $paymentStatus = $refundFlow ? 'cho_hoan_tien' : 'da_thanh_toan';
        $remainingAmount = 0;
    } elseif ($paidAmount > 0 && $paymentPlan === 'deposit_30' && $depositAmount > 0 && $paidAmount >= $depositAmount) {
        $paymentStatus = $refundFlow ? 'cho_hoan_tien' : 'da_dat_coc';
        $remainingAmount = $refundFlow ? 0 : max(0, $totalAmount - $paidAmount);
    } elseif ($paidAmount > 0) {
        $paymentStatus = $refundFlow ? 'cho_hoan_tien' : 'chua_thanh_toan';
        $remainingAmount = $refundFlow ? 0 : max(0, $totalAmount - $paidAmount);
    } else {
        $paymentStatus = 'chua_thanh_toan';
        $remainingAmount = $refundFlow ? 0 : $totalAmount;
    }

    db()->prepare('UPDATE orders SET paid_amount = ?, remaining_amount = ?, payment_status = ?, updated_at = NOW() WHERE id = ?')
        ->execute([$paidAmount, $remainingAmount, $paymentStatus, $orderId]);
}

function mark_payment_intent_paid(int $paymentIntentId, array $paymentData): array
{
    $intentStmt = db()->prepare('SELECT * FROM payment_intents WHERE id = ? LIMIT 1');
    $intentStmt->execute([$paymentIntentId]);
    $intent = $intentStmt->fetch();
    if (!$intent) {
        return ['ok' => false, 'message' => 'Không tìm thấy payment intent.'];
    }

    $notifyOrderId = !empty($intent['order_id']) ? (int)$intent['order_id'] : 0;

    db()->beginTransaction();
    try {
        $paymentStmt = db()->prepare('INSERT INTO payments (payment_intent_id, customer_id, order_id, provider, provider_transaction_id, provider_reference_code, transfer_type, paid_amount, fee_amount, net_amount, payment_status, raw_content, paid_at, confirmed_at, raw_payload_text, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, NOW(), NOW(), ?, NOW())');
        $paymentStmt->execute([
            $paymentIntentId,
            $intent['customer_id'] ?? null,
            $intent['order_id'] ?? null,
            $paymentData['provider'] ?? 'sepay',
            $paymentData['provider_transaction_id'],
            $paymentData['provider_reference_code'] ?? null,
            $paymentData['transfer_type'] ?? 'in',
            $paymentData['paid_amount'],
            $paymentData['paid_amount'],
            'success',
            $paymentData['raw_content'] ?? null,
            $paymentData['raw_payload_text'] ?? null,
        ]);
        $paymentId = (int)db()->lastInsertId();

        db()->prepare('UPDATE payment_intents SET status = ?, updated_at = NOW() WHERE id = ?')->execute(['paid', $paymentIntentId]);

        if ($notifyOrderId > 0) {
            sync_order_payment_status($notifyOrderId);
            $order = admin_get_order($notifyOrderId);
            if ($order) {
                db()->prepare('INSERT INTO order_status_logs (order_id, from_status, to_status, note, changed_by_type, changed_by_id, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())')
                    ->execute([$notifyOrderId, $order['order_status'], $order['order_status'], 'Nhận thanh toán thành công', 'webhook', null]);
            }
        }

        db()->commit();

        if ($notifyOrderId > 0) {
            notify_order_payment_status_via_telegram($notifyOrderId);
        }

        return ['ok' => true, 'payment_id' => $paymentId];
    } catch (Throwable $e) {
        if (db()->inTransaction()) {
            db()->rollBack();
        }
        if (str_contains($e->getMessage(), 'Duplicate')) {
            return ['ok' => true, 'duplicate' => true];
        }
        return ['ok' => false, 'message' => $e->getMessage()];
    }
}

function find_pending_payment_intent_from_sepay(array $payload): ?array
{
    $isGatewayIpn =
        isset($payload['notification_type'], $payload['order'], $payload['transaction']) &&
        is_array($payload['order']) &&
        is_array($payload['transaction']);

    if ($isGatewayIpn) {
        $invoiceNumber = trim((string)($payload['order']['order_invoice_number'] ?? ''));
        $orderDescription = trim((string)($payload['order']['order_description'] ?? ''));
        $amount = format_order_money(
            $payload['transaction']['transaction_amount']
            ?? $payload['order']['order_amount']
            ?? 0
        );

        $candidates = [];

        foreach ([$invoiceNumber, $orderDescription] as $text) {
            if ($text === '') {
                continue;
            }

            if (preg_match_all('/(PAY[A-Z0-9]{12})/', strtoupper($text), $matches)) {
                foreach (($matches[1] ?? []) as $code) {
                    $candidates[] = $code;
                }
            }
        }

        foreach (array_unique($candidates) as $intentCode) {
            $stmt = db()->prepare('
                SELECT *
                FROM payment_intents
                WHERE intent_code = ?
                  AND status IN ("pending", "waiting_payment")
                ORDER BY id DESC
                LIMIT 1
            ');
            $stmt->execute([$intentCode]);
            $intent = $stmt->fetch();

            if ($intent && format_order_money($intent['requested_amount']) <= $amount) {
                return $intent;
            }
        }

        if ($invoiceNumber !== '') {
            $stmt = db()->prepare('
                SELECT *
                FROM payment_intents
                WHERE transfer_note = ?
                  AND status IN ("pending", "waiting_payment")
                ORDER BY id DESC
                LIMIT 1
            ');
            $stmt->execute([$invoiceNumber]);
            $intent = $stmt->fetch();

            if ($intent && format_order_money($intent['requested_amount']) <= $amount) {
                return $intent;
            }

            $stmt = db()->prepare('SELECT id FROM orders WHERE order_code = ? LIMIT 1');
            $stmt->execute([$invoiceNumber]);
            $orderId = (int)$stmt->fetchColumn();

            if ($orderId > 0) {
                $stmt = db()->prepare('
                    SELECT *
                    FROM payment_intents
                    WHERE order_id = ?
                      AND status IN ("pending", "waiting_payment")
                    ORDER BY id DESC
                    LIMIT 1
                ');
                $stmt->execute([$orderId]);
                $intent = $stmt->fetch();

                if ($intent && format_order_money($intent['requested_amount']) <= $amount) {
                    return $intent;
                }
            }
        }

        return null;
    }

    $rawContent = trim((string)($payload['content'] ?? ''));
    $referenceCode = trim((string)($payload['referenceCode'] ?? ''));
    $amount = format_order_money($payload['transferAmount'] ?? 0);
    $candidates = [];

    foreach ([$referenceCode, $rawContent] as $text) {
        if ($text === '') {
            continue;
        }

        if (preg_match('/(PAY[A-Z0-9]{12})/', strtoupper($text), $m)) {
            $candidates[] = $m[1];
        }
    }

    if (!$candidates && $rawContent !== '') {
        $stmt = db()->prepare('
            SELECT *
            FROM payment_intents
            WHERE transfer_note = ?
              AND status IN ("pending", "waiting_payment")
            LIMIT 1
        ');
        $stmt->execute([$rawContent]);
        $intent = $stmt->fetch();

        if ($intent && format_order_money($intent['requested_amount']) <= $amount) {
            return $intent;
        }
    }

    foreach (array_unique($candidates) as $intentCode) {
        $stmt = db()->prepare('
            SELECT *
            FROM payment_intents
            WHERE intent_code = ?
              AND status IN ("pending", "waiting_payment")
            LIMIT 1
        ');
        $stmt->execute([$intentCode]);
        $intent = $stmt->fetch();

        if ($intent && format_order_money($intent['requested_amount']) <= $amount) {
            return $intent;
        }
    }

    return null;
}

function handle_sepay_webhook(array $headers, string $rawBody): array
{
    $required = require_upgrade_tables(['payment_webhook_logs', 'payment_intents', 'payments']);
    if ($required) {
        return ['ok' => false, 'status' => 500, 'message' => 'Thiếu bảng hệ thống mới: ' . implode(', ', $required)];
    }

    $payload = json_decode($rawBody, true);
    if (!is_array($payload)) {
        $payload = $_POST ?: [];
    }

    $expectedApiKey = sepay_webhook_api_key();
    if ($expectedApiKey !== '') {
        $providedAuth = trim((string)get_header_case_insensitive($headers, 'Authorization'));
        $validAuth = stripos($expectedApiKey, 'Apikey ') === 0 ? $expectedApiKey : ('Apikey ' . $expectedApiKey);

        if ($providedAuth === '' || !hash_equals($validAuth, $providedAuth)) {
            return ['ok' => false, 'status' => 403, 'message' => 'invalid_api_key'];
        }
    }

    $isGatewayIpn =
        isset($payload['notification_type'], $payload['order'], $payload['transaction']) &&
        is_array($payload['order']) &&
        is_array($payload['transaction']);

    $provider = 'sepay';
    $payloadSubAccount = '';
    $rawContent = '';

    if ($isGatewayIpn) {
        $notificationType = strtoupper(trim((string)($payload['notification_type'] ?? '')));
        if ($notificationType !== 'ORDER_PAID') {
            return ['ok' => true, 'status' => 200, 'message' => 'ignored'];
        }

        $transactionStatus = strtoupper(trim((string)($payload['transaction']['transaction_status'] ?? '')));
        $orderStatus = strtoupper(trim((string)($payload['order']['order_status'] ?? '')));

        if (
            ($transactionStatus !== '' && !in_array($transactionStatus, ['APPROVED', 'CAPTURED'], true)) &&
            ($orderStatus !== '' && !in_array($orderStatus, ['CAPTURED', 'PAID'], true))
        ) {
            return ['ok' => true, 'status' => 200, 'message' => 'ignored'];
        }

        $providerTransactionId = trim((string)(
            $payload['transaction']['transaction_id']
            ?? $payload['transaction']['id']
            ?? ''
        ));

        $eventKey = trim((string)(
            $payload['transaction']['id']
            ?? $payload['order']['id']
            ?? $providerTransactionId
        ));
        if ($eventKey === '') {
            $eventKey = hash('sha256', $rawBody);
        }

        $parsedAmount = format_order_money(
            $payload['transaction']['transaction_amount']
            ?? $payload['order']['order_amount']
            ?? 0
        );
        $parsedReferenceCode = trim((string)($payload['order']['order_invoice_number'] ?? ''));
        $parsedTransferType = 'in';
        $rawContent = trim((string)($payload['order']['order_description'] ?? ''));
    } else {
        $providerTransactionId = trim((string)($payload['id'] ?? ''));
        $eventKey = $providerTransactionId !== '' ? $providerTransactionId : hash('sha256', $rawBody);
        $parsedAmount = format_order_money($payload['transferAmount'] ?? 0);
        $parsedReferenceCode = trim((string)($payload['referenceCode'] ?? ''));
        $parsedTransferType = strtolower(trim((string)($payload['transferType'] ?? '')));
        $payloadSubAccount = trim((string)($payload['subAccount'] ?? ''));
        $rawContent = trim((string)($payload['content'] ?? ''));

        if ($parsedTransferType !== 'in') {
            $requestHeadersJson = json_encode($headers, JSON_UNESCAPED_UNICODE);

            $logStmt = db()->prepare('INSERT INTO payment_webhook_logs (provider, event_key, provider_transaction_id, request_headers_text, request_body_text, parsed_amount, parsed_reference_code, parsed_transfer_type, process_status, linked_payment_id, error_message, processed_at, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, NOW())');
            try {
                $logStmt->execute([$provider, $eventKey, $providerTransactionId ?: null, $requestHeadersJson, $rawBody, $parsedAmount, $parsedReferenceCode ?: null, $parsedTransferType ?: null, 'ignored']);
            } catch (Throwable $e) {
            }

            return ['ok' => true, 'status' => 200, 'message' => 'ignored'];
        }

        $expectedSubAccount = sepay_expected_sub_account();
        if ($expectedSubAccount !== '' && $payloadSubAccount !== '' && !hash_equals($expectedSubAccount, $payloadSubAccount)) {
            $requestHeadersJson = json_encode($headers, JSON_UNESCAPED_UNICODE);

            $logStmt = db()->prepare('INSERT INTO payment_webhook_logs (provider, event_key, provider_transaction_id, request_headers_text, request_body_text, parsed_amount, parsed_reference_code, parsed_transfer_type, process_status, linked_payment_id, error_message, processed_at, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, ?, NOW(), NOW())');
            try {
                $logStmt->execute([$provider, $eventKey, $providerTransactionId ?: null, $requestHeadersJson, $rawBody, $parsedAmount, $parsedReferenceCode ?: null, $parsedTransferType ?: null, 'failed', 'SubAccount không khớp cấu hình']);
            } catch (Throwable $e) {
            }

            return ['ok' => false, 'status' => 400, 'message' => 'sub_account_mismatch'];
        }
    }

    $requestHeadersJson = json_encode($headers, JSON_UNESCAPED_UNICODE);

    $logStmt = db()->prepare('INSERT INTO payment_webhook_logs (provider, event_key, provider_transaction_id, request_headers_text, request_body_text, parsed_amount, parsed_reference_code, parsed_transfer_type, process_status, linked_payment_id, error_message, processed_at, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, NOW())');

    try {
        $logStmt->execute([
            $provider,
            $eventKey,
            $providerTransactionId ?: null,
            $requestHeadersJson,
            $rawBody,
            $parsedAmount,
            $parsedReferenceCode ?: null,
            $parsedTransferType ?: null,
            'received'
        ]);
        $webhookLogId = (int)db()->lastInsertId();
    } catch (Throwable $e) {
        if (str_contains($e->getMessage(), 'Duplicate')) {
            return ['ok' => true, 'status' => 200, 'message' => 'duplicate'];
        }
        return ['ok' => false, 'status' => 500, 'message' => $e->getMessage()];
    }

    $intent = find_pending_payment_intent_from_sepay($payload);
    if (!$intent) {
        db()->prepare('UPDATE payment_webhook_logs SET process_status = ?, processed_at = NOW(), error_message = ? WHERE id = ?')
            ->execute(['failed', 'Không tìm thấy payment intent phù hợp', $webhookLogId]);

        return ['ok' => false, 'status' => 422, 'message' => 'intent_not_found'];
    }

    $result = mark_payment_intent_paid((int)$intent['id'], [
        'provider' => 'sepay',
        'provider_transaction_id' => $providerTransactionId !== '' ? $providerTransactionId : ('BODY_' . substr(hash('sha256', $rawBody), 0, 24)),
        'provider_reference_code' => $parsedReferenceCode ?: null,
        'transfer_type' => 'in',
        'paid_amount' => $parsedAmount,
        'raw_content' => $rawContent,
        'raw_payload_text' => $rawBody,
    ]);

    if (!$result['ok']) {
        db()->prepare('UPDATE payment_webhook_logs SET process_status = ?, processed_at = NOW(), error_message = ? WHERE id = ?')
            ->execute(['failed', $result['message'], $webhookLogId]);

        return ['ok' => false, 'status' => 500, 'message' => $result['message']];
    }

    db()->prepare('UPDATE payment_webhook_logs SET process_status = ?, linked_payment_id = ?, processed_at = NOW(), error_message = NULL WHERE id = ?')
        ->execute([!empty($result['duplicate']) ? 'duplicate' : 'processed', $result['payment_id'] ?? null, $webhookLogId]);

    return ['ok' => true, 'status' => 200, 'message' => 'processed'];
}