<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can access messages', 403);
}

$userId = (int)$user['id'];

$stmt = $pdo->prepare('
    SELECT
        m.id,
        m.sender_user_id,
        m.receiver_user_id,
        m.subject,
        m.message,
        m.is_read,
        m.created_at,
        u.full_name AS sender_name,
        u.email AS sender_email
    FROM messages m
    INNER JOIN users u ON u.id = m.sender_user_id
    WHERE m.receiver_user_id = ?
    ORDER BY m.created_at DESC
');

$stmt->execute([$userId]);

$messages = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $messages[] = [
        'id' => (int)$row['id'],
        'sender_user_id' => (int)$row['sender_user_id'],
        'receiver_user_id' => (int)$row['receiver_user_id'],
        'sender_name' => $row['sender_name'],
        'sender_email' => $row['sender_email'],
        'subject' => $row['subject'],
        'message' => $row['message'],
        'is_read' => (int)$row['is_read'],
        'created_at' => $row['created_at'],
    ];
}

jsonResponse([
    'success' => true,
    'messages' => $messages,
]);