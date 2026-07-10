<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../helpers/auth.php';

$user = currentUser();
$pdo = getPDO();

if (($user['role'] ?? '') !== 'participant') {
    jsonError('Only participants can generate documents', 403);
}

$data = getJsonInput();

$userId = (int)$user['id'];
$months = (int)($data['months'] ?? 1);

if (!in_array($months, [1, 3, 6, 12], true)) {
    jsonError('Invalid period. Use 1, 3, 6 or 12 months.', 400);
}

$periodLabel = match ($months) {
    1 => 'Last 1 Month',
    3 => 'Last 3 Months',
    6 => 'Last 6 Months',
    12 => 'Last 12 Months',
};

$stmt = $pdo->prepare('
    SELECT
        pp.id AS participant_profile_id,
        pp.current_week,
        pp.total_weeks,
        pp.wellness_score,
        pp.progress_percent,
        pp.status,
        pp.start_date,
        pp.joined_at,
        u.full_name,
        u.email,
        p.title AS program_title
    FROM participant_profiles pp
    INNER JOIN users u ON u.id = pp.user_id
    INNER JOIN programs p ON p.id = pp.program_id
    WHERE pp.user_id = ?
      AND pp.status = "active"
    ORDER BY pp.id DESC
    LIMIT 1
');
$stmt->execute([$userId]);
$profile = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$profile) {
    jsonError('Participant profile not found', 404);
}

$participantProfileId = (int)$profile['participant_profile_id'];

$stmt = $pdo->prepare('
    SELECT
        COUNT(*) AS total_tasks,
        COALESCE(SUM(CASE WHEN status = "completed" THEN 1 ELSE 0 END), 0) AS completed_tasks
    FROM daily_tasks
    WHERE participant_id = ?
      AND task_date >= DATE_SUB(CURDATE(), INTERVAL ? MONTH)
');
$stmt->execute([$participantProfileId, $months]);
$tasks = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];

$totalTasks = (int)($tasks['total_tasks'] ?? 0);
$completedTasks = (int)($tasks['completed_tasks'] ?? 0);

$stmt = $pdo->prepare('
    SELECT
        mood,
        notes,
        what_went_well,
        challenges,
        improvement_notes,
        stress_level,
        created_at
    FROM reflections
    WHERE participant_id = ?
      AND created_at >= DATE_SUB(NOW(), INTERVAL ? MONTH)
    ORDER BY created_at DESC
    LIMIT 50
');
$stmt->execute([$participantProfileId, $months]);
$reflections = $stmt->fetchAll(PDO::FETCH_ASSOC);

$title = 'Wellness Progress Report';
$createdAt = date('Y-m-d H:i:s');

$lines = [];

$lines[] = $title;
$lines[] = '';
$lines[] = 'Generated at: ' . $createdAt;
$lines[] = 'Period: ' . $periodLabel;
$lines[] = '';
$lines[] = 'Participant';
$lines[] = 'Name: ' . ($profile['full_name'] ?? '-');
$lines[] = 'Email: ' . ($profile['email'] ?? '-');
$lines[] = '';
$lines[] = 'Program';
$lines[] = 'Program: ' . ($profile['program_title'] ?? '-');
$lines[] = 'Current Week: ' . ($profile['current_week'] ?? '-') . ' of ' . ($profile['total_weeks'] ?? '-');
$lines[] = 'Progress: ' . ($profile['progress_percent'] ?? '0') . '%';
$lines[] = 'Wellness Score: ' . ($profile['wellness_score'] ?? '0');
$lines[] = 'Status: ' . ($profile['status'] ?? '-');
$lines[] = 'Start Date: ' . ($profile['start_date'] ?? '-');
$lines[] = '';
$lines[] = 'Tasks';
$lines[] = 'Completed Tasks: ' . $completedTasks;
$lines[] = 'Total Tasks: ' . $totalTasks;
$lines[] = '';
$lines[] = 'Recent Reflections';

if (empty($reflections)) {
    $lines[] = 'No reflections found for this period.';
} else {
    foreach ($reflections as $reflection) {
        $lines[] = '';
        $lines[] = 'Date: ' . ($reflection['created_at'] ?? '-');
        $lines[] = 'Mood: ' . ($reflection['mood'] ?? '-');
        $lines[] = 'Stress Level: ' . ($reflection['stress_level'] ?? '-');
        $lines[] = 'Notes: ' . ($reflection['notes'] ?? '-');
        $lines[] = 'What Went Well: ' . ($reflection['what_went_well'] ?? '-');
        $lines[] = 'Challenges: ' . ($reflection['challenges'] ?? '-');
        $lines[] = 'Improvement Notes: ' . ($reflection['improvement_notes'] ?? '-');
    }
}

function pdfEscape(string $text): string {
    $text = str_replace(["\\", "(", ")"], ["\\\\", "\\(", "\\)"], $text);
    $text = preg_replace('/[^\x20-\x7E]/', '', $text);
    return $text ?? '';
}

$pdfLines = [];
$y = 815;
$pageFontSize = 15;
$lineHeight = 22;

foreach ($lines as $line) {
    $pdfLines[] = 'BT /F1 ' . $pageFontSize . ' Tf 40 ' . $y . ' Td (' . pdfEscape($line) . ') Tj ET';
    $y -= $lineHeight;

    if ($y < 60) {
        break;
    }
}

$content = implode("\n", $pdfLines);

$pdf = "%PDF-1.4\n";

$objects = [];

$objects[] = "<< /Type /Catalog /Pages 2 0 R >>";
$objects[] = "<< /Type /Pages /Kids [3 0 R] /Count 1 >>";
$objects[] = "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>";
$objects[] = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>";
$objects[] = "<< /Length " . strlen($content) . " >>\nstream\n" . $content . "\nendstream";

$offsets = [0];

foreach ($objects as $i => $object) {
    $offsets[] = strlen($pdf);
    $pdf .= ($i + 1) . " 0 obj\n" . $object . "\nendobj\n";
}

$xrefPosition = strlen($pdf);

$pdf .= "xref\n";
$pdf .= "0 " . (count($objects) + 1) . "\n";
$pdf .= "0000000000 65535 f \n";

for ($i = 1; $i <= count($objects); $i++) {
    $pdf .= str_pad((string)$offsets[$i], 10, '0', STR_PAD_LEFT) . " 00000 n \n";
}

$pdf .= "trailer\n";
$pdf .= "<< /Size " . (count($objects) + 1) . " /Root 1 0 R >>\n";
$pdf .= "startxref\n";
$pdf .= $xrefPosition . "\n";
$pdf .= "%%EOF";

$baseDir = dirname(__DIR__, 3) . '/uploads/participant_documents';

if (!is_dir($baseDir)) {
    mkdir($baseDir, 0775, true);
}

$userDir = $baseDir . '/user_' . $userId;

if (!is_dir($userDir)) {
    mkdir($userDir, 0775, true);
}

$fileName = 'wellness_report_' . $participantProfileId . '_' . $months . 'm_' . time() . '.pdf';
$filePath = $userDir . '/' . $fileName;

file_put_contents($filePath, $pdf);

$relativePath = 'uploads/participant_documents/user_' . $userId . '/' . $fileName;

$stmt = $pdo->prepare('
    INSERT INTO participant_documents
        (
            participant_profile_id,
            user_id,
            title,
            document_type,
            period_label,
            period_months,
            file_path
        )
    VALUES
        (?, ?, ?, "progress_report", ?, ?, ?)
');

$stmt->execute([
    $participantProfileId,
    $userId,
    $title . ' - ' . $periodLabel,
    $periodLabel,
    $months,
    $relativePath,
]);

jsonResponse([
    'success' => true,
    'message' => 'Document generated successfully',
    'document' => [
        'id' => (int)$pdo->lastInsertId(),
        'title' => $title . ' - ' . $periodLabel,
        'document_type' => 'progress_report',
        'period_label' => $periodLabel,
        'period_months' => $months,
        'file_path' => $relativePath,
        'created_at' => $createdAt,
    ],
]);