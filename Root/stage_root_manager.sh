#!/system/bin/sh
# HyperMOS: stage the matching root manager after user 0 CE unlock.
# Does NOT install an APK or start package manager.
SRC="/system_ext/etc/hypermos-root/RootManager.apk"
NAMING="/system_ext/etc/hypermos-root/manager-name.txt"
ROOT="/data/media/0"
[ -s "$SRC" ] && [ -s "$NAMING" ] || exit 0
ce="$(/system/bin/getprop sys.user.0.ce_available)"
case "$ce" in
  true|1) ;;
  *) exit 0 ;;
esac
[ -d "$ROOT" ] || exit 0

name="$(/system/bin/cat "$NAMING")"
case "$name" in
  KernelSU-Next_v*.apk) ;;
  *) /system/bin/log -t HyperMOSRoot "Unsafe manager filename; skip"; exit 1 ;;
esac
# Validate no path separators or shell-special characters.
case "$name" in
  *[!a-zA-Z0-9._-]*) exit 1 ;;
esac
dir="$ROOT/Download"
[ -d "$dir" ] || /system/bin/mkdir -p "$dir" || exit 1
if [ ! -d "$dir" ]; then exit 1; fi
dest="$dir/$name"
if [ -e "$dest" ]; then
  # Never overwrite an APK the user already placed in Download.
  exit 0
fi
tmp="$dir/.hypermos-root-$$.tmp"
trap '/system/bin/rm -f "$tmp"' EXIT HUP INT TERM
/system/bin/cp "$SRC" "$tmp" || exit 1
/system/bin/chown 1023:1023 "$tmp" || exit 1
/system/bin/chmod 0644 "$tmp" || exit 1
/system/bin/restorecon "$tmp" >/dev/null 2>&1 || {
  /system/bin/log -t HyperMOSRoot "Cannot apply media SELinux context"
  exit 1
}
if [ ! -e "$dest" ]; then
  /system/bin/mv -n "$tmp" "$dest" || exit 1
fi
[ -s "$dest" ] || exit 1
/system/bin/log -t HyperMOSRoot "Root manager staged to user 0 Download: $name (not installed)"
exit 0
