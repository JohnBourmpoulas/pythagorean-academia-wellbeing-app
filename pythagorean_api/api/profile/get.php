<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$stmt = $pdo->prepare(
    'SELECT 
        ip.*,
        u.profile_photo
     FROM interested_profiles ip
     INNER JOIN users u ON u.id = ip.user_id
     WHERE ip.user_id = ?
     LIMIT 1'
);

$stmt->execute([(int)$user['id']]);
$profile = $stmt->fetch(PDO::FETCH_ASSOC);

jsonResponse([
    'success' => true,
    'user' => [
        'id' => (int)$user['id'],
        'full_name' => $user['full_name'],
        'email' => $user['email'],
        'phone' => $user['phone'],
        'role' => $user['role'],
        'profile_photo' => $user['profile_photo'] ?? null,
    ],
    'profile' => $profile ?: null,
]);