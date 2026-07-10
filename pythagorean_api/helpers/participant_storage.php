<?php
declare(strict_types=1);

function generateParticipantStorageFolder(): string
{
    return bin2hex(random_bytes(16));
}

function getProjectRootPath(): string
{
    $root = realpath(__DIR__ . '/..');

    if ($root === false) {
        throw new RuntimeException('Project root not found');
    }

    return $root;
}

function getParticipantStorageBasePath(string $storageFolder): string
{
    return getProjectRootPath()
        . DIRECTORY_SEPARATOR . 'uploads'
        . DIRECTORY_SEPARATOR . 'participants'
        . DIRECTORY_SEPARATOR . $storageFolder;
}

function createParticipantStorageFolders(string $storageFolder): void
{
    $basePath = getParticipantStorageBasePath($storageFolder);

    $folders = [
        '',
        'profile',
        'documents',
        'reports',
        'certificates',
        'assessments',
        'reflections',
        'exports',
        'temp',
    ];

    foreach ($folders as $folder) {
        $path = $basePath;

        if ($folder !== '') {
            $path .= DIRECTORY_SEPARATOR . $folder;
        }

        if (!is_dir($path)) {
            if (!mkdir($path, 0755, true)) {
                throw new RuntimeException('Could not create participant folder: ' . $path);
            }
        }
    }
}

function deleteParticipantStorageFolder(?string $storageFolder): void
{
    if ($storageFolder === null || trim($storageFolder) === '') {
        return;
    }

    $basePath = getParticipantStorageBasePath($storageFolder);

    deleteDirectoryRecursive($basePath);
}

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
        } elseif (is_file($path)) {
            unlink($path);
        }
    }

    rmdir($dir);
}