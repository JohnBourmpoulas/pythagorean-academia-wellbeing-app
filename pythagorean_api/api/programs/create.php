<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';
require_once __DIR__ . '/../../helpers/audit.php';

$admin = requireRole(['admin']);
$data = getJsonInput();
$pdo = getPDO();

$title = trim($data['title'] ?? '');
$shortTitle = trim($data['short_title'] ?? '');
$description = trim($data['description'] ?? '');
$durationWeeks = (int)($data['duration_weeks'] ?? 0);
$maxParticipants = isset($data['max_participants']) ? (int)$data['max_participants'] : null;
$categoryId = isset($data['category_id']) ? (int)$data['category_id'] : null;

if ($title === '' || $shortTitle === '' || $description === '' || $durationWeeks <= 0) {
    jsonError('Title, short title, description and duration are required');
}

$pdo->beginTransaction();

try {
    $stmt = $pdo->prepare('
        INSERT INTO programs (category_id, created_by_admin_id, title, short_title, description, duration_weeks, max_participants, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, "active")
    ');
    $stmt->execute([
        $categoryId,
        (int)$admin['id'],
        $title,
        $shortTitle,
        $description,
        $durationWeeks,
        $maxParticipants,
    ]);

    $programId = (int)$pdo->lastInsertId();

    $stmt = $pdo->prepare('INSERT INTO admin_programs (admin_id, program_id) VALUES (?, ?)');
    $stmt->execute([(int)$admin['id'], $programId]);

    auditLog((int)$admin['id'], 'create_program', 'program', $programId, ['title' => $title]);

    $pdo->commit();

    jsonResponse([
        'success' => true,
        'message' => 'Program created successfully',
        'program_id' => $programId,
    ], 201);
} catch (Throwable $e) {
    $pdo->rollBack();
    jsonError('Could not create program', 500, ['debug' => $e->getMessage()]);
}
