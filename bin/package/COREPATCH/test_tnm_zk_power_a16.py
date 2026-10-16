#!/usr/bin/env python3
"""Fast isolated regression for the twelve ZKOS HAOTIAN policy deltas.

The fixture tests transformation logic; a full ROM build is still required.
"""
import importlib.util
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "tnm_zk_power_a16", ROOT / "tnm_zk_power_a16.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

STOCK_GATE = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"


def body(signature, instructions):
    return (f".method public static {signature}\n"
            "    .locals 1\n"
            + "".join(f"    {line}\n" for line in instructions)
            + "    return-void\n.end method\n")


def check():
    with tempfile.TemporaryDirectory(prefix="tnm-zk-jar-") as tmp:
        root = Path(tmp)
        unrelated = root / "smali/com/example/Unrelated.smali"
        unrelated.parent.mkdir(parents=True)
        unrelated.write_text(body("test()V", ["const/4 v0, 0x1"]))
        original = unrelated.read_bytes()

        total = 0
        for suffix, signatures in module.ZK_METHODS.items():
            target = root / "smali" / suffix
            target.parent.mkdir(parents=True, exist_ok=True)
            methods = []
            for signature in signatures:
                methods.append(body(signature, [
                    f"sget-boolean v0, {STOCK_GATE}",
                    "if-eqz v0, :gate_false",
                    ":gate_false",
                ]))
                total += 1
            if target.name == "NotificationManagerServiceImpl.smali":
                methods.append(body("<clinit>()V", [
                    f"sget-boolean v0, {STOCK_GATE}",
                    ".line 73",
                    "sput-boolean v0, Lcom/android/server/notification/"
                    "NotificationManagerServiceImpl;->IS_INTERNATIONAL_BUILD:Z",
                ]))
            target.write_text("\n".join(methods), encoding="utf-8")

        policy = root / "smali/com/miui/server/greeze/PolicyManager.smali"
        policy.parent.mkdir(parents=True)
        policy.write_text(body("<clinit>()V", [
            'const-string v0, "CN"', "invoke-virtual {v0}, "
            "Ljava/lang/String;->toString()Ljava/lang/String;",
        ]), encoding="utf-8")

        assert total == 10, total
        module.run(root)
        compiled = "\n".join(p.read_text() for p in root.rglob("*.smali"))
        assert compiled.count(module.ZK_FIELD) == 10
        assert "->IS_INTERNATIONAL_BUILD:Z" not in compiled
        assert 'const-string v0, "TNM"' in policy.read_text()
        assert "sput-boolean v0, Lcom/android/server/notification/" not in compiled
        assert (root / "smali/com/android/tnm/TNMBuild.smali").is_file()
        assert unrelated.read_bytes() == original, "Unrelated class modified"

        before = {str(p): p.read_bytes() for p in root.rglob("*.smali")}
        module.run(root)
        after = {str(p): p.read_bytes() for p in root.rglob("*.smali")}
        assert before == after, "Port is not idempotent"
        print("PASS: 10 ZK build fields, NotificationManager initializer, "
              "Greeze TNM region, unrelated class intact, idempotent")


if __name__ == "__main__":
    check()
