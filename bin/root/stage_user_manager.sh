#!/system/bin/sh
# Place a SukiSU boot-completed.d hook early enough for first-boot installation.
# Android init invokes this after /data is mounted. Does NOT install an app
# in init's SELinux domain or create an extra long-running service.
set -u

TAG=HyperMOSRoot
SOURCE=/system_ext/etc/hypermos-root/install-user-manager.sh
HOOK_DIR=/data/adb/boot-completed.d
HOOK=$HOOK_DIR/hypermos-sukisu-manager.sh
DONE=/data/adb/hypermos-root/sukisu-manager-installed
say() { /system/bin/log -t "$TAG" "$*" 2>/dev/null || :; }

[ -f "$DONE" ] && exit 0
[ -f "$SOURCE" ] && [ ! -L "$SOURCE" ] || { say "missing manager install hook"; exit 0; }

# Only use a root-controlled location; never follow unexpected symlinks.
for path in /data/adb "$HOOK_DIR" "$HOOK"; do
    if [ -L "$path" ]; then
        say "unsafe symlink in SukiSU boot hook path: $path"
        exit 0
    fi
done
/system/bin/mkdir -p "$HOOK_DIR" 2>/dev/null || { say "cannot stage boot hook"; exit 0; }
/system/bin/chown root:root "$HOOK_DIR" 2>/dev/null || :
/system/bin/chmod 0700 "$HOOK_DIR" 2>/dev/null || :
/system/bin/restorecon -R "$HOOK_DIR" >/dev/null 2>&1 || :

# If the hook is already staged, do not overwrite a boot-time file from
# another install or a newer ROM version.
if [ -e "$HOOK" ]; then
    exit 0
fi
tmp=$HOOK_DIR/.hypermos-sukisu-$$.tmp
/system/bin/cp "$SOURCE" "$tmp" || { say "cannot copy boot hook"; exit 0; }
/system/bin/chown root:root "$tmp" || { /system/bin/rm -f "$tmp"; exit 0; }
/system/bin/chmod 0700 "$tmp" || { /system/bin/rm -f "$tmp"; exit 0; }
/system/bin/restorecon "$tmp" >/dev/null 2>&1 || :
if [ -e "$HOOK" ] || [ -L "$HOOK" ]; then
    /system/bin/rm -f "$tmp"
    exit 0
fi
/system/bin/mv -n "$tmp" "$HOOK" || { /system/bin/rm -f "$tmp"; exit 0; }
/system/bin/restorecon "$HOOK" >/dev/null 2>&1 || :
say "prepared one-shot user Manager installation for SukiSU boot-completed hook"
exit 0
