#!/usr/bin/env python3
"""HyperMOS Android 16 MiCTS VoiceInteraction self-heal patch.

Stock RoleObserver behavior is left untouched.

Only when showSessionFromSession() is called while mImpl == null:
1. Ask the existing framework switchImplementationIfNeededLocked(true) path
   to rebuild/rebind the current VoiceInteractionService once.
2. If mImpl is still null, invoke the stock RoleObserver once for the current
   ASSISTANT role and retry the framework rebind.

No daemon, polling loop, forced Google role callback, hardcoded
GsaVoiceInteractionService class, or direct SettingsProvider write is used.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

HEAL_MARKER = "HyperMOS MiCTS: one-shot VoiceInteraction self-heal"
WARN_TEXT = "showSessionFromSession without running voice interaction service"


class PatchError(RuntimeError):
    pass


def smali_files(root: Path):
    yield from root.rglob("*.smali")


def read(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def write(path: Path, lines: list[str]) -> None:
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def class_descriptor(lines: list[str], path: Path) -> str:
    for line in lines[:80]:
        m = re.match(r"\s*\.class\b.*\s(L[^;]+;)\s*$", line)
        if m:
            return m.group(1)
    raise PatchError(f"cannot resolve class descriptor: {path}")


def method_bounds(lines: list[str], needle_index: int) -> tuple[int, int]:
    start = None
    for i in range(needle_index, -1, -1):
        if lines[i].lstrip().startswith(".method"):
            start = i
            break
    if start is None:
        raise PatchError("method start not found")

    for i in range(needle_index, len(lines)):
        if lines[i].lstrip().startswith(".end method"):
            return start, i
    raise PatchError("method end not found")


def unique_file(root: Path, predicate, description: str) -> Path:
    matches = []
    for path in smali_files(root):
        text = path.read_text(encoding="utf-8", errors="strict")
        if predicate(text):
            matches.append(path)
    if len(matches) != 1:
        raise PatchError(
            f"{description}: expected exactly 1 smali file, found {len(matches)}: "
            + ", ".join(str(p) for p in matches[:8])
        )
    return matches[0]


def patch_show_session(root: Path) -> Path:
    path = unique_file(
        root,
        lambda t: WARN_TEXT in t
        and "showSessionFromSession(" in t
        and "switchImplementationIfNeededLocked(Z)V" in t,
        "VoiceInteraction showSessionFromSession",
    )
    lines = read(path)

    helper_name = "hypermosHealVoiceInteractionLocked()V"
    if any(HEAL_MARKER in line for line in lines):
        joined = "\n".join(lines)
        required = (
            helper_name,
            "switchImplementationIfNeededLocked(Z)V",
            "mRoleObserver:",
            "android.app.role.ASSISTANT",
        )
        if not all(value in joined for value in required):
            raise PatchError(f"self-heal marker present but payload incomplete: {path}")
        return path

    warn_indexes = [i for i, line in enumerate(lines) if WARN_TEXT in line]
    if len(warn_indexes) != 1:
        raise PatchError(
            f"showSession warning: expected 1 occurrence, found {len(warn_indexes)} in {path}"
        )

    warn_i = warn_indexes[0]
    start, end = method_bounds(lines, warn_i)
    if "showSessionFromSession(" not in lines[start]:
        raise PatchError(f"warning is not inside showSessionFromSession(): {path}")

    owner = class_descriptor(lines, path)
    joined = "\n".join(lines)

    role_desc = None
    for line in lines:
        m = re.search(r"\bmRoleObserver:(L[^;]+;)", line)
        if m:
            role_desc = m.group(1)
            break
    if role_desc is None:
        raise PatchError(f"mRoleObserver field descriptor not found: {path}")

    if f"{owner}->mCurUser:I" not in joined and "->mCurUser:I" not in joined:
        raise PatchError(f"mCurUser field not found: {path}")

    candidate = None
    field_desc = None
    for i in range(start + 1, warn_i):
        m = re.match(
            r"\s*iget-object\s+([vp]\d+),\s*p0,\s*"
            + re.escape(owner)
            + r"->mImpl:(L[^;]+;)\s*$",
            lines[i],
        )
        if not m:
            continue

        reg = m.group(1)
        desc = m.group(2)
        for j in range(i + 1, min(i + 6, warn_i)):
            b = re.match(
                rf"\s*if-nez\s+{re.escape(reg)},\s*(:[A-Za-z0-9_]+)\s*$",
                lines[j],
            )
            if b:
                candidate = (j, reg, b.group(1))
                field_desc = desc
                break
        if candidate:
            break

    if candidate is None or field_desc is None:
        raise PatchError(
            f"mImpl null-guard pattern not found before showSession warning: {path}"
        )

    branch_i, reg, continue_label = candidate
    if not any(line.strip() == continue_label for line in lines[branch_i + 1:end + 1]):
        raise PatchError(f"continuation label {continue_label} missing: {path}")

    indent = re.match(r"\s*", lines[branch_i]).group(0)
    payload = [
        f"{indent}# {HEAL_MARKER}",
        f"{indent}invoke-direct {{p0}}, {owner}->{helper_name}",
        f"{indent}iget-object {reg}, p0, {owner}->mImpl:{field_desc}",
        f"{indent}if-nez {reg}, {continue_label}",
    ]
    lines[branch_i + 1:branch_i + 1] = payload

    helper = [
        "",
        f".method private {helper_name}",
        "    .locals 3",
        "",
        "    # First retry the current configured VoiceInteractionService.",
        "    const/4 v0, 0x1",
        f"    invoke-virtual {{p0, v0}}, {owner}->switchImplementationIfNeededLocked(Z)V",
        "",
        f"    iget-object v0, p0, {owner}->mImpl:{field_desc}",
        "    if-nez v0, :hypermos_micts_done",
        "",
        "    # Still missing: resync the stock ASSISTANT role once, then retry.",
        f"    iget-object v0, p0, {owner}->mRoleObserver:{role_desc}",
        "    if-eqz v0, :hypermos_micts_done",
        "",
        f"    iget v1, p0, {owner}->mCurUser:I",
        "    invoke-static {v1}, Landroid/os/UserHandle;->of(I)Landroid/os/UserHandle;",
        "    move-result-object v1",
        "",
        '    const-string v2, "android.app.role.ASSISTANT"',
        f"    invoke-virtual {{v0, v2, v1}}, {role_desc}->onRoleHoldersChanged(Ljava/lang/String;Landroid/os/UserHandle;)V",
        "",
        "    const/4 v0, 0x1",
        f"    invoke-virtual {{p0, v0}}, {owner}->switchImplementationIfNeededLocked(Z)V",
        "",
        ":hypermos_micts_done",
        "    return-void",
        ".end method",
    ]
    lines.extend(helper)

    write(path, lines)
    return path


def verify(show_path: Path) -> None:
    show = show_path.read_text(encoding="utf-8")
    checks = {
        "heal marker": HEAL_MARKER in show,
        "self-heal helper": "hypermosHealVoiceInteractionLocked()V" in show,
        "framework retry": show.count("switchImplementationIfNeededLocked(Z)V") >= 2,
        "stock role resync fallback": "android.app.role.ASSISTANT" in show,
        "stock failure log retained": WARN_TEXT in show,
        "no forced Google package": "HyperMOS MiCTS: force Google assistant package" not in show,
    }
    failed = [name for name, ok in checks.items() if not ok]
    if failed:
        raise PatchError("verification failed: " + ", ".join(failed))


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} <services-decompile-dir>", file=sys.stderr)
        return 2

    root = Path(sys.argv[1]).resolve()
    if not root.is_dir():
        print(f"not a directory: {root}", file=sys.stderr)
        return 2

    try:
        show_path = patch_show_session(root)
        verify(show_path)
    except PatchError as exc:
        print(f"[MICTS-SELF-HEAL][ERROR] {exc}", file=sys.stderr)
        return 1

    print("[MICTS-SELF-HEAL] stock RoleObserver left untouched")
    print(f"[MICTS-SELF-HEAL] showSessionFromSession: {show_path}")
    print("[MICTS-SELF-HEAL] verification OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
