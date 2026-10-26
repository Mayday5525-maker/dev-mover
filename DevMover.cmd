@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
echo ================================================================
echo   Dev Mover v1.0.0 - portable edition
echo   Move TRAE CN / WorkBuddy / VS Code / Claude Code data
echo   off a full drive to another disk
echo ================================================================
echo.
echo  IMPORTANT: fully quit the target apps first
echo  (including their system tray icons).
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev-mover.ps1" -Interactive %*
set EXITCODE=%ERRORLEVEL%
echo.
if "%EXITCODE%"=="0" (
  echo [OK] Done. You can start the apps again.
) else (
  echo [NOT OK] See the messages above. Your data was NOT deleted;
  echo backups and logs are kept on the target drive.
)
echo.
pause
exit /b %EXITCODE%
