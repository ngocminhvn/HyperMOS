#!/usr/bin/env python3
"""Gate SukiSU's Android-only feature module out of its host boot patcher."""
from __future__ import annotations

import argparse
from pathlib import Path


PLAIN = "mod feature;"
GUARDED = '#[cfg(target_os = "android")]\nmod feature;'


def transform(source: str) -> tuple[str, bool]:
    if GUARDED in source:
        return source, False
    if source.count(PLAIN) != 1:
        raise ValueError("feature module declaration missing or ambiguous")
    return source.replace(PLAIN, GUARDED), True


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        patched, changed = transform("mod defs;\nmod feature;\nmod feature_id;\n")
        assert changed and GUARDED in patched
        assert transform(patched) == (patched, False)
        try:
            transform("mod defs;\n")
        except ValueError:
            pass
        else:
            raise AssertionError("missing declaration must fail closed")
        print("[ROOT] SukiSU host source patch self-test PASS")
        return 0
    if args.source is None:
        parser.error("--source is required outside --self-test")
    source = args.source.read_text(encoding="utf-8")
    updated, changed = transform(source)
    if changed:
        args.source.write_text(updated, encoding="utf-8")
        print("[ROOT] Gated Android-only SukiSU feature module from host build")
    else:
        print("[ROOT] SukiSU feature module already gated for host build")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
