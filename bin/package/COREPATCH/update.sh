#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

work_dir=$(pwd)
source $work_dir/functions.sh
AndroidVER=$(cat $work_dir/bin/ddevice/androidver.txt)

# No option: full standalone HyperMOS CorePatch.
# --kaorios: keep HyperMOS-only patches and disable methods owned by Kaorios.
case "${1:-}" in
    "")
        export COREPATCH_DISABLE_SIGNATURE_VERIFICATION=1
        export COREPATCH_RUN_HYPERMOS_EXTRAS=1
        info "COREPATCH: full HyperMOS profile"
        ;;
    --kaorios)
        export COREPATCH_DISABLE_SIGNATURE_VERIFICATION=0
        export COREPATCH_RUN_HYPERMOS_EXTRAS=1
        info "COREPATCH: HyperMOS + Kaorios compatibility profile (overlap disabled)"
        ;;
    *)
        error "COREPATCH: unknown option: $1 (supported: --kaorios)"
        exit 1
        ;;
esac

if [[ $AndroidVER == "15" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a15.sh
elif [[ $AndroidVER == "16" ]];then
    # CN notifications are patched separately in NOTIFICATION_FIX/A16.
    # Signature/downgrade is disabled in the HyperMOS Kaorios-compat profile.
    corepatch_options=()
    if [[ "$COREPATCH_DISABLE_SIGNATURE_VERIFICATION" == "1" ]]; then
        corepatch_options+=(--disable-signature-verification)
    fi
    bash "$work_dir/bin/package/COREPATCH/jar_patcher_a16.sh" \
        "${corepatch_options[@]}" || exit 1
elif [[ $AndroidVER == "17" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a17.sh
else
    error "COREPATCH: unsupported Android version: $AndroidVER (supported: 15, 16, 17)"
    exit 1
fi
