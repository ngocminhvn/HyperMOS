#!/system/bin/sh
# Read-only, on-demand Android 16 EU notification/cleanup diagnostic.
# Never force-stops, kills, whitelists, freezes or modifies any package.
set -eu

pkg="${1:-com.facebook.orca}"
phase="${2:-snapshot}"
case "$pkg" in
    ''|.*|*..*|*[!a-zA-Z0-9._]*)
        echo "Invalid package name: $pkg" >&2
        exit 2
        ;;
esac
case "$phase" in
    before|after-clean|after-swipe|idle|snapshot) ;;
    *) echo "Usage: sh eu_background_runtime_a16.sh [package] [before|after-clean|after-swipe|idle|snapshot]" >&2; exit 2 ;;
esac

echo "=== HyperMOS A16 EU cleanup diagnostic (read-only) ==="
echo "package=$pkg"
echo "phase=$phase"
echo "time=$(date '+%Y-%m-%d %H:%M:%S %z')"
echo "uptime=$(cat /proc/uptime 2>/dev/null || echo unavailable)"
echo "device=$(getprop ro.product.device)"
echo "android_sdk=$(getprop ro.build.version.sdk)"
echo
echo "[App package state: stopped=false permits delivery, not proof of FCM]"
state="$(dumpsys package "$pkg" 2>/dev/null | grep -m 1 'User 0:' || true)"
if [ -n "$state" ]; then
    printf '%s\n' "$state"
else
    echo "package_state_unavailable_or_not_installed"
fi
echo
echo "[Process: absence of PID is OK if stopped=false]"
if command -v pidof >/dev/null 2>&1; then
    pidof "$pkg" || echo "main_process_not_running"
fi
ps -A 2>/dev/null | grep -F "$pkg" || true
echo
echo "[Recent exits; check reason/subreason/OneKeyClean/SwipeUpClean]"
dumpsys activity exit-info "$pkg" 2>/dev/null | grep -E 'process=|reason=|subreason=|description=' | head -n 10 || true
echo
echo "[Power management: standby bucket is contextual]"
am get-standby-bucket "$pkg" 2>/dev/null || echo "standby_bucket_unavailable"
echo
echo "[Battery: Android temperature is tenths of a degree Celsius]"
dumpsys battery 2>/dev/null | grep -E 'status:|level:|temperature:' || true
echo
echo "[CPU policy: scaling_max is a ceiling, not current load]"
for policy in /sys/devices/system/cpu/cpufreq/policy[0-9]*; do
    [ -d "$policy" ] || continue
    label="${policy##*/}"
    max="$(cat "$policy/scaling_max_freq" 2>/dev/null || echo unknown)"
    hw="$(cat "$policy/cpuinfo_max_freq" 2>/dev/null || echo unknown)"
    echo "$label scaling_max=$max hardware_max=$hw"
done
echo
echo "[One short CPU sample; no background monitoring]"
top -b -n 1 2>/dev/null | head -n 8 || true
echo
echo "NOTICE: This script neither starts/stops apps nor changes settings."
echo "Compare before/after results plus actual incoming-notification tests."
