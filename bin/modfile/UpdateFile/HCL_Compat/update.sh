#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

src_ctl="$work_dir/bin/modfile/UpdateFile/HCL_Compat/hcl-compatctl.sh"
images="$work_dir/build/baserom/images"

[[ -f "$src_ctl" ]] || { error "HCL Compat: hcl-compatctl.sh missing"; exit 1; }

if [[ -d "$images/system_ext" ]]; then
  bin_dst="$images/system_ext/bin"
  runtime_ctl="/system_ext/bin/hcl-compatctl"
elif [[ -d "$images/product" ]]; then
  bin_dst="$images/product/bin"
  runtime_ctl="/product/bin/hcl-compatctl"
elif [[ -d "$images/system/system" ]]; then
  bin_dst="$images/system/system/bin"
  runtime_ctl="/system/bin/hcl-compatctl"
else
  error "HCL Compat: no suitable partition found"
  exit 1
fi

mods "HCL Compat read-only diagnostics"
mkdir -p "$bin_dst"
cp -f "$src_ctl" "$bin_dst/hcl-compatctl"
chmod 0755 "$bin_dst/hcl-compatctl"

[[ -x "$bin_dst/hcl-compatctl" ]] || {
  error "HCL Compat: installed controller is not executable"
  exit 1
}

# Safety guard: this ROM integration must remain diagnostic-only.
# Descriptive text such as "resetprop_mutation=false" is allowed; executable
# mutation commands are not.
for forbidden in   '(^|[[:space:]])resetprop[[:space:]]'   '(^|[[:space:]])setprop[[:space:]]'   '(^|[[:space:]])sed[[:space:]]+-i[[:space:]]'   '(^|[[:space:]])set_uname[[:space:]]'   '(^|[[:space:]])add_sus_path[[:space:]]'   '(^|[[:space:]])add_open_redirect[[:space:]]'   '/data/adb/tricky_store/'   '/data/adb/modules/'   'target\.txt'   'app_keybox\.map'; do
  if grep -Eqi "$forbidden" "$bin_dst/hcl-compatctl"; then
    error "HCL Compat: forbidden mutating capability detected: $forbidden"
    exit 1
  fi
done

mods "HCL Compat -> $runtime_ctl"
mods "HCL Compat -> Done"
