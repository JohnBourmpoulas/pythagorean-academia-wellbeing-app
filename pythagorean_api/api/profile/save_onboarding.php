<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

function nullableNumber(array $data, string $key, ?float $min = null, ?float $max = null): ?float {
    if (!array_key_exists($key, $data) || $data[$key] === null) return null;
    $raw = trim(str_replace(',', '.', (string)$data[$key]));
    if ($raw === '') return null;
    if (!is_numeric($raw)) jsonResponse(['success' => false, 'message' => "Invalid $key"], 400);
    $value = (float)$raw;
    if ($min !== null && $value < $min) jsonResponse(['success' => false, 'message' => "$key is too small"], 400);
    if ($max !== null && $value > $max) jsonResponse(['success' => false, 'message' => "$key is too large"], 400);
    return $value;
}

function nullableInt(array $data, string $key): ?int {
    if (!array_key_exists($key, $data) || $data[$key] === null || trim((string)$data[$key]) === '') return null;
    if (filter_var($data[$key], FILTER_VALIDATE_INT) === false) {
        jsonResponse(['success' => false, 'message' => "Invalid $key"], 400);
    }
    return (int)$data[$key];
}

try {
    $user = currentUser();
    $data = getJsonInput();
    $pdo = getPDO();

    $height = nullableNumber($data, 'height_cm');
    if ($height !== null && $height > 0 && $height <= 3) $height *= 100;
    if ($height !== null && ($height < 50 || $height > 250)) {
        jsonResponse(['success' => false, 'message' => 'Height must be between 50 and 250 cm'], 400);
    }

    $weight = nullableNumber($data, 'weight_kg', 1, 500);
    $neck = nullableNumber($data, 'neck_cm', 1, 200);
    $waist = nullableNumber($data, 'waist_cm', 1, 300);
    $age = nullableInt($data, 'age');

    $bmi = null;
    if ($height !== null && $weight !== null && $height > 0) {
        $meters = $height / 100;
        $bmi = round($weight / ($meters * $meters), 2);
    }

    $goals = $data['goals'] ?? [];
    if (is_string($goals)) {
        $decodedGoals = json_decode($goals, true);
        $goals = is_array($decodedGoals)
            ? $decodedGoals
            : array_values(array_filter(array_map('trim', preg_split('/[,\n]+/', $goals))));
    }
    if (!is_array($goals)) $goals = [];

    $pdo->beginTransaction();

    // Phone belongs to users, not interested_profiles.
    if (array_key_exists('phone', $data)) {
        $phone = trim((string)($data['phone'] ?? ''));
        $phone = $phone === '' ? null : $phone;
        $userStmt = $pdo->prepare('UPDATE users SET phone = ? WHERE id = ?');
        $userStmt->execute([$phone, (int)$user['id']]);
    }

    $stmt = $pdo->prepare('
        INSERT INTO interested_profiles (
            user_id, age, profession, height_cm, weight_kg, neck_cm, waist_cm, bmi,
            nutrition_habits, smoking_habits, physical_activity, sleep_quality, goals, onboarding_completed
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
        ON DUPLICATE KEY UPDATE
            age = VALUES(age), profession = VALUES(profession),
            height_cm = VALUES(height_cm), weight_kg = VALUES(weight_kg),
            neck_cm = VALUES(neck_cm), waist_cm = VALUES(waist_cm), bmi = VALUES(bmi),
            nutrition_habits = VALUES(nutrition_habits), smoking_habits = VALUES(smoking_habits),
            physical_activity = VALUES(physical_activity), sleep_quality = VALUES(sleep_quality),
            goals = VALUES(goals), onboarding_completed = 1
    ');

    $stmt->execute([
        (int)$user['id'],
        $age,
        isset($data['profession']) && trim((string)$data['profession']) !== '' ? trim((string)$data['profession']) : null,
        $height,
        $weight,
        $neck,
        $waist,
        $bmi,
        $data['nutrition_habits'] ?? null,
        $data['smoking_habits'] ?? null,
        $data['physical_activity'] ?? null,
        $data['sleep_quality'] ?? null,
        json_encode($goals, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
    ]);

    $pdo->commit();

    jsonResponse([
        'success' => true,
        'message' => 'Profile saved',
        'height_cm' => $height,
        'weight_kg' => $weight,
        'neck_cm' => $neck,
        'waist_cm' => $waist,
        'bmi' => $bmi,
    ]);
} catch (Throwable $e) {
    if (isset($pdo) && $pdo instanceof PDO && $pdo->inTransaction()) $pdo->rollBack();
    error_log('save_onboarding.php: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Could not save profile'], 500);
}
