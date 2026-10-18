#!/usr/bin/env python3
"""Port ONLY selected, previously-identified ZK build-boolean gates into EU DEX.

No class/method/resource injection; never touches thermal, perf, UID kill or
private build labels. Explicit input pin + exact method signatures + ZK parity
check; replace sget-boolean vA, IS_INTERNATIONAL_BUILD with const/4 vA, 1; nop.
A DEX code-unit size is preserved; branch/try offsets remain unchanged.
"""
import argparse
import hashlib
import json
import struct
import sys
import zlib
from pathlib import Path

EU_SHA = 'ad30c2d2aa6d474c1b975bce8fb0f8816fc4dafe19fc825ff23022a5016f73ae'
EU_FIELD = ('Lmiui/os/Build;', 'IS_INTERNATIONAL_BUILD', 'Z')
ZK_FIELD = ('Lmiui/zk/Build;', 'IS_ZK_BUILD', 'Z')
# Only the gates ZK previously changed that directly affect Google sync,
# Doze callbacks or the display local config. DO NOT apply other 38+ EU reads.
ALLOW = {
    ('Lcom/miui/powerkeeper/utils/GmsObserver;', '<init>', '(Landroid/content/Context;)V'): 1,
    ('Lcom/miui/powerkeeper/utils/GmsObserver;', 'updateGoogleSync', '(Z)V'): 1,
    ('Lcom/miui/powerkeeper/controller/DeviceIdleController$1;', '<init>', '()V'): 1,
    ('Lcom/miui/powerkeeper/controller/DeviceIdleController$2;', '<init>', '()V'): 1,
    ('Lcom/miui/powerkeeper/statemachine/DisplayFrameSetting;', 'getValidLocalConfigPath', '(Landroid/content/Context;)Ljava/lang/String;'): 2,
    ('Lcom/miui/powerkeeper/statemachine/DisplayFrameSetting;', 'isSupportDevice', '()Z'): 1,
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


class Dex:
    def __init__(self, data):
        self.raw = data
        if len(data) < 112 or not data.startswith(b'dex\n'):
            raise ValueError('Not a valid DEX magic/header')
        if struct.unpack_from('<I', data, 32)[0] != len(data):
            raise ValueError('DEX file-size mismatch')
        self.strings = []
        ssize, soff = struct.unpack_from('<II', data, 0x38)
        for idx in range(ssize):
            off = struct.unpack_from('<I', data, soff + idx * 4)[0]
            _, off = self.uleb(off)
            end = data.index(b'\0', off)
            self.strings.append(data[off:end].decode('utf-8', 'replace'))
        tsize, toff = struct.unpack_from('<II', data, 0x40)
        self.types = [self.strings[struct.unpack_from('<I', data, toff + i * 4)[0]] for i in range(tsize)]
        psize, poff = struct.unpack_from('<II', data, 0x48)
        self.protos = []
        for i in range(psize):
            _, retval, paramoff = struct.unpack_from('<III', data, poff + i * 12)
            args = []
            if paramoff:
                count = struct.unpack_from('<I', data, paramoff)[0]
                args = [self.types[struct.unpack_from('<H', data, paramoff + 4 + j * 2)[0]] for j in range(count)]
            self.protos.append('(' + ''.join(args) + ')' + self.types[retval])
        fsize, foff = struct.unpack_from('<II', data, 0x50)
        self.fields = []
        for i in range(fsize):
            cl, typ, name = struct.unpack_from('<HHI', data, foff + i * 8)
            self.fields.append((self.types[cl], self.strings[name], self.types[typ]))
        msize, moff = struct.unpack_from('<II', data, 0x58)
        self.methods = []
        for i in range(msize):
            cl, proto, name = struct.unpack_from('<HHI', data, moff + i * 8)
            self.methods.append((self.types[cl], self.strings[name], self.protos[proto]))
        csize, coff = struct.unpack_from('<II', data, 0x60)
        self.codes = {}
        for i in range(csize):
            _, _, _, _, _, _, classdata, _ = struct.unpack_from('<IIIIIIII', data, coff + i * 32)
            if not classdata:
                continue
            pos = classdata
            static_count, pos = self.uleb(pos)
            instance_count, pos = self.uleb(pos)
            direct_count, pos = self.uleb(pos)
            virtual_count, pos = self.uleb(pos)
            for _ in range(static_count + instance_count):
                _, pos = self.uleb(pos)
                _, pos = self.uleb(pos)
            for count in [direct_count, virtual_count]:
                idx = 0
                for _ in range(count):
                    offset, pos = self.uleb(pos)
                    idx += offset
                    _, pos = self.uleb(pos)
                    codeoff, pos = self.uleb(pos)
                    if codeoff:
                        size = struct.unpack_from('<I', data, codeoff + 12)[0]
                        self.codes[self.methods[idx]] = (codeoff + 16, size)

    def uleb(self, pos):
        value = shift = 0
        while True:
            if pos >= len(self.raw) or shift > 35:
                raise ValueError('Invalid ULEB128')
            byte = self.raw[pos]
            pos += 1
            value |= (byte & 127) << shift
            if not byte & 128:
                return value, pos
            shift += 7

    def gate_hits(self, key, field):
        if key not in self.codes:
            raise ValueError('Missing required method: ' + repr(key))
        offsets = []
        offset, size = self.codes[key]
        field_indices = {i for i, name in enumerate(self.fields) if name == field}
        if len(field_indices) != 1:
            raise ValueError('Missing or duplicate build field reference: ' + repr(field))
        # SGET_BOOLEAN (0x63) encoded in exactly two 16-bit code units;
        # check register and indexed field, anchored inside *this* method.
        field_id = next(iter(field_indices))
        for idx in range(size - 1):
            word = struct.unpack_from('<H', self.raw, offset + 2 * idx)[0]
            if word & 0xff != 0x63:
                continue
            ref = struct.unpack_from('<H', self.raw, offset + 2 * idx + 2)[0]
            if ref == field_id:
                offsets.append((offset + 2 * idx, word >> 8))
        return offsets


def port(eu, zk):
    if sha(eu) != EU_SHA:
        raise ValueError('EU DEX SHA-256 mismatch; donor not previously audited')
    a, b = Dex(eu), Dex(zk)
    edits = []
    for key, count in ALLOW.items():
        hits = a.gate_hits(key, EU_FIELD)
        zk_hits = b.gate_hits(key, ZK_FIELD)
        if len(hits) != count or len(zk_hits) != count:
            raise ValueError(f'{key}: expected {count} EU/ZK matching gates, got EU={len(hits)} ZK={len(zk_hits)}')
        if any(reg > 15 for _, reg in hits):
            raise ValueError(f'{key}: gate register exceeds const/4 range')
        edits.extend((key, off, reg) for off, reg in hits)
    if len(edits) != 7:
        raise ValueError(f'Expected exactly seven scoped gates, got {len(edits)}')
    dest = bytearray(eu)
    for key, off, reg in edits:
        # const/4 vA, #+1 followed by nop, same size as the sget-boolean.
        struct.pack_into('<HH', dest, off, 0x1012 | (reg << 8), 0x0000)
    # Standard DEX header SHA-1 and Adler-32, in that order.
    dest[12:32] = hashlib.sha1(dest[32:]).digest()
    struct.pack_into('<I', dest, 8, zlib.adler32(dest[12:]) & 0xffffffff)
    final = bytes(dest)
    check = Dex(final)
    for key, count in ALLOW.items():
        if check.gate_hits(key, EU_FIELD):
            raise ValueError('An allowed EU gate was not patched: ' + repr(key))
    expected = {i for _, off, _ in edits for i in range(off, off + 4)} | set(range(8, 32))
    actual = {i for i, (x, y) in enumerate(zip(eu, final)) if x != y}
    if not actual <= expected:
        raise ValueError('EU DEX changed outside whitelist and DEX header')
    return final, {
        'source': 'exact_EU_DEX', 'source_sha256': sha(eu),
        'output_sha256': sha(final), 'gate_policy': 'ZKOS_proven_selected_GMS_Doze_Display_only',
        'changed_methods': [{ 'class':k[0], 'name':k[1], 'prototype':k[2], 'count':sum(t[0] == k for t in edits)} for k in ALLOW],
        'changed_gates': len(edits), 'total_EU_methods_preserved': len(a.codes),
        'unrelated_EU_methods_untouched': True,
        'perfhook_or_RYU_methods_imported': False,
        'unchanged_thermal_resources_GPU_governor': True,
        'device_property_rewritten': False,
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--eu', required=True, type=Path)
    p.add_argument('--zk-reference', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    p.add_argument('--report', type=Path)
    args = p.parse_args()
    output, report = port(args.eu.read_bytes(), args.zk_reference.read_bytes())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(output)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2) + '\n')
    print('[POWERKEEPER EU/ZK SCOPED] ' + json.dumps(report))

if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, struct.error, IndexError) as exc:
        print('[POWERKEEPER EU/ZK SCOPED] FAIL: ' + str(exc), file=sys.stderr)
        raise SystemExit(1)