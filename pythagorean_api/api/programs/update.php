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

$title = trim($data['title'] ?? '');
$shortTitle = trim($data['short_title'] ?? '');
$description = trim($data['description'] ?? '');
$durationWeeks = (int)($data['duration_weeks'] ?? 0);
$maxParticipants = isset($data['max_participants']) ? (int)$data['max_participants'] : null;
$status = $data['status'] ?? 'active';

if (!in_array($status, ['active', 'inactive', 'deleted'], true)) {
    jsonError('Invalid status');
}

if ($title === '' || $shortTitle === '' || $description === '' || $durationWeeks <= 0) {
    jsonError('Title, short title, description and duration are required');
}

$stmt = $pdo->prepare('
    UPDATE programs
    SET title = ?, short_title = ?, description = ?, duration_weeks = ?, max_participants = ?, status = ?
    WHERE id = ?
');
$stmt->execute([
    $title,
    $shortTitle,
    $description,
    $durationWeeks,
    $maxParticipants,
    $status,
    $programId,
]);

auditLog((int)$admin['id'], 'update_program', 'program', $programId, ['title' => $title]);

jsonResponse([
    'success' => true,
    'message' => 'Program updated successfully',
]);
