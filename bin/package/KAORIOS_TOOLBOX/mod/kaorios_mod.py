#!/usr/bin/env python3
"""Small command hub for HyperMOS-specific Kaorios integration."""
from __future__ import annotations

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
        "build_spoof",
        "secure_flag",
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
        config.setdefault("native_pif", True)
        return config


    def assignments(config: dict[str, bool]) -> dict[str, bool]:
        # Upstream v2.0.6.2 hooks (ActivityThread, Instrumentation, NameValueCache,
        # ComputerEngine, SystemServer) are one fixed set, so they follow "enabled".
        return {
            "KAORIOS_MASTER": config["enabled"],
            "KAORIOS_ENABLE_SYSTEM_SERVER": config["enabled"],
            "KAORIOS_ENABLE_BUILD_SPOOF": config["build_spoof"],
            "KAORIOS_ENABLE_SECURE_FLAG": config["secure_flag"],
            "KAORIOS_ENABLE_NATIVE_PIF": config["native_pif"],
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
        # Android 17 platform CIL contains nlmsg xperms unsupported by the
        # Ubuntu 24.04 secilc/libsepol 3.5. TNM builds a checksum-verified
        # isolated 3.11 compiler earlier in patchpackage.sh: reuse it here.
        # Android 16 intentionally keeps its existing system compiler path.
        repo_root = Path(__file__).resolve().parents[4]
        android_version_file = repo_root / "bin/ddevice/androidver.txt"
        android_version = (
            android_version_file.read_text(encoding="utf-8").strip()
            if android_version_file.is_file() else ""
        )
        if android_version == "17":
            compiler_path = repo_root / "build/tools/tnm-secilc-3.11/secilc"
            if not compiler_path.is_file() or not os.access(compiler_path, os.X_OK):
                raise IntegrationError(
                    "Android 17 requires SELinux 3.11 compiler prepared by TNM: "
                    + str(compiler_path)
                )
            compiler = str(compiler_path)
        else:
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
        print(f"KAORIOS SELinux: validating split policy using {compiler}", flush=True)
        result = subprocess.run(command, text=True, capture_output=True)
        (report_dir / "secilc.stdout.log").write_text(result.stdout, encoding="utf-8")
        (report_dir / "secilc.stderr.log").write_text(result.stderr, encoding="utf-8")
        if result.returncode:
            # Report the real compiler diagnostics in Actions as well as artifacts.
            print(result.stderr[-12000:] or result.stdout[-12000:], file=sys.stderr, flush=True)
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



COMMANDS = {
    "config": _cmd_config,
    "secure-flag": _cmd_secure_flag,
    "selinux": _cmd_selinux,
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
