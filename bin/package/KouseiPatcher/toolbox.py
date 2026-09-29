from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass
from typing import Optional


@dataclass
class Patch:
    smali_class: str
    method: str
    position: str
    anchor: str
    lines_to_add: list[str]
    anchor_is_directive: bool = False
    anchor_is_substring: bool = False


PATCHES: list[Patch] = [
    Patch(
        smali_class="android/app/Instrumentation.smali",
        method="newApplication(Ljava/lang/Class;Landroid/content/Context;)Landroid/app/Application;",
        position="above",
        anchor="return-object",
        anchor_is_substring=True,
        lines_to_add=[
            "invoke-static {p1}, Landroid/security/kaorios/KaoriosHook;->initContext(Landroid/content/Context;)V",
        ],
    ),
    Patch(
        smali_class="android/app/Instrumentation.smali",
        method="newApplication(Ljava/lang/ClassLoader;Ljava/lang/String;Landroid/content/Context;)Landroid/app/Application;",
        position="above",
        anchor="return-object",
        anchor_is_substring=True,
        lines_to_add=[
            "invoke-static {p3}, Landroid/security/kaorios/KaoriosHook;->initContext(Landroid/content/Context;)V",
        ],
    ),
    Patch(
        smali_class="android/app/ApplicationPackageManager.smali",
        method="hasSystemFeature(Ljava/lang/String;I)Z",
        position="below",
        anchor=".locals",
        anchor_is_directive=True,
        lines_to_add=[
            "invoke-static {p1, p2}, Landroid/security/kaorios/KaoriosHook;->hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;",
            "move-result-object v0",
            "if-eqz v0, :cond_kaorios",
            "invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z",
            "move-result v0",
            "return v0",
            ":cond_kaorios",
        ],
    ),
    Patch(
        smali_class="android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi.smali",
        method="generateKeyPair()Ljava/security/KeyPair;",
        position="replace",
        anchor=".locals",
        anchor_is_directive=True,
        lines_to_add=[
            ".locals 15",
            "invoke-static {p0}, Landroid/security/kaorios/KaoriosHook;->initGenerateSoftwareKeyPair(Ljava/lang/Object;)Ljava/security/KeyPair;",
            "move-result-object v14",
            "if-eqz v14, :cond_kaorios",
            "return-object v14",
            ":cond_kaorios",
        ],
    ),
    Patch(
        smali_class="android/security/keystore2/AndroidKeyStoreSpi.smali",
        method="engineGetCertificateChain(Ljava/lang/String;)[Ljava/security/cert/Certificate;",
        position="below",
        anchor="aput-object v2, v3, v4",
        anchor_is_substring=True,
        lines_to_add=[
            "invoke-static {v3}, Landroid/security/kaorios/KaoriosHook;->CertificateChainIfNeeded([Ljava/security/cert/Certificate;)[Ljava/security/cert/Certificate;",
            "move-result-object v3",
        ],
    ),
]

SERVICES_PATCH = Patch(
    smali_class="com/android/server/SystemServer.smali",
    method="run()V",
    position="above",
    anchor="Lcom/android/server/SystemServer;->startOtherServices(Lcom/android/server/utils/TimingsTraceAndSlog;)V",
    anchor_is_substring=True,
    lines_to_add=[
        "invoke-static {}, Landroid/security/kaorios/KaoriosHook;->initSystemServer()V",
    ],
)


GUARD_COMMENT = "# [kaorios-patched]"


def find_smali_file(base_dir: str, smali_class: str) -> Optional[str]:
    target = os.path.normpath(smali_class)
    for root, _dirs, files in os.walk(base_dir):
        for fname in files:
            full = os.path.join(root, fname)
            normalized = os.path.normpath(full)
            if normalized.endswith(target):
                return full
    return None


def indent_of(line: str) -> str:
    return line[: len(line) - len(line.lstrip())]


def method_signature_matches(line: str, method_sig: str) -> bool:
    stripped = line.strip()
    if not stripped.startswith(".method"):
        return False
    return method_sig in stripped


def apply_patch(patch: Patch, base_dir: str) -> bool:
    filepath = find_smali_file(base_dir, patch.smali_class)
    if not filepath:
        return False

    with open(filepath, "r", encoding="utf-8") as f:
        original_lines = f.readlines()

    for ln in original_lines:
        if GUARD_COMMENT in ln:
            first_add = patch.lines_to_add[0].strip()
            content = "".join(original_lines)
            if first_add in content:
                return True
            break

    in_target_method = False
    method_depth = 0
    anchor_stripped = patch.anchor.strip()
    inserted = False
    new_lines: list[str] = []

    i = 0
    while i < len(original_lines):
        line = original_lines[i]
        stripped = line.strip()

        if stripped.startswith(".method") and not in_target_method:
            if method_signature_matches(stripped, patch.method):
                in_target_method = True
                method_depth = 1
                new_lines.append(line)
                i += 1
                continue

        if in_target_method:
            if stripped.startswith(".method"):
                method_depth += 1
            elif stripped.startswith(".end method"):
                method_depth -= 1
                if method_depth == 0:
                    in_target_method = False

            if not inserted:
                match = False
                if patch.anchor_is_directive:
                    match = stripped.startswith(anchor_stripped)
                    if not match and anchor_stripped == ".locals":
                        match = stripped.startswith(".registers")
                elif patch.anchor_is_substring:
                    match = anchor_stripped in stripped
                else:
                    match = stripped == anchor_stripped

                if match:
                    base_indent = indent_of(line)
                    inject = [f"{base_indent}{l}\n" for l in patch.lines_to_add]
                    inject[0] = inject[0].rstrip("\n") + "  " + GUARD_COMMENT + "\n"

                    if patch.position == "above":
                        new_lines.extend(inject)
                        new_lines.append(line)
                    elif patch.position == "replace":
                        new_lines.extend(inject)
                    else:
                        new_lines.append(line)
                        new_lines.extend(inject)

                    inserted = True
                    i += 1
                    continue

        new_lines.append(line)
        i += 1

    if not inserted:
        return False

    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    return True



DEV_STATUS_METHOD = "getStringForUser(Landroid/content/ContentResolver;Ljava/lang/String;I)Ljava/lang/String;"
DEV_STATUS_HOOK = "Landroid/security/kaorios/KaoriosHook;->shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z"


def _unique_label(base: str, body: str) -> str:
    label = base
    idx = 1
    while re.search(rf"(?m)^\s*{re.escape(label)}\s*$", body):
        label = f"{base}_{idx}"
        idx += 1
    return label


def _canonicalize_param_aliases(body: str, registers: int, param_count: int) -> str:
    """Convert physical vN parameter aliases to stable pN aliases before growing registers."""
    first_param = registers - param_count
    for p_idx in range(param_count - 1, -1, -1):
        v_idx = first_param + p_idx
        body = re.sub(rf"(?<![A-Za-z0-9_])v{v_idx}(?![0-9])", f"p{p_idx}", body)
    return body


def _instruction_insertion_offset(body: str) -> int:
    """Insert after .locals/.registers, .param and method annotations."""
    lines = body.splitlines(keepends=True)
    in_annotation = False
    insert_after = 0

    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith(".method"):
            insert_after = i + 1
            continue
        if stripped.startswith(".locals") or stripped.startswith(".registers"):
            insert_after = i + 1
            continue
        if stripped.startswith(".param"):
            insert_after = i + 1
            continue
        if stripped.startswith(".annotation"):
            in_annotation = True
            insert_after = i + 1
            continue
        if in_annotation:
            insert_after = i + 1
            if stripped.startswith(".end annotation"):
                in_annotation = False
            continue
        break

    return sum(len(lines[i]) for i in range(insert_after))


def patch_dev_status(base_dir: str) -> bool:
    """Patch Settings$NameValueCache to hide Developer Options / ADB state per caller."""
    filepath = find_smali_file(base_dir, "android/provider/Settings$NameValueCache.smali")
    if not filepath:
        print("Settings$NameValueCache.smali not found")
        return False

    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    method_re = re.compile(
        r"(?ms)^\.method[^\r\n]*\s"
        + re.escape(DEV_STATUS_METHOD)
        + r"[^\r\n]*(?:\r?\n).*?^\.end method[ \t]*(?:\r?\n|$)"
    )
    matches = list(method_re.finditer(content))
    if len(matches) != 1:
        print(f"Expected exactly one {DEV_STATUS_METHOD}; found {len(matches)}")
        return False

    method = matches[0].group(0)
    hook_count = method.count(DEV_STATUS_HOOK)
    if hook_count == 1:
        return True
    if hook_count > 1:
        print(f"Developer/ADB hide hook duplicated: {hook_count}")
        return False

    newline = "\r\n" if "\r\n" in method else "\n"
    locals_match = re.search(r"(?m)^(?P<indent>[ \t]*)\.locals[ \t]+(?P<num>\d+)[^\r\n]*(?:\r?\n|$)", method)
    registers_match = re.search(r"(?m)^(?P<indent>[ \t]*)\.registers[ \t]+(?P<num>\d+)[^\r\n]*(?:\r?\n|$)", method)

    if locals_match:
        old_locals = int(locals_match.group("num"))
        scratch = f"v{old_locals}"
        new_directive = f"{locals_match.group('indent')}.locals {old_locals + 1}{newline}"
        method = method[:locals_match.start()] + new_directive + method[locals_match.end():]
    elif registers_match:
        old_registers = int(registers_match.group("num"))
        param_count = 4  # p0=this, p1=ContentResolver, p2=name, p3=userId
        old_locals = old_registers - param_count
        if old_locals < 0:
            print(f"Invalid .registers {old_registers} in {DEV_STATUS_METHOD}")
            return False
        method = _canonicalize_param_aliases(method, old_registers, param_count)
        # Re-find after alias normalization to preserve offsets.
        registers_match = re.search(r"(?m)^(?P<indent>[ \t]*)\.registers[ \t]+(?P<num>\d+)[^\r\n]*(?:\r?\n|$)", method)
        scratch = f"v{old_locals}"
        new_directive = f"{registers_match.group('indent')}.locals {old_locals + 1}{newline}"
        method = method[:registers_match.start()] + new_directive + method[registers_match.end():]
    else:
        print(f"No .locals/.registers in {DEV_STATUS_METHOD}")
        return False

    label = _unique_label(":cond_kaorios_dev_stock", method)
    inject = (
        f"    if-eqz p2, {label}{newline}"
        f"    invoke-static/range {{p1 .. p3}}, {DEV_STATUS_HOOK}{newline}"
        f"    move-result {scratch}{newline}"
        f"    if-eqz {scratch}, {label}{newline}"
        f"    const-string {scratch}, \"0\"{newline}"
        f"    return-object {scratch}{newline}"
        f"{newline}"
        f"    {label}{newline}"
    )

    offset = _instruction_insertion_offset(method)
    patched_method = method[:offset] + inject + method[offset:]

    if patched_method.count(DEV_STATUS_HOOK) != 1:
        print("Developer/ADB hide hook verification failed")
        return False

    patched_content = content[:matches[0].start()] + patched_method + content[matches[0].end():]
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(patched_content)

    print("Patched Settings$NameValueCache: hide Developer Options / ADB status")
    return True


def main():
    parser = argparse.ArgumentParser(description="Kaorios smali patcher")
    parser.add_argument("base_dir", help="Thư mục chứa smali")
    parser.add_argument("--services", action="store_true", help="Patch SystemServer (Android 13-16)")
    parser.add_argument("--dev-only", action="store_true", help="Chỉ patch ẩn Developer Options / ADB")
    args = parser.parse_args()

    if not os.path.isdir(args.base_dir):
        sys.exit(1)

    if args.dev_only:
        if not patch_dev_status(args.base_dir):
            sys.exit(1)
        return

    patches = list(PATCHES)
    if args.services:
        patches.append(SERVICES_PATCH)

    for patch in patches:
        if not apply_patch(patch, args.base_dir):
            print(f"Patch failed: {patch.smali_class} :: {patch.method}")
            sys.exit(1)

    if not args.services:
        if not patch_dev_status(args.base_dir):
            sys.exit(1)


if __name__ == "__main__":
    main()
