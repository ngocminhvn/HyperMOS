#!/system/bin/sh
# HyperMOS TNM Hosts controller
# Commands: boot | apply | disable | status | test

DATA_DIR=/data/system/tnm
SRC="$DATA_DIR/hosts"
TARGET=/system/etc/hosts
MARKER=tnm-hosts-test.invalid

log() { echo "TNM_HOSTS: $*"; }

ensure_source() {
    mkdir -p "$DATA_DIR" || return 1
    if [ ! -s "$SRC" ]; then
        printf '127.0.0.1 localhost\n::1 localhost\n127.0.0.2 %s\n' "$MARKER" > "$SRC" || return 1
    elif ! grep -q "[[:space:]]$MARKER\([[:space:]]\|$\)" "$SRC"; then
        printf '\n127.0.0.2 %s\n' "$MARKER" >> "$SRC" || return 1
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

apply_hosts() {
    ensure_source || { log "source setup failed"; return 1; }

    # Atomic updates replace the source inode. Always re-bind so TARGET follows
    # the newest hosts file instead of the inode that was mounted previously.
    umount "$TARGET" 2>/dev/null || true
    mount --bind "$SRC" "$TARGET" || {
        log "bind mount failed"
        return 1
    }

    if ! is_bound; then
        log "bind verification failed"
        return 1
    fi

    log "active source=$SRC target=$TARGET"
    return 0
}

disable_hosts() {
    umount "$TARGET" 2>/dev/null || true
    log "disabled"
}

status_hosts() {
    if is_bound; then
        echo "BOUND=1"
    else
        echo "BOUND=0"
    fi
    echo "SOURCE=$SRC"
    echo "TARGET=$TARGET"
    echo "SOURCE_LINES=$(wc -l < "$SRC" 2>/dev/null || echo 0)"
    grep -q "[[:space:]]$MARKER\([[:space:]]\|$\)" "$TARGET" 2>/dev/null &&
        echo "MARKER_VISIBLE=1" || echo "MARKER_VISIBLE=0"
}

test_hosts() {
    status_hosts
    if ! is_bound; then
        echo "RESULT=MOUNT_FAIL"
        return 2
    fi

    # Android/toybox ping performs hostname resolution through libc. We only
    # inspect the resolved address printed on the first line; no packet result
    # is required for this self-test.
    first="$(ping -c 1 -W 1 "$MARKER" 2>&1 | head -n 1)"
    echo "$first" | grep -q '127\.0\.0\.2' && {
        echo "RESOLVER=1"
        echo "RESULT=OK"
        return 0
    }

    echo "RESOLVER=0"
    echo "RESULT=RESOLVER_FAIL"
    return 3
}

case "${1:-status}" in
    boot)
        [ -s "$SRC" ] && apply_hosts || log "no user hosts yet; stock hosts retained"
        ;;
    apply|enable|reload)
        apply_hosts
        ;;
    disable|off)
        disable_hosts
        ;;
    status)
        status_hosts
        ;;
    test)
        test_hosts
        ;;
    *)
        echo "usage: tnm-hostsctl {boot|apply|disable|status|test}" >&2
        exit 64
        ;;
esac
