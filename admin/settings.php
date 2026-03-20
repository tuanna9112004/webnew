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
        'type' => 'text',
        'placeholder' => '/uploads/logo.png hoặc https://...',
        'help' => 'Nhập đường dẫn ảnh hoặc URL logo.',
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
        'type' => 'password',
        'placeholder' => 'Nhập API key',
        'help' => 'Nhập cùng API Key đã cấu hình trên SePay. Để trống nếu không muốn thay đổi.',
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
        'type' => 'password',
        'placeholder' => 'Dán Bot Token mới từ @BotFather',
        'help' => 'Mở bot trên Telegram và /start trước. Để trống nếu không muốn thay đổi token đã lưu.',
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
        'label' => 'Bật thông báo Telegram cho đơn đã cọc / đã thanh toán',
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
 * Chuẩn hóa dữ liệu đầu vào
 */
function normalize_setting_input(string $key, array $meta)
{
    $type = $meta['type'] ?? 'text';

    if ($type === 'checkbox') {
        return isset($_POST[$key]) ? '1' : '0';
    }

    if ($type === 'password') {
        $value = trim((string)($_POST[$key] ?? ''));
        return $value === '' ? (string) app_setting($key, '') : $value;
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
            $value = normalize_setting_input($key, $meta);
            $stmt->execute([$key, $value]);
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

/**
 * Lấy giá trị hiện tại
 */
$values = [];
foreach ($fields as $key => $meta) {
    $default = ($meta['type'] ?? 'text') === 'checkbox' ? '0' : '';
    $values[$key] = (string) app_setting($key, $default);
}
$hasSepayWebhookApiKey = trim((string)($values['sepay_webhook_api_key'] ?? '')) !== '';
$hasTelegramBotToken = trim((string)($values['telegram_bot_token'] ?? '')) !== '';
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thiết lập website</title>
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/style.css">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: #f6f7fb;
            margin: 0;
            color: #111827;
        }
        .wrap {
            max-width: 1180px;
            margin: 32px auto;
            padding: 0 16px 40px;
        }
        .top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 22px;
        }
        .title {
            margin: 0 0 8px;
            font-size: 30px;
            line-height: 1.2;
        }
        .sub {
            color: #6b7280;
            font-size: 14px;
            max-width: 760px;
        }
        .actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            border-radius: 14px;
            padding: 12px 18px;
            text-decoration: none;
            font-weight: 800;
            border: 1px solid #111827;
            background: #111827;
            color: #fff;
            cursor: pointer;
            transition: .18s ease;
        }
        .btn:hover {
            transform: translateY(-1px);
            opacity: .96;
        }
        .btn-secondary {
            background: #fff;
            color: #111827;
            border-color: #d1d5db;
        }

        .alert {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: 14px;
            font-size: 14px;
            border: 1px solid;
        }
        .alert-success {
            background: #ecfdf5;
            color: #065f46;
            border-color: #a7f3d0;
        }
        .alert-error {
            background: #fef2f2;
            color: #991b1b;
            border-color: #fecaca;
        }

        .section-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 24px;
            padding: 22px;
            box-shadow: 0 16px 40px rgba(15, 23, 42, .05);
            margin-bottom: 18px;
        }
        .section-title {
            margin: 0 0 16px;
            font-size: 20px;
            font-weight: 800;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }
        .group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .group-full {
            grid-column: 1 / -1;
        }
        .group label {
            font-weight: 700;
            font-size: 14px;
        }
        .group input,
        .group textarea {
            width: 100%;
            border: 1px solid #d1d5db;
            border-radius: 14px;
            padding: 12px 14px;
            font: inherit;
            background: #fff;
            color: #111827;
            transition: border-color .18s ease, box-shadow .18s ease;
        }
        .group input:focus,
        .group textarea:focus {
            outline: none;
            border-color: #111827;
            box-shadow: 0 0 0 3px rgba(17, 24, 39, .08);
        }
        .group textarea {
            min-height: 110px;
            resize: vertical;
        }
        .help {
            color: #6b7280;
            font-size: 12px;
            line-height: 1.5;
        }
        .secret-status {
            margin-top: 4px;
            color: #065f46;
            font-size: 12px;
            font-weight: 700;
        }

        .checkbox-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
        }
        .checkbox {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 14px 16px;
            border: 1px solid #e5e7eb;
            border-radius: 16px;
            background: #fafafa;
            cursor: pointer;
            font-weight: 600;
        }
        .checkbox input {
            width: 18px;
            height: 18px;
            accent-color: #111827;
        }

        .sticky-actions {
            position: sticky;
            bottom: 12px;
            z-index: 30;
            display: flex;
            justify-content: flex-end;
            margin-top: 18px;
        }
        .sticky-box {
            background: rgba(255,255,255,.9);
            backdrop-filter: blur(10px);
            border: 1px solid #e5e7eb;
            border-radius: 18px;
            padding: 12px;
            box-shadow: 0 12px 30px rgba(15,23,42,.08);
        }

        @media (max-width: 860px) {
            .grid,
            .checkbox-grid {
                grid-template-columns: 1fr;
            }
            .title {
                font-size: 26px;
            }
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="top">
        <div>
            <h1 class="title">Thiết lập website</h1>
            <div class="sub">
                Quản lý thông tin shop, liên hệ, mạng xã hội, SePay và các tính năng hệ thống.
                Các dữ liệu này sẽ thay thế phần config hard-code trên giao diện.
            </div>
        </div>

        <div class="actions">
            <a class="btn btn-secondary" href="<?= route_url('/admin/products.php') ?>">Quay lại quản lý sản phẩm</a>
        </div>
    </div>

    <?php if ($message): ?>
        <div class="alert alert-success"><?= e($message) ?></div>
    <?php endif; ?>

    <?php if ($error): ?>
        <div class="alert alert-error"><?= e($error) ?></div>
    <?php endif; ?>

    <form method="post" autocomplete="off">
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
                    <div class="checkbox-grid">
                        <?php foreach ($sectionFields as $key => $meta): ?>
                            <label class="checkbox">
                                <input
                                    type="checkbox"
                                    name="<?= e($key) ?>"
                                    value="1"
                                    <?= $values[$key] === '1' ? 'checked' : '' ?>
                                >
                                <span><?= e($meta['label']) ?></span>
                            </label>
                        <?php endforeach; ?>
                    </div>
                <?php else: ?>
                    <div class="grid">
                        <?php foreach ($sectionFields as $key => $meta): ?>
                            <?php
                            $type = $meta['type'] ?? 'text';
                            $inputType = in_array($type, ['text', 'email', 'url', 'number', 'password'], true) ? $type : 'text';
                            $isFull = $type === 'textarea';
                            ?>
                            <div class="group <?= $isFull ? 'group-full' : '' ?>">
                                <label for="<?= e($key) ?>"><?= e($meta['label']) ?></label>

                                <?php if ($type === 'textarea'): ?>
                                    <textarea
                                        id="<?= e($key) ?>"
                                        name="<?= e($key) ?>"
                                        placeholder="<?= e($meta['placeholder'] ?? '') ?>"
                                    ><?= e($values[$key]) ?></textarea>
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
                                <?php if ($key === 'sepay_webhook_api_key' && $hasSepayWebhookApiKey): ?>
                                    <div class="secret-status">Đã lưu API Key SePay. Để trống nếu không muốn thay đổi.</div>
                                <?php endif; ?>
                                <?php if ($key === 'telegram_bot_token' && $hasTelegramBotToken): ?>
                                    <div class="secret-status">Đã lưu Bot Token Telegram. Để trống nếu không muốn thay đổi.</div>
                                <?php endif; ?>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>

        <div class="sticky-actions">
            <div class="sticky-box">
                <button class="btn" type="submit">Lưu thiết lập</button>
            </div>
        </div>
    </form>
</div>
</body>
</html>