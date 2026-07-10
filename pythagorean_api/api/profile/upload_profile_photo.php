<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (!isset($_FILES['profile_photo'])) {
    jsonResponse([
        'success' => false,
        'message' => 'No file uploaded'
    ], 400);
}

$file = $_FILES['profile_photo'];

if ($file['error'] !== UPLOAD_ERR_OK) {
    jsonResponse([
        'success' => false,
        'message' => 'Upload error'
    ], 400);
}

$maxSize = 3 * 1024 * 1024;

if ($file['size'] > $maxSize) {
    jsonResponse([
        'success' => false,
        'message' => 'File is too large. Maximum size is 3MB.'
    ], 400);
}

$allowedTypes = [
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
];

$mimeType = mime_content_type($file['tmp_name']);

if (!isset($allowedTypes[$mimeType])) {
    jsonResponse([
        'success' => false,
        'message' => 'Invalid image type. Allowed: JPG, PNG, WEBP.'
    ], 400);
}

$extension = $allowedTypes[$mimeType];

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

$userId = (int)$user['id'];
$fullName = $user['full_name'] ?? 'user';

$userFolderName = 'user_' . $userId . '_' . slugifyName($fullName);

$projectRoot = realpath(__DIR__ . '/../..');

if ($projectRoot === false) {
    jsonResponse([
        'success' => false,
        'message' => 'Project root not found'
    ], 500);
}

$uploadsRoot = $projectRoot . DIRECTORY_SEPARATOR . 'uploads';
$profilePhotosRoot = $uploadsRoot . DIRECTORY_SEPARATOR . 'profile_photos';
$userUploadDir = $profilePhotosRoot . DIRECTORY_SEPARATOR . $userFolderName;

if (!is_dir($uploadsRoot)) {
    if (!mkdir($uploadsRoot, 0755, true)) {
        jsonResponse([
            'success' => false,
            'message' => 'Could not create uploads folder'
        ], 500);
    }
}

if (!is_dir($profilePhotosRoot)) {
    if (!mkdir($profilePhotosRoot, 0755, true)) {
        jsonResponse([
            'success' => false,
            'message' => 'Could not create profile_photos folder'
        ], 500);
    }
}

if (!is_dir($userUploadDir)) {
    if (!mkdir($userUploadDir, 0755, true)) {
        jsonResponse([
            'success' => false,
            'message' => 'Could not create user upload folder'
        ], 500);
    }
}

$stmt = $pdo->prepare('SELECT profile_photo FROM users WHERE id = ? LIMIT 1');
$stmt->execute([$userId]);
$oldPhoto = $stmt->fetchColumn();

if ($oldPhoto) {
    $oldAbsolutePath = $projectRoot . DIRECTORY_SEPARATOR . str_replace(
        ['/', '\\'],
        DIRECTORY_SEPARATOR,
        $oldPhoto
    );

    if (is_file($oldAbsolutePath)) {
        unlink($oldAbsolutePath);
    }
}

$fileName = 'profile_' . time() . '.' . $extension;

$absolutePath = $userUploadDir . DIRECTORY_SEPARATOR . $fileName;

$relativePath = 'uploads/profile_photos/' . $userFolderName . '/' . $fileName;

if (!move_uploaded_file($file['tmp_name'], $absolutePath)) {
    jsonResponse([
        'success' => false,
        'message' => 'Could not save image'
    ], 500);
}

$stmt = $pdo->prepare('UPDATE users SET profile_photo = ? WHERE id = ?');
$stmt->execute([$relativePath, $userId]);

jsonResponse([
    'success' => true,
    'message' => 'Profile photo uploaded successfully',
    'profile_photo' => $relativePath,
]);