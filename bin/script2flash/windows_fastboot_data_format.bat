@echo off&setlocal enabledelayedexpansion
title HyperOS Flash ROM - First Install (Format Data)
cd %~dp0
set fastboot=META-INF\fastboot
set /p DeviceCodeRom=<META-INF\Data\DeviceCode

echo =======================================================
echo      HyperOS Custom ROM - First Install (Format Data)
echo =======================================================
echo.
echo Waiting for device...

:check_device
!fastboot! devices | findstr /r ".*fastboot" >nul
if errorlevel 1 (
    timeout /t 2 >nul
    goto check_device
)

echo Detecting device...
for /f "tokens=2" %%a in ('!fastboot! getvar product 2^>^&1 ^| findstr /l /b /c:"product:"') do set DeviceCodeReal=%%a
for /f "tokens=2" %%a in ('!fastboot! getvar slot-count 2^>^&1 ^| findstr /l /b /c:"slot-count:"') do set fqlx=%%a
if "!fqlx!" == "2" (set fqlx=AB)  else (set fqlx=A)

if "!DeviceCodeReal!" == "mars" set DeviceCodeReal=star

echo Your device: !DeviceCodeReal!

echo !DeviceCodeReal! | findstr /b /c:"!DeviceCodeRom!"  >nul 2>nul 
if errorlevel 1 (
    echo ERROR: This ROM is only for !DeviceCodeRom!.
    echo Detected: !DeviceCodeReal!
    pause
    exit /B 1
)

echo Compatible device: !DeviceCodeRom!
echo.
echo =======================================================
echo WARNING: Your device will be flashed and the DATA
echo partition will be FORMATTED.
echo You WILL LOSE all your apps, settings and files!
echo =======================================================
set /p CHOICE="Do you want to continue with data format? [y/N]: "
if /i "%CHOICE%" neq "y" exit /B 0

echo.
echo ##############################################################
echo Please wait. Do not disconnect the cable until flashing is complete.
echo ##############################################################
echo.

for /f %%i in ('dir /b *.img.zst') do (
 	set par=%%i
 	set par=!par:.img.zst=!
 	del /s /q !par!.img >nul 2>nul 
 	echo  Extracting !par! ...
   	META-INF\zstd -d !par!.img.zst -o !par!.img
)

echo.
echo Flashing partitions...

for /f %%i in ('dir /b images') do (
	set par=%%~ni
	set url=images\%%i
	if !par! == cust ( 
		!fastboot! flash !par! !url!  >nul 2>nul 
	) else if !par! == preloader_raw (
		!fastboot! flash preloader_a !url! >nul 2>nul 
		!fastboot! flash preloader_b !url! >nul 2>nul 
		!fastboot! flash preloader1 !url! >nul 2>nul 
		!fastboot! flash preloader2 !url! >nul 2>nul 
	) else if !fqlx! == AB ( 
		!fastboot! flash !par!_a !url!
		!fastboot! flash !par!_b !url!
	) else ( 
		!fastboot! flash !par! !url!
	)
)

if exist super.img (
        echo Flashing super...
        !fastboot! flash super super.img
        del /s /q super.img >nul 2>nul 
)

echo.
echo Formatting data...
!fastboot! erase frp  >NUL 2>NUL
!fastboot! erase userdata  >NUL 2>NUL
!fastboot! erase metadata  >NUL 2>NUL

echo.
echo ##############################################################
echo All done! Your device is automatically restarting...
echo Now wait for 10-15 minutes for booting.
echo ##############################################################
echo.

if !fqlx! == AB (!fastboot! set_active a  >NUL 2>NUL)
!fastboot! reboot 
pause
exit