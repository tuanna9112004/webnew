<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

// Lấy ID sản phẩm cần hiển thị lại
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

if ($id > 0) {
    try {
        $stmt = db()->prepare("UPDATE products SET is_active = 1 WHERE id = :id");
        $stmt->execute(['id' => $id]);

        if ($stmt->rowCount() > 0) {
            $_SESSION['success_msg'] = "Sản phẩm đã được hiển thị lại trên gian hàng.";
        } else {
            $_SESSION['error_msg'] = "Không tìm thấy sản phẩm hoặc sản phẩm đã hiển thị sẵn.";
        }
    } catch (PDOException $e) {
        $_SESSION['error_msg'] = "Lỗi Database: " . $e->getMessage();
    }
} else {
    $_SESSION['error_msg'] = "ID sản phẩm không hợp lệ.";
}

// Giữ nguyên trạng thái bộ lọc khi quay lại (để người dùng đỡ phải chọn lại tab Đã ẩn)
$redirectUrl = route_url('/admin/products.php');
if (isset($_SERVER['HTTP_REFERER']) && strpos($_SERVER['HTTP_REFERER'], 'products.php') !== false) {
    $redirectUrl = $_SERVER['HTTP_REFERER'];
}

header("Location: " . $redirectUrl);
exit;