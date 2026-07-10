<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$programId = (int)($_GET['program_id'] ?? 0);
$day = (int)($_GET['day'] ?? 0);

if ($programId <= 0) {
    jsonError('Invalid program id', 400);
}

$sql = '
    SELECT
        t.*,
        l.title AS library_title,
        l.type AS library_type
    FROM program_daily_tasks t
    LEFT JOIN library_items l ON l.id = t.library_item_id
    WHERE t.program_id = ?
';

$params = [$programId];

if ($day > 0) {
    $sql .= ' AND t.day_number = ?';
    $params[] = $day;
}

$sql .= ' ORDER BY t.day_number ASC, t.order_index ASC, t.id ASC';

$stmt = $pdo->prepare($sql);
$stmt->execute($params);

jsonResponse([
    'success' => true,
    'message' => 'Tasks loaded',
    'tasks' => $stmt->fetchAll(PDO::FETCH_ASSOC),
]);