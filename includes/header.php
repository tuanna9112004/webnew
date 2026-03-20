<?php
require_once __DIR__ . '/functions.php';

$currentUri = $_SERVER['REQUEST_URI'] ?? '';
$currentPath = parse_url($currentUri, PHP_URL_PATH) ?: '/';
$currentPath = rtrim($currentPath, '/') ?: '/';
$isHome = in_array($currentPath, ['/', '/trang-chu', '/index', '/index.php', '/shop'], true);
$isAdminPage = strpos($currentPath, '/admin/') !== false || $currentPath === '/admin';
$shopName = function_exists('shop_name') ? shop_name() : 'Duong Mot Mi SHOP';
$shopLogo = function_exists('shop_logo_url') ? shop_logo_url() : resolve_media_url('img/logo.jpg');
$shopZaloLink = function_exists('shop_zalo_link') ? shop_zalo_link() : (defined('ZALO_LINK') ? ZALO_LINK : '#');
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title><?= isset($pageTitle) ? e($pageTitle) : e($shopName); ?></title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/style.css">
    <?php if (!empty($pageStylesheets) && is_array($pageStylesheets)): ?>
        <?php foreach ($pageStylesheets as $stylesheet): ?>
    <link rel="stylesheet" href="<?= e($stylesheet) ?>">
        <?php endforeach; ?>
    <?php endif; ?>
    <?= $pageExtraHead ?? '' ?>

    <style>
        /* ==========================================================================
           LUXURY & MINIMALIST STYLESHEET
           ========================================================================== */
        
        :root {
            --lux-dark: #121212;
            --lux-light: #ffffff;
            --lux-gold: #cda55d;
            --lux-gold-hover: #e3be75;
            --lux-muted: #888888;
            --lux-border: rgba(0, 0, 0, 0.08);
            --transition-smooth: all 0.5s cubic-bezier(0.25, 1, 0.5, 1);
        }

        body {
            font-family: 'Inter', sans-serif;
            color: var(--lux-dark);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            background-color: #fafafa;
        }

        /* PREMIUM GLASSMORPHISM HEADER */
        .site-header {
            background-color: rgba(255, 255, 255, 0.85);
            backdrop-filter: saturate(180%) blur(25px);
            -webkit-backdrop-filter: saturate(180%) blur(25px);
            box-shadow: 0 4px 40px rgba(0, 0, 0, 0.03);
            border-bottom: 1px solid var(--lux-border);
            position: sticky;
            top: 0;
            z-index: 1000;
            padding: 18px 0;
            transition: var(--transition-smooth);
        }

        .header-wrap {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        /* LUXURY LOGO */
        .logo {
            display: flex;
            align-items: center;
            gap: 15px;
            font-family: 'Playfair Display', serif;
            font-weight: 700;
            font-size: 22px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            color: var(--lux-gold);
            text-decoration: none;
            transition: var(--transition-smooth);
        }

        .logo-mark-img {
            border-radius: 50%;
            object-fit: cover;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            transition: var(--transition-smooth);
            border: 1px solid var(--lux-border);
        }

        .logo:hover {
            color: var(--lux-gold-hover);
            text-shadow: 0 4px 15px rgba(205, 165, 93, 0.3);
        }

        .logo:hover .logo-mark-img {
            transform: scale(1.03) translateY(-2px);
            box-shadow: 0 8px 20px rgba(205, 165, 93, 0.2);
            border-color: var(--lux-gold);
        }

        /* ELEGANT MENU */
        .site-header .menu {
            display: flex;
            align-items: center;
            gap: 40px;
        }

        .site-header .menu a {
            font-size: 13px;
            font-weight: 500;
            color: var(--lux-muted);
            text-transform: uppercase;
            letter-spacing: 1.5px;
            position: relative;
            text-decoration: none;
            transition: var(--transition-smooth);
            padding: 5px 0;
            display: inline-flex;
            align-items: center;
        }

        .site-header .menu a::after {
            content: '';
            position: absolute;
            width: 0;
            height: 1px;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            background-color: var(--lux-gold);
            transition: width 0.4s cubic-bezier(0.25, 1, 0.5, 1);
        }

        .site-header .menu a:hover {
            color: var(--lux-dark);
        }

        .site-header .menu a:hover::after {
            width: 100%;
        }

        /* CART ICON & BADGE */
        .cart-link {
            gap: 6px;
        }
        .cart-badge {
            background-color: var(--lux-gold);
            color: #fff;
            border-radius: 12px;
            padding: 2px 6px;
            font-size: 11px;
            font-weight: 700;
            min-width: 20px;
            text-align: center;
            display: inline-block;
            transition: transform 0.2s ease;
        }
        .cart-badge.bump {
            transform: scale(1.3);
        }

        /* Nút menu mobile */
        .mobile-menu-toggle {
            display: none;
            background: transparent;
            border: none;
            color: var(--lux-dark);
            cursor: pointer;
            padding: 10px;
            transition: var(--transition-smooth);
        }
        
        .mobile-menu-toggle:hover {
            color: var(--lux-gold);
        }

        .tab-bar-mobile {
            display: none !important;
        }

        /* MOBILE OPTIMIZATION */
        @media (max-width: 768px) {
            .site-header {
                padding: 12px 20px;
            }

            .header-wrap {
                justify-content: space-between !important;
                position: relative;
            }

            .logo span {
                font-size: 16px;
            }
            
            .logo-mark-img {
                width: 36px;
                height: 36px;
            }

            .mobile-menu-toggle {
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .site-header .menu {
                display: none;
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                background-color: rgba(255,255,255,0.98);
                backdrop-filter: blur(30px);
                -webkit-backdrop-filter: blur(30px);
                flex-direction: column;
                padding: 10px 0 30px 0;
                box-shadow: 0 30px 60px rgba(0, 0, 0, 0.08);
                border-top: 1px solid var(--lux-border);
                gap: 0;
            }

            .site-header .menu a {
                padding: 18px 25px;
                display: block;
                width: 100%;
                text-align: center;
                font-size: 14px;
                letter-spacing: 2px;
            }
            
            .site-header .menu a::after {
                display: none;
            }

            .site-header .menu.is-open {
                display: flex;
                animation: fadeSlideDown 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards;
            }

            body {
                padding-bottom: 0 !important;
            }
        }

        @keyframes fadeSlideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>

<header class="site-header">
    <div class="container header-wrap">
        <a class="logo" href="<?= route_url('/index.php') ?>">
            <img
                class="logo-mark-img"
                src="<?= e($shopLogo) ?>"
                alt="<?= e($shopName) ?>"
                width="46"
                height="46"
                loading="eager"
                decoding="async"
            >
            <span><?= e($shopName) ?></span>
        </a>

        <button class="mobile-menu-toggle" id="mobileMenuToggle" aria-label="Mở menu">
            <svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <line x1="3" y1="12" x2="21" y2="12"></line>
                <line x1="3" y1="6" x2="21" y2="6"></line>
                <line x1="3" y1="18" x2="21" y2="18"></line>
            </svg>
        </button>

        <nav class="menu" id="headerMenu">
            <a href="<?= route_url('/index.php') ?>">Trang chủ</a>
            <a href="<?= route_url('/order_lookup.php') ?>">Tra cứu đơn</a>
            <?php if (is_customer_logged_in()): ?>
                <a href="<?= route_url('/customer/account.php') ?>">Tài khoản</a>
                <a href="<?= route_url('/customer/logout.php') ?>">Đăng xuất</a>
            <?php else: ?>
                <a href="<?= route_url('/customer/login.php') ?>">Đăng nhập</a>
            <?php endif; ?>
            
            <a href="<?= route_url('/cart.php') ?>" id="headerCartLink" class="cart-link">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
                Giỏ hàng <span id="cartItemCount" class="cart-badge"><?= (int)get_cart_item_count() ?></span>
            </a>
        </nav>
    </div>
</header>

<main class="container main-content">

<script>
document.addEventListener('DOMContentLoaded', function () {
    const mobileMenuToggle = document.getElementById('mobileMenuToggle');
    const headerMenu = document.getElementById('headerMenu');

    if (mobileMenuToggle && headerMenu) {
        mobileMenuToggle.addEventListener('click', function () {
            headerMenu.classList.toggle('is-open');
        });

        document.addEventListener('click', function (event) {
            if (!headerMenu.contains(event.target) && !mobileMenuToggle.contains(event.target)) {
                headerMenu.classList.remove('is-open');
            }
        });
    }
});
</script>