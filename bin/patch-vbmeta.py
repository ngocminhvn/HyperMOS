#!/usr/bin/env python3
"""Set AVB disable flags on a structurally valid, standalone vbmeta image."""
import pathlib
import struct
import sys

sys.dont_write_bytecode = True
from verify_boot_chain import inspect


def patch(path):
    metadata = inspect(path)
    if metadata['avb_footer'] or not path.read_bytes().startswith(b'AVB0'):
        raise ValueError('Expected standalone vbmeta image')
    with path.open('r+b') as f:
        f.seek(120)
        f.write(struct.pack('>I', metadata['avb']['flags'] | 3))
    inspect(path)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('Usage: patch-vbmeta.py <vbmeta-image>')
    try:
        patch(pathlib.Path(sys.argv[1]))
    except Exception as exc:
        sys.exit('VBMETA ERROR: ' + str(exc))
    print('Patched AVB disable flags (signature trust is not asserted).')
