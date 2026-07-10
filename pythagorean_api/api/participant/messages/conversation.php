<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can access messages', 403);
}

$participantId = (int)$user['id'];
$adminId = (int)($_GET['admin_user_id'] ?? 0);

if ($adminId <= 0) {
    jsonError('Invalid admin user id', 400);
}

$stmt = $pdo->prepare('
    UPDATE messages
    SET is_read = 1
    WHERE sender_user_id = ?
      AND receiver_user_id = ?
');
$stmt->execute([$adminId, $participantId]);

$stmt = $pdo->prepare('
    SELECT
        m.id,
        m.sender_user_id,
        m.receiver_user_id,
        m.subject,
        m.message,
        m.is_read,
        m.created_at,
        s.full_name AS sender_name,
        r.full_name AS receiver_name
    FROM messages m
    INNER JOIN users s ON s.id = m.sender_user_id
    INNER JOIN users r ON r.id = m.receiver_user_id
    WHERE 
        (m.sender_user_id = ? AND m.receiver_user_id = ?)
        OR
        (m.sender_user_id = ? AND m.receiver_user_id = ?)
    ORDER BY m.created_at ASC
');

$stmt->execute([
    $participantId,
    $adminId,
    $adminId,
    $participantId,
]);

$messages = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $messages[] = [
        'id' => (int)$row['id'],
        'sender_user_id' => (int)$row['sender_user_id'],
        'receiver_user_id' => (int)$row['receiver_user_id'],
        'subject' => $row['subject'],
        'message' => $row['message'],
        'is_read' => (int)$row['is_read'],
        'created_at' => $row['created_at'],
        'sender_name' => $row['sender_name'],
        'receiver_name' => $row['receiver_name'],
        'is_mine' => (int)$row['sender_user_id'] === $participantId ? 1 : 0,
    ];
}

jsonResponse([
    'success' => true,
    'messages' => $messages,
]);