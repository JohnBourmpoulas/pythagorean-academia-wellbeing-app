<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = requireRole(['participant']);
$pdo = getPDO();

$stmt = $pdo->prepare('
    SELECT r.*
    FROM reflections r
    INNER JOIN participant_profiles pp ON pp.id = r.participant_id
    WHERE pp.user_id = ?
    ORDER BY r.created_at DESC
');
$stmt->execute([(int)$user['id']]);

jsonResponse([
    'success' => true,
    'reflections' => $stmt->fetchAll(),
]);
