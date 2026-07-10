<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$userId = (int)($user['id'] ?? 0);

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access this dashboard'
    ], 403);
}

function tableExists(PDO $pdo, string $table): bool {
    $stmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
    ");
    $stmt->execute([$table]);
    return (int)$stmt->fetchColumn() > 0;
}

function columnExists(PDO $pdo, string $table, string $column): bool {
    $stmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND COLUMN_NAME = ?
    ");
    $stmt->execute([$table, $column]);
    return (int)$stmt->fetchColumn() > 0;
}

function safeDate(?string $date): ?DateTimeImmutable {
    if ($date === null || trim($date) === '' || $date === '0000-00-00' || $date === '0000-00-00 00:00:00') {
        return null;
    }

    try {
        return new DateTimeImmutable($date);
    } catch (Throwable $e) {
        return null;
    }
}

try {
    $ppSelect = [
        'pp.id AS participant_profile_id',
        'pp.user_id',
        'pp.program_id',
        columnExists($pdo, 'participant_profiles', 'current_week') ? 'pp.current_week' : '1 AS current_week',
        columnExists($pdo, 'participant_profiles', 'total_weeks') ? 'pp.total_weeks' : 'p.duration_weeks AS total_weeks',
        columnExists($pdo, 'participant_profiles', 'wellness_score') ? 'pp.wellness_score' : '0 AS wellness_score',
        columnExists($pdo, 'participant_profiles', 'progress_percent') ? 'pp.progress_percent' : '0 AS progress_percent',
        columnExists($pdo, 'participant_profiles', 'storage_folder') ? 'pp.storage_folder' : 'NULL AS storage_folder',
        columnExists($pdo, 'participant_profiles', 'joined_at') ? 'pp.joined_at' : 'NULL AS joined_at',
        columnExists($pdo, 'participant_profiles', 'start_date') ? 'pp.start_date' : 'NULL AS start_date',
        columnExists($pdo, 'participant_profiles', 'created_at') ? 'pp.created_at' : 'NULL AS participant_created_at',
        'u.full_name',
        'u.email',
        columnExists($pdo, 'users', 'phone') ? 'u.phone' : 'NULL AS phone',
        columnExists($pdo, 'users', 'profile_photo') ? 'u.profile_photo' : 'NULL AS profile_photo',
        'p.title AS program_title',
        'p.description AS program_description',
        'p.duration_weeks'
    ];

    $where = 'pp.user_id = ?';

    if (columnExists($pdo, 'participant_profiles', 'status')) {
        $where .= ' AND pp.status = "active"';
    }

    $stmt = $pdo->prepare("
        SELECT " . implode(', ', $ppSelect) . "
        FROM participant_profiles pp
        INNER JOIN users u ON u.id = pp.user_id
        INNER JOIN programs p ON p.id = pp.program_id
        WHERE $where
        ORDER BY pp.id DESC
        LIMIT 1
    ");

    $stmt->execute([$userId]);
    $profile = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$profile) {
        jsonResponse([
            'success' => false,
            'message' => 'Participant profile not found'
        ], 404);
    }

    $participantProfileId = (int)$profile['participant_profile_id'];
    $programId = (int)$profile['program_id'];
    $durationWeeks = max(1, (int)($profile['duration_weeks'] ?? $profile['total_weeks'] ?? 1));
    $totalDays = max(1, $durationWeeks * 7);

    $startDate = safeDate($profile['start_date'] ?? null)
        ?? safeDate($profile['joined_at'] ?? null)
        ?? safeDate($profile['participant_created_at'] ?? null)
        ?? new DateTimeImmutable('today');

    $today = new DateTimeImmutable('today');
    $daysSinceStart = (int)$startDate->setTime(0, 0)->diff($today)->format('%r%a');
    $currentDay = min($totalDays, max(1, $daysSinceStart + 1));
    $currentWeek = (int)ceil($currentDay / 7);

    $todayTasksCount = 0;
    $completedTasksCount = 0;
    $totalProgramTasks = 0;
    $completedProgramTasks = 0;
    $totalPoints = 0;
    $todayPoints = 0;
    $weeklyProgress = [];

    if (tableExists($pdo, 'program_daily_tasks')) {
        $stmt = $pdo->prepare("
            SELECT COUNT(*)
            FROM program_daily_tasks
            WHERE program_id = ?
              AND is_active = 1
        ");
        $stmt->execute([$programId]);
        $totalProgramTasks = (int)$stmt->fetchColumn();

        $stmt = $pdo->prepare("
            SELECT COUNT(*)
            FROM program_daily_tasks
            WHERE program_id = ?
              AND day_number = ?
              AND is_active = 1
        ");
        $stmt->execute([$programId, $currentDay]);
        $todayTasksCount = (int)$stmt->fetchColumn();

        if (tableExists($pdo, 'participant_activity_completions')) {
            $stmt = $pdo->prepare("
                SELECT COUNT(*)
                FROM participant_activity_completions c
                INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
                WHERE c.participant_profile_id = ?
                  AND t.program_id = ?
                  AND t.day_number = ?
                  AND t.is_active = 1
            ");
            $stmt->execute([$participantProfileId, $programId, $currentDay]);
            $completedTasksCount = (int)$stmt->fetchColumn();

            $stmt = $pdo->prepare("
                SELECT COUNT(*)
                FROM participant_activity_completions c
                INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
                WHERE c.participant_profile_id = ?
                  AND t.program_id = ?
                  AND t.is_active = 1
            ");
            $stmt->execute([$participantProfileId, $programId]);
            $completedProgramTasks = (int)$stmt->fetchColumn();

            if (columnExists($pdo, 'participant_activity_completions', 'points_earned')) {
                $stmt = $pdo->prepare("
                    SELECT COALESCE(SUM(points_earned), 0)
                    FROM participant_activity_completions c
                    INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
                    WHERE c.participant_profile_id = ?
                      AND t.program_id = ?
                      AND t.is_active = 1
                ");
                $stmt->execute([$participantProfileId, $programId]);
                $totalPoints = (int)$stmt->fetchColumn();

                $stmt = $pdo->prepare("
                    SELECT COALESCE(SUM(points_earned), 0)
                    FROM participant_activity_completions c
                    INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
                    WHERE c.participant_profile_id = ?
                      AND t.program_id = ?
                      AND t.day_number = ?
                      AND t.is_active = 1
                ");
                $stmt->execute([$participantProfileId, $programId, $currentDay]);
                $todayPoints = (int)$stmt->fetchColumn();
            }
        }

        $startDay = max(1, $currentDay - 6);

        for ($day = $startDay; $day <= $currentDay; $day++) {
            $stmt = $pdo->prepare("
                SELECT COUNT(*)
                FROM program_daily_tasks
                WHERE program_id = ?
                  AND day_number = ?
                  AND is_active = 1
            ");
            $stmt->execute([$programId, $day]);
            $dayTotal = (int)$stmt->fetchColumn();

            $dayCompleted = 0;

            if ($dayTotal > 0 && tableExists($pdo, 'participant_activity_completions')) {
                $stmt = $pdo->prepare("
                    SELECT COUNT(*)
                    FROM participant_activity_completions c
                    INNER JOIN program_daily_tasks t ON t.id = c.program_daily_task_id
                    WHERE c.participant_profile_id = ?
                      AND t.program_id = ?
                      AND t.day_number = ?
                      AND t.is_active = 1
                ");
                $stmt->execute([$participantProfileId, $programId, $day]);
                $dayCompleted = (int)$stmt->fetchColumn();
            }

            $weeklyProgress[] = $dayTotal > 0
                ? (int)round(($dayCompleted / $dayTotal) * 100)
                : 0;
        }
    }

    while (count($weeklyProgress) < 7) {
        array_unshift($weeklyProgress, 0);
    }

    if (count($weeklyProgress) > 7) {
        $weeklyProgress = array_slice($weeklyProgress, -7);
    }

    $dailyGoalPercent = $todayTasksCount > 0
        ? (int)round(($completedTasksCount / $todayTasksCount) * 100)
        : 0;

    $completionPercent = $totalProgramTasks > 0
        ? (int)round(($completedProgramTasks / $totalProgramTasks) * 100)
        : 0;

    if (columnExists($pdo, 'participant_profiles', 'progress_percent')) {
        $stmt = $pdo->prepare('
            UPDATE participant_profiles
            SET progress_percent = ?
            WHERE id = ?
        ');
        $stmt->execute([$completionPercent, $participantProfileId]);
    }

    if (columnExists($pdo, 'participant_profiles', 'wellness_score')) {
        $stmt = $pdo->prepare('
            UPDATE participant_profiles
            SET wellness_score = ?
            WHERE id = ?
        ');
        $stmt->execute([$totalPoints, $participantProfileId]);
    }

    $steps = 0;
    $sleepHours = 0.0;
    $heartRate = 0;

    if (tableExists($pdo, 'participant_metrics')) {
        $participantColumn = columnExists($pdo, 'participant_metrics', 'participant_profile_id')
            ? 'participant_profile_id'
            : (columnExists($pdo, 'participant_metrics', 'participant_id') ? 'participant_id' : null);

        if ($participantColumn !== null) {
            $dateFilter = '';

            if (columnExists($pdo, 'participant_metrics', 'metric_date')) {
                $dateFilter = ' AND metric_date = CURDATE()';
            } elseif (columnExists($pdo, 'participant_metrics', 'created_at')) {
                $dateFilter = ' AND DATE(created_at) = CURDATE()';
            }

            $stmt = $pdo->prepare("
                SELECT metric_type, metric_value
                FROM participant_metrics
                WHERE $participantColumn = ?
                $dateFilter
            ");
            $stmt->execute([$participantProfileId]);

            foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $metric) {
                if ($metric['metric_type'] === 'steps') {
                    $steps = (int)$metric['metric_value'];
                } elseif ($metric['metric_type'] === 'sleep_hours') {
                    $sleepHours = (float)$metric['metric_value'];
                } elseif ($metric['metric_type'] === 'heart_rate') {
                    $heartRate = (int)$metric['metric_value'];
                }
            }
        }
    }

    jsonResponse([
        'success' => true,
        'dashboard' => [
            'participant_profile_id' => $participantProfileId,
            'user_id' => (int)$profile['user_id'],
            'program_id' => $programId,

            'full_name' => $profile['full_name'] ?? '',
            'email' => $profile['email'] ?? '',
            'phone' => $profile['phone'] ?? '',
            'profile_photo' => $profile['profile_photo'] ?? null,

            'program_name' => $profile['program_title'] ?? '',
            'program_description' => $profile['program_description'] ?? '',

            'current_week' => $currentWeek,
            'total_weeks' => $durationWeeks,
            'current_day' => $currentDay,
            'total_days' => $totalDays,

            'completion_percent' => $completionPercent,
            'wellness_score' => $totalPoints,
            'total_points' => $totalPoints,
            'today_points' => $todayPoints,
            'daily_goal_percent' => $dailyGoalPercent,

            // For the current UI, today_steps is used as the visible points metric.
            // Wearable steps will be connected later in the Wearables phase.
            'today_steps' => $totalPoints,
            'sleep_hours' => $sleepHours,
            'heart_rate' => $heartRate,

            'today_tasks_count' => $todayTasksCount,
            'completed_tasks_count' => $completedTasksCount,

            'weekly_progress' => $weeklyProgress,
            'storage_folder' => $profile['storage_folder'] ?? null,
            'joined_at' => $profile['joined_at'] ?? null,
            'start_date' => $profile['start_date'] ?? null,
        ],
    ]);
} catch (Throwable $e) {
    jsonResponse([
        'success' => false,
        'message' => $e->getMessage(),
        'file' => basename($e->getFile()),
        'line' => $e->getLine(),
    ], 500);
}
