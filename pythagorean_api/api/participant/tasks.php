<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = requireRole(['participant']);
$pdo = getPDO();

$stmt = $pdo->prepare('
    SELECT pp.id
    FROM participant_profiles pp
    WHERE pp.user_id = ?
    ORDER BY pp.joined_at DESC
    LIMIT 1
');
$stmt->execute([(int)$user['id']]);
$participant = $stmt->fetch();

if (!$participant) {
    jsonError('Participant profile not found', 404);
}

$stmt = $pdo->prepare('
    SELECT *
    FROM daily_tasks
    WHERE participant_id = ?
    ORDER BY task_date DESC, scheduled_time ASC
');
$stmt->execute([(int)$participant['id']]);

jsonResponse([
    'success' => true,
    'tasks' => $stmt->fetchAll(),
]);
