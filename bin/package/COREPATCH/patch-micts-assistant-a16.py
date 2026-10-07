#!/usr/bin/env python3
"""HyperMOS Android 16 MiCTS VoiceInteraction self-heal patch.

Normal RoleObserver behavior stays stock.

Only when showSessionFromSession() is called while mImpl == null:
1. Set a one-shot internal flag and invoke RoleObserver.
   Only that callback sees com.google.android.googlequicksearchbox as the
   ASSISTANT holder; all normal RoleObserver callbacks remain stock.
2. Clear the flag immediately and ask the framework to rebind.

The actual Google VoiceInteractionService component is still resolved dynamically.
No daemon, polling loop, permanent Google-role override, hardcoded
GsaVoiceInteractionService component, or direct SettingsProvider write is used.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

GOOGLE_PACKAGE = "com.google.android.googlequicksearchbox"
HEAL_MARKER = "HyperMOS MiCTS: one-shot VoiceInteraction self-heal"
ROLE_MARKER = "HyperMOS MiCTS: conditional Google assistant fallback"
FLAG_FIELD = "mHypermosForceGoogleAssistant"
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


def ensure_flag_field(path: Path, owner: str) -> None:
    lines = read(path)
    field = f".field private {FLAG_FIELD}:Z"
    if any(line.strip() == field for line in lines):
        return

    field_indexes = [i for i, line in enumerate(lines) if line.lstrip().startswith(".field ")]
    if not field_indexes:
        raise PatchError(f"no .field anchor found in VoiceInteraction class: {path}")

    insert_at = field_indexes[-1] + 1
    lines.insert(insert_at, field)
    write(path, lines)


def find_role_observer(root: Path, owner: str) -> tuple[Path, str]:
    path = unique_file(
        root,
        lambda t: "getRoleHoldersAsUser" in t
        and "onRoleHoldersChanged" in t
        and "android.app.role.ASSISTANT" in t,
        "RoleObserver",
    )
    lines = read(path)
    role_desc = class_descriptor(lines, path)

    this_outer = None
    for line in lines:
        m = re.search(r"->this\$0:(L[^;]+;)", line)
        if m:
            this_outer = m.group(1)
            break
    if this_outer != owner:
        raise PatchError(
            f"RoleObserver outer mismatch: expected {owner}, found {this_outer} in {path}"
        )
    return path, role_desc


def patch_role_observer(path: Path, role_desc: str, owner: str) -> None:
    lines = read(path)
    joined = "\n".join(lines)

    if ROLE_MARKER in joined:
        required = (
            GOOGLE_PACKAGE,
            f"{owner}->{FLAG_FIELD}:Z",
            "Ljava/util/Collections;->singletonList",
        )
        if not all(value in joined for value in required):
            raise PatchError(f"conditional Google fallback marker is incomplete: {path}")
        return

    calls = [
        i
        for i, line in enumerate(lines)
        if "Landroid/app/role/RoleManager;->getRoleHoldersAsUser(" in line
        and ")Ljava/util/List;" in line
    ]
    if len(calls) != 1:
        raise PatchError(
            f"RoleObserver getRoleHoldersAsUser: expected 1 call, found {len(calls)} in {path}"
        )

    call_i = calls[0]
    start, end = method_bounds(lines, call_i)
    if "onRoleHoldersChanged(" not in lines[start]:
        raise PatchError(f"role query is not inside onRoleHoldersChanged(): {path}")

    move_i = None
    result_reg = None
    for i in range(call_i + 1, min(call_i + 6, end + 1)):
        m = re.match(r"\s*move-result-object\s+([vp]\d+)\s*$", lines[i])
        if m:
            move_i = i
            result_reg = m.group(1)
            break
        if lines[i].strip() and not lines[i].lstrip().startswith(("#", ".")):
            break
    if move_i is None or result_reg is None:
        raise PatchError(f"RoleObserver role-list move-result-object not found: {path}")

    invoke_line = lines[call_i]
    move_line = lines[move_i]
    regs_match = re.search(r"\{([^}]*)\}", invoke_line)
    if regs_match:
        invoke_regs = {
            token.strip()
            for token in regs_match.group(1).split(",")
            if token.strip()
        }
        if result_reg in invoke_regs:
            raise PatchError(
                f"role-list result register {result_reg} is also an invoke argument; "
                f"refusing unsafe in-place branch patch: {path}"
            )

    stock_label = ":hypermos_micts_stock_role"
    ready_label = ":hypermos_micts_role_ready"
    method_text = "\n".join(lines[start:end + 1])
    if stock_label in method_text or ready_label in method_text:
        raise PatchError(f"conditional fallback labels already exist without marker: {path}")

    indent = re.match(r"\s*", invoke_line).group(0)
    block = [
        f"{indent}# {ROLE_MARKER}",
        f"{indent}iget-object {result_reg}, p0, {role_desc}->this$0:{owner}",
        f"{indent}iget-boolean {result_reg}, {result_reg}, {owner}->{FLAG_FIELD}:Z",
        f"{indent}if-eqz {result_reg}, {stock_label}",
        f'{indent}const-string {result_reg}, "{GOOGLE_PACKAGE}"',
        f"{indent}invoke-static {{{result_reg}}}, Ljava/util/Collections;->singletonList(Ljava/lang/Object;)Ljava/util/List;",
        f"{indent}move-result-object {result_reg}",
        f"{indent}goto {ready_label}",
        f"{indent}{stock_label}",
        invoke_line,
        move_line,
        f"{indent}{ready_label}",
    ]
    lines[call_i:move_i + 1] = block
    write(path, lines)


def patch_show_session(root: Path) -> tuple[Path, Path]:
    path = unique_file(
        root,
        lambda t: WARN_TEXT in t
        and "showSessionFromSession(" in t
        and "switchImplementationIfNeededLocked(Z)V" in t,
        "VoiceInteraction showSessionFromSession",
    )
    lines = read(path)
    owner = class_descriptor(lines, path)

    ensure_flag_field(path, owner)
    lines = read(path)

    role_path, role_desc = find_role_observer(root, owner)
    patch_role_observer(role_path, role_desc, owner)

    helper_name = "hypermosHealVoiceInteractionLocked()V"
    if any(HEAL_MARKER in line for line in lines):
        joined = "\n".join(lines)
        required = (
            helper_name,
            "switchImplementationIfNeededLocked(Z)V",
            "mRoleObserver:",
            f"{owner}->{FLAG_FIELD}:Z",
        )
        if not all(value in joined for value in required):
            raise PatchError(f"self-heal marker present but payload incomplete: {path}")
        return path, role_path

    warn_indexes = [i for i, line in enumerate(lines) if WARN_TEXT in line]
    if len(warn_indexes) != 1:
        raise PatchError(
            f"showSession warning: expected 1 occurrence, found {len(warn_indexes)} in {path}"
        )

    warn_i = warn_indexes[0]
    start, end = method_bounds(lines, warn_i)
    if "showSessionFromSession(" not in lines[start]:
        raise PatchError(f"warning is not inside showSessionFromSession(): {path}")

    joined = "\n".join(lines)

    actual_role_desc = None
    for line in lines:
        m = re.search(r"\bmRoleObserver:(L[^;]+;)", line)
        if m:
            actual_role_desc = m.group(1)
            break
    if actual_role_desc != role_desc:
        raise PatchError(
            f"mRoleObserver descriptor mismatch: outer={actual_role_desc}, role={role_desc}"
        )

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
        "    # One-shot Google fallback only when showSessionFromSession saw mImpl == null.",
        f"    iget-object v0, p0, {owner}->mRoleObserver:{role_desc}",
        "    if-eqz v0, :hypermos_micts_done",
        "",
        "    const/4 v1, 0x1",
        f"    iput-boolean v1, p0, {owner}->{FLAG_FIELD}:Z",
        "",
        f"    iget v1, p0, {owner}->mCurUser:I",
        "    invoke-static {v1}, Landroid/os/UserHandle;->of(I)Landroid/os/UserHandle;",
        "    move-result-object v1",
        "",
        '    const-string v2, "android.app.role.ASSISTANT"',
        f"    invoke-virtual {{v0, v2, v1}}, {role_desc}->onRoleHoldersChanged(Ljava/lang/String;Landroid/os/UserHandle;)V",
        "",
        "    const/4 v1, 0x0",
        f"    iput-boolean v1, p0, {owner}->{FLAG_FIELD}:Z",
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
    return path, role_path


def verify(show_path: Path, role_path: Path) -> None:
    show = show_path.read_text(encoding="utf-8")
    role = role_path.read_text(encoding="utf-8")

    show_checks = {
        "heal marker": HEAL_MARKER in show,
        "self-heal helper": "hypermosHealVoiceInteractionLocked()V" in show,
        "framework retry": show.count("switchImplementationIfNeededLocked(Z)V") >= 1,
        "one-shot flag field": f".field private {FLAG_FIELD}:Z" in show,
        "flag enable": f"iput-boolean v1, p0, " in show and f"->{FLAG_FIELD}:Z" in show,
        "stock failure log retained": WARN_TEXT in show,
    }
    role_checks = {
        "conditional role marker": ROLE_MARKER in role,
        "Google only in fallback": GOOGLE_PACKAGE in role,
        "conditional flag read": f"->{FLAG_FIELD}:Z" in role,
        "dynamic singleton role view": "Ljava/util/Collections;->singletonList" in role,
        "stock role query retained": "getRoleHoldersAsUser" in role,
    }

    failed = [
        name
        for name, ok in {**show_checks, **role_checks}.items()
        if not ok
    ]
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
        show_path, role_path = patch_show_session(root)
        verify(show_path, role_path)
    except PatchError as exc:
        print(f"[MICTS-SELF-HEAL][ERROR] {exc}", file=sys.stderr)
        return 1

    print(f"[MICTS-SELF-HEAL] showSessionFromSession: {show_path}")
    print(f"[MICTS-SELF-HEAL] conditional Google fallback: {role_path}")
    print("[MICTS-SELF-HEAL] normal RoleObserver callbacks remain stock")
    print("[MICTS-SELF-HEAL] verification OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
