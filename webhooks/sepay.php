<?php
require_once __DIR__ . '/../includes/functions.php';

$headers = function_exists('getallheaders') ? (getallheaders() ?: []) : [];
$rawBody = file_get_contents('php://input') ?: '';
$result = handle_sepay_webhook($headers, $rawBody);
http_response_code($result['status'] ?? 200);
header('Content-Type: application/json; charset=utf-8');
echo json_encode([
    'success' => (bool)($result['ok'] ?? false),
    'message' => (string)($result['message'] ?? 'ok'),
], JSON_UNESCAPED_UNICODE);
