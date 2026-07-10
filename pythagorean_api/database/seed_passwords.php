<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/security.php';

$pdo = getPDO();

$users = [
    ['admin@pythagorean.gr', 'admin123'],
    ['manager@pythagorean.gr', 'manager123'],
];

foreach ($users as [$email, $password]) {
    $passwordData = createPasswordHash($password);

    $stmt = $pdo->prepare('
        UPDATE users
        SET password_hash = ?, password_salt = ?
        WHERE email = ?
    ');
    $stmt->execute([
        $passwordData['hash'],
        $passwordData['salt'],
        $email,
    ]);

    echo "Updated password for {$email}\n";
}
