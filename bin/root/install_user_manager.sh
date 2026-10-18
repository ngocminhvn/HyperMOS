#!/system/bin/sh
# Install official SukiSU Manager as a normal user app after Android boots.
# Invoked in the shell SELinux domain by Android init, not via /data/adb hooks.
# PackageManager (not a direct /data/app copy) owns the installed APK.
set -u

TAG=HyperMOSRoot
APK=/system_ext/etc/hypermos-root/RootManager.apk
PKG=com.sukisu.ultra
HASH=c7f69280cf468e8415c585ff31f963d0147386831217a1e89b822afddc5f40ed

say() { /system/bin/log -t "$TAG" "$*" 2>/dev/null || :; }
installed_path() {
    /system/bin/cmd package path --user 0 "$PKG" 2>/dev/null |
        /system/bin/sed -n 's/^package://p' |
        /system/bin/head -n 1
}

[ "$(/system/bin/getprop sys.boot_completed)" = 1 ] || exit 0
[ -f "$APK" ] && [ ! -L "$APK" ] || { say "manager payload missing"; exit 0; }

# Idempotent: do not replace an existing manager, especially if it is newer.
current="$(installed_path)"
case "$current" in
    /data/app/*)
        say "manager already installed as user app: $current"
        exit 0
        ;;
    "")
        ;;
    *)
        say "manager has non-user install path $current; manual migration needed"
        exit 0
        ;;
esac

# Use only the pinned official release APK; fail without blocking boot.
echo "$HASH  $APK" | /system/bin/sha256sum -c - >/dev/null 2>&1 || {
    say "official manager APK digest mismatch; skipping install"
    exit 0
}

result="$(/system/bin/cmd package install --user 0 -r "$APK" 2>&1)"
status=$?
if [ "$status" -ne 0 ]; then
    say "manager user-app installation failed ($status): $result"
    exit 0
fi

current="$(installed_path)"
case "$current" in
    /data/app/*) say "SukiSU installed as ordinary user app: $current" ;;
    *) say "PackageManager did not produce a user APK ($status): $result" ;;
esac
exit 0
