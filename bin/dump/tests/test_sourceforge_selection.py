#!/usr/bin/env python3
"""Offline checks: a 403-only SourceForge probe must not claim fastest mirror."""
import importlib.util
import unittest
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1] / "sourceforge_download.py"
spec = importlib.util.spec_from_file_location("hypermos_sourceforge_download", MODULE)
sf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sf)


class SourceForgeSelectionTests(unittest.TestCase):
    def test_all_403_is_autoselect_fallback_not_measured(self):
        probes = [
            {"mirror": name, "status": "unavailable", "reason": "http_403"}
            for name in sf.MIRRORS
        ]
        ordered, _ = [], probes
        self.assertEqual(
            sf.classify_mirror_selection("router-autoselect", probes),
            "sourceforge_autoselect_fallback",
        )
        self.assertNotIn("range_measured", sf.classify_mirror_selection("router-autoselect", probes))
        self.assertIn("not measured", sf.mirror_selection_label("sourceforge_autoselect_fallback"))

    def test_measured_auto_route(self):
        probes = [{"mirror": "autoselect", "status": "ok", "speed_bps": 1200000}]
        self.assertEqual(sf.classify_mirror_selection("router-autoselect", probes), "range_measured")

    def test_measured_named_route(self):
        probes = [{"mirror": "zenlayer", "status": "ok", "speed_bps": 500000}]
        self.assertEqual(sf.classify_mirror_selection("measured-zenlayer", probes), "range_measured")

    def test_non_measured_fallback(self):
        probes = [{"mirror": "zenlayer", "status": "unavailable", "reason": "http_403"}]
        self.assertEqual(sf.classify_mirror_selection("router-zenlayer", probes), "unverified_fallback")
        self.assertEqual(sf.classify_mirror_selection("input-direct", probes), "original_direct_url")

    def test_ranking_retains_autoselect_and_fallback_order(self):
        sf_url = "https://sourceforge.net/projects/demo/files/roms/test.zip/download"
        canonical, project, file_path = sf.normalize(sf_url)
        urls = sf.candidate_urls(sf_url, canonical, project, file_path, ["autoselect", "zenlayer"])
        self.assertEqual(urls[0][0], "router-autoselect")
        self.assertEqual(urls[1][0], "measured-zenlayer")


if __name__ == "__main__":
    unittest.main()
