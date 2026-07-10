<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonResponse([
        'success' => false,
        'message' => 'Only participants can access the library'
    ],403);
}

$type = strtolower(trim($_GET['type'] ?? 'all'));

$sql = "
SELECT
    li.id,
    li.title,
    li.description,
    li.content,
    li.type,
    li.external_url,
    li.file_path,
    li.thumbnail_path,
    li.duration_seconds,
    li.is_required,
    li.sort_order
FROM library_items li
WHERE
    li.is_active = 1
";

$params = [];

if ($type !== 'all') {
    $sql .= " AND li.type = :type ";
    $params['type'] = $type;
}

$sql .= "
ORDER BY
    li.sort_order ASC,
    li.created_at DESC
";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);

$items = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

    $items[] = [

        'id' => (int)$row['id'],

        'title' => $row['title'],

        'description' => $row['description'],

        'content' => $row['content'],

        'type' => $row['type'],

        'external_url' => $row['external_url'],

        'file_path' => $row['file_path'],

        'thumbnail_path' => $row['thumbnail_path'],

        'duration_seconds' => $row['duration_seconds'] == null
            ? null
            : (int)$row['duration_seconds'],

        'is_required' => (bool)$row['is_required'],

        'sort_order' => (int)$row['sort_order'],
    ];
}

jsonResponse([
    'success' => true,
    'items' => $items
]);