#!/usr/bin/env python3
"""Strict Android 16 one-shot Xiaomi AppOps patch for first-time app installs.

Patches COREPATCH's already-decompiled services.jar. Fail if Xiaomi has
changed the expected hook rather than pretending that the patch worked.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

RELATIVE = Path("com/android/server/pm/BroadcastHelper.smali")
METHOD = "sendPackageAddedForNewUsers(Ljava/lang/String;I[I[IZILandroid/util/SparseArray;)V"
CALL = ("    invoke-direct {p0, p1, p2, p3}, "
        "Lcom/android/server/pm/BroadcastHelper;->hypermosAutoAppOps(Ljava/lang/String;I[I)V")
HELPER = """
# HyperMOS one-shot callback. AOSP sends this only for new package users.
.method private hypermosAutoAppOps(Ljava/lang/String;I[I)V
    .locals 1

    iget-object v0, p0, Lcom/android/server/pm/BroadcastHelper;->mContext:Landroid/content/Context;
    invoke-static {v0, p1, p2, p3}, Lcom/android/server/pm/HyperMOSAutoOps;->apply(Landroid/content/Context;Ljava/lang/String;I[I)V
    return-void
.end method
"""


def patch_tree(root: Path, helper_source: Path) -> tuple[str, bool]:
    matches = sorted(root.glob("smali*/" + str(RELATIVE)))
    if len(matches) != 1:
        raise RuntimeError(f"Need exactly one {RELATIVE}, got {len(matches)}")
    path = matches[0]
    original = path.read_text(encoding="utf-8")
    count = original.count(CALL)
    if count > 1:
        raise RuntimeError("Duplicate hook")
    if count == 1:
        if original.count(".method private hypermosAutoAppOps") != 1:
            raise RuntimeError("Partial patch detected")
        if not (path.parent / "HyperMOSAutoOps.smali").is_file():
            raise RuntimeError("Existing hook missing helper class")
        return str(path), False
    if "hypermosAutoAppOps" in original:
        raise RuntimeError("Unknown existing hook")
    lines = original.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines)
              if line.lstrip().startswith(".method ") and METHOD in line]
    if len(starts) != 1:
        raise RuntimeError(f"Expected one A16 {METHOD}, got {len(starts)}")
    start = starts[0]
    ends = [i for i in range(start + 1, len(lines))
            if lines[i].strip() == ".end method"]
    if not ends:
        raise RuntimeError("Unterminated method")
    end = ends[0]
    if not any(re.match(r"^\s*\.(locals|registers)\s+\d+", x)
               for x in lines[start + 1:end]):
        raise RuntimeError("Unexpected register layout")
    instruction = re.compile(r"^\s*[a-z][a-z0-9/-]*(?:\s|$)")
    insert_at = None
    for i in range(start + 1, end):
        stripped = lines[i].strip()
        if instruction.match(lines[i]) and not stripped.startswith(("end ", "restart ")):
            insert_at = i
            break
    if insert_at is None:
        raise RuntimeError("No first instruction found")
    if not any("mContext:Landroid/content/Context;" in x for x in lines):
        raise RuntimeError("Missing BroadcastHelper context field")
    target = path.parent / "HyperMOSAutoOps.smali"
    if target.exists():
        raise RuntimeError("Unexpected pre-existing helper class")
    source = helper_source.read_text(encoding="utf-8")
    if "Lcom/android/server/pm/HyperMOSAutoOps;" not in source:
        raise RuntimeError("Invalid helper source")
    # Uses existing p0-p3: no register-count changes needed.
    lines.insert(insert_at, CALL + "\n")
    path.write_text("".join(lines).rstrip("\n") + "\n" + HELPER, encoding="utf-8")
    target.write_text(source, encoding="utf-8")
    return str(path), True


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("decompiled_services", type=Path)
    args = parser.parse_args()
    path, changed = patch_tree(args.decompiled_services,
                               Path(__file__).with_name("HyperMOSAutoOps.smali"))
    print(f"[AUTO-APP-OPS] {'patched' if changed else 'already present'}: {path}")
