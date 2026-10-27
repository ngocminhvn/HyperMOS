#!/usr/bin/env python3
"""Install the least-privilege SELinux contract for Kaorios AdvancedPolicy."""

from __future__ import annotations

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


if __name__ == "__main__":
    raise SystemExit(main())
