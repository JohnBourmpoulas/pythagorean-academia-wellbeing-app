<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access reflection history'
    ], 403);
}

$userId = (int)$user['id'];

$stmt = $pdo->prepare('
    SELECT id, program_id
    FROM participant_profiles
    WHERE user_id = ?
      AND status = "active"
    ORDER BY id DESC
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

$stmt = $pdo->prepare('
    SELECT
        id,
        mood_level,
        stress_level,
        energy_level,
        sleep_quality,
        notes,
        reflection_date,
        created_at
    FROM participant_reflections
    WHERE participant_profile_id = ?
    ORDER BY reflection_date DESC, id DESC
');

$stmt->execute([$participantProfileId]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

jsonResponse([
    'success' => true,
    'reflections' => array_map(function ($row) {
        return [
            'id' => (int)$row['id'],
            'mood_level' => (int)$row['mood_level'],
            'stress_level' => (int)$row['stress_level'],
            'energy_level' => (int)$row['energy_level'],
            'sleep_quality' => (int)$row['sleep_quality'],
            'notes' => $row['notes'],
            'reflection_date' => $row['reflection_date'],
            'created_at' => $row['created_at'],
        ];
    }, $rows),
]);