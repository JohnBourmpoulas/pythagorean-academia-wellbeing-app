<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$id = (int)($_GET['id'] ?? 0);

if ($id <= 0) {
    jsonError('Invalid resource id', 400);
}

$stmt = $pdo->prepare('
    SELECT
        li.id,
        li.program_id,
        p.title AS program_title,
        li.type,
        li.title,
        li.description,
        li.content,
        li.external_url,
        li.file_path,
        li.thumbnail_path,
        li.duration_seconds,
        li.is_required,
        li.is_active,
        li.sort_order,
        li.created_by_admin_id,
        u.full_name AS created_by_name,
        li.created_at,
        li.updated_at
    FROM library_items li
    LEFT JOIN programs p ON p.id = li.program_id
    LEFT JOIN users u ON u.id = li.created_by_admin_id
    WHERE li.id = ?
    LIMIT 1
');
$stmt->execute([$id]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$row) {
    jsonError('Library item not found', 404);
}

jsonResponse([
    'success' => true,
    'item' => [
        'id' => (int)$row['id'],
        'program_id' => $row['program_id'] === null ? null : (int)$row['program_id'],
        'program_title' => $row['program_title'],
        'type' => $row['type'],
        'title' => $row['title'],
        'description' => $row['description'],
        'content' => $row['content'],
        'external_url' => $row['external_url'],
        'file_path' => $row['file_path'],
        'thumbnail_path' => $row['thumbnail_path'],
        'duration_seconds' => $row['duration_seconds'] === null ? null : (int)$row['duration_seconds'],
        'is_required' => (int)$row['is_required'],
        'is_active' => (int)$row['is_active'],
        'sort_order' => (int)$row['sort_order'],
        'created_by_admin_id' => $row['created_by_admin_id'] === null ? null : (int)$row['created_by_admin_id'],
        'created_by_name' => $row['created_by_name'],
        'created_at' => $row['created_at'],
        'updated_at' => $row['updated_at'],
    ],
]);