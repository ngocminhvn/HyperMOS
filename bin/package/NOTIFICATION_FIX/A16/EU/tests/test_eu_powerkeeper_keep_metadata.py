"""Regression checks: preserve original EU PowerKeeper metadata, no signing."""
import importlib.util
import tempfile
import unittest
import warnings
import zipfile
from pathlib import Path

SOURCE = Path(__file__).resolve().parent.parent / "eu_powerkeeper_keep_metadata.py"
spec = importlib.util.spec_from_file_location("eu_powerkeeper_keep_metadata", SOURCE)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

OLD_DEX = b"dex\n035\x00" + bytes(range(32))
NEW_DEX = b"dex\n035\x00" + bytes(reversed(range(32)))

def sample(apk, has_meta=True):
    with zipfile.ZipFile(apk, "w") as z:
        z.comment = b"original eu zip comment"
        names = {
            "AndroidManifest.xml": b"Original manifest with eu metadata",
            "classes.dex": OLD_DEX,
            "resources.arsc": b"\x00\x01resources",
            "assets/config.json": b'{"policy":"eu"}',
            "lib/arm64-v8a/libnative.so": b"\x7fELF00",
        }
        if has_meta:
            names.update({
                "META-INF/MANIFEST.MF": b"Manifest-Version: 1.0\n",
                "META-INF/CERT.SF": b"EU original SF bytes",
                "META-INF/CERT.RSA": b"EU original RSA bytes",
            })
        for name, raw in names.items():
            entry = zipfile.ZipInfo(name, (2008, 1, 1, 0, 0, 0))
            entry.compress_type = zipfile.ZIP_DEFLATED
            entry.external_attr = 0o644 << 16
            z.writestr(entry, raw)

class PowerKeeperMetadataTests(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.root = Path(self.folder.name)
        self.base = self.root / "stock.apk"
        self.final = self.root / "patched.apk"
        self.dex = self.root / "classes.dex"
        self.dex.write_bytes(NEW_DEX)

    def tearDown(self):
        self.folder.cleanup()

    def test_preserve_non_dex_and_meta_exactly(self):
        sample(self.base)
        result = module.pack(self.base, self.dex, self.final)
        self.assertEqual(result["non_dex_entries_verified"], 7)
        self.assertEqual(len(result["meta_inf_entries_preserved"]), 3)
        self.assertFalse(result["apk_resigned"])
        self.assertFalse(result["cryptographic_signature_valid_after_modification"])
        self.assertEqual(result["patched_dex_sha256"], module.digest(NEW_DEX))
        self.assertEqual(module.verify_preservation(self.base, self.final, NEW_DEX)["apk_resigned"], False)
        with zipfile.ZipFile(self.base) as a, zipfile.ZipFile(self.final) as b:
            self.assertEqual(a.comment, b.comment)
            self.assertEqual(a.namelist(), b.namelist())
            for name in a.namelist():
                if name == "classes.dex":
                    self.assertNotEqual(a.read(name), b.read(name))
                else:
                    self.assertEqual(a.read(name), b.read(name))

    def test_apk_without_meta_inf_is_accepted(self):
        sample(self.base, has_meta=False)
        result = module.pack(self.base, self.dex, self.final)
        self.assertEqual(result["meta_inf_entries_preserved"], [])
        self.assertFalse(result["apk_resigned"])

    def test_modified_manifest_is_detected(self):
        sample(self.base)
        module.pack(self.base, self.dex, self.final)
        tmp = self.root / "bad.apk"
        with zipfile.ZipFile(self.final) as source, zipfile.ZipFile(tmp, "w") as dest:
            dest.comment = source.comment
            for name in source.namelist():
                data = (b"modified manifest" if name == "AndroidManifest.xml"
                        else source.read(name))
                dest.writestr(name, data)
        with self.assertRaisesRegex(ValueError, "Non-DEX APK member changed"):
            module.verify_preservation(self.base, tmp, NEW_DEX)

    def test_reject_unmodified_dex(self):
        sample(self.base)
        self.dex.write_bytes(OLD_DEX)
        with self.assertRaisesRegex(ValueError, "was not actually changed"):
            module.pack(self.base, self.dex, self.final)

    def test_reject_duplicate_zip_entries(self):
        sample(self.base)
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            with zipfile.ZipFile(self.base, "a") as z:
                z.writestr("META-INF/CERT.SF", b"duplicate")
        with self.assertRaisesRegex(ValueError, "duplicate ZIP members"):
            module.pack(self.base, self.dex, self.final)

if __name__ == "__main__":
    unittest.main()
