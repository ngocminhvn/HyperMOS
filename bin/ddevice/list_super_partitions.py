#!/usr/bin/env python3
"""Read Android raw-super liblp partition names without --info's fragile JSON."""
from __future__ import annotations
import contextlib
import importlib.util
import io
import sys
from pathlib import Path

def main() -> int:
    if len(sys.argv) != 3:
        raise ValueError("Usage: list_super_partitions.py <lpunpack.py> <raw-super.img>")
    module_path = Path(sys.argv[1]).resolve()
    image_path = Path(sys.argv[2]).resolve()
    spec = importlib.util.spec_from_file_location("hypermos_liblp_reader", module_path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load liblp parser: {module_path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    reader = module.LpUnpack(SUPER_IMAGE=str(image_path))
    try:
        with contextlib.redirect_stdout(io.StringIO()):
            metadata = reader._read_metadata()
        names = [part.name for part in metadata.partitions]
    finally:
        reader._fd.close()
    if not names or any(not name for name in names) or len(set(names)) != len(names):
        raise ValueError("Empty or inconsistent logical partition metadata")
    for name in names:
        if not name.replace("_", "").isalnum():
            raise ValueError(f"Unexpected logical partition name: {name!r}")
        print(name)
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError) as ex:
        print(f"[EU SUPER] {ex}", file=sys.stderr)
        sys.exit(1)
