#!/usr/bin/env bash
set -euo pipefail
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
    # HyperMOS A16 test stack on the #48/#49 base:
    # - disable signature verification
    # - disable secure flag
    # - PenguinOS-style CN notification policy
    # - PolicyManager.CN_MODEL=false is applied inside the CN notification patch
    # - long press power -> MiCTS (fail-open to the original Xiaomi action)
    if ! bash "$work_dir/bin/package/COREPATCH/jar_patcher_a16.sh" \
        --disable-signature-verification \
        --cn-notification-fix \
        --disable-secure-flag \
        --micts-power-key \
        --passkey \
        --kaorios-k1; then
        error "COREPATCH A16 failed"
        exit 1
    fi
elif [[ $AndroidVER == "17" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a17.sh
fi
