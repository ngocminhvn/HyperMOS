#!/usr/bin/env python3
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

MOD_DIR = Path(__file__).resolve().parent
KAORIOS_DIR = MOD_DIR.parent
REPO_ROOT = KAORIOS_DIR.parents[2]


class NativePifTest(unittest.TestCase):
    def test_config_json_includes_native_pif_and_no_init_boot(self):
        config_path = KAORIOS_DIR / "config.json"
        self.assertTrue(config_path.is_file())
        with open(config_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        cfg = data["KaoriosToolbox"][0]
        self.assertIn("native_pif", cfg)
        self.assertTrue(cfg["native_pif"])
        self.assertNotIn("init_boot", cfg)

    def test_load_config_emits_native_pif_and_no_init_boot(self):
        loader = MOD_DIR / "load-config.py"
        config_path = KAORIOS_DIR / "config.json"
        res = subprocess.run(
            [sys.executable, str(loader), str(config_path)],
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertIn("KAORIOS_ENABLE_NATIVE_PIF=true", res.stdout)
        self.assertNotIn("KAORIOS_ENABLE_INIT_BOOT", res.stdout)

        res_pif = subprocess.run(
            [sys.executable, str(loader), str(config_path), "--get", "native_pif"],
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertEqual(res_pif.stdout.strip(), "true")

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

    def test_native_bridge_round_trip_and_jni_export(self):
        driver = KAORIOS_DIR / "app/classes.dex"
        baksmali = REPO_ROOT / "bin/apktool/baksmaliv2.jar"
        smali = REPO_ROOT / "bin/apktool/smaliv2.jar"
        patcher = MOD_DIR / "patch-native-pif-driver.py"
        bridge = MOD_DIR / "PifNative.smali"
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source"
            rebuilt = root / "rebuilt.dex"
            verified = root / "verified"
            subprocess.run(
                ["java", "-jar", str(baksmali), "d", "--api", "36", str(driver), "-o", str(source)],
                check=True, capture_output=True, text=True,
            )
            subprocess.run(
                [sys.executable, str(patcher), str(source), "--template", str(bridge)],
                check=True, capture_output=True, text=True,
            )
            subprocess.run(
                ["java", "-jar", str(smali), "a", "--api", "36", str(source), "-o", str(rebuilt)],
                check=True, capture_output=True, text=True,
            )
            subprocess.run(
                ["java", "-jar", str(baksmali), "d", "--api", "36", str(rebuilt), "-o", str(verified)],
                check=True, capture_output=True, text=True,
            )
            hook = (verified / "android/security/kaorios/KaoriosHook.smali").read_text()
            native = (verified / "android/security/ntmanager/PifNative.smali").read_text()
            self.assertIn("PifNative;->install(Landroid/content/Context;)V", hook)
            self.assertIn("nativeInstall([Ljava/lang/String;[Ljava/lang/String;)Z", native)
            self.assertIn("com.google.android.gms.unstable", native)

        exported = subprocess.run(
            ["readelf", "-Ws", str(KAORIOS_DIR / "bin/lib/arm64-v8a/libkaoripif.so")],
            check=True, capture_output=True, text=True,
        ).stdout
        self.assertIn("Java_android_security_ntmanager_PifNative_nativeInstall", exported)

    def test_init_boot_files_absent(self):
        self.assertFalse((KAORIOS_DIR / "bin/resetprop").exists())
        self.assertFalse((KAORIOS_DIR / "bin/init").exists())

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
