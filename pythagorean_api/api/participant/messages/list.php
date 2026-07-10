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
        u.id AS admin_user_id,
        u.full_name AS sender_name,
        u.email AS sender_email,

        (
            SELECT m.subject
            FROM messages m
            WHERE
                (m.sender_user_id = u.id AND m.receiver_user_id = ?)
                OR
                (m.sender_user_id = ? AND m.receiver_user_id = u.id)
            ORDER BY m.created_at DESC
            LIMIT 1
        ) AS subject,

        (
            SELECT m.message
            FROM messages m
            WHERE
                (m.sender_user_id = u.id AND m.receiver_user_id = ?)
                OR
                (m.sender_user_id = ? AND m.receiver_user_id = u.id)
            ORDER BY m.created_at DESC
            LIMIT 1
        ) AS message,

        (
            SELECT m.created_at
            FROM messages m
            WHERE
                (m.sender_user_id = u.id AND m.receiver_user_id = ?)
                OR
                (m.sender_user_id = ? AND m.receiver_user_id = u.id)
            ORDER BY m.created_at DESC
            LIMIT 1
        ) AS created_at,

        (
            SELECT m.id
            FROM messages m
            WHERE
                (m.sender_user_id = u.id AND m.receiver_user_id = ?)
                OR
                (m.sender_user_id = ? AND m.receiver_user_id = u.id)
            ORDER BY m.created_at DESC
            LIMIT 1
        ) AS latest_message_id,

        (
            SELECT COUNT(*)
            FROM messages m
            WHERE m.sender_user_id = u.id
              AND m.receiver_user_id = ?
              AND m.is_read = 0
        ) AS unread_count

    FROM users u
    WHERE u.role = "admin"
      AND EXISTS (
          SELECT 1
          FROM messages m
          WHERE
              (m.sender_user_id = u.id AND m.receiver_user_id = ?)
              OR
              (m.sender_user_id = ? AND m.receiver_user_id = u.id)
      )
    ORDER BY created_at DESC
');

$stmt->execute([
    $userId, $userId,
    $userId, $userId,
    $userId, $userId,
    $userId, $userId,
    $userId,
    $userId, $userId,
]);

$conversations = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $unread = (int)($row['unread_count'] ?? 0);

    $conversations[] = [
        'id' => (int)$row['latest_message_id'],
        'sender_user_id' => (int)$row['admin_user_id'],
        'admin_user_id' => (int)$row['admin_user_id'],
        'sender_name' => $row['sender_name'],
        'sender_email' => $row['sender_email'],
        'subject' => $row['subject'] ?? 'Message from program team',
        'message' => $row['message'] ?? '',
        'created_at' => $row['created_at'],
        'is_read' => $unread > 0 ? 0 : 1,
        'unread_count' => $unread,
    ];
}

jsonResponse([
    'success' => true,
    'messages' => $conversations,
]);