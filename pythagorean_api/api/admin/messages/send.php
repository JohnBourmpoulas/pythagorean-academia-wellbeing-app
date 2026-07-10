<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$data = getJsonInput();
$pdo = getPDO();

$adminId = (int)$admin['id'];
$receiverUserId = (int)($data['receiver_user_id'] ?? 0);
$subject = trim((string)($data['subject'] ?? ''));
$message = trim((string)($data['message'] ?? ''));

if ($receiverUserId <= 0) {
    jsonError('Invalid receiver user id', 400);
}

if ($subject === '') {
    $subject = 'Message from program team';
}

if ($message === '') {
    jsonError('Message is required', 400);
}

$stmt = $pdo->prepare('
    SELECT id
    FROM users
    WHERE id = ?
      AND role = "participant"
    LIMIT 1
');
$stmt->execute([$receiverUserId]);

if (!$stmt->fetchColumn()) {
    jsonError('Participant not found', 404);
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
    $adminId,
    $receiverUserId,
    $subject,
    $message,
]);

jsonResponse([
    'success' => true,
    'message' => 'Message sent successfully',
    'id' => (int)$pdo->lastInsertId(),
]);