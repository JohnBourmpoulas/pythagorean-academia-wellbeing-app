<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$stmt = $pdo->prepare('
    SELECT p.*, pc.name AS category_name
    FROM programs p
    LEFT JOIN program_categories pc ON pc.id = p.category_id
    INNER JOIN admin_programs ap ON ap.program_id = p.id
    WHERE ap.admin_id = ? AND p.status != "deleted"
    ORDER BY p.id DESC
');
$stmt->execute([(int)$admin['id']]);

jsonResponse([
    'success' => true,
    'programs' => $stmt->fetchAll(),
]);
