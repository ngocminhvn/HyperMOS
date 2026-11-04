#!/usr/bin/env python3
"""Offline regression tests: ranked SF mirror and safe fallbacks (no network)."""
import hashlib
import io
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BASE))
from mirror_fetch import fetch  # noqa: E402


def zip_bytes():
    stream = io.BytesIO()
    with zipfile.ZipFile(stream, "w") as archive:
        archive.writestr("system/product/app/Example/Example.apk", b"A" * 4096,
                         compress_type=zipfile.ZIP_STORED)
    return stream.getvalue()


class FakeSF:
    MIRRORS = ("fast", "slow", "autoselect")

    def __init__(self, payload, behavior=("good",)):
        self.payload = payload
        self.behavior = iter(behavior)
        self.calls = []

    def normalize(self, url):
        if url.startswith("https://sourceforge.net/projects/litegapps/files/"):
            return (url, "litegapps", "addon/arm64/37/gapps/Example/Example.zip")
        return None

    def benchmark(self, canonical):
        return (["fast", "slow", "autoselect"], [
            {"mirror": "slow", "status": "ok", "speed_bps": 1000,
             "speed_mib_s": 0.01, "serving_host": "slow.example"},
            {"mirror": "fast", "status": "ok", "speed_bps": 8000000,
             "speed_mib_s": 7.63, "serving_host": "fast.example"},
            {"mirror": "autoselect", "status": "unavailable", "reason": "http_403"},
        ])

    def candidate_urls(self, url, canonical, project, relative, ranked):
        return [(f"measured-{item}", item) for item in ranked]

    def download(self, url, output, connections, attempt_timeout):
        self.calls.append((url, connections, attempt_timeout))
        decision = next(self.behavior)
        if decision == "fail":
            return False
        if decision == "bad_hash":
            output.write_bytes(zip_bytes() + b"modified")
            return True
        output.write_bytes(self.payload)
        return True


class MirrorFetchTest(unittest.TestCase):
    def entry(self, payload):
        return {
            "name": "Example",
            "url": "https://sourceforge.net/projects/litegapps/files/"
                   "addon/arm64/37/gapps/Example/Example.zip/download",
            "sha256": hashlib.sha256(payload).hexdigest(),
        }

    def test_fastest_measured_mirror_is_first(self):
        payload = zip_bytes()
        sf = FakeSF(payload)
        with tempfile.TemporaryDirectory() as directory:
            output = fetch(self.entry(payload), Path(directory), driver=sf)
            self.assertEqual(output.read_bytes(), payload)
        self.assertEqual([c[0] for c in sf.calls], ["fast"])
        self.assertEqual(sf.calls[0][1], 12)
        self.assertLessEqual(sf.calls[0][2], 180)

    def test_fails_over_on_stalled_mirror(self):
        payload = zip_bytes()
        sf = FakeSF(payload, behavior=("fail", "good"))
        with tempfile.TemporaryDirectory() as directory:
            output = fetch(self.entry(payload), Path(directory), driver=sf)
            self.assertEqual(output.read_bytes(), payload)
        self.assertEqual([c[0] for c in sf.calls], ["fast", "slow"])

    def test_rejects_hash_mismatch_and_retries(self):
        payload = zip_bytes()
        sf = FakeSF(payload, behavior=("bad_hash", "good"))
        with tempfile.TemporaryDirectory() as directory:
            output = fetch(self.entry(payload), Path(directory), driver=sf)
            self.assertEqual(hashlib.sha256(output.read_bytes()).hexdigest(),
                             self.entry(payload)["sha256"])
            self.assertFalse((Path(directory) / "Example.zip.part.aria2").exists())
        self.assertEqual([c[0] for c in sf.calls], ["fast", "slow"])

    def test_cached_verified_archive_skips_all_probes(self):
        payload = zip_bytes()
        sf = FakeSF(payload, behavior=())
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Example.zip"
            path.write_bytes(payload)
            self.assertEqual(fetch(self.entry(payload), Path(directory), driver=sf), path)
        self.assertEqual(sf.calls, [])

    def test_invalid_url_or_checksum_fails_closed(self):
        payload = zip_bytes()
        entry = self.entry(payload)
        entry["url"] = "https://evil.example/Example.zip"
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                fetch(entry, Path(directory), driver=FakeSF(payload))


if __name__ == "__main__":
    unittest.main()
