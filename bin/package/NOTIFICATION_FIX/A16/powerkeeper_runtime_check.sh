#!/system/bin/sh
# Run under su on the HAOTIAN device after flashing the test ROM.
# Diagnostics only. Does not change SELinux, packages, or system settings.
PKG=com.miui.powerkeeper
printf '%s\n' "=== HyperMOS PowerKeeper runtime audit ==="
printf 'Date: '; date
printf 'SELinux: '; getenforce
printf 'APK: '; pm path "$PKG"
printf '%s\n' "=== PACKAGE STATE ==="
dumpsys package "$PKG" | grep -E 'codePath=|versionName=|appId=|sharedUser=|User 0:|enabled=' | head -n 15
printf '%s\n' "=== PROCESS ==="
pid="$(pidof "$PKG" 2>/dev/null || true)"
if [ -n "$pid" ]; then
  printf 'RUNNING pid=%s\n' "$pid"
  ps -AZ | grep -F "$PKG" || true
  for p in $pid; do
    [ ! -r "/proc/$p/attr/current" ] || { printf 'Process context: '; cat "/proc/$p/attr/current"; }
  done
else
  printf '%s\n' "NOT RUNNING: process launch or initialization must be investigated"
fi
printf '%s\n' "=== PROVIDER ACTIVITY ==="
timeout 15 content query --user 0 --uri content://com.miui.powerkeeper.configure/userTable 2>&1 | head -n 20 || true
printf '%s\n' "=== RECENT FAILURE SIGNS ==="
logcat -d -b main -b system -b crash -v brief 2>/dev/null |
  grep -i -E 'selinux_android_setcontext.*powerkeeper|No match for app with uid 1000|Could not find provider: com.miui.powerkeeper.configure|FATAL EXCEPTION.*powerkeeper|Process com.miui.powerkeeper.*failed to attach' |
  tail -n 24
printf '%s\n' "=== FINAL PROCESS ==="
pid="$(pidof "$PKG" 2>/dev/null || true)"
if [ -n "$pid" ]; then
  printf '%s\n' "PASS: PowerKeeper process exists. Inspect context and provider results above."
else
  printf '%s\n' "FAIL: PowerKeeper process is absent. Do NOT assume FCM/performance hooks have run."
  exit 1
fi
