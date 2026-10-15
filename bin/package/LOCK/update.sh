#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
images="$work_dir/build/baserom/images"
source "$work_dir/functions.sh"

system="$images/system/system"
system_ext="$images/system_ext"
binary="$work_dir/bin/package/LOCK/system_ext/xbin/ryu_helper"
stock_init="$system/etc/init/hw/init.rc"

[ -d "$system" ] || { error "LOCK: system tree missing"; exit 1; }
[ -d "$system_ext" ] || { error "LOCK: system_ext tree missing"; exit 1; }
[ -s "$stock_init" ] || { error "LOCK: stock /system/etc/init/hw/init.rc missing"; exit 1; }
[ -s "$binary" ] || { error "LOCK: bundled RYU helper missing"; exit 1; }

# Retain the reviewed payload in the repository, without installing/executing it.
# No security-state property writer is permitted by this package.
expected=6d82fc8e92089ce24226636ec4d24deb15655d7a7473d37d24fa4ae53588c1df
actual=$(sha256sum "$binary")
[ "${actual%% *}" = "$expected" ] || {
  error "LOCK: RYU helper changed; review the payload before building"
  exit 1
}

# Read-only audit: never guess how to remove a block from Xiaomi/TNM init.
# Reused image trees with previous LOCK changes must be rebuilt from clean stock.
python3 - "$images" <<'PY'
import os
import pathlib
import sys

images = pathlib.Path(sys.argv[1])
legacy_names = {"hypermos-lock.rc"}
legacy_tokens = (
    b"ryu_helper", b"hypermos-resetprop", b"tnm_resetprop_exec",
    b"hypermos-lock.rc",
)
conflicts = []
def walk_error(exc):
    sys.exit(f"LOCK: cannot audit image directory: {exc}")

for root, dirs, files in os.walk(images, followlinks=False, onerror=walk_error):
    for name in files:
        path = pathlib.Path(root) / name
        relative = path.relative_to(images)
        if name in {"ryu_helper", "hypermos-resetprop"}:
            conflicts.append(str(relative))
            continue
        if name in legacy_names:
            conflicts.append(str(relative))
            continue
        # Include tnm.rc without treating an unrelated TNM file as ours.
        if name.endswith((".rc", ".cil")) or "file_contexts" in name:
            try:
                data = path.read_bytes()
            except OSError as exc:
                sys.exit(f"LOCK: cannot audit {relative}: {exc}")
            if any(token in data for token in legacy_tokens):
                conflicts.append(str(relative))
if conflicts:
    sys.exit(
        "LOCK: existing helper trigger/policy/payload detected; rebuild from a "
        "clean image tree (no files were changed):\n" + "\n".join(sorted(conflicts))
    )
PY

mods "LOCK: security-state spoofing disabled; no helper boot trigger installed"
info "LOCK: Xiaomi init and SELinux left unchanged; RYU helper retained only in source"
