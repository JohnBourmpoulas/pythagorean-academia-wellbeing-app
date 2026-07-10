<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$userId = (int)($user['id'] ?? 0);

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse(['success' => false, 'message' => 'Only participants can complete tasks'], 403);
}

$data = getJsonInput();
$taskId = (int)($data['task_id'] ?? $data['program_daily_task_id'] ?? 0);

if ($taskId <= 0) {
    jsonResponse(['success' => false, 'message' => 'Invalid task id'], 400);
}

try {
    $stmt = $pdo->prepare('
        SELECT id, user_id, program_id, status
        FROM participant_profiles
        WHERE user_id = ?
          AND status = "active"
        ORDER BY id DESC
        LIMIT 1
    ');
    $stmt->execute([$userId]);
    $participant = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$participant) {
        jsonResponse(['success' => false, 'message' => 'Participant profile not found'], 404);
    }

    $participantProfileId = (int)$participant['id'];
    $programId = (int)$participant['program_id'];

    $stmt = $pdo->prepare('
        SELECT id, program_id, day_number, title, task_type, points, is_active
        FROM program_daily_tasks
        WHERE id = ?
          AND program_id = ?
        LIMIT 1
    ');
    $stmt->execute([$taskId, $programId]);
    $task = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$task) {
        jsonResponse(['success' => false, 'message' => 'Task not found for your active program'], 404);
    }

    $points = (int)($task['points'] ?? 0);

    $pdo->beginTransaction();

    $stmt = $pdo->prepare('
        INSERT IGNORE INTO participant_activity_completions
            (
                participant_profile_id,
                user_id,
                program_daily_task_id,
                completed_at,
                points_earned,
                metadata
            )
        VALUES
            (?, ?, ?, NOW(), ?, ?)
    ');

    $stmt->execute([
        $participantProfileId,
        $userId,
        $taskId,
        $points,
        json_encode([
            'program_id' => $programId,
            'task_title' => $task['title'] ?? '',
            'task_type' => $task['task_type'] ?? 'custom',
            'day_number' => (int)($task['day_number'] ?? 1),
        ], JSON_UNESCAPED_UNICODE),
    ]);

    $stmt = $pdo->prepare('
        SELECT COUNT(*)
        FROM program_daily_tasks
        WHERE program_id = ?
          AND is_active = 1
    ');
    $stmt->execute([$programId]);
    $totalTasks = (int)$stmt->fetchColumn();

    $stmt = $pdo->prepare('
        SELECT COUNT(*)
        FROM participant_activity_completions c
        INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
        WHERE c.participant_profile_id = ?
          AND t.program_id = ?
          AND t.is_active = 1
    ');
    $stmt->execute([$participantProfileId, $programId]);
    $completedTasks = (int)$stmt->fetchColumn();

    $progressPercent = $totalTasks > 0
        ? (int)round(($completedTasks / $totalTasks) * 100)
        : 0;

    $stmt = $pdo->prepare('
        UPDATE participant_profiles
        SET progress_percent = ?
        WHERE id = ?
    ');
    $stmt->execute([$progressPercent, $participantProfileId]);

    $pdo->commit();

    jsonResponse([
        'success' => true,
        'message' => 'Task completed successfully',
        'points_earned' => $points,
        'progress_percent' => $progressPercent,
    ]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    jsonResponse([
        'success' => false,
        'message' => 'Could not complete task: ' . $e->getMessage(),
    ], 500);
}