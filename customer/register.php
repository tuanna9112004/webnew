<?php
require_once __DIR__ . '/../includes/functions.php';

if (is_customer_logged_in()) {
    redirect('/customer/account.php');
}

$pageTitle = 'Đăng ký tài khoản';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$error = '';

if (is_post()) {
    if (!csrf_is_valid(true)) {
        refresh_csrf_token();
        $error = 'Phiên đăng ký đã được làm mới. Vui lòng gửi lại biểu mẫu.';
    } else {
        $result = customer_register_local($_POST);
        if ($result['ok']) {
            flash_set('customer_auth', 'Đăng ký thành công. Chào mừng bạn đến với shop!', 'success');
            redirect('/customer/account.php');
        }
        $error = $result['message'] ?? 'Không thể đăng ký.';
    }
}

require_once __DIR__ . '/../includes/header.php';
?>

<div class="auth-shell" style="max-width:560px; padding-top: 24px;">
    <div class="auth-card">
        <h1 class="section-title">Tạo tài khoản khách hàng</h1>
        <p class="section-subtitle">Lưu thông tin nhận hàng, theo dõi đơn và mua nhanh hơn ở lần sau.</p>

        <?php if ($error): ?>
            <div class="alert alert-error"><?= e($error) ?></div>
        <?php endif; ?>

        <form method="post">
            <?= csrf_field() ?>
            <div class="form-group">
                <label class="form-label" for="full_name">Họ và tên</label>
                <input class="form-control" id="full_name" name="full_name" value="<?= e(old_input('full_name')) ?>" required>
            </div>
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="email">Email</label>
                    <input class="form-control" type="email" id="email" name="email" value="<?= e(old_input('email')) ?>">
                </div>
                <div class="form-group">
                    <label class="form-label" for="phone">Số điện thoại</label>
                    <input class="form-control" id="phone" name="phone" value="<?= e(old_input('phone')) ?>">
                </div>
            </div>
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="password">Mật khẩu</label>
                    <input class="form-control" type="password" id="password" name="password" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="password_confirm">Nhập lại mật khẩu</label>
                    <input class="form-control" type="password" id="password_confirm" name="password_confirm" required>
                </div>
            </div>
            <button class="btn-primary" type="submit">Đăng ký</button>
            <a class="link-muted" style="margin-left:12px;" href="<?= route_url('/customer/login.php') ?>">Đã có tài khoản? Đăng nhập</a>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
