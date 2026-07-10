<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$stmt = $pdo->prepare('
    SELECT
        pp.id AS participant_profile_id,
        u.id AS user_id,
        u.full_name,
        u.email,
        pp.status,
        p.title AS program_title,
        (
            SELECT m.message
            FROM messages m
            WHERE 
                (m.sender_user_id = u.id AND m.receiver_user_id = ?)
                OR
                (m.sender_user_id = ? AND m.receiver_user_id = u.id)
            ORDER BY m.created_at DESC
            LIMIT 1
        ) AS last_message,
        (
            SELECT m.created_at
            FROM messages m
            WHERE 
                (m.sender_user_id = u.id AND m.receiver_user_id = ?)
                OR
                (m.sender_user_id = ? AND m.receiver_user_id = u.id)
            ORDER BY m.created_at DESC
            LIMIT 1
        ) AS last_message_at,
        (
            SELECT COUNT(*)
            FROM messages m
            WHERE m.sender_user_id = u.id
              AND m.receiver_user_id = ?
              AND m.is_read = 0
        ) AS unread_count
    FROM participant_profiles pp
    INNER JOIN users u ON u.id = pp.user_id
    INNER JOIN programs p ON p.id = pp.program_id
    WHERE pp.status = "active"
    ORDER BY last_message_at DESC, u.full_name ASC
');

$adminId = (int)$admin['id'];
$stmt->execute([$adminId, $adminId, $adminId, $adminId, $adminId]);

$participants = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $participants[] = [
        'participant_profile_id' => (int)$row['participant_profile_id'],
        'user_id' => (int)$row['user_id'],
        'full_name' => $row['full_name'],
        'email' => $row['email'],
        'status' => $row['status'],
        'program_title' => $row['program_title'],
        'last_message' => $row['last_message'],
        'last_message_at' => $row['last_message_at'],
        'unread_count' => (int)$row['unread_count'],
    ];
}

jsonResponse([
    'success' => true,
    'participants' => $participants,
]);