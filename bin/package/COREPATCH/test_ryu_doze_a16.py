#!/usr/bin/env python3
"""Fail-closed tests for RYU A16 low-power-Doze field parity."""
import importlib.util
import tempfile
from pathlib import Path

source = Path(__file__).with_name("ryu_doze_a16.py")
spec = importlib.util.spec_from_file_location("ryu_doze_a16", source)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

fixture = """
.class public Lcom/android/server/DeviceIdleControllerStubImpl;
.super Ljava/lang/Object;
.field private static mIsLowPowerDozeDevice:Z

.method static constructor <clinit>()V
    .registers 1
    sget-boolean v0, Lmiui/os/Build;->IS_GLOBAL_BUILD:Z
    if-nez v0, :doze_false
    const/4 v0, 0x1
    goto :doze_write
:doze_false
    const/4 v0, 0x0
:doze_write
    sput-boolean v0, Lcom/android/server/DeviceIdleControllerStubImpl;->mIsLowPowerDozeDevice:Z
    return-void
.end method
"""
field = "Lcom/android/server/DeviceIdleControllerStubImpl;->mIsLowPowerDozeDevice:Z"
out = module.patch_class(fixture)
assert out != fixture
assert out.count(field) == fixture.count(field)
assert out.count("const/4 v0, 0x0\n    sput-boolean v0, " + field) == 1
assert "com/projectryu" not in out
assert module.patch_class(out) == out, "not idempotent"
assert out.count("if-nez v0, :doze_false") == 1
assert out.count("goto :doze_write") == 1
assert out.count(".registers 1") == 1

with tempfile.TemporaryDirectory() as temp:
    folder = Path(temp) / "smali_classes2/com/android/server"
    folder.mkdir(parents=True)
    target = folder / "DeviceIdleControllerStubImpl.smali"
    target.write_text(fixture)
    module.main(Path(temp))
    assert target.read_text() == out
    module.main(Path(temp))
    assert target.read_text() == out

bad = fixture.replace("Lmiui/os/Build;->", "Lfake/os/Build;->")
for case in [
    bad,
    fixture.replace("mIsLowPowerDozeDevice:Z\n    return-void", "otherField:Z\n    return-void"),
    fixture.replace("    return-void\n.end method", "    sput-boolean v0, " + field + "\n    return-void\n.end method"),
]:
    try:
        module.patch_class(case)
    except ValueError:
        pass
    else:
        raise AssertionError("Unexpected smali variant did not fail closed")

print("[PASS] RYU Doze false at unique field write; idempotent; no RYU dependencies")
