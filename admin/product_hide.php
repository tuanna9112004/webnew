<?php
require_once __DIR__ . '/../includes/functions.php';
admin_require_login();

// Lấy ID sản phẩm cần ẩn từ URL
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

if ($id > 0) {
    try {
        // SỬ DỤNG HÀM db() CỦA HỆ THỐNG THAY VÌ BIẾN TOÀN CỤC
        $stmt = db()->prepare("UPDATE products SET is_active = 0 WHERE id = :id");
        $stmt->execute(['id' => $id]);

        if ($stmt->rowCount() > 0) {
            $_SESSION['success_msg'] = "Đã ẩn sản phẩm thành công. Sản phẩm sẽ nằm trong danh sách 'Đã ẩn'.";
        } else {
            $_SESSION['error_msg'] = "Không tìm thấy sản phẩm hoặc sản phẩm đã được ẩn từ trước.";
        }
    } catch (PDOException $e) {
        $_SESSION['error_msg'] = "Lỗi Database: " . $e->getMessage();
    }
} else {
    $_SESSION['error_msg'] = "ID sản phẩm không hợp lệ.";
}

header('Location: ' . route_url('/admin/products.php'));
exit;