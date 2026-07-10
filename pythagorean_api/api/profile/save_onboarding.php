<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$data = getJsonInput();
$pdo = getPDO();

$height = isset($data['height_cm']) ? (float)$data['height_cm'] : null;
$weight = isset($data['weight_kg']) ? (float)$data['weight_kg'] : null;
$bmi = null;

if ($height && $weight && $height > 0) {
    $meters = $height / 100;
    $bmi = round($weight / ($meters * $meters), 2);
}

$stmt = $pdo->prepare('
    INSERT INTO interested_profiles (
        user_id, age, profession, height_cm, weight_kg, neck_cm, waist_cm, bmi,
        nutrition_habits, smoking_habits, physical_activity, sleep_quality, goals, onboarding_completed
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
    ON DUPLICATE KEY UPDATE
        age = VALUES(age),
        profession = VALUES(profession),
        height_cm = VALUES(height_cm),
        weight_kg = VALUES(weight_kg),
        neck_cm = VALUES(neck_cm),
        waist_cm = VALUES(waist_cm),
        bmi = VALUES(bmi),
        nutrition_habits = VALUES(nutrition_habits),
        smoking_habits = VALUES(smoking_habits),
        physical_activity = VALUES(physical_activity),
        sleep_quality = VALUES(sleep_quality),
        goals = VALUES(goals),
        onboarding_completed = 1
');

$stmt->execute([
    (int)$user['id'],
    $data['age'] ?? null,
    $data['profession'] ?? null,
    $height,
    $weight,
    $data['neck_cm'] ?? null,
    $data['waist_cm'] ?? null,
    $bmi,
    $data['nutrition_habits'] ?? null,
    $data['smoking_habits'] ?? null,
    $data['physical_activity'] ?? null,
    $data['sleep_quality'] ?? null,
    json_encode($data['goals'] ?? [], JSON_UNESCAPED_UNICODE),
]);

jsonResponse([
    'success' => true,
    'message' => 'Onboarding profile saved',
    'bmi' => $bmi,
]);
