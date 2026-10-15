#!/usr/bin/env python3
"""Extract ROM evidence on a disposable runner; never execute donor init/helpers."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import zipfile

PARTS = ('system', 'system_ext', 'vendor', 'product', 'odm')
REPO = Path(__file__).resolve().parents[3]
TOOLS = REPO / 'bin/Linux/x86_64'


def run(*args, **kwargs):
    print('+', ' '.join(map(str, args)), flush=True)
    return subprocess.run(list(map(str, args)), check=True, **kwargs)


def member(archive, name, target):
    # Write only to a caller-selected path, never an archive-provided path.
    with archive.open(name) as source, target.open('wb') as output:
        shutil.copyfileobj(source, output)


def unpack(archive_path, scratch, evidence):
    images = scratch / 'partitions'
    images.mkdir()
    with zipfile.ZipFile(archive_path) as archive:
        names = archive.namelist()
        (evidence / 'zip-members.json').write_text(json.dumps(names, indent=2))
        payload = [n for n in names if Path(n).name == 'payload.bin']
        supers = sorted(n for n in names if Path(n).name == 'super.img'
                        or Path(n).name.startswith('super.img.'))
        if len(payload) == 1:
            target = scratch / 'payload.bin'
            member(archive, payload[0], target)
            mode = 'payload'
        elif supers:
            chunks = []
            for index, name in enumerate(supers):
                target = scratch / ('super-chunk-' + str(index))
                member(archive, name, target)
                chunks.append(target)
            mode = 'super'
        else:
            raise ValueError('Unsupported ROM layout; inspect zip-members.json before adapting')
    archive_path.unlink()
    if mode == 'payload':
        run(TOOLS / 'payload-extract', 'extract', '-o', images, target)
        target.unlink()
    else:
        super_image = scratch / 'super.img'
        with chunks[0].open('rb') as source:
            sparse = source.read(4) == b'\x3a\xff\x26\xed'
        if sparse:
            run('simg2img', *chunks, super_image)
            for chunk in chunks:
                chunk.unlink()
        elif len(chunks) == 1:
            chunks[0].rename(super_image)
        else:
            raise ValueError('Multiple non-sparse super chunks; refusing to guess merge format')
        selected = ','.join(p + suffix for p in PARTS for suffix in ('', '_a'))
        run(sys.executable, REPO / 'bin/lpunpack.py', '-p', selected, super_image, images)
        super_image.unlink()
    extracted = scratch / 'extracted'
    extracted.mkdir()
    for part in PARTS:
        image = images / (part + '.img')
        slotted = images / (part + '_a.img')
        if not image.exists() and slotted.exists():
            slotted.rename(image)
        if not image.exists():
            if part in ('system', 'system_ext', 'vendor'):
                raise ValueError('Required partition missing: ' + part)
            continue
        kind = subprocess.check_output([str(TOOLS / 'gettype'), '-i', str(image)], text=True).strip()
        if kind == 'erofs':
            run(TOOLS / 'extract.erofs', '-x', '-i', image, '-o', extracted)
        elif kind == 'ext':
            run(sys.executable, REPO / 'bin/imgextractor/imgextractor.py', image, extracted)
        else:
            raise ValueError(f'Unsupported {part} filesystem: {kind}')
        image.unlink()
    return extracted


def collect(root, evidence):
    records = []
    for path in sorted(root.rglob('*')):
        rel = path.relative_to(root)
        if path.is_symlink():
            records.append({'path': str(rel), 'symlink': os.readlink(path)})
            continue
        if not path.is_file():
            continue
        name = path.name
        if not (path.suffix in ('.rc', '.cil') or 'contexts' in name
                or name.endswith('_fs_config') or name in ('plat_sepolicy_vers.txt',
                'ryu_helper', 'hypermos-resetprop', 'passwd', 'linker.config.json')):
            continue
        destination = evidence / 'files' / rel
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, destination)
        data = path.read_bytes()
        record = {'path': str(rel), 'mode': oct(path.stat().st_mode & 0o7777),
                  'size': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
        if name in ('ryu_helper', 'hypermos-resetprop'):
            with (destination.parent / (name + '.readelf.txt')).open('w') as output:
                run('readelf', '-h', '-l', '-d', path, stdout=output)
            bundled = REPO / 'bin/package/LOCK/system_ext/xbin/ryu_helper'
            record['matches_bundled_ryu_helper'] = data == bundled.read_bytes()
        records.append(record)
    (evidence / 'files.json').write_text(json.dumps(records, indent=2) + '\n')


def verify_policy(root, evidence):
    platform = root / 'system/system/etc/selinux'
    if not platform.is_dir():
        platform = root / 'system/etc/selinux'
    vendor = root / 'vendor/etc/selinux'
    version = (vendor / 'plat_sepolicy_vers.txt').read_text().strip()
    if not version.replace('.', '').isdigit():
        raise ValueError('Invalid SELinux mapping version')
    inputs = [platform / 'plat_sepolicy.cil', platform / 'mapping' / (version + '.cil')]
    optional = [platform / 'mapping' / (version + '.compat.cil')]
    for part in ('system_ext', 'product'):
        folder = root / part / 'etc/selinux'
        optional += [folder / (part + '_sepolicy.cil'),
                     folder / 'mapping' / (version + '.cil'),
                     folder / 'mapping' / (version + '.compat.cil')]
    inputs += [p for p in optional if p.is_file()]
    inputs += [vendor / 'plat_pub_versioned.cil', vendor / 'vendor_sepolicy.cil']
    odm = root / 'odm/etc/selinux/odm_sepolicy.cil'
    if odm.is_file():
        inputs.append(odm)
    with tempfile.TemporaryDirectory(prefix='lock-secilc-') as tmp:
        with (evidence / 'secilc.log').open('w') as output:
            result = subprocess.run(['secilc', '-m', '-M', 'true', '-G', '-N', '-c', '30',
                                     *map(str, inputs), '-o', tmp + '/policy',
                                     '-f', tmp + '/contexts'], stdout=output, stderr=subprocess.STDOUT)
    return {'mapping_version': version, 'returncode': result.returncode,
            'neverallow_checked': False, 'device_tested': False}


def verify_init(root, evidence):
    verifier = shutil.which('host_init_verifier')
    if not verifier:
        return {'status': 'unavailable', 'device_tested': False}
    command = [verifier]
    for part in PARTS:
        folder = root / part
        if part == 'system' and (folder / 'system').is_dir():
            folder /= 'system'
        if not folder.is_dir():
            continue
        command.append(f'--out_{part}={folder}')
        passwd = folder / 'etc/passwd'
        if passwd.is_file():
            command += ['-p', str(passwd)]
        for contexts in sorted((folder / 'etc/selinux').glob('*property_contexts')):
            command.append('--property_contexts=' + str(contexts))
    with (evidence / 'host_init_verifier.log').open('w') as output:
        result = subprocess.run(command, stdout=output, stderr=subprocess.STDOUT)
    return {'status': 'passed' if result.returncode == 0 else 'failed',
            'returncode': result.returncode, 'device_tested': False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', required=True)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    summary = {'url': args.url, 'extracted': False, 'helper_executed': False}
    try:
        with tempfile.TemporaryDirectory(prefix='lock-rom-') as tmp:
            scratch = Path(tmp)
            archive = scratch / 'rom.zip'
            run('curl', '--fail', '--location', '--retry', '3', '--connect-timeout', '30',
                '--max-time', '3600', '--output', archive, args.url)
            digest = hashlib.sha256()
            with archive.open('rb') as stream:
                for block in iter(lambda: stream.read(8 * 1024 * 1024), b''):
                    digest.update(block)
            summary['rom_sha256'] = digest.hexdigest()
            root = unpack(archive, scratch, args.output)
            collect(root, args.output)
            summary['extracted'] = True
            summary['selinux'] = verify_policy(root, args.output)
            summary['init'] = verify_init(root, args.output)
            if summary['selinux']['returncode']:
                raise ValueError('Split policy compilation failed; inspect secilc.log')
            if summary['init']['status'] == 'failed':
                raise ValueError('Native init verification failed; inspect host_init_verifier.log')
    finally:
        (args.output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')


if __name__ == '__main__':
    main()
