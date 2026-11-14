"""Replace JAR DEX entries and align their stored payloads for ART."""

import copy
from pathlib import Path
import re
import struct
import sys
import zipfile


def repack(original, decoded, output):
    with zipfile.ZipFile(original) as source, zipfile.ZipFile(output, "w") as target:
        target.comment = source.comment
        for entry in source.infolist():
            metadata = copy.copy(entry)
            data = source.read(entry)
            if re.fullmatch(r"classes(?:[2-9]|[1-9][0-9]+)?\.dex", entry.filename):
                data = (decoded / entry.filename).read_bytes()
                metadata.compress_type = zipfile.ZIP_STORED
                # The local extra field sits immediately before the DEX payload.
                offset = target.fp.tell() + 30 + len(entry.filename) + len(metadata.extra)
                padding = -offset % 4
                if padding:
                    metadata.extra += struct.pack("<HH", 0xD935, padding) + bytes(padding)
            target.writestr(metadata, data)


if __name__ == "__main__":
    repack(*map(Path, sys.argv[1:]))
