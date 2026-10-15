#!/usr/bin/env python3
"""Offline tests for SourceForge URL normalization and mirror selection."""
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).parent))
import sourceforge_download as sf


class SourceForgeDownloadTests(unittest.TestCase):
    FILE = (
        "EliteRomLite_v4.05_HAOTIAN_OS3.0.307.0_ChinaStable-A16.zip"
    )
    BASE = (
        "https://sourceforge.net/projects/eliteroms/files/"
        "HyperOS-STABLE-UPDATES/HyperOS-v3.0/" + FILE
    )

    def test_star_slash_star_sourceforge_url(self):
        canonical, project, relative = sf.normalize(self.BASE + "*/*")
        self.assertEqual(project, "eliteroms")
        self.assertEqual(
            relative,
            "HyperOS-STABLE-UPDATES/HyperOS-v3.0/" + self.FILE
        )
        self.assertEqual(canonical, self.BASE + "/download")

    def test_official_download_url(self):
        self.assertEqual(sf.normalize(self.BASE + "/download")[0],
                         self.BASE + "/download")

    def test_plain_url_with_query(self):
        self.assertEqual(sf.normalize(self.BASE + "?ts=123")[0],
                         self.BASE + "/download")

    def test_downloads_sourceforge_project_url(self):
        direct = self.BASE.replace(
            "https://sourceforge.net/projects/eliteroms/files/",
            "https://downloads.sourceforge.net/project/eliteroms/"
        )
        self.assertEqual(sf.normalize(direct)[0], self.BASE + "/download")

    def test_other_host_remains_direct(self):
        self.assertIsNone(sf.normalize("https://files.example.org/rom.zip"))

    def test_bad_url_rejected(self):
        with self.assertRaises(ValueError):
            sf.normalize("file:///tmp/rom.zip")
        with self.assertRaises(ValueError):
            sf.normalize(self.BASE.replace(".zip", ".zip/../../bad"))

    def test_mirror_query(self):
        self.assertTrue(
            sf.mirror_url(self.BASE + "/download", "onboardcloud")
              .endswith("?use_mirror=onboardcloud")
        )

    def test_rank_by_measured_speed_and_deduplicate_actual_hosts(self):
        measurements = {
            "autoselect": (30, "same.example.net"),
            "onboardcloud": (50, "same.example.net"),
            "zenlayer": (60, "fast.example.net"),
            "twds": None,
        }

        def mocked_probe(item):
            name, _url = item
            data = measurements[name]
            if data is None:
                return {"mirror": name, "status": "unavailable"}
            return {
                "mirror": name, "status": "ok",
                "speed_bps": data[0],
                "serving_host": data[1],
            }

        with mock.patch.object(sf, "probe", side_effect=mocked_probe):
            ranked, records = sf.benchmark(
                self.BASE + "/download", tuple(measurements)
            )
        self.assertEqual(ranked, ["zenlayer", "onboardcloud", "autoselect"])
        self.assertEqual(len(records), 4)

    def test_without_valid_mirrors_falls_back_to_autoselect(self):
        def unavailable(item):
            return {"mirror": item[0], "status": "unavailable"}

        with mock.patch.object(sf, "probe", side_effect=unavailable):
            ranked, _ = sf.benchmark(self.BASE + "/download", ("twds",))
        self.assertEqual(ranked, ["autoselect"])

    def test_probe_rejects_html_without_download(self):
        class Result:
            returncode = 0
            stdout = "200\t100\t1000\thttps://sourceforge.net/a"
        with tempfile.TemporaryDirectory() as tmp:
            # curl is simulated; no HTTP requests are made.
            def fake_run(command, **kwargs):
                Path(command[command.index("-o") + 1]).write_bytes(
                    b"<html>not a zip</html>"
                )
                return Result()
            with mock.patch.object(sf.subprocess, "run", side_effect=fake_run):
                entry = sf.probe(("onboardcloud", self.BASE + "/download"))
        self.assertEqual(entry["status"], "unavailable")


if __name__ == "__main__":
    unittest.main()
