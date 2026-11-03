#!/usr/bin/env python3
"""HyperChanger patcher smoke tests. Run: python3 tests/test_hyperchanger.py"""
from pathlib import Path
import importlib.util
import re
import tempfile
import textwrap

repo = Path(__file__).resolve().parents[1]
base = repo / "bin/modfile/UpdateFile/ZZ_HyperChanger"
spec = importlib.util.spec_from_file_location("hyperchanger_patch", base / "patch.py")
assert spec and spec.loader
patcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(patcher)

hint = textwrap.dedent("""\
.class public Lcom/miui/charge/ChargeUtils;
.super Ljava/lang/Object;
.method public static getChargingHintText(IZLandroid/content/Context;)Ljava/lang/String;
    .locals 1
    const-string v0, "Charging"
    return-object v0
.end method
""")
view = textwrap.dedent("""\
.class public Lcom/android/systemui/statusbar/phone/KeyguardIndicationTextView;
.super Landroid/widget/TextView;
.method public constructor <init>(Landroid/content/Context;)V
    .locals 0
    invoke-direct {p0, p1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    return-void
.end method
.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;)V
    .locals 0
    invoke-direct {p0, p1}, Lcom/android/systemui/statusbar/phone/KeyguardIndicationTextView;-><init>(Landroid/content/Context;)V
    return-void
.end method
""")
modified_hint = patcher.patch_hint(hint)
modified_view = patcher.patch_view(view)
assert modified_hint.count("->render(") == 1
assert "invoke-static {p2, v0}" in modified_hint
assert modified_view.count("->bind(") == 1, "delegating constructors must not bind twice"
assert modified_view.count("return-void") == 2

# Nonmatching Xiaomi variants MUST NOT be patched by guesses.
for invalid in (
    hint.replace("getChargingHintText", "getHint"),
    hint.replace("Landroid/content/Context;", "Ljava/lang/String;"),
):
    try:
        patcher.patch_hint(invalid)
    except ValueError:
        pass
    else:
        raise AssertionError("patcher accepted incompatible charging signature")
try:
    patcher.patch_view(view.replace("Landroid/widget/TextView;", "Landroid/view/View;"))
except ValueError:
    pass
else:
    raise AssertionError("patcher accepted a non-TextView superclass")

# The settings contract is uniform and sampling is not a persistent service.
helper = (base / "HyperChanger.smali").read_text(encoding="utf-8")
loop = (base / "HyperChangerLoop.smali").read_text(encoding="utf-8")
update = (base / "update.sh").read_text(encoding="utf-8")
expected = {
    "enabled", "show_power", "show_ampere", "show_voltage", "show_temp",
    "hide_original_text", "text_size", "update_mode", "update_interval",
}
present = set(re.findall(r'"hyperchanger_([a-z_]+)"', helper + loop))
assert expected == present, (expected, present)
assert "SCREEN_OFF" in loop and "removeCallbacks" in loop
assert "onViewDetachedFromWindow" in loop and "unregisterReceiver" in loop
assert "isInteractive" in helper and "isKeyguardLocked" in helper
assert "WAKE_LOCK" not in helper + loop
assert "HyperChanger: unsupported SystemUI signatures; leave original APK intact" in update
assert "hyperchanger-v1" in update
assert "rm -f \"$marker\"" in update
assert not re.search(r"ryu", helper + loop + update + (base / "patch.py").read_text(), re.I)

# Check method register declarations and branch targets without requiring a
# third-party smali assembler in the lightweight test environment.
for source in (helper, loop):
    methods = re.split(r"(?=^\.method\b)", source, flags=re.M)[1:]
    assert methods, "missing methods"
    for method in methods:
        declaration = method.splitlines()[0]
        num_local = re.search(r"\.locals\s+(\d+)", method)
        assert num_local, declaration
        instructions = "\n".join(line.split("#", 1)[0] for line in method.splitlines())
        max_register = max(map(int, re.findall(r"\bv(\d+)\b", instructions)), default=-1)
        assert max_register < int(num_local.group(1)), declaration
        labels = set(re.findall(r"^\s*(:[\w\d_]+)\s*$", method, re.M))
        for line in method.splitlines():
            if re.match(r"\s*(if-\w+|goto(?:/\d+)?)\b", line):
                target = re.findall(r":[A-Za-z_0-9]+", line)
                assert target and target[-1] in labels, (declaration, line)
print("PASS: HyperChanger compatible hooks, settings and wake-only lifecycle")
