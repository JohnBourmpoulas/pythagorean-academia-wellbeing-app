<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$stmt = $pdo->query('SELECT COUNT(*) AS total FROM users WHERE role != "admin"');
$totalUsers = (int)$stmt->fetch()['total'];

$stmt = $pdo->prepare('
    SELECT COUNT(*) AS total
    FROM program_applications pa
    INNER JOIN admin_programs ap ON ap.program_id = pa.program_id
    WHERE ap.admin_id = ? AND pa.status = "pending"
');
$stmt->execute([(int)$admin['id']]);
$pendingApplications = (int)$stmt->fetch()['total'];

$stmt = $pdo->prepare('
    SELECT COUNT(*) AS total
    FROM programs p
    INNER JOIN admin_programs ap ON ap.program_id = p.id
    WHERE ap.admin_id = ? AND p.status = "active"
');
$stmt->execute([(int)$admin['id']]);
$activePrograms = (int)$stmt->fetch()['total'];

jsonResponse([
    'success' => true,
    'stats' => [
        'total_users' => $totalUsers,
        'pending_applications' => $pendingApplications,
        'active_programs' => $activePrograms,
    ],
]);
