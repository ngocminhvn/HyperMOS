#!/usr/bin/env python3
"""Offline regression tests for Xiaomi official stock-ROM CDN mirror selection."""
import hashlib
import importlib.util
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[1] / "sourceforge_download.py"
spec = importlib.util.spec_from_file_location("stock_downloader", SOURCE)
downloader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(downloader)

ROM = ("https://bigota.d.miui.com/OS3.0.303.0.WOCMIXM/"
       "dada_global-ota_full-OS3.0.303.0.WOCMIXM-user-16.0-93266168a5.zip")


class XiaomiStockCDNTest(unittest.TestCase):
    def test_only_host_changes_and_fastest_verified_first(self):
        def fake_probe(pair):
            host, _ = pair
            speed = (3_000_000 if host == "bn.d.miui.com" else
                     900_000 if host == "cdnorg.d.miui.com" else
                     8_000 if host == "bigota.d.miui.com" else 0)
            if not speed:
                return {"mirror": host, "status": "unavailable", "reason": "range_denied"}
            return {"mirror": host, "status": "ok", "speed_bps": speed,
                    "speed_mib_s": speed / (1024 * 1024), "serving_host": host}
        with patch.object(downloader, "probe", side_effect=fake_probe):
            candidates, reports = downloader.xiaomi_candidates(ROM)
        self.assertEqual(len(reports), len(downloader.XIAOMI_CDNS))
        self.assertEqual(candidates[0][0], "bn.d.miui.com")
        self.assertEqual(candidates[1][0], "cdnorg.d.miui.com")
        self.assertEqual(candidates[-1][0], "bigota.d.miui.com")
        for host, url in candidates:
            self.assertTrue(url.startswith("https://" + host + "/"))
            self.assertEqual(url.split("/", 3)[-1], ROM.split("/", 3)[-1])

    def test_non_xiaomi_is_untouched(self):
        with patch.object(downloader, "probe") as mocked:
            candidates, reports = downloader.xiaomi_candidates(
                "https://example.org/ROM.zip")
            self.assertEqual((candidates, reports), ([], []))
            mocked.assert_not_called()

    def test_legacy_recovery_archive_md5_check(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "stock.zip"
            with zipfile.ZipFile(p, "w") as z:
                z.writestr("payload.bin", b"A" * 4096,
                           compress_type=zipfile.ZIP_STORED)
            actual = hashlib.md5(p.read_bytes()).hexdigest()
            self.assertTrue(downloader.valid_zip(p, actual))
            self.assertFalse(downloader.valid_zip(p, "0" * 32))


if __name__ == "__main__":
    unittest.main()
