<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();
$data = getJsonInput();

$id = (int)($data['id'] ?? 0);

if ($id <= 0) {
    jsonError('Invalid task id', 400);
}

$stmt = $pdo->prepare('
    DELETE FROM program_daily_tasks
    WHERE id = ?
');

$stmt->execute([$id]);

jsonResponse([
    'success' => true,
    'message' => 'Task deleted successfully',
]);