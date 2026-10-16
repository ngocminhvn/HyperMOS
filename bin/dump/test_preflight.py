#!/usr/bin/env python3
"""Known encrypted ROM guard tests. Never accesses network."""
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parent))
from preflight import known_encrypted_release, check_source

PROJECT = "https://sourceforge.net/projects/eliteroms/files/HyperOS-STABLE-UPDATES/HyperOS-v3.0/"
FILENAME = "EliteRomLite_v4.05_HAOTIAN_OS3.0.307.0_ChinaStable-A16.zip"


class PreflightTests(unittest.TestCase):
    def test_verified_eliterom_web_url_is_blocked(self):
        self.assertTrue(known_encrypted_release(PROJECT + FILENAME + "*/*"))
        self.assertTrue(known_encrypted_release(PROJECT + FILENAME + "/download"))

    def test_signed_direct_mirror_url_is_blocked(self):
        direct = (
            "https://master.dl.sourceforge.net/project/eliteroms/"
            "HyperOS-STABLE-UPDATES/HyperOS-v3.0/" + FILENAME
            + "?viasf=1&fid=abc&e=123&st=test"
        )
        self.assertTrue(known_encrypted_release(direct))

    def test_other_roms_not_blocked(self):
        self.assertFalse(known_encrypted_release(PROJECT + "stock-haotian.zip"))
        self.assertFalse(known_encrypted_release(PROJECT + FILENAME.replace("4.05", "4.06")))
        self.assertFalse(known_encrypted_release("https://example.com/" + FILENAME))
        self.assertFalse(known_encrypted_release("https://sourceforge.net/projects/other/files/" + FILENAME))

    def test_emits_diagnostic_and_exits_before_download(self):
        with tempfile.TemporaryDirectory() as tmp:
            summary = Path(tmp) / "summary.md"
            with patch.dict("os.environ", {"GITHUB_STEP_SUMMARY": str(summary)}):
                status = check_source(PROJECT + FILENAME)
            self.assertEqual(status, 2)
            self.assertIn("encrypted", summary.read_text().lower())
            self.assertIn("adb_dump.py", summary.read_text())

    def test_new_rom_not_blocked(self):
        self.assertEqual(check_source(PROJECT + "new-unverified.zip"), 0)


if __name__ == "__main__":
    unittest.main()
