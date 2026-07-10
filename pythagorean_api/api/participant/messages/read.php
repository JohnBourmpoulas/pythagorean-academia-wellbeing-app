<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can read messages', 403);
}

$data = getJsonInput();

$userId = (int)$user['id'];
$messageId = (int)($data['id'] ?? 0);

if ($messageId <= 0) {
    jsonError('Invalid message id', 400);
}

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
    WHERE m.id = ?
      AND m.receiver_user_id = ?
    LIMIT 1
');
$stmt->execute([$messageId, $userId]);
$message = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$message) {
    jsonError('Message not found', 404);
}

$stmt = $pdo->prepare('
    UPDATE messages
    SET is_read = 1
    WHERE id = ?
      AND receiver_user_id = ?
');
$stmt->execute([$messageId, $userId]);

jsonResponse([
    'success' => true,
    'message_data' => [
        'id' => (int)$message['id'],
        'sender_user_id' => (int)$message['sender_user_id'],
        'receiver_user_id' => (int)$message['receiver_user_id'],
        'sender_name' => $message['sender_name'],
        'sender_email' => $message['sender_email'],
        'subject' => $message['subject'],
        'message' => $message['message'],
        'is_read' => 1,
        'created_at' => $message['created_at'],
    ],
]);