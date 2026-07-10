<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$input = json_decode(file_get_contents('php://input'), true);

$currentPassword = trim($input['current_password'] ?? '');
$newPassword = trim($input['new_password'] ?? '');

if ($currentPassword === '' || $newPassword === '') {
    jsonResponse(['success' => false, 'message' => 'Missing password fields'], 400);
}

if (strlen($newPassword) < 6) {
    jsonResponse(['success' => false, 'message' => 'New password must be at least 6 characters'], 400);
}

$stmt = $pdo->prepare('SELECT id, password_hash FROM users WHERE id = ? LIMIT 1');
$stmt->execute([(int)$user['id']]);
$dbUser = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$dbUser || !password_verify($currentPassword, $dbUser['password_hash'])) {
    jsonResponse(['success' => false, 'message' => 'Current password is incorrect'], 401);
}

$newHash = password_hash($newPassword, PASSWORD_DEFAULT);

$stmt = $pdo->prepare('UPDATE users SET password_hash = ? WHERE id = ?');
$stmt->execute([$newHash, (int)$user['id']]);

jsonResponse(['success' => true, 'message' => 'Password changed successfully']);