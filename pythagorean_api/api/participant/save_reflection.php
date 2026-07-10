<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse(['success' => false, 'message' => 'Only participants can submit reflections'], 403);
}

$data = json_decode(file_get_contents('php://input'), true);

$mood = (int)($data['mood_level'] ?? 0);
$stress = (int)($data['stress_level'] ?? 0);
$energy = (int)($data['energy_level'] ?? 0);
$sleep = (int)($data['sleep_quality'] ?? 0);
$notes = trim($data['notes'] ?? '');

if ($mood < 1 || $mood > 5 || $stress < 1 || $stress > 5 || $energy < 1 || $energy > 5 || $sleep < 1 || $sleep > 5) {
    jsonResponse(['success' => false, 'message' => 'Invalid reflection values'], 400);
}

$stmt = $pdo->prepare('
    SELECT id, user_id, program_id
    FROM participant_profiles
    WHERE user_id = ? AND status = "active"
    ORDER BY id DESC
    LIMIT 1
');
$stmt->execute([(int)$user['id']]);
$profile = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$profile) {
    jsonResponse(['success' => false, 'message' => 'Participant profile not found'], 404);
}

$participantId = (int)$profile['id'];
$userId = (int)$profile['user_id'];
$programId = (int)$profile['program_id'];

$pdo->beginTransaction();

try {
    $stmt = $pdo->prepare('
        INSERT INTO participant_reflections
            (participant_profile_id, user_id, program_id, mood_level, stress_level, energy_level, sleep_quality, notes, reflection_date)
        VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, CURDATE())
    ');
    $stmt->execute([
        $participantId,
        $userId,
        $programId,
        $mood,
        $stress,
        $energy,
        $sleep,
        $notes,
    ]);

    $stmt = $pdo->prepare('
        INSERT INTO participant_history
            (participant_profile_id, user_id, program_id, event_type, title, description, created_by_user_id)
        VALUES
            (?, ?, ?, "reflection_submitted", "Daily reflection submitted", ?, ?)
    ');
    $stmt->execute([
        $participantId,
        $userId,
        $programId,
        $notes !== '' ? $notes : 'The participant submitted a daily reflection.',
        $userId,
    ]);

    $pdo->commit();

    jsonResponse(['success' => true, 'message' => 'Reflection saved successfully']);
} catch (Throwable $e) {
    $pdo->rollBack();

    jsonResponse([
        'success' => false,
        'message' => 'Could not save reflection',
        'debug' => $e->getMessage()
    ], 500);
}