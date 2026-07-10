<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

$userId = (int)$user['id'];

function deleteDirectoryRecursive(string $dir): void
{
    if (!is_dir($dir)) {
        return;
    }

    $items = scandir($dir);

    if ($items === false) {
        return;
    }

    foreach ($items as $item) {
        if ($item === '.' || $item === '..') {
            continue;
        }

        $path = $dir . DIRECTORY_SEPARATOR . $item;

        if (is_dir($path)) {
            deleteDirectoryRecursive($path);
        } else {
            if (is_file($path)) {
                unlink($path);
            }
        }
    }

    rmdir($dir);
}

function slugifyName(string $text): string
{
    $text = trim($text);
    $text = mb_strtolower($text, 'UTF-8');

    $greek = [
        'ά' => 'a', 'έ' => 'e', 'ή' => 'i', 'ί' => 'i', 'ό' => 'o', 'ύ' => 'y', 'ώ' => 'o',
        'ϊ' => 'i', 'ϋ' => 'y', 'ΐ' => 'i', 'ΰ' => 'y',
        'α' => 'a', 'β' => 'v', 'γ' => 'g', 'δ' => 'd', 'ε' => 'e', 'ζ' => 'z', 'η' => 'i',
        'θ' => 'th', 'ι' => 'i', 'κ' => 'k', 'λ' => 'l', 'μ' => 'm', 'ν' => 'n', 'ξ' => 'x',
        'ο' => 'o', 'π' => 'p', 'ρ' => 'r', 'σ' => 's', 'ς' => 's', 'τ' => 't', 'υ' => 'y',
        'φ' => 'f', 'χ' => 'ch', 'ψ' => 'ps', 'ω' => 'o',
    ];

    $text = strtr($text, $greek);
    $text = preg_replace('/[^a-z0-9]+/', '_', $text);
    $text = trim($text, '_');

    return $text !== '' ? $text : 'user';
}

$stmt = $pdo->prepare(
    'SELECT id, full_name, profile_photo
     FROM users
     WHERE id = ?
     LIMIT 1'
);
$stmt->execute([$userId]);
$dbUser = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$dbUser) {
    jsonResponse([
        'success' => false,
        'message' => 'User not found'
    ], 404);
}

$projectRoot = realpath(__DIR__ . '/../..');

if ($projectRoot === false) {
    jsonResponse([
        'success' => false,
        'message' => 'Project root not found'
    ], 500);
}

$fullName = $dbUser['full_name'] ?? 'user';
$userFolderName = 'user_' . $userId . '_' . slugifyName($fullName);

$userPhotoDir = $projectRoot
    . DIRECTORY_SEPARATOR . 'uploads'
    . DIRECTORY_SEPARATOR . 'profile_photos'
    . DIRECTORY_SEPARATOR . $userFolderName;

$profilePhoto = $dbUser['profile_photo'] ?? null;

if ($profilePhoto) {
    $profilePhotoPath = $projectRoot . DIRECTORY_SEPARATOR . str_replace(
        ['/', '\\'],
        DIRECTORY_SEPARATOR,
        $profilePhoto
    );

    if (is_file($profilePhotoPath)) {
        unlink($profilePhotoPath);
    }
}

deleteDirectoryRecursive($userPhotoDir);

$pdo->beginTransaction();

try {
    $stmt = $pdo->prepare('DELETE FROM user_tokens WHERE user_id = ?');
    $stmt->execute([$userId]);

    $stmt = $pdo->prepare('DELETE FROM notifications WHERE user_id = ?');
    $stmt->execute([$userId]);

    $stmt = $pdo->prepare('DELETE FROM interested_profiles WHERE user_id = ?');
    $stmt->execute([$userId]);

    $stmt = $pdo->prepare('DELETE FROM participant_profiles WHERE user_id = ?');
    $stmt->execute([$userId]);

    $stmt = $pdo->prepare('DELETE FROM program_applications WHERE user_id = ?');
    $stmt->execute([$userId]);

    $stmt = $pdo->prepare('DELETE FROM users WHERE id = ?');
    $stmt->execute([$userId]);

    $pdo->commit();

    jsonResponse([
        'success' => true,
        'message' => 'Account and user files deleted successfully'
    ]);
} catch (Throwable $e) {
    $pdo->rollBack();

    jsonResponse([
        'success' => false,
        'message' => 'Could not delete account'
    ], 500);
}