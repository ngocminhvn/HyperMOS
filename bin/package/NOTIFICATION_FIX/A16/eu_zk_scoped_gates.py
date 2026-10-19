#!/usr/bin/env python3
"""Keep Xiaomi.eu GmsObserver and DeviceIdleController method bytes unchanged.

The frozen seven-gate audit stays as historical evidence. Only the three
DisplayFrameSetting flag reads are adapted. Exact EU DEX source checksum,
the seven-read audit, KillProcessController and the byte-level three-edit
allowlist are all verified before installation. No new classes or ABI changes.
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
ZK_AUDIT_BLOB_SHA = 'f229fb0a5c67d41a55310a119ef64b18a86d6c04'
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

# Four Google/DeviceIdle methods remain original EU; only DisplayFrameSetting
# may be adjusted for the China-base ROM.
EU_NATIVE = {
    key for key in ALLOW
    if key[0].startswith(('Lcom/miui/powerkeeper/utils/GmsObserver;',
                          'Lcom/miui/powerkeeper/controller/DeviceIdleController$'))
}
DISPLAY_ONLY = {key: count for key, count in ALLOW.items() if key not in EU_NATIVE}
if len(EU_NATIVE) != 4 or len(DISPLAY_ONLY) != 2 or sum(DISPLAY_ONLY.values()) != 3:
    raise RuntimeError('Unexpected EU native / DisplayFrameSetting method inventory')


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


EU_KILL_CLASS = 'Lcom/miui/powerkeeper/controller/KillProcessController;'
EU_KILL_REQUIRED = {
    ('setUidState', '(IZ)V'),
    ('shouldKillByCheckerPolicy', '(I)Z'),
}


def verify_eu_killprocess_unchanged(source: Dex, patched: Dex) -> dict:
    """Fail closed unless every executable EU KillProcessController method is identical.

    Checks every declared method's signature and instruction array, not just
    the two main UID kill methods. No ZK, RYU, or GMS-specific kill grafts.
    """
    original = {key: source.codes[key] for key in source.codes if key[0] == EU_KILL_CLASS}
    current = {key: patched.codes[key] for key in patched.codes if key[0] == EU_KILL_CLASS}
    if set(original) != set(current) or len(original) != 23:
        raise ValueError('EU KillProcessController method inventory changed')
    if not EU_KILL_REQUIRED <= {(k[1], k[2]) for k in original}:
        raise ValueError('EU KillProcessController UID policy methods missing')
    fingerprint = hashlib.sha256()
    for key in sorted(original):
        old_off, old_units = original[key]
        new_off, new_units = current[key]
        old_code = source.raw[old_off:old_off + old_units * 2]
        new_code = patched.raw[new_off:new_off + new_units * 2]
        if old_units != new_units or old_code != new_code:
            raise ValueError('EU KillProcessController bytecode was modified: ' + repr(key))
        fingerprint.update(repr(key).encode('utf-8'))
        fingerprint.update(old_code)
    return {
        'eu_killprocess_controller_unchanged': True,
        'eu_killprocess_method_count': len(original),
        'eu_killprocess_instructions_sha256': fingerprint.hexdigest(),
        'eu_uid_kill_policy': 'exact_original_EU_no_RYU_or_ZK_overrides',
    }


def load_gate_reference(path: Path) -> dict:
    """Validate the frozen audit record; do not need the 4 MB donor DEX."""
    reference = json.loads(path.read_text(encoding='utf-8'))
    expected_methods = [
        {'class': key[0], 'method': key[1], 'prototype': key[2],
         'eu_reads': count, 'previously_verified_zk_reads': count}
        for key, count in ALLOW.items()
    ]
    provenance = reference.get('zk_dex_reference', {})
    if (reference.get('schema_version') != 1
            or provenance.get('git_blob_sha1') != ZK_AUDIT_BLOB_SHA
            or provenance.get('source_field') != 'Lmiui/zk/Build;->IS_ZK_BUILD:Z'
            or reference.get('eu_dex_sha256') != EU_SHA
            or reference.get('scoped_eu_dex_sha256') != '64efd5ef111c27b7040c6d89054b72bef9e01d5363075dd348098e866fa6e2f1'
            or reference.get('unchanged_eu_killprocess_sha256') != 'e4a1804e1e715fa9ab07e1d5cd5916c041a58d2e71b5677c4d85358027515f1f'
            or reference.get('gate_method_total') != len(ALLOW)
            or reference.get('gate_read_total') != sum(ALLOW.values())
            or reference.get('gate_methods') != expected_methods):
        raise ValueError('Frozen ZKOS gate audit manifest changed or is incomplete')
    return reference


def port(eu, reference: dict):
    if sha(eu) != EU_SHA or sha(eu) != reference['eu_dex_sha256']:
        raise ValueError('EU DEX SHA-256 mismatch; donor not previously audited')
    a = Dex(eu)
    edits = []
    for key, count in ALLOW.items():
        hits = a.gate_hits(key, EU_FIELD)
        if len(hits) != count:
            raise ValueError(f'{key}: expected {count} audited EU gates, got EU={len(hits)}')
        if any(reg > 15 for _, reg in hits):
            raise ValueError(f'{key}: gate register exceeds const/4 range')
        if key in DISPLAY_ONLY:
            edits.extend((key, off, reg) for off, reg in hits)
    if len(edits) != 3:
        raise ValueError(f'Expected exactly three DisplayFrameSetting gates, got {len(edits)}')
    dest = bytearray(eu)
    for key, off, reg in edits:
        # const/4 vA, #+1 followed by nop, same size as the sget-boolean.
        struct.pack_into('<HH', dest, off, 0x1012 | (reg << 8), 0x0000)
    # Standard DEX header SHA-1 and Adler-32, in that order.
    dest[12:32] = hashlib.sha1(dest[32:]).digest()
    struct.pack_into('<I', dest, 8, zlib.adler32(dest[12:]) & 0xffffffff)
    final = bytes(dest)
    check = Dex(final)
    kill_parity = verify_eu_killprocess_unchanged(a, check)
    if kill_parity['eu_killprocess_instructions_sha256'] != reference['unchanged_eu_killprocess_sha256']:
        raise ValueError('Original EU KillProcessController fingerprint differs from frozen audit')
    for key, count in DISPLAY_ONLY.items():
        if check.gate_hits(key, EU_FIELD):
            raise ValueError('An expected DisplayFrameSetting gate was not patched: ' + repr(key))
    for key in EU_NATIVE:
        old_off, old_units = a.codes[key]
        new_off, new_units = check.codes[key]
        if (old_units != new_units
                or a.raw[old_off:old_off + old_units * 2] !=
                   check.raw[new_off:new_off + new_units * 2]
                or len(check.gate_hits(key, EU_FIELD)) != ALLOW[key]):
            raise ValueError('EU GmsObserver / DeviceIdleController method was changed: ' + repr(key))
    expected = {i for _, off, _ in edits for i in range(off, off + 4)} | set(range(8, 32))
    actual = {i for i, (x, y) in enumerate(zip(eu, final)) if x != y}
    if not actual <= expected:
        raise ValueError('EU DEX changed outside whitelist and DEX header')
    if sha(final) in (EU_SHA, reference['scoped_eu_dex_sha256']):
        raise ValueError('New output cannot equal the EU input or the retired seven-gate output')
    return final, {
        'source': 'exact_EU_DEX', 'source_sha256': sha(eu),
        'output_sha256': sha(final), 'gate_policy': 'original_EU_GmsObserver_DeviceIdleController_plus_three_DisplayFrameSetting_reads',
        'zk_gate_audit_git_blob_sha1': ZK_AUDIT_BLOB_SHA,
        'zk_dex_required_at_build': False,
        'changed_methods': [{ 'class':k[0], 'name':k[1], 'prototype':k[2], 'count':sum(t[0] == k for t in edits)} for k in DISPLAY_ONLY],
        'changed_gates': len(edits), 'eu_native_gms_doze_methods_unchanged': True, 'total_EU_methods_preserved': len(a.codes),
        'unrelated_EU_methods_untouched': True,
        'perfhook_or_RYU_methods_imported': False,
        'unchanged_thermal_resources_GPU_governor': True,
        'device_property_rewritten': False,
        **kill_parity,
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--eu', required=True, type=Path)
    p.add_argument('--gate-manifest', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    p.add_argument('--report', type=Path)
    args = p.parse_args()
    reference = load_gate_reference(args.gate_manifest)
    output, report = port(args.eu.read_bytes(), reference)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(output)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2) + '\n')
    print('[POWERKEEPER EU/SCOPED GATES] ' + json.dumps(report))

if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, json.JSONDecodeError, KeyError, TypeError, struct.error, IndexError) as exc:
        print('[POWERKEEPER EU/SCOPED GATES] FAIL: ' + str(exc), file=sys.stderr)
        raise SystemExit(1)