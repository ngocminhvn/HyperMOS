#!/system/bin/sh
# HyperMOS HCL Compat (read-only)
# Diagnostic-only adaptation inspired by minhtritt1996/HCL-Module.
# Intentionally does NOT spoof boot state, fingerprint, uname, attestation,
# TrickyStore targets, HMA rules, or run a background guardian daemon.

prop() {
    getprop "$1" 2>/dev/null
}

value_or_dash() {
    if [ -n "$1" ]; then
        printf '%s\n' "$1"
    else
        printf '%s\n' "-"
    fi
}

print_status() {
    DEVICE="$(prop ro.product.vendor.device)"
    [ -n "$DEVICE" ] || DEVICE="$(prop ro.product.device)"
    [ -n "$DEVICE" ] || DEVICE="$(prop ro.product.name)"

    MODEL="$(prop ro.product.vendor.model)"
    [ -n "$MODEL" ] || MODEL="$(prop ro.product.odm.model)"
    [ -n "$MODEL" ] || MODEL="$(prop ro.product.model)"

    BRAND="$(prop ro.product.vendor.brand)"
    [ -n "$BRAND" ] || BRAND="$(prop ro.product.brand)"

    MANUFACTURER="$(prop ro.product.vendor.manufacturer)"
    [ -n "$MANUFACTURER" ] || MANUFACTURER="$(prop ro.product.manufacturer)"

    printf '%s\n' "HyperMOS HCL Compat — read-only diagnostics"
    printf '%s\n' "=========================================="
    printf 'device=%s\n' "$(value_or_dash "$DEVICE")"
    printf 'model=%s\n' "$(value_or_dash "$MODEL")"
    printf 'brand=%s\n' "$(value_or_dash "$BRAND")"
    printf 'manufacturer=%s\n' "$(value_or_dash "$MANUFACTURER")"
    printf 'android=%s\n' "$(value_or_dash "$(prop ro.build.version.release)")"
    printf 'sdk=%s\n' "$(value_or_dash "$(prop ro.build.version.sdk)")"
    printf 'hyperos=%s\n' "$(value_or_dash "$(prop ro.mi.os.version.name)")"
    printf 'mod_device=%s\n' "$(value_or_dash "$(prop ro.product.mod_device)")"
    printf 'fingerprint=%s\n' "$(value_or_dash "$(prop ro.build.fingerprint)")"
    printf 'kernel=%s\n' "$(uname -r 2>/dev/null || printf '-')"
}

print_matrix() {
    printf '%s\n' "Partition identity matrix (reported values only)"
    printf '%s\n' "================================================"
    for part in system system_ext product vendor odm bootimage vendor_dlkm odm_dlkm; do
        printf '[%s]\n' "$part"
        printf '  fingerprint=%s\n' "$(value_or_dash "$(prop "ro.${part}.build.fingerprint")")"
        printf '  device=%s\n' "$(value_or_dash "$(prop "ro.product.${part}.device")")"
        printf '  model=%s\n' "$(value_or_dash "$(prop "ro.product.${part}.model")")"
        printf '  name=%s\n' "$(value_or_dash "$(prop "ro.product.${part}.name")")"
        printf '  brand=%s\n' "$(value_or_dash "$(prop "ro.product.${part}.brand")")"
        printf '  manufacturer=%s\n' "$(value_or_dash "$(prop "ro.product.${part}.manufacturer")")"
    done
}

print_security() {
    printf '%s\n' "Boot/security state (reported values only)"
    printf '%s\n' "=========================================="
    printf 'flash_locked=%s\n' "$(value_or_dash "$(prop ro.boot.flash.locked)")"
    printf 'verifiedbootstate=%s\n' "$(value_or_dash "$(prop ro.boot.verifiedbootstate)")"
    printf 'vbmeta_device_state=%s\n' "$(value_or_dash "$(prop ro.boot.vbmeta.device_state)")"
    printf 'secureboot=%s\n' "$(value_or_dash "$(prop ro.boot.secureboot)")"
    printf 'warranty_bit=%s\n' "$(value_or_dash "$(prop ro.boot.warranty_bit)")"
    printf 'oem_unlock_allowed=%s\n' "$(value_or_dash "$(prop sys.oem_unlock_allowed)")"
    printf 'ro_secure=%s\n' "$(value_or_dash "$(prop ro.secure)")"
}

print_features() {
    cat <<'EOF'
HyperMOS HCL Compat feature policy
==================================
read_only_identity_audit=true
partition_matrix=true
security_state_report=true
spoof_uname=false
guardian_daemon=false
resetprop_mutation=false
boot_state_spoof=false
fingerprint_spoof=false
attestation_target_management=false
trickystore_mutation=false
hma_rule_sync=false
security_cache_cleanup=false
EOF
}

case "${1:-status}" in
    status)
        print_status
        ;;
    matrix)
        print_matrix
        ;;
    security)
        print_security
        ;;
    features)
        print_features
        ;;
    all)
        print_status
        printf '\n'
        print_matrix
        printf '\n'
        print_security
        printf '\n'
        print_features
        ;;
    -h|--help|help)
        cat <<'EOF'
Usage: hcl-compatctl [status|matrix|security|features|all]

This HyperMOS integration is intentionally read-only. It reports the
device/partition/security state without changing runtime properties,
attestation configuration, root-hiding rules, or kernel uname.
EOF
        ;;
    *)
        printf 'Unknown command: %s\n' "$1" >&2
        exit 2
        ;;
esac
