Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# スクリプト自身の場所（realpath）
$ScriptDir = Resolve-Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
$WorkDir   = Join-Path $ScriptDir "work"

if (-not (Test-Path -LiteralPath $WorkDir)) {
    throw "work ディレクトリが存在しません: $WorkDir"
}

# png 一覧取得（work 直下のみ）
$pngFiles = Get-ChildItem -LiteralPath $WorkDir -Filter *.png -File
$total = $pngFiles.Count
if ($total -eq 0) {
    return
}

$index = 0

foreach ($png in $pngFiles) {
    $index++

    $base = [System.IO.Path]::GetFileNameWithoutExtension($png.Name)
    $webpPath = Join-Path $WorkDir ($base + ".webp")

    if (Test-Path -LiteralPath $webpPath) {
        $webp = Get-Item -LiteralPath $webpPath

        # PNG の更新日時を基準
        $time = $png.LastWriteTime

        # WebP に同期
        $webp.LastWriteTime = $time
        $webp.CreationTime = $time
    }

    # ---- 進捗表示 ----
    $percent = [int](($index * 100) / $total)
    Write-Host -NoNewline "`rsync: $index/$total ($percent%)"
}

Write-Host ""
