#!/usr/bin/env python3
"""Read-only build validator for Kaorios AdvancedPolicy SELinux deployment.

This script never edits SELinux policy. It:
  * resolves the SettingsProvider domain from the extracted ROM seapp_contexts;
  * runs the existing read-only checker for service_contexts/add/find/binder access;
  * requires a complete split-CIL input set and verifies it compiles with secilc;
  * reports precompiled policy artifacts so the build log makes runtime policy
    selection visible.

Exit 0 only when the extracted ROM already contains a valid policy deployment.
"""

from __future__ import annotations

import argparse
import importlib.util
import re
import shutil
import subprocess
import sys
from pathlib import Path

SERVICE = "kaorios_advanced_policy"
REQUIRED_REPORT = (
    "POLICY_TYPE_DEFINED",
    "SYSTEM_SERVER_ADD_ALLOWED",
    "SETTINGS_DOMAIN_FIND_ALLOWED",
    "BINDER_CALL_PATH_ALLOWED",
)


def die(message: str) -> int:
    print(f"KAORIOS-SEPOLICY-VALIDATE: ERROR: {message}", file=sys.stderr)
    return 1


def info(message: str) -> None:
    print(f"KAORIOS-SEPOLICY-VALIDATE: {message}")


def load_helpers(script_dir: Path):
    path = script_dir / "patch-advanced-policy-sepolicy.py"
    if not path.is_file():
        raise RuntimeError(f"missing policy helper: {path}")
    spec = importlib.util.spec_from_file_location("kaorios_policy_helpers", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load policy helper: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def parse_report(stdout: str) -> dict[str, str]:
    report: dict[str, str] = {}
    for line in stdout.splitlines():
        key, sep, value = line.partition("=")
        if sep:
            report[key.strip()] = value.strip()
    return report


def find_precompiled(root: Path) -> list[Path]:
    matches: list[Path] = []
    for partition in ("vendor", "odm"):
        for base in (
            root / partition / "etc/selinux",
            root / "system" / partition / "etc/selinux",
            root / partition / partition / "etc/selinux",
        ):
            if not base.is_dir():
                continue
            for path in sorted(base.glob("precompiled_sepolicy*")):
                if path.is_file():
                    matches.append(path)
    return matches


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path, help="extracted ROM images root")
    args = parser.parse_args()

    root = args.root.resolve()
    if not root.is_dir():
        return die(f"ROM images root does not exist: {root}")

    script_dir = Path(__file__).resolve().parent
    checker = script_dir / "check-advanced-policy-sepolicy.py"
    if not checker.is_file():
        return die(f"missing read-only checker: {checker}")

    if shutil.which("secilc") is None:
        return die("secilc is not installed on the build host")

    try:
        helpers = load_helpers(script_dir)
        sources = helpers.policy_sources(root)
        named, generic = helpers.seapp_candidates(root)
        domain = helpers.resolve_domain(sources, named, generic)
    except Exception as exc:
        return die(f"failed to inspect ROM policy layout: {exc}")

    if not domain:
        return die("could not resolve a unique SettingsProvider SELinux domain from ROM seapp_contexts")
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", domain):
        return die(f"resolved invalid SettingsProvider domain: {domain!r}")
    info(f"SettingsProvider domain = {domain}")

    command = [
        sys.executable,
        str(checker),
        "--root",
        str(root),
        "--settings-domain",
        domain,
    ]
    try:
        checked = subprocess.run(command, capture_output=True, text=True, timeout=600)
    except (OSError, subprocess.SubprocessError) as exc:
        return die(f"checker execution failed: {exc}")

    if checked.stdout:
        print(checked.stdout, end="")
    if checked.stderr:
        print(checked.stderr, end="", file=sys.stderr)

    report = parse_report(checked.stdout)
    if report.get("SERVICE_CONTEXT_MAPPING") != "FOUND":
        return die("service_contexts mapping is not uniquely present and valid")

    missing = [key for key in REQUIRED_REPORT if report.get(key) != "YES"]
    if missing:
        return die("required SELinux checks failed: " + ", ".join(missing))

    try:
        inputs = helpers.compile_inputs(root)
    except Exception as exc:
        return die(f"failed to enumerate split-CIL inputs: {exc}")
    if not inputs:
        return die("split-CIL compile inputs are incomplete")

    info("secilc inputs:")
    for path in inputs:
        print(f"  - {path}")

    try:
        compile_mode = helpers.compile_mode(inputs)
    except Exception as exc:
        return die(f"secilc validation failed: {exc}")
    if compile_mode is None:
        return die("current extracted SELinux policy does not compile cleanly with secilc")

    info(
        "split-CIL policy compiles successfully "
        + ("with neverallow checks" if compile_mode else "with -N fallback")
    )

    precompiled = find_precompiled(root)
    if precompiled:
        info("precompiled policy artifacts detected (read-only; not modified):")
        for path in precompiled:
            print(f"  - {path}")
    else:
        info("no precompiled_sepolicy artifacts detected")

    info(f"{SERVICE} SELinux deployment validation PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
