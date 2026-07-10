<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$data = getJsonInput();

$adminId = (int)$admin['id'];
$participantUserId = (int)($data['participant_user_id'] ?? 0);

if ($participantUserId <= 0) {
    jsonError('Invalid participant user id', 400);
}

$stmt = $pdo->prepare('
    DELETE FROM messages
    WHERE
        (sender_user_id = ? AND receiver_user_id = ?)
        OR
        (sender_user_id = ? AND receiver_user_id = ?)
');

$stmt->execute([
    $adminId,
    $participantUserId,
    $participantUserId,
    $adminId,
]);

jsonResponse([
    'success' => true,
    'message' => 'Conversation deleted successfully',
]);