#!/system/bin/sh
# Apply the same Android property values as the tested KernelSU module.
# Runs after boot completion and must never hold up boot if resetprop fails.

tag=HyperMOSBootState
resetprop=/data/adb/ksu/bin/resetprop
ksud=/data/adb/ksu/bin/ksud
legacy_ksud=/data/adb/ksud

[ "$(/system/bin/getprop sys.boot_completed)" = 1 ] || exit 0

apply_prop() {
  if [ -x "$resetprop" ] && "$resetprop" -n "$1" "$2" >/dev/null 2>&1; then
    return 0
  fi
  if [ -x "$ksud" ] && "$ksud" resetprop -n "$1" "$2" >/dev/null 2>&1; then
    return 0
  fi
  if [ -x "$legacy_ksud" ] && "$legacy_ksud" resetprop -n "$1" "$2" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

failed=0
for item in \
  ro.boot.flash.locked=1 \
  ro.boot.vbmeta.device_state=locked \
  ro.boot.verifiedbootstate=green; do
  key=${item%%=*}
  value=${item#*=}
  if [ "$(/system/bin/getprop "$key")" = "$value" ]; then
    continue
  fi
  if ! apply_prop "$key" "$value" ||
     [ "$(/system/bin/getprop "$key")" != "$value" ]; then
    failed=1
    /system/bin/log -t "$tag" "Could not set $key; continuing boot"
  fi
done

if [ "$failed" -eq 0 ]; then
  /system/bin/log -t "$tag" "Android boot properties synchronized"
fi
exit 0
