"""Regression tests for the active Xiaomi.eu Android 16 RYU policy."""
import importlib.util
from pathlib import Path
import tempfile
import unittest


BASE = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("ryu_policy", BASE / "ryu_policy.py")
RYU = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RYU)


class RyuPolicyTest(unittest.TestCase):
    def test_eu_dispatch_uses_function_available_before_corepatch_helper(self):
        dispatcher = (BASE.parent / "patch.sh").read_text(encoding="utf-8")
        eu_branch = dispatcher.split(
            'if [[ "$rom_source" == xiaomi_eu ]]; then', 1
        )[1].split("fi", 1)[0]
        self.assertIn('info "[EU A16]', eu_branch)
        self.assertNotIn('log "[EU A16]', eu_branch)

    def test_manifest_contains_all_three_security_deltas(self):
        manifest = RYU.load(BASE / "ryu_policy.json")
        rows = manifest["groups"]["miui-services"]
        self.assertEqual(19, len(rows))
        selected = {(row["class"], row["signature"]): row for row in rows}
        self.assertFalse(any(row["class"] == "com/android/server/job/JobServiceContextImpl.smali" for row in rows))
        ams = "com/android/server/am/ActivityManagerServiceImpl.smali"
        compatibility_signature = (
            "checkRunningCompatibility(Landroid/app/IApplicationThread;"
            "Landroid/content/pm/ActivityInfo;Landroid/content/Intent;I"
            "Ljava/lang/String;)Z"
        )
        self.assertEqual(["p2"], selected[(ams, compatibility_signature)]["registers"])
        pms = "com/android/server/pm/PackageManagerServiceImpl.smali"
        can_update = selected[(pms, "canBeUpdate(Ljava/lang/String;)V")]
        self.assertEqual("ryu_return_void", can_update["operation"])
        self.assertNotIn("anchor", can_update)
        isolation_signature = (
            "verifyIsolationViolation("
            "Lcom/android/internal/pm/parsing/pkg/ParsedPackage;"
            "Lcom/android/server/pm/InstallSource;)V"
        )
        self.assertEqual(
            "ryu_return_void",
            selected[(pms, isolation_signature)]["operation"],
        )
        self.assertNotIn("anchor", selected[(pms, isolation_signature)])
        helper = "miui/app/ActivitySecurityHelper.smali"
        malware_signature = (
            "getMalwareBlockingIntent(Ljava/lang/String;Landroid/content/Intent;"
            "ZZII)Landroid/content/Intent;"
        )
        malware = selected[(helper, malware_signature)]
        self.assertEqual(("force_international", ["v1"], True),
                         (malware["operation"], malware["registers"], malware["value"]))

    def test_return_void_patch_and_verify(self):
        row = {"operation": "ryu_return_void"}
        original = """.method private canBeUpdate(Ljava/lang/String;)V
    .locals 2
    invoke-static {}, Lvendor/layout/Independent;->check()V
    return-void
.end method"""
        patched, status = RYU.check_policy(row, original, False)
        self.assertEqual("patched", status)
        self.assertTrue(RYU.is_return_void_stub(patched))
        self.assertNotIn("Lvendor/layout/Independent;", patched)
        verified, status = RYU.check_policy(row, patched, True)
        self.assertEqual((patched, "verified"), (verified, status))

    def test_existing_corepatch_stub_is_idempotent(self):
        row = {"operation": "ryu_return_void"}
        stub = """.method public verifyIsolationViolation(Ljava/lang/Object;)V
    .registers 8
    return-void
.end method"""
        self.assertEqual((stub, "already_patched"), RYU.check_policy(row, stub, False))
        self.assertEqual((stub, "verified"), RYU.check_policy(row, stub, True))

    def test_return_void_verify_rejects_non_minimal_body(self):
        row = {"operation": "ryu_return_void"}
        body = """.method private canBeUpdate(Ljava/lang/String;)V
    .locals 0
    return-void
    nop
.end method"""
        with self.assertRaisesRegex(ValueError, "minimal"):
            RYU.check_policy(row, body, True)

    def test_complete_manifest_patch_then_verify(self):
        manifest = RYU.load(BASE / "ryu_policy.json")
        by_class = {}
        for row in manifest["groups"]["miui-services"]:
            header = ".method public " + row["signature"]
            if row["operation"] == "force_international":
                instructions = [
                    "    sget-boolean %s, %s" % (reg, RYU.INTERNATIONAL)
                    for reg in row["registers"]
                ]
            elif row["operation"] == "force_cn_model_false":
                instructions = ["    sput-boolean v0, " + RYU.GREEZE]
            else:
                instructions = [
                    "    invoke-static {}, Lvendor/layout/Independent;->check()V"
                ]
            method = "\n".join([header, "    .locals 16", *instructions,
                                "    return-void", ".end method"])
            by_class.setdefault(row["class"], []).append(method)

        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for rel, methods in by_class.items():
                path = root / "smali" / rel
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("\n\n".join(methods) + "\n", encoding="utf-8")
            patched = RYU.run(root, manifest, "miui-services", False, None)
            self.assertEqual(19, len(patched["modified"]))
            verified = RYU.run(root, manifest, "miui-services", True, None)
            self.assertEqual([], verified["modified"])


if __name__ == "__main__":
    unittest.main()
