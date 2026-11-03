#!/usr/bin/env python3
"""HyperChanger patcher smoke tests."""
from pathlib import Path
import importlib.util
import re
import textwrap


repo = Path(__file__).resolve().parents[1]
base = repo / "bin/modfile/UpdateFile/InfoChanger"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


patcher = load("hyperchanger_patch", base / "patch.py")

injector = textwrap.dedent("""\
.class public final Lcom/android/keyguard/injector/KeyguardIndicationInjector;
.super Ljava/lang/Object;
.field public final mContext:Landroid/content/Context;
.field public final mKeyguardIndicationController:Lcom/android/systemui/statusbar/KeyguardIndicationController;
.method public constructor <init>(Landroid/content/Context;Lcom/android/systemui/statusbar/KeyguardIndicationController;Lcom/android/systemui/statusbar/phone/StatusBarKeyguardViewManager;Lcom/android/keyguard/KeyguardUpdateMonitor;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/android/keyguard/injector/KeyguardIndicationInjector;->mContext:Landroid/content/Context;
    iput-object p2, p0, Lcom/android/keyguard/injector/KeyguardIndicationInjector;->mKeyguardIndicationController:Lcom/android/systemui/statusbar/KeyguardIndicationController;
    return-void
.end method
""")
modified = patcher.patch_injector(injector)
assert modified.count("HyperChanger;->init(") == 1
assert modified.index("HyperChanger;->init(") < modified.index("return-void")
for invalid in (
    injector.replace("StatusBarKeyguardViewManager", "StatusBarViewManager"),
    injector.replace("iput-object p2", "iput-object p3"),
    injector.replace(".class public final", ".class public"),
):
    try:
        patcher.patch_injector(invalid)
    except ValueError:
        pass
    else:
        raise AssertionError("patcher accepted an incompatible injector")

helper = (base / "HyperChanger.smali").read_text(encoding="utf-8")
loop = (base / "HyperChangerLoop.smali").read_text(encoding="utf-8")
update = (base / "update.sh").read_text(encoding="utf-8")
expected = {
    "enabled", "show_power", "show_ampere", "show_voltage", "show_temp",
    "hide_original_text", "text_size", "update_mode", "update_interval",
}
present = set(re.findall(r'"hyperchanger_([a-z_]+)"', helper + loop))
assert expected == present, (expected, present)
assert "Settings$System" in helper
assert "SCREEN_OFF" in loop and "removeCallbacks" in loop
assert "isInteractive" in helper and "isKeyguardLocked" in helper
assert "WAKE_LOCK" not in helper + loop
assert "apksigner" not in update.lower()
assert "hyperchanger-v1" in update
assert not re.search(r"projectryu", helper + loop + update, re.I)

# Validate registers and branch targets without a third-party assembler.
for source in (helper, loop):
    methods = re.split(r"(?=^\.method\b)", source, flags=re.M)[1:]
    assert methods
    for method in methods:
        declaration = method.splitlines()[0]
        local_match = re.search(r"\.locals\s+(\d+)", method)
        assert local_match, declaration
        instructions = "\n".join(line.split("#", 1)[0] for line in method.splitlines())
        max_register = max(map(int, re.findall(r"\bv(\d+)\b", instructions)), default=-1)
        assert max_register < int(local_match.group(1)), declaration
        labels = set(re.findall(r"^\s*(:[\w\d_]+)\s*$", method, re.M))
        for line in method.splitlines():
            if re.match(r"\s*(if-\w+|goto(?:/\d+)?)\b", line):
                target = re.findall(r":[A-Za-z_0-9]+", line)
                assert target and target[-1] in labels, (declaration, line)

print("PASS: HyperChanger RYU hook, TNM contract and smali validation")
