#!/usr/bin/env bash
# Read-only, non-root Android 16 HAOTIAN heat capture. Run on a computer with adb.
# Capture one baseline and a few samples while the user is watching TikTok.
set -euo pipefail

if ! command -v adb >/dev/null 2>&1; then
  echo "adb is required (Android platform-tools)." >&2
  exit 1
fi
out="${1:-haotian-heat-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out"
device="$(adb get-state 2>/dev/null || true)"
if [[ "$device" != "device" ]]; then
  echo "No authorized adb device found." >&2
  exit 1
fi
codename="$(adb shell getprop ro.product.device | tr -d '\r')"
if [[ "$codename" != "haotian" ]]; then
  echo "This protocol targets Xiaomi 15 Pro (haotian), found: $codename" >&2
  exit 1
fi

{
  echo "Device: $codename"
  echo "Android: $(adb shell getprop ro.build.version.release | tr -d '\r')"
  echo "ROM: $(adb shell getprop ro.build.version.incremental | tr -d '\r')"
  echo "OS security patch: $(adb shell getprop ro.build.version.security_patch | tr -d '\r')"
  echo "Peak refresh: $(adb shell settings get system peak_refresh_rate | tr -d '\r')"
  echo "Min refresh: $(adb shell settings get system min_refresh_rate | tr -d '\r')"
  echo "Timestamp: $(date -Is)"
} > "$out/metadata.txt"

# No su/root, frequencies/thermal limits never written, no apps stopped.
for n in 1 2 3; do
  sample="$out/sample-$n"
  mkdir -p "$sample"
  adb shell dumpsys battery > "$sample/battery.txt" || true
  adb shell dumpsys thermalservice > "$sample/thermalservice.txt" || true
  adb shell dumpsys cpuinfo > "$sample/cpuinfo.txt" || true
  adb shell top -b -n 1 -m 30 > "$sample/top.txt" || true
  adb shell dumpsys power > "$sample/power.txt" || true
  adb shell dumpsys gfxinfo com.zhiliaoapp.musically > "$sample/tiktok-global-gfx.txt" || true
  adb shell dumpsys gfxinfo com.ss.android.ugc.trill > "$sample/tiktok-region-gfx.txt" || true
  if [[ "$n" -lt 3 ]]; then sleep 15; fi
done
echo "Collected read-only data into: $out"
echo "Review the files before sharing: dumpsys and process listings can contain personal data."
echo "Compare against a same-length session on the earlier HyperMOS ROM with"
echo "the same brightness, refresh setting, connection type and ambient conditions."
