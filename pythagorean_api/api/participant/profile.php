<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse(['success' => false, 'message' => 'Only participants can access profile'], 403);
}

$userId = (int)$user['id'];

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

$interestedJoin = tableExists($pdo, 'interested_profiles')
    ? 'LEFT JOIN interested_profiles ip ON ip.user_id = u.id'
    : '';

$select = [
    'u.id AS user_id',
    'u.full_name',
    'u.email',
    columnExists($pdo, 'users', 'phone') ? 'u.phone' : 'NULL AS phone',
    columnExists($pdo, 'users', 'profile_photo') ? 'u.profile_photo' : 'NULL AS profile_photo',

    'pp.id AS participant_profile_id',
    'pp.program_id',
    columnExists($pdo, 'participant_profiles', 'current_week') ? 'pp.current_week' : '1 AS current_week',
    columnExists($pdo, 'participant_profiles', 'total_weeks') ? 'pp.total_weeks' : 'p.duration_weeks AS total_weeks',
    columnExists($pdo, 'participant_profiles', 'progress_percent') ? 'pp.progress_percent' : '0 AS progress_percent',
    columnExists($pdo, 'participant_profiles', 'wellness_score') ? 'pp.wellness_score' : '0 AS wellness_score',
    columnExists($pdo, 'participant_profiles', 'status') ? 'pp.status' : '"active" AS status',
    columnExists($pdo, 'participant_profiles', 'storage_folder') ? 'pp.storage_folder' : 'NULL AS storage_folder',
    columnExists($pdo, 'participant_profiles', 'start_date') ? 'pp.start_date' : 'NULL AS start_date',
    columnExists($pdo, 'participant_profiles', 'joined_at') ? 'pp.joined_at' : 'NULL AS joined_at',

    'p.title AS program_title',
    'p.description AS program_description',
];

if (tableExists($pdo, 'interested_profiles')) {
    $interestedColumns = [
        'age',
        'profession',
        'height_cm',
        'weight_kg',
        'neck_cm',
        'waist_cm',
        'bmi',
        'nutrition_habits',
        'smoking_habits',
        'physical_activity',
        'sleep_quality',
        'goals',
        'onboarding_completed',
    ];

    foreach ($interestedColumns as $column) {
        $select[] = columnExists($pdo, 'interested_profiles', $column)
            ? "ip.$column"
            : "NULL AS $column";
    }
}

$where = 'pp.user_id = ?';

if (columnExists($pdo, 'participant_profiles', 'status')) {
    $where .= ' AND pp.status = "active"';
}

$stmt = $pdo->prepare('
    SELECT ' . implode(', ', $select) . '
    FROM participant_profiles pp
    INNER JOIN users u ON u.id = pp.user_id
    INNER JOIN programs p ON p.id = pp.program_id
    ' . $interestedJoin . '
    WHERE ' . $where . '
    ORDER BY pp.id DESC
    LIMIT 1
');

$stmt->execute([$userId]);
$profile = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$profile) {
    jsonResponse(['success' => false, 'message' => 'Participant profile not found'], 404);
}

jsonResponse([
    'success' => true,
    'profile' => [
        'user_id' => (int)$profile['user_id'],
        'participant_profile_id' => (int)$profile['participant_profile_id'],

        'full_name' => $profile['full_name'] ?? '',
        'email' => $profile['email'] ?? '',
        'phone' => $profile['phone'] ?? null,
        'profile_photo' => $profile['profile_photo'] ?? null,

        'program_id' => (int)$profile['program_id'],
        'program_title' => $profile['program_title'] ?? '',
        'program_description' => $profile['program_description'] ?? '',

        'current_week' => (int)($profile['current_week'] ?? 1),
        'total_weeks' => (int)($profile['total_weeks'] ?? 1),
        'progress_percent' => (int)($profile['progress_percent'] ?? 0),
        'wellness_score' => (int)($profile['wellness_score'] ?? 0),
        'status' => $profile['status'] ?? 'active',
        'storage_folder' => $profile['storage_folder'] ?? null,
        'start_date' => $profile['start_date'] ?? null,
        'joined_at' => $profile['joined_at'] ?? null,

        'age' => $profile['age'] ?? null,
        'profession' => $profile['profession'] ?? null,
        'height_cm' => $profile['height_cm'] ?? null,
        'weight_kg' => $profile['weight_kg'] ?? null,
        'neck_cm' => $profile['neck_cm'] ?? null,
        'waist_cm' => $profile['waist_cm'] ?? null,
        'bmi' => $profile['bmi'] ?? null,
        'nutrition_habits' => $profile['nutrition_habits'] ?? null,
        'smoking_habits' => $profile['smoking_habits'] ?? null,
        'physical_activity' => $profile['physical_activity'] ?? null,
        'sleep_quality' => $profile['sleep_quality'] ?? null,
        'goals' => $profile['goals'] ?? null,
        'onboarding_completed' => (int)($profile['onboarding_completed'] ?? 0),
    ],
]);