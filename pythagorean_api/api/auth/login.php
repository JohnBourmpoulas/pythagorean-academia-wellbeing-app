<?php
declare(strict_types=1);

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/security.php';
require_once __DIR__ . '/../../helpers/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method not allowed', 405);
}

$data = getJsonInput();

$email = strtolower(trim($data['email'] ?? ''));
$password = (string)($data['password'] ?? '');

if ($email === '' || $password === '') {
    jsonError('Email and password are required');
}

$pdo = getPDO();

$stmt = $pdo->prepare('SELECT * FROM users WHERE email = ? AND status = "active" LIMIT 1');
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !verifyPassword($password, $user['password_hash'], $user['password_salt'])) {
    jsonError('Invalid email or password', 401);
}

$token = createUserToken((int)$user['id']);

jsonResponse([
    'success' => true,
    'token' => $token,
    'user' => [
        'id' => (int)$user['id'],
        'full_name' => $user['full_name'],
        'email' => $user['email'],
        'phone' => $user['phone'],
        'role' => $user['role'],
    ],
]);
