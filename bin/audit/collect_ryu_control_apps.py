#!/usr/bin/env python3
"""Read-only collection of RYU apps and framework jars for offline REA analysis."""
import argparse
import hashlib
import json
import shutil
import zipfile
from pathlib import Path

TARGET_EXACT = {
    'powerkeeper.apk', 'securitycenter.apk', 'settings.apk',
    'systemui.apk', 'miuisystemui.apk', 'miuihome.apk',
    'systemuiplugin.apk', 'joyose.apk', 'gamebooster.apk',
    'batteryandperformance.apk', 'framework-res.apk', 'gamecenter.apk',
}
TARGET_WORDS = (
    'projectryu', 'ryuos', 'ryu', 'performance', 'perfhook',
    'thermal', 'gamebooster', 'gameturbo', 'modcenter', 'powerkeeper',
    'securitycenter', 'batterymanager', 'powercontrol', 'perfcontrol',
)
JARS = {'framework.jar', 'services.jar', 'miui-services.jar', 'miui-framework.jar'}
MAX_FILE = 300 * 1024 * 1024
MAX_TOTAL = 1200 * 1024 * 1024
MAX_COUNT = 60


def sha256_file(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for buf in iter(lambda: f.read(8 * 1024 * 1024), b''):
            h.update(buf)
    return h.hexdigest()


def analyze(root, output, partition):
    root = root.resolve(strict=True)
    if not root.is_dir():
        raise ValueError('Extracted partition root is not a directory')
    output.mkdir(parents=True, exist_ok=True)
    manifest_path = output / 'manifest.json'
    if manifest_path.is_file():
        result = json.loads(manifest_path.read_text(encoding='utf-8'))
    else:
        result = {'source': 'RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip',
                  'mode': 'read-only original APK/JAR collector',
                  'files': [], 'inventory': [], 'warnings': []}
    copied = sum(x['size_bytes'] for x in result['files'])
    count = len(result['files'])
    found = 0
    for src in sorted(root.rglob('*')):
        if not src.is_file() or src.is_symlink():
            continue
        suffix = src.suffix.lower()
        if suffix not in ('.apk', '.jar'):
            continue
        rel = src.relative_to(root)
        filename = src.name.lower()
        size = src.stat().st_size
        is_apk = suffix == '.apk'
        matching = (filename in TARGET_EXACT or any(k in filename for k in TARGET_WORDS)) if is_apk else filename in JARS
        reason = 'selected' if matching else 'inventory_only'
        if matching and (size > MAX_FILE or copied + size > MAX_TOTAL or count >= MAX_COUNT):
            reason = 'skipped_safety_limit'
        if matching and is_apk and reason == 'selected' and not zipfile.is_zipfile(src):
            reason = 'skipped_invalid_apk'
        entry = {'partition': partition, 'path': str(rel), 'type': suffix.lstrip('.'),
                 'size_bytes': size, 'status': reason}
        result['inventory'].append(entry)
        if reason == 'skipped_safety_limit':
            result['warnings'].append('Collection limit: ' + partition + '/' + str(rel))
        if reason != 'selected':
            continue
        destination = output / 'files' / partition / rel
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, destination)
        if destination.stat().st_size != size:
            raise IOError('Truncated copy: ' + str(destination))
        entry['sha256'] = sha256_file(destination)
        entry['artifact_path'] = str(destination.relative_to(output))
        result['files'].append(dict(entry))
        copied += size
        count += 1
        found += 1
    manifest_path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'[RYU APPS] {partition}: added {found} files, {count} total; {len(result["inventory"])} inventory rows', flush=True)


def finalize(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    items = manifest['files']
    if not any(Path(e['path']).name.lower() == 'powerkeeper.apk' for e in items):
        raise RuntimeError('PowerKeeper APK not found; ROM or extraction layout is wrong')
    if not any(Path(e['path']).name.lower() == 'miui-services.jar' for e in items):
        raise RuntimeError('miui-services.jar not found; expected framework partition not scanned')
    lines = []
    for e in items:
        path = output / e['artifact_path']
        if not path.is_file() or sha256_file(path) != e['sha256']:
            raise RuntimeError('SHA256 mismatch: ' + str(path))
        lines.append(f'{e["sha256"]}  {e["artifact_path"]}')
    (output / 'SHA256SUMS.txt').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    inv = ['partition\tpath\ttype\tsize_bytes\tstatus']
    inv.extend('\t'.join(str(e[k]) for k in ('partition', 'path', 'type', 'size_bytes', 'status'))
               for e in manifest['inventory'])
    (output / 'app-inventory.tsv').write_text('\n'.join(inv) + '\n', encoding='utf-8')
    guide = """# RYUOS HAOTIAN original applications and frameworks

Source: RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip
SHA-256 verified on original ROM before extraction. APK/JAR bytes are copied unchanged.

Key targets: PowerKeeper.apk -> com.projectryu.perf.PerfHook,
SecurityCenter.apk, Settings.apk, SystemUI.apk and miui-services.jar.
Not every UI controller is in an APK: inspect framework.jar, services.jar,
miui-services.jar for framework/service call sites, and the inventory for
other potential app names. JARs contain DEX and may be read with JADX/REA.

Files: files/, manifest.json, app-inventory.tsv, SHA256SUMS.txt.
This workflow does NOT install or run REA, patch ROM, flash any image,
or change CPU/GPU, SELinux or system settings.
"""
    (output / 'README.md').write_text(guide, encoding='utf-8')
    print(f'[RYU APPS] READY: {len(items)} original APK/JAR files, {len(manifest["inventory"])} inventoried, {len(manifest["warnings"])} warnings')
    print('\n'.join(f' - {e["partition"]}/{e["path"]} ({e["size_bytes"]} bytes)' for e in items))


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--root', type=Path)
    p.add_argument('--partition', choices=['system', 'system_ext', 'product', 'mi_ext', 'vendor', 'odm'])
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--finalize', action='store_true')
    a = p.parse_args()
    if a.finalize:
        finalize(a.output)
    else:
        if not a.root or not a.partition:
            p.error('--root and --partition are required unless --finalize is set')
        analyze(a.root, a.output, a.partition)


if __name__ == '__main__':
    main()
