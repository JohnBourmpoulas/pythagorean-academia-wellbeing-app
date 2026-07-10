<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);
$pdo = getPDO();
$data = getJsonInput();

$programId = (int)($data['program_id'] ?? 0);
$dayNumber = (int)($data['day_number'] ?? 1);
$orderIndex = (int)($data['order_index'] ?? 0);
$title = trim((string)($data['title'] ?? ''));
$description = trim((string)($data['description'] ?? ''));
$taskType = trim((string)($data['task_type'] ?? 'custom'));
$libraryItemId = isset($data['library_item_id']) && $data['library_item_id'] !== ''
    ? (int)$data['library_item_id']
    : null;
$durationMinutes = isset($data['duration_minutes']) && $data['duration_minutes'] !== ''
    ? (int)$data['duration_minutes']
    : null;
$points = (int)($data['points'] ?? 10);
$instructions = trim((string)($data['instructions'] ?? ''));
$isRequired = (int)($data['is_required'] ?? 1);

if ($programId <= 0) {
    jsonError('Invalid program id', 400);
}

if ($title === '') {
    jsonError('Title is required', 400);
}

$stmt = $pdo->prepare('
    INSERT INTO program_daily_tasks
        (
            program_id,
            day_number,
            order_index,
            title,
            description,
            task_type,
            library_item_id,
            duration_minutes,
            points,
            instructions,
            is_required,
            created_by
        )
    VALUES
        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
');

$stmt->execute([
    $programId,
    $dayNumber,
    $orderIndex,
    $title,
    $description,
    $taskType,
    $libraryItemId,
    $durationMinutes,
    $points,
    $instructions,
    $isRequired,
    (int)$admin['id'],
]);

jsonResponse([
    'success' => true,
    'message' => 'Task created successfully',
    'id' => (int)$pdo->lastInsertId(),
]);