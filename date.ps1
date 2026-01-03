# スクリプト自身の場所
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WorkDir   = Join-Path $ScriptDir "work"

Set-Location $WorkDir

# png を列挙（日本語OK）
Get-ChildItem -LiteralPath . -Filter *.png -File | ForEach-Object {
    $png  = $_
    $webp = [System.IO.Path]::ChangeExtension($png.FullName, ".webp")

    if (Test-Path -LiteralPath $webp) {
        $dst = Get-Item -LiteralPath $webp

        # 日時コピー
        $dst.CreationTime  = $png.CreationTime
        $dst.LastWriteTime = $png.LastWriteTime

        # png 削除
        Remove-Item -LiteralPath $png.FullName -Force
    }
}
