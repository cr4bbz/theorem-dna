@echo off
setlocal
title Theorem DNA - Full Verification

echo Starting full Theorem DNA verification...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0verify.ps1" -Mode full
set "RESULT=%ERRORLEVEL%"

echo.
if "%RESULT%"=="0" (
  color 2F
  echo ALL CHECKS PASSED
) else (
  color 4F
  echo ONE OR MORE CHECKS FAILED
)

if exist "%~dp0..\verification-reports\last-report.html" (
  echo.
  echo Opening verification report...
  start "" "%~dp0..\verification-reports\last-report.html"
)

echo.
pause
exit /b %RESULT%
