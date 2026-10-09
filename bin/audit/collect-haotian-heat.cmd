@echo off
setlocal EnableExtensions
rem Read-only Xiaomi 15 Pro / HAOTIAN heat capture for Windows platform-tools.
rem Open TikTok and watch normally while this script captures 3 samples.
where adb >nul 2>nul
if errorlevel 1 (
  echo adb.exe not found in PATH. Run this beside adb.exe.
  exit /b 1
)
adb get-state >nul 2>nul
if errorlevel 1 (
  echo Connect and authorize your phone for adb debugging first.
  exit /b 1
)
set "OUT=%~1"
if "%OUT%"=="" set "OUT=haotian-heat"
if not exist "%OUT%" mkdir "%OUT%"
adb shell getprop ro.product.device > "%OUT%\device.txt"
findstr /i /x "haotian" "%OUT%\device.txt" >nul
if errorlevel 1 (
  echo This tool only supports Xiaomi 15 Pro / haotian.
  exit /b 1
)
adb shell getprop ro.build.version.incremental > "%OUT%\rom.txt"
adb shell settings get system peak_refresh_rate > "%OUT%\peak-refresh.txt"
adb shell settings get system min_refresh_rate > "%OUT%\min-refresh.txt"
for /L %%N in (1,1,3) do (
  echo Capture sample %%N of 3...
  adb shell dumpsys battery > "%OUT%\battery-%%N.txt"
  adb shell dumpsys thermalservice > "%OUT%\thermal-%%N.txt"
  adb shell dumpsys cpuinfo > "%OUT%\cpuinfo-%%N.txt"
  adb shell top -b -n 1 -m 30 > "%OUT%\top-%%N.txt"
  adb shell dumpsys power > "%OUT%\power-%%N.txt"
  adb shell dumpsys gfxinfo com.zhiliaoapp.musically > "%OUT%\tiktok-global-%%N.txt"
  adb shell dumpsys gfxinfo com.ss.android.ugc.trill > "%OUT%\tiktok-region-%%N.txt"
  if not %%N==3 timeout /t 15 /nobreak >nul
)
echo Collected heat report in "%OUT%". Review personal data before sharing.
echo This script never changes governor, thermal, root, app permissions or boost.
endlocal
