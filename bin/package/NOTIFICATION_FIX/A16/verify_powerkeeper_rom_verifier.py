#!/usr/bin/env python3
"""Require the audited v1 fallback/digest patches in the final framework DEX."""
import argparse
import json
import re
import subprocess
import tempfile
import zipfile
from pathlib import Path
from verify_perfhook_apk import defined_classes

TARGETS = {'Landroid/util/apk/ApkSignatureVerifier;', 'Landroid/util/jar/StrictJarVerifier;'}


def instructions(body):
    return [s.strip() for s in body.splitlines()
            if s.strip() and not s.lstrip().startswith(('.', '#', ':'))]


def method(text, name):
    bodies = re.findall(r'(?ms)^\.method[^\n]*\b' + re.escape(name) + r'\([^\n]*\n(.*?)^\.end method', text)
    if len(bodies) != 1:
        raise ValueError('Expected exactly one ' + name)
    return instructions(bodies[0])


def constant_return(code, value):
    if len(code) != 2:
        return False
    c = re.fullmatch(r'const(?:/4|/16)? ([vp]\d+), (0x[0-9a-f]+|\d+)', code[0])
    return bool(c and int(c[2], 0) == value and code[1] == 'return ' + c[1])


def check(apk_verifier, jar_verifier):
    if not constant_return(method(apk_verifier, 'getMinimumSignatureSchemeVersionForTargetSdk'), 0):
        raise ValueError('Final framework does not lower signature scheme minimum to zero')
    if not constant_return(method(jar_verifier, 'verifyMessageDigest'), 1):
        raise ValueError('Final framework does not have the audited v1 digest bypass')
    code = method(apk_verifier, 'verifyV3AndBelowSignatures')
    calls = [i for i, s in enumerate(code) if '->verifyV1Signature(' in s and s.startswith('invoke-static')]
    if len(calls) != 1 or calls[0] == 0:
        raise ValueError('Unexpected v1 fallback call layout')
    if not re.fullmatch(r'const(?:/4|/16)? p3, (?:0x0|0)', code[calls[0] - 1]):
        raise ValueError('Final framework does not disable full verification at v1 fallback')


def verify(framework, baksmali, java='java'):
    texts = {}
    with tempfile.TemporaryDirectory(prefix='powerkeeper-verifier-') as folder:
        temp = Path(folder)
        with zipfile.ZipFile(framework) as archive:
            for name in archive.namelist():
                if not re.fullmatch(r'classes(?:[2-9]|[1-9]\d+)?\.dex', name):
                    continue
                raw = archive.read(name)
                selected = sorted(TARGETS & defined_classes(raw))
                if not selected:
                    continue
                dex = temp / name; dex.write_bytes(raw)
                out = temp / (name + '-smali')
                subprocess.run([java, '-jar', str(baksmali), 'd', '--api', '36',
                                '--classes', ','.join(selected), '-o', str(out), str(dex)], check=True)
                for cls in selected:
                    if cls in texts:
                        raise ValueError('Duplicate verifier class')
                    texts[cls] = (out / (cls[1:-1] + '.smali')).read_text()
        if set(texts) != TARGETS:
            raise ValueError('Final framework is missing signature verifier classes')
        check(texts['Landroid/util/apk/ApkSignatureVerifier;'], texts['Landroid/util/jar/StrictJarVerifier;'])
    return {'final_framework_v1_bypass_verified': True, 'runtime_tested': False}


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--framework', type=Path, required=True)
    p.add_argument('--baksmali', type=Path, required=True)
    p.add_argument('--java', default='java')
    a = p.parse_args()
    print(json.dumps(verify(a.framework, a.baksmali, a.java)))
