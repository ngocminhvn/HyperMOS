#!/usr/bin/env python3
import json
from pathlib import Path
import subprocess
import sys
import unittest

MOD_DIR = Path(__file__).resolve().parent
KAORIOS_DIR = MOD_DIR.parent
REPO_ROOT = KAORIOS_DIR.parents[2]


class NativePifAndInitTest(unittest.TestCase):
    def test_config_json_includes_native_pif_and_init_boot(self):
        config_path = KAORIOS_DIR / "config.json"
        self.assertTrue(config_path.is_file())
        with open(config_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        cfg = data["KaoriosToolbox"][0]
        self.assertIn("native_pif", cfg)
        self.assertIn("init_boot", cfg)
        self.assertTrue(cfg["native_pif"])
        self.assertTrue(cfg["init_boot"])

    def test_load_config_emits_native_pif_and_init_boot(self):
        loader = MOD_DIR / "load-config.py"
        config_path = KAORIOS_DIR / "config.json"
        res = subprocess.run(
            [sys.executable, str(loader), str(config_path)],
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertIn("KAORIOS_ENABLE_NATIVE_PIF=true", res.stdout)
        self.assertIn("KAORIOS_ENABLE_INIT_BOOT=true", res.stdout)

        res_pif = subprocess.run(
            [sys.executable, str(loader), str(config_path), "--get", "native_pif"],
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertEqual(res_pif.stdout.strip(), "true")

        res_init = subprocess.run(
            [sys.executable, str(loader), str(config_path), "--get", "init_boot"],
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertEqual(res_init.stdout.strip(), "true")

    def test_native_libraries_present(self):
        lib_dir = KAORIOS_DIR / "bin/lib"
        self.assertTrue(lib_dir.is_dir())

        for arch in ("arm64-v8a", "armeabi-v7a"):
            arch_dir = lib_dir / arch
            self.assertTrue(arch_dir.is_dir())
            for lib_name in ("libkaoripif.so", "libkaoriospif.so", "libshadowhook_kaorios.so"):
                target = arch_dir / lib_name
                self.assertTrue(target.is_file(), f"Missing {target}")
                self.assertGreater(target.stat().st_size, 0)
                # Ensure ELF header
                with open(target, "rb") as f:
                    self.assertEqual(f.read(4), b"\x7fELF")

    def test_kaorihelper_binary_present_and_executable(self):
        helper = KAORIOS_DIR / "bin/resetprop/kaorihelper"
        self.assertTrue(helper.is_file())
        self.assertGreater(helper.stat().st_size, 0)
        with open(helper, "rb") as f:
            header = f.read(5)
            # ELF 64-bit ARM64
            self.assertEqual(header[:4], b"\x7fELF")
            self.assertEqual(header[4], 2)  # 64-bit

    def test_init_kaorios_rc_contents(self):
        rc = KAORIOS_DIR / "bin/init/init.kaorios.rc"
        self.assertTrue(rc.is_file())
        text = rc.read_text(encoding="utf-8")
        self.assertIn("on post-fs-data", text)
        self.assertIn("/system/bin/kaorihelper --init ro.boot.vbmeta.device_state locked", text)
        self.assertIn("/system/bin/kaorihelper --init ro.boot.verifiedbootstate green", text)
        self.assertIn("/system/bin/kaorihelper --init ro.boot.flash.locked 1", text)
        self.assertIn("/system/bin/kaorihelper --init ro.debuggable 0", text)
        self.assertIn("/system/bin/kaorihelper --init ro.secure 1", text)
        self.assertIn("/system/bin/kaorihelper --init ro.build.type user", text)
        self.assertIn("/system/bin/kaorihelper --init ro.secureboot.lockstate locked", text)

    def test_fix_selinux_maps_system_lib_file(self):
        import importlib.util
        spec = importlib.util.spec_from_file_location("fix_selinux", REPO_ROOT / "bin/fix_selinux.py")
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        import re

        paths_to_test = [
            "/system/lib64/libkaoripif.so",
            "/system/system/lib64/libkaoripif.so",
            "/system/lib/libkaoripif.so",
            "/system/system/lib/libkaoripif.so",
        ]
        for p in paths_to_test:
            ctx = next((c for pat, c in mod.MAP_RULE_A.items() if re.search(pat, p)), None)
            self.assertEqual(ctx, "u:object_r:system_lib_file:s0", f"Failed for {p}")


if __name__ == "__main__":
    unittest.main()
