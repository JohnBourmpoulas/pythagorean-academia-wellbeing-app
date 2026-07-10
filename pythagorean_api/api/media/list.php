<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

currentUser();
$pdo = getPDO();

$type = $_GET['type'] ?? null;

if ($type) {
    $stmt = $pdo->prepare('
        SELECT mi.*, mc.name AS category_name
        FROM media_items mi
        LEFT JOIN media_categories mc ON mc.id = mi.category_id
        WHERE mi.status = "active" AND mi.type = ?
        ORDER BY mi.id DESC
    ');
    $stmt->execute([$type]);
} else {
    $stmt = $pdo->query('
        SELECT mi.*, mc.name AS category_name
        FROM media_items mi
        LEFT JOIN media_categories mc ON mc.id = mi.category_id
        WHERE mi.status = "active"
        ORDER BY mi.id DESC
    ');
}

jsonResponse([
    'success' => true,
    'media' => $stmt->fetchAll(),
]);
