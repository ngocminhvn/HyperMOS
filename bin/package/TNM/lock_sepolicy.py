"""Native policy and init validation used by TNM post-fs integration."""
import shutil
import subprocess
import tempfile
from pathlib import Path

PARTS = ('system', 'system_ext', 'vendor', 'product', 'odm')


def verify_policy(root, evidence, system_ext_policy=None):
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
        selected = system_ext_policy if part == 'system_ext' and system_ext_policy else folder / (part + '_sepolicy.cil')
        optional += [selected,
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

