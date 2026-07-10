<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$admin = requireRole(['admin']);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Invalid request method', 405);
}

$type = strtolower(trim($_POST['type'] ?? 'file'));

$allowedTypes = ['image', 'video', 'audio', 'pdf', 'file'];

if (!in_array($type, $allowedTypes, true)) {
    jsonError('Invalid upload type', 400);
}

if (!isset($_FILES['file'])) {
    jsonError('No file uploaded', 400);
}

$file = $_FILES['file'];

if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
    jsonError('Upload failed', 400);
}

$originalName = basename((string)$file['name']);
$extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

$allowedExtensions = [
    'image' => ['jpg', 'jpeg', 'png', 'webp'],
    'video' => ['mp4', 'mov', 'webm'],
    'audio' => ['mp3', 'wav', 'm4a'],
    'pdf' => ['pdf'],
    'file' => ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov', 'webm', 'mp3', 'wav', 'm4a', 'pdf'],
];

if (!in_array($extension, $allowedExtensions[$type], true)) {
    jsonError('File type not allowed', 400);
}

$baseUploadDir = dirname(__DIR__, 3) . '/uploads/library';
$relativeBase = 'uploads/library';

if (!is_dir($baseUploadDir)) {
    mkdir($baseUploadDir, 0775, true);
}

$typeDir = $baseUploadDir . '/' . $type;

if (!is_dir($typeDir)) {
    mkdir($typeDir, 0775, true);
}

$safeName = preg_replace('/[^a-zA-Z0-9_\.-]/', '_', pathinfo($originalName, PATHINFO_FILENAME));
$filename = $safeName . '_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $extension;

$targetPath = $typeDir . '/' . $filename;
$relativePath = $relativeBase . '/' . $type . '/' . $filename;

if (!move_uploaded_file($file['tmp_name'], $targetPath)) {
    jsonError('Could not save uploaded file', 500);
}

jsonResponse([
    'success' => true,
    'message' => 'File uploaded successfully',
    'file_path' => $relativePath,
    'original_name' => $originalName,
]);