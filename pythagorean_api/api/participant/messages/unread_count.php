<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can access unread messages', 403);
}

$userId = (int)$user['id'];

$stmt = $pdo->prepare('
    SELECT COUNT(*) AS unread_count
    FROM messages
    WHERE receiver_user_id = ?
      AND is_read = 0
');

$stmt->execute([$userId]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

jsonResponse([
    'success' => true,
    'unread_count' => (int)($row['unread_count'] ?? 0),
]);