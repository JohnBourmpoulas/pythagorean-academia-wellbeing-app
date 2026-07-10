<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$userId = (int)($user['id'] ?? 0);
$frequencyDays = 7;

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access assessments',
        'assessments' => [],
        'questions' => [],
        'summary' => [
            'completed' => 0,
            'total' => 0,
            'pending' => 0,
            'progress_percent' => 0,
            'next_available_at' => null,
            'days_until_next' => 0,
        ],
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

function normalizeAssessmentType(string $type): string
{
    $type = strtolower(trim($type));
    $type = str_replace(['_', '-'], ' ', $type);

    if (str_contains($type, 'sleep')) return 'sleep';
    if (str_contains($type, 'stress')) return 'stress';
    if (str_contains($type, 'wellness')) return 'wellness';

    return trim(str_replace(' ', '_', $type));
}

function assessmentTitle(string $type): string
{
    if ($type === 'sleep') return 'Sleep';
    if ($type === 'stress') return 'Stress';
    if ($type === 'wellness') return 'Wellness Assessment';

    return ucwords(str_replace(['_', '-'], ' ', $type));
}

function mysqlDate(?DateTime $date): ?string
{
    return $date ? $date->format('Y-m-d H:i:s') : null;
}

function daysRemaining(DateTime $now, DateTime $target): int
{
    if ($target <= $now) return 0;

    $seconds = $target->getTimestamp() - $now->getTimestamp();
    return (int)ceil($seconds / 86400);
}

if (!tableExists($pdo, 'assessment_questions')) {
    $pdo->exec('
        CREATE TABLE IF NOT EXISTS assessment_questions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            assessment_type VARCHAR(80) NOT NULL,
            question_text TEXT NOT NULL,
            sort_order INT NOT NULL DEFAULT 0,
            INDEX idx_assessment_type (assessment_type)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ');
}

if (!tableExists($pdo, 'assessment_results')) {
    $pdo->exec('
        CREATE TABLE IF NOT EXISTS assessment_results (
            id INT AUTO_INCREMENT PRIMARY KEY,
            participant_id INT NOT NULL,
            assessment_type VARCHAR(80) NOT NULL,
            score INT NOT NULL DEFAULT 0,
            result_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_participant_id (participant_id),
            INDEX idx_assessment_type (assessment_type)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ');
}

$stmt = $pdo->prepare('
    SELECT
        id,
        user_id,
        program_id,
        wellness_score,
        progress_percent,
        status
    FROM participant_profiles
    WHERE user_id = ?
      AND status = "active"
    ORDER BY id DESC
    LIMIT 1
');
$stmt->execute([$userId]);
$participant = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$participant) {
    jsonResponse([
        'success' => false,
        'message' => 'Participant profile not found',
        'assessments' => [],
        'questions' => [],
        'summary' => [
            'completed' => 0,
            'total' => 0,
            'pending' => 0,
            'progress_percent' => 0,
            'next_available_at' => null,
            'days_until_next' => 0,
        ],
    ], 404);
}

$participantId = (int)$participant['id'];
$now = new DateTime('now');

$stmt = $pdo->prepare('
    SELECT
        id,
        participant_id,
        assessment_type,
        score,
        result_date
    FROM assessment_results
    WHERE participant_id = ?
    ORDER BY result_date DESC, id DESC
');
$stmt->execute([$participantId]);
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);

$latestByType = [];
foreach ($results as &$result) {
    $normalizedType = normalizeAssessmentType((string)($result['assessment_type'] ?? ''));

    $result['id'] = (int)$result['id'];
    $result['participant_id'] = (int)$result['participant_id'];
    $result['assessment_type'] = $normalizedType;
    $result['type'] = $normalizedType;
    $result['score'] = (int)$result['score'];

    if ($normalizedType !== '' && !isset($latestByType[$normalizedType])) {
        $latestByType[$normalizedType] = $result;
    }
}
unset($result);

$stmt = $pdo->prepare('
    SELECT
        assessment_type,
        COUNT(*) AS total_questions,
        MIN(sort_order) AS first_sort_order
    FROM assessment_questions
    GROUP BY assessment_type
');
$stmt->execute();
$questionTypes = $stmt->fetchAll(PDO::FETCH_ASSOC);

$typeMap = [];

foreach ($questionTypes as $row) {
    $type = normalizeAssessmentType((string)($row['assessment_type'] ?? ''));
    if ($type === '') continue;

    if (!isset($typeMap[$type])) {
        $typeMap[$type] = [
            'assessment_type' => $type,
            'total_questions' => 0,
            'first_sort_order' => (int)($row['first_sort_order'] ?? 999),
        ];
    }

    $typeMap[$type]['total_questions'] += (int)($row['total_questions'] ?? 0);
    $typeMap[$type]['first_sort_order'] = min(
        (int)$typeMap[$type]['first_sort_order'],
        (int)($row['first_sort_order'] ?? 999)
    );
}

foreach (['sleep', 'stress', 'wellness'] as $defaultType) {
    if (!isset($typeMap[$defaultType])) {
        $typeMap[$defaultType] = [
            'assessment_type' => $defaultType,
            'total_questions' => 0,
            'first_sort_order' => $defaultType === 'sleep' ? 1 : ($defaultType === 'stress' ? 2 : 3),
        ];
    }
}

uasort($typeMap, static function (array $a, array $b): int {
    $order = ['sleep' => 1, 'stress' => 2, 'wellness' => 3];
    $aType = (string)$a['assessment_type'];
    $bType = (string)$b['assessment_type'];
    $aOrder = $order[$aType] ?? (int)$a['first_sort_order'];
    $bOrder = $order[$bType] ?? (int)$b['first_sort_order'];

    if ($aOrder === $bOrder) return strcmp($aType, $bType);
    return $aOrder <=> $bOrder;
});

$assessments = [];
$nextDates = [];

foreach ($typeMap as $row) {
    $type = (string)$row['assessment_type'];
    $latest = $latestByType[$type] ?? null;

    $hasResult = $latest !== null;
    $resultDate = null;
    $nextAvailable = null;
    $daysLeft = 0;
    $locked = false;

    if ($hasResult) {
        $resultDate = new DateTime((string)$latest['result_date']);
        $nextAvailable = clone $resultDate;
        $nextAvailable->modify('+' . $frequencyDays . ' days');

        $locked = $nextAvailable > $now;
        $daysLeft = daysRemaining($now, $nextAvailable);

        if ($locked) {
            $nextDates[] = $nextAvailable;
        }
    }

    $status = $locked ? 'completed' : 'pending';

    $assessments[] = [
        'id' => $type,
        'assessment_type' => $type,
        'type' => $type,
        'title' => assessmentTitle($type),
        'description' => 'Complete this questionnaire to update your wellness score.',
        'status' => $status,
        'completed' => $locked,
        'is_completed' => $locked,
        'is_available' => !$locked,
        'frequency_days' => $frequencyDays,
        'days_remaining' => $daysLeft,
        'days_until_next' => $daysLeft,
        'total_questions' => (int)($row['total_questions'] ?? 0),
        'score' => $hasResult ? (int)$latest['score'] : 0,
        'result_id' => $hasResult ? (int)$latest['id'] : null,
        'result_date' => $hasResult ? (string)$latest['result_date'] : null,
        'completed_at' => $hasResult ? (string)$latest['result_date'] : null,
        'last_completed_at' => $hasResult ? (string)$latest['result_date'] : null,
        'next_available_at' => mysqlDate($nextAvailable),
    ];
}

$total = count($assessments);
$completedCount = 0;

foreach ($assessments as $assessment) {
    if (($assessment['status'] ?? '') === 'completed') {
        $completedCount++;
    }
}

$pendingCount = max(0, $total - $completedCount);
$progressPercent = $total > 0 ? (int)round(($completedCount / $total) * 100) : 0;

usort($nextDates, static function (DateTime $a, DateTime $b): int {
    return $a->getTimestamp() <=> $b->getTimestamp();
});

$nearestNext = $nextDates[0] ?? null;
$daysUntilNext = $nearestNext ? daysRemaining($now, $nearestNext) : 0;

$selectedType = normalizeAssessmentType((string)($_GET['type'] ?? $_GET['assessment_type'] ?? ''));
if ($selectedType === '' && count($assessments) > 0) {
    $selectedType = (string)$assessments[0]['assessment_type'];
}

$questions = [];
if ($selectedType !== '') {
    $stmt = $pdo->prepare('
        SELECT
            id,
            assessment_type,
            question_text,
            sort_order
        FROM assessment_questions
        WHERE LOWER(REPLACE(REPLACE(assessment_type, "_", " "), "-", " ")) LIKE ?
        ORDER BY sort_order ASC, id ASC
    ');
    $stmt->execute(['%' . str_replace('_', ' ', $selectedType) . '%']);
    $questions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($questions as &$question) {
        $question['id'] = (int)$question['id'];
        $question['assessment_type'] = normalizeAssessmentType((string)$question['assessment_type']);
        $question['type'] = $question['assessment_type'];
        $question['question_text'] = (string)$question['question_text'];
        $question['text'] = $question['question_text'];
        $question['sort_order'] = (int)$question['sort_order'];
    }
    unset($question);
}

jsonResponse([
    'success' => true,
    'participant' => [
        'id' => $participantId,
        'program_id' => (int)$participant['program_id'],
        'wellness_score' => (int)$participant['wellness_score'],
        'progress_percent' => (int)$participant['progress_percent'],
    ],
    'summary' => [
        'completed' => $completedCount,
        'total' => $total,
        'pending' => $pendingCount,
        'progress_percent' => $progressPercent,
        'frequency_days' => $frequencyDays,
        'next_available_at' => mysqlDate($nearestNext),
        'days_until_next' => $daysUntilNext,
    ],
    'completed_count' => $completedCount,
    'total_count' => $total,
    'pending_count' => $pendingCount,
    'progress_percent' => $progressPercent,
    'assessments' => $assessments,
    'questions' => $questions,
    'results' => $results,
]);
