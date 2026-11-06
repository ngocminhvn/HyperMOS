#!/usr/bin/env python3
"""Small command hub for HyperMOS-specific Kaorios integration."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path


# Config loader.
def _cmd_config() -> int:
    """Validate compact Kaorios config.json and emit derived build switches."""

    import argparse
    import json
    from pathlib import Path
    import sys


    ROOT_KEY = "KaoriosToolbox"
    CORE_FEATURES = (
        "enabled",
        "pif_spoof",
        "keybox",
        "hidden_app",
        "installer_source",
        "devstatus",
        "build_spoof",
        "secure_flag",
        "corepatch",
    )
    OPTIONAL_FEATURES = (
        "native_pif",
    )
    FEATURES = CORE_FEATURES + OPTIONAL_FEATURES


    def unique_object(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f"duplicate key: {key}")
            result[key] = value
        return result


    def load_config(path: Path) -> dict[str, bool]:
        try:
            root = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
        except (OSError, UnicodeError, json.JSONDecodeError, ValueError) as error:
            raise ValueError(f"cannot read valid JSON from {path}: {error}") from error
        if not isinstance(root, dict) or set(root) != {ROOT_KEY}:
            raise ValueError(f"top level must contain only {ROOT_KEY!r}")
        entries = root[ROOT_KEY]
        if not isinstance(entries, list) or len(entries) != 1 or not isinstance(entries[0], dict):
            raise ValueError(f"{ROOT_KEY} must be an array containing exactly one object")
        config = entries[0]
        missing = sorted(set(CORE_FEATURES) - set(config))
        unknown = sorted(set(config) - set(FEATURES))
        if missing or unknown:
            raise ValueError(f"feature keys mismatch; missing={missing}, unknown={unknown}")
        invalid = sorted(key for key, item in config.items() if type(item) is not bool)
        if invalid:
            raise ValueError(f"feature values must be JSON booleans: {invalid}")
        config.setdefault("native_pif", config.get("pif_spoof", True))
        return config


    def assignments(config: dict[str, bool]) -> dict[str, bool]:
        runtime = config["pif_spoof"] or config["keybox"]
        system_server = runtime or config["hidden_app"] or config["installer_source"] or config["devstatus"]
        return {
            "KAORIOS_MASTER": config["enabled"],
            "KAORIOS_ENABLE_ACTIVITY_THREAD": runtime,
            "KAORIOS_ENABLE_INSTRUMENTATION": runtime,
            "KAORIOS_ENABLE_KEYBOX": config["keybox"],
            "KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF": config["pif_spoof"],
            "KAORIOS_ENABLE_SYSTEM_SERVER": system_server,
            "KAORIOS_ENABLE_HIDDEN_APP": config["hidden_app"],
            "KAORIOS_ENABLE_INSTALLER_SOURCE": config["installer_source"],
            "KAORIOS_ENABLE_DEVSTATUS": config["devstatus"],
            "KAORIOS_ENABLE_BUILD_SPOOF": config["build_spoof"],
            "KAORIOS_ENABLE_SECURE_FLAG": config["secure_flag"],
            "KAORIOS_ENABLE_COREPATCH": config["corepatch"],
            "KAORIOS_ENABLE_NATIVE_PIF": config["native_pif"],
            "KAORIOS_INSTALL_TOOLBOX": config["enabled"],
            "KAORIOS_VERBOSE_LOG": False,
        }


    def main() -> int:
        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument("config", type=Path)
        parser.add_argument("--get", choices=FEATURES, help="print one feature value only")
        args = parser.parse_args()
        try:
            config = load_config(args.config)
        except ValueError as error:
            print(f"KAORIOS: {error}", file=sys.stderr)
            return 1
        if args.get:
            print("true" if config[args.get] else "false")
        else:
            for variable, value in assignments(config).items():
                print(f"{variable}={'true' if value else 'false'}")
        return 0
    result = main()
    return 0 if result is None else result


# Upstream compatibility adapter.
def _cmd_adapter() -> int:
    """MOD-only adapter around unmodified Kaorios upstream patchers.

    Keep MOD policy/config logic out of upstream-owned files so Kaorios scripts
    can be replaced wholesale on update. If upstream changes the private
    ComputerEngine helper API, this adapter fails closed and becomes the single
    compatibility layer that needs updating.
    """

    import argparse
    import importlib.util
    import re
    from pathlib import Path

    MOD_DIR = Path(__file__).resolve().parent
    UPSTREAM_SCRIPT_DIR = MOD_DIR.parent / "script"


    def _load(filename: str, module_name: str):
        path = UPSTREAM_SCRIPT_DIR / filename
        if not path.is_file():
            raise RuntimeError(f"missing upstream Kaorios module: {path}")
        spec = importlib.util.spec_from_file_location(module_name, path)
        if spec is None or spec.loader is None:
            raise RuntimeError(f"cannot load upstream Kaorios module: {path}")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return module


    def _parse_bool(value: str) -> bool:
        value = value.strip().lower()
        if value in {"1", "true", "yes", "on"}:
            return True
        if value in {"0", "false", "no", "off"}:
            return False
        raise argparse.ArgumentTypeError(f"invalid boolean: {value!r}")


    def _services_module():
        module = _load("patch-services-a17.py", "kaorios_upstream_services")
        for name in ("_patch_visibility", "_verify_visibility"):
            if not callable(getattr(module, name, None)):
                raise RuntimeError(
                    f"upstream patch-services-a17.py no longer exposes {name}; "
                    "update the adapter command in kaorios_mod.py"
                )
        return module


    def _installer_module(services, text: str):
        helper = getattr(services, "_installer_patcher", None)
        if callable(helper):
            return helper(text)
        if not re.search(
            r"(?m)^\.method[^\n]*\b(?:getInstallerPackageName|getInstallSourceInfo)\(",
            text,
        ):
            return None
        module = _load("patch-installer-source.py", "kaorios_upstream_installer")
        if not callable(getattr(module, "patch", None)) or not callable(getattr(module, "verify", None)):
            raise RuntimeError(
                "upstream patch-installer-source.py API changed; update kaorios_mod.py"
            )
        return module


    def verify_selected(text: str, *, hidden_app: bool, installer_source: bool) -> None:
        if not hidden_app and not installer_source:
            raise ValueError("no ComputerEngine feature selected")
        services = _services_module()
        if hidden_app:
            services._verify_visibility(text)
        if installer_source:
            installer = _installer_module(services, text)
            if installer is not None:
                installer.verify(text)


    def patch_selected(text: str, *, hidden_app: bool, installer_source: bool) -> tuple[str, bool]:
        if not hidden_app and not installer_source:
            raise ValueError("no ComputerEngine feature selected")
        services = _services_module()
        patched = text
        changed = False
        if hidden_app:
            patched, visibility_changed = services._patch_visibility(patched)
            changed = changed or visibility_changed
        if installer_source:
            installer = _installer_module(services, patched)
            if installer is not None:
                patched, installer_changed = installer.patch(patched)
                changed = changed or installer_changed
        verify_selected(patched, hidden_app=hidden_app, installer_source=installer_source)
        return patched, changed


    def main() -> None:
        parser = argparse.ArgumentParser(
            description="MOD compatibility adapter for Kaorios ComputerEngine hooks."
        )
        parser.add_argument("smali", type=Path)
        parser.add_argument("--hidden-app", required=True, type=_parse_bool)
        parser.add_argument("--installer-source", required=True, type=_parse_bool)
        parser.add_argument("--check-only", action="store_true")
        args = parser.parse_args()
        original = args.smali.read_text(encoding="utf-8")
        if args.check_only:
            verify_selected(
                original,
                hidden_app=args.hidden_app,
                installer_source=args.installer_source,
            )
            print("verified")
            return
        patched, changed = patch_selected(
            original,
            hidden_app=args.hidden_app,
            installer_source=args.installer_source,
        )
        if changed:
            args.smali.write_text(patched, encoding="utf-8")
        print("patched" if changed else "already patched")
    result = main()
    return 0 if result is None else result


# Secure Flag patcher.
def _cmd_secure_flag() -> int:
    """Apply or verify MOD-local permanent FLAG_SECURE bypasses."""


    import argparse
    import re
    import sys
    from dataclasses import dataclass
    from pathlib import Path


    @dataclass(frozen=True)
    class Target:
        relative_class: str
        signature: str
        static_return: tuple[str, ...]


    SERVICES_REQUIRED_TARGETS = (
        Target(
            "com/android/server/devicepolicy/DevicePolicyCacheImpl.smali",
            "isScreenCaptureAllowed(I)Z",
            ("const/4 v0, 0x1", "return v0"),
        ),
        Target(
            "com/android/server/wm/WindowState.smali",
            "isSecureLocked()Z",
            ("const/4 v0, 0x0", "return v0"),
        ),
        Target(
            "com/android/server/wm/WindowState.smali",
            "setSecureLocked(Z)V",
            ("return-void",),
        ),
        Target(
            "com/android/server/wm/WindowStateAnimator.smali",
            "isSecureLocked()Z",
            ("const/4 v0, 0x0", "return v0"),
        ),
        Target(
            "com/android/server/wm/WindowStateAnimator.smali",
            "setSecureLocked(Z)V",
            ("return-void",),
        ),
    )

    MIUI_SERVICES_TARGETS = (
        Target(
            "com/android/server/wm/WindowManagerServiceImpl.smali",
            "notAllowCaptureDisplay(Lcom/android/server/wm/RootWindowContainer;I)Z",
            ("const/4 v0, 0x0", "return v0"),
        ),
    )

    # Backward-compatible alias used by existing tests and external callers.
    TARGETS = SERVICES_REQUIRED_TARGETS


    class PatchError(RuntimeError):
        pass


    def find_unique(root: Path, relative: str) -> Path | None:
        matches = [path for path in root.rglob(Path(relative).name) if path.as_posix().endswith(relative)]
        if len(matches) > 1:
            raise PatchError(f"expected at most one {relative}, found {len(matches)}")
        return matches[0] if matches else None


    def method_span(text: str, signature: str) -> tuple[int, int]:
        header = re.compile(rf"(?m)^\.method[^\n]*\s{re.escape(signature)}[ \t]*$")
        matches = list(header.finditer(text))
        if len(matches) != 1:
            raise PatchError(f"expected exactly one method {signature}, found {len(matches)}")
        end = text.find("\n.end method", matches[0].end())
        if end < 0:
            raise PatchError(f"unterminated method {signature}")
        return matches[0].start(), end + len("\n.end method")


    def body_offset(block: str, signature: str) -> int:
        lines = block.splitlines(keepends=True)
        register_index = next(
            (index for index, line in enumerate(lines) if re.match(r"\s*\.(?:registers|locals)\s+", line)),
            None,
        )
        if register_index is None:
            raise PatchError(f"{signature}: missing .registers/.locals")

        annotation_depth = 0
        for index in range(register_index + 1, len(lines)):
            stripped = lines[index].strip()
            if stripped.startswith(".annotation") or stripped.startswith(".subannotation"):
                annotation_depth += 1
                continue
            if stripped.startswith(".end annotation") or stripped.startswith(".end subannotation"):
                annotation_depth -= 1
                continue
            if annotation_depth:
                continue
            if not stripped or stripped.startswith("#") or stripped.startswith("."):
                continue
            return sum(len(line) for line in lines[:index])
        raise PatchError(f"{signature}: no original instruction/label found")


    def parameter_slots(signature: str, is_static: bool) -> int:
        descriptor = signature[signature.index("(") + 1 : signature.index(")")]
        slots = 0
        index = 0
        while index < len(descriptor):
            char = descriptor[index]
            if char in "JD":
                slots += 2
                index += 1
            elif char == "L":
                slots += 1
                index = descriptor.index(";", index) + 1
            elif char == "[":
                slots += 1
                index += 1
                while descriptor[index] == "[":
                    index += 1
                index = descriptor.index(";", index) + 1 if descriptor[index] == "L" else index + 1
            else:
                slots += 1
                index += 1
        return slots if is_static else slots + 1


    def static_method(block: str, target: Target) -> str:
        offset = body_offset(block, target.signature)
        prefix = block[:offset]
        if any("v0" in line for line in target.static_return):
            register = re.search(r"(?m)^([ \t]*)\.(locals|registers)[ \t]+(\d+)[ \t]*$", prefix)
            if register is None:
                raise PatchError(f"{target.signature}: missing .registers/.locals")
            count = int(register.group(3), 0)
            if register.group(2) == "locals":
                required = max(count, 1)
            else:
                header = block.splitlines()[0]
                required = max(count, parameter_slots(target.signature, " static " in f" {header} ") + 1)
            replacement = f"{register.group(1)}.{register.group(2)} {required}"
            prefix = prefix[: register.start()] + replacement + prefix[register.end() :]
        body = "".join(f"    {line}\n" for line in target.static_return)
        return prefix + body + ".end method"


    def executable_instructions(block: str) -> tuple[str, ...]:
        """Return opcodes while ignoring baksmali's non-semantic metadata.

        A smali assemble/disassemble round trip may move ``.line``, ``.param`` and
        annotation directives between otherwise identical instructions. Final
        artifact verification must validate the bypass behavior, not require the
        regenerated text to match our pre-assembly text byte for byte.
        """
        instructions = []
        annotation_depth = 0
        for line in block.splitlines()[1:]:
            stripped = line.strip()
            if stripped.startswith((".annotation", ".subannotation")):
                annotation_depth += 1
                continue
            if stripped.startswith((".end annotation", ".end subannotation")):
                annotation_depth = max(0, annotation_depth - 1)
                continue
            if annotation_depth or not stripped:
                continue
            if stripped.startswith(("#", ".", ":")):
                continue
            instructions.append(stripped)
        return tuple(instructions)


    def has_static_return(block: str, target: Target) -> bool:
        return executable_instructions(block) == target.static_return


    def patch_target(path: Path, target: Target, check_only: bool) -> bool:
        text = path.read_text(encoding="utf-8")
        start, end = method_span(text, target.signature)
        block = text[start:end]
        if has_static_return(block, target):
            return False
        if check_only:
            raise PatchError(f"{path}: missing permanent bypass in {target.signature}")
        desired = static_method(block, target)
        path.write_text(text[:start] + desired + text[end:], encoding="utf-8")
        return True


    def patch_if_supported(root: Path, target: Target, check_only: bool) -> bool:
        path = find_unique(root, target.relative_class)
        if path is None:
            return False
        try:
            changed = patch_target(path, target, check_only)
        except PatchError as exc:
            if "expected exactly one method" in str(exc) and "found 0" in str(exc):
                return False
            raise
        if changed:
            print(f"KAORIOS: statically patched {target.signature} in {path.name}")
        return True


    def run_services(root: Path, check_only: bool) -> int:
        device_policy = find_unique(root, SERVICES_REQUIRED_TARGETS[0].relative_class)
        if device_policy is None:
            raise PatchError("DevicePolicyCacheImpl.smali not found")
        patch_target(device_policy, SERVICES_REQUIRED_TARGETS[0], check_only)

        window_patched = 0
        for target in SERVICES_REQUIRED_TARGETS[1:]:
            if patch_if_supported(root, target, check_only):
                window_patched += 1
        if window_patched == 0:
            raise PatchError("no supported WindowState/WindowStateAnimator secure method found")

        print("KAORIOS: static Secure Flag bypasses verified" if check_only else "KAORIOS: static Secure Flag bypasses applied")
        return 0


    def run_miui_services(root: Path, check_only: bool) -> int:
        target = MIUI_SERVICES_TARGETS[0]
        path = find_unique(root, target.relative_class)
        if path is None:
            raise PatchError("WindowManagerServiceImpl.smali not found in miui-services")
        patch_target(path, target, check_only)
        print(
            "KAORIOS: Xiaomi static Secure Flag bypass verified"
            if check_only
            else "KAORIOS: Xiaomi static Secure Flag bypass applied"
        )
        return 0


    def run(root: Path, check_only: bool, archive: str = "services") -> int:
        if archive == "services":
            return run_services(root, check_only)
        if archive == "miui-services":
            return run_miui_services(root, check_only)
        raise PatchError(f"unsupported archive kind: {archive}")


    def main() -> int:
        parser = argparse.ArgumentParser()
        parser.add_argument("root", type=Path)
        parser.add_argument("--check-only", action="store_true")
        parser.add_argument("--archive", choices=("services", "miui-services"), default="services")
        args = parser.parse_args()
        try:
            return run(args.root, args.check_only, args.archive)
        except (OSError, PatchError, ValueError) as exc:
            print(f"KAORIOS: Secure Flag patch failed: {exc}", file=sys.stderr)
            return 1
    result = main()
    return 0 if result is None else result


# Developer status patcher.
def _cmd_devstatus() -> int:
    """Fail-closed Kaorios "hide Developer options / ADB" patch for Settings$NameValueCache.

    Injects the Kaorios framework driver hook

        Landroid/security/kaorios/KaoriosHook;->shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z

    at the head of

        Landroid/provider/Settings$NameValueCache;->getStringForUser(Landroid/content/ContentResolver;Ljava/lang/String;I)Ljava/lang/String;

    so that the per-app AdvancedPolicy rules managed by Kaorios Toolbox can blank
    developer/ADB related settings reads for a selected app. When the driver returns
    a non-null Boolean TRUE the method returns "0" (developer options off) instead of
    the stored value; when it returns null the stock body runs unchanged.

    This module is deliberately HyperMOS-local: the maintained upstream
    ``kaorios_patcher.py`` documents this target as an optional, per-ROM manual patch
    (guide section 11), so keeping the logic in a separate fail-closed module avoids
    diverging from the upstream patcher and its verifier set. The injected block is
    identical in shape to the upstream Template_V2060/a1x reference smali for the
    supported Android 15, 16 and 17 layouts.

    Exit codes
        0   patched, or already patched and structurally verified
        1   hard failure (ambiguous target, failed verification, bad usage, --strict skip)
        3   skipped: target file absent, or layout not safely supported
    """

    import argparse
    import re
    import sys
    from pathlib import Path

    TARGET_REL = "android/provider/Settings$NameValueCache.smali"
    CLASS_DESC = "Landroid/provider/Settings$NameValueCache;"
    METHOD_ANCHOR = (
        "getStringForUser"
        "(Landroid/content/ContentResolver;Ljava/lang/String;I)Ljava/lang/String;"
    )
    HOOK = (
        "Landroid/security/kaorios/KaoriosHook;->"
        "shouldHideDevStatusFromNameValueCache"
        "(Landroid/content/ContentResolver;Ljava/lang/String;I)Z"
    )
    LABEL = ":cond_kaorios_dev_stock"
    HIDDEN_VALUE = "0"
    SCRATCH = "v0"
    INDENT = "    "
    PARAM_COUNT = 4  # p0=this, p1=ContentResolver, p2=String name, p3=int user

    CLASS_RE = re.compile(r"(?m)^\.class[^\r\n]*" + re.escape(CLASS_DESC) + r"[ \t]*(?:\r?\n|$)")
    METHOD_RE = re.compile(
        r"(?m)^\.method[^\r\n]*" + re.escape(METHOD_ANCHOR) + r"[ \t]*(?:\r?\n|$)"
    )
    METHOD_END_RE = re.compile(r"(?m)^[ \t]*\.end method[ \t]*(?:\r?\n|$)")
    LOCALS_RE = re.compile(r"(?m)^[ \t]*\.locals[ \t]+(\d+)[ \t]*(?:\r?\n|$)")
    REGISTERS_RE = re.compile(r"(?m)^[ \t]*\.registers[ \t]+(\d+)[ \t]*(?:\r?\n|$)")


    class UnsupportedLayout(ValueError):
        """The target method is present but its layout cannot be patched safely."""


    class VerifyError(ValueError):
        """The patched method does not satisfy the required hook structure."""


    def _method_span(text: str) -> tuple[int, int]:
        """Return (start, end) of the target getStringForUser method, inclusive of .end method."""
        if not CLASS_RE.search(text):
            raise UnsupportedLayout(f"expected .class {CLASS_DESC} in Settings$NameValueCache.smali")
        matches = list(METHOD_RE.finditer(text))
        if len(matches) == 0:
            raise UnsupportedLayout(f"target method not found: {METHOD_ANCHOR}")
        if len(matches) > 1:
            raise UnsupportedLayout(f"ambiguous target method: found {len(matches)} matches of {METHOD_ANCHOR}")
        end = METHOD_END_RE.search(text, matches[0].end())
        if end is None:
            raise UnsupportedLayout("unterminated target method (missing .end method)")
        return matches[0].start(), end.end()


    def _body_start(body: str) -> int:
        """Offset of the first real instruction inside a method body.

        Directives, labels, comments, blank lines and complete annotation blocks are
        skipped so the hook lands exactly where the upstream reference templates put
        it: after the leading ``.line`` marker and before the stock first opcode.
        """
        offset = 0
        annotation_depth = 0
        for raw in body.splitlines(keepends=True):
            stripped = raw.strip()
            if annotation_depth > 0:
                offset += len(raw)
                if stripped.startswith(".end annotation"):
                    annotation_depth -= 1
                elif stripped.startswith(".annotation"):
                    annotation_depth += 1
                continue
            if not stripped or stripped[0] in ".:#":
                offset += len(raw)
                if stripped.startswith(".annotation"):
                    annotation_depth += 1
                continue
            return offset
        return offset


    def _local_slots(body: str) -> int:
        """Number of local registers available for scratch use.

        Raises UnsupportedLayout when the directive is missing or leaves no free
        local register for the Boolean scratch value.
        """
        match = LOCALS_RE.search(body)
        if match is not None:
            slots = int(match.group(1))
        else:
            match = REGISTERS_RE.search(body)
            if match is None:
                raise UnsupportedLayout("neither .locals nor .registers directive found in target method")
            slots = int(match.group(1)) - PARAM_COUNT
        if slots < 1:
            raise UnsupportedLayout(
                f"target method exposes {slots} local register(s); a free local is required for the scratch value"
            )
        return slots


    def _hook_block(newline: str) -> str:
        return (
            f"{INDENT}if-eqz p2, {LABEL}{newline}"
            f"{INDENT}invoke-static/range {{p1 .. p3}}, {HOOK}{newline}"
            f"{INDENT}move-result {SCRATCH}{newline}"
            f"{INDENT}if-eqz {SCRATCH}, {LABEL}{newline}"
            f"{INDENT}const-string {SCRATCH}, \"{HIDDEN_VALUE}\"{newline}"
            f"{INDENT}return-object {SCRATCH}{newline}"
            f"{newline}"
            f"{INDENT}{LABEL}{newline}"
        )


    def _hook_pattern(roundtrip: bool = False) -> re.Pattern[str]:
        """Match the injected block, optionally tolerating baksmali label renaming."""
        label = r"(?P<stock>:[A-Za-z0-9_]+)" if roundtrip else re.escape(LABEL)
        second_label = r"(?P=stock)" if roundtrip else re.escape(LABEL)
        return re.compile(
            r"(?m)^[ \t]*if-eqz[ \t]+p2,[ \t]*" + label + r"[ \t]*\r?\n"
            r"^[ \t]*invoke-static/range[ \t]*\{p1[ \t]*\.\.[ \t]*p3\},[ \t]*" + re.escape(HOOK) + r"[ \t]*\r?\n"
            r"^[ \t]*move-result[ \t]+(?P<scratch>v\d+)[ \t]*\r?\n"
            r"^[ \t]*if-eqz[ \t]+(?P=scratch),[ \t]*" + second_label + r"[ \t]*\r?\n"
            r"^[ \t]*const-string[ \t]+(?P=scratch),[ \t]*\"0\"[ \t]*\r?\n"
            r"^[ \t]*return-object[ \t]+(?P=scratch)[ \t]*\r?\n"
            r"(?:^[ \t]*\r?\n)*"
            r"^[ \t]*" + second_label + r"[ \t]*\r?\n"
        )


    def _parameter_aliases(body: str) -> dict[str, set[str]]:
        """Return p-register names and their equivalent v-register aliases."""
        locals_match = LOCALS_RE.search(body)
        if locals_match is not None:
            first_param = int(locals_match.group(1))
        else:
            registers_match = REGISTERS_RE.search(body)
            if registers_match is None:
                raise UnsupportedLayout("neither .locals nor .registers directive found in target method")
            first_param = int(registers_match.group(1)) - PARAM_COUNT
        return {
            "p1": {"p1", f"v{first_param + 1}"},
            "p2": {"p2", f"v{first_param + 2}"},
            "p3": {"p3", f"v{first_param + 3}"},
        }


    def _significant_lines(text: str) -> list[str]:
        """Strip formatting/debug directives while preserving opcodes and labels."""
        result: list[str] = []
        for raw in text.splitlines():
            stripped = raw.split("#", 1)[0].strip()
            if not stripped or stripped.startswith("."):
                continue
            result.append(stripped)
        return result


    def _verify_roundtrip_block(body: str) -> tuple[str, str]:
        """Verify the hook semantically after smali -> DEX -> baksmali round-trip."""
        head = _body_start(body)
        lines = _significant_lines(body[head:])
        preview = " | ".join(lines[:8])
        if len(lines) < 7:
            raise VerifyError(f"round-trip dev-status hook is truncated; head={preview}")

        aliases = _parameter_aliases(body)

        first = re.fullmatch(r"if-eqz\s+([^,]+),\s*(:[A-Za-z0-9_]+)", lines[0])
        if first is None or first.group(1) not in aliases["p2"]:
            raise VerifyError(f"round-trip dev-status first branch is invalid; head={preview}")
        stock_label = first.group(2)

        range_call = re.fullmatch(
            r"invoke-static/range\s*\{([^ ]+)\s*\.\.\s*([^ }]+)\},\s*" + re.escape(HOOK),
            lines[1],
        )
        normal_call = re.fullmatch(
            r"invoke-static\s*\{([^}]*)\},\s*" + re.escape(HOOK),
            lines[1],
        )
        if range_call is not None:
            if range_call.group(1) not in aliases["p1"] or range_call.group(2) not in aliases["p3"]:
                raise VerifyError(f"round-trip dev-status hook arguments are invalid; head={preview}")
        elif normal_call is not None:
            regs = [part.strip() for part in normal_call.group(1).split(",")]
            if (
                len(regs) != 3
                or regs[0] not in aliases["p1"]
                or regs[1] not in aliases["p2"]
                or regs[2] not in aliases["p3"]
            ):
                raise VerifyError(f"round-trip dev-status hook arguments are invalid; head={preview}")
        else:
            raise VerifyError(f"round-trip dev-status hook call is invalid; head={preview}")

        move = re.fullmatch(r"move-result\s+(v\d+)", lines[2])
        if move is None:
            raise VerifyError(f"round-trip dev-status move-result is invalid; head={preview}")
        scratch = move.group(1)

        if re.fullmatch(
            r"if-eqz\s+" + re.escape(scratch) + r",\s*" + re.escape(stock_label),
            lines[3],
        ) is None:
            raise VerifyError(f"round-trip dev-status second branch is invalid; head={preview}")

        if re.fullmatch(
            r"const-string(?:/jumbo)?\s+" + re.escape(scratch) + r',\s*"0"',
            lines[4],
        ) is None:
            raise VerifyError(f"round-trip dev-status hidden value is invalid; head={preview}")

        if re.fullmatch(r"return-object\s+" + re.escape(scratch), lines[5]) is None:
            raise VerifyError(f"round-trip dev-status return is invalid; head={preview}")

        if lines[6] != stock_label:
            raise VerifyError(f"round-trip dev-status stock label is invalid; head={preview}")

        return stock_label, scratch


    def _has_stock_instruction(body: str, label: str) -> bool:
        """Require a real opcode after the stock label, not just another label/end marker."""
        definition = re.search(r"(?m)^[ \t]*" + re.escape(label) + r"[ \t]*\r?\n", body)
        if definition is None:
            return False
        for line in body[definition.end():].splitlines():
            stripped = line.split("#", 1)[0].strip()
            if stripped and not stripped.startswith((".", ":")):
                return True
        return False


    def verify(text: str, *, roundtrip: bool = False) -> None:
        """Assert the method carries exactly one correctly placed Kaorios dev-status hook."""
        start, end = _method_span(text)
        body = text[start:end]
        _local_slots(body)

        hook_count = body.count(HOOK)
        if hook_count != 1:
            raise VerifyError(f"expected exactly one dev-status hook call, found {hook_count}")

        if roundtrip:
            label, _scratch = _verify_roundtrip_block(body)
        else:
            match = _hook_pattern(roundtrip=False).search(body)
            if match is None:
                raise VerifyError("dev-status hook block does not match the required fail-closed structure")
            label = LABEL
            head = _body_start(body)
            if match.start() < head or body[head:match.start()].strip():
                raise VerifyError("dev-status hook block is not at the head of the method body")
            if match.group("scratch") != SCRATCH:
                raise VerifyError(f"dev-status hook must use {SCRATCH} as scratch register, found {match.group('scratch')}")

        label_definitions = re.findall(r"(?m)^[ \t]*" + re.escape(label) + r"[ \t]*\r?$", body)
        if len(label_definitions) != 1:
            raise VerifyError(f"expected exactly one stock label definition for {label}, found {len(label_definitions)}")
        if not _has_stock_instruction(body, label):
            raise VerifyError("stock implementation is missing after the dev-status bypass label")


    def patch(text: str) -> tuple[str, bool]:
        start, end = _method_span(text)
        body = text[start:end]
        if HOOK in body:
            verify(text)
            return text, False
        if LABEL in body:
            raise UnsupportedLayout(f"reserved label {LABEL} already present in target method")
        _local_slots(body)

        newline = "\r\n" if "\r\n" in text else "\n"
        insert_at = start + _body_start(body)
        patched = text[:insert_at] + _hook_block(newline) + text[insert_at:]
        verify(patched)
        return patched, True


    def find_target(root: Path) -> Path | None:
        if root.is_file():
            return root
        matches = sorted(root.rglob(TARGET_REL))
        if len(matches) > 1:
            raise UnsupportedLayout(f"expected exactly one {TARGET_REL}, found {len(matches)}")
        return matches[0] if matches else None


    def main() -> int:
        parser = argparse.ArgumentParser(
            description="Patch/verify the Kaorios dev-status hook in Settings$NameValueCache."
        )
        parser.add_argument("path", type=Path, help="decompiled framework smali tree, or the target .smali file")
        parser.add_argument("--verify-only", action="store_true", help="verify without modifying")
        parser.add_argument(
            "--verify-roundtrip",
            action="store_true",
            help="verify semantic hook structure after smali/baksmali label renaming",
        )
        parser.add_argument("--strict", action="store_true", help="treat SKIP conditions as hard failures")
        args = parser.parse_args()

        try:
            target = find_target(args.path)
        except UnsupportedLayout as error:
            print(f"ERROR: {error}", file=sys.stderr)
            return 1

        if target is None:
            print(f"SKIP: {TARGET_REL} not present under {args.path}")
            return 1 if args.strict else 3

        try:
            text = target.read_bytes().decode("utf-8")
        except (OSError, UnicodeError) as error:
            print(f"ERROR: cannot read {target}: {error}", file=sys.stderr)
            return 1

        if args.verify_only:
            try:
                verify(text, roundtrip=args.verify_roundtrip)
            except (UnsupportedLayout, VerifyError) as error:
                print(f"ERROR: {error}", file=sys.stderr)
                return 1
            print(f"VERIFIED: {target}")
            return 0

        try:
            patched, changed = patch(text)
        except UnsupportedLayout as error:
            print(f"SKIP: {error}")
            return 1 if args.strict else 3
        except VerifyError as error:
            print(f"ERROR: {error}", file=sys.stderr)
            return 1

        if changed:
            try:
                target.write_bytes(patched.encode("utf-8"))
            except OSError as error:
                print(f"ERROR: cannot write {target}: {error}", file=sys.stderr)
                return 1
            print(f"PATCHED: {target}")
        else:
            print(f"ALREADY_PATCHED: {target}")
        return 0
    result = main()
    return 0 if result is None else result


# Android 17 Build spoof verifier.
def _cmd_verify_build() -> int:
    """Verify a decompiled Android 17 framework tree carries the Kaorios Build spoof.

    The Kaorios Build spoof only exists on Android 17 (guide section 7): the string
    fields of ``android/os/Build`` plus ``Build$VERSION`` must be writable at runtime
    so the Toolbox can rewrite them, which means the ``final`` modifier has to be
    gone. ``Build;->TIME:J`` only needs ``final`` removed.

    This is a structural check on the re-disassembled final artifact. It mirrors the
    post-patch assertions the upstream patcher performs on the smali it edits, so a
    broken DEX rebuild cannot silently ship an unspoofable Build class.
    """

    import argparse
    import re
    import sys
    from pathlib import Path

    BUILD_REL = "android/os/Build.smali"
    BUILD_VERSION_REL = "android/os/Build$VERSION.smali"

    BUILD_STRING_FIELDS = [
        "BRAND",
        "BRAND_FOR_ATTESTATION",
        "DEVICE",
        "DEVICE_FOR_ATTESTATION",
        "FINGERPRINT",
        "HARDWARE",
        "ID",
        "MANUFACTURER",
        "MANUFACTURER_FOR_ATTESTATION",
        "MODEL",
        "MODEL_FOR_ATTESTATION",
        "PRODUCT",
        "PRODUCT_FOR_ATTESTATION",
        "TAGS",
        "TYPE",
        "USER",
    ]
    VERSION_FIELDS = [
        "RELEASE",
        "RELEASE_OR_CODENAME",
        "RELEASE_OR_PREVIEW_DISPLAY",
        "SECURITY_PATCH",
        "DEVICE_INITIAL_SDK_INT",
    ]
    TIME_FIELD = "TIME"


    class VerifyError(ValueError):
        pass


    def find_unique(smali_root: Path, rel: str) -> Path:
        matches = sorted(smali_root.rglob(rel))
        if len(matches) != 1:
            raise VerifyError(f"expected exactly one {rel} below {smali_root}; found {len(matches)}")
        return matches[0]


    def _field_line(content: str, field: str, descriptor: str) -> str | None:
        match = re.search(rf"\.field[^\r\n]*[ \t]{re.escape(field)}:{re.escape(descriptor)}", content)
        return match.group(0) if match else None


    def verify_build(path: Path) -> None:
        content = path.read_bytes().decode("utf-8")
        for field in BUILD_STRING_FIELDS:
            line = _field_line(content, field, "Ljava/lang/String;")
            if line is None:
                if field.endswith("_FOR_ATTESTATION") and not re.search(rf"\.field[^\r\n]*[ \t]{re.escape(field)}:", content):
                    continue  # absent on this ROM/framework revision
                raise VerifyError(f"{path.name}: field {field}:Ljava/lang/String; not found")
            if "final" in line:
                raise VerifyError(f"{path.name}: field {field} still declares 'final' - Build spoof did not apply")

        time_line = _field_line(content, TIME_FIELD, "J")
        if time_line is None:
            raise VerifyError(f"{path.name}: field {TIME_FIELD}:J not found")
        if "final" in time_line:
            raise VerifyError(f"{path.name}: field {TIME_FIELD}:J still declares 'final' - Build spoof did not apply")


    def verify_version(path: Path) -> None:
        content = path.read_bytes().decode("utf-8")
        for field in VERSION_FIELDS:
            match = re.search(rf"\.field[^\r\n]*[ \t]{re.escape(field)}:[^\s]+", content)
            if match is None:
                raise VerifyError(f"{path.name}: field {field} not found")
            if "final" in match.group(0):
                raise VerifyError(f"{path.name}: field {field} still declares 'final' - Build spoof did not apply")


    def verify_root(smali_root: Path) -> tuple[Path, Path]:
        build = find_unique(smali_root, BUILD_REL)
        version = find_unique(smali_root, BUILD_VERSION_REL)
        verify_build(build)
        verify_version(version)
        return build, version


    def main() -> int:
        parser = argparse.ArgumentParser(description="Verify the Android 17 Kaorios Build spoof in a smali tree.")
        parser.add_argument("smali_root", type=Path)
        args = parser.parse_args()
        try:
            build, version = verify_root(args.smali_root)
        except (VerifyError, OSError, UnicodeError) as error:
            print(f"ERROR: {error}", file=sys.stderr)
            return 1
        print(f"verified Build spoof: {build}, {version}")
        return 0
    result = main()
    return 0 if result is None else result


# SELinux policy integration.
def _cmd_selinux() -> int:
    """Install the least-privilege SELinux contract for Kaorios AdvancedPolicy."""


    import argparse
    import os
    import re
    import shutil
    import subprocess
    import sys
    import tempfile
    from pathlib import Path


    SERVICE_NAME = "kaorios_advanced_policy"
    SERVICE_TYPE = "kaorios_advanced_policy_service"
    BEGIN = "; BEGIN HyperMOS KAORIOS ADVANCED POLICY (managed)"
    END = "; END HyperMOS KAORIOS ADVANCED POLICY (managed)"
    SERVICE_CONTEXT_LINE = (
        f"{SERVICE_NAME} u:object_r:{SERVICE_TYPE}:s0"
    )
    POLICY_BLOCK = f"""{BEGIN}
    (type {SERVICE_TYPE})
    (roletype object_r {SERVICE_TYPE})
    (typeattributeset service_manager_type ({SERVICE_TYPE}))
    (typeattributeset system_server_service ({SERVICE_TYPE}))
    (typeattributeset app_api_service ({SERVICE_TYPE}))
    (allow system_server {SERVICE_TYPE} (service_manager (add)))
    (allow priv_app {SERVICE_TYPE} (service_manager (find)))
    {END}
    """


    class IntegrationError(RuntimeError):
        pass


    def replace_managed_block(text: str, block: str) -> str:
        begin_count = text.count(BEGIN)
        end_count = text.count(END)
        if begin_count != end_count or begin_count > 1:
            raise IntegrationError("invalid or duplicated Kaorios managed policy markers")
        if begin_count == 1:
            start = text.index(BEGIN)
            try:
                finish = text.index(END, start) + len(END)
            except ValueError as exc:
                raise IntegrationError("Kaorios managed policy markers are out of order") from exc
            prefix = text[:start].rstrip()
            suffix = text[finish:].lstrip("\r\n")
            return f"{prefix}\n\n{block.rstrip()}\n" + suffix
        return f"{text.rstrip()}\n\n{block}" if text.strip() else block


    def replace_service_context(text: str) -> str:
        rows = []
        for line in text.splitlines():
            stripped = line.strip()
            if stripped and not stripped.startswith("#"):
                fields = stripped.split()
                if fields and fields[0] == SERVICE_NAME:
                    rows.append(stripped)
        if len(rows) > 1:
            raise IntegrationError(f"duplicate {SERVICE_NAME} service_contexts rows")
        if rows and rows[0] != SERVICE_CONTEXT_LINE:
            raise IntegrationError(
                f"conflicting {SERVICE_NAME} service_contexts row: {rows[0]}"
            )
        if rows:
            return text if text.endswith("\n") else text + "\n"
        return f"{text.rstrip()}\n{SERVICE_CONTEXT_LINE}\n" if text.strip() else SERVICE_CONTEXT_LINE + "\n"


    def ensure_no_unmanaged_type(policy: str) -> None:
        outside = policy
        if BEGIN in policy and END in policy:
            start = policy.index(BEGIN)
            finish = policy.index(END, start) + len(END)
            outside = policy[:start] + policy[finish:]
        if re.search(rf"(?<![A-Za-z0-9_]){re.escape(SERVICE_TYPE)}(?![A-Za-z0-9_])", outside):
            raise IntegrationError(
                f"{SERVICE_TYPE} already exists outside the managed block"
            )


    def validate_contract(policy: str, contexts: str) -> None:
        required = (
            f"(type {SERVICE_TYPE})",
            f"(roletype object_r {SERVICE_TYPE})",
            f"(typeattributeset service_manager_type ({SERVICE_TYPE}))",
            f"(typeattributeset system_server_service ({SERVICE_TYPE}))",
            f"(typeattributeset app_api_service ({SERVICE_TYPE}))",
            f"(allow system_server {SERVICE_TYPE} (service_manager (add)))",
            f"(allow priv_app {SERVICE_TYPE} (service_manager (find)))",
        )
        if policy.count(BEGIN) != 1 or policy.count(END) != 1:
            raise IntegrationError("Kaorios managed policy block is absent or duplicated")
        for expression in required:
            if policy.count(expression) != 1:
                raise IntegrationError(f"missing or duplicated policy expression: {expression}")
        active_rows = [
            line.strip()
            for line in contexts.splitlines()
            if line.strip() and not line.lstrip().startswith("#")
            and line.split()[0] == SERVICE_NAME
        ]
        if active_rows != [SERVICE_CONTEXT_LINE]:
            raise IntegrationError(
                f"expected exactly one service_contexts row: {SERVICE_CONTEXT_LINE}"
            )


    def policy_inputs(images: Path, candidate: Path) -> list[Path]:
        platform = images / "system/system/etc/selinux"
        if not platform.is_dir():
            platform = images / "system/etc/selinux"
        vendor = images / "vendor/etc/selinux"
        version_path = vendor / "plat_sepolicy_vers.txt"
        if not version_path.is_file():
            raise IntegrationError(f"missing SELinux mapping version: {version_path}")
        version = version_path.read_text(encoding="utf-8").strip()
        if not version.replace(".", "").isdigit():
            raise IntegrationError(f"invalid SELinux mapping version: {version!r}")

        inputs = [
            platform / "plat_sepolicy.cil",
            platform / "mapping" / f"{version}.cil",
        ]
        optional = [platform / "mapping" / f"{version}.compat.cil"]
        for partition in ("system_ext", "product"):
            folder = images / partition / "etc/selinux"
            selected = candidate if partition == "system_ext" else folder / "product_sepolicy.cil"
            optional.extend(
                (
                    selected,
                    folder / "mapping" / f"{version}.cil",
                    folder / "mapping" / f"{version}.compat.cil",
                )
            )
        inputs.extend(path for path in optional if path.is_file())
        inputs.extend(
            (
                vendor / "plat_pub_versioned.cil",
                vendor / "vendor_sepolicy.cil",
            )
        )
        odm = images / "odm/etc/selinux/odm_sepolicy.cil"
        if odm.is_file():
            inputs.append(odm)
        missing = [path for path in inputs if not path.is_file()]
        if missing:
            raise IntegrationError("missing split policy inputs: " + ", ".join(map(str, missing)))
        return inputs


    def compile_policy(images: Path, candidate: Path, report_dir: Path) -> None:
        compiler = shutil.which("secilc")
        if not compiler:
            raise IntegrationError("secilc is required to validate the final split policy")
        report_dir.mkdir(parents=True, exist_ok=True)
        output = report_dir / "compiled-policy"
        file_contexts = report_dir / "compiled-file-contexts"
        command = [
            compiler, "-m", "-M", "true", "-G", "-N", "-c", "30",
            *map(str, policy_inputs(images, candidate)),
            "-o", str(output), "-f", str(file_contexts),
        ]
        result = subprocess.run(command, text=True, capture_output=True)
        (report_dir / "secilc.stdout.log").write_text(result.stdout, encoding="utf-8")
        (report_dir / "secilc.stderr.log").write_text(result.stderr, encoding="utf-8")
        if result.returncode:
            raise IntegrationError(
                "split policy compilation failed; see " + str(report_dir / "secilc.stderr.log")
            )
        output.unlink(missing_ok=True)
        file_contexts.unlink(missing_ok=True)


    def precompiled_caches(images: Path) -> list[Path]:
        paths: list[Path] = []
        for partition in ("vendor", "odm"):
            directory = images / partition / "etc/selinux"
            if directory.is_dir():
                paths.extend(sorted(directory.glob("precompiled_sepolicy*")))
        return [path for path in paths if path.is_file() or path.is_symlink()]


    def atomic_write(path: Path, data: str) -> None:
        mode = path.stat().st_mode
        with tempfile.NamedTemporaryFile(
            "w", encoding="utf-8", newline="\n", dir=path.parent, delete=False
        ) as handle:
            handle.write(data)
            temporary = Path(handle.name)
        os.chmod(temporary, mode)
        os.replace(temporary, path)


    def integrate(images: Path, report_dir: Path, check_only: bool) -> None:
        policy = images / "system_ext/etc/selinux/system_ext_sepolicy.cil"
        contexts = images / "system_ext/etc/selinux/system_ext_service_contexts"
        for path in (policy, contexts):
            if not path.is_file():
                raise IntegrationError(f"missing required SELinux input: {path}")

        original_policy = policy.read_text(encoding="utf-8")
        original_contexts = contexts.read_text(encoding="utf-8")
        if check_only:
            validate_contract(original_policy, original_contexts)
            if precompiled_caches(images):
                raise IntegrationError("stale precompiled_sepolicy cache remains after policy change")
            compile_policy(images, policy, report_dir)
            return

        ensure_no_unmanaged_type(original_policy)
        proposed_policy = replace_managed_block(original_policy, POLICY_BLOCK)
        proposed_contexts = replace_service_context(original_contexts)
        validate_contract(proposed_policy, proposed_contexts)

        report_dir.mkdir(parents=True, exist_ok=True)
        candidate = report_dir / "system_ext_sepolicy.cil.candidate"
        candidate.write_text(proposed_policy, encoding="utf-8", newline="\n")
        compile_policy(images, candidate, report_dir)

        backups = {
            policy: original_policy,
            contexts: original_contexts,
        }
        try:
            atomic_write(policy, proposed_policy)
            atomic_write(contexts, proposed_contexts)
            for cache in precompiled_caches(images):
                cache.unlink()
            validate_contract(
                policy.read_text(encoding="utf-8"),
                contexts.read_text(encoding="utf-8"),
            )
        except Exception:
            for path, data in backups.items():
                atomic_write(path, data)
            raise


    def main() -> int:
        parser = argparse.ArgumentParser()
        parser.add_argument("--images", type=Path, required=True)
        parser.add_argument("--report-dir", type=Path, required=True)
        parser.add_argument("--check", action="store_true")
        args = parser.parse_args()
        try:
            integrate(args.images.resolve(), args.report_dir.resolve(), args.check)
        except (IntegrationError, OSError) as exc:
            print(f"KAORIOS SELinux: {exc}", file=sys.stderr)
            return 1
        action = "verified" if args.check else "integrated"
        print(f"KAORIOS SELinux: AdvancedPolicy contract {action}")
        return 0
    result = main()
    return 0 if result is None else result


def _cmd_build_native() -> int:
    """Rebuild the two checked-in native PIF libraries with Android NDK r27+."""
    if len(sys.argv) != 2:
        raise SystemExit("usage: kaorios_mod.py build-native /path/to/android-ndk")
    ndk = Path(sys.argv[1]).resolve()
    toolchain = ndk / "toolchains/llvm/prebuilt/linux-x86_64/bin"
    native = Path(__file__).resolve().parent / "native_pif"
    source = native / "property_overlay.c"
    targets = (
        ("aarch64-linux-android33-clang", native / "arm64-v8a/libkaoripif.so"),
        ("armv7a-linux-androideabi33-clang", native / "armeabi-v7a/libkaoripif.so"),
    )
    for compiler, output in targets:
        output.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            [
                str(toolchain / compiler), "-std=c11", "-O2", "-fPIC", "-shared",
                "-fvisibility=hidden", "-Wall", "-Wextra", "-Werror",
                "-Wl,-soname,libkaoripif.so", "-Wl,-z,relro,-z,now", "-llog",
                str(source), "-o", str(output),
            ],
            check=True,
        )
        subprocess.run(
            [str(toolchain / "llvm-strip"), "--strip-unneeded", str(output)],
            check=True,
        )
        output.chmod(0o644)
        print(f"built {output}")
    return 0


COMMANDS = {
    "config": _cmd_config,
    "adapter": _cmd_adapter,
    "secure-flag": _cmd_secure_flag,
    "devstatus": _cmd_devstatus,
    "verify-build": _cmd_verify_build,
    "selinux": _cmd_selinux,
    "build-native": _cmd_build_native,
}


def _main() -> int:
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        names = ", ".join(COMMANDS)
        print(f"usage: {Path(sys.argv[0]).name} <{names}> [args...]", file=sys.stderr)
        return 2
    command = sys.argv.pop(1)
    return COMMANDS[command]()


if __name__ == "__main__":
    raise SystemExit(_main())
