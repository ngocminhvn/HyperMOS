#!/usr/bin/env python3
import importlib.util
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path


SCRIPT = Path(__file__).with_name("securitycenter_countdown.py")
SPEC = importlib.util.spec_from_file_location("securitycenter_countdown", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


FRAGMENT = """.class public Lcom/miui/permcenter/privacymanager/InterceptPermissionFragment;
.method protected g0()I
    .locals 1
    const/16 v0, 0xa
    return v0
.end method
.method public j0()I
    .locals 1
    const v0, 0x7f0e0001
    return v0
.end method
"""

INPUT = """.class public Lcom/miui/permcenter/install/AdbInputApplyActivity;
.method protected onCreate()V
    .locals 4
    const/16 v0, 0x64
    const-wide/16 v1, 0x3e8
    invoke-virtual {p1, v0, v1, v2}, Landroid/os/Handler;->sendEmptyMessageDelayed(IJ)Z
    return-void
.end method
"""

INPUT_HANDLER = """.class Lcom/miui/permcenter/install/AdbInputApplyActivity$a;
.method public handleMessage()V
    .locals 4
    const/16 v0, 0x64
    const-wide/16 v1, 0x3e8
    invoke-virtual {p0, v0, v1, v2}, Landroid/os/Handler;->sendEmptyMessageDelayed(IJ)Z
    return-void
.end method
"""

INSTALL = """.class public Lcom/miui/permcenter/install/AdbInstallActivity;
.method protected onDialogCreated()V
    .locals 4
    const/16 v0, 0xa
    const-wide/16 v1, 0x640
    invoke-virtual {p1, v0, v1, v2}, Landroid/os/Handler;->sendEmptyMessageDelayed(IJ)Z
    return-void
.end method
"""

INSTALL_HANDLER = """.class Lcom/miui/permcenter/install/AdbInstallActivity$a;
.method public handleMessage()V
    .locals 4
    const/16 v1, 0xa
    const-wide/16 v2, 0x3e8
    invoke-virtual {p0, v1, v2, v3}, Landroid/os/Handler;->sendEmptyMessageDelayed(IJ)Z
    return-void
.end method
"""


class SecurityCenterCountdownTest(unittest.TestCase):
    def make_tree(self, root: Path) -> None:
        base = root / "smali/classes3/com/miui/permcenter"
        files = {
            base / "privacymanager/InterceptPermissionFragment.smali": FRAGMENT,
            base / "install/AdbInputApplyActivity.smali": INPUT,
            base / "install/AdbInputApplyActivity$a.smali": INPUT_HANDLER,
            base / "install/AdbInstallActivity.smali": INSTALL,
            base / "install/AdbInstallActivity$a.smali": INSTALL_HANDLER,
        }
        for path, text in files.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8")

    def test_apply_and_verify(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            self.make_tree(root)
            report = MODULE.process(root, apply=True)
            self.assertEqual(report.fragment_old_seconds, 10)
            self.assertEqual(report.adb_input_delay_sites, 2)
            self.assertEqual(report.adb_install_delay_sites, 2)
            MODULE.process(root, apply=False)
            combined = "\n".join(path.read_text(encoding="utf-8") for path in root.rglob("*.smali"))
            self.assertNotIn("0x3e8", combined)
            self.assertNotIn("0x640", combined)

    def test_rejects_incomplete_activity_coverage(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            self.make_tree(root)
            (root / "smali/classes3/com/miui/permcenter/install/AdbInstallActivity$a.smali").unlink()
            with self.assertRaisesRegex(ValueError, "AdbInstallActivity countdown coverage"):
                MODULE.process(root, apply=True)

    def test_compare_apks_allows_only_dex_changes(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            base = root / "base.apk"
            patched = root / "patched.apk"
            for path, dex in ((base, b"old-dex"), (patched, b"new-dex")):
                with zipfile.ZipFile(path, "w") as archive:
                    archive.writestr("classes.dex", dex)
                    archive.writestr("resources.arsc", b"same-resource")
            result = MODULE.compare_apks(base, patched)
            self.assertEqual(result["changed_dex_entries"], ["classes.dex"])
            with zipfile.ZipFile(patched, "w") as archive:
                archive.writestr("classes.dex", b"new-dex")
                archive.writestr("resources.arsc", b"changed-resource")
            with self.assertRaisesRegex(ValueError, "Non-DEX APK content changed"):
                MODULE.compare_apks(base, patched)


if __name__ == "__main__":
    unittest.main()
