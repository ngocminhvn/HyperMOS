#!/usr/bin/env python3
"""Source-only hook regression checks; the real EU JAR still needs a build test."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

PATCH = Path(__file__).with_name("patch.py")
VIMS = "com/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub.smali"
CSMS = "com/android/server/contextualsearch/ContextualSearchManagerService.smali"
BRIDGE = "com/android/server/micts/MiCTSBridge.smali"
VIMS_BODY = """.class public Ltest/VIMS;
.super Ljava/lang/Object;
.method public showSessionFromSession(Landroid/os/IBinder;Landroid/os/Bundle;ILjava/lang/String;)Z
    .locals 0
    const/4 p1, 0x0
    return p1
.end method
"""
CSMS_BODY = """.class public Ltest/CSMS;
.super Ljava/lang/Object;
.method private enforcePermission(Ljava/lang/String;)V
    .locals 0
    return-void
.end method
"""

class PatchTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "smali"
        self.dex = self.root / "classes.dex.out"
        for rel, src in ((VIMS, VIMS_BODY), (CSMS, CSMS_BODY)):
            p = self.dex / rel
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(src)

    def patch(self):
        return subprocess.run(
            [sys.executable, str(PATCH), "--root", str(self.root)],
            capture_output=True, text=True, check=False
        )

    def test_only_micts_uses_csservice_no_vis_fallback(self):
        result = self.patch()
        self.assertEqual(result.returncode, 0, result.stderr)
        vis = (self.dex / VIMS).read_text()
        cs = (self.dex / CSMS).read_text()
        bridge = (self.dex / BRIDGE).read_text()
        self.assertIn("->isRequest(Landroid/os/Bundle;)Z", vis)
        self.assertIn("->start(Landroid/os/Bundle;)Z", vis)
        self.assertRegex(vis, r"->start\(Landroid/os/Bundle;\)Z\n\s+move-result v0\n\s+return v0")
        self.assertIn(":micts_original_vis", vis)  # only for non-MiCTS calls
        self.assertIn("->isActive()Z", cs)
        self.assertIn("getPackagesForUid", bridge)
        self.assertIn("CSService invocation failed (no VIS fallback)", bridge)
        self.assertIn("restoreCallingIdentity(J)V", bridge)
        self.assertIn("Landroid/app/contextualsearch/IContextualSearchManager;", bridge)
        self.assertNotIn("hasSigningCertificate", bridge)

    def test_system_as_root_services_path_matches_kaorios(self):
        root = PATCH.parents[3]
        updater = (root / "bin/package/MICTS/update.sh").read_text()
        kaorios = (root / "bin/package/KAORIOS_TOOLBOX/patch.sh").read_text()
        jar_path = "build/baserom/images/system/system/framework/services.jar"
        self.assertIn(jar_path, updater)
        self.assertIn(jar_path, kaorios)
        self.assertNotIn('images/system/framework/services.jar"', updater)

    def test_missing_method_fails_before_writing(self):
        original = (self.dex / VIMS).read_text()
        p = self.dex / CSMS
        p.write_text(CSMS_BODY.replace("enforcePermission", "noSuchMethod"))
        result = self.patch()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("FAST-FAIL", result.stderr)
        self.assertEqual((self.dex / VIMS).read_text(), original)
        self.assertFalse((self.dex / BRIDGE).exists())

    def test_duplicate_patch_fails(self):
        self.assertEqual(self.patch().returncode, 0)
        result = self.patch()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("already patched", result.stderr)

if __name__ == "__main__":
    unittest.main()
