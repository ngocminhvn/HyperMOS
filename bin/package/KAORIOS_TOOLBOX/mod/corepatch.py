#!/usr/bin/env python3
"""Apply and verify the Kaorios 2.0.6+ static CorePatch recipe.

The upstream documentation uses registers from one reference ROM.  This tool
derives operands from each target method instead of copying those registers.
It patches only documented CorePatch behavior and fails closed on ambiguous
class ownership or a recognized class with an unsupported layout.
"""
from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


class CorePatchError(RuntimeError):
    pass


METHOD_RE = re.compile(
    r"^\s*\.method\b.*?\s(?P<name>[A-Za-z0-9_$<>-]+)\([^)]*\)(?P<ret>\S+)\s*$"
)
INVOKE_REGS_RE = re.compile(r"\{(?P<regs>[^}]*)\}")
REGISTER_RE = re.compile(r"^[vp]\d+$")


FRAMEWORK_CLASSES = {
    "package_parser": "android/content/pm/PackageParser.smali",
    "package_parser_exception": "android/content/pm/PackageParser$PackageParserException.smali",
    "package_parser_signing": "android/content/pm/PackageParser$SigningDetails.smali",
    "signing_details": "android/content/pm/SigningDetails.smali",
    "v2": "android/util/apk/ApkSignatureSchemeV2Verifier.smali",
    "v3": "android/util/apk/ApkSignatureSchemeV3Verifier.smali",
    "signature_verifier": "android/util/apk/ApkSignatureVerifier.smali",
    "signing_block": "android/util/apk/ApkSigningBlockUtils.smali",
    "strict_verifier": "android/util/jar/StrictJarVerifier.smali",
    "strict_file": "android/util/jar/StrictJarFile.smali",
    "parsing_utils": "com/android/internal/pm/pkg/parsing/ParsingPackageUtils.smali",
}


def class_file(root: Path, relative: str) -> Path | None:
    matches = list(root.glob(f"classes*.dex.out/{relative}"))
    if len(matches) > 1:
        raise CorePatchError(f"duplicate class owner for {relative}: {matches}")
    return matches[0] if matches else None


def all_smali(root: Path):
    yield from root.glob("classes*.dex.out/**/*.smali")


def read(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def write(path: Path, lines: list[str]) -> None:
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def method_blocks(lines: list[str]):
    blocks = []
    start = None
    match = None
    for index, line in enumerate(lines):
        current = METHOD_RE.match(line)
        if current:
            if start is not None:
                raise CorePatchError("nested smali method")
            start, match = index, current
        elif start is not None and line.strip() == ".end method":
            blocks.append((start, index, match.group("name"), match.group("ret")))
            start, match = None, None
    if start is not None:
        raise CorePatchError("unterminated smali method")
    return blocks


def containing_method(lines: list[str], index: int) -> tuple[int, int] | None:
    for start, end, _name, _ret in method_blocks(lines):
        if start <= index <= end:
            return start, end
    return None


def const(register: str, value: int, indent: str = "    ") -> str:
    if not REGISTER_RE.match(register):
        raise CorePatchError(f"invalid register: {register}")
    return f"{indent}const/16 {register}, 0x{value:x}"


def is_const(line: str, register: str, value: int) -> bool:
    return bool(re.fullmatch(
        rf"\s*const(?:/4|/16)?\s+{re.escape(register)},\s*0x{value:x}\s*", line
    ))


def previous_code(lines: list[str], index: int) -> int | None:
    for pos in range(index - 1, -1, -1):
        stripped = lines[pos].strip()
        if stripped and not stripped.startswith("#"):
            return pos
    return None


def next_code(lines: list[str], index: int, end: int | None = None) -> int | None:
    limit = len(lines) if end is None else min(len(lines), end + 1)
    for pos in range(index + 1, limit):
        stripped = lines[pos].strip()
        if stripped and not stripped.startswith("#"):
            return pos
    return None


def insert_const_before(lines: list[str], index: int, register: str, value: int) -> bool:
    prior = previous_code(lines, index)
    if prior is not None and is_const(lines[prior], register, value):
        return False
    indent = re.match(r"\s*", lines[index]).group(0) or "    "
    lines.insert(index, const(register, value, indent))
    return True


def replace_methods(path: Path, names: set[str], value: int | None) -> tuple[int, int]:
    lines = read(path)
    blocks = [block for block in method_blocks(lines) if block[2] in names]
    changed = 0
    for start, end, name, ret in reversed(blocks):
        if value is None:
            if ret != "V":
                raise CorePatchError(f"{path}:{name} is not void ({ret})")
            body = [lines[start], "    .locals 0", "", "    return-void", ".end method"]
        else:
            if ret not in {"Z", "I"}:
                raise CorePatchError(f"{path}:{name} has unsupported return type {ret}")
            body = [
                lines[start], "    .locals 1", "", f"    const/4 v0, 0x{value:x}",
                "", "    return v0", ".end method",
            ]
        if lines[start:end + 1] != body:
            lines[start:end + 1] = body
            changed += 1
    if changed:
        write(path, lines)
    return len(blocks), changed


def verify_methods(path: Path, names: set[str], value: int | None) -> int:
    lines = read(path)
    matched = 0
    for start, end, name, ret in method_blocks(lines):
        if name not in names:
            continue
        matched += 1
        body = [line.strip() for line in lines[start + 1:end] if line.strip()]
        if value is None:
            expected = [".locals 0", "return-void"]
        else:
            expected = [".locals 1", f"const/4 v0, 0x{value:x}", "return v0"]
        if body != expected:
            raise CorePatchError(f"CorePatch method stub verification failed: {path}:{name}")
    return matched


def invoke_registers(line: str) -> list[str]:
    match = INVOKE_REGS_RE.search(line)
    if not match or ".." in match.group("regs"):
        raise CorePatchError(f"unsupported invoke register form: {line.strip()}")
    registers = [item.strip() for item in match.group("regs").split(",") if item.strip()]
    if not registers or any(not REGISTER_RE.match(item) for item in registers):
        raise CorePatchError(f"cannot parse invoke registers: {line.strip()}")
    return registers


def patch_invoke_argument(path: Path, signature: str, argument: int, value: int) -> tuple[int, int]:
    lines = read(path)
    matched = changed = 0
    index = 0
    while index < len(lines):
        if signature not in lines[index]:
            index += 1
            continue
        registers = invoke_registers(lines[index])
        try:
            register = registers[argument]
        except IndexError as error:
            raise CorePatchError(f"missing invoke argument in {path}: {lines[index].strip()}") from error
        matched += 1
        if insert_const_before(lines, index, register, value):
            changed += 1
            index += 1
        index += 1
    if changed:
        write(path, lines)
    return matched, changed


def verify_invoke_argument(path: Path, signature: str, argument: int, value: int) -> int:
    lines = read(path)
    matched = 0
    for index, line in enumerate(lines):
        if signature not in line:
            continue
        registers = invoke_registers(line)
        if len(registers) <= argument:
            raise CorePatchError(f"missing invoke argument in {path}")
        prior = previous_code(lines, index)
        if prior is None or not is_const(lines[prior], registers[argument], value):
            raise CorePatchError(f"CorePatch invoke guard missing in {path}: {signature}")
        matched += 1
    return matched


def patch_string_branch(path: Path, needle: str, opcode: str, value: int) -> tuple[int, int]:
    lines = read(path)
    matched = changed = 0
    index = 0
    while index < len(lines):
        if needle not in lines[index]:
            index += 1
            continue
        block = containing_method(lines, index)
        if block is None:
            raise CorePatchError(f"string anchor outside method in {path}")
        _start, end = block
        branch = None
        for pos in range(index + 1, min(end, index + 80) + 1):
            match = re.match(rf"\s*{opcode}\s+([vp]\d+),\s*:\S+", lines[pos])
            if match:
                branch = (pos, match.group(1))
                break
        if branch is None:
            raise CorePatchError(f"{opcode} not found near {needle!r} in {path}")
        matched += 1
        pos, register = branch
        if insert_const_before(lines, pos, register, value):
            changed += 1
            index = pos + 1
        else:
            index = pos + 1
    if changed:
        write(path, lines)
    return matched, changed


def verify_string_branch(path: Path, needle: str, opcode: str, value: int) -> int:
    lines = read(path)
    matched = 0
    for index, line in enumerate(lines):
        if needle not in line:
            continue
        block = containing_method(lines, index)
        if block is None:
            raise CorePatchError(f"string anchor outside method in {path}")
        branch = None
        for pos in range(index + 1, min(block[1], index + 80) + 1):
            match = re.match(rf"\s*{opcode}\s+([vp]\d+),\s*:\S+", lines[pos])
            if match:
                branch = (pos, match.group(1))
                break
        if branch is None:
            raise CorePatchError(f"branch not found in {path}")
        pos, register = branch
        prior = previous_code(lines, pos)
        if prior is None or not is_const(lines[prior], register, value):
            raise CorePatchError(f"CorePatch branch guard missing in {path}")
        matched += 1
    return matched


def patch_is_equal(path: Path) -> tuple[int, int]:
    lines = read(path)
    matched = changed = 0
    for index, line in enumerate(lines):
        if "Ljava/security/MessageDigest;->isEqual([B[B)Z" not in line:
            continue
        result = next_code(lines, index)
        if result is None:
            raise CorePatchError(f"missing result after MessageDigest.isEqual in {path}")
        move = re.match(r"(\s*)move-result\s+([vp]\d+)\s*$", lines[result])
        forced = re.match(r"\s*const(?:/4|/16)?\s+([vp]\d+),\s*0x1\s*$", lines[result])
        matched += 1
        if move:
            lines[result] = const(move.group(2), 1, move.group(1) or "    ")
            changed += 1
        elif not forced:
            raise CorePatchError(f"unexpected result after MessageDigest.isEqual in {path}")
    if changed:
        write(path, lines)
    return matched, changed


def verify_is_equal(path: Path) -> int:
    lines = read(path)
    matched = 0
    for index, line in enumerate(lines):
        if "Ljava/security/MessageDigest;->isEqual([B[B)Z" not in line:
            continue
        result = next_code(lines, index)
        if result is None or not re.match(
            r"\s*const(?:/4|/16)?\s+[vp]\d+,\s*0x1\s*$", lines[result]
        ):
            raise CorePatchError(f"MessageDigest.isEqual result is not forced true in {path}")
        matched += 1
    return matched


def patch_strict_jar(path: Path) -> tuple[int, int]:
    lines = read(path)
    matched = changed = 0
    for index, line in enumerate(lines):
        if "StrictJarFile;->findEntry(Ljava/lang/String;)Ljava/util/zip/ZipEntry;" not in line:
            continue
        result_pos = next_code(lines, index)
        if result_pos is None:
            raise CorePatchError(f"missing findEntry result in {path}")
        result_match = re.match(r"\s*move-result-object\s+([vp]\d+)", lines[result_pos])
        if not result_match:
            raise CorePatchError(f"unexpected findEntry result in {path}")
        register = result_match.group(1)
        branch_pos = next_code(lines, result_pos)
        if branch_pos is None:
            raise CorePatchError(f"missing findEntry null branch in {path}")
        branch = re.match(rf"(\s*)if-eqz\s+{re.escape(register)},\s*:\S+", lines[branch_pos])
        matched += 1
        if branch:
            lines[branch_pos] = f"{branch.group(1) or '    '}nop"
            changed += 1
        elif lines[branch_pos].strip() != "nop":
            raise CorePatchError(f"unsupported findEntry guard in {path}")
    if changed:
        write(path, lines)
    return matched, changed


def verify_strict_jar(path: Path) -> int:
    lines = read(path)
    matched = 0
    for index, line in enumerate(lines):
        if "StrictJarFile;->findEntry(Ljava/lang/String;)Ljava/util/zip/ZipEntry;" not in line:
            continue
        result_pos = next_code(lines, index)
        branch_pos = next_code(lines, result_pos) if result_pos is not None else None
        if branch_pos is None or lines[branch_pos].strip() != "nop":
            raise CorePatchError(f"StrictJarFile mismatch guard remains in {path}")
        matched += 1
    return matched


def patch_install_package_helper(path: Path) -> tuple[int, int]:
    lines = read(path)
    matched = changed = 0
    index = 0
    while index < len(lines):
        if "AndroidPackage;->isLeavingSharedUser()Z" not in lines[index]:
            index += 1
            continue
        result_pos = next_code(lines, index)
        if result_pos is None:
            raise CorePatchError(f"missing isLeavingSharedUser result in {path}")
        result = re.match(r"\s*move-result\s+([vp]\d+)\s*$", lines[result_pos])
        if not result:
            raise CorePatchError(f"unexpected isLeavingSharedUser result in {path}")
        branch_pos = next_code(lines, result_pos)
        if branch_pos is None:
            raise CorePatchError(f"missing isLeavingSharedUser branch in {path}")
        branch = re.match(r"\s*if-eqz\s+([vp]\d+),\s*:\S+", lines[branch_pos])
        already_forced = is_const(lines[branch_pos], result.group(1), 1)
        if already_forced:
            branch_pos = next_code(lines, branch_pos)
            branch = re.match(r"\s*if-eqz\s+([vp]\d+),\s*:\S+", lines[branch_pos]) if branch_pos else None
        if not branch:
            raise CorePatchError(f"unexpected isLeavingSharedUser branch in {path}")
        register = branch.group(1)
        matched += 1
        if not already_forced and insert_const_before(lines, branch_pos, register, 1):
            changed += 1
            index = branch_pos + 1
        else:
            index = branch_pos + 1
    if changed:
        write(path, lines)
    return matched, changed


def verify_install_package_helper(path: Path) -> int:
    lines = read(path)
    matched = 0
    for index, line in enumerate(lines):
        if "AndroidPackage;->isLeavingSharedUser()Z" not in line:
            continue
        result_pos = next_code(lines, index)
        branch_pos = next_code(lines, result_pos) if result_pos is not None else None
        if branch_pos is None:
            raise CorePatchError(f"missing isLeavingSharedUser branch in {path}")
        branch = re.match(r"\s*if-eqz\s+([vp]\d+),\s*:\S+", lines[branch_pos])
        if not branch:
            # An inserted const sits between move-result and branch.
            branch_pos = next_code(lines, branch_pos)
            branch = re.match(r"\s*if-eqz\s+([vp]\d+),\s*:\S+", lines[branch_pos]) if branch_pos else None
        if not branch:
            raise CorePatchError(f"unsupported isLeavingSharedUser branch in {path}")
        prior = previous_code(lines, branch_pos)
        if prior is None or not is_const(lines[prior], branch.group(1), 1):
            raise CorePatchError(f"isLeavingSharedUser guard not forced true in {path}")
        matched += 1
    return matched


def patch_reconcile(path: Path) -> tuple[int, int]:
    lines = read(path)
    matched = changed = 0
    for start, end, name, _ret in method_blocks(lines):
        if name != "<clinit>":
            continue
        for index in range(start + 1, end):
            if re.fullmatch(r"\s*const/4\s+v0,\s*0x[01]\s*", lines[index]):
                matched += 1
                replacement = re.sub(r"0x[01]", "0x1", lines[index])
                if replacement != lines[index]:
                    lines[index] = replacement
                    changed += 1
                break
        break
    if changed:
        write(path, lines)
    return matched, changed


def verify_reconcile(path: Path) -> int:
    lines = read(path)
    for start, end, name, _ret in method_blocks(lines):
        if name == "<clinit>" and any(
            re.fullmatch(r"\s*const/4\s+v0,\s*0x1\s*", line)
            for line in lines[start + 1:end]
        ):
            return 1
    return 0


def add(counter: Counter, key: str, result: tuple[int, int]) -> None:
    matched, changed = result
    counter[f"{key}.matched"] += matched
    counter[f"{key}.changed"] += changed


def apply_framework(root: Path) -> Counter:
    result = Counter()
    files = {key: class_file(root, rel) for key, rel in FRAMEWORK_CLASSES.items()}
    if files["package_parser"]:
        add(result, "PackageParser.certs", patch_invoke_argument(
            files["package_parser"], "ApkSignatureVerifier;->unsafeGetCertsWithoutVerification", -1, 1
        ))
        add(result, "PackageParser.sharedUser", patch_string_branch(
            files["package_parser"], "<manifest> specifies bad sharedUserId name", "if-nez", 1
        ))
    if files["package_parser_exception"]:
        path = files["package_parser_exception"]
        lines = read(path)
        matched = changed = 0
        index = 0
        while index < len(lines):
            match = re.match(r"\s*iput\s+([vp]\d+),\s*[vp]\d+,\s*Landroid/content/pm/PackageParser\$PackageParserException;->error:I", lines[index])
            if not match:
                index += 1
                continue
            matched += 1
            if insert_const_before(lines, index, match.group(1), 0):
                changed += 1
                index += 1
            index += 1
        if changed:
            write(path, lines)
        add(result, "PackageParserException.error", (matched, changed))
    if files["package_parser_signing"]:
        add(result, "PackageParserSigningDetails.checkCapability", replace_methods(
            files["package_parser_signing"], {"checkCapability"}, 1
        ))
    if files["signing_details"]:
        add(result, "SigningDetails.capabilities", replace_methods(
            files["signing_details"], {"checkCapability", "checkCapabilityRecover", "hasAncestorOrSelf"}, 1
        ))
    for key in ("v2", "v3", "signing_block"):
        if files[key]:
            add(result, f"{key}.digest", patch_is_equal(files[key]))
    if files["signature_verifier"]:
        add(result, "ApkSignatureVerifier.minimum", replace_methods(
            files["signature_verifier"], {"getMinimumSignatureSchemeVersionForTargetSdk"}, 0
        ))
        add(result, "ApkSignatureVerifier.v1", patch_invoke_argument(
            files["signature_verifier"], "ApkSignatureVerifier;->verifyV1Signature", -1, 0
        ))
    if files["strict_verifier"]:
        add(result, "StrictJarVerifier.digest", replace_methods(
            files["strict_verifier"], {"verifyMessageDigest"}, 1
        ))
    if files["strict_file"]:
        add(result, "StrictJarFile.entry", patch_strict_jar(files["strict_file"]))
    if files["parsing_utils"]:
        add(result, "ParsingPackageUtils.sharedUser", patch_string_branch(
            files["parsing_utils"], "<manifest> specifies bad sharedUserId name", "if-eqz", 0
        ))
    verify_framework(root)
    return result


def verify_framework(root: Path) -> Counter:
    result = Counter()
    files = {key: class_file(root, rel) for key, rel in FRAMEWORK_CLASSES.items()}
    if files["package_parser"]:
        result["PackageParser.certs"] = verify_invoke_argument(
            files["package_parser"], "ApkSignatureVerifier;->unsafeGetCertsWithoutVerification", -1, 1
        )
        result["PackageParser.sharedUser"] = verify_string_branch(
            files["package_parser"], "<manifest> specifies bad sharedUserId name", "if-nez", 1
        )
    if files["package_parser_exception"]:
        lines = read(files["package_parser_exception"])
        count = 0
        for index, line in enumerate(lines):
            match = re.match(r"\s*iput\s+([vp]\d+),.*PackageParser\$PackageParserException;->error:I", line)
            if match:
                prior = previous_code(lines, index)
                if prior is None or not is_const(lines[prior], match.group(1), 0):
                    raise CorePatchError("PackageParserException error code is not forced to zero")
                count += 1
        result["PackageParserException.error"] = count
    if files["package_parser_signing"]:
        result["PackageParserSigningDetails.checkCapability"] = verify_methods(
            files["package_parser_signing"], {"checkCapability"}, 1
        )
    if files["signing_details"]:
        result["SigningDetails.capabilities"] = verify_methods(
            files["signing_details"], {"checkCapability", "checkCapabilityRecover", "hasAncestorOrSelf"}, 1
        )
    for key in ("v2", "v3", "signing_block"):
        if files[key]:
            result[f"{key}.digest"] = verify_is_equal(files[key])
    if files["signature_verifier"]:
        result["ApkSignatureVerifier.minimum"] = verify_methods(
            files["signature_verifier"], {"getMinimumSignatureSchemeVersionForTargetSdk"}, 0
        )
        result["ApkSignatureVerifier.v1"] = verify_invoke_argument(
            files["signature_verifier"], "ApkSignatureVerifier;->verifyV1Signature", -1, 0
        )
    if files["strict_verifier"]:
        result["StrictJarVerifier.digest"] = verify_methods(
            files["strict_verifier"], {"verifyMessageDigest"}, 1
        )
    if files["strict_file"]:
        result["StrictJarFile.entry"] = verify_strict_jar(files["strict_file"])
    if files["parsing_utils"]:
        result["ParsingPackageUtils.sharedUser"] = verify_string_branch(
            files["parsing_utils"], "<manifest> specifies bad sharedUserId name", "if-eqz", 0
        )
    expected = {
        "package_parser": ("PackageParser.certs", "PackageParser.sharedUser"),
        "package_parser_exception": ("PackageParserException.error",),
        "package_parser_signing": ("PackageParserSigningDetails.checkCapability",),
        "signing_details": ("SigningDetails.capabilities",),
        "v2": ("v2.digest",),
        "v3": ("v3.digest",),
        "signature_verifier": ("ApkSignatureVerifier.minimum", "ApkSignatureVerifier.v1"),
        "signing_block": ("signing_block.digest",),
        "strict_verifier": ("StrictJarVerifier.digest",),
        "strict_file": ("StrictJarFile.entry",),
        "parsing_utils": ("ParsingPackageUtils.sharedUser",),
    }
    for class_key, checks in expected.items():
        if files[class_key] and any(result[check] == 0 for check in checks):
            missing = [check for check in checks if result[check] == 0]
            raise CorePatchError(
                f"recognized framework class has unsupported CorePatch layout: {class_key}: {missing}"
            )
    if sum(result.values()) == 0:
        raise CorePatchError("no supported framework CorePatch target was found")
    return result


SERVICE_METHODS = {
    "checkDowngrade": None,
    "shouldCheckUpgradeKeySetLocked": 0,
    "verifySignatures": 0,
    "compareSignatures": 0,
    "matchSignaturesCompat": 1,
}
SERVICE_METHOD_OWNERS = {
    "checkDowngrade": "com/android/server/pm/PackageManagerServiceUtils.smali",
    "verifySignatures": "com/android/server/pm/PackageManagerServiceUtils.smali",
    "compareSignatures": "com/android/server/pm/PackageManagerServiceUtils.smali",
    "matchSignaturesCompat": "com/android/server/pm/PackageManagerServiceUtils.smali",
    "shouldCheckUpgradeKeySetLocked": "com/android/server/pm/KeySetManagerService.smali",
}


def service_method_owner(root: Path, name: str) -> Path | None:
    preferred = class_file(root, SERVICE_METHOD_OWNERS[name])
    if preferred and name in {block[2] for block in method_blocks(read(preferred))}:
        return preferred
    matches = []
    for path in all_smali(root):
        if name in {block[2] for block in method_blocks(read(path))}:
            matches.append(path)
    if len(matches) > 1:
        raise CorePatchError(f"ambiguous owner for services method {name}: {matches}")
    return matches[0] if matches else None


def apply_services(root: Path) -> Counter:
    result = Counter()
    for name, value in SERVICE_METHODS.items():
        path = service_method_owner(root, name)
        if path:
            add(result, f"method.{name}", replace_methods(path, {name}, value))
    install = class_file(root, "com/android/server/pm/InstallPackageHelper.smali")
    if install:
        add(result, "InstallPackageHelper.sharedUser", patch_install_package_helper(install))
    reconcile = class_file(root, "com/android/server/pm/ReconcilePackageUtils.smali")
    if reconcile:
        add(result, "ReconcilePackageUtils.clinit", patch_reconcile(reconcile))
    verify_services(root)
    return result


def verify_services(root: Path) -> Counter:
    result = Counter()
    for name, value in SERVICE_METHODS.items():
        path = service_method_owner(root, name)
        if path:
            result[f"method.{name}"] = verify_methods(path, {name}, value)
    install = class_file(root, "com/android/server/pm/InstallPackageHelper.smali")
    if install:
        result["InstallPackageHelper.sharedUser"] = verify_install_package_helper(install)
        if result["InstallPackageHelper.sharedUser"] == 0:
            raise CorePatchError("InstallPackageHelper has no supported shared-user guard")
    reconcile = class_file(root, "com/android/server/pm/ReconcilePackageUtils.smali")
    if reconcile:
        result["ReconcilePackageUtils.clinit"] = verify_reconcile(reconcile)
        if result["ReconcilePackageUtils.clinit"] == 0:
            raise CorePatchError("ReconcilePackageUtils has no supported <clinit> flag")
    if sum(result.values()) == 0:
        raise CorePatchError("no supported services CorePatch target was found")
    return result


def apply_miui_services(root: Path) -> Counter:
    result = Counter()
    for path in all_smali(root):
        names = {block[2] for block in method_blocks(read(path))}
        targets = names & {"verifyIsolationViolation", "canBeUpdate"}
        if targets:
            add(result, "miui.update", replace_methods(path, targets, None))
    verify_miui_services(root)
    return result


def verify_miui_services(root: Path) -> Counter:
    result = Counter()
    for path in all_smali(root):
        names = {block[2] for block in method_blocks(read(path))}
        targets = names & {"verifyIsolationViolation", "canBeUpdate"}
        if targets:
            result["miui.update"] += verify_methods(path, targets, None)
    if sum(result.values()) == 0:
        raise CorePatchError("no supported miui-services CorePatch target was found")
    return result


APPLY = {
    "framework": apply_framework,
    "services": apply_services,
    "miui-services": apply_miui_services,
}
VERIFY = {
    "framework": verify_framework,
    "services": verify_services,
    "miui-services": verify_miui_services,
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("apply", "verify"))
    parser.add_argument("--kind", required=True, choices=tuple(APPLY))
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        if not args.root.is_dir():
            raise CorePatchError(f"smali root is missing: {args.root}")
        counts = (APPLY if args.command == "apply" else VERIFY)[args.kind](args.root)
        payload = {
            "schema": 1,
            "recipe": "Kaorios Toolbox 2.0.6+ CorePatch",
            "command": args.command,
            "kind": args.kind,
            "counts": dict(sorted(counts.items())),
        }
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(payload, sort_keys=True))
        return 0
    except (CorePatchError, OSError, UnicodeError) as error:
        print(f"KAORIOS COREPATCH ERROR: {error}", file=__import__("sys").stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
