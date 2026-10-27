#!/usr/bin/env python3
"""Validate compact Kaorios config.json and emit derived build switches."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys


ROOT_KEY = "KaoriosToolbox"
FEATURES = (
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
    missing = sorted(set(FEATURES) - set(config))
    unknown = sorted(set(config) - set(FEATURES))
    if missing or unknown:
        raise ValueError(f"feature keys mismatch; missing={missing}, unknown={unknown}")
    invalid = sorted(key for key, item in config.items() if type(item) is not bool)
    if invalid:
        raise ValueError(f"feature values must be JSON booleans: {invalid}")
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
        "KAORIOS_INSTALL_TOOLBOX": config["enabled"],
        "KAORIOS_VALIDATE_KEYBOX": config["keybox"],
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


if __name__ == "__main__":
    raise SystemExit(main())
