#!/system/bin/sh
# HyperMOS TNM Hosts controller
# Commands: boot | apply | disable | status | test

DATA_DIR=/data/system/tnm
SRC="$DATA_DIR/hosts"
TARGET=/system/etc/hosts
DISABLED="$DATA_DIR/disabled"
STOCK="$DATA_DIR/stock-hosts"
MARKER=tnm-hosts-test.invalid
MARKER_IP=127.0.0.2

log() { echo "TNM_HOSTS: $*"; }

ensure_source() {
    mkdir -p "$DATA_DIR" || return 1
    if [ ! -s "$SRC" ]; then
        printf '127.0.0.1 localhost\n::1 localhost\n%s %s\n' "$MARKER_IP" "$MARKER" > "$SRC" || return 1
    elif ! grep -Eq "(^|[[:space:]])${MARKER}([[:space:]]|$)" "$SRC"; then
        printf '\n%s %s\n' "$MARKER_IP" "$MARKER" >> "$SRC" || return 1
    fi
    chown 0:0 "$SRC" || return 1
    chmod 0644 "$SRC" || return 1
    # A bind mount retains the data file's SELinux label. Files under
    # /data/system are not necessarily readable by ordinary app processes.
    # Match a stock /system file BEFORE mounting; never disable SELinux.
    if command -v chcon >/dev/null 2>&1; then
        chcon --reference=/system/build.prop "$SRC" || {
            log "cannot label hosts like /system/build.prop"
            return 1
        }
    fi
    if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then
        src_type="$(ls -Zd "$SRC" 2>/dev/null | awk '{print $1}')"
        sys_type="$(ls -Zd /system/build.prop 2>/dev/null | awk '{print $1}')"
        if [ -z "$src_type" ] || [ -z "$sys_type" ] || [ "$src_type" != "$sys_type" ]; then
            log "SELINUX_CONTEXT_MISMATCH source=$src_type expected=$sys_type"
            return 1
        fi
    fi
}

is_bound() {
    [ -e "$SRC" ] || return 1
    a="$(stat -Lc '%d:%i' "$SRC" 2>/dev/null)"
    b="$(stat -Lc '%d:%i' "$TARGET" 2>/dev/null)"
    [ -n "$a" ] && [ "$a" = "$b" ]
}

marker_visible() {
    grep -Eq "(^|[[:space:]])${MARKER}([[:space:]]|$)" "$TARGET" 2>/dev/null
}

# Save the real, unmodified ROM file before the first bind. We need its
# contents on disable because running apps may retain an older mount namespace.
save_stock() {
    if [ ! -s "$STOCK" ] && ! marker_visible; then
        cp "$TARGET" "$STOCK" || return 1
        chown 0:0 "$STOCK" 2>/dev/null || true
        chmod 0644 "$STOCK" 2>/dev/null || true
    fi
}

restore_source() {
    [ -f "$SRC" ] || return 0
    # Rewrite the SAME inode so that apps already holding a bind mount stop
    # blocking, including apps outside the controller's mount namespace.
    if [ -s "$STOCK" ]; then
        cat "$STOCK" > "$SRC" || return 1
    else
        printf '127.0.0.1 localhost\n::1 localhost\n' > "$SRC" || return 1
    fi
    chown 0:0 "$SRC" 2>/dev/null || true
    chmod 0644 "$SRC" 2>/dev/null || true
}

apply_hosts() {
    ensure_source || { log "source setup failed"; return 1; }
    save_stock || { log "could not back up stock hosts"; return 1; }
    # Do not replace a verified mount: preserving its inode allows live updates
    # across apps that inherited the bind at boot.
    if ! is_bound; then
        mount --bind "$SRC" "$TARGET" || { log "bind mount failed"; return 1; }
    fi
    is_bound || { log "bind verification failed"; return 1; }
    marker_visible || { log "marker not visible after bind"; return 1; }
    ndc resolver flushdefaultif 2>/dev/null || true
    ndc resolver flushif wlan0 2>/dev/null || true
    ndc resolver flushif rmnet_data0 2>/dev/null || true
    cmd netd resolver flushnetworkcache 0 2>/dev/null || true
    log "active source=$SRC target=$TARGET"
}

disable_hosts() {
    # Marker was already persisted and source rewritten before switching to
    # init's namespace, so disabling is safe even for still-running apps.
    if is_bound; then
        umount "$TARGET" || { log "unmount failed"; return 1; }
    fi
    log "disabled"
}

# su (Magisk/KernelSU) can run in an isolated mount namespace. A successful
# bind there is NOT evidence that ordinary Android app processes see the file.
# Prefer init's mount namespace for new binds; if setns is unavailable,
# fail clearly and let the already staged file activate at next boot.
enter_init_mount_ns() {
    action="$1"
    current_ns="$(readlink /proc/self/ns/mnt 2>/dev/null)"
    init_ns="$(readlink /proc/1/ns/mnt 2>/dev/null)"
    if [ -z "$current_ns" ] || [ -z "$init_ns" ]; then
        log "mount namespace could not be inspected"
        return 1
    fi
    [ "$current_ns" = "$init_ns" ] && return 0
    if ! command -v nsenter >/dev/null 2>&1; then
        log "nsenter unavailable, reboot required"
        return 1
    fi
    if ! nsenter -t 1 -m -- /system/bin/true 2>/dev/null; then
        log "cannot access init mount namespace, reboot required"
        return 1
    fi
    exec nsenter -t 1 -m -- /system/bin/sh "$0" "$action"
}

status_hosts() {
    is_bound && echo "BOUND=1" || echo "BOUND=0"
    echo "SOURCE=$SRC"
    echo "TARGET=$TARGET"
    echo "SOURCE_LINES=$(wc -l < "$SRC" 2>/dev/null || echo 0)"
    marker_visible && echo "MARKER_VISIBLE=1" || echo "MARKER_VISIBLE=0"
    echo "SOURCE_CONTEXT=$(ls -Zd "$SRC" 2>/dev/null | awk '{print $1}')"
    echo "SYSTEM_CONTEXT=$(ls -Zd /system/build.prop 2>/dev/null | awk '{print $1}')"
    echo "SELINUX=$(getenforce 2>/dev/null)"
    [ -f "$DISABLED" ] && echo "DISABLED=1" || echo "DISABLED=0"
}

resolve_marker() {
    if command -v getent >/dev/null 2>&1; then
        out="$(getent hosts "$MARKER" 2>/dev/null | head -n 1)"
        echo "$out" | grep -Eq "(^|[[:space:]])${MARKER_IP}([[:space:]]|$)" && return 0
    fi
    # nslookup talks directly to DNS and normally ignores /etc/hosts.
    # It must not be used as evidence that Android apps honour the bind.
    first="$(ping -c 1 -W 1 "$MARKER" 2>&1 | head -n 1)"
    echo "$first" | grep -q "$MARKER_IP" && return 0
    return 1
}

test_hosts() {
    status_hosts
    if ! is_bound; then echo "RESOLVER=0"; echo "RESULT=MOUNT_FAIL"; return 2; fi
    if ! marker_visible; then echo "RESOLVER=0"; echo "RESULT=MARKER_FAIL"; return 4; fi
    if resolve_marker; then echo "RESOLVER=1"; echo "RESULT=OK"; return 0; fi
    echo "RESOLVER=0"
    echo "RESULT=RESOLVER_UNVERIFIED"
    return 3
}

case "${1:-status}" in
    boot)
        if [ -s "$SRC" ] && [ ! -f "$DISABLED" ]; then
            apply_hosts
        else
            log "hosts disabled or not yet configured; stock hosts retained"
        fi
        ;;
    apply|enable|reload)
        mkdir -p "$DATA_DIR" || exit 1
        rm -f "$DISABLED" || exit 1
        enter_init_mount_ns "${1}" || { log "PENDING_REBOOT=1"; exit 78; }
        apply_hosts
        ;;
    disable|off)
        mkdir -p "$DATA_DIR" || exit 1
        touch "$DISABLED" || exit 1
        restore_source || { log "could not restore stock hosts"; exit 1; }
        enter_init_mount_ns "${1}" || { log "PENDING_REBOOT=1"; exit 78; }
        disable_hosts
        ;;
    status) status_hosts ;;
    test) test_hosts ;;
    *) echo "usage: tnm-hostsctl {boot|apply|disable|status|test}" >&2; exit 64 ;;
esac
