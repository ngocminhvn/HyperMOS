"""Read-only regression checks for audited Global303 EU PowerKeeper cloud port."""
import importlib.util
import io
import json
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "global_cloud_policy.py"
MANIFEST = ROOT / "global_cloud_policy.json"
PACKAGER = ROOT / "eu_powerkeeper_keep_metadata.py"


def import_path(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


policy = import_path("global_cloud_policy", SCRIPT)
meta = import_path("eu_powerkeeper_keep_metadata", PACKAGER)


class GlobalCloudTests(unittest.TestCase):
    def test_only_global_cloud_and_region_methods_are_selected(self):
        data = policy.load_manifest(MANIFEST)
        expected = {
            ("com/miui/powerkeeper/cloudcontrol/CloudUpdateReceiver.smali",
             "onReceive(Landroid/content/Context;Landroid/content/Intent;)V"),
            ("com/miui/powerkeeper/cloudcontrol/LocalUpdateUtils.smali",
             "getCloudServer(Landroid/content/Context;)Ljava/lang/String;"),
            ("com/miui/powerkeeper/cloudcontrol/LocalUpdateUtils.smali",
             "setServerConfigurations(Landroid/content/Context;)V"),
            ("f/h.smali", "c(Landroid/content/Context;)Lf/j;"),
        }
        self.assertEqual({(r["path"], r["signature"]) for r in data["methods"]},
                         expected)
        self.assertEqual(4, len(data["methods"]))
        self.assertEqual({"global-cloud"},
                         {r["bucket"] for r in data["methods"]})
        forbidden = ("GmsObserver", "setUidState", "KillProcessController",
                     "ActiveStateController", "GCM_WORK", "GCM_CONN_ALARM",
                     "c2dm.intent.RECEIVE", "thermal", "PerfHook")
        rows = json.dumps(data["methods"])
        for marker in forbidden:
            self.assertNotIn(marker, rows)

    def test_rejects_unsafe_deltas(self):
        with self.assertRaises(ValueError):
            policy.validate_edits([{"at": 1, "remove": ["nop"],
                                    "insert": ["return-void"]},
                                   {"at": 1, "remove": ["nop"],
                                    "insert": ["return-void"]}])
        with self.assertRaises(ValueError):
            policy.validate_edits([{"at": 1, "remove": ["nop"],
                                    "insert": ["one\\ntwo"]}])

    def test_preserves_non_dex_apk_entries_and_signature_warning(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source, dex, target = (root / name for name in
                                   ("stock.apk", "new.dex", "modified.apk"))
            with zipfile.ZipFile(source, "w") as f:
                f.writestr("AndroidManifest.xml", b"manifest")
                f.writestr("classes.dex", b"dex\\nstock")
                f.writestr("META-INF/CERT.RSA", b"cert")
                f.writestr("assets/local.config", b"EU_original")
            dex.write_bytes(b"dex\\nglobal-cloud")
            report = meta.pack(source, dex, target)
            self.assertTrue(report["apk_resources_manifest_native_libraries_preserved"])
            self.assertFalse(report["cryptographic_signature_valid_after_modification"])
            self.assertFalse(report["apk_resigned"])
            self.assertEqual(3, report["non_dex_entries_verified"])
            self.assertEqual(b"EU_original",
                             zipfile.ZipFile(target).read("assets/local.config"))

    def test_applies_only_to_eu_a16(self):
        wrapper = (ROOT / "PowerKeeper.sh").read_text(encoding="utf-8")
        driver = (ROOT / "patch.sh").read_text(encoding="utf-8")
        self.assertIn('rom_source.txt', wrapper)
        self.assertIn('androidver.txt', wrapper)
        self.assertIn('sdkLevel.txt', wrapper)
        self.assertIn('versionCode=\'40200\'', wrapper.replace('"', "'"))
        self.assertIn('bash "$base/PowerKeeper.sh"', driver)
        self.assertNotIn('fcm_wakelock.py', driver)
        self.assertNotIn('fcm_greeze.py', driver)


if __name__ == "__main__":
    unittest.main()
