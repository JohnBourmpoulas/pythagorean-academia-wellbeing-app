<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access calendar'
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

function firstExistingColumn(PDO $pdo, string $table, array $columns): ?string
{
    foreach ($columns as $column) {
        if (columnExists($pdo, $table, $column)) {
            return $column;
        }
    }

    return null;
}

if (!tableExists($pdo, 'program_daily_tasks')) {
    jsonResponse([
        'success' => false,
        'message' => 'Program daily tasks table was not found'
    ], 500);
}

$stmt = $pdo->prepare('
    SELECT
        pp.id,
        pp.user_id,
        pp.program_id,
        pp.current_week,
        pp.total_weeks,
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
$participant = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$participant) {
    jsonResponse([
        'success' => false,
        'message' => 'Participant profile not found'
    ], 404);
}

$participantId = (int)$participant['id'];
$programId = (int)$participant['program_id'];

if ($programId <= 0) {
    jsonResponse([
        'success' => false,
        'message' => 'Active program not found'
    ], 404);
}

$completionTaskColumn = null;
$completionParticipantColumn = null;

if (tableExists($pdo, 'participant_activity_completions')) {
    $completionTaskColumn = firstExistingColumn($pdo, 'participant_activity_completions', [
        'program_daily_task_id',
        'daily_task_id',
        'program_activity_id',
        'task_id'
    ]);

    $completionParticipantColumn = firstExistingColumn($pdo, 'participant_activity_completions', [
        'participant_profile_id',
        'participant_id'
    ]);
}

$joinCompletion = '';
$completedSelect = '0 AS is_completed';
$completedAtSelect = 'NULL AS completed_at';

if ($completionTaskColumn !== null && $completionParticipantColumn !== null) {
    $joinCompletion = "
        LEFT JOIN participant_activity_completions c
          ON c.`$completionTaskColumn` = t.id
         AND c.`$completionParticipantColumn` = :participant_id
    ";
    $completedSelect = 'CASE WHEN c.id IS NULL THEN 0 ELSE 1 END AS is_completed';
    $completedAtSelect = 'c.completed_at AS completed_at';
}

$libraryJoin = '';
$librarySelect = 'NULL AS library_title, NULL AS library_type';

if (tableExists($pdo, 'library_items') && columnExists($pdo, 'program_daily_tasks', 'library_item_id')) {
    $libraryJoin = 'LEFT JOIN library_items li ON li.id = t.library_item_id';
    $librarySelect = 'li.title AS library_title, li.type AS library_type';
}

$isActiveWhere = columnExists($pdo, 'program_daily_tasks', 'is_active')
    ? 'AND t.is_active = 1'
    : '';

$dueDateSelect = columnExists($pdo, 'program_daily_tasks', 'due_date')
    ? 't.due_date'
    : 'NULL';

$orderColumn = columnExists($pdo, 'program_daily_tasks', 'order_index')
    ? 't.order_index'
    : 't.id';

$sql = "
    SELECT
        t.id,
        t.program_id,
        t.day_number,
        t.title,
        t.description,
        t.task_type,
        t.duration_minutes,
        t.points,
        t.is_required,
        t.instructions,
        $dueDateSelect AS due_date,
        $librarySelect,
        $completedSelect,
        $completedAtSelect
    FROM program_daily_tasks t
    $libraryJoin
    $joinCompletion
    WHERE t.program_id = :program_id
      $isActiveWhere
    ORDER BY t.day_number ASC, $orderColumn ASC, t.id ASC
";

$stmt = $pdo->prepare($sql);
$stmt->bindValue(':program_id', $programId, PDO::PARAM_INT);
if ($completionTaskColumn !== null && $completionParticipantColumn !== null) {
    $stmt->bindValue(':participant_id', $participantId, PDO::PARAM_INT);
}
$stmt->execute();

$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$startDateRaw = $participant['start_date'] ?? null;
if (!$startDateRaw) {
    $startDateRaw = $participant['joined_at'] ?? null;
}
if (!$startDateRaw) {
    $startDateRaw = date('Y-m-d');
}

try {
    $programStart = new DateTime(substr((string)$startDateRaw, 0, 10));
} catch (Throwable $e) {
    $programStart = new DateTime(date('Y-m-d'));
}

$events = [];
$completedCount = 0;

foreach ($rows as $row) {
    $dayNumber = max(1, (int)($row['day_number'] ?? 1));
    $weekNumber = (int)ceil($dayNumber / 7);

    $taskDate = $row['due_date'] ?? null;
    if (!$taskDate) {
        $date = clone $programStart;
        $date->modify('+' . ($dayNumber - 1) . ' days');
        $taskDate = $date->format('Y-m-d');
    }

    $isCompleted = (int)($row['is_completed'] ?? 0) === 1;
    if ($isCompleted) {
        $completedCount++;
    }

    $events[] = [
        'id' => (int)$row['id'],
        'program_id' => (int)$row['program_id'],
        'title' => $row['title'] ?? '',
        'description' => $row['description'] ?? '',
        'task_type' => $row['task_type'] ?? 'custom',
        'duration_minutes' => isset($row['duration_minutes']) ? (int)$row['duration_minutes'] : 0,
        'points' => isset($row['points']) ? (int)$row['points'] : 0,
        'is_required' => (int)($row['is_required'] ?? 1),
        'instructions' => $row['instructions'] ?? '',
        'library_title' => $row['library_title'] ?? '',
        'library_type' => $row['library_type'] ?? '',
        'day_number' => $dayNumber,
        'week_number' => $weekNumber,
        'task_date' => $taskDate,
        'scheduled_time' => null,
        'status' => $isCompleted ? 'completed' : 'pending',
        'completed_at' => $row['completed_at'] ?? null,
    ];
}

$totalCount = count($events);
$completionPercent = $totalCount > 0 ? (int)round(($completedCount / $totalCount) * 100) : 0;

$days = [];
foreach ($events as $event) {
    $dateKey = (string)$event['task_date'];

    if (!isset($days[$dateKey])) {
        $days[$dateKey] = [
            'date' => $dateKey,
            'day_number' => (int)$event['day_number'],
            'week_number' => (int)$event['week_number'],
            'total' => 0,
            'completed' => 0,
            'percent' => 0,
        ];
    }

    $days[$dateKey]['total']++;
    if ($event['status'] === 'completed') {
        $days[$dateKey]['completed']++;
    }
}

foreach ($days as $dateKey => $day) {
    $days[$dateKey]['percent'] = $day['total'] > 0
        ? (int)round(($day['completed'] / $day['total']) * 100)
        : 0;
}

jsonResponse([
    'success' => true,
    'program' => [
        'id' => $programId,
        'title' => $participant['program_title'] ?? 'Current Program',
        'current_week' => (int)($participant['current_week'] ?? 1),
        'total_weeks' => (int)($participant['total_weeks'] ?? $participant['duration_weeks'] ?? 0),
        'start_date' => $programStart->format('Y-m-d'),
        'end_date' => $participant['end_date'] ?? null,
        'progress_percent' => $completionPercent,
    ],
    'summary' => [
        'total' => $totalCount,
        'completed' => $completedCount,
        'pending' => max(0, $totalCount - $completedCount),
        'percent' => $completionPercent,
    ],
    'days' => array_values($days),
    'events' => $events,
]);
