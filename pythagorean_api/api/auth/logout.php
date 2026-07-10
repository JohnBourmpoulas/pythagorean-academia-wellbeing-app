<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$token = getBearerToken();
$pdo = getPDO();

$stmt = $pdo->prepare('UPDATE user_tokens SET revoked_at = NOW() WHERE token_hash = ?');
$stmt->execute([hashToken($token)]);

jsonResponse([
    'success' => true,
    'message' => 'Logged out successfully',
]);
