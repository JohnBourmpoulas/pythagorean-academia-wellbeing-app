<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$id = (int)($_GET['id'] ?? 0);

if ($id <= 0) {
    jsonError('Invalid task id', 400);
}

$stmt = $pdo->prepare('
    SELECT
        t.*,
        l.title AS library_title,
        l.type AS library_type
    FROM program_daily_tasks t
    LEFT JOIN library_items l ON l.id = t.library_item_id
    WHERE t.id = ?
    LIMIT 1
');

$stmt->execute([$id]);
$task = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$task) {
    jsonError('Task not found', 404);
}

jsonResponse([
    'success' => true,
    'task' => $task,
]);