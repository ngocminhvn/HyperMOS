#!/usr/bin/env python3
"""Keep GMS out of the RYU conditional UID kill using its existing package name.

Unlike the former adjacency-sensitive inline patch, this replaces exactly the
existing isLockedApplication() call. The package name passed to that call is
already available in setUidState(), so there is no second UID/package lookup.
No service, periodic task, wakelock, or process monitor is introduced.
"""
from pathlib import Path
import re

SET_UID = "setUidState(IZ)V"
OWNER = "Lcom/miui/powerkeeper/controller/KillProcessController;"
LOCKED = "Lmiui/process/ProcessManager;->isLockedApplication(Ljava/lang/String;I)Z"
WRAPPER = OWNER + "->tnmIsGmsOrLocked(Ljava/lang/String;I)Z"
LOOKUP = "->getPackageNameByUid("
GMS = "com.google.android.gms"

METHOD_RE = re.compile(
    r"(?ms)^\.method[^\n]*[ \t]" + re.escape(SET_UID)
    + r"[ \t]*$.*?^\.end method[ \t]*$"
)
INVOKE_RE = re.compile(
    r"(?m)^[ \t]*invoke-static(?:/range)?[ \t]+\{[^}\n]+\},[ \t]*"
    + re.escape(LOCKED) + r"[ \t]*$"
)
HELPER = """
# GMS-only exception for the existing locked-app/UID-kill gate.
# Package name was resolved by setUidState; do not resolve UID again.
.method private static tnmIsGmsOrLocked(Ljava/lang/String;I)Z
    .locals 1
    const-string v0, "com.google.android.gms"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :tnm_check_existing_lock
    const/4 v0, 0x1
    return v0
    :tnm_check_existing_lock
    invoke-static {p0, p1}, Lmiui/process/ProcessManager;->isLockedApplication(Ljava/lang/String;I)Z
    move-result v0
    return v0
.end method
"""


def patch_method(uid_method: str) -> str:
    if "tnmIsGmsOrLocked" in uid_method or GMS in uid_method:
        raise ValueError("GMS protection has already been applied")
    if uid_method.count(LOOKUP) != 1:
        raise ValueError("Expected a single existing package-name lookup")
    if uid_method.count(LOCKED) != 1:
        raise ValueError("Expected a single existing locked-application call")
    hits = list(INVOKE_RE.finditer(uid_method))
    if len(hits) != 1:
        raise ValueError("Existing locked-application invocation is missing or ambiguous")
    # Only the call target changes; registers, branch targets and control flow
    # in RYU's original setUidState remain byte-for-byte identical.
    hit = hits[0]
    changed = hit.group().replace(LOCKED, WRAPPER)
    result = uid_method[:hit.start()] + changed + uid_method[hit.end():]
    if result.count(LOOKUP) != 1 or result.count(WRAPPER) != 1:
        raise ValueError("Unexpected change to package lookup or UID guard")
    return result


def patch(root: Path) -> dict:
    hits = list(root.rglob("KillProcessController.smali"))
    if len(hits) != 1:
        raise ValueError(f"Expected one KillProcessController, got {len(hits)}")
    path = hits[0]
    source = path.read_text(encoding="utf-8")
    if WRAPPER in source or "tnmIsGmsOrLocked(" in source:
        raise ValueError("GMS UID protection already exists")
    methods = list(METHOD_RE.finditer(source))
    if len(methods) != 1:
        raise ValueError("setUidState method missing or ambiguous")
    m = methods[0]
    patched = patch_method(m.group())
    updated = source[:m.start()] + patched + source[m.end():] + "\n" + HELPER
    if updated.count(LOOKUP) != source.count(LOOKUP):
        raise ValueError("Unexpected extra UID/package lookup")
    if updated.count("->shouldKillByCheckerPolicy(I)Z") != source.count("->shouldKillByCheckerPolicy(I)Z"):
        raise ValueError("Unexpected change to UID kill policy")
    path.write_text(updated, encoding="utf-8")
    return {
        "gms_uid_kill_exemption": "shared existing locked-app gate",
        "reused_package_lookup": True,
        "additional_package_lookup": 0,
        "additional_helper_method": 1,
        "new_daemon_or_timer": False,
        "other_uid_policies_unchanged": True,
    }
