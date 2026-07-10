<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';
require_once __DIR__ . '/../../helpers/audit.php';
require_once __DIR__ . '/../../helpers/participant_storage.php';

$admin = requireRole(['admin']);
$data = getJsonInput();
$pdo = getPDO();

$applicationId = (int)($data['application_id'] ?? 0);

if ($applicationId <= 0) {
    jsonError('Invalid application id', 400);
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

$stmt = $pdo->prepare('
    SELECT 
        pa.*, 
        p.duration_weeks,
        p.title AS program_title,
        u.full_name,
        u.email
    FROM program_applications pa
    INNER JOIN programs p ON p.id = pa.program_id
    INNER JOIN users u ON u.id = pa.user_id
    INNER JOIN admin_programs ap ON ap.program_id = pa.program_id
    WHERE pa.id = ? 
      AND ap.admin_id = ? 
      AND pa.status = "pending"
    LIMIT 1
');
$stmt->execute([$applicationId, (int)$admin['id']]);
$application = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$application) {
    jsonError('Pending application not found', 404);
}

$pdo->beginTransaction();

try {
    $userId = (int)$application['user_id'];
    $programId = (int)$application['program_id'];
    $totalWeeks = max(1, (int)$application['duration_weeks']);

    $stmt = $pdo->prepare('
        UPDATE program_applications
        SET status = "approved",
            reviewed_by_admin_id = ?,
            reviewed_at = NOW()
        WHERE id = ?
    ');
    $stmt->execute([(int)$admin['id'], $applicationId]);

    $stmt = $pdo->prepare('
        UPDATE users
        SET role = "participant"
        WHERE id = ?
    ');
    $stmt->execute([$userId]);

    $stmt = $pdo->prepare('
        SELECT id, storage_folder
        FROM participant_profiles
        WHERE user_id = ?
          AND program_id = ?
        LIMIT 1
    ');
    $stmt->execute([$userId, $programId]);
    $existingParticipant = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($existingParticipant) {
        $participantId = (int)$existingParticipant['id'];
        $storageFolder = trim((string)($existingParticipant['storage_folder'] ?? ''));

        if ($storageFolder === '') {
            $storageFolder = generateParticipantStorageFolder();
        }

        createParticipantStorageFolders($storageFolder);

        $set = [];
        $params = [];

        if (columnExists($pdo, 'participant_profiles', 'application_id')) {
            $set[] = 'application_id = ?';
            $params[] = $applicationId;
        }

        if (columnExists($pdo, 'participant_profiles', 'total_weeks')) {
            $set[] = 'total_weeks = ?';
            $params[] = $totalWeeks;
        }

        if (columnExists($pdo, 'participant_profiles', 'current_week')) {
            $set[] = 'current_week = 1';
        }

        if (columnExists($pdo, 'participant_profiles', 'progress_percent')) {
            $set[] = 'progress_percent = 0';
        }

        if (columnExists($pdo, 'participant_profiles', 'status')) {
            $set[] = 'status = "active"';
        }

        if (columnExists($pdo, 'participant_profiles', 'start_date')) {
            $set[] = 'start_date = COALESCE(start_date, CURDATE())';
        }

        if (columnExists($pdo, 'participant_profiles', 'storage_folder')) {
            $set[] = 'storage_folder = ?';
            $params[] = $storageFolder;
        }

        if (!empty($set)) {
            $params[] = $participantId;

            $stmt = $pdo->prepare('
                UPDATE participant_profiles
                SET ' . implode(', ', $set) . '
                WHERE id = ?
            ');
            $stmt->execute($params);
        }
    } else {
        $storageFolder = generateParticipantStorageFolder();
        createParticipantStorageFolders($storageFolder);

        $columns = [];
        $placeholders = [];
        $params = [];

        $insertValue = function (string $column, mixed $value) use (&$columns, &$placeholders, &$params, $pdo) {
            if (columnExists($pdo, 'participant_profiles', $column)) {
                $columns[] = $column;
                $placeholders[] = '?';
                $params[] = $value;
            }
        };

        $insertRaw = function (string $column, string $rawSql) use (&$columns, &$placeholders, $pdo) {
            if (columnExists($pdo, 'participant_profiles', $column)) {
                $columns[] = $column;
                $placeholders[] = $rawSql;
            }
        };

        $insertValue('user_id', $userId);
        $insertValue('program_id', $programId);
        $insertValue('application_id', $applicationId);
        $insertValue('current_week', 1);
        $insertValue('total_weeks', $totalWeeks);
        $insertValue('wellness_score', 0);
        $insertValue('progress_percent', 0);
        $insertValue('status', 'active');
        $insertRaw('start_date', 'CURDATE()');
        $insertValue('storage_folder', $storageFolder);
        $insertValue('profile_completed', 0);

        if (empty($columns)) {
            throw new RuntimeException('participant_profiles has no compatible columns');
        }

        $stmt = $pdo->prepare('
            INSERT INTO participant_profiles (' . implode(', ', $columns) . ')
            VALUES (' . implode(', ', $placeholders) . ')
        ');
        $stmt->execute($params);

        $participantId = (int)$pdo->lastInsertId();
    }

    if ($participantId <= 0) {
        throw new RuntimeException('Could not create participant profile');
    }

    if (tableExists($pdo, 'daily_tasks') && tableExists($pdo, 'program_activities')) {
        $stmt = $pdo->prepare('
            INSERT INTO daily_tasks
                (participant_id, program_activity_id, title, description, scheduled_time, task_date)
            SELECT
                ?, id, title, description, scheduled_time, CURDATE()
            FROM program_activities
            WHERE program_id = ?
              AND NOT EXISTS (
                  SELECT 1
                  FROM daily_tasks dt
                  WHERE dt.participant_id = ?
                    AND dt.program_activity_id = program_activities.id
                    AND dt.task_date = CURDATE()
              )
        ');
        $stmt->execute([$participantId, $programId, $participantId]);
    }

    if (tableExists($pdo, 'wearable_devices')) {
        $stmt = $pdo->prepare('
            INSERT INTO wearable_devices
                (participant_id, provider, device_name, status)
            SELECT ?, ?, ?, ?
            WHERE NOT EXISTS (
                SELECT 1
                FROM wearable_devices
                WHERE participant_id = ?
                  AND provider = ?
                  AND device_name = ?
            )
        ');

        $devices = [
            ['Apple', 'Apple Watch'],
            ['Apple', 'Apple Health'],
            ['Samsung', 'Samsung Health'],
            ['Google', 'Google Fit'],
        ];

        foreach ($devices as $device) {
            $stmt->execute([
                $participantId,
                $device[0],
                $device[1],
                'disconnected',
                $participantId,
                $device[0],
                $device[1],
            ]);
        }
    }

    if (tableExists($pdo, 'participant_history')) {
        $stmt = $pdo->prepare('
            INSERT INTO participant_history
                (participant_profile_id, user_id, program_id, event_type, title, description, metadata, created_by_user_id)
            VALUES
                (?, ?, ?, ?, ?, ?, ?, ?)
        ');

        $stmt->execute([
            $participantId,
            $userId,
            $programId,
            'profile_created',
            'Participant profile activated',
            'The application was approved and the user gained access to the participant dashboard.',
            json_encode([
                'application_id' => $applicationId,
                'program_title' => $application['program_title'] ?? null,
                'storage_folder' => $storageFolder,
            ], JSON_UNESCAPED_UNICODE),
            (int)$admin['id'],
        ]);
    }

    if (tableExists($pdo, 'notifications')) {
        try {
            $stmt = $pdo->prepare('
                INSERT INTO notifications (user_id, title, message, created_at)
                VALUES (?, ?, ?, NOW())
            ');
            $stmt->execute([
                $userId,
                'Application approved',
                'Your application has been approved. You now have access to your participant dashboard.',
            ]);
        } catch (Throwable $ignored) {
        }
    }

    try {
        auditLog((int)$admin['id'], 'approve_application', 'program_application', $applicationId);
    } catch (Throwable $ignored) {
    }

    $pdo->commit();

    jsonResponse([
        'success' => true,
        'message' => 'Application approved and user promoted to participant',
        'participant_profile_id' => $participantId,
        'storage_folder' => $storageFolder,
    ]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    header('Content-Type: application/json');

    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'file' => basename($e->getFile()),
        'line' => $e->getLine(),
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    exit;
}