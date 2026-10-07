#!/system/bin/sh
# HyperMOS MiCTS assistant bootstrap.
# Re-apply the Google Assistant role only when the Google voice interaction
# service is missing. Preserve any explicitly selected non-Google assistant.

TAG="HyperMOS-MiCTS"
PKG="com.google.android.googlequicksearchbox"
ROLE="android.app.role.ASSISTANT"
GOOGLE_VIS_PREFIX="$PKG/"

log_i() {
    log -t "$TAG" "$*" 2>/dev/null || true
}

if ! pm path "$PKG" >/dev/null 2>&1; then
    log_i "Google app not installed; skip assistant bootstrap"
    exit 0
fi

voice_service="$(settings get secure voice_interaction_service 2>/dev/null || true)"
case "$voice_service" in
    "$GOOGLE_VIS_PREFIX"*)
        log_i "Google VoiceInteractionService already active"
        exit 0
        ;;
esac

holders="$(cmd role get-role-holders "$ROLE" 2>/dev/null || true)"
holders="$(printf '%s\n' "$holders" | sed '/^[[:space:]]*$/d')"

if [ -n "$holders" ] && ! printf '%s\n' "$holders" | grep -Fxq "$PKG"; then
    log_i "Another assistant is selected; preserve: $holders"
    exit 0
fi

if cmd role add-role-holder "$ROLE" "$PKG" >/dev/null 2>&1; then
    sleep 1
    voice_service="$(settings get secure voice_interaction_service 2>/dev/null || true)"
    case "$voice_service" in
        "$GOOGLE_VIS_PREFIX"*)
            log_i "Google Assistant role applied; VoiceInteractionService active"
            exit 0
            ;;
    esac

    if [ -n "$voice_service" ]; then
        log_i "Google Assistant role applied; VoiceInteractionService pending: $voice_service"
    else
        log_i "Google Assistant role applied; VoiceInteractionService pending: none"
    fi
    exit 0
fi

log_i "Failed to apply Google Assistant role"
exit 0
