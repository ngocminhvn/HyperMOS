#chinh-sua-genInstall.sh
#!/bin/bash
work_dir=$(pwd)

# Load device information
device_code=$(cat $work_dir/bin/ddevice/device_code.txt 2>/dev/null)

codename="$device_code"
for s in EEAGlobal EEAGLOBAL Global GLOBAL EEA IN RU TR TW ID JP KR; do
    codename="${codename%$s}"
done
name=$(cat $work_dir/bin/ddevice/name_devices.txt 2>/dev/null)
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt 2>/dev/null)
base_rom_code=$(cat $work_dir/bin/ddevice/base_rom_code.txt 2>/dev/null)
regionTYPE=$(cat $work_dir/bin/ddevice/device_type.txt 2>/dev/null)
AndroidVer=$(cat $work_dir/bin/ddevice/androidver.txt 2>/dev/null)
starxVER=$(cat $work_dir/Version 2>/dev/null)
build_date=$(date +"%Y-%m-%d")

# If device_code is empty, fallback to unknown
if [ -z "$device_code" ]; then
    device_code="unknown"
fi

# Define output file
OUTPUT_FILE="$work_dir/bin/script2flash/${device_code}.install"

# Format ROM Type (e.g. OS3 -> HyperOS)
if [[ "$rom_os" == *"OS"* ]]; then
    rom_type="HyperOS"
else
    rom_type="MIUI"
fi

cat <<EOF > "$OUTPUT_FILE"
{
    "Devices": {
        "Name": "${name:-Unknown}",
        "Brand": "Xiaomi",
        "Codename": "${codename}"
    },
    "ROM": {
        "Type": "${rom_type}",
        "Version": "${base_rom_code:-Unknown}",
        "Region": "${regionTYPE:-Unknown}",
        "Android": "${AndroidVer:-Unknown}"
    },
    "ToolBuild": {
        "Version": "${starxVER:-1.0}",
        "BuildDate": "${build_date}",
        "Author": "${builder_name:-Nothings}",
        "BuildType": "PureStock-Release"
    },
    "Directory": {
        "Firmware": "images",
        "System": "super"
    }
}
EOF

echo "Generated $OUTPUT_FILE"

# Generate a Windows fastboot flash script next to the ROM contents.
# The script validates the device, flashes only firmware images that exist,
# switches to fastbootd for super.img, and optionally wipes userdata.
FLASH_FILE="$work_dir/bin/script2flash/FLASH.bat"
flash_codename="$(echo "$codename" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')"

cat <<EOF > "$FLASH_FILE"
@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title XM_build ROM Flasher - ${flash_codename}

set "EXPECTED_DEVICE=${flash_codename}"
set "ROM_VERSION=${base_rom_code:-Unknown}"
set "FASTBOOT="

echo.
echo ============================================================
echo                 XM_build ROM FLASHER
echo ============================================================
echo Device  : %EXPECTED_DEVICE%
echo ROM     : %ROM_VERSION%
echo.
echo WARNING: Bootloader must be unlocked.
echo Keep the USB cable connected until the script finishes.
echo ============================================================
echo.

rem Locate fastboot.exe. Put platform-tools beside FLASH.bat or add it to PATH.
if exist "%~dp0fastboot.exe" set "FASTBOOT=%~dp0fastboot.exe"
if not defined FASTBOOT if exist "%~dp0platform-tools\fastboot.exe" set "FASTBOOT=%~dp0platform-tools\fastboot.exe"
if not defined FASTBOOT if exist "%~dp0META-INF\fastboot.exe" set "FASTBOOT=%~dp0META-INF\fastboot.exe"
if not defined FASTBOOT (
    for /f "delims=" %%F in ('where fastboot.exe 2^>nul') do (
        if not defined FASTBOOT set "FASTBOOT=%%F"
    )
)

if not defined FASTBOOT (
    echo [ERROR] fastboot.exe was not found.
    echo Install Android platform-tools, add fastboot to PATH,
    echo or place fastboot.exe next to this FLASH.bat.
    goto :fail
)

if not exist "images" (
    echo [ERROR] images folder is missing.
    goto :fail
)

if not exist "super\super.img" (
    echo [ERROR] super\super.img is missing.
    goto :fail
)

echo [INFO] Fastboot: "%FASTBOOT%"
echo [INFO] Waiting for device in bootloader fastboot mode...
call :wait_fastboot 90
if errorlevel 1 goto :fail

set "DEVICE="
for /f "tokens=2 delims=: " %%D in ('"%FASTBOOT%" getvar product 2^>^&1 ^| findstr /i /b /c:"product:"') do set "DEVICE=%%D"

if not defined DEVICE (
    echo [ERROR] Could not read device codename.
    goto :fail
)

echo [INFO] Connected device: !DEVICE!
if /I not "!DEVICE!"=="%EXPECTED_DEVICE%" (
    echo [ERROR] Wrong device.
    echo Expected: %EXPECTED_DEVICE%
    echo Found   : !DEVICE!
    goto :fail
)

echo.
choice /C YN /N /M "Format data after flashing? [Y/N]: "
if errorlevel 2 (
    set "WIPE_DATA=0"
) else (
    set "WIPE_DATA=1"
)

echo.
echo [1/3] Flashing firmware images...
for %%P in (
    abl aop aop_config bluetooth boot cpucp cpucp_dtb devcfg dsp dtbo
    featenabler hyp idmanager imagefv init_boot keymaster modem modemfirmware
    multiimgqti pdp pdp_cdb pvmfw qupfw shrm soccp_dcd soccp_debug
    spuservice tz uefi uefisecapp vbmeta vbmeta_system vendor_boot
    vendor_kernel_boot vm-bootsys xbl xbl_config xbl_ramdump
) do (
    call :flash_partition "%%P"
    if errorlevel 1 goto :fail
)

echo.
echo [INFO] Setting active slot A when supported...
"%FASTBOOT%" set_active a >nul 2>&1

echo.
echo [2/3] Switching to fastbootd...
"%FASTBOOT%" reboot fastboot
if errorlevel 1 (
    echo [ERROR] Could not reboot to fastbootd.
    goto :fail
)

call :wait_fastboot 90
if errorlevel 1 goto :fail

echo.
echo [3/3] Flashing super.img...
"%FASTBOOT%" flash super "super\super.img"
if errorlevel 1 (
    echo [ERROR] super.img flash failed.
    goto :fail
)

if "%WIPE_DATA%"=="1" (
    echo.
    echo [WIPE] Formatting userdata/metadata using fastboot -w...
    "%FASTBOOT%" -w
    if errorlevel 1 (
        echo [ERROR] Data wipe failed.
        goto :fail
    )
)

echo.
echo [DONE] Flash completed successfully.
echo [INFO] Rebooting to Android...
"%FASTBOOT%" reboot
echo.
echo First boot can take several minutes.
pause
exit /b 0

:flash_partition
set "PART=%~1"
set "IMG=images\%~1.img"

if not exist "!IMG!" (
    echo [SKIP] !PART!.img not present
    exit /b 0
)

echo [FLASH] !PART! ^<- !IMG!

rem Query whether this partition is slotted. If yes, flash both A and B.
"%FASTBOOT%" getvar has-slot:!PART! 2>&1 | findstr /i /c:"yes" >nul
if not errorlevel 1 (
    "%FASTBOOT%" flash !PART!_a "!IMG!"
    if errorlevel 1 exit /b 1
    "%FASTBOOT%" flash !PART!_b "!IMG!"
    if errorlevel 1 exit /b 1
) else (
    "%FASTBOOT%" flash !PART! "!IMG!"
    if errorlevel 1 exit /b 1
)

exit /b 0

:wait_fastboot
set /a WAIT_LEFT=%~1
:wait_fastboot_loop
for /f "tokens=1" %%D in ('"%FASTBOOT%" devices 2^>nul') do (
    if not "%%D"=="" exit /b 0
)
if !WAIT_LEFT! LEQ 0 (
    echo [ERROR] Fastboot device timeout.
    exit /b 1
)
set /a WAIT_LEFT-=2
timeout /t 2 /nobreak >nul
goto :wait_fastboot_loop

:fail
echo.
echo ============================================================
echo FLASH FAILED - DO NOT DISCONNECT WHILE A FLASH IS RUNNING.
echo Check the error above, cable/driver, and fastboot mode.
echo ============================================================
pause
exit /b 1
EOF

echo "Generated $FLASH_FILE"
