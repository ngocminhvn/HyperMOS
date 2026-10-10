#!/usr/bin/env python3
"""Fast, dependency-free regression tests for the RYU UID policy port.

This covers ABI decisions and refusal on changed stock layouts. It does not
claim that a patched APK runs on an Android device.
"""
import importlib.util
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "ryu_uid_policy_a16", HERE / "ryu_uid_policy_a16.py"
)
port = importlib.util.module_from_spec(spec)
spec.loader.exec_module(port)

PKG = "com/miui/powerkeeper/"
DESCRIPTORS = {
    "PowerKeeperInterface$l.smali": "PowerKeeperInterface$l",
    "AppRuleChecker$j.smali": "AppRuleChecker$j",
    "AppRuleChecker.smali": "AppRuleChecker",
    "AppRuleChecker$i.smali": "AppRuleChecker$i",
    "KillProcessController.smali": "controller/KillProcessController",
}


def source_text(name: str, *, with_method: bool) -> str:
    desc = "L" + PKG + DESCRIPTORS[name] + ";"
    header = ".class public " + desc + "\n.super Ljava/lang/Object;\n"
    if name == "PowerKeeperInterface$l.smali":
        method = (".method public abstract getUidPolicy(I)Landroid/os/Bundle;\n"
                  ".end method\n")
        return header + (method if with_method else "")
    if name == "AppRuleChecker$j.smali":
        header += (".field e:Lcom/miui/powerkeeper/AppRuleChecker$i;\n"
                   ".field f:Lcom/miui/powerkeeper/AppRuleChecker$i;\n")
        method = (".method public d()Landroid/os/Bundle;\n"
                  "    .locals 1\n"
                  '    const-string v0, "POLICY"\n'
                  '    const-string v0, "DELAY_MINUTE"\n'
                  '    const-string v0, "HOT_POLICY"\n'
                  '    const-string v0, "HOT_DELAY_MINUTE"\n'
                  "    return-object v0\n.end method\n")
        return header + (method if with_method else "")
    if name == "AppRuleChecker$i.smali":
        return header + ".field a:I\n.field b:J\n"
    if name == "AppRuleChecker.smali":
        header += (".method public q(I)Lcom/miui/powerkeeper/AppRuleChecker$j;\n"
                   ".locals 0\nreturn-object p0\n.end method\n")
        method = (".method public getUidPolicy(I)Landroid/os/Bundle;\n"
                  ".locals 2\n"
                  "invoke-direct {p0, p1}, Lcom/miui/powerkeeper/AppRuleChecker;->q(I)Lcom/miui/powerkeeper/AppRuleChecker$j;\n"
                  "move-result-object v0\n"
                  "invoke-virtual {v0}, Lcom/miui/powerkeeper/AppRuleChecker$j;->d()Landroid/os/Bundle;\n"
                  "move-result-object v0\nreturn-object v0\n.end method\n")
        return header + (method if with_method else "")
    if name == "KillProcessController.smali":
        return header + (
            ".method private shouldKillByCheckerPolicy(I)Z\n"
            ".locals 1\n"
            "invoke-interface {p0, p1}, Lcom/miui/powerkeeper/PowerKeeperInterface$l;->getUidPolicy(I)Landroid/os/Bundle;\n"
            "move-result-object v0\n"
            "const/4 v0, 0x0\nreturn v0\n.end method\n"
        )
    raise ValueError(name)


class PortTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="pk-uid-")
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        self.ryu = root / "ryu"
        self.stock = root / "stock"
        self.ryu.mkdir()
        self.stock.mkdir()
        self.report = root / "report.json"
        for name in DESCRIPTORS:
            (self.ryu / name).write_text(
                source_text(name, with_method=True), encoding="utf-8"
            )
            (self.stock / name).write_text(
                source_text(name, with_method=False), encoding="utf-8"
            )

    def test_three_missing_definitions_and_idempotency(self):
        port.run(self.ryu, self.stock, self.report)
        import json
        changes = json.loads(self.report.read_text())["changes"]
        self.assertEqual(set(changes), {
            "PowerKeeperInterface$l.smali",
            "AppRuleChecker$j.smali",
            "AppRuleChecker.smali",
        })
        self.assertEqual(set(changes.values()), {"added"})
        port.run(self.ryu, self.stock, self.report)
        changes = json.loads(self.report.read_text())["changes"]
        self.assertEqual(set(changes.values()), {"already_present"})

    def test_unknown_helper_policy_fields_refused(self):
        helper = self.stock / "AppRuleChecker$j.smali"
        helper.write_text(helper.read_text().replace(
            ".field f:Lcom/miui/powerkeeper/AppRuleChecker$i;\n", ""
        ))
        with self.assertRaisesRegex(ValueError, "missing expected field"):
            port.run(self.ryu, self.stock, self.report)

    def test_missing_controller_gate_refused(self):
        ctrl = self.stock / "KillProcessController.smali"
        ctrl.write_text(ctrl.read_text().replace(
            "shouldKillByCheckerPolicy", "unrelatedMethod"
        ))
        with self.assertRaisesRegex(ValueError, "not been ported"):
            port.run(self.ryu, self.stock, self.report)


if __name__ == "__main__":
    unittest.main()
