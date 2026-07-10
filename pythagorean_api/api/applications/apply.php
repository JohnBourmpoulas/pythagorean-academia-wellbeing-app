<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = requireRole(['interested', 'participant']);
$data = getJsonInput();
$pdo = getPDO();

$programId = (int)($data['program_id'] ?? 0);

$stmt = $pdo->prepare('SELECT id FROM programs WHERE id = ? AND status = "active"');
$stmt->execute([$programId]);

if (!$stmt->fetch()) {
    jsonError('Program not found', 404);
}

try {
    $stmt = $pdo->prepare('
        INSERT INTO program_applications (user_id, program_id, status)
        VALUES (?, ?, "pending")
    ');
    $stmt->execute([(int)$user['id'], $programId]);

    jsonResponse([
        'success' => true,
        'message' => 'Application submitted successfully',
        'application_id' => (int)$pdo->lastInsertId(),
    ], 201);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        jsonError('You have already applied to this program', 409);
    }
    jsonError('Could not submit application', 500, ['debug' => $e->getMessage()]);
}
