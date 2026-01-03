@echo off
setlocal
chcp 65001 >nul

powershell -ExecutionPolicy Bypass -File %~dp0rename_png_to_datetime.ps1 %
docker run --rm -v "%cd%/work.sh:/work/work.sh" -v "%cd%/work:/work" imgtest sh /work/work.sh
powershell -ExecutionPolicy Bypass -File %~dp0sync_time.ps1 %
php pngremove.php ./work
pause
