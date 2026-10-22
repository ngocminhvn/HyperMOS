#!/usr/bin/env python3
"""Stage the TNM post-fs property action in an extracted image, never run it here."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import stat
import subprocess
import tempfile

from lock_sepolicy import verify_init, verify_policy

HASH = '6d82fc8e92089ce24226636ec4d24deb15655d7a7473d37d24fa4ae53588c1df'
RUNTIME = '/system_ext/xbin/tnm_helper'
CONTEXT = 'u:object_r:tnm_helper_exec:s0'
PROPERTIES = (
    ('ro.bootloader', 'locked'), ('ro.boot.vbmeta.device_state', 'locked'),
    ('ro.boot.flash.locked', '1'), ('ro.boot.veritymode', 'enforcing'),
    ('ro.boot.warranty_bit', '0'), ('ro.boot.verifiedbootstate', 'green'),
    ('ro.secureboot.devicelock', '1'), ('ro.secureboot.lockstate', 'locked'),
    ('sys.oem_unlock_allowed', '0'),
)
INIT_BLOCK = ('# BEGIN HyperMOS LOCK (managed)\non post-fs\n' + ''.join(
    f'    exec u:r:init:s0 root root -- {RUNTIME} -n {name} {value}\n'
    for name, value in PROPERTIES) + '# END HyperMOS LOCK (managed)\n').encode()
POLICY_BLOCK = b'''; BEGIN HyperMOS LOCK (managed)
(type tnm_helper_exec)
(roletype object_r tnm_helper_exec)
(typeattributeset file_type (tnm_helper_exec))
(typeattributeset exec_type (tnm_helper_exec))
(typeattributeset system_file_type (tnm_helper_exec))
(allow init tnm_helper_exec (file (read getattr map execute open execute_no_trans)))
; END HyperMOS LOCK (managed)
'''
TOKENS = (b'tnm_helper', b'hypermos-resetprop', b'tnm_resetprop_exec', b'hypermos-lock.rc')


def managed(data, block):
    begin, end = block.splitlines()[0], block.splitlines()[-1]
    if begin not in data and end not in data:
        return data, False
    if data.count(begin) != 1 or data.count(end) != 1 or data.count(block) != 1:
        raise ValueError('Changed, partial or duplicate managed LOCK block; use a clean image')
    return data.replace(block, b'', 1), True


def append(data, block):
    return data + (b'' if data.endswith(b'\n') else b'\n') + b'\n' + block


def checked(root, relative, required=True):
    path = root / relative
    try:
        path.resolve(strict=required).relative_to(root.resolve())
    except ValueError:
        raise ValueError(f'Path outside image tree: {relative}') from None
    if path.is_symlink():
        raise ValueError(f'Refusing to replace linked audit/input file: {relative}')
    if required and (not path.is_file() or not path.stat().st_size):
        raise ValueError(f'Missing or empty image input: {relative}')
    return path


def row(data, key, expected):
    matches = [line for line in data.splitlines() if line.split() and line.split()[0] == key]
    if matches and (len(matches) != 1 or matches[0].split() != expected.split()):
        raise ValueError(f'Conflicting/duplicate metadata for {key.decode()}')
    return data if matches else data + (b'' if data.endswith(b'\n') else b'\n') + expected + b'\n'


def replace_file(path, data, mode):
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix='.hypermos-lock-', dir=path.parent)
    try:
        with os.fdopen(descriptor, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def validate_binary(binary):
    data = binary.read_bytes()
    if hashlib.sha256(data).hexdigest() != HASH:
        raise ValueError('TNM helper hash changed')
    output = subprocess.check_output(['readelf', '-h', '-l', '-d', str(binary)],
                                     text=True, env={**os.environ, 'LC_ALL': 'C'})
    needed = set(re.findall(r'Shared library: \[([^]]+)\]', output))
    if ('AArch64' not in output or 'ELF64' not in output or
            'DYN (Position-Independent Executable file)' not in output or
            '[Requesting program interpreter: /system/bin/linker64]' not in output or
            needed != {'libdl.so', 'libc.so'}):
        raise ValueError('Unexpected helper ELF architecture/interpreter/dependencies')
    return data


def integrate(images, binary, report, check=False):
    images = images.absolute()
    payload = validate_binary(binary)
    init = checked(images, 'system/system/etc/init/hw/init.rc')
    policy = checked(images, 'system_ext/etc/selinux/system_ext_sepolicy.cil')
    contexts = [checked(images, name) for name in (
        'system_ext/etc/selinux/system_ext_file_contexts', 'config/system_ext_file_contexts')]
    dac = checked(images, 'config/system_ext_fs_config')
    helper = checked(images, 'system_ext/xbin/tnm_helper', required=False)
    # Resolve the declared Bionic paths without dereferencing Android absolute
    # APEX links into the build host. Runtime namespace resolution needs boot testing.
    for relative, target in (
        ('bin/linker64', '/apex/com.android.runtime/bin/linker64'),
        ('lib64/libc.so', '/apex/com.android.runtime/lib64/bionic/libc.so'),
        ('lib64/libdl.so', '/apex/com.android.runtime/lib64/bionic/libdl.so'),
    ):
        path = images / 'system/system' / relative
        if path.is_symlink():
            if os.readlink(path) != target:
                raise ValueError(f'Unexpected Android runtime link: {relative}')
        elif not path.is_file() or path.read_bytes()[:5] != b'\x7fELF\x02':
            raise ValueError(f'Missing ARM64 runtime dependency path: {relative}')
    original_init, installed_init = managed(init.read_bytes(), INIT_BLOCK)
    original_policy, installed_policy = managed(policy.read_bytes(), POLICY_BLOCK)
    if installed_init != installed_policy:
        raise ValueError('Partial LOCK installation; rebuild a clean image')
    if not installed_init and helper.exists():
        raise ValueError('Unmanaged helper already installed; rebuild a clean image')
    if helper.exists() and hashlib.sha256(helper.read_bytes()).hexdigest() != HASH:
        raise ValueError('Conflicting installed helper')
    expected_context = f'{RUNTIME} {CONTEXT}'.encode()
    expected_dac = b'system_ext/xbin/tnm_helper 0 2000 0755'
    allowed_rows = {**{p: expected_context for p in contexts}, dac: expected_dac}
    def walk_error(exc):
        raise exc
    for directory, dirs, files in os.walk(images, followlinks=False, onerror=walk_error):
        for name in dirs:
            path = Path(directory) / name
            if path.is_symlink() and name in {'init', 'selinux', 'config', 'system_ext'}:
                path.resolve(strict=True).relative_to(images.resolve())
        for name in files:
            path = Path(directory) / name
            if name.startswith('precompiled_sepolicy'):
                continue  # Native CIL is checked below, then these caches are invalidated.
            if path == helper:
                continue
            if (name in {'tnm_helper', 'hypermos-resetprop', 'hypermos-lock.rc'} or
                    (name.endswith('_helper') and path.is_file() and not path.is_symlink()
                     and path.stat().st_size == len(payload)
                     and hashlib.sha256(path.read_bytes()).hexdigest() == HASH)):
                raise ValueError(f'Legacy/duplicate LOCK payload: {path.relative_to(images)}')
            if not (name.endswith(('.rc', '.cil', '_fs_config')) or 'file_contexts' in name):
                continue
            path.resolve(strict=True).relative_to(images.resolve())
            data = path.read_bytes()
            if path == init:
                data = original_init
            elif path == policy:
                data = original_policy
            elif path in allowed_rows:
                # Only the precise dedicated row is allowed; no broad/context aliases.
                data = b'\n'.join(line for line in data.splitlines()
                                  if line.split() != allowed_rows[path].split())
            if any(token in data for token in TOKENS):
                raise ValueError(f'Unmanaged/duplicate LOCK reference: {path.relative_to(images)}')
    proposed = {
        init: init.read_bytes() if installed_init else append(original_init, INIT_BLOCK),
        policy: policy.read_bytes() if installed_policy else append(original_policy, POLICY_BLOCK),
        **{p: row(p.read_bytes(), RUNTIME.encode(), expected_context) for p in contexts},
        dac: row(dac.read_bytes(), b'system_ext/xbin/tnm_helper', expected_dac),
        helper: payload,
    }
    # Validate the complete action grammar we own, without executing the helper.
    commands = INIT_BLOCK.decode().splitlines()[2:-1]
    for line, (name, value) in zip(commands, PROPERTIES):
        if shlex.split(line) != ['exec', 'u:r:init:s0', 'root', 'root', '--', RUNTIME, '-n', name, value]:
            raise ValueError('Invalid managed Android init command')
    caches = [p for part in ('vendor', 'odm') for p in
              (images / part / 'etc/selinux').glob('precompiled_sepolicy*') if p.is_file()]
    for path in caches:
        checked(images, str(path.relative_to(images)))
    if check:
        if not installed_init or not helper.is_file() or caches or stat.S_IMODE(helper.stat().st_mode) != 0o755:
            raise ValueError('Incomplete LOCK staging or stale precompiled policy')
        if any(not p.exists() or p.read_bytes() != data for p, data in proposed.items()):
            raise ValueError('LOCK payload/metadata does not match managed configuration')
    # Compile candidate split CIL before changing any image file. No compile bypass.
    report.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='lock-candidate-') as tmp:
        candidate = Path(tmp) / 'system_ext_sepolicy.cil'
        candidate.write_bytes(proposed[policy])
        compilation = verify_policy(images, report, candidate)
    if compilation['returncode']:
        raise ValueError(f'Candidate split SELinux compilation failed: {report / "secilc.log"}')
    if not check:
        backup = {p: (p.read_bytes(), stat.S_IMODE(p.stat().st_mode)) if p.exists() else None
                  for p in [*proposed, *caches]}
        try:
            for path, data in proposed.items():
                mode = 0o755 if path == helper else backup[path][1]
                if backup[path] is None or backup[path] != (data, mode):
                    replace_file(path, data, mode)
            for path in caches:
                path.unlink()
            native_init = verify_init(images, report)
            if native_init['status'] == 'failed':
                raise ValueError(f'Native init verification failed: {report / "host_init_verifier.log"}')
        except Exception:
            for path, old in reversed(list(backup.items())):
                if old is None:
                    path.unlink(missing_ok=True)
                else:
                    replace_file(path, *old)
            raise
    else:
        native_init = verify_init(images, report)
    result = {'mode': 'check' if check else 'install', 'helper_sha256': HASH,
              'init_path': '/system/etc/init/hw/init.rc', 'trigger': 'post-fs',
              'helper_commands': len(PROPERTIES), 'blacklist_added': False,
              'split_policy': compilation, 'native_init': native_init,
              'runtime_tested': False, 'hardware_bootloader_or_tee_operations_added': False}
    (report / 'integration.json').write_text(json.dumps(result, indent=2) + '\n')
    if native_init['status'] == 'failed':
        raise ValueError(f'Native init verification failed: {report / "host_init_verifier.log"}')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--images', type=Path, required=True)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    print(json.dumps(integrate(args.images, args.binary, args.report, args.check), indent=2))


if __name__ == '__main__':
    main()
