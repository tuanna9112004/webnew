<?php
require_once __DIR__ . '/includes/functions.php';

header('Content-Type: application/json; charset=utf-8');

$orderCode = trim((string)($_GET['code'] ?? ''));
$guestToken = trim((string)($_GET['token'] ?? ''));
$customer = current_customer();

$order = $orderCode !== ''
    ? get_order_by_code_for_view($orderCode, $customer['id'] ?? null, $guestToken !== '' ? $guestToken : null)
    : null;

if (!$order) {
    http_response_code(404);
    echo json_encode([
        'ok' => false,
        'message' => 'not_found',
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

echo json_encode([
    'ok' => true,
    'order_code' => $order['order_code'],
    'payment_status' => $order['payment_status'],
    'order_status' => $order['order_status'],
    'paid_amount' => (float)$order['paid_amount'],
    'remaining_amount' => (float)$order['remaining_amount'],
], JSON_UNESCAPED_UNICODE);
