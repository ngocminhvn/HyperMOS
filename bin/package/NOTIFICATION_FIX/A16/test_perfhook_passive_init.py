#!/usr/bin/env python3
"""Guard passive RYU PerfHook boot behavior in the ZKOS PowerKeeper graft.

Tests isolate the exact smali transformation. The complete PowerKeeper build
must additionally validate real donor method layout and smali assembly.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from zk_full_powerkeeper_a16 import make_perfhook_init_passive

PREFIX = "Lcom/android/tnm/perf/PerfHook;"
stub = f""".class public {PREFIX}
.super Ljava/lang/Object;

.method public init()V
    .locals 2
    invoke-direct {{p0}}, {PREFIX}->startPerfWorker()V
    invoke-direct {{p0}}, {PREFIX}->schedulePerfCacheInitialization()V
    invoke-direct {{p0}}, {PREFIX}->applyInitialZeroOnce()V
    invoke-virtual {{v0, v1, v0, v0}}, Landroid/content/ContentResolver;->registerContentObserver(Landroid/net/Uri;ZLandroid/database/ContentObserver;)V
    invoke-direct {{p0}}, {PREFIX}->setupSconfigFileObserver()V
    invoke-direct {{p0}}, {PREFIX}->updateConfig()V
    return-void
.end method

.method private updateConfig()V
    .locals 0
    return-void
.end method
"""

out = make_perfhook_init_passive(stub)
init = out.split(".method public init()V", 1)[1].split(".end method", 1)[0]
assert "->applyInitialZeroOnce()V" not in init
assert "->updateConfig()V" not in init
assert "->startPerfWorker()V" in init
assert "->registerContentObserver(" in init
assert "->setupSconfigFileObserver()V" in init
assert ".method private updateConfig()V" in out

for removed in ("->startPerfWorker()V", "->applyInitialZeroOnce()V",
                "->updateConfig()V", "->registerContentObserver("):
    bad = stub.replace(removed, "->missingMethod()V")
    try:
        make_perfhook_init_passive(bad)
    except ValueError:
        pass
    else:
        raise AssertionError(f"Unexpected pass after deleting boot invariant {removed}")
print("PASS: PerfHook boot initializes observers without sconfig reset or policy apply")
