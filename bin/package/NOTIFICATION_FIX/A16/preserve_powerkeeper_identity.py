#!/usr/bin/env python3
"""Retain Xiaomi certificate identity for the existing patched v1 verifier.

This does NOT create a valid Xiaomi signature. The pinned RYU reference
provides the original v1 metadata; only compiled DEX is taken from the rebuild.
The ROM must have the already audited v1/digest bypass enabled.
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
REFERENCE = '7783b8581deeaf2c39d4fdf04d68a724b9f9c2d0fdf2604b866b399efca27108'
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
    if sha(reference) != REFERENCE:
        raise ValueError('RYU reference SHA256 mismatch')
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
            raise ValueError('Xiaomi v1 metadata differs from pinned reference')
        # The signing-block footer sits immediately before the central directory.
        with apk.open('rb') as fh:
            fh.seek(max(0, z.start_dir - 16))
            if fh.read(16) == b'APK Sig Block 42':
                raise ValueError('Unexpected v2/v3 signing block in preserved-identity APK')
        if not any(DEX.fullmatch(n) for n in names):
            raise ValueError('APK contains no DEX')
    return {'mode': 'xiaomi-certificate-preserved-patched-v1',
            'certificate_sha256': XIAOMI, 'sha256': sha(apk),
            'cryptographic_signature_valid': False,
            'requires_rom_v1_digest_bypass': True, 'runtime_tested': False}


def verify_base(base, signer, java):
    # Refuse an already re-signed/testkey base. Do not disguise its provenance.
    check = subprocess.run([java, '-jar', str(signer), 'verify', '--verbose',
                            '--print-certs', '--min-sdk-version', '36', str(base)],
                           check=True, capture_output=True, text=True).stdout
    certs = re.findall(r'^Signer #\d+ certificate SHA-256 digest: (\S+)', check, re.M)
    if certs != [XIAOMI]:
        raise ValueError('Base APK must be verified Xiaomi stock, not an Android/testkey rebuild')


def rebuild(base, patched, reference, output, signer, java):
    verify_base(base, signer, java)
    meta = metadata(reference)
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=output.parent, prefix='powerkeeper-identity-') as folder:
        candidate = Path(folder) / 'PowerKeeper.apk'
        with zipfile.ZipFile(base) as original, zipfile.ZipFile(patched) as rebuilt:
            for z in [original, rebuilt]:
                if len(z.namelist()) != len(set(z.namelist())) or z.testzip():
                    raise ValueError('Duplicate or corrupted input ZIP')
            dex = {n for n in original.namelist() if DEX.fullmatch(n)}
            if not dex or dex != {n for n in rebuilt.namelist() if DEX.fullmatch(n)}:
                raise ValueError('Compiled DEX set differs from stock')
            with zipfile.ZipFile(candidate, 'w') as dest:
                dest.comment = original.comment
                for member in original.infolist():
                    if member.filename.upper().startswith('META-INF/'):
                        continue
                    raw = rebuilt.read(member.filename) if member.filename in dex else original.read(member)
                    # writestr updates header_offset and sizes on its ZipInfo.
                    # Keep the original entry intact for subsequent stock reads.
                    dest.writestr(copy.copy(member), raw)
                for name, raw in meta.items():
                    dest.writestr(name, raw, compress_type=zipfile.ZIP_DEFLATED)
            report = verify(candidate, reference)
            # Guard manifest/resources/assets/JNI: bytecode patching only.
            with zipfile.ZipFile(candidate) as final:
                for n in original.namelist():
                    if n not in dex and not n.upper().startswith('META-INF/'):
                        if final.read(n) != original.read(n):
                            raise ValueError('Non-DEX content changed: ' + n)
            report['base_sha256'] = sha(base)
            report['compiled_dex_sha256'] = {n: hashlib.sha256(rebuilt.read(n)).hexdigest() for n in sorted(dex)}
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
    a = p.parse_args()
    if a.check_base:
        if not a.apksigner:
            p.error('--check-base requires --apksigner')
        verify_base(a.apk, a.apksigner, a.java)
        metadata(a.reference)
        result = {'mode': 'verified-xiaomi-base', 'certificate_sha256': XIAOMI, 'sha256': sha(a.apk)}
    elif a.base:
        if not a.patched or not a.apksigner:
            p.error('--base requires --patched and --apksigner')
        result = rebuild(a.base, a.patched, a.reference, a.apk, a.apksigner, a.java)
    else:
        result = verify(a.apk, a.reference)
    if a.report:
        a.report.parent.mkdir(parents=True, exist_ok=True)
        a.report.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
