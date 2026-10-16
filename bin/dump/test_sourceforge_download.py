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

    def test_sourceforge_mirror_redirect_url(self):
        mirrored = (
            "https://master.dl.sourceforge.net/project/eliteroms/"
            "HyperOS-STABLE-UPDATES/HyperOS-v3.0/" + self.FILE
            + "?viasf=1&fid=test"
        )
        self.assertEqual(sf.normalize(mirrored)[0], self.BASE + "/download")

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

    def test_preserve_signed_master_link_first_on_probe_failure(self):
        original = (
            "https://master.dl.sourceforge.net/project/eliteroms/"
            "HyperOS-STABLE-UPDATES/HyperOS-v3.0/" + self.FILE
            + "?viasf=1&fid=abc&st=signedtoken"
        )
        canonical, project, relative = sf.normalize(original)
        candidates = sf.candidate_urls(
            original, canonical, project, relative, ["autoselect"]
        )
        self.assertEqual(candidates[0], ("input-direct", original))
        self.assertIn(
            ("router-autoselect", sf.download_router_url(project, relative)),
            candidates,
        )
        self.assertIn(
            ("direct-master", sf.direct_mirror_url(project, relative, "master")),
            candidates,
        )
        # The old implementation only attempted one failing web-UI URL.
        self.assertGreater(len(candidates), 8)

    def test_ordinary_sourceforge_page_can_use_measured_direct_cdn(self):
        original = self.BASE + "*/*"
        canonical, project, relative = sf.normalize(original)
        candidates = sf.candidate_urls(
            original, canonical, project, relative,
            ["zenlayer", "autoselect"],
        )
        self.assertEqual(
            candidates[0],
            ("measured-zenlayer", sf.direct_mirror_url(project, relative, "zenlayer")),
        )
        self.assertTrue(all("use_mirror=autoselect" not in u for _, u in candidates))
        self.assertIn(("input-original", original), candidates)

    def test_download_router_not_sourceforge_web_page(self):
        _, project, relative = sf.normalize(self.BASE)
        self.assertEqual(
            sf.download_router_url(project, relative),
            self.BASE.replace(
                "https://sourceforge.net/projects/eliteroms/files/",
                "https://downloads.sourceforge.net/project/eliteroms/",
            ),
        )
        self.assertTrue(
            sf.download_router_url(project, relative, "psychz")
              .endswith("?use_mirror=psychz")
        )

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
