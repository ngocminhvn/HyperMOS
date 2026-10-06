#!/system/bin/sh
# HyperMOS TNM Hosts controller
# Commands: boot | apply | disable | status | test

DATA_DIR=/data/system/tnm
SRC="$DATA_DIR/hosts"
TARGET=/system/etc/hosts
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
    chown 0:0 "$SRC" 2>/dev/null
    chmod 0644 "$SRC" 2>/dev/null
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

apply_hosts() {
    ensure_source || { log "source setup failed"; return 1; }
    umount "$TARGET" 2>/dev/null || true
    mount --bind "$SRC" "$TARGET" || { log "bind mount failed"; return 1; }
    is_bound || { log "bind verification failed"; return 1; }
    marker_visible || { log "marker not visible after bind"; return 1; }
    ndc resolver flushdefaultif 2>/dev/null || true
    ndc resolver flushif wlan0 2>/dev/null || true
    ndc resolver flushif rmnet_data0 2>/dev/null || true
    cmd netd resolver flushnetworkcache 0 2>/dev/null || true
    log "active source=$SRC target=$TARGET"
}

disable_hosts() {
    umount "$TARGET" 2>/dev/null || true
    log "disabled"
}

status_hosts() {
    is_bound && echo "BOUND=1" || echo "BOUND=0"
    echo "SOURCE=$SRC"
    echo "TARGET=$TARGET"
    echo "SOURCE_LINES=$(wc -l < "$SRC" 2>/dev/null || echo 0)"
    marker_visible && echo "MARKER_VISIBLE=1" || echo "MARKER_VISIBLE=0"
}

resolve_marker() {
    if command -v getent >/dev/null 2>&1; then
        out="$(getent hosts "$MARKER" 2>/dev/null | head -n 1)"
        echo "$out" | grep -Eq "(^|[[:space:]])${MARKER_IP}([[:space:]]|$)" && return 0
    fi
    if command -v nslookup >/dev/null 2>&1; then
        out="$(nslookup "$MARKER" 2>&1)"
        echo "$out" | grep -q "$MARKER_IP" && return 0
    fi
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
    boot) [ -s "$SRC" ] && apply_hosts || log "no user hosts yet; stock hosts retained" ;;
    apply|enable|reload) apply_hosts ;;
    disable|off) disable_hosts ;;
    status) status_hosts ;;
    test) test_hosts ;;
    *) echo "usage: tnm-hostsctl {boot|apply|disable|status|test}" >&2; exit 64 ;;
esac
