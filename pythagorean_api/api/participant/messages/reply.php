<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can reply to messages', 403);
}

$data = getJsonInput();

$participantId = (int)$user['id'];
$adminUserId = (int)($data['admin_user_id'] ?? 0);
$replyText = trim((string)($data['message'] ?? ''));

if ($adminUserId <= 0) {
    jsonError('Invalid admin user id', 400);
}

if ($replyText === '') {
    jsonError('Message is required', 400);
}

$stmt = $pdo->prepare('
    SELECT id
    FROM users
    WHERE id = ?
      AND role = "admin"
    LIMIT 1
');
$stmt->execute([$adminUserId]);

if (!$stmt->fetchColumn()) {
    jsonError('Admin not found', 404);
}

$stmt = $pdo->prepare('
    SELECT subject
    FROM messages
    WHERE
        (sender_user_id = ? AND receiver_user_id = ?)
        OR
        (sender_user_id = ? AND receiver_user_id = ?)
    ORDER BY created_at DESC
    LIMIT 1
');

$stmt->execute([
    $adminUserId,
    $participantId,
    $participantId,
    $adminUserId,
]);

$last = $stmt->fetch(PDO::FETCH_ASSOC);
$subject = $last['subject'] ?? 'Message from program team';

if (!str_starts_with(strtolower($subject), 're:')) {
    $subject = 'Re: ' . $subject;
}

$stmt = $pdo->prepare('
    INSERT INTO messages
        (
            sender_user_id,
            receiver_user_id,
            subject,
            message,
            is_read
        )
    VALUES
        (?, ?, ?, ?, 0)
');

$stmt->execute([
    $participantId,
    $adminUserId,
    $subject,
    $replyText,
]);

jsonResponse([
    'success' => true,
    'message' => 'Reply sent successfully',
    'reply_id' => (int)$pdo->lastInsertId(),
]);