#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

work_dir=$(pwd)
source $work_dir/functions.sh
AndroidVER=$(cat $work_dir/bin/ddevice/androidver.txt)

if [[ $AndroidVER == "13" ]];then
    if [[ "${COREPATCH_DISABLE_SIGNATURE_VERIFICATION:-1}" == "1" ||
          "${COREPATCH_DISABLE_SECURE_FLAG:-1}" == "1" ]]; then
        bash $work_dir/bin/package/COREPATCH/A13/Penguin13.sh
    else
        info "COREPATCH A13: signature and static Secure Flag patches disabled"
    fi
elif [[ $AndroidVER == "14" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a14.sh
elif [[ $AndroidVER == "15" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a15.sh
elif [[ $AndroidVER == "16" ]];then
    # CN notifications are patched separately in NOTIFICATION_FIX/A16.
    # CorePatch retains signature bypass; permanent FLAG_SECURE bypass is used
    # only when the Kaorios runtime hook is not selected.
    corepatch_options=()
    if [[ "${COREPATCH_DISABLE_SIGNATURE_VERIFICATION:-1}" == "1" ]]; then
        corepatch_options+=(--disable-signature-verification)
    fi
    if [[ "${COREPATCH_DISABLE_SECURE_FLAG:-1}" == "1" ]]; then
        corepatch_options+=(--disable-secure-flag)
    fi
    bash "$work_dir/bin/package/COREPATCH/jar_patcher_a16.sh" \
        "${corepatch_options[@]}" || exit 1
elif [[ $AndroidVER == "17" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a17.sh
fi
