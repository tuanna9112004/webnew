<?php
$httpsEnabled = (
    (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
    || (($_SERVER['SERVER_PORT'] ?? null) == 443)
    || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https')
);

if (session_status() === PHP_SESSION_NONE) {
    session_name('dmm_shop_session');
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'domain' => '',
        'secure' => $httpsEnabled,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');
    ini_set('session.cookie_httponly', '1');
    ini_set('session.cookie_samesite', 'Lax');
    if ($httpsEnabled) {
        ini_set('session.cookie_secure', '1');
    }
    session_start();
}

define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'clothing_shop');
define('DB_USER', 'root');
define('DB_PASS', '123456');

define('BASE_URL', ''); // ví dụ '' nếu nằm trực tiếp trong htdocs
define('ZALO_LINK', 'https://zalo.me/0961691107');
define('ORDER_DEPOSIT_RATE', 30);

/**
 * SePay config fallback
 * Nếu đã có app_settings thì callback sẽ ưu tiên đọc từ app_settings.
 * Nếu chưa có app_settings hoặc chưa lưu key thì sẽ dùng hằng số này.
 */
define('SEPAY_WEBHOOK_API_KEY', 'DMM_SEPAY_2026_SECRET_8899');
define('SEPAY_EXPECTED_SUB_ACCOUNT', 'VQRQAHSJJ1234'); // ví dụ: VA123456, không dùng thì để ''

define('CUSTOMER_SESSION_IDLE_TIMEOUT', 60 * 60 * 6);
define('CUSTOMER_SESSION_ABSOLUTE_TIMEOUT', 60 * 60 * 24 * 14);

date_default_timezone_set('Asia/Ho_Chi_Minh');