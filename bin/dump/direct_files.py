#!/usr/bin/env python3
"""Extract only requested files from a ROM ZIP containing a direct partition tree.

Never extract arbitrary ZIP contents. Keep the partition structure expected by collect.py.
"""
import argparse
import shutil
import zipfile
from pathlib import Path, PurePosixPath

PARTS = {
    'system', 'system_ext', 'product', 'vendor', 'odm', 'mi_ext',
    'mi_product', 'system_dlkm', 'vendor_dlkm', 'odm_dlkm', 'product_dlkm',
}
BASE = {'framework.jar', 'miui-framework.jar', 'miui-services.jar', 'powerkeeper.apk', 'services.jar'}


def collect_archive(zip_path: Path, output: Path, mode: str, targets: Path) -> int:
    allowed = set()
    if mode == 'full':
        for line in targets.read_text(encoding='utf-8').splitlines():
            if not line.strip() or line.startswith('#'):
                continue
            bits = PurePosixPath(line.strip()).parts
            if len(bits) >= 3 and bits[1] in PARTS:
                allowed.add((bits[1], '/'.join(bits[2:]).casefold()))
    output = output.resolve()
    count = 0
    with zipfile.ZipFile(zip_path, 'r') as z:
        for info in z.infolist():
            if info.is_dir():
                continue
            parts = PurePosixPath(info.filename).parts
            if any(part == '..' for part in parts) or info.filename.startswith('/') or '\\' in info.filename:
                raise SystemExit('Unsafe ZIP member: ' + info.filename)
            chosen = None
            for i, part in enumerate(parts[:-1]):
                if part not in PARTS:
                    continue
                rest = parts[i+1:]
                if mode == 'base':
                    matching = rest[-1].casefold() in BASE
                else:
                    matching = (part, '/'.join(rest).casefold()) in allowed
                if matching:
                    chosen = (part, rest)
                    break
            if chosen is None:
                continue
            part, rest = chosen
            dest = (output / part / Path(*rest)).resolve()
            if not dest.is_relative_to(output):
                raise SystemExit('Unsafe path: ' + info.filename)
            dest.parent.mkdir(parents=True, exist_ok=True)
            if dest.exists():
                print('[WARN] Duplicate direct file entry:', info.filename)
                continue
            with z.open(info) as src, dest.open('wb') as target:
                shutil.copyfileobj(src, target, 1024 * 1024)
            print('[DUMP] Direct file:', info.filename)
            count += 1
    print(f'[DUMP] Direct-file mode: {count} requested files extracted')
    return count


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--zip', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--mode', choices=('base', 'full'), required=True)
    p.add_argument('--targets', type=Path, required=True)
    a = p.parse_args()
    if collect_archive(a.zip, a.output, a.mode, a.targets) == 0:
        raise SystemExit('[ERROR] No matching direct files; consult entries.txt artifact')


if __name__ == '__main__':
    main()
