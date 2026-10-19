#!/usr/bin/env python3
"""Fixture regression checks for MiCTS static services.jar patch."""
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from patch_micts import patch, PatchError, KEY, GOOGLE

FIXTURE = """
.class public Lcom/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub;
.super Ljava/lang/Object;
.method public showSessionFromSession(Landroid/os/IBinder;Landroid/os/Bundle;ILjava/lang/String;)Z
    .locals 7
    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v0, v2}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;
    move-result-object v4
    invoke-virtual {p2, v3}, Landroid/os/Bundle;->containsKey(Ljava/lang/String;)Z
    move-result v5
    invoke-direct {p0, p2}, Lcom/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub;->getContextualSearchIntent(Landroid/os/Bundle;)Landroid/content/Intent;
    move-result-object v6
    const/4 v0, 0x0
    return v0
.end method
.method private getContextualSearchIntent(Landroid/os/Bundle;)Landroid/content/Intent;
    .locals 5
    invoke-virtual {v1, v0}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z
    move-result v0
    invoke-virtual {v4, v2}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;
    move-result-object v1
    return-object v1
.end method
""".lstrip()


class PatchTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        place = self.root / "smali_classes2" / "com/android/server/voiceinteraction"
        place.mkdir(parents=True)
        self.file = place / "VoiceInteractionManagerService$VoiceInteractionManagerServiceStub.smali"
        self.file.write_text(FIXTURE, encoding="utf-8")

    def test_two_methods_and_idempotent(self):
        p, changed_key, changed_pkg = patch(self.root)
        self.assertEqual(p, self.file)
        self.assertTrue(changed_key and changed_pkg)
        edited = self.file.read_text()
        self.assertIn(f'const-string v3, "{KEY}"', edited)
        self.assertIn(f'const-string v2, "{GOOGLE}"', edited)
        self.assertEqual(edited.count("HyperMOS-MiCTS:"), 2)
        _, k, p = patch(self.root)
        self.assertFalse(k or p)
        self.assertEqual(edited, self.file.read_text())

    def test_fail_closed_on_missing_intent_path(self):
        self.file.write_text(FIXTURE.replace("getContextualSearchIntent", "otherMethod"))
        with self.assertRaises(PatchError):
            patch(self.root)

    def test_fail_closed_on_ambiguous_target(self):
        self.file.write_text(FIXTURE.replace(
            "    move-result-object v3\n",
            "    move-result-object v3\n"
            "    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;\n"
            "    move-result-object v3\n",
        ))
        with self.assertRaises(PatchError):
            patch(self.root)


if __name__ == "__main__":
    unittest.main()
