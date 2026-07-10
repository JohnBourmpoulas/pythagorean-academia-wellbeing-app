<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();

$status = $_GET['status'] ?? null;

$sql = '
    SELECT
        pa.id AS application_id,
        pa.status,
        pa.submitted_at,
        pa.reviewed_at,
        u.id AS user_id,
        u.full_name,
        u.email,
        u.phone,
        p.id AS program_id,
        p.title,
        p.short_title,
        ip.age,
        ip.profession,
        ip.goals
    FROM program_applications pa
    INNER JOIN users u ON u.id = pa.user_id
    INNER JOIN programs p ON p.id = pa.program_id
    LEFT JOIN interested_profiles ip ON ip.user_id = u.id
    INNER JOIN admin_programs ap ON ap.program_id = p.id
    WHERE ap.admin_id = ?
';

$params = [(int)$admin['id']];

if ($status) {
    $sql .= ' AND pa.status = ?';
    $params[] = $status;
}

$sql .= ' ORDER BY pa.submitted_at DESC';

$stmt = $pdo->prepare($sql);
$stmt->execute($params);

jsonResponse([
    'success' => true,
    'applications' => $stmt->fetchAll(),
]);
