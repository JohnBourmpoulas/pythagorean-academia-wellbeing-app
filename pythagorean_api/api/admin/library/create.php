<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';
require_once __DIR__ . '/../../../helpers/audit.php';

$admin = requireRole(['admin']);
$data = getJsonInput();
$pdo = getPDO();

$type = strtolower(trim((string)($data['type'] ?? '')));
$title = trim((string)($data['title'] ?? ''));

$allowedTypes = ['article', 'video', 'audio', 'meditation', 'pdf'];

if (!in_array($type, $allowedTypes, true)) {
    jsonError('Invalid resource type', 400);
}

if ($title === '') {
    jsonError('Title is required', 400);
}

$programId = isset($data['program_id']) && $data['program_id'] !== ''
    ? (int)$data['program_id']
    : null;

$description = trim((string)($data['description'] ?? ''));
$content = trim((string)($data['content'] ?? ''));
$externalUrl = trim((string)($data['external_url'] ?? ''));
$filePath = trim((string)($data['file_path'] ?? ''));
$thumbnailPath = trim((string)($data['thumbnail_path'] ?? ''));

$durationSeconds = isset($data['duration_seconds'])
    ? (int)$data['duration_seconds']
    : null;

$isRequired = (int)($data['is_required'] ?? 0);
$isActive = (int)($data['is_active'] ?? 1);
$sortOrder = (int)($data['sort_order'] ?? 0);

$stmt = $pdo->prepare('
    INSERT INTO library_items
        (
            program_id,
            type,
            title,
            description,
            content,
            external_url,
            file_path,
            thumbnail_path,
            duration_seconds,
            is_required,
            is_active,
            sort_order,
            created_by_admin_id
        )
    VALUES
        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
');

$stmt->execute([
    $programId,
    $type,
    $title,
    $description !== '' ? $description : null,
    $content !== '' ? $content : null,
    $externalUrl !== '' ? $externalUrl : null,
    $filePath !== '' ? $filePath : null,
    $thumbnailPath !== '' ? $thumbnailPath : null,
    $durationSeconds,
    $isRequired,
    $isActive,
    $sortOrder,
    (int)$admin['id'],
]);

$itemId = (int)$pdo->lastInsertId();

try {
    auditLog((int)$admin['id'], 'create_library_item', 'library_item', $itemId);
} catch (Throwable $ignored) {
}

jsonResponse([
    'success' => true,
    'message' => 'Library item created successfully',
    'id' => $itemId,
]);