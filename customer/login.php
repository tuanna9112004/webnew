<?php
require_once __DIR__ . '/../includes/functions.php';

if (is_customer_logged_in()) {
    redirect('/customer/account.php');
}

$pageTitle = 'Đăng nhập khách hàng';
$pageStylesheets = [BASE_URL . '/assets/shop-upgrade.css'];
$error = '';
$redirectTarget = (string)($_GET['redirect'] ?? '/customer/account.php');

if (is_post()) {
    if (!csrf_is_valid(true)) {
        refresh_csrf_token();
        $error = 'Phiên đăng nhập đã được làm mới. Vui lòng bấm đăng nhập lại một lần nữa.';
    } else {
        $login = trim((string)($_POST['login'] ?? ''));
        $password = (string)($_POST['password'] ?? '');
        $customer = customer_find_by_login($login);

        if ($customer && !empty($customer['password_hash']) && password_verify($password, $customer['password_hash'])) {
            customer_login($customer);
            flash_set('customer_auth', 'Đăng nhập thành công.', 'success');
            $target = trim((string)($_POST['redirect'] ?? $redirectTarget));
            if ($target === '' || !str_starts_with($target, '/')) {
                $target = '/customer/account.php';
            }
            redirect($target);
        }

        customer_log_security_event($customer['id'] ?? null, 'login_failed', 'Đăng nhập thất bại với: ' . $login);
        $error = 'Sai thông tin đăng nhập hoặc tài khoản chưa tồn tại.';
    }
}

$flash = flash_get('customer_auth');
require_once __DIR__ . '/../includes/header.php';
?>

<div class="auth-shell" style="max-width:560px; padding-top: 24px;">
    <div class="auth-card">
        <h1 class="section-title">Đăng nhập khách hàng</h1>
        <p class="section-subtitle">Dùng email hoặc số điện thoại để truy cập tài khoản của bạn.</p>

        <?php if ($flash): ?>
            <div class="alert alert-<?= e($flash['type']) ?>"><?= e($flash['message']) ?></div>
        <?php endif; ?>
        <?php if ($error): ?>
            <div class="alert alert-error"><?= e($error) ?></div>
        <?php endif; ?>

        <form method="post">
            <?= csrf_field() ?>
            <input type="hidden" name="redirect" value="<?= e($redirectTarget) ?>">
            <div class="form-group">
                <label class="form-label" for="login">Email hoặc số điện thoại</label>
                <input class="form-control" id="login" name="login" value="<?= e(old_input('login')) ?>" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="password">Mật khẩu</label>
                <input class="form-control" type="password" id="password" name="password" required>
            </div>
            <button class="btn-primary" type="submit">Đăng nhập</button>
            <a class="link-muted" style="margin-left:12px;" href="<?= route_url('/customer/register.php') ?>">Chưa có tài khoản? Đăng ký</a>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
