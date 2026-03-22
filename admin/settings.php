<?php
require_once __DIR__ . '/../includes/functions.php';

admin_require_login();

if (!table_exists('app_settings')) {
    exit('Bảng app_settings chưa tồn tại. Hãy chạy migration phase 4.');
}

/**
 * Cấu hình field
 */
$sections = [
    'general' => 'Thông tin chung',
    'contact' => 'Liên hệ & mạng xã hội',
    'payment' => 'Thanh toán / SePay',
    'notifications' => 'Thông báo Telegram',
    'features' => 'Tính năng hệ thống',
];

$fields = [
    'shop_name' => [
        'label' => 'Tên shop',
        'section' => 'general',
        'type' => 'text',
        'placeholder' => 'Ví dụ: Duong Mot Mi Shop',
    ],
    'shop_tagline' => [
        'label' => 'Tagline',
        'section' => 'general',
        'type' => 'textarea',
        'placeholder' => 'Ví dụ: Thời trang tối giản, chốt đơn nhanh qua Zalo',
    ],
    'shop_logo' => [
        'label' => 'Logo / ảnh thương hiệu',
        'section' => 'general',
        'type' => 'file',
        'help' => 'Chọn ảnh để tải lên làm logo (Hệ thống sẽ tự động lưu thành img/logo.jpg).',
    ],

    'shop_phone' => [
        'label' => 'Số điện thoại',
        'section' => 'contact',
        'type' => 'text',
        'placeholder' => 'Ví dụ: 0912345678',
    ],
    'shop_email' => [
        'label' => 'Email liên hệ',
        'section' => 'contact',
        'type' => 'email',
        'placeholder' => 'contact@shop.com',
    ],
    'shop_address' => [
        'label' => 'Địa chỉ',
        'section' => 'contact',
        'type' => 'text',
        'placeholder' => 'Ví dụ: Hà Nội / TP.HCM',
    ],
    'shop_working_hours' => [
        'label' => 'Giờ làm việc',
        'section' => 'contact',
        'type' => 'text',
        'placeholder' => 'Ví dụ: 8:00 - 22:00',
    ],
    'zalo_contact_link' => [
        'label' => 'Link Zalo',
        'section' => 'contact',
        'type' => 'url',
        'placeholder' => 'https://zalo.me/...',
    ],
    'zalo_group_link' => [
        'label' => 'Link nhóm Zalo',
        'section' => 'contact',
        'type' => 'url',
        'placeholder' => 'https://zalo.me/g/...',
    ],
    'facebook_link' => [
        'label' => 'Link Facebook',
        'section' => 'contact',
        'type' => 'url',
        'placeholder' => 'https://facebook.com/...',
    ],
    'instagram_link' => [
        'label' => 'Link Instagram',
        'section' => 'contact',
        'type' => 'url',
        'placeholder' => 'https://instagram.com/...',
    ],
    'tiktok_link' => [
        'label' => 'Link TikTok',
        'section' => 'contact',
        'type' => 'url',
        'placeholder' => 'https://tiktok.com/@...',
    ],

    'default_deposit_rate' => [
        'label' => 'Tỷ lệ cọc mặc định (%)',
        'section' => 'payment',
        'type' => 'number',
        'placeholder' => 'Ví dụ: 30',
        'min' => 0,
        'max' => 100,
        'help' => 'Nhập từ 0 đến 100.',
    ],
    'sepay_bank_name' => [
        'label' => 'Tên ngân hàng hiển thị',
        'section' => 'payment',
        'type' => 'text',
        'placeholder' => 'Ví dụ: MB Bank',
    ],
    'sepay_bank_code' => [
        'label' => 'Mã ngân hàng QR SePay',
        'section' => 'payment',
        'type' => 'text',
        'placeholder' => 'Ví dụ: MBBank',
        'help' => 'Dùng cho QR SePay.',
    ],
    'sepay_bank_account_no' => [
        'label' => 'Số tài khoản / SubAccount SePay',
        'section' => 'payment',
        'type' => 'text',
        'placeholder' => 'Ví dụ: 123456789',
    ],
    'sepay_account_name' => [
        'label' => 'Chủ tài khoản SePay',
        'section' => 'payment',
        'type' => 'text',
        'placeholder' => 'Ví dụ: NGUYEN VAN A',
    ],
    'sepay_webhook_api_key' => [
        'label' => 'Webhook API Key SePay',
        'section' => 'payment',
        'type' => 'text',
        'placeholder' => 'Nhập API key',
        'help' => 'Nhập cùng API Key đã cấu hình trên SePay.',
    ],
    'sepay_expected_sub_account' => [
        'label' => 'SubAccount kỳ vọng khi callback',
        'section' => 'payment',
        'type' => 'text',
        'placeholder' => 'Ví dụ: SUB001',
    ],


    'telegram_bot_username' => [
        'label' => 'Username bot Telegram',
        'section' => 'notifications',
        'type' => 'text',
        'placeholder' => 'Ví dụ: DuongMotMI_notify_bot',
        'help' => 'Chỉ để ghi nhớ, không bắt buộc.',
    ],
    'telegram_bot_token' => [
        'label' => 'Bot Token Telegram',
        'section' => 'notifications',
        'type' => 'text',
        'placeholder' => 'Dán Bot Token mới từ @BotFather',
        'help' => 'Mở bot trên Telegram và /start trước.',
    ],
    'telegram_chat_id' => [
        'label' => 'Chat ID Telegram nhận thông báo',
        'section' => 'notifications',
        'type' => 'text',
        'placeholder' => 'Ví dụ: 123456789',
        'help' => 'Lấy bằng API getUpdates sau khi đã bấm Start với bot.',
    ],

    'enable_guest_checkout' => [
        'label' => 'Cho phép guest checkout',
        'section' => 'features',
        'type' => 'checkbox',
    ],
    'enable_wallet' => [
        'label' => 'Bật ví tiền',
        'section' => 'features',
        'type' => 'checkbox',
    ],

    'telegram_notify_enabled' => [
        'label' => 'Bật thông báo Telegram (Đơn cọc/Thanh toán)',
        'section' => 'features',
        'type' => 'checkbox',
    ],
    'enable_social_login_google' => [
        'label' => 'Bật đăng nhập Google',
        'section' => 'features',
        'type' => 'checkbox',
    ],
    'enable_social_login_facebook' => [
        'label' => 'Bật đăng nhập Facebook',
        'section' => 'features',
        'type' => 'checkbox',
    ],
];

/**
 * Gom field theo section
 */
$groupedFields = [];
foreach ($fields as $key => $meta) {
    $section = $meta['section'] ?? 'general';
    $groupedFields[$section][$key] = $meta;
}

/**
 * Lấy giá trị hiện tại từ DB
 */
$values = [];
foreach ($fields as $key => $meta) {
    $default = ($meta['type'] ?? 'text') === 'checkbox' ? '0' : '';
    $values[$key] = (string) app_setting($key, $default);
}

/**
 * Chuẩn hóa dữ liệu đầu vào
 */
function normalize_setting_input(string $key, array $meta, array $currentValues)
{
    $type = $meta['type'] ?? 'text';

    if ($type === 'checkbox') {
        return isset($_POST[$key]) ? '1' : '0';
    }

    if ($type === 'password') {
        $value = trim((string)($_POST[$key] ?? ''));
        return $value === '' ? (string) ($currentValues[$key] ?? '') : $value;
    }

    if ($type === 'file') {
        if (isset($_FILES[$key]) && $_FILES[$key]['error'] === UPLOAD_ERR_OK) {
            if ($key === 'shop_logo') {
                $uploadDir = __DIR__ . '/../img/';
                if (!is_dir($uploadDir)) {
                    mkdir($uploadDir, 0755, true);
                }
                
                $targetFile = $uploadDir . 'logo.jpg';
                $check = @getimagesize($_FILES[$key]['tmp_name']);
                
                if ($check !== false) {
                    if (move_uploaded_file($_FILES[$key]['tmp_name'], $targetFile)) {
                        return 'img/logo.jpg';
                    }
                }
            }
        }
        return (string)($currentValues[$key] ?? '');
    }

    $value = trim((string)($_POST[$key] ?? ''));

    if ($type === 'email') {
        if ($value === '') {
            return '';
        }
        return filter_var($value, FILTER_VALIDATE_EMAIL) ? $value : '';
    }

    if ($type === 'url') {
        if ($value === '') {
            return '';
        }
        return filter_var($value, FILTER_VALIDATE_URL) ? $value : '';
    }

    if ($type === 'number') {
        $number = is_numeric($value) ? (float)$value : 0;
        $min = isset($meta['min']) ? (float)$meta['min'] : null;
        $max = isset($meta['max']) ? (float)$meta['max'] : null;

        if ($min !== null && $number < $min) {
            $number = $min;
        }
        if ($max !== null && $number > $max) {
            $number = $max;
        }

        return (string)(int)$number;
    }

    return $value;
}

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf_or_fail();

    try {
        db()->beginTransaction();

        $stmt = db()->prepare(
            'INSERT INTO app_settings (setting_key, setting_value, updated_at)
             VALUES (?, ?, NOW())
             ON DUPLICATE KEY UPDATE
                setting_value = VALUES(setting_value),
                updated_at = NOW()'
        );

        foreach ($fields as $key => $meta) {
            $value = normalize_setting_input($key, $meta, $values);
            $stmt->execute([$key, $value]);
            
            $values[$key] = $value;
        }

        db()->commit();
        $message = 'Đã lưu thiết lập website thành công.';
    } catch (Throwable $e) {
        if (db()->inTransaction()) {
            db()->rollBack();
        }
        $error = 'Lưu thiết lập thất bại: ' . $e->getMessage();
    }
}

?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thiết lập website</title>
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/style.css">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --bg-body: #f8fafc;
            --bg-card: #ffffff;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --focus-ring: rgba(79, 70, 229, 0.2);
            --success-bg: #f0fdf4;
            --success-text: #166534;
            --success-border: #bbf7d0;
            --error-bg: #fef2f2;
            --error-text: #991b1b;
            --error-border: #fecaca;
        }

        * { box-sizing: border-box; }
        
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background: var(--bg-body);
            margin: 0;
            color: var(--text-main);
            line-height: 1.5;
        }

        .wrap {
            max-width: 1024px;
            margin: 40px auto;
            padding: 0 20px 60px;
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .title {
            margin: 0 0 4px;
            font-size: 28px;
            font-weight: 700;
            letter-spacing: -0.025em;
        }

        .sub {
            color: var(--text-muted);
            font-size: 15px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            border-radius: 8px;
            padding: 10px 20px;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            border: 1px solid transparent;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-primary {
            background: var(--primary);
            color: #fff;
            box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.1), 0 2px 4px -1px rgba(79, 70, 229, 0.06);
        }

        .btn-primary:hover {
            background: var(--primary-hover);
            transform: translateY(-1px);
            box-shadow: 0 6px 8px -1px rgba(79, 70, 229, 0.15), 0 4px 6px -1px rgba(79, 70, 229, 0.1);
        }

        .btn-secondary {
            background: #fff;
            color: var(--text-main);
            border-color: var(--border-color);
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
        }

        .btn-secondary:hover {
            background: #f1f5f9;
        }

        .alert {
            margin-bottom: 24px;
            padding: 16px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            border: 1px solid;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-success {
            background: var(--success-bg);
            color: var(--success-text);
            border-color: var(--success-border);
        }

        .alert-error {
            background: var(--error-bg);
            color: var(--error-text);
            border-color: var(--error-border);
        }

        .section-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 28px;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05), 0 1px 2px 0 rgba(0, 0, 0, 0.03);
            margin-bottom: 24px;
        }

        .section-title {
            margin: 0 0 24px;
            font-size: 18px;
            font-weight: 600;
            color: var(--text-main);
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border-color);
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px 24px;
        }

        .group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .group-full {
            grid-column: 1 / -1;
        }

        .group label {
            font-weight: 500;
            font-size: 14px;
            color: #334155;
        }

        .group input[type="text"],
        .group input[type="email"],
        .group input[type="url"],
        .group input[type="number"],
        .group input[type="password"],
        .group textarea {
            width: 100%;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 10px 14px;
            font-size: 14px;
            font-family: inherit;
            background: #fff;
            color: var(--text-main);
            transition: all 0.2s ease;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.02);
        }

        .group input:focus,
        .group textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px var(--focus-ring);
        }

        .group textarea {
            min-height: 100px;
            resize: vertical;
        }

        .group input[type="file"] {
            font-size: 14px;
            color: var(--text-muted);
            file-selector-button: font-weight 500;
        }
        
        .group input[type="file"]::file-selector-button {
            margin-right: 12px;
            padding: 8px 16px;
            border-radius: 6px;
            border: 1px solid var(--border-color);
            background: #f8fafc;
            color: var(--text-main);
            cursor: pointer;
            transition: background 0.2s;
        }

        .group input[type="file"]::file-selector-button:hover {
            background: #f1f5f9;
        }

        .help {
            color: var(--text-muted);
            font-size: 13px;
            margin-top: 2px;
        }

        /* Toggle Switch UI */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .toggle-wrapper {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px;
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .toggle-wrapper:hover {
            border-color: #cbd5e1;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }

        .toggle-label-text {
            font-weight: 500;
            font-size: 14px;
            color: var(--text-main);
            user-select: none;
        }

        .toggle-input {
            display: none;
        }

        .toggle-switch {
            position: relative;
            width: 44px;
            height: 24px;
            background-color: #cbd5e1;
            border-radius: 999px;
            transition: background-color 0.2s ease;
            flex-shrink: 0;
        }

        .toggle-switch::after {
            content: '';
            position: absolute;
            top: 2px;
            left: 2px;
            width: 20px;
            height: 20px;
            background-color: white;
            border-radius: 50%;
            transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
        }

        .toggle-input:checked + .toggle-switch {
            background-color: var(--primary);
        }

        .toggle-input:checked + .toggle-switch::after {
            transform: translateX(20px);
        }

        .sticky-actions {
            position: sticky;
            bottom: 24px;
            z-index: 30;
            display: flex;
            justify-content: flex-end;
            margin-top: 32px;
        }

        .sticky-box {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 16px 24px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
        }

        @media (max-width: 768px) {
            .grid, .features-grid {
                grid-template-columns: 1fr;
            }
            .header-section {
                flex-direction: column;
                align-items: flex-start;
            }
            .wrap { padding: 0 16px 80px; }
            .section-card { padding: 20px; }
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="header-section">
        <div>
            <h1 class="title">Thiết lập Website</h1>
            <div class="sub">
                Quản lý thông tin chung, liên hệ, thanh toán SePay và các tính năng hệ thống.
            </div>
        </div>

        <div class="actions">
            <a class="btn btn-secondary" href="<?= route_url('/admin/products.php') ?>">
                <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
                Trở về
            </a>
        </div>
    </div>

    <?php if ($message): ?>
        <div class="alert alert-success">
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <?= e($message) ?>
        </div>
    <?php endif; ?>

    <?php if ($error): ?>
        <div class="alert alert-error">
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <?= e($error) ?>
        </div>
    <?php endif; ?>

    <form method="post" autocomplete="off" enctype="multipart/form-data">
        <?= csrf_field() ?>

        <?php foreach ($groupedFields as $sectionKey => $sectionFields): ?>
            <div class="section-card">
                <h2 class="section-title"><?= e($sections[$sectionKey] ?? 'Thiết lập') ?></h2>

                <?php
                $isFeatureSection = true;
                foreach ($sectionFields as $meta) {
                    if (($meta['type'] ?? 'text') !== 'checkbox') {
                        $isFeatureSection = false;
                        break;
                    }
                }
                ?>

                <?php if ($isFeatureSection): ?>
                    <div class="features-grid">
                        <?php foreach ($sectionFields as $key => $meta): ?>
                            <label class="toggle-wrapper">
                                <span class="toggle-label-text"><?= e($meta['label']) ?></span>
                                <input
                                    class="toggle-input"
                                    type="checkbox"
                                    name="<?= e($key) ?>"
                                    value="1"
                                    <?= $values[$key] === '1' ? 'checked' : '' ?>
                                >
                                <div class="toggle-switch"></div>
                            </label>
                        <?php endforeach; ?>
                    </div>
                <?php else: ?>
                    <div class="grid">
                        <?php foreach ($sectionFields as $key => $meta): ?>
                            <?php
                            $type = $meta['type'] ?? 'text';
                            $inputType = in_array($type, ['text', 'email', 'url', 'number', 'password', 'file'], true) ? $type : 'text';
                            $isFull = in_array($type, ['textarea', 'file'], true);
                            ?>
                            <div class="group <?= $isFull ? 'group-full' : '' ?>">
                                <label for="<?= e($key) ?>"><?= e($meta['label']) ?></label>

                                <?php if ($type === 'textarea'): ?>
                                    <textarea
                                        id="<?= e($key) ?>"
                                        name="<?= e($key) ?>"
                                        placeholder="<?= e($meta['placeholder'] ?? '') ?>"
                                    ><?= e($values[$key]) ?></textarea>
                                
                                <?php elseif ($type === 'file'): ?>
                                    <?php if (!empty($values[$key])): ?>
                                        <div style="margin-bottom: 12px;">
                                            <img src="<?= BASE_URL . '/' . e($values[$key]) ?>?v=<?= time() ?>" alt="Ảnh hiện tại" style="max-height: 80px; border-radius: 8px; border: 1px solid var(--border-color); box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                                        </div>
                                    <?php endif; ?>
                                    <input
                                        id="<?= e($key) ?>"
                                        type="file"
                                        name="<?= e($key) ?>"
                                        accept="image/*"
                                    >
                                    
                                <?php else: ?>
                                    <?php $fieldValue = $inputType === 'password' ? '' : $values[$key]; ?>
                                    <input
                                        id="<?= e($key) ?>"
                                        type="<?= e($inputType) ?>"
                                        name="<?= e($key) ?>"
                                        value="<?= e($fieldValue) ?>"
                                        placeholder="<?= e($meta['placeholder'] ?? '') ?>"
                                        <?php if (isset($meta['min'])): ?>min="<?= e((string)$meta['min']) ?>"<?php endif; ?>
                                        <?php if (isset($meta['max'])): ?>max="<?= e((string)$meta['max']) ?>"<?php endif; ?>
                                    >
                                <?php endif; ?>

                                <?php if (!empty($meta['help'])): ?>
                                    <div class="help"><?= e($meta['help']) ?></div>
                                <?php endif; ?>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>

        <div class="sticky-actions">
            <div class="sticky-box">
                <button class="btn btn-primary" type="submit">
                    <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4"></path></svg>
                    Lưu thiết lập
                </button>
            </div>
        </div>
    </form>
</div>
</body>
</html>