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
        'message' => 'Only participants can submit assessments'
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

    return $type === '' ? 'wellness' : trim(str_replace(' ', '_', $type));
}

function mysqlDate(DateTime $date): string
{
    return $date->format('Y-m-d H:i:s');
}

function daysRemaining(DateTime $now, DateTime $target): int
{
    if ($target <= $now) return 0;

    $seconds = $target->getTimestamp() - $now->getTimestamp();
    return (int)ceil($seconds / 86400);
}

$data = getJsonInput();

$assessmentType = normalizeAssessmentType(
    (string)($data['assessment_type'] ?? $data['type'] ?? 'wellness')
);

$answersInput = $data['answers'] ?? [];

if (!is_array($answersInput) || count($answersInput) === 0) {
    jsonResponse([
        'success' => false,
        'message' => 'No answers submitted'
    ], 400);
}

$stmt = $pdo->prepare('
    SELECT id, program_id
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
        'message' => 'Participant profile not found'
    ], 404);
}

$participantId = (int)$participant['id'];
$programId = (int)$participant['program_id'];

$stmt = $pdo->prepare('
    SELECT id, result_date
    FROM assessment_results
    WHERE participant_id = ?
      AND LOWER(REPLACE(REPLACE(assessment_type, "_", " "), "-", " ")) LIKE ?
    ORDER BY result_date DESC, id DESC
    LIMIT 1
');
$stmt->execute([$participantId, '%' . str_replace('_', ' ', $assessmentType) . '%']);
$latestResult = $stmt->fetch(PDO::FETCH_ASSOC);

if ($latestResult) {
    $now = new DateTime('now');
    $lastCompletedAt = new DateTime((string)$latestResult['result_date']);
    $nextAvailableAt = clone $lastCompletedAt;
    $nextAvailableAt->modify('+' . $frequencyDays . ' days');

    if ($nextAvailableAt > $now) {
        jsonResponse([
            'success' => false,
            'message' => 'This assessment is already completed. It will open again in ' . daysRemaining($now, $nextAvailableAt) . ' day(s).',
            'status' => 'completed',
            'frequency_days' => $frequencyDays,
            'completed_at' => mysqlDate($lastCompletedAt),
            'next_available_at' => mysqlDate($nextAvailableAt),
            'days_remaining' => daysRemaining($now, $nextAvailableAt),
        ], 409);
    }
}

$answers = [];

foreach ($answersInput as $index => $item) {
    if (!is_array($item)) {
        continue;
    }

    $questionId = (int)($item['question_id'] ?? 0);
    $questionText = trim((string)($item['question_text'] ?? ''));
    $answerValue = trim((string)($item['answer_value'] ?? $item['value'] ?? $item['answer'] ?? ''));

    if ($answerValue === '') {
        continue;
    }

    if ($questionId <= 0 && $questionText !== '') {
        $stmt = $pdo->prepare('
            SELECT id
            FROM assessment_questions
            WHERE assessment_type = ?
              AND question_text = ?
            LIMIT 1
        ');
        $stmt->execute([$assessmentType, $questionText]);
        $questionId = (int)$stmt->fetchColumn();

        if ($questionId <= 0) {
            $stmt = $pdo->prepare('
                INSERT INTO assessment_questions
                    (assessment_type, question_text, sort_order)
                VALUES
                    (?, ?, ?)
            ');
            $stmt->execute([$assessmentType, $questionText, $index + 1]);
            $questionId = (int)$pdo->lastInsertId();
        }
    }

    if ($questionId <= 0) {
        continue;
    }

    $answers[] = [
        'question_id' => $questionId,
        'answer_value' => $answerValue,
    ];
}

if (count($answers) === 0) {
    jsonResponse([
        'success' => false,
        'message' => 'No valid answers submitted'
    ], 400);
}

$numericTotal = 0;
$numericCount = 0;

foreach ($answers as $answer) {
    if (is_numeric($answer['answer_value'])) {
        $numericTotal += (float)$answer['answer_value'];
        $numericCount++;
    }
}

$score = 0;

if ($numericCount > 0) {
    $average = $numericTotal / $numericCount;
    $score = (int)round(($average / 5) * 100);
    $score = max(0, min(100, $score));
}

$pdo->beginTransaction();

try {
    $stmt = $pdo->prepare('
        INSERT INTO assessment_results
            (participant_id, assessment_type, score, result_date)
        VALUES
            (?, ?, ?, NOW())
    ');
    $stmt->execute([$participantId, $assessmentType, $score]);

    $resultId = (int)$pdo->lastInsertId();

    $stmt = $pdo->prepare('
        INSERT INTO assessment_answers
            (assessment_result_id, question_id, answer_value)
        VALUES
            (?, ?, ?)
    ');

    foreach ($answers as $answer) {
        $stmt->execute([
            $resultId,
            $answer['question_id'],
            $answer['answer_value'],
        ]);
    }

    $stmt = $pdo->prepare('
        UPDATE participant_profiles
        SET wellness_score = ?
        WHERE id = ?
    ');
    $stmt->execute([$score, $participantId]);

    if (tableExists($pdo, 'participant_history')) {
        $stmt = $pdo->prepare('
            INSERT INTO participant_history
                (
                    participant_profile_id,
                    user_id,
                    program_id,
                    event_type,
                    title,
                    description,
                    metadata,
                    created_by_user_id
                )
            VALUES
                (?, ?, ?, ?, ?, ?, ?, ?)
        ');

        $stmt->execute([
            $participantId,
            $userId,
            $programId,
            'assessment_completed',
            'Assessment completed',
            'The participant completed an assessment.',
            json_encode([
                'assessment_result_id' => $resultId,
                'assessment_type' => $assessmentType,
                'score' => $score,
                'next_available_in_days' => $frequencyDays,
            ], JSON_UNESCAPED_UNICODE),
            $userId,
        ]);
    }

    $pdo->commit();

    $nextAvailableAt = new DateTime('now');
    $nextAvailableAt->modify('+' . $frequencyDays . ' days');

    jsonResponse([
        'success' => true,
        'message' => 'Assessment submitted successfully',
        'assessment_result_id' => $resultId,
        'assessment_type' => $assessmentType,
        'score' => $score,
        'wellness_score' => $score,
        'frequency_days' => $frequencyDays,
        'next_available_at' => mysqlDate($nextAvailableAt),
        'days_remaining' => $frequencyDays,
    ]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    jsonResponse([
        'success' => false,
        'message' => 'Could not submit assessment',
        'debug' => $e->getMessage(),
    ], 500);
}
