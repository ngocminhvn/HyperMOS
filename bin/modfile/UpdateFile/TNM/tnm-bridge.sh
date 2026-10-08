#!/system/bin/sh
# HyperMOS TNM bridge: on-demand launcher, NEVER a persistent root daemon.
set -eu
umask 077
[ "$(id -u)" = 0 ] || { echo "TNM bridge requires an approved root session" >&2; exit 10; }

BACKEND=/data/adb/tnm/bin/tnmctl
case "${1:-status}" in
  status|protocol|capabilities|call) ;;
  *) echo "Unsupported bridge verb" >&2; exit 2 ;;
esac
[ -f "$BACKEND" ] && [ -x "$BACKEND" ] && [ ! -L "$BACKEND" ] || {
  echo "TNM backend is missing; launch the signed TNM APK to sync" >&2
  exit 11
}
# Backend is installed as root-owned files by TNM after the root provider grants access.
[ "$(stat -c %u "$BACKEND" 2>/dev/null)" = 0 ] || {
  echo "TNM backend owner mismatch" >&2
  exit 12
}
[ ! -L /data/adb/tnm ] &&
[ "$(stat -c %u /data/adb/tnm 2>/dev/null)" = 0 ] || {
  echo "TNM backend directory is not trusted" >&2
  exit 12
}
mode="$(stat -c %a "$BACKEND" 2>/dev/null)" || exit 12
case "$mode" in
  500|550|555|700|750|755) ;;
  *) echo "TNM backend permissions are unsafe" >&2; exit 12 ;;
esac
exec "$BACKEND" "$@"
