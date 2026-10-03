#!/usr/bin/env bash
set -e

work_dir=$(pwd)
source "$work_dir/functions.sh"

SRC="$work_dir/bin/package/ResetProp/system_ext"
DST="$work_dir/build/baserom/images/system_ext"
TOOL="$SRC/xbin/xeutoolbox"
POLICY="$DST/etc/selinux/system_ext_sepolicy.cil"

# Restore the ResetProp runtime helper only.
# Keep ROM property files and boot / AVB integrity properties untouched.
[ -f "$TOOL" ] || exit 1

mkdir -p "$DST/xbin"
cp -f "$TOOL" "$DST/xbin/xeutoolbox"
chmod 0755 "$DST/xbin/xeutoolbox"

# xeutoolbox is labelled by bin/fix_selinux.py. Define the SELinux type once
# so the binary remains usable without appending duplicate policy on rebuilds.
if [ -f "$POLICY" ] && ! grep -Fq '(type xeutoolbox_exec)' "$POLICY"; then
    cat >> "$POLICY" <<'EOF'

(type xeutoolbox_exec)
(roletype object_r xeutoolbox_exec)
(typeattributeset file_type (xeutoolbox_exec))
(typeattributeset exec_type (xeutoolbox_exec))
(typeattributeset system_file_type (xeutoolbox_exec))
(allow init xeutoolbox_exec (file (read getattr map execute open execute_no_trans)))
EOF
fi

# Intentionally no init.rc resetprop commands here:
# - no build.prop / system.prop / vendor prop edits
# - no ro.boot.* overrides
# - no ro.secureboot.* overrides
# - no vbmeta digest / size overrides
# - no extra build notification/log spam
exit 0
