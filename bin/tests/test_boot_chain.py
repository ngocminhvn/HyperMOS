import argparse
import contextlib
import io
import json
import pathlib
import struct
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
import vbpatcher as patch
import verify_boot_chain as verify


class BootChainTests(unittest.TestCase):
    def test_invalid_magic_is_failure(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = pathlib.Path(tmp)
            (p / 'bad.img').write_bytes(b'bad image')
            with self.assertRaises(ValueError):
                patch.unpack(argparse.Namespace(image=str(p / 'bad.img'), output=str(p / 'out')))

    def test_truncated_lz4_is_failure(self):
        with self.assertRaises(ValueError):
            patch.decompress_ramdisk(b'\x02\x21\x4c\x18' + struct.pack('<I', 100) + b'bad')

    def test_cpio_without_trailer_is_failure(self):
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(ValueError):
                patch.unpack_cpio(b'', tmp)

    def test_footer_bounds_are_checked(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = pathlib.Path(tmp) / 'vbmeta.img'
            footer = verify.avb.AvbFooter()
            footer.original_image_size = 0
            footer.vbmeta_offset = 1024
            footer.vbmeta_size = 256
            p.write_bytes(b'AVB0' + b'\0' * 256 + footer.encode())
            with self.assertRaises(ValueError):
                verify.inspect(p)

    def test_v4_two_fragments_repack_updates_table(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = pathlib.Path(tmp)
            pieces = []
            for i in range(2):
                rd = p / f'fragment_{i}' / 'ramdisk_root'
                rd.mkdir(parents=True)
                (rd / 'fstab.test').write_text('first_stage_mount,avb=vbmeta_vendor')
                (rd / 'ramdisk_meta.json').write_text(json.dumps([
                    dict(name='fstab.test', mode=0x81a4, uid=0, gid=0)]))
                pieces.append(patch.compress_ramdisk(patch.pack_cpio(str(rd)), 'gzip'))
            table = bytearray(216)
            struct.pack_into('<III', table, 0, len(pieces[0]), 0, 1)
            struct.pack_into('<III', table, 108, len(pieces[1]), len(pieces[0]), 3)
            (p / 'vendor_ramdisk_table.img').write_bytes(table)
            (p / 'dtb.img').write_bytes(b'dtb')
            (p / 'bootconfig.img').write_bytes(b'androidboot.hardware=qcom\n')
            config = dict(header_version=4, page_size=4096, kernel_load_addr=0,
                          ramdisk_load_addr=0, cmdline='bootconfig', tags_load_addr=0,
                          name='', dtb_load_addr=0, vendor_ramdisk_table_entry_num=2,
                          vendor_ramdisk_table_entry_size=108, has_avb=False,
                          original_image_size=65536,
                          fragments=[dict(path=f'fragment_{i}/ramdisk_root', compression='gzip') for i in range(2)])
            (p / 'config.json').write_text(json.dumps(config))
            # Change only the first fragment, making its compressed size change.
            (p / 'fragment_0/ramdisk_root/fstab.test').write_text('first_stage_mount')
            patch.repack(argparse.Namespace(config=str(p / 'config.json'), output=str(p / 'vendor_boot.img')))
            info = verify.inspect(p / 'vendor_boot.img')
            fragments = info['vendor_ramdisk_fragments']
            self.assertNotEqual(fragments[0]['size'], len(pieces[0]))
            self.assertEqual(fragments[1]['offset'], fragments[0]['size'])
            self.assertEqual(fragments[1]['sha256'], verify.sha(pieces[1]))
            out = p / 'roundtrip'
            patch.unpack(argparse.Namespace(image=str(p / 'vendor_boot.img'), output=str(out)))
            self.assertEqual((out / 'fragment_0/ramdisk_root/fstab.test').read_text(), 'first_stage_mount')
            self.assertEqual((out / 'fragment_1/ramdisk_root/fstab.test').read_text(), 'first_stage_mount,avb=vbmeta_vendor')


if __name__ == '__main__':
    with contextlib.redirect_stdout(io.StringIO()):
        unittest.main()
