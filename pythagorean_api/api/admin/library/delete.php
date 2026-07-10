<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';
require_once __DIR__ . '/../../../helpers/audit.php';

$admin = requireRole(['admin']);
$data = getJsonInput();
$pdo = getPDO();

$id = (int)($data['id'] ?? 0);

if ($id <= 0) {
    jsonError('Invalid resource id', 400);
}

$stmt = $pdo->prepare('SELECT * FROM library_items WHERE id = ? LIMIT 1');
$stmt->execute([$id]);
$item = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$item) {
    jsonError('Library item not found', 404);
}

$stmt = $pdo->prepare('DELETE FROM library_items WHERE id = ?');
$stmt->execute([$id]);

try {
    auditLog((int)$admin['id'], 'delete_library_item', 'library_item', $id);
} catch (Throwable $ignored) {
}

jsonResponse([
    'success' => true,
    'message' => 'Library item deleted successfully',
]);