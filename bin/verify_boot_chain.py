#!/usr/bin/env python3
"""Read-only boot/AVB metadata. Structural validation is not signature trust."""
import argparse
import hashlib
import importlib.util
import io
import json
import pathlib
import struct
import subprocess
import sys

sys.dont_write_bytecode = True

ROOT = pathlib.Path(__file__).resolve().parent.parent
TOOL = ROOT / 'bin/package/DISABLE_AVB/HMATools/aosp/avb/avbtool.v1.2.py'
spec = importlib.util.spec_from_file_location('hypermos_avb', TOOL)
avb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(avb)
NAMES = ('boot.img', 'vendor_boot.img', 'vbmeta.img', 'init_boot.img', 'dtbo.img')
REPORTED_HASH = 'e71fdea945abcd2618c99d061d6a20ade25e964b331e95ad0501b9e3788265f6'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def section(data, offset, size):
    if offset < 0 or size < 0 or offset + size > len(data):
        raise ValueError(f'truncated section: offset={offset}, size={size}')
    return data[offset:offset + size]


def aligned(size, page):
    if page <= 0 or page & (page - 1):
        raise ValueError('invalid page size')
    return (size + page - 1) // page * page


def text_field(data):
    return data.split(b'\0', 1)[0].decode('utf-8', errors='replace')


def boot_info(data):
    result = {}
    if data.startswith(b'VNDRBOOT'):
        fmt = '<8sIIIII2048sI16sIIQ'
        h = struct.unpack(fmt, section(data, 0, struct.calcsize(fmt)))
        version, page, ramdisk_size = h[1], h[2], h[5]
        if version not in (3, 4) or h[9] != (2128 if version == 4 else 2112):
            raise ValueError('invalid vendor boot header')
        offset = aligned(h[9], page)
        ramdisk = section(data, offset, ramdisk_size)
        offset += aligned(ramdisk_size, page)
        result.update(header_version=version, vendor_cmdline=text_field(h[6]),
                      ramdisk_sha256=sha(ramdisk), dtb_sha256=sha(section(data, offset, h[10])))
        offset += aligned(h[10], page)
        if version == 4:
            table_size, count, entry_size, bc_size = struct.unpack('<IIII', section(data, 2112, 16))
            table = section(data, offset, table_size)
            if entry_size < 108 or count * entry_size != table_size:
                raise ValueError('invalid vendor ramdisk table')
            entries = []
            end = 0
            for i in range(count):
                size, start, kind = struct.unpack_from('<III', table, i * entry_size)
                if start != end:
                    raise ValueError('noncontiguous vendor ramdisk table')
                end = start + size
                entries.append(dict(size=size, offset=start, type=kind,
                                    sha256=sha(section(ramdisk, start, size))))
            result['vendor_ramdisk_fragments'] = entries
            if end != ramdisk_size:
                raise ValueError(f'vendor ramdisk table covers {end} bytes, header requires {ramdisk_size}')
            offset += aligned(table_size, page)
            result['bootconfig'] = section(data, offset, bc_size).decode('utf-8', errors='replace')
    elif data.startswith(b'ANDROID!'):
        version = struct.unpack_from('<I', section(data, 0, 44), 40)[0]
        result['header_version'] = version
        if version in (3, 4):
            kernel, ramdisk = struct.unpack_from('<II', data, 8)
            header_size = struct.unpack_from('<I', data, 20)[0]
            if header_size != (1584 if version == 4 else 1580):
                raise ValueError('invalid boot header size')
            result['cmdline'] = text_field(section(data, 44, 1536))
            section(data, 4096, kernel)
            offset = 4096 + aligned(kernel, 4096)
            result['ramdisk_sha256'] = sha(section(data, offset, ramdisk))
            if version == 4:
                sig_size = struct.unpack_from('<I', data, 1580)[0]
                result['boot_signature_sha256'] = sha(section(data, offset + aligned(ramdisk, 4096), sig_size)) if sig_size else None
        elif version in (0, 1, 2):
            kernel, _, ramdisk, _, second = struct.unpack_from('<IIIII', data, 8)
            page = struct.unpack_from('<I', data, 36)[0]
            result['cmdline'] = text_field(section(data, 64, 512)) + text_field(section(data, 608, 1024))
            section(data, page, kernel)
            offset = page + aligned(kernel, page)
            result['ramdisk_sha256'] = sha(section(data, offset, ramdisk))
            offset += aligned(ramdisk, page)
            section(data, offset, second)
            if version >= 1:
                recovery_size, recovery_offset = struct.unpack_from('<IQ', section(data, 0, 1648), 1632)
                section(data, recovery_offset, recovery_size)
                offset += aligned(second, page) + aligned(recovery_size, page)
            if version == 2:
                dtb_size = struct.unpack_from('<I', section(data, 0, 1660), 1648)[0]
                result['dtb_sha256'] = sha(section(data, offset, dtb_size))
        else:
            raise ValueError(f'unsupported boot header {version}')
    else:
        raise ValueError('invalid boot magic')
    return result


def inspect(path):
    data = path.read_bytes()
    if not data:
        raise ValueError('empty image')
    result = dict(size=len(data), sha256=sha(data))
    if path.name in ('boot.img', 'vendor_boot.img', 'init_boot.img'):
        result.update(boot_info(data))
    if path.name == 'dtbo.img':
        h = struct.unpack('>8I', section(data, 0, 32))
        if h[0] != 0xd7b7ab1e or h[1] > len(data) or h[2] < 32 or h[3] < 32:
            raise ValueError('invalid DTBO header')
        table = section(data, h[5], h[3] * h[4])
        for i in range(h[4]):
            size, offset = struct.unpack_from('>II', table, i * h[3])
            section(data, offset, size)
    footer = data[-64:].startswith(b'AVBf')
    result['avb_footer'] = footer
    offset = 0
    limit = len(data)
    if footer:
        f = avb.AvbFooter(data[-64:])
        offset, limit = f.vbmeta_offset, f.vbmeta_offset + f.vbmeta_size
        if f.original_image_size > offset or limit > len(data) - 64:
            raise ValueError('invalid AVB footer bounds')
    if data.startswith(b'AVB0') or footer:
        h = avb.AvbVBMetaHeader(section(data, offset, 256))
        size = 256 + h.authentication_data_block_size + h.auxiliary_data_block_size
        if offset + size > limit:
            raise ValueError('invalid AVB block sizes')
        blob = section(data, offset, size)
        aux = section(blob, 256 + h.authentication_data_block_size, h.auxiliary_data_block_size)
        for start, length in ((h.hash_offset, h.hash_size), (h.signature_offset, h.signature_size)):
            section(blob[256:256 + h.authentication_data_block_size], start, length)
        encoded_descriptors = section(aux, h.descriptors_offset, h.descriptors_size)
        position = 0
        while position < len(encoded_descriptors):
            _, length = struct.unpack('>QQ', section(encoded_descriptors, position, 16))
            if length % 8:
                raise ValueError('unaligned AVB descriptor')
            section(encoded_descriptors, position + 16, length)
            position += 16 + length
        descriptors = avb.parse_descriptors(encoded_descriptors)
        key = section(aux, h.public_key_offset, h.public_key_size)
        section(aux, h.public_key_metadata_offset, h.public_key_metadata_size)
        summary = []
        for d in descriptors:
            item = dict(type=type(d).__name__)
            for attr in ('partition_name', 'rollback_index_location', 'image_size', 'hash_algorithm'):
                if hasattr(d, attr):
                    item[attr] = getattr(d, attr)
            if hasattr(d, 'digest'):
                item['digest'] = d.digest.hex()
            if hasattr(d, 'public_key'):
                item['public_key_sha256'] = sha(d.public_key)
            if isinstance(d, avb.AvbHashDescriptor) and d.partition_name == path.stem:
                item['payload_hash_matches'] = hashlib.new(d.hash_algorithm, d.salt + section(data, 0, d.image_size)).digest() == d.digest
            summary.append(item)
        result['avb'] = dict(algorithm=avb.lookup_algorithm_by_type(h.algorithm_type)[0],
                            flags=h.flags, rollback_index=h.rollback_index,
                            public_key_sha256=sha(key) if key else None,
                            vbmeta_struct_sha256=sha(blob), vbmeta_struct_size=size,
                            descriptors=summary)
        # avbtool's textual summary is also retained for independent inspection.
        p = subprocess.run([sys.executable, str(TOOL), 'info_image', '--image', str(path)],
                           capture_output=True, text=True)
        if p.returncode:
            raise ValueError('avbtool info_image failed: ' + p.stderr)
        result['avbtool_info'] = p.stdout
    elif path.name.startswith('vbmeta'):
        raise ValueError('invalid vbmeta magic')
    return result


def snapshot(images):
    names = set(NAMES) | {p.name for p in images.glob('vbmeta*.img')}
    return {n: inspect(images / n) if (images / n).exists() else None for n in sorted(names)}


def vbmeta_digest(images):
    """libavb hashes loaded vbmeta structs, not padded partition files.

    With verification disabled, libavb skips descriptors/chain loading.
    Otherwise avbtool's chain traversal computes the reference digest.
    """
    path = images / 'vbmeta.img'
    if not path.exists():
        return None
    info = inspect(path)['avb']
    if info['flags'] & 2:
        return dict(digest=info['vbmeta_struct_sha256'], size=info['vbmeta_struct_size'],
                    mode='libavb verification-disabled: top-level only')
    output = io.StringIO()
    missing = [d['partition_name'] for d in info['descriptors']
               if d['type'] == 'AvbChainPartitionDescriptor'
               and not (images / (d['partition_name'] + '.img')).exists()]
    if missing:
        return dict(digest=None, size=None, mode='unavailable: missing chained images', missing=missing)
    avb.Avb().calculate_vbmeta_digest(str(path), 'sha256', output)
    total = info['vbmeta_struct_size']
    for d in info['descriptors']:
        if d['type'] == 'AvbChainPartitionDescriptor':
            total += inspect(images / (d['partition_name'] + '.img'))['avb']['vbmeta_struct_size']
    return dict(digest=output.getvalue().strip(), size=total, mode='avbtool chained vbmeta structs')


def main():
    p = argparse.ArgumentParser()
    p.add_argument('stage', choices=('before', 'after', 'final', 'inspect'))
    p.add_argument('--images', type=pathlib.Path, required=True)
    p.add_argument('--metadata', type=pathlib.Path, default=ROOT / 'build/boot-chain')
    args = p.parse_args()
    current = snapshot(args.images)
    digest = vbmeta_digest(args.images)
    result = dict(images=current, vbmeta_digest=digest,
                  resetprop=dict(enabled=False, vbmeta_disable='unset in current pipeline',
                                 digest_injected=None, size_injected=None))
    # Any generated injection must name the digest of the final images. This
    # pipeline deliberately injects none; record actual existing cmdline values.
    result['boot_vbmeta_parameters'] = {
        name: [token for token in (entry.get('cmdline', '') + ' ' + entry.get('vendor_cmdline', '') + ' ' + entry.get('bootconfig', '')).split()
               if token.startswith('androidboot.vbmeta.')]
        for name, entry in current.items() if entry}
    if args.stage != 'inspect':
        args.metadata.mkdir(parents=True, exist_ok=True)
        if args.stage != 'before':
            previous = json.loads((args.metadata / 'before.json').read_text())['images']
            for name, old in previous.items():
                if old is not None and current.get(name) is None:
                    raise ValueError(f'final image missing: {name}')
        (args.metadata / (args.stage + '.json')).write_text(json.dumps(result, indent=2) + '\n')
    print('BOOT CHAIN DIAGNOSTIC')
    print(json.dumps(result, indent=2))
    matches = [f'{n}:{field}' for n, entry in current.items() if entry
               for field, value in [('file_sha256', entry['sha256']),
                                    ('vbmeta_struct_sha256', entry.get('avb', {}).get('vbmeta_struct_sha256'))]
               if value == REPORTED_HASH]
    if digest and digest['digest'] == REPORTED_HASH:
        matches.append('reference_vbmeta_digest')
    print('reported verifiedBootHash matches:', matches or 'none')
    if args.stage == 'final':
        print('image | before SHA256/size | after SHA256/size | final SHA256/size')
        stages = [json.loads((args.metadata / (s + '.json')).read_text())['images'] for s in ('before', 'after', 'final')]
        for n in sorted(set().union(*(s.keys() for s in stages))):
            print(n + ' | ' + ' | '.join(f"{s[n]['sha256']}/{s[n]['size']}" if s.get(n) else 'absent' for s in stages))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, struct.error, LookupError, avb.AvbError) as exc:
        sys.exit('BOOT CHAIN ERROR: ' + str(exc))
