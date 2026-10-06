#!/usr/bin/env python3
"""Replace only the managed FakeLock values; preserve unrelated stock properties."""
from pathlib import Path
import sys

LEGACY = set('ro.boot.verifiedbootstate vendor.boot.verifiedbootstate vendor.boot.vbmeta.device_state ro.boot.veritymode ro.boot.vbmeta.device_state ro.boot.flash.locked ro.boot.warranty_bit ro.warranty_bit ro.debuggable ro.secure ro.secureboot.devicelock ro.secureboot.lockstate ro.build.type ro.build.keys ro.build.tags ro.vendor.boot.warranty_bit ro.vendor.warranty_bit sys.oem_unlock_allowed ro.oem_unlock_supported init.svc.flash_recovery ro.boot.realmebootstate ro.boot.realme.lockstate ro.crypto.state init.svc.adbd ro.miui.has_gmscore ro.opa.eligible_device ro.miui.support_miui_ime_bottom'.split())
BEGIN = '# HyperMOS FakeLock BEGIN'
END = '# HyperMOS FakeLock END'

def update(target, payload):
    values = {}
    for line in payload.read_text().splitlines():
        if line.strip() and not line.lstrip().startswith('#'):
            k, v = line.split('=', 1)
            if k in values:
                raise ValueError('Duplicate payload key: ' + k)
            values[k] = v
    result = []
    legacy = managed = False
    for line in target.read_text().splitlines():
        if line == BEGIN:
            managed = True
            continue
        if line == END:
            managed = False
            continue
        if line == '#PlayIntegrityFix':
            legacy = True
            continue
        key = line.split('=', 1)[0].strip()
        if managed or key in values or (legacy and key in LEGACY):
            continue
        result.append(line)
    result += [BEGIN, *(f'{k}={v}' for k, v in values.items()), END]
    target.write_text('\n'.join(result) + '\n')
    print('FakeLock build.prop: ' + ', '.join(f'{k}={v}' for k, v in values.items()))

if __name__ == '__main__':
    update(Path(sys.argv[1]), Path(sys.argv[2]))
