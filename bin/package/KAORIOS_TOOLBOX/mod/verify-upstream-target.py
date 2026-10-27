#!/usr/bin/env python3
"""Verify one saved smali target with the vendored Kaorios verifier."""
from __future__ import annotations

import argparse
import importlib.util
from pathlib import Path


def load_patcher(path: Path):
    spec = importlib.util.spec_from_file_location("kaorios_upstream_patcher", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load upstream Kaorios patcher: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("patcher", type=Path)
    parser.add_argument("smali", type=Path)
    args = parser.parse_args()

    if not args.patcher.is_file() or not args.smali.is_file():
        raise SystemExit("patcher and smali must both be regular files")
    patcher = load_patcher(args.patcher)
    verify = getattr(patcher, "verify_target_content", None)
    if not callable(verify):
        raise SystemExit("upstream patcher does not expose verify_target_content")
    verify(args.smali.name, args.smali.read_bytes().decode("utf-8"))
    print(f"verified {args.smali}")


if __name__ == "__main__":
    main()
