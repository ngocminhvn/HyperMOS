#!/system/bin/sh
# HyperMOS SukiSU v4.2.1: one-time user app install via SukiSU boot-completed.d.
# Runs as the root provider's boot-completed hook, after PackageManager starts.
# No system/priv-app preload, no auto-granted su access, no daemon.
set -u

TAG=HyperMOSRoot
APK=/system_ext/etc/hypermos-root/RootManager.apk
PKG=com.sukisu.ultra
HASH=c7f69280cf468e8415c585ff31f963d0147386831217a1e89b822afddc5f40ed
STATE=/data/adb/hypermos-root
DONE=$STATE/sukisu-manager-installed
SELF=/data/adb/boot-completed.d/hypermos-sukisu-manager.sh

say() { /system/bin/log -t "$TAG" "$*" 2>/dev/null || :; }
installed_path() {
    /system/bin/cmd package path --user 0 "$PKG" 2>/dev/null |
        /system/bin/sed -n 's/^package://p' |
        /system/bin/head -n 1
}
finish() {
    /system/bin/mkdir -p "$STATE" || return 1
    /system/bin/chmod 0700 "$STATE" || return 1
    /system/bin/touch "$DONE" || return 1
    /system/bin/chmod 0600 "$DONE" || return 1
    /system/bin/restorecon "$DONE" >/dev/null 2>&1 || :
    # Stop invoking the installation task on later boots.
    /system/bin/rm -f "$SELF" 2>/dev/null || :
}

[ "$(/system/bin/id -u)" = 0 ] || { say "user installer must run as root"; exit 0; }
[ -f "$DONE" ] && exit 0
[ "$(/system/bin/getprop sys.boot_completed)" = 1 ] || exit 0
[ -f "$APK" ] && [ ! -L "$APK" ] || { say "manager payload missing"; exit 0; }

# Never touch an already installed user app; changing its data/signature
# silently would break Manager trust and user settings.
current="$(installed_path)"
case "$current" in
    /data/app/*)
        say "manager already installed as user app: $current"
        finish || say "could not write SukiSU manager installation state"
        exit 0
        ;;
    "")
        ;;
    *)
        say "manager has non-user install path $current; refusing silent update"
        exit 0
        ;;
esac

# Do not trust a modified/stale staged APK.
echo "$HASH  $APK" | /system/bin/sha256sum -c - >/dev/null 2>&1 || {
    say "official manager APK digest mismatch; skipping install"
    exit 0
}

# PackageManager is asked to install an ordinary app into /data/app (user 0).
# Never copy bytes directly to /data/app or manipulate packages.xml.
result="$(/system/bin/cmd package install --user 0 -r "$APK" 2>&1)"
status=$?
if [ "$status" -ne 0 ]; then
    say "manager user-app installation failed ($status): $result"
    exit 0
fi

current="$(installed_path)"
case "$current" in
    /data/app/*)
        say "SukiSU installed as ordinary user app: $current"
        finish || say "could not persist manager installation state"
        ;;
    *)
        say "PackageManager returned success but non-user install path: $current"
        ;;
esac
# Fail open: package installation must never stop Android from booting.
exit 0
