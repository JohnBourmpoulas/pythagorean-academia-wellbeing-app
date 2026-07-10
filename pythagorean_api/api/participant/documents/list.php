<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can access documents', 403);
}

$userId = (int)$user['id'];

$stmt = $pdo->prepare('
    SELECT id
    FROM participant_profiles
    WHERE user_id = ?
      AND status = "active"
    ORDER BY id DESC
    LIMIT 1
');
$stmt->execute([$userId]);
$participantProfileId = (int)($stmt->fetchColumn() ?: 0);

if ($participantProfileId <= 0) {
    jsonError('Participant profile not found', 404);
}

$stmt = $pdo->prepare('
    SELECT
        id,
        title,
        document_type,
        period_label,
        period_months,
        file_path,
        created_at
    FROM participant_documents
    WHERE participant_profile_id = ?
      AND user_id = ?
    ORDER BY created_at DESC
');
$stmt->execute([$participantProfileId, $userId]);

$documents = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $documents[] = [
        'id' => (int)$row['id'],
        'title' => $row['title'],
        'document_type' => $row['document_type'],
        'period_label' => $row['period_label'],
        'period_months' => $row['period_months'] === null
            ? null
            : (int)$row['period_months'],
        'file_path' => $row['file_path'],
        'created_at' => $row['created_at'],
    ];
}

jsonResponse([
    'success' => true,
    'documents' => $documents,
]);