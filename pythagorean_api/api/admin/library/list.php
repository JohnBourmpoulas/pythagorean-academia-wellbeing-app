<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$type = strtolower(trim($_GET['type'] ?? 'all'));

$sql = '
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
        li.created_at,
        li.updated_at
    FROM library_items li
    LEFT JOIN programs p ON p.id = li.program_id
    WHERE 1 = 1
';

$params = [];

if ($type !== 'all') {
    $sql .= ' AND li.type = ? ';
    $params[] = $type;
}

$sql .= '
    ORDER BY 
        li.sort_order ASC,
        li.created_at DESC
';

$stmt = $pdo->prepare($sql);
$stmt->execute($params);

$items = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $items[] = [
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
        'created_at' => $row['created_at'],
        'updated_at' => $row['updated_at'],
    ];
}

jsonResponse([
    'success' => true,
    'items' => $items,
]);