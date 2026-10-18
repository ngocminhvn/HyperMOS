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
    # CN notification fix: restore the complete pre-ZK policy (no class exclusions).
    # Do NOT apply ZKOS miui-services power/Doze parity or RYU app/background gates.
    # Keep the pre-existing CorePatch signature and FLAG_SECURE integration.
    bash "$work_dir/bin/package/COREPATCH/jar_patcher_a16.sh" \
        --disable-signature-verification \
        --cn-notification-fix \
        --disable-secure-flag || exit 1
elif [[ $AndroidVER == "17" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a17.sh
fi
