<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can view wearable data',
    ], 403);
}

$userId = (int)($user['id'] ?? 0);

function ensureHealthMetricTables(PDO $pdo): void
{
    $pdo->exec('
        CREATE TABLE IF NOT EXISTS participant_health_syncs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            participant_profile_id INT NOT NULL,
            provider VARCHAR(80) NOT NULL DEFAULT "Health Connect",
            device_name VARCHAR(150) NULL,
            status VARCHAR(40) NOT NULL DEFAULT "connected",
            last_sync_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME NULL,
            INDEX idx_phs_participant (participant_profile_id),
            INDEX idx_phs_provider (provider)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ');

    $pdo->exec('
        CREATE TABLE IF NOT EXISTS participant_health_metrics (
            id INT AUTO_INCREMENT PRIMARY KEY,
            participant_profile_id INT NOT NULL,
            metric_type VARCHAR(80) NOT NULL,
            metric_value DECIMAL(12,2) NOT NULL DEFAULT 0,
            metric_unit VARCHAR(40) NOT NULL,
            provider VARCHAR(80) NOT NULL DEFAULT "Health Connect",
            device_name VARCHAR(150) NULL,
            recorded_at DATETIME NOT NULL,
            metric_date DATE NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_phm_participant_date (participant_profile_id, metric_date),
            INDEX idx_phm_type (metric_type),
            INDEX idx_phm_recorded (recorded_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ');
}

try {
    ensureHealthMetricTables($pdo);

    $stmt = $pdo->prepare('
        SELECT id, user_id, program_id
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
        ], 404);
    }

    $participantProfileId = (int)$participant['id'];
    $today = date('Y-m-d');

    $stmt = $pdo->prepare('
        SELECT metric_type, metric_value, metric_unit, provider, device_name, recorded_at
        FROM participant_health_metrics
        WHERE participant_profile_id = ?
          AND metric_date = ?
        ORDER BY recorded_at DESC, id DESC
    ');
    $stmt->execute([$participantProfileId, $today]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $latest = [
        'steps' => null,
        'heart_rate' => null,
        'sleep_hours' => null,
    ];

    foreach ($rows as $row) {
        $type = (string)$row['metric_type'];
        if (array_key_exists($type, $latest) && $latest[$type] === null) {
            $latest[$type] = [
                'metric_type' => $type,
                'metric_value' => (float)$row['metric_value'],
                'metric_unit' => (string)$row['metric_unit'],
                'provider' => (string)$row['provider'],
                'device_name' => (string)($row['device_name'] ?? ''),
                'recorded_at' => (string)$row['recorded_at'],
            ];
        }
    }

    $stmt = $pdo->prepare('
        SELECT provider, device_name, status, last_sync_at
        FROM participant_health_syncs
        WHERE participant_profile_id = ?
        ORDER BY last_sync_at DESC, id DESC
    ');
    $stmt->execute([$participantProfileId]);
    $devices = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $lastSyncAt = null;
    if (count($devices) > 0) {
        $lastSyncAt = $devices[0]['last_sync_at'] ?? null;
    }

    jsonResponse([
        'success' => true,
        'message' => 'Wearable data loaded',
        'today' => [
            'steps' => $latest['steps'],
            'heart_rate' => $latest['heart_rate'],
            'sleep_hours' => $latest['sleep_hours'],
        ],
        'metrics' => $latest,
        'devices' => $devices,
        'last_sync_at' => $lastSyncAt,
    ]);
} catch (Throwable $e) {
    jsonResponse([
        'success' => false,
        'message' => 'Could not load wearable data',
        'debug' => $e->getMessage(),
    ], 500);
}
