@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
echo Starting Dev Mover GUI...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0DevMover-GUI.ps1" %*
if errorlevel 1 pause
