<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access statistics'
    ], 403);
}

$userId = (int)($user['id'] ?? 0);

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

function intValue($value): int
{
    if ($value === null || $value === '') {
        return 0;
    }
    return (int)$value;
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
        pp.joined_at,
        pp.start_date,
        pp.end_date,
        pp.status,
        p.title AS program_title,
        p.duration_weeks
    FROM participant_profiles pp
    LEFT JOIN programs p ON p.id = pp.program_id
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

$participantProfileId = (int)$profile['id'];
$programId = (int)$profile['program_id'];
$programTitle = (string)($profile['program_title'] ?? 'Current Program');
$totalWeeks = intValue($profile['total_weeks']);
if ($totalWeeks <= 0) {
    $totalWeeks = intValue($profile['duration_weeks']);
}
if ($totalWeeks <= 0) {
    $totalWeeks = 1;
}

$startDate = $profile['start_date'] ?: null;
if (!$startDate && !empty($profile['joined_at'])) {
    $startDate = substr((string)$profile['joined_at'], 0, 10);
}

$currentDay = 1;
if ($startDate) {
    try {
        $start = new DateTime($startDate);
        $today = new DateTime('today');
        $diff = (int)$start->diff($today)->format('%r%a');
        $currentDay = max(1, $diff + 1);
    } catch (Throwable $e) {
        $currentDay = 1;
    }
}

$currentWeek = (int)ceil($currentDay / 7);
$currentWeek = max(1, min($currentWeek, $totalWeeks));

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
$stmt->execute([$participantProfileId, $programId]);
$completedTasks = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare('
    SELECT COALESCE(SUM(c.points_earned), 0)
    FROM participant_activity_completions c
    INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
    WHERE c.participant_profile_id = ?
      AND t.program_id = ?
      AND t.is_active = 1
');
$stmt->execute([$participantProfileId, $programId]);
$totalPoints = (int)$stmt->fetchColumn();

$completionRate = 0;
if ($totalTasks > 0) {
    $completionRate = (int)round(($completedTasks / $totalTasks) * 100);
}

$stmt = $pdo->prepare('
    SELECT
        t.day_number,
        COUNT(*) AS total_tasks,
        COUNT(DISTINCT c.program_daily_task_id) AS completed_tasks,
        COALESCE(SUM(c.points_earned), 0) AS points
    FROM program_daily_tasks t
    LEFT JOIN participant_activity_completions c
      ON c.program_daily_task_id = t.id
     AND c.participant_profile_id = ?
    WHERE t.program_id = ?
      AND t.is_active = 1
    GROUP BY t.day_number
    ORDER BY t.day_number ASC
');
$stmt->execute([$participantProfileId, $programId]);
$dayRows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$weekly = [];
for ($i = 1; $i <= $totalWeeks; $i++) {
    $weekly[$i] = [
        'week' => $i,
        'total_tasks' => 0,
        'completed_tasks' => 0,
        'points' => 0,
        'percent' => 0,
    ];
}

$daily = [];
foreach ($dayRows as $row) {
    $day = max(1, (int)$row['day_number']);
    $week = (int)ceil($day / 7);
    if (!isset($weekly[$week])) {
        $weekly[$week] = [
            'week' => $week,
            'total_tasks' => 0,
            'completed_tasks' => 0,
            'points' => 0,
            'percent' => 0,
        ];
    }

    $dayTotal = (int)$row['total_tasks'];
    $dayCompleted = (int)$row['completed_tasks'];
    $dayPoints = (int)$row['points'];
    $dayPercent = $dayTotal > 0 ? (int)round(($dayCompleted / $dayTotal) * 100) : 0;

    $weekly[$week]['total_tasks'] += $dayTotal;
    $weekly[$week]['completed_tasks'] += $dayCompleted;
    $weekly[$week]['points'] += $dayPoints;

    $daily[] = [
        'day_number' => $day,
        'week' => $week,
        'total_tasks' => $dayTotal,
        'completed_tasks' => $dayCompleted,
        'points' => $dayPoints,
        'percent' => $dayPercent,
    ];
}

foreach ($weekly as $key => $row) {
    $weekly[$key]['percent'] = $row['total_tasks'] > 0
        ? (int)round(($row['completed_tasks'] / $row['total_tasks']) * 100)
        : 0;
}

$weekly = array_values($weekly);

$bestWeek = 0;
$bestWeekPercent = 0;
foreach ($weekly as $row) {
    if ((int)$row['percent'] > $bestWeekPercent) {
        $bestWeekPercent = (int)$row['percent'];
        $bestWeek = (int)$row['week'];
    }
}

$currentWeekStats = [
    'week' => $currentWeek,
    'total_tasks' => 0,
    'completed_tasks' => 0,
    'points' => 0,
    'percent' => 0,
];
foreach ($weekly as $row) {
    if ((int)$row['week'] === $currentWeek) {
        $currentWeekStats = $row;
        break;
    }
}

$reflectionStats = [
    'mood' => 0.0,
    'stress' => 0.0,
    'energy' => 0.0,
    'sleep' => 0.0,
    'count' => 0,
];

$reflectionTable = null;
if (tableExists($pdo, 'participant_reflections')) {
    $reflectionTable = 'participant_reflections';
} elseif (tableExists($pdo, 'reflections')) {
    $reflectionTable = 'reflections';
}

if ($reflectionTable) {
    $profileColumn = columnExists($pdo, $reflectionTable, 'participant_profile_id')
        ? 'participant_profile_id'
        : (columnExists($pdo, $reflectionTable, 'participant_id') ? 'participant_id' : null);

    if ($profileColumn) {
        $moodColumn = columnExists($pdo, $reflectionTable, 'mood_level') ? 'mood_level' : 'mood';
        $stressColumn = columnExists($pdo, $reflectionTable, 'stress_level') ? 'stress_level' : 'stress';
        $energyColumn = columnExists($pdo, $reflectionTable, 'energy_level') ? 'energy_level' : 'energy';
        $sleepColumn = columnExists($pdo, $reflectionTable, 'sleep_quality') ? 'sleep_quality' : 'sleep';

        $sql = "
            SELECT
                ROUND(AVG($moodColumn), 1) AS mood,
                ROUND(AVG($stressColumn), 1) AS stress,
                ROUND(AVG($energyColumn), 1) AS energy,
                ROUND(AVG($sleepColumn), 1) AS sleep,
                COUNT(*) AS total_count
            FROM $reflectionTable
            WHERE $profileColumn = ?
        ";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$participantProfileId]);
        $reflectionRow = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];

        $reflectionStats = [
            'mood' => round((float)($reflectionRow['mood'] ?? 0), 1),
            'stress' => round((float)($reflectionRow['stress'] ?? 0), 1),
            'energy' => round((float)($reflectionRow['energy'] ?? 0), 1),
            'sleep' => round((float)($reflectionRow['sleep'] ?? 0), 1),
            'count' => (int)($reflectionRow['total_count'] ?? 0),
        ];
    }
}

$metrics = [];
if (tableExists($pdo, 'participant_metrics')) {
    $stmt = $pdo->prepare('
        SELECT
            metric_type,
            ROUND(AVG(metric_value), 2) AS average_value,
            ROUND(MAX(metric_value), 2) AS max_value,
            ROUND(MIN(metric_value), 2) AS min_value,
            COUNT(*) AS total_records
        FROM participant_metrics
        WHERE participant_profile_id = ?
        GROUP BY metric_type
        ORDER BY metric_type ASC
    ');
    $stmt->execute([$participantProfileId]);
    $metricRows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($metricRows as $metric) {
        $metrics[] = [
            'metric_type' => (string)$metric['metric_type'],
            'average_value' => (float)$metric['average_value'],
            'max_value' => (float)$metric['max_value'],
            'min_value' => (float)$metric['min_value'],
            'total_records' => (int)$metric['total_records'],
        ];
    }
}

$recentActivity = [];
if (tableExists($pdo, 'participant_history')) {
    $stmt = $pdo->prepare('
        SELECT title, description, event_type, created_at
        FROM participant_history
        WHERE participant_profile_id = ?
        ORDER BY created_at DESC
        LIMIT 6
    ');
    $stmt->execute([$participantProfileId]);
    $recentActivity = $stmt->fetchAll(PDO::FETCH_ASSOC);
} else {
    $stmt = $pdo->prepare('
        SELECT
            "Activity completed" AS title,
            t.title AS description,
            "activity_completed" AS event_type,
            c.completed_at AS created_at
        FROM participant_activity_completions c
        INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
        WHERE c.participant_profile_id = ?
          AND t.program_id = ?
        ORDER BY c.completed_at DESC
        LIMIT 6
    ');
    $stmt->execute([$participantProfileId, $programId]);
    $recentActivity = $stmt->fetchAll(PDO::FETCH_ASSOC);
}

jsonResponse([
    'success' => true,
    'statistics' => [
        'participant_profile_id' => $participantProfileId,
        'program_id' => $programId,
        'program_title' => $programTitle,
        'current_day' => $currentDay,
        'current_week' => $currentWeek,
        'total_weeks' => $totalWeeks,
        'progress_percent' => $completionRate,
        'completion_percent' => $completionRate,
        'wellness_score' => intValue($profile['wellness_score']),
        'total_tasks' => $totalTasks,
        'completed_tasks' => $completedTasks,
        'pending_tasks' => max(0, $totalTasks - $completedTasks),
        'total_points' => $totalPoints,
        'average_points_per_completed_task' => $completedTasks > 0 ? round($totalPoints / $completedTasks, 1) : 0,
        'current_week_stats' => $currentWeekStats,
        'best_week' => $bestWeek,
        'best_week_percent' => $bestWeekPercent,
        'weekly_progress' => $weekly,
        'daily_progress' => $daily,
        'reflections' => $reflectionStats,
        'metrics' => $metrics,
        'recent_activity' => array_map(function ($item) {
            return [
                'title' => (string)($item['title'] ?? ''),
                'description' => (string)($item['description'] ?? ''),
                'event_type' => (string)($item['event_type'] ?? ''),
                'created_at' => (string)($item['created_at'] ?? ''),
            ];
        }, $recentActivity),
    ],
]);
