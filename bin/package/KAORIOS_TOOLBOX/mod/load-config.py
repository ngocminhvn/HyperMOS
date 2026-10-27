#!/usr/bin/env python3
"""Validate Kaorios config.json and emit fixed, shell-safe assignments."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys


SCHEMA = {
    "master": "KAORIOS_MASTER",
    "activity_thread": "KAORIOS_ENABLE_ACTIVITY_THREAD",
    "instrumentation": "KAORIOS_ENABLE_INSTRUMENTATION",
    "keybox": "KAORIOS_ENABLE_KEYBOX",
    "system_feature_spoof": "KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF",
    "system_server": "KAORIOS_ENABLE_SYSTEM_SERVER",
    "hidden_app": "KAORIOS_ENABLE_HIDDEN_APP",
    "installer_source": "KAORIOS_ENABLE_INSTALLER_SOURCE",
    "devstatus": "KAORIOS_ENABLE_DEVSTATUS",
    "build_spoof": "KAORIOS_ENABLE_BUILD_SPOOF",
    "secure_flag": "KAORIOS_ENABLE_SECURE_FLAG",
    "corepatch": "KAORIOS_ENABLE_COREPATCH",
    "install_toolbox": "KAORIOS_INSTALL_TOOLBOX",
    "validate_keybox": "KAORIOS_VALIDATE_KEYBOX",
    "verbose_log": "KAORIOS_VERBOSE_LOG",
}


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate key: {key}")
        result[key] = value
    return result


def load_config(path: Path) -> dict[str, bool]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
    except (OSError, UnicodeError, json.JSONDecodeError, ValueError) as error:
        raise ValueError(f"cannot read valid JSON from {path}: {error}") from error
    if not isinstance(value, dict):
        raise ValueError("top-level config must be a JSON object")
    missing = sorted(set(SCHEMA) - set(value))
    unknown = sorted(set(value) - set(SCHEMA))
    if missing or unknown:
        raise ValueError(f"config keys mismatch; missing={missing}, unknown={unknown}")
    invalid = sorted(key for key, item in value.items() if type(item) is not bool)
    if invalid:
        raise ValueError(f"config values must be JSON booleans: {invalid}")
    return value


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("config", type=Path)
    parser.add_argument("--get", choices=tuple(SCHEMA), help="print one JSON value only")
    args = parser.parse_args()
    try:
        config = load_config(args.config)
    except ValueError as error:
        print(f"KAORIOS: {error}", file=sys.stderr)
        return 1
    if args.get:
        print("true" if config[args.get] else "false")
    else:
        for key, variable in SCHEMA.items():
            print(f"{variable}={'true' if config[key] else 'false'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
