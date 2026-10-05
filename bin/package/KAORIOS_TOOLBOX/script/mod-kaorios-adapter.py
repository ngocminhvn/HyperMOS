#!/usr/bin/env python3
"""MOD-only adapter around unmodified Kaorios upstream patchers.

Keep MOD policy/config logic out of upstream-owned files so Kaorios scripts
can be replaced wholesale on update. If upstream changes the private
ComputerEngine helper API, this adapter fails closed and becomes the single
compatibility layer that needs updating.
"""
from __future__ import annotations

import argparse
import importlib.util
import re
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent


def _load(filename: str, module_name: str):
    path = SCRIPT_DIR / filename
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
                "update mod-kaorios-adapter.py for the new upstream layout"
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
            "upstream patch-installer-source.py API changed; update mod-kaorios-adapter.py"
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


if __name__ == "__main__":
    main()
