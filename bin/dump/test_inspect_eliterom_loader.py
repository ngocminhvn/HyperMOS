#!/usr/bin/env python3
"""Synthetic fixtures for second-stage non-executing installer forensics."""
import struct
import unittest

from test_trace_eliterom_crypto import synthetic_elf
from trace_eliterom_crypto import ElfView
from inspect_eliterom_loader import (
    direct_entry_edges, inspect, phdrs, windows_protection_sections
)
from pathlib import Path
import tempfile


class LoaderTests(unittest.TestCase):
    def test_elf_load_segments_and_absent_sections(self):
        blob = synthetic_elf()
        segments = phdrs(blob)
        self.assertEqual(len(segments), 1)
        self.assertTrue(segments[0]["writable"])
        self.assertTrue(segments[0]["executable"])

    def test_known_boundary_entry_branches(self):
        data=bytearray(synthetic_elf())
        # at entry 0x400470: ENDBR64; call rel32 to 0x400700;
        # mov ebx,imm32; jmp rel32 to 0x400500.
        va=0x400470
        data[0x470:0x474]=bytes.fromhex("f30f1efa")
        data[0x474]=0xe8
        struct.pack_into("<i", data,0x475,0x400700-(va+9))
        data[0x479]=0xbb
        data[0x47a:0x47e]=b"\0"*4
        data[0x47e]=0xe9
        struct.pack_into("<i",data,0x47f,0x400500-(va+19))
        evidence=direct_entry_edges(bytes(data),ElfView(bytes(data)))
        self.assertEqual(evidence["branches"][0]["target"],"0x400700")
        self.assertEqual(evidence["branches"][1]["target"],"0x400500")

    def test_pe_themida_section_detection(self):
        pe=bytearray(512)
        pe[:2]=b"MZ"
        struct.pack_into("<I",pe,0x3c,0x80)
        pe[0x80:0x84]=b"PE\0\0"
        struct.pack_into("<H",pe,0x86,1)
        struct.pack_into("<H",pe,0x94,0)
        pe[0x98:0xa0]=b".themida"
        result=windows_protection_sections(bytes(pe))
        self.assertTrue(result["has_themida_named_section"])
        self.assertEqual(result["sections"],[".themida"])

    def test_read_only_synthetic_report_does_not_assume_key(self):
        with tempfile.TemporaryDirectory() as temp:
            fixture=Path(temp)/"toy.elf"
            fixture.write_bytes(synthetic_elf())
            result=inspect(fixture)
            self.assertFalse(result["inspection_executed_installer"])
            self.assertEqual(result["large_rwx_file_region_bytes"],0x800)
            self.assertFalse(result["literal_strings_present"]["custom.img"])
            self.assertIn("Key source",result["warning"])


if __name__=="__main__":
    unittest.main()
