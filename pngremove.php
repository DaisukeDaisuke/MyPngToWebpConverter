<?php
declare(strict_types=1);

/**
 * png と webp を比較し、1行出力で削減量を表示
 * webp が小さい場合のみ png を削除
 * 対象ディレクトリは realpath で固定
 */

$input   = $argv[1] ?? '.';
$realDir = realpath($input);

if ($realDir === false || !is_dir($realDir)) {
	fwrite(STDERR, "無効なディレクトリです: {$input}\n");
	exit(1);
}

function formatSize(int $bytes): string {
	if ($bytes >= 1024 * 1024) {
		return round($bytes / (1024 * 1024), 2) . ' MB';
	}
	return round($bytes / 1024, 2) . ' KB';
}

$pngFiles  = [];
$webpFiles = [];

/* ファイル収集（realpath 配下のみ） */
foreach (scandir($realDir) as $file) {
	if ($file === '.' || $file === '..') {
		continue;
	}

	$path = $realDir . DIRECTORY_SEPARATOR . $file;
	if (!is_file($path)) {
		continue;
	}

	$ext  = strtolower(pathinfo($file, PATHINFO_EXTENSION));
	$base = pathinfo($file, PATHINFO_FILENAME);

	if ($ext === 'png') {
		$pngFiles[$base] = $path;
	} elseif ($ext === 'webp') {
		$webpFiles[$base] = $path;
	}
}

$totalPngSize  = 0;
$totalWebpSize = 0;
$totalSaved    = 0;
$processed     = 0;
$deleted       = 0;

foreach ($pngFiles as $base => $pngPath) {
	if (!isset($webpFiles[$base])) {
		continue;
	}

	$webpPath = $webpFiles[$base];

	$pngSize  = filesize($pngPath);
	$webpSize = filesize($webpPath);

	if ($pngSize === false || $webpSize === false) {
		continue;
	}

	$totalPngSize  += $pngSize;
	$totalWebpSize += $webpSize;

	$diff = $pngSize - $webpSize;
	$rate = ($pngSize > 0)
		? round(($diff / $pngSize) * 100, 2)
		: 0.0;

	if ($diff > 0) {
		unlink($pngPath);
		$totalSaved += $diff;
		$deleted++;
	}

	echo sprintf(
		"%s | png: %s | webp: %s | saved: %s (%.2f%%)\n",
		$base,
		formatSize($pngSize),
		formatSize($webpSize),
		formatSize(max(0, $diff)),
		max(0, $rate)
	);

	$processed++;
}

/* 全体削減率 */
$overallRate = ($totalPngSize > 0)
	? round((($totalPngSize - $totalWebpSize) / $totalPngSize) * 100, 2)
	: 0.0;

echo "\n";
echo "-----------------------------\n";
echo "処理ディレクトリ : {$realDir}\n";
echo "処理ペア数       : {$processed}\n";
echo "png 削除数       : {$deleted}\n";
echo "総 png サイズ    : " . formatSize($totalPngSize) . "\n";
echo "総 webp サイズ   : " . formatSize($totalWebpSize) . "\n";
echo "総削減量         : " . formatSize($totalSaved) . "\n";
echo "全体削減率       : {$overallRate}%\n";
