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
    # Match the known-good #24 COREPATCH behavior:
    # - keep CN notification fix
    # - do NOT disable secure flag in services.jar / miui-services.jar
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a16.sh \
        --cn-notification-fix
elif [[ $AndroidVER == "17" ]];then
    bash $work_dir/bin/package/COREPATCH/jar_patcher_a17.sh
fi
