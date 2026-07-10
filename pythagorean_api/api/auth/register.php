<?php
declare(strict_types=1);

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/security.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method not allowed', 405);
}

$data = getJsonInput();

$fullName = trim($data['full_name'] ?? '');
$email = strtolower(trim($data['email'] ?? ''));
$password = (string)($data['password'] ?? '');
$phone = trim($data['phone'] ?? '');

if ($fullName === '' || $email === '' || strlen($password) < 6) {
    jsonError('Full name, valid email and password with at least 6 characters are required');
}

$pdo = getPDO();

try {
    $passwordData = createPasswordHash($password);

    $stmt = $pdo->prepare('
        INSERT INTO users (full_name, email, password_hash, password_salt, phone, role)
        VALUES (?, ?, ?, ?, ?, "interested")
    ');
    $stmt->execute([
        $fullName,
        $email,
        $passwordData['hash'],
        $passwordData['salt'],
        $phone,
    ]);

    $userId = (int)$pdo->lastInsertId();

    $stmt = $pdo->prepare('INSERT INTO interested_profiles (user_id) VALUES (?)');
    $stmt->execute([$userId]);

    jsonResponse([
        'success' => true,
        'message' => 'Account created successfully',
        'user_id' => $userId,
    ], 201);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        jsonError('Email already exists', 409);
    }
    jsonError('Registration failed', 500, ['debug' => $e->getMessage()]);
}
