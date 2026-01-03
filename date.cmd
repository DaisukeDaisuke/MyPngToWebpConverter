@echo off
setlocal
chcp 65001 >nul

powershell -ExecutionPolicy Bypass -File %~dp0date.ps1 %
pause