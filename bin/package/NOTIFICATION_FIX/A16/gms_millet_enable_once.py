#!/usr/bin/env python3
"""Android 16 EU PowerKeeper: boot-time-only GMS Millet exemption.

Patch ONLY ActiveStateController.enable()'s successful-return path.
Do not modify dealNoRestrictApp(), callbacks, observers, or periodic work.
The original Xiaomi method retains its short-circuit/early-return paths.
"""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

CLASS = "Lcom/miui/powerkeeper/controller/ActiveStateController;"
GMS = "com.google.android.gms"
KEY = "MILLET_NO_RESTRICT_APP"

# Use existing local registers v0-v5 AFTER the original monitor-exit.
# No extra register, method, field, background thread, observer or daemon.
INJECTION = r"""
    :tnm_millet_boot_try_start
    iget-object v0, p0, Lcom/miui/powerkeeper/controller/ActiveStateController;->mContext:Landroid/content/Context;
    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    const-string v1, "MILLET_NO_RESTRICT_APP"
    const-string v2, "com.google.android.gms"
    invoke-static {v0, v1}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :tnm_millet_boot_write
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z
    move-result v4
    if-nez v4, :tnm_millet_boot_write
    const-string v4, ","
    invoke-virtual {v3, v4}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v4
    invoke-static {v4}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v4
    invoke-interface {v4, v2}, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v5
    if-nez v5, :tnm_millet_boot_try_end
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, ","
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    :tnm_millet_boot_write
    invoke-static {v0, v1, v2}, Landroid/provider/Settings$System;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z
    :tnm_millet_boot_try_end
    .catch Ljava/lang/Exception; {:tnm_millet_boot_try_start .. :tnm_millet_boot_try_end} :tnm_millet_boot_handler
    goto :tnm_millet_boot_return
    :tnm_millet_boot_handler
    move-exception v0
    :tnm_millet_boot_return
"""

TARGET = re.compile(r"(?ms)^\.method[^\n]*\senable\(\)V[ \t]*\n.*?^\.end method[ \t]*$")
RETURN = re.compile(r"(?m)^[ \t]+return-void[ \t]*$")


def patch(src: str) -> tuple[str, dict]:
    if f".class public {CLASS}" not in src and f".class {CLASS}" not in src:
        raise ValueError("Unexpected ActiveStateController class identity")
    if "tnm_millet_boot_try_start" in src:
        raise ValueError("Boot-only Millet patch already present")
    methods = list(TARGET.finditer(src))
    if len(methods) != 1:
        raise ValueError(f"Expected exactly one enable()V method; found {len(methods)}")
    old = methods[0].group()
    # Pinned EU Android 16 enable(): 12 registers, 1 parameter,
    # three returns: two early exits and the completed enable() path.
    if not re.search(r"(?m)^[ \t]+\.locals 11[ \t]*$", old):
        raise ValueError("EU enable() register layout changed")
    returns = list(RETURN.finditer(old))
    if len(returns) != 3 or "monitor-exit" not in old or ".catchall" not in old:
        raise ValueError("EU enable() exit / monitor layout changed")
    last = returns[-1]
    # The last return must follow the original monitor-exit. Patch only
    # this normal success return, never early exits or the catchall path.
    if not re.search(r"(?m)^[ \t]+monitor-exit v\d+[ \t]*$", old[:last.start()]):
        raise ValueError("Missing completed-enable monitor exit")
    altered = old[:last.start()] + INJECTION + "    return-void" + old[last.end():]
    if altered.replace(INJECTION + "    return-void", old[last.start():last.end()], 1) != old:
        raise ValueError("Patch modifies more than the final return path")
    new_src = src[:methods[0].start()] + altered + src[methods[0].end():]
    # Ensure no other methods (including dealNoRestrictApp) were edited.
    if new_src.replace(altered, old, 1) != src:
        raise ValueError("Unexpected unrelated Smali edits")
    return new_src, {
        "class": CLASS, "method": "enable()V", "when": "completed_enable_only",
        "gms_package": GMS, "settings_key": KEY,
        "writes_only_if_absent": True, "preserves_existing_packages": True,
        "modifies_dealNoRestrictApp": False,
        "new_background_worker": False, "new_observer": False,
        "new_polling": False, "new_registers": 0,
        "early_return_paths_untouched": len(returns) - 1,
        "old_smali_sha256": hashlib.sha256(src.encode()).hexdigest(),
        "new_smali_sha256": hashlib.sha256(new_src.encode()).hexdigest(),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--smali", required=True, type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    old = args.smali.read_text(encoding="utf-8")
    result, report = patch(old)
    args.smali.write_text(result, encoding="utf-8")
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[POWERKEEPER GMS MILLET BOOT] " + json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as exc:
        print("[POWERKEEPER GMS MILLET BOOT] FAIL: " + str(exc), file=sys.stderr)
        raise SystemExit(1)
