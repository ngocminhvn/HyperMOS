#!/usr/bin/env python3
"""Retain Xiaomi certificate identity and v1 metadata for patched PowerKeeper.apk.

This does NOT create a valid cryptographic signature for the changed DEX bytecode.
Instead, it preserves Xiaomi's exact official v1 metadata (CERT.RSA, CERT.SF, MANIFEST.MF)
and unchanged stock non-DEX assets while transplanting only the patched classes.dex.
This allows the APK to run with its original Xiaomi certificate identity under the ROM's
CorePatch signature bypass without testkey re-signing.
"""
import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import tempfile
import zipfile
from pathlib import Path

XIAOMI = 'c9009d01ebf9f5d0302bc71b2fe9aa9a47a432bba17308a3111b75d7b2149025'
DEX = re.compile(r'classes(?:[2-9]|[1-9]\d+)?\.dex\Z')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def cert_present(blob):
    """Find the exact pinned DER certificate in PKCS#7 constructed objects."""
    pos = 0
    while pos < len(blob):
        start = pos
        tag = blob[pos]
        pos += 1
        if pos >= len(blob):
            raise ValueError('Truncated DER')
        size = blob[pos]
        pos += 1
        if size & 128:
            count = size & 127
            if not count or count > 4 or pos + count > len(blob):
                raise ValueError('Invalid DER length')
            size = int.from_bytes(blob[pos:pos + count], 'big')
            pos += count
        end = pos + size
        if end > len(blob):
            raise ValueError('Truncated DER object')
        if tag == 0x30 and hashlib.sha256(blob[start:end]).hexdigest() == XIAOMI:
            return True
        if tag & 32 and cert_present(blob[pos:end]):
            return True
        pos = end
    return False


def metadata(reference):
    with zipfile.ZipFile(reference) as z:
        names = [n for n in z.namelist() if n.upper().startswith('META-INF/') and not n.endswith('/')]
        if len(names) != len(set(names)):
            raise ValueError('Duplicate reference metadata')
        result = {n: z.read(n) for n in names}
    if not {'META-INF/CERT.RSA', 'META-INF/CERT.SF', 'META-INF/MANIFEST.MF'} <= result.keys():
        raise ValueError('Reference v1 metadata missing')
    if not cert_present(result['META-INF/CERT.RSA']):
        raise ValueError('Reference does not contain the expected Xiaomi certificate')
    return result


def verify(apk, reference):
    expected = metadata(reference)
    with zipfile.ZipFile(apk) as z:
        names = z.namelist()
        if len(names) != len(set(names)) or z.testzip():
            raise ValueError('Duplicate or damaged APK entries')
        actual = {n: z.read(n) for n in names if n.upper().startswith('META-INF/') and not n.endswith('/')}
        if actual != expected:
            raise ValueError('Xiaomi v1 metadata differs from verified stock')
        # Ensure no v2/v3 signing block in preserved-identity APK so system relies on v1
        with apk.open('rb') as fh:
            fh.seek(max(0, z.start_dir - 16))
            if fh.read(16) == b'APK Sig Block 42':
                raise ValueError('Unexpected v2/v3 signing block in preserved-identity APK')
        if not any(DEX.fullmatch(n) for n in names):
            raise ValueError('APK contains no DEX')
    return {
        'mode': 'xiaomi-certificate-preserved-patched-v1',
        'certificate_sha256': XIAOMI,
        'sha256': sha(apk),
        'metadata_sha256': {n: hashlib.sha256(data).hexdigest() for n, data in actual.items()},
        'cryptographic_signature_valid': False,
        'requires_rom_v1_digest_bypass': True,
        'runtime_tested': False,
    }


def verify_base(base, signer, java, allow_stripped=False):
    command = [java, '-jar', str(signer), 'verify', '--verbose',
               '--print-certs', str(base)]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode:
        combined = result.stdout + result.stderr
        stripped = ('no such signature was found' in combined and
                    'Signature stripped?' in combined)
        if not stripped or not allow_stripped:
            raise subprocess.CalledProcessError(
                result.returncode, command, result.stdout, result.stderr)
        # Xiaomi's ROM build pipeline may strip the v2/v3 signing block from
        # a trusted system APK while leaving pinned v1 certificate metadata.
        # Accept only that narrow stock-ROM case; metadata() still requires
        # the exact Xiaomi certificate hash below.
        metadata(base)
        return 'pinned-xiaomi-v1-metadata-stripped-v2-v3'
    check = result.stdout
    certs = re.findall(r'^Signer #\d+ certificate SHA-256 digest: (\S+)', check, re.M)
    if certs != [XIAOMI]:
        raise ValueError('Base APK must be verified Xiaomi stock, not an Android/testkey rebuild')
    return 'apksigner-verified'


def rebuild(base, patched, reference, output, signer, java, allow_stripped=False):
    base_verification = verify_base(base, signer, java, allow_stripped)
    meta = metadata(reference)
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=output.parent, prefix='powerkeeper-identity-') as folder:
        candidate = Path(folder) / 'PowerKeeper.apk'
        with zipfile.ZipFile(base) as original:
            if len(original.namelist()) != len(set(original.namelist())) or original.testzip():
                raise ValueError('Duplicate or corrupted base ZIP')
            dex = {n for n in original.namelist() if DEX.fullmatch(n)}

            if patched.is_file() and patched.suffix == '.dex':
                dex_bytes = patched.read_bytes()
                if len(dex_bytes) < 112 or not dex_bytes.startswith(b"dex\n"):
                    raise ValueError('Invalid patched DEX file')
                rebuilt_dex = {'classes.dex'}
                with zipfile.ZipFile(candidate, 'w') as dest:
                    dest.comment = original.comment
                    for member in original.infolist():
                        if member.filename.upper().startswith('META-INF/'):
                            continue
                        raw = dex_bytes if member.filename == 'classes.dex' else original.read(member)
                        dest.writestr(copy.copy(member), raw)
                    for name, raw in meta.items():
                        dest.writestr(name, raw, compress_type=zipfile.ZIP_DEFLATED)
                compiled_hashes = {'classes.dex': hashlib.sha256(dex_bytes).hexdigest()}
            else:
                with zipfile.ZipFile(patched) as rebuilt:
                    if len(rebuilt.namelist()) != len(set(rebuilt.namelist())) or rebuilt.testzip():
                        raise ValueError('Duplicate or corrupted rebuilt ZIP')
                    rebuilt_dex = {n for n in rebuilt.namelist() if DEX.fullmatch(n)}
                    if not dex or not dex.issubset(rebuilt_dex):
                        raise ValueError('Compiled DEX set differs from stock')
                    with zipfile.ZipFile(candidate, 'w') as dest:
                        dest.comment = original.comment
                        for member in original.infolist():
                            if member.filename.upper().startswith('META-INF/'):
                                continue
                            raw = rebuilt.read(member.filename) if member.filename in rebuilt_dex else original.read(member)
                            dest.writestr(copy.copy(member), raw)
                        for name, raw in meta.items():
                            dest.writestr(name, raw, compress_type=zipfile.ZIP_DEFLATED)
                    compiled_hashes = {n: hashlib.sha256(rebuilt.read(n)).hexdigest() for n in sorted(rebuilt_dex)}

            report = verify(candidate, reference)
            with zipfile.ZipFile(candidate) as final:
                for n in original.namelist():
                    if n not in rebuilt_dex and not n.upper().startswith('META-INF/'):
                        if final.read(n) != original.read(n):
                            raise ValueError('Non-DEX content changed: ' + n)
            report['base_sha256'] = sha(base)
            report['base_verification'] = base_verification
            report['compiled_dex_sha256'] = compiled_hashes
        os.replace(candidate, output)
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--reference', type=Path, required=True)
    p.add_argument('--apk', type=Path, required=True)
    p.add_argument('--base', type=Path)
    p.add_argument('--patched', type=Path)
    p.add_argument('--apksigner', type=Path)
    p.add_argument('--java', default='java')
    p.add_argument('--report', type=Path)
    p.add_argument('--check-base', action='store_true')
    p.add_argument('--allow-stripped-base', action='store_true')
    a = p.parse_args()
    if a.check_base:
        if not a.apksigner:
            p.error('--check-base requires --apksigner')
        base_verification = verify_base(
            a.apk, a.apksigner, a.java, a.allow_stripped_base)
        metadata(a.apk)
        result = {'mode': 'verified-xiaomi-base',
                  'base_verification': base_verification,
                  'certificate_sha256': XIAOMI, 'sha256': sha(a.apk)}
    elif a.base:
        if not a.patched or not a.apksigner:
            p.error('--base requires --patched and --apksigner')
        result = rebuild(a.base, a.patched, a.reference, a.apk, a.apksigner,
                         a.java, a.allow_stripped_base)
    else:
        result = verify(a.apk, a.reference)
    if a.report:
        a.report.parent.mkdir(parents=True, exist_ok=True)
        a.report.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
