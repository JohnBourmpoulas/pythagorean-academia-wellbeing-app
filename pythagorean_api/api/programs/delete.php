<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';
require_once __DIR__ . '/../../helpers/audit.php';

$admin = requireRole(['admin']);
$data = getJsonInput();
$pdo = getPDO();

$programId = (int)($data['program_id'] ?? 0);

$stmt = $pdo->prepare('SELECT id FROM admin_programs WHERE admin_id = ? AND program_id = ?');
$stmt->execute([(int)$admin['id'], $programId]);

if (!$stmt->fetch()) {
    jsonError('Program not found or not managed by this admin', 404);
}

$stmt = $pdo->prepare('UPDATE programs SET status = "deleted" WHERE id = ?');
$stmt->execute([$programId]);

auditLog((int)$admin['id'], 'delete_program', 'program', $programId);

jsonResponse([
    'success' => true,
    'message' => 'Program deleted successfully',
]);
