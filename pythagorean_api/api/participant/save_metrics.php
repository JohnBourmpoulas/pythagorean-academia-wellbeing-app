<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can sync wearable data',
    ], 403);
}

$userId = (int)($user['id'] ?? 0);
$data = getJsonInput();

$provider = trim((string)($data['provider'] ?? 'Health Connect'));
$deviceName = trim((string)($data['device_name'] ?? $provider));
$metricsInput = $data['metrics'] ?? [];

if ($provider === '') {
    $provider = 'Health Connect';
}

if ($deviceName === '') {
    $deviceName = $provider;
}

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
    $now = date('Y-m-d H:i:s');

    $allowedTypes = [
        'steps' => 'steps',
        'heart_rate' => 'bpm',
        'sleep_hours' => 'hours',
    ];

    $cleanMetrics = [];

    if (is_array($metricsInput)) {
        foreach ($metricsInput as $metric) {
            if (!is_array($metric)) {
                continue;
            }

            $type = strtolower(trim((string)($metric['metric_type'] ?? '')));

            if (!array_key_exists($type, $allowedTypes)) {
                continue;
            }

            if (!array_key_exists('metric_value', $metric) || !is_numeric($metric['metric_value'])) {
                continue;
            }

            $value = (float)$metric['metric_value'];
            $unit = trim((string)($metric['metric_unit'] ?? $allowedTypes[$type]));
            $recordedAtRaw = trim((string)($metric['recorded_at'] ?? $now));

            $timestamp = strtotime($recordedAtRaw);
            if ($timestamp === false) {
                $timestamp = time();
            }

            $recordedAt = date('Y-m-d H:i:s', $timestamp);
            $metricDate = date('Y-m-d', $timestamp);

            if ($unit === '') {
                $unit = $allowedTypes[$type];
            }

            $cleanMetrics[] = [
                'metric_type' => $type,
                'metric_value' => $value,
                'metric_unit' => $unit,
                'recorded_at' => $recordedAt,
                'metric_date' => $metricDate,
            ];
        }
    }

    $pdo->beginTransaction();

    $stmt = $pdo->prepare('
        SELECT id
        FROM participant_health_syncs
        WHERE participant_profile_id = ?
          AND provider = ?
        ORDER BY id DESC
        LIMIT 1
    ');
    $stmt->execute([$participantProfileId, $provider]);
    $syncId = (int)($stmt->fetchColumn() ?: 0);

    if ($syncId > 0) {
        $stmt = $pdo->prepare('
            UPDATE participant_health_syncs
            SET device_name = ?,
                status = "connected",
                last_sync_at = NOW(),
                updated_at = NOW()
            WHERE id = ?
        ');
        $stmt->execute([$deviceName, $syncId]);
    } else {
        $stmt = $pdo->prepare('
            INSERT INTO participant_health_syncs
                (participant_profile_id, provider, device_name, status, last_sync_at, updated_at)
            VALUES
                (?, ?, ?, "connected", NOW(), NOW())
        ');
        $stmt->execute([$participantProfileId, $provider, $deviceName]);
    }

    $inserted = 0;

    if (count($cleanMetrics) > 0) {
        $deleteStmt = $pdo->prepare('
            DELETE FROM participant_health_metrics
            WHERE participant_profile_id = ?
              AND metric_type = ?
              AND metric_date = ?
              AND provider = ?
        ');

        $insertStmt = $pdo->prepare('
            INSERT INTO participant_health_metrics
                (
                    participant_profile_id,
                    metric_type,
                    metric_value,
                    metric_unit,
                    provider,
                    device_name,
                    recorded_at,
                    metric_date
                )
            VALUES
                (?, ?, ?, ?, ?, ?, ?, ?)
        ');

        foreach ($cleanMetrics as $metric) {
            $deleteStmt->execute([
                $participantProfileId,
                $metric['metric_type'],
                $metric['metric_date'],
                $provider,
            ]);

            $insertStmt->execute([
                $participantProfileId,
                $metric['metric_type'],
                $metric['metric_value'],
                $metric['metric_unit'],
                $provider,
                $deviceName,
                $metric['recorded_at'],
                $metric['metric_date'],
            ]);

            $inserted++;
        }
    }

    $pdo->commit();

    jsonResponse([
        'success' => true,
        'message' => $inserted > 0
            ? 'Health metrics synced successfully'
            : 'Health sync completed, but no wearable values were found on this device',
        'inserted' => $inserted,
        'provider' => $provider,
        'device_name' => $deviceName,
        'last_sync_at' => $now,
    ]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    jsonResponse([
        'success' => false,
        'message' => 'Could not save health metrics',
        'debug' => $e->getMessage(),
    ], 500);
}
