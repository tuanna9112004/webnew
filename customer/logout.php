<?php
require_once __DIR__ . '/../includes/functions.php';
customer_logout();
flash_set('customer_auth', 'Bạn đã đăng xuất.', 'info');
redirect('/customer/login.php');
