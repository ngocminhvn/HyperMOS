#!/usr/bin/env python3
"""Selectively reproduce RYUOS HAOTIAN GmsObserver's RYU-build gates.

The actual RYUOS PowerKeeper APK differs from Xiaomi's GmsObserver in only
two method bodies: constructor and updateGoogleSync(Z)V. Both replace the
stock IS_INTERNATIONAL_BUILD query with IS_RYU_BUILD. We reproduce the
true outcome of those gates without RYU dependencies, without bypassing
the existing isGmsControlEnabled() logic or changing Doze/thermal policy.
"""
from pathlib import Path
import re
import sys

CLASS = "GmsObserver"
GATE = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
RYU_GATE = "Lcom/projectryu/Build;->IS_RYU_BUILD:Z"
METHODS = ("<init>(Landroid/content/Context;)V", "updateGoogleSync(Z)V")


def patch_method(text: str, signature: str) -> str:
    method = re.compile(
        rf"(?ms)^\.method[^\n]*[ \t]{re.escape(signature)}[ \t]*\n"
        rf".*?^\.end method[ \t]*$"
    )
    found = list(method.finditer(text))
    if len(found) != 1:
        raise ValueError(f"{signature}: expected exactly one method, got {len(found)}")
    m = found[0]
    body = m.group()
    marker = "# HyperMOS RYU GMS true-build gate"
    if marker in body:
        return text
    hits = list(re.finditer(
        r"(?m)^(?P<indent>[ \t]*)sget-boolean[ \t]+(?P<reg>[vp]\d+),[ \t]*"
        + re.escape(GATE) + r"[ \t]*$", body
    ))
    if len(hits) != 1 or RYU_GATE in body:
        raise ValueError(f"{signature}: unexpected GMS build-gate layout")
    gate = hits[0]
    reg = gate.group("reg")
    if reg.startswith("v") and int(reg[1:]) > 15:
        raise ValueError(f"Unsafe GMS gate register {reg}")
    # A p-register may be encoded as v16+ on Android 16; a direct const/4
    # cannot address such a register. Explicitly fail instead of producing
    # an invalid DEX.
    if reg.startswith("p"):
        direct = re.search(r"(?m)^\s*\.(?:locals|registers)\s+(\d+)", body)
        if not direct:
            raise ValueError(f"{signature}: no register declaration")
        count = int(direct.group(1))
        if count > 15:
            raise ValueError(f"{signature}: cannot safely write {reg} with const/4")
    line = gate.group("indent") + marker + "\n" + gate.group("indent") + "const/4 " + reg + ", 0x1"
    changed = body[:gate.start()] + line + body[gate.end():]
    return text[:m.start()] + changed + text[m.end():]


def patch_file(source: str) -> str:
    text = source
    for signature in METHODS:
        text = patch_method(text, signature)
    if "isGmsControlEnabled()Z" not in text:
        raise ValueError("Core GmsObserver control method missing")
    return text


def main(root: Path):
    hits = list(root.rglob(CLASS + ".smali"))
    if len(hits) != 1:
        raise ValueError(f"{CLASS}: expected one class, got {len(hits)}")
    target = hits[0]
    original = target.read_text(encoding="utf-8")
    patched = patch_file(original)
    if patch_file(patched) != patched:
        raise ValueError("GmsObserver patch is not idempotent")
    target.write_text(patched, encoding="utf-8")
    print("[RYU-A16-GMS] RYU-equivalent GMS gates active; original isGmsControlEnabled untouched")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: ryu_gms_observer_a16.py <PowerKeeper-decompile-root>")
        main(Path(sys.argv[1]))
    except (ValueError, OSError) as exc:
        print(f"[RYU-A16-GMS] FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
