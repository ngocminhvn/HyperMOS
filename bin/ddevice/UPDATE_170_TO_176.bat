@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title HyperMOS EU HAOTIAN #170 to #176 - Dirty Flash
echo.
echo ========================================================
echo  HyperMOS EU #170 to #176 - non-wiping image update
echo  Connect the HAOTIAN phone in BOOTLOADER FASTBOOT mode.
echo ========================================================
echo.
where powershell.exe >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Windows PowerShell is required.
    pause
    exit /b 1
)
if not exist "%~dp0UPDATE_170_TO_176.ps1" (
    echo [ERROR] UPDATE_170_TO_176.ps1 is missing.
    pause
    exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0UPDATE_170_TO_176.ps1"
set "EXIT_CODE=%ERRORLEVEL%"
echo.
if not "%EXIT_CODE%"=="0" (
    echo [FAILED] Fastboot update stopped. Read the error above.
    echo If any IMG was already flashed, restore matching #170
    echo partitions instead of blindly repeating a partial flash.
) else (
    echo [DONE] Flashing completed without formatting userdata.
)
pause
exit /b %EXIT_CODE%
