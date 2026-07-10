<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';
require_once __DIR__ . '/../../../helpers/audit.php';

$admin = requireRole(['admin']);
$data = getJsonInput();
$pdo = getPDO();

$id = (int)($data['id'] ?? 0);

if ($id <= 0) {
    jsonError('Invalid resource id', 400);
}

$stmt = $pdo->prepare('SELECT * FROM library_items WHERE id = ? LIMIT 1');
$stmt->execute([$id]);
$item = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$item) {
    jsonError('Library item not found', 404);
}

$allowedColumns = [
    'program_id',
    'type',
    'title',
    'description',
    'content',
    'external_url',
    'file_path',
    'thumbnail_path',
    'duration_seconds',
    'is_required',
    'is_active',
    'sort_order',
];

$allowedTypes = ['article', 'video', 'audio', 'meditation', 'pdf'];

$set = [];
$params = [];

foreach ($allowedColumns as $column) {
    if (!array_key_exists($column, $data)) {
        continue;
    }

    $value = $data[$column];

    if ($column === 'type') {
        $value = strtolower(trim((string)$value));

        if (!in_array($value, $allowedTypes, true)) {
            jsonError('Invalid resource type', 400);
        }
    }

    if ($column === 'title') {
        $value = trim((string)$value);

        if ($value === '') {
            jsonError('Title is required', 400);
        }
    }

    if ($column === 'program_id') {
        $value = ($value === null || $value === '') ? null : (int)$value;
    }

    if (in_array($column, ['is_required', 'is_active', 'sort_order', 'duration_seconds'], true)) {
        $value = ($value === null || $value === '') ? null : (int)$value;
    }

    if (in_array($column, ['description', 'content', 'external_url', 'file_path', 'thumbnail_path'], true)) {
        $value = trim((string)$value);
        $value = $value === '' ? null : $value;
    }

    $set[] = "$column = ?";
    $params[] = $value;
}

if (empty($set)) {
    jsonError('No fields to update', 400);
}

$params[] = $id;

$stmt = $pdo->prepare('
    UPDATE library_items
    SET ' . implode(', ', $set) . '
    WHERE id = ?
');
$stmt->execute($params);

try {
    auditLog((int)$admin['id'], 'update_library_item', 'library_item', $id);
} catch (Throwable $ignored) {
}

jsonResponse([
    'success' => true,
    'message' => 'Library item updated successfully',
]);