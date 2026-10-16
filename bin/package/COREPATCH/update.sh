#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

work_dir=$(pwd)
source $work_dir/functions.sh
AndroidVER=$(cat $work_dir/bin/ddevice/androidver.txt)

if [[ $AndroidVER == "13" ]];then
    bash $work_dir/bin/package/COREPATCH/A13/Penguin13.sh
elif [[ $AndroidVER == "14" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a14.sh
elif [[ $AndroidVER == "15" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a15.sh
elif [[ $AndroidVER == "16" ]];then
    # Port only RYU-derived app/background compatibility behavior on main. The full
    # 44-gate audit profile remains available for explicit offline testing.
    # Signature verification is an existing independent HyperMOS feature and
    # is not part of this compatibility profile.
    tnm_framework_options=(--tnm-app-compat-gates)
    # HyperMOS A16 patch stack:
    # - disable signature verification
    # - disable secure flag
    # - PenguinOS-style CN notification policy
    # - PolicyManager.CN_MODEL=false is applied inside the CN notification patch
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a16.sh \
        --disable-signature-verification \
        --cn-notification-fix \
        --tnm-notification-policy \
        --tnm-zk-power-parity \
        "${tnm_framework_options[@]}" \
        --disable-secure-flag || exit 1
elif [[ $AndroidVER == "17" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a17.sh
fi
