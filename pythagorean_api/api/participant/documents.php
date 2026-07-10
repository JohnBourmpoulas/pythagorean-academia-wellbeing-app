<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access documents'
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
        file_type,
        title,
        file_path,
        mime_type,
        file_size,
        created_at
    FROM participant_files
    WHERE participant_profile_id = ?
    ORDER BY created_at DESC
');

$stmt->execute([$participantProfileId]);
$files = $stmt->fetchAll(PDO::FETCH_ASSOC);

jsonResponse([
    'success' => true,
    'documents' => array_map(function ($file) {
        return [
            'id' => (int)$file['id'],
            'file_type' => $file['file_type'],
            'title' => $file['title'],
            'file_path' => $file['file_path'],
            'mime_type' => $file['mime_type'],
            'file_size' => (int)($file['file_size'] ?? 0),
            'created_at' => $file['created_at'],
        ];
    }, $files),
]);