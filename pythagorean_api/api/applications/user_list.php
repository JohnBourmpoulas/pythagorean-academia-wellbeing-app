<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$stmt = $pdo->prepare('
    SELECT pa.*, p.title, p.short_title
    FROM program_applications pa
    INNER JOIN programs p ON p.id = pa.program_id
    WHERE pa.user_id = ?
    ORDER BY pa.submitted_at DESC
');
$stmt->execute([(int)$user['id']]);

jsonResponse([
    'success' => true,
    'applications' => $stmt->fetchAll(),
]);
