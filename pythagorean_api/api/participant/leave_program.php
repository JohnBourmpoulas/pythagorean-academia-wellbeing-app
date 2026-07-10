<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can leave a program', 403);
}

$userId = (int)$user['id'];

try {
    $pdo->beginTransaction();

    $stmt = $pdo->prepare('
        SELECT id
        FROM participant_profiles
        WHERE user_id = ?
          AND status = "active"
        ORDER BY id DESC
        LIMIT 1
    ');
    $stmt->execute([$userId]);
    $participantProfileId = (int)($stmt->fetchColumn() ?: 0);

    if ($participantProfileId <= 0) {
        $pdo->rollBack();
        jsonError('Active participant profile not found', 404);
    }

    $stmt = $pdo->prepare('
        UPDATE participant_profiles
        SET status = "removed",
            end_date = CURDATE()
        WHERE id = ?
          AND user_id = ?
    ');
    $stmt->execute([$participantProfileId, $userId]);

    $stmt = $pdo->prepare('
        UPDATE users
        SET role = "interested"
        WHERE id = ?
    ');
    $stmt->execute([$userId]);

    $pdo->commit();

    jsonResponse([
        'success' => true,
        'message' => 'You left the program successfully. Please login again.',
    ]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    jsonError('Could not leave program: ' . $e->getMessage(), 500);
}