<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can delete conversations', 403);
}

$data = getJsonInput();

$participantId = (int)$user['id'];
$adminUserId = (int)($data['admin_user_id'] ?? 0);

if ($adminUserId <= 0) {
    jsonError('Invalid admin user id', 400);
}

$stmt = $pdo->prepare('
    DELETE FROM messages
    WHERE
        (sender_user_id = ? AND receiver_user_id = ?)
        OR
        (sender_user_id = ? AND receiver_user_id = ?)
');

$stmt->execute([
    $participantId,
    $adminUserId,
    $adminUserId,
    $participantId,
]);

jsonResponse([
    'success' => true,
    'message' => 'Conversation deleted successfully',
]);