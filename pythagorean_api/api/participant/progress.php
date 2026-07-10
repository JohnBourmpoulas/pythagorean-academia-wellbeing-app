<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$userId = (int)($user['id'] ?? 0);

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access progress'
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

function columnExists(PDO $pdo, string $table, string $column): bool
{
    $stmt = $pdo->prepare('
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND COLUMN_NAME = ?
    ');
    $stmt->execute([$table, $column]);
    return (int)$stmt->fetchColumn() > 0;
}

if (!tableExists($pdo, 'program_daily_tasks')) {
    jsonResponse([
        'success' => false,
        'message' => 'program_daily_tasks table not found'
    ], 500);
}

if (!tableExists($pdo, 'participant_activity_completions')) {
    $pdo->exec('
        CREATE TABLE IF NOT EXISTS participant_activity_completions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            participant_id INT NULL,
            program_activity_id INT NULL,
            completed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            notes TEXT NULL,
            program_daily_task_id INT NULL,
            participant_profile_id INT NULL,
            user_id INT NULL,
            points_earned INT NOT NULL DEFAULT 0,
            metadata JSON NULL,
            INDEX idx_participant_profile_id (participant_profile_id),
            INDEX idx_program_daily_task_id (program_daily_task_id),
            INDEX idx_user_id (user_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ');
}

$stmt = $pdo->prepare('
    SELECT
        pp.id,
        pp.user_id,
        pp.program_id,
        pp.application_id,
        pp.current_week,
        pp.total_weeks,
        pp.wellness_score,
        pp.progress_percent,
        pp.start_date,
        pp.joined_at,
        pp.status,
        p.title AS program_title,
        p.duration_weeks AS program_duration_weeks
    FROM participant_profiles pp
    INNER JOIN programs p ON p.id = pp.program_id
    WHERE pp.user_id = ?
      AND pp.status = "active"
    ORDER BY pp.id DESC
    LIMIT 1
');
$stmt->execute([$userId]);
$profile = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$profile) {
    jsonResponse([
        'success' => false,
        'message' => 'Participant profile not found'
    ], 404);
}

$participantId = (int)$profile['id'];
$programId = (int)$profile['program_id'];

$totalWeeks = (int)($profile['total_weeks'] ?? 0);
if ($totalWeeks <= 0) {
    $totalWeeks = (int)($profile['program_duration_weeks'] ?? 0);
}
if ($totalWeeks <= 0) {
    $totalWeeks = 1;
}

$startDateText = $profile['start_date'] ?: null;
if (!$startDateText && !empty($profile['joined_at'])) {
    $startDateText = substr((string)$profile['joined_at'], 0, 10);
}
if (!$startDateText) {
    $startDateText = date('Y-m-d');
}

try {
    $startDate = new DateTimeImmutable($startDateText);
} catch (Throwable $e) {
    $startDate = new DateTimeImmutable('today');
}

$today = new DateTimeImmutable('today');
$daysFromStart = (int)$startDate->diff($today)->format('%r%a');
$currentDay = max(1, $daysFromStart + 1);
$currentWeek = max(1, (int)ceil($currentDay / 7));
$currentWeek = min($currentWeek, $totalWeeks);

$stmt = $pdo->prepare('
    SELECT COUNT(*)
    FROM program_daily_tasks
    WHERE program_id = ?
      AND is_active = 1
');
$stmt->execute([$programId]);
$totalTasks = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare('
    SELECT COUNT(DISTINCT c.program_daily_task_id)
    FROM participant_activity_completions c
    INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
    WHERE c.participant_profile_id = ?
      AND t.program_id = ?
      AND t.is_active = 1
');
$stmt->execute([$participantId, $programId]);
$completedTasks = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare('
    SELECT COALESCE(SUM(c.points_earned), 0)
    FROM participant_activity_completions c
    INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
    WHERE c.participant_profile_id = ?
      AND t.program_id = ?
      AND t.is_active = 1
');
$stmt->execute([$participantId, $programId]);
$totalPoints = (int)$stmt->fetchColumn();

$completionPercent = 0;
if ($totalTasks > 0) {
    $completionPercent = (int)round(($completedTasks / $totalTasks) * 100);
}

$weekStart = $today->modify('monday this week');
$weeklyProgress = [];
$dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

for ($i = 0; $i < 7; $i++) {
    $date = $weekStart->modify('+' . $i . ' days');
    $dateText = $date->format('Y-m-d');

    $dayFromProgramStart = (int)$startDate->diff($date)->format('%r%a') + 1;

    $dayTotal = 0;
    $dayCompleted = 0;
    $percent = 0;

    if ($dayFromProgramStart >= 1) {
        $stmt = $pdo->prepare('
            SELECT COUNT(*)
            FROM program_daily_tasks
            WHERE program_id = ?
              AND day_number = ?
              AND is_active = 1
        ');
        $stmt->execute([$programId, $dayFromProgramStart]);
        $dayTotal = (int)$stmt->fetchColumn();

        $stmt = $pdo->prepare('
            SELECT COUNT(DISTINCT c.program_daily_task_id)
            FROM participant_activity_completions c
            INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
            WHERE c.participant_profile_id = ?
              AND t.program_id = ?
              AND t.day_number = ?
              AND t.is_active = 1
              AND DATE(c.completed_at) = ?
        ');
        $stmt->execute([$participantId, $programId, $dayFromProgramStart, $dateText]);
        $dayCompleted = (int)$stmt->fetchColumn();

        if ($dayTotal > 0) {
            $percent = (int)round(($dayCompleted / $dayTotal) * 100);
        }
    }

    $weeklyProgress[] = [
        'date' => $dateText,
        'label' => $dayLabels[$i],
        'day' => $dayLabels[$i],
        'program_day' => max(0, $dayFromProgramStart),
        'total_tasks' => $dayTotal,
        'completed_tasks' => $dayCompleted,
        'percent' => $percent,
    ];
}

$completedDatesStmt = $pdo->prepare('
    SELECT DATE(c.completed_at) AS completed_date
    FROM participant_activity_completions c
    INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
    WHERE c.participant_profile_id = ?
      AND t.program_id = ?
      AND t.is_active = 1
    GROUP BY DATE(c.completed_at)
    ORDER BY completed_date DESC
');
$completedDatesStmt->execute([$participantId, $programId]);
$completedDates = $completedDatesStmt->fetchAll(PDO::FETCH_COLUMN);

$completedDateSet = array_flip($completedDates);
$streak = 0;
$cursor = new DateTimeImmutable('today');

while (isset($completedDateSet[$cursor->format('Y-m-d')])) {
    $streak++;
    $cursor = $cursor->modify('-1 day');
}

$achievements = [];

if ($completedTasks >= 1) {
    $achievements[] = [
        'title' => 'First Activity',
        'description' => 'Completed your first program activity',
        'icon' => 'check_circle'
    ];
}

if ($streak >= 3) {
    $achievements[] = [
        'title' => '3 Day Streak',
        'description' => 'Completed activities for 3 days in a row',
        'icon' => 'local_fire_department'
    ];
}

if ($totalPoints >= 50) {
    $achievements[] = [
        'title' => '50 Points',
        'description' => 'Collected 50 program points',
        'icon' => 'star'
    ];
}

if ($completionPercent >= 50) {
    $achievements[] = [
        'title' => 'Halfway There',
        'description' => 'Reached 50% program completion',
        'icon' => 'flag'
    ];
}

if ($completionPercent >= 100 && $totalTasks > 0) {
    $achievements[] = [
        'title' => 'Program Completed',
        'description' => 'Completed all program activities',
        'icon' => 'emoji_events'
    ];
}

$history = [];

if (tableExists($pdo, 'participant_history')) {
    $stmt = $pdo->prepare('
        SELECT
            id,
            event_type,
            title,
            description,
            created_at
        FROM participant_history
        WHERE participant_profile_id = ?
        ORDER BY created_at DESC
        LIMIT 10
    ');
    $stmt->execute([$participantId]);
    $history = $stmt->fetchAll(PDO::FETCH_ASSOC);
}

if (empty($history)) {
    $stmt = $pdo->prepare('
        SELECT
            c.id,
            "activity_completed" AS event_type,
            CONCAT("Completed: ", t.title) AS title,
            COALESCE(t.description, "") AS description,
            c.completed_at AS created_at
        FROM participant_activity_completions c
        INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
        WHERE c.participant_profile_id = ?
          AND t.program_id = ?
        ORDER BY c.completed_at DESC
        LIMIT 10
    ');
    $stmt->execute([$participantId, $programId]);
    $history = $stmt->fetchAll(PDO::FETCH_ASSOC);
}

if (columnExists($pdo, 'participant_profiles', 'progress_percent')) {
    $stmt = $pdo->prepare('
        UPDATE participant_profiles
        SET progress_percent = ?, current_week = ?, total_weeks = ?
        WHERE id = ?
    ');
    $stmt->execute([$completionPercent, $currentWeek, $totalWeeks, $participantId]);
}

jsonResponse([
    'success' => true,
    'progress' => [
        'participant_profile_id' => $participantId,
        'program_id' => $programId,
        'program_title' => $profile['program_title'] ?: 'Current Program',
        'current_day' => $currentDay,
        'current_week' => $currentWeek,
        'total_weeks' => $totalWeeks,
        'wellness_score' => (int)($profile['wellness_score'] ?? 0),
        'progress_percent' => $completionPercent,
        'total_tasks' => $totalTasks,
        'completed_tasks' => $completedTasks,
        'remaining_tasks' => max(0, $totalTasks - $completedTasks),
        'total_points' => $totalPoints,
        'streak' => $streak,
        'weekly_progress' => $weeklyProgress,
        'achievements' => $achievements,
        'history' => array_map(function ($item) {
            return [
                'id' => (int)($item['id'] ?? 0),
                'event_type' => $item['event_type'] ?? '',
                'title' => $item['title'] ?? '',
                'description' => $item['description'] ?? '',
                'created_at' => $item['created_at'] ?? '',
            ];
        }, $history),
    ],
]);
