#!/usr/bin/env bash
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
device_file="$work_dir/bin/ddevice/device_f.txt"
android_file="$work_dir/bin/ddevice/androidver.txt"

[[ -s "$device_file" && -s "$android_file" ]] || { error "TNM FULL PERF: device metadata missing"; exit 1; }
device="$(tr '[:upper:]' '[:lower:]' < "$device_file" | tr -d '\r\n')"
android="$(tr -d '\r\n' < "$android_file")"
if [[ "$device" != "haotian" || "$android" != "16" ]]; then
  mods "TNM FULL PERF: not HAOTIAN Android 16, skip"
  exit 0
fi

# PowerKeeper and framework power/thermal policy now follow the original ZKOS
# bytecode. Do not overlay the former RYU/TNM CPU/boost/powerhint/ODM thermal
# profiles, KGSL SELinux access, or PerfHook init when building ZKOS-parity main.
# Keep base-ROM vendor/ODM safety and performance files as shipped by Xiaomi.
if [[ "${GITHUB_REF_NAME:-}" == "main" ]]; then
  mods "ZKOS POWER/THERMAL: keep Xiaomi base thermal/perf XML; no RYU/TNM profile overlay"
  exit 0
fi

# Validated TNM performance import is supported on HAOTIAN main.
case "${GITHUB_REF_NAME:-}" in
  main)
    ;;
  *)
    error "TNM FULL PERF: unsupported branch, actual=${GITHUB_REF_NAME:-unknown}"
    exit 1
    ;;
esac

artifact="${TNM_REF_DIR:-}"
[[ -n "$artifact" && -s "$artifact/manifest.json" ]] || {
  error "TNM FULL PERF: missing validated repository thermal ZIP reference"
  exit 1
}
python3 "$work_dir/bin/modfile/UpdateFile/TNMPerfProfile/port_tnm_perf.py" \
  --artifact "$artifact" \
  --rom "$work_dir/build/baserom/images"
python3 "$work_dir/bin/modfile/UpdateFile/TNMPerfProfile/port_tnm_thermal_profiles.py" \
  --artifact "$artifact" \
  --rom "$work_dir/build/baserom/images"

mods "TNM FULL PERF: original powerhint/perf plus verified ODM app thermal profiles staged (charging and no-limit untouched)"

# Live #115 evidence: KGSL frequency nodes are root:root 0644 and
# system_app lacks SELinux file write. Retain all thermal services/limits.
vendor_policy="$work_dir/build/baserom/images/vendor/etc/selinux/vendor_sepolicy.cil"
[[ -s "$vendor_policy" ]] || { error "TNM PERF: vendor CIL missing"; exit 1; }
for rule in '(allow system_app vendor_sysfs_kgsl (file (write)))' \
            '(allow init vendor_sysfs_kgsl (file (setattr)))'; do
  if ! grep -Fqx "$rule" "$vendor_policy"; then
    printf '\n%s\n' "$rule" >> "$vendor_policy"
  fi
done
install -Dm644 "$work_dir/bin/modfile/UpdateFile/TNMPerfProfile/tnm-perfhook-access.rc" \
  "$work_dir/build/baserom/images/system_ext/etc/init/tnm-perfhook-access.rc"
install -Dm755 "$work_dir/bin/modfile/UpdateFile/TNMPerfProfile/tnm-thermalctl" \
  "$work_dir/build/baserom/images/system_ext/bin/tnm-thermalctl"
# Force init to compile modified split CIL instead of an old binary policy.
for part in vendor odm; do
  policy_dir="$work_dir/build/baserom/images/$part/etc/selinux"
  if [[ -d "$policy_dir" ]]; then
    find "$policy_dir" -maxdepth 1 -type f -name 'precompiled_sepolicy*' -delete
  fi
done
mods "TNM PERF: KGSL min/max system-group access staged; thermal limits retained"
