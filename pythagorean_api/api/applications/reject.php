<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';
require_once __DIR__ . '/../../helpers/audit.php';

$admin = requireRole(['admin']);
$data = getJsonInput();
$pdo = getPDO();

$applicationId = (int)($data['application_id'] ?? 0);
$notes = trim($data['admin_notes'] ?? '');

$stmt = $pdo->prepare('
    UPDATE program_applications pa
    INNER JOIN admin_programs ap ON ap.program_id = pa.program_id
    SET pa.status = "rejected",
        pa.reviewed_by_admin_id = ?,
        pa.reviewed_at = NOW(),
        pa.admin_notes = ?
    WHERE pa.id = ? AND ap.admin_id = ? AND pa.status = "pending"
');
$stmt->execute([(int)$admin['id'], $notes, $applicationId, (int)$admin['id']]);

if ($stmt->rowCount() === 0) {
    jsonError('Pending application not found', 404);
}

auditLog((int)$admin['id'], 'reject_application', 'program_application', $applicationId);

jsonResponse([
    'success' => true,
    'message' => 'Application rejected',
]);
