<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/response.php';
require_once __DIR__ . '/security.php';

function createUserToken(int $userId): string {
    $pdo = getPDO();
    $plainToken = createPlainToken();
    $tokenHash = hashToken($plainToken);
    $expiresAt = (new DateTime('+' . TOKEN_TTL_HOURS . ' hours'))->format('Y-m-d H:i:s');

    $stmt = $pdo->prepare('
        INSERT INTO user_tokens (user_id, token_hash, expires_at)
        VALUES (?, ?, ?)
    ');
    $stmt->execute([$userId, $tokenHash, $expiresAt]);

    return $plainToken;
}

function getBearerToken(): ?string {
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (preg_match('/Bearer\s+(.+)/', $authHeader, $matches)) {
        return trim($matches[1]);
    }

    return null;
}

function currentUser(): array {
    $token = getBearerToken();

    if (!$token) {
        jsonError('Missing authorization token', 401);
    }

    $pdo = getPDO();
    $tokenHash = hashToken($token);

    $stmt = $pdo->prepare('
        SELECT u.*
        FROM user_tokens t
        INNER JOIN users u ON u.id = t.user_id
        WHERE t.token_hash = ?
          AND t.revoked_at IS NULL
          AND t.expires_at > NOW()
          AND u.status = "active"
        LIMIT 1
    ');
    $stmt->execute([$tokenHash]);
    $user = $stmt->fetch();

    if (!$user) {
        jsonError('Invalid or expired token', 401);
    }

    return $user;
}

function requireRole(array $roles): array {
    $user = currentUser();

    if (!in_array($user['role'], $roles, true)) {
        jsonError('Forbidden: insufficient permissions', 403);
    }

    return $user;
}
