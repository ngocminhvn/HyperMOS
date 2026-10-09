#!/usr/bin/env python3
"""Selective GmsObserver build-gate regression tests."""
import importlib.util
from pathlib import Path

path = Path(__file__).with_name("ryu_gms_observer_a16.py")
spec = importlib.util.spec_from_file_location("ryugms", path)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

sample = """
.class public Lcom/miui/powerkeeper/utils/GmsObserver;
.super Ljava/lang/Object;

.method public constructor <init>(Landroid/content/Context;)V
    .registers 4
    sget-boolean v1, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    if-eqz v1, :skip
:skip
    return-void
.end method

.method private static updateGoogleSync(Z)V
    .registers 2
    sget-boolean p0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    if-nez p0, :done
:done
    return-void
.end method

.method public isGmsControlEnabled()Z
    .registers 2
    invoke-static {}, Lcom/miui/powerkeeper/utils/GmsObserver;->isGmsAppInstalled()Z
    move-result v0
    return v0
.end method
"""
out = m.patch_file(sample)
assert out.count("# HyperMOS RYU GMS true-build gate") == 2
assert "const/4 v1, 0x1" in out and "const/4 p0, 0x1" in out
assert ".method public isGmsControlEnabled()Z" in out
assert "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD" not in out
assert m.patch_file(out) == out

variants = [
    sample.replace("IS_INTERNATIONAL_BUILD", "IS_GLOBAL_BUILD", 1),
    sample.replace("sget-boolean v1,", "sget-boolean v16,"),
    sample.replace(".method private static updateGoogleSync(Z)V", ".method static unknown(Z)V"),
]
for bad in variants:
    try:
        m.patch_file(bad)
    except ValueError:
        pass
    else:
        raise AssertionError("Incorrect GMS layout allowed")
print("[PASS] RYU GmsObserver gates enabled; original controller preserved")
