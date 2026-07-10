<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$userId = (int)($user['id'] ?? 0);

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access this page'
    ], 403);
}

function tableExists(PDO $pdo, string $table): bool
{
    $stmt = $pdo->prepare('
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
    ');
    $stmt->execute([$table]);
    return (int)$stmt->fetchColumn() > 0;
}

function ensureCompletionTable(PDO $pdo): void
{
    $pdo->exec('
        CREATE TABLE IF NOT EXISTS participant_activity_completions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            participant_profile_id INT NOT NULL,
            user_id INT NOT NULL,
            program_id INT NOT NULL,
            program_daily_task_id INT NOT NULL,
            completed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            points_earned INT NOT NULL DEFAULT 0,
            metadata JSON NULL,
            UNIQUE KEY unique_participant_program_task (participant_profile_id, program_daily_task_id),
            INDEX idx_participant_profile_id (participant_profile_id),
            INDEX idx_program_id (program_id),
            INDEX idx_program_daily_task_id (program_daily_task_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ');
}

ensureCompletionTable($pdo);

$stmt = $pdo->prepare('
    SELECT
        pp.id,
        pp.user_id,
        pp.program_id,
        pp.current_week,
        pp.total_weeks,
        pp.progress_percent,
        pp.start_date,
        p.title AS program_title,
        p.duration_weeks
    FROM participant_profiles pp
    INNER JOIN programs p ON p.id = pp.program_id
    WHERE pp.user_id = ?
      AND pp.status = "active"
    ORDER BY pp.id DESC
    LIMIT 1
');

$stmt->execute([$userId]);
$participant = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$participant) {
    jsonResponse([
        'success' => false,
        'message' => 'Participant profile not found'
    ], 404);
}

$participantId = (int)$participant['id'];
$programId = (int)$participant['program_id'];
$totalWeeks = (int)($participant['total_weeks'] ?? $participant['duration_weeks'] ?? 1);
if ($totalWeeks <= 0) {
    $totalWeeks = 1;
}

$requestedDay = (int)($_GET['day'] ?? 0);

if ($requestedDay > 0) {
    $currentDay = $requestedDay;
} else {
    $startDate = $participant['start_date'] ?? null;

    if ($startDate) {
        $stmt = $pdo->prepare('SELECT DATEDIFF(CURDATE(), ?) + 1');
        $stmt->execute([$startDate]);
        $currentDay = (int)$stmt->fetchColumn();
    } else {
        $currentDay = 1;
    }

    if ($currentDay <= 0) {
        $currentDay = 1;
    }
}

$maxDays = max(1, $totalWeeks * 7);
if ($currentDay > $maxDays) {
    $currentDay = $maxDays;
}

$currentWeek = (int)ceil($currentDay / 7);
if ($currentWeek <= 0) {
    $currentWeek = 1;
}

$stmt = $pdo->prepare('
    SELECT
        t.id,
        t.program_id,
        t.day_number,
        t.order_index,
        t.title,
        t.description,
        t.task_type,
        t.library_item_id,
        t.duration_minutes,
        t.points,
        t.instructions,
        t.is_required,
        t.is_active,
        l.title AS library_title,
        l.type AS library_type,
        l.content AS library_content,
        l.external_url AS library_external_url,
        l.file_path AS library_file_path,
        c.id AS completion_id,
        c.completed_at
    FROM program_daily_tasks t
    LEFT JOIN library_items l ON l.id = t.library_item_id
    LEFT JOIN participant_activity_completions c
      ON c.program_daily_task_id = t.id
     AND c.participant_profile_id = ?
    WHERE t.program_id = ?
      AND t.day_number = ?
      AND t.is_active = 1
    ORDER BY t.order_index ASC, t.id ASC
');

$stmt->execute([$participantId, $programId, $currentDay]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$tasks = array_map(function (array $task): array {
    $completed = !empty($task['completion_id']);

    return [
        'id' => (int)$task['id'],
        'program_daily_task_id' => (int)$task['id'],
        'program_id' => (int)$task['program_id'],
        'day_number' => (int)$task['day_number'],
        'order_index' => (int)$task['order_index'],
        'title' => $task['title'] ?? '',
        'description' => $task['description'] ?? '',
        'task_type' => $task['task_type'] ?? 'custom',
        'library_item_id' => $task['library_item_id'] !== null ? (int)$task['library_item_id'] : null,
        'library_title' => $task['library_title'] ?? '',
        'library_type' => $task['library_type'] ?? '',
        'library_content' => $task['library_content'] ?? '',
        'library_external_url' => $task['library_external_url'] ?? '',
        'library_file_path' => $task['library_file_path'] ?? '',
        'duration_minutes' => $task['duration_minutes'] !== null ? (int)$task['duration_minutes'] : null,
        'points' => (int)($task['points'] ?? 0),
        'instructions' => $task['instructions'] ?? '',
        'is_required' => (int)($task['is_required'] ?? 1),
        'status' => $completed ? 'completed' : 'pending',
        'completed_at' => $task['completed_at'],
        'scheduled_time' => null,
        'task_date' => date('Y-m-d'),
    ];
}, $rows);

$totalTasks = count($tasks);
$completedTasks = 0;
foreach ($tasks as $task) {
    if (($task['status'] ?? '') === 'completed') {
        $completedTasks++;
    }
}

$todayProgress = $totalTasks > 0 ? (int)round(($completedTasks / $totalTasks) * 100) : 0;

jsonResponse([
    'success' => true,
    'program' => [
        'id' => $programId,
        'title' => $participant['program_title'] ?? '',
        'current_day' => $currentDay,
        'current_week' => $currentWeek,
        'total_weeks' => $totalWeeks,
        'progress_percent' => (int)($participant['progress_percent'] ?? 0),
    ],
    'summary' => [
        'total_tasks' => $totalTasks,
        'completed_tasks' => $completedTasks,
        'today_progress' => $todayProgress,
    ],
    'tasks' => $tasks,
]);
