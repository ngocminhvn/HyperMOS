#!/usr/bin/env python3
"""HyperMOS Android 16 MiCTS/Google Assistant services.jar self-heal patch.

Two event-driven hooks:
1. Force RoleObserver's resolved assistant package to Google, while still letting
   framework dynamically resolve the actual VoiceInteractionService component.
2. If showSessionFromSession() sees mImpl == null, resync RoleObserver inside
   system_server, then ask the existing switchImplementationIfNeededLocked(true)
   path to rebind once before continuing.

No daemon, polling loop, hardcoded GsaVoiceInteractionService class, or direct
SettingsProvider write is used.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

GOOGLE_PACKAGE = "com.google.android.googlequicksearchbox"
ROLE_MARKER = "HyperMOS MiCTS: force Google assistant package"
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


def patch_role_observer(root: Path) -> Path:
    path = unique_file(
        root,
        lambda t: "getRoleHoldersAsUser" in t
        and "onRoleHoldersChanged" in t
        and "android.app.role.ASSISTANT" in t,
        "RoleObserver",
    )
    lines = read(path)

    if any(ROLE_MARKER in line for line in lines):
        # Fail closed if marker exists but payload was damaged.
        joined = "\n".join(lines)
        if GOOGLE_PACKAGE not in joined or "Collections;->singletonList" not in joined:
            raise PatchError(f"RoleObserver marker present but payload incomplete: {path}")
        return path

    call_indexes = [
        i
        for i, line in enumerate(lines)
        if "Landroid/app/role/RoleManager;->getRoleHoldersAsUser(" in line
        and ")Ljava/util/List;" in line
    ]
    if len(call_indexes) != 1:
        raise PatchError(
            f"RoleObserver getRoleHoldersAsUser: expected 1 call, found {len(call_indexes)} in {path}"
        )

    call_i = call_indexes[0]
    start, end = method_bounds(lines, call_i)
    if "onRoleHoldersChanged(" not in lines[start]:
        raise PatchError(f"role-holder call is not inside onRoleHoldersChanged(): {path}")

    move_i = None
    reg = None
    for i in range(call_i + 1, min(call_i + 6, end + 1)):
        m = re.match(r"\s*move-result-object\s+([vp]\d+)\s*$", lines[i])
        if m:
            move_i = i
            reg = m.group(1)
            break
        if lines[i].strip() and not lines[i].lstrip().startswith(("#", ".")):
            break
    if move_i is None or reg is None:
        raise PatchError(f"RoleObserver move-result-object not found after role query: {path}")

    indent = re.match(r"\s*", lines[move_i]).group(0)
    payload = [
        f"{indent}# {ROLE_MARKER}",
        f'{indent}const-string {reg}, "{GOOGLE_PACKAGE}"',
        f"{indent}invoke-static {{{reg}}}, Ljava/util/Collections;->singletonList(Ljava/lang/Object;)Ljava/util/List;",
        f"{indent}move-result-object {reg}",
    ]
    lines[move_i + 1:move_i + 1] = payload
    write(path, lines)
    return path


def patch_show_session(root: Path) -> Path:
    path = unique_file(
        root,
        lambda t: WARN_TEXT in t and "showSessionFromSession(" in t,
        "VoiceInteraction showSessionFromSession",
    )
    lines = read(path)

    helper_name = "hypermosEnsureGoogleVoiceInteractionLocked()V"
    if any(HEAL_MARKER in line for line in lines):
        joined = "\\n".join(lines)
        required = (
            "switchImplementationIfNeededLocked(Z)V",
            helper_name,
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
    joined = "\\n".join(lines)
    if "switchImplementationIfNeededLocked(Z)V" not in joined:
        raise PatchError(
            f"switchImplementationIfNeededLocked(Z)V not found in same class; refusing unsafe patch: {path}"
        )
    if f"{owner}->mCurUser:I" not in joined and " mCurUser:I" not in joined:
        raise PatchError(f"mCurUser field not found in VoiceInteraction stub: {path}")

    role_desc = None
    for line in lines:
        m = re.search(r"\\bmRoleObserver:(L[^;]+;)", line)
        if m:
            role_desc = m.group(1)
            break
    if role_desc is None:
        raise PatchError(f"mRoleObserver field descriptor not found: {path}")

    candidate = None
    field_desc = None
    for i in range(start + 1, warn_i):
        m = re.match(
            r"\\s*iget-object\\s+([vp]\\d+),\\s*p0,\\s*"
            + re.escape(owner)
            + r"->mImpl:(L[^;]+;)\\s*$",
            lines[i],
        )
        if not m:
            continue
        reg = m.group(1)
        desc = m.group(2)
        for j in range(i + 1, min(i + 5, warn_i)):
            b = re.match(
                rf"\\s*if-nez\\s+{re.escape(reg)},\\s*(:[A-Za-z0-9_]+)\\s*$",
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
        raise PatchError(f"non-null continuation label {continue_label} missing: {path}")

    indent = re.match(r"\\s*", lines[branch_i]).group(0)
    payload = [
        f"{indent}# {HEAL_MARKER}",
        f"{indent}invoke-direct {{p0}}, {owner}->hypermosEnsureGoogleVoiceInteractionLocked()V",
        f"{indent}iget-object {reg}, p0, {owner}->mImpl:{field_desc}",
        f"{indent}if-nez {reg}, {continue_label}",
    ]
    lines[branch_i + 1:branch_i + 1] = payload

    helper = [
        "",
        f".method private hypermosEnsureGoogleVoiceInteractionLocked()V",
        "    .locals 3",
        "",
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


def verify(role_path: Path, show_path: Path) -> None:
    role = role_path.read_text(encoding="utf-8")
    show = show_path.read_text(encoding="utf-8")

    checks = {
        "role marker": ROLE_MARKER in role,
        "Google package": GOOGLE_PACKAGE in role,
        "dynamic VIS resolution": "VoiceInteractionService" in role,
        "singleton forced role view": "Ljava/util/Collections;->singletonList" in role,
        "heal marker": HEAL_MARKER in show,
        "framework retry": "switchImplementationIfNeededLocked(Z)V" in show,
        "RoleObserver resync helper": "hypermosEnsureGoogleVoiceInteractionLocked()V" in show,
        "Assistant role resync": "android.app.role.ASSISTANT" in show,
        "stock failure log retained": WARN_TEXT in show,
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
        role_path = patch_role_observer(root)
        show_path = patch_show_session(root)
        verify(role_path, show_path)
    except PatchError as exc:
        print(f"[MICTS-SELF-HEAL][ERROR] {exc}", file=sys.stderr)
        return 1

    print(f"[MICTS-SELF-HEAL] RoleObserver: {role_path}")
    print(f"[MICTS-SELF-HEAL] showSessionFromSession: {show_path}")
    print("[MICTS-SELF-HEAL] verification OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
