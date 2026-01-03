[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# スクリプト自身の場所
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WorkDir   = Join-Path $ScriptDir "work"

if (-not (Test-Path -LiteralPath $WorkDir)) {
    Write-Error "work ディレクトリが存在しません: $WorkDir"
    exit 1
}

# png 一覧取得（日本語 OK）
$files = Get-ChildItem -LiteralPath $WorkDir -Filter *.png -File
$total = $files.Count

if ($total -eq 0) {
    Write-Host "png ファイルが存在しません"
    exit 0
}

$startTime = Get-Date
$index = 0
$barWidth = 30

foreach ($png in $files) {
    $index++

    # CreationTime を使用
    $baseName = $png.LastWriteTime.ToString("yyyyMMdd_HHmmss")
    $target   = Join-Path $WorkDir ($baseName + ".png")

    # 衝突回避
    $i = 1
    while (Test-Path -LiteralPath $target) {
        $target = Join-Path $WorkDir ("{0}_{1}.png" -f $baseName, $i)
        $i++
    }

    Rename-Item -LiteralPath $png.FullName -NewName (Split-Path $target -Leaf)

    # ---- 進捗計算 ----
    $elapsed = (Get-Date) - $startTime
    $avgSec  = $elapsed.TotalSeconds / $index
    $remain  = [math]::Max(0, [int](($total - $index) * $avgSec))

    $percent = [int](($index / $total) * 100)
    $filled  = [int](($barWidth * $index) / $total)
    $empty   = $barWidth - $filled

    $bar = ('#' * $filled) + ('.' * $empty)

    Write-Host -NoNewline "`rrename: [$bar] $percent% ($index/$total) ETA ${remain}s   `r"
}