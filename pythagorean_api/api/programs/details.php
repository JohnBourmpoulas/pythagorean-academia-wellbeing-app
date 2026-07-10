<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

currentUser();
$pdo = getPDO();

$programId = (int)($_GET['id'] ?? 0);

$stmt = $pdo->prepare('
    SELECT p.*, pc.name AS category_name
    FROM programs p
    LEFT JOIN program_categories pc ON pc.id = p.category_id
    WHERE p.id = ? AND p.status != "deleted"
');
$stmt->execute([$programId]);
$program = $stmt->fetch();

if (!$program) {
    jsonError('Program not found', 404);
}

$stmt = $pdo->prepare('SELECT * FROM program_activities WHERE program_id = ? ORDER BY sort_order ASC');
$stmt->execute([$programId]);

jsonResponse([
    'success' => true,
    'program' => $program,
    'activities' => $stmt->fetchAll(),
]);
