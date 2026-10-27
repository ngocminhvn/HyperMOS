#!/usr/bin/env python3
"""Tests for the strict Kaorios JSON configuration loader."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


LOADER_PATH = Path(__file__).with_name("load-config.py")
spec = importlib.util.spec_from_file_location("kaorios_config_loader", LOADER_PATH)
loader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(loader)


class ConfigLoaderTest(unittest.TestCase):
    def write(self, directory: str, value) -> Path:
        path = Path(directory) / "config.json"
        path.write_text(json.dumps(value), encoding="utf-8")
        return path

    def valid(self):
        return {key: True for key in loader.SCHEMA}

    def test_accepts_complete_boolean_config(self):
        with tempfile.TemporaryDirectory() as directory:
            value = self.valid()
            value["verbose_log"] = False
            self.assertEqual(value, loader.load_config(self.write(directory, value)))

    def test_rejects_missing_unknown_and_non_boolean_values(self):
        with tempfile.TemporaryDirectory() as directory:
            for value in (
                {key: item for key, item in self.valid().items() if key != "keybox"},
                {**self.valid(), "typo": True},
                {**self.valid(), "keybox": "true"},
                {**self.valid(), "keybox": 1},
            ):
                with self.subTest(value=value):
                    with self.assertRaises(ValueError):
                        loader.load_config(self.write(directory, value))

    def test_rejects_duplicate_keys(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "config.json"
            path.write_text('{"master": true, "master": false}', encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "duplicate key"):
                loader.load_config(path)


if __name__ == "__main__":
    unittest.main()
