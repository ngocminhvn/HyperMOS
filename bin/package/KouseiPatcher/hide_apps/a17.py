#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

HOOK = (
    "Landroid/security/kaorios/KaoriosHook;->"
    "shouldHideAppListForCaller(ILjava/lang/String;I)Z"
)
TARGET_REL = "com/android/server/pm/ComputerEngine.smali"

METHOD_7_RE = re.compile(
    r"(?m)^\.method[^\r\n]*[ \t]"
    r"shouldFilterApplication"
    r"\(Lcom/android/server/pm/pkg/PackageStateInternal;"
    r"ILandroid/content/ComponentName;IIZZ\)Z"
    r"[ \t]*(?:\r?\n|$)"
)
METHOD_3_RE = re.compile(
    r"(?m)^\.method[^\r\n]*[ \t]"
    r"shouldFilterApplication"
    r"\(Lcom/android/server/pm/pkg/PackageStateInternal;II\)Z"
    r"[ \t]*(?:\r?\n|$)"
)
METHOD_END_RE = re.compile(r"(?m)^[ \t]*\.end method[ \t]*(?:\r?\n|$)")
DIRECTIVE_RE = re.compile(
    r"(?m)^(?P<indent>[ \t]*)\.(?P<kind>locals|registers)"
    r"[ \t]+(?P<num>\d+)[^\r\n]*(?:\r?\n|$)"
)


class PatchError(RuntimeError):
    pass


def find_target(root: Path) -> Path:
    matches = [
        p for p in root.rglob("ComputerEngine.smali")
        if str(p).replace("\\", "/").endswith(TARGET_REL)
    ]
    if len(matches) != 1:
        raise PatchError(f"expected exactly one ComputerEngine.smali; found {len(matches)}")
    return matches[0]


def method_span(text: str) -> tuple[int, int, int, str]:
    m7 = list(METHOD_7_RE.finditer(text))
    m3 = list(METHOD_3_RE.finditer(text))

    if len(m7) == 1 and len(m3) == 0:
        match = m7[0]
        param_width = 8  # p0 + 7 explicit parameters
        user_param = "p5"
    elif len(m3) == 1 and len(m7) == 0:
        match = m3[0]
        param_width = 4  # p0 + 3 explicit parameters
        user_param = "p3"
    else:
        raise PatchError(
            "expected exactly one supported ComputerEngine.shouldFilterApplication; "
            f"found 7-param={len(m7)}, 3-param={len(m3)}"
        )

    end = METHOD_END_RE.search(text, match.end())
    if end is None:
        raise PatchError("unterminated ComputerEngine.shouldFilterApplication")

    return match.start(), end.end(), param_width, user_param


def canonicalize_param_aliases(body: str, registers: int, param_width: int) -> str:
    first_param = registers - param_width
    if first_param < 0:
        raise PatchError(
            f".registers {registers} smaller than parameter width {param_width}"
        )
    for p_idx in range(param_width - 1, -1, -1):
        body = re.sub(
            rf"(?<![A-Za-z0-9_])v{first_param + p_idx}(?![0-9])",
            f"p{p_idx}",
            body,
        )
    return body


def grow_locals(body: str, extra: int, param_width: int) -> tuple[str, list[str]]:
    match = DIRECTIVE_RE.search(body)
    if not match:
        raise PatchError("target method has no .locals/.registers")

    newline = "\r\n" if "\r\n" in body else "\n"
    kind = match.group("kind")
    count = int(match.group("num"))

    if kind == "locals":
        first_new = count
        new_locals = count + extra
    else:
        old_locals = count - param_width
        if old_locals < 0:
            raise PatchError(
                f".registers {count} smaller than parameter width {param_width}"
            )
        body = canonicalize_param_aliases(body, count, param_width)
        match = DIRECTIVE_RE.search(body)
        if not match:
            raise PatchError("register directive disappeared after normalization")
        first_new = old_locals
        new_locals = old_locals + extra

    if first_new + extra - 1 > 255:
        raise PatchError(
            f"new scratch register v{first_new + extra - 1} exceeds safe 8-bit register range"
        )

    replacement = f"{match.group('indent')}.locals {new_locals}{newline}"
    body = body[:match.start()] + replacement + body[match.end():]
    return body, [f"v{i}" for i in range(first_new, first_new + extra)]


def insertion_offset(body: str) -> int:
    lines = body.splitlines(keepends=True)
    in_annotation = False
    after = 0

    for idx, line in enumerate(lines):
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith(".method"):
            after = idx + 1
            continue
        if (
            stripped.startswith(".locals")
            or stripped.startswith(".registers")
            or stripped.startswith(".param")
        ):
            after = idx + 1
            continue
        if stripped.startswith(".annotation"):
            in_annotation = True
            after = idx + 1
            continue
        if in_annotation:
            after = idx + 1
            if stripped.startswith(".end annotation"):
                in_annotation = False
            continue
        break

    return sum(len(lines[i]) for i in range(after))


def unique_label(base: str, body: str) -> str:
    label = base
    suffix = 1
    while re.search(rf"(?m)^\s*{re.escape(label)}\s*$", body):
        label = f"{base}_{suffix}"
        suffix += 1
    return label


def patch_text(text: str) -> str:
    start, end, param_width, user_param = method_span(text)
    body = text[start:end]

    hook_count = body.count(HOOK)
    if hook_count == 1:
        verify_text(text)
        return text
    if hook_count != 0:
        raise PatchError(f"duplicate/partial Hide Installed Apps hooks: {hook_count}")

    # Three consecutive locals make the final hook call register-safe via /range.
    body, regs = grow_locals(body, extra=3, param_width=param_width)
    r_uid, r_pkg, r_user = regs

    l_try_start = unique_label(":try_start_kaorios_hia", body)
    l_try_end = unique_label(":try_end_kaorios_hia", body)
    l_catch = unique_label(":catch_kaorios_hia", body)
    l_stock = unique_label(":cond_kaorios_hia_stock", body)

    nl = "\r\n" if "\r\n" in body else "\n"
    hook_code = (
        f"    {l_try_start}{nl}"
        f"    if-eqz p1, {l_try_end}{nl}"
        f"    invoke-interface/range {{p1 .. p1}}, "
        f"Lcom/android/server/pm/pkg/PackageStateInternal;->getPackageName()Ljava/lang/String;{nl}"
        f"    move-result-object {r_pkg}{nl}"
        f"    if-eqz {r_pkg}, {l_try_end}{nl}"
        f"    move/from16 {r_uid}, p2{nl}"
        f"    move/from16 {r_user}, {user_param}{nl}"
        f"    invoke-static/range {{{r_uid} .. {r_user}}}, {HOOK}{nl}"
        f"    move-result {r_uid}{nl}"
        f"    if-eqz {r_uid}, {l_try_end}{nl}"
        f"    const/16 {r_uid}, 0x1{nl}"
        f"    return {r_uid}{nl}"
        f"    {l_try_end}{nl}"
        f"    .catch Ljava/lang/Throwable; {{{l_try_start} .. {l_try_end}}} {l_catch}{nl}"
        f"    goto {l_stock}{nl}"
        f"    {l_catch}{nl}"
        f"    move-exception {r_uid}{nl}"
        f"    {l_stock}{nl}"
    )

    off = insertion_offset(body)
    patched_body = body[:off] + hook_code + body[off:]
    patched = text[:start] + patched_body + text[end:]
    verify_text(patched)
    return patched


def verify_text(text: str) -> None:
    start, end, _param_width, _user_param = method_span(text)
    body = text[start:end]

    if body.count(HOOK) != 1:
        raise PatchError("Hide Installed Apps hook count must be exactly 1")
    if (
        "PackageStateInternal;->getPackageName()Ljava/lang/String;" not in body
        or "invoke-static/range" not in body
        or ".catch Ljava/lang/Throwable;" not in body
    ):
        raise PatchError("Hide Installed Apps A17 fail-open structure verification failed")

    hook_pos = body.find(HOOK)
    return_pos = body.find("return ", hook_pos)
    if hook_pos < 0 or return_pos < 0:
        raise PatchError("Hide Installed Apps A17 return path verification failed")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Kaorios Hide Installed Apps patcher for Android 17"
    )
    parser.add_argument("root", type=Path)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()

    if not args.root.is_dir():
        raise PatchError(f"directory does not exist: {args.root}")

    target = find_target(args.root)
    text = target.read_text(encoding="utf-8")

    if args.verify:
        verify_text(text)
        print("Hide Installed Apps A17 verifier: PASS")
        return

    patched = patch_text(text)
    target.write_text(patched, encoding="utf-8")
    print(f"Hide Installed Apps A17 patched: {target}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Hide Installed Apps A17 failed: {exc}", file=sys.stderr)
        sys.exit(1)
