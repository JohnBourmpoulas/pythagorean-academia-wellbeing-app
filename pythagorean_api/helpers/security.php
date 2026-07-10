<?php
declare(strict_types=1);

function createPasswordHash(string $password): array {
    $salt = bin2hex(random_bytes(32));
    $hash = hash_pbkdf2('sha512', $password, $salt, 100000, 128);
    return [
        'hash' => $hash,
        'salt' => $salt,
    ];
}

function verifyPassword(string $password, string $storedHash, string $storedSalt): bool {
    $hash = hash_pbkdf2('sha512', $password, $storedSalt, 100000, 128);
    return hash_equals($storedHash, $hash);
}

function createPlainToken(): string {
    return bin2hex(random_bytes(48));
}

function hashToken(string $token): string {
    return hash('sha512', $token);
}
