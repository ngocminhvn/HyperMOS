#!/usr/bin/env python3
"""Offline OpenSSL Salted__ encrypted-image checks (no network)."""
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parent))
from archive_inspect import classify
import archive_fallback
from openssl_image import LP_GEOMETRY, probe_profile, looks_like_super, decrypt_member


class OpenSSLImageTests(unittest.TestCase):
    def test_openssl_salted_magic(self):
        self.assertEqual(classify(b"Salted__12345678encrypted"),
                         "encrypted-openssl-salted")

    def test_missing_password_reports_precise_failure_before_extract(self):
        with tempfile.TemporaryDirectory() as dirname:
            d = Path(dirname)
            source = d / "rom.zip"
            with zipfile.ZipFile(source, "w") as bundle:
                bundle.writestr("META-INF/com/google/android/updater-script",
                                "EliteRom custom ROM")
                bundle.writestr("firmware-update/custom.img",
                                b"Salted__12345678" + b"\x00" * 8192)
            with patch.dict(os.environ, {"DUMP_IMAGE_PASSWORD": ""}):
                with self.assertRaises(SystemExit) as raised:
                    archive_fallback.extract(source, d / "work", "base")
            self.assertIn("[ENCRYPTED-ROM-IMAGE]", str(raised.exception))
            self.assertIn("DUMP_IMAGE_PASSWORD", str(raised.exception))

    @unittest.skipUnless(shutil.which("openssl"), "OpenSSL CLI required")
    def test_valid_password_profile_and_full_decrypt(self):
        password = "offline-test-passphrase"
        env = dict(os.environ, DUMP_IMAGE_PASSWORD=password)
        plain = bytearray(16 * 1024)
        plain[4096:4100] = LP_GEOMETRY
        plain = bytes(plain)
        created = subprocess.run(
            ["openssl", "enc", "-aes-256-cbc", "-salt", "-pbkdf2",
             "-pass", "env:DUMP_IMAGE_PASSWORD"],
            input=plain, capture_output=True, env=env, check=True
        ).stdout
        self.assertTrue(created.startswith(b"Salted__"))
        self.assertTrue(looks_like_super(plain))
        found = probe_profile(created[:16+8192], env=env)
        self.assertIsNotNone(found)
        self.assertEqual(found[0], "aes256-pbkdf2")
        with tempfile.TemporaryDirectory() as dirname:
            d = Path(dirname)
            archive_path = d / "test.zip"
            with zipfile.ZipFile(archive_path, "w") as zipfile_out:
                zipfile_out.writestr("firmware-update/custom.img", created)
            with zipfile.ZipFile(archive_path) as zipfile_in:
                with patch.dict(os.environ, {"DUMP_IMAGE_PASSWORD": password}):
                    output = decrypt_member(
                        zipfile_in, "firmware-update/custom.img",
                        d / "decoded.img", found[1]
                    )
            self.assertEqual(output.read_bytes(), plain)

    @unittest.skipUnless(shutil.which("openssl"), "OpenSSL CLI required")
    def test_wrong_password_is_not_accepted(self):
        good = dict(os.environ, DUMP_IMAGE_PASSWORD="good")
        bad = dict(os.environ, DUMP_IMAGE_PASSWORD="wrong")
        plain = bytearray(16 * 1024)
        plain[4096:4100] = LP_GEOMETRY
        created = subprocess.run(
            ["openssl", "enc", "-aes-256-cbc", "-salt", "-pbkdf2",
             "-pass", "env:DUMP_IMAGE_PASSWORD"],
            input=bytes(plain), capture_output=True, env=good, check=True
        ).stdout
        self.assertIsNone(probe_profile(created[:16+8192], env=bad))


if __name__ == "__main__":
    unittest.main()
