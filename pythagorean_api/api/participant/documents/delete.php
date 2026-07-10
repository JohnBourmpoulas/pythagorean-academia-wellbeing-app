<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can delete documents', 403);
}

$data = getJsonInput();

$userId = (int)$user['id'];
$documentId = (int)($data['id'] ?? 0);

if ($documentId <= 0) {
    jsonError('Invalid document id', 400);
}

$stmt = $pdo->prepare('
    SELECT
        id,
        file_path
    FROM participant_documents
    WHERE id = ?
      AND user_id = ?
    LIMIT 1
');
$stmt->execute([$documentId, $userId]);
$document = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$document) {
    jsonError('Document not found', 404);
}

$filePath = (string)$document['file_path'];

$absolutePath = dirname(__DIR__, 3) . '/' . ltrim($filePath, '/');

if (is_file($absolutePath)) {
    @unlink($absolutePath);
}

$stmt = $pdo->prepare('
    DELETE FROM participant_documents
    WHERE id = ?
      AND user_id = ?
');
$stmt->execute([$documentId, $userId]);

jsonResponse([
    'success' => true,
    'message' => 'Document deleted successfully',
]);