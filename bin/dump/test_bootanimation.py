#!/usr/bin/env python3
"""Offline tests for the one-file bootanimation ROM dump."""
import io
import tempfile
import unittest
import zipfile
from pathlib import Path

from bootanimation import candidate_rank, from_archive, from_partitions, validate_animation


def animation_bytes():
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as archive:
        archive.writestr("desc.txt", "1080 2400 30\np 1 0 part0\n")
        archive.writestr("part0/00000.png", b"test-image")
    return buffer.getvalue()


class BootanimationTests(unittest.TestCase):
    def test_accepts_known_media_paths(self):
        self.assertIsNotNone(candidate_rank("system/media/bootanimation.zip"))
        self.assertIsNotNone(candidate_rank("images/product/media/bootanimation.zip"))
        self.assertIsNotNone(candidate_rank("system/system/media/bootanimation.zip"))
        self.assertIsNone(candidate_rank("app/bootanimation.zip"))
        self.assertIsNone(candidate_rank("../system/media/bootanimation.zip"))

    def test_direct_rom_selects_product_override(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            rom, out = root / "rom.zip", root / "bootanimation.zip"
            with zipfile.ZipFile(rom, "w") as archive:
                archive.writestr("system/media/bootanimation.zip", animation_bytes())
                archive.writestr("product/media/bootanimation.zip", animation_bytes())
            self.assertEqual(from_archive(rom, out), "product/media/bootanimation.zip")
            validate_animation(out)

    def test_partition_tree_selects_system(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            file = root / "images/system/system/media/bootanimation.zip"
            file.parent.mkdir(parents=True)
            file.write_bytes(animation_bytes())
            out = root / "output/bootanimation.zip"
            source = from_partitions(root / "images", out)
            self.assertEqual(source, "system/system/media/bootanimation.zip")
            validate_animation(out)

    def test_no_direct_file_falls_back(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            rom = root / "rom.zip"
            with zipfile.ZipFile(rom, "w") as archive:
                archive.writestr("payload.bin", b"dummy")
            self.assertIsNone(from_archive(rom, root / "output.zip"))


if __name__ == "__main__":
    unittest.main()
