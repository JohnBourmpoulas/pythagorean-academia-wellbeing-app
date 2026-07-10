<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';

function auditLog(?int $userId, string $action, ?string $entityType = null, ?int $entityId = null, array $details = []): void {
    $pdo = getPDO();
    $stmt = $pdo->prepare('
        INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details)
        VALUES (?, ?, ?, ?, ?)
    ');
    $stmt->execute([
        $userId,
        $action,
        $entityType,
        $entityId,
        json_encode($details, JSON_UNESCAPED_UNICODE),
    ]);
}
