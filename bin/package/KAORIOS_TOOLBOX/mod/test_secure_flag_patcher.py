#!/usr/bin/env python3
import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("patch-secure-flag.py")
SPEC = importlib.util.spec_from_file_location("secure_flag_patcher", MODULE_PATH)
PATCHER = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = PATCHER
SPEC.loader.exec_module(PATCHER)


class SecureFlagPatcherTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def write(self, relative: str, body: str) -> Path:
        path = self.root / "classes2.dex.out" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, encoding="utf-8")
        return path

    def test_patch_and_verify(self):
        policy = self.write(
            "com/android/server/devicepolicy/DevicePolicyCacheImpl.smali",
            ".class public Lcom/android/server/devicepolicy/DevicePolicyCacheImpl;\n"
            ".method public isScreenCaptureAllowed(I)Z\n"
            "    .locals 1\n\n    const/4 v0, 0x0\n    return v0\n.end method\n",
        )
        window = self.write(
            "com/android/server/wm/WindowState.smali",
            ".class public Lcom/android/server/wm/WindowState;\n"
            ".method isSecureLocked()Z\n    .registers 2\n\n    const/4 v0, 0x1\n    return v0\n.end method\n"
            ".method setSecureLocked(Z)V\n    .locals 1\n\n    return-void\n.end method\n",
        )
        self.assertEqual(PATCHER.run(self.root, False), 0)
        self.assertEqual(PATCHER.run(self.root, True), 0)
        self.assertIn("const/4 v0, 0x1", policy.read_text(encoding="utf-8"))
        self.assertIn("const/4 v0, 0x0", window.read_text(encoding="utf-8"))
        self.assertNotIn("KaoriosHook", policy.read_text(encoding="utf-8"))
        self.assertNotIn("KaoriosHook", window.read_text(encoding="utf-8"))

    def test_allocates_local_register_for_static_return(self):
        path = self.write(
            "com/android/server/devicepolicy/DevicePolicyCacheImpl.smali",
            ".class public Lcom/android/server/devicepolicy/DevicePolicyCacheImpl;\n"
            ".method public isScreenCaptureAllowed(I)Z\n"
            "    .registers 2\n\n    const/4 p1, 0x1\n    return p1\n.end method\n",
        )
        self.assertTrue(PATCHER.patch_target(path, PATCHER.TARGETS[0], False))
        self.assertIn(".registers 3", path.read_text(encoding="utf-8"))
        self.assertFalse(PATCHER.patch_target(path, PATCHER.TARGETS[0], True))

    def test_verify_ignores_roundtrip_debug_directives(self):
        path = self.write(
            "com/android/server/devicepolicy/DevicePolicyCacheImpl.smali",
            ".class public Lcom/android/server/devicepolicy/DevicePolicyCacheImpl;\n"
            ".method public isScreenCaptureAllowed(I)Z\n"
            "    .locals 1\n\n"
            "    .line 42\n"
            "    const/4 v0, 0x1\n"
            "    .line 43\n"
            "    return v0\n"
            ".end method\n",
        )
        self.assertFalse(PATCHER.patch_target(path, PATCHER.TARGETS[0], True))

        body = path.read_text(encoding="utf-8").replace(
            "    .line 43\n", "    invoke-static {}, Ljava/lang/System;->gc()V\n"
        )
        path.write_text(body, encoding="utf-8")
        with self.assertRaises(PATCHER.PatchError):
            PATCHER.patch_target(path, PATCHER.TARGETS[0], True)

    def test_window_state_animator_fallback(self):
        self.write(
            "com/android/server/devicepolicy/DevicePolicyCacheImpl.smali",
            ".class public Lcom/android/server/devicepolicy/DevicePolicyCacheImpl;\n"
            ".method public isScreenCaptureAllowed(I)Z\n"
            "    .locals 1\n\n    const/4 v0, 0x0\n    return v0\n.end method\n",
        )
        animator = self.write(
            "com/android/server/wm/WindowStateAnimator.smali",
            ".class public Lcom/android/server/wm/WindowStateAnimator;\n"
            ".method isSecureLocked()Z\n    .locals 1\n\n    const/4 v0, 0x1\n    return v0\n.end method\n",
        )
        self.assertEqual(PATCHER.run(self.root, False), 0)
        self.assertIn("const/4 v0, 0x0", animator.read_text(encoding="utf-8"))
        self.assertEqual(PATCHER.run(self.root, True), 0)

    def test_xiaomi_capture_gate_is_statically_bypassed(self):
        miui = self.write(
            "com/android/server/wm/WindowManagerServiceImpl.smali",
            ".class public Lcom/android/server/wm/WindowManagerServiceImpl;\n"
            ".method public notAllowCaptureDisplay(Lcom/android/server/wm/RootWindowContainer;I)Z\n"
            "    .registers 9\n\n    const/4 v0, 0x1\n    return v0\n.end method\n",
        )
        self.assertEqual(PATCHER.run(self.root, False, "miui-services"), 0)
        self.assertEqual(PATCHER.run(self.root, True, "miui-services"), 0)
        body = miui.read_text(encoding="utf-8")
        self.assertIn("const/4 v0, 0x0", body)
        self.assertNotIn("KaoriosHook", body)
        self.assertNotIn(":kaorios_secure_stock", body)


if __name__ == "__main__":
    unittest.main()
