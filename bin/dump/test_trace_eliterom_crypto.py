#!/usr/bin/env python3
"""Synthetic ELF tests for static EliteRom crypto tracing; no real installer run."""
import struct
import tempfile
import unittest
from pathlib import Path

from trace_eliterom_crypto import ElfView, analyze, entropy


def synthetic_elf():
    data = bytearray(0x800)
    data[:16] = b"\x7fELF\x02\x01\x01" + b"\0" * 9
    struct.pack_into("<H", data, 18, 62)        # EM_X86_64
    struct.pack_into("<Q", data, 24, 0x400470)  # entry VA
    struct.pack_into("<Q", data, 32, 64)        # PHDR offset
    struct.pack_into("<H", data, 54, 56)        # PHDR entry size
    struct.pack_into("<H", data, 56, 2)         # 2 program headers
    struct.pack_into("<IIQQQQQQ", data, 64, 1, 7, 0, 0x400000,
                     0, 0x800, 0x800, 0x1000)
    struct.pack_into("<IIQQQQQQ", data, 120, 2, 6, 0x200,
                     0x400200, 0, 0x100, 0x100, 8)
    tags = [(5, 0x400360), (10, 64), (6, 0x400300), (11, 24),
            (23, 0x400400), (2, 24), (0, 0)]
    for i, tag in enumerate(tags):
        struct.pack_into("<qQ", data, 0x200 + 16*i, *tag)
    struct.pack_into("<IBBHQQ", data, 0x300+24, 1, 18, 0, 0, 0, 0)
    name = b"\0EVP_DecryptInit_ex\0"
    data[0x360:0x360+len(name)] = name
    struct.pack_into("<QQq", data, 0x400, 0x400550, (1 << 32) | 7, 0)
    data[0x460:0x466] = bytes.fromhex("f30f1efaff25")
    struct.pack_into("<i", data, 0x466, 0x400550-0x40046a)
    data[0x470] = 0xe8
    struct.pack_into("<i", data, 0x471, 0x400460-0x400475)
    return bytes(data)


class ElfTraceTests(unittest.TestCase):
    def test_reject_non_elf(self):
        with self.assertRaises(ValueError):
            ElfView(b"not ELF")

    def test_entropy(self):
        self.assertEqual(entropy(b"\0"*256), 0)
        self.assertEqual(round(entropy(bytes(range(256))), 4), 8)

    def test_plt_mapping_and_synthetic_caller(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "toy.elf"
            path.write_bytes(synthetic_elf())
            report = analyze(path)
        self.assertEqual(report["dynamic_jumps_imported"], 1)
        self.assertEqual(report["plt_stubs_matched"], 1)
        self.assertEqual(report["imported_crypto_functions"][0]["name"],
                         "EVP_DecryptInit_ex")
        self.assertEqual(report["imported_crypto_functions"][0]["got"], "0x400550")
        calls = report["static_reference_scan"]["results"]["direct_call_plt"]
        self.assertEqual(calls, [{"site":"0x400470",
                                  "imported":"EVP_DecryptInit_ex"}])

    def test_no_plaintext_secrets_emitted(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "toy.elf"
            path.write_bytes(synthetic_elf())
            report = analyze(path)
        self.assertNotIn("secret", report)
        self.assertNotIn("password_value", report)
        self.assertEqual(report["literal_occurrences"]["custom.img"], 0)


if __name__ == "__main__":
    unittest.main()
