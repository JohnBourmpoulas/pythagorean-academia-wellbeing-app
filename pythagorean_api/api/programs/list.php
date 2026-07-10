<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

currentUser();
$pdo = getPDO();

$stmt = $pdo->query('
    SELECT p.*, pc.name AS category_name
    FROM programs p
    LEFT JOIN program_categories pc ON pc.id = p.category_id
    WHERE p.status = "active"
    ORDER BY p.id ASC
');

jsonResponse([
    'success' => true,
    'programs' => $stmt->fetchAll(),
]);
