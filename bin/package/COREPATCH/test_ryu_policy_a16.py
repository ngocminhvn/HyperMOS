#!/usr/bin/env python3
"""Synthetic regression checks for the selective RYU Android 16 policy."""
import importlib.util
import tempfile
from pathlib import Path

p = Path(__file__).with_name("ryu_policy_a16.py")
spec = importlib.util.spec_from_file_location("ryup", p)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

bq_src = """
.class public Lcom/android/server/am/BroadcastQueueModernStubImpl;
.super Ljava/lang/Object;
.field private mIsBlockBroadcastFirstBoot:Z
.method public updateBlockBroadcast()V
    .locals 4
    const/4 v0, 0x1
    iput-boolean v0, p0, Lcom/android/server/am/BroadcastQueueModernStubImpl;->mIsBlockBroadcastFirstBoot:Z
    invoke-virtual {v0}, Lmiui/security/SecurityManagerInternal;->isAllowedDeviceProvision()Z
    return-void
.end method
.method public checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Landroid/content/pm/ResolveInfo;)Z
    .locals 10
    iget-object v0, p2, Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;
    const/4 v0, 0x0
    return v0
.end method
"""

# Mirrors the actual RYU HAOTIAN ProcessSceneCleaner task-check/return
# shape, with the RYU-only foreground-service block omitted.
ps_src = """
.class public Lcom/android/server/am/ProcessSceneCleaner;
.super Ljava/lang/Object;
.method private killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z
    .registers 14
    invoke-static {p1}, Lcom/android/server/wm/WindowProcessUtils;->getTaskTopApp(I)Lcom/android/server/wm/WindowProcessController;
    move-result-object v1
    if-eqz v1, :cond_end
    iget-object v3, v1, Lcom/android/server/wm/WindowProcessController;->mOwner:Ljava/lang/Object;
    check-cast v3, Lcom/android/server/am/ProcessRecord;
    invoke-virtual {v3}, Lcom/android/server/am/ProcessRecord;->getWindowProcessController()Lcom/android/server/wm/WindowProcessController;
    move-result-object v0
    invoke-static {v0, p1}, Lcom/android/server/wm/WindowProcessUtils;->isProcessHasActivityInOtherTaskLocked(Lcom/android/server/wm/WindowProcessController;I)Z
    move-result v0
    if-nez v0, :cond_end
    iget-object v2, v3, Lcom/android/server/am/ProcessRecord;->info:Landroid/content/pm/ApplicationInfo;
    iget-object v2, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;
    invoke-virtual {p0, v2}, Lcom/android/server/am/ProcessSceneCleaner;->getKillReason(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
:cond_end
    const/4 v0, 0x1
    return v0
.end method
"""
smali = m.foreground_service_protection(ps_src)
method = m.method(smali, "killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z").group()
marker = "Lcom/android/server/am/ProcessServiceRecord;->hasForegroundServices()Z"
assert method.count(marker) == 1
assert method.index("isProcessHasActivityInOtherTaskLocked") < method.index(marker)
assert method.index(marker) < method.index("ProcessRecord;->info")
assert "if-nez v2, :cond_end" in method
assert ":cond_end\n    const/4 v0, 0x1\n    return v0" in method
assert "const/4 v0, 0x0\n    return v0" not in method
assert m.foreground_service_protection(smali) == smali

# Reject unfamiliar layouts instead of assuming register or branch semantics.
variants = [
    ps_src.replace("isProcessHasActivityInOtherTaskLocked", "unknownMethod"),
    ps_src.replace("if-nez v0, :cond_end", "if-eqz v0, :cond_end"),
    ps_src.replace(":cond_end\n    const/4 v0, 0x1", ":cond_end\n    const/4 v0, 0x0"),
    ps_src.replace("v2, v3, Lcom/android/server/am/ProcessRecord;->info", "v2, v3, Lcom/android/server/am/ProcessRecord;->other"),
]
for variant in variants:
    try:
        m.foreground_service_protection(variant)
    except ValueError:
        pass
    else:
        raise AssertionError("Unknown FGS task cleanup layout was accepted")

# Existing original RYU method must remain untouched; no double injection.
original_ryu = ps_src.replace(
    "    iget-object v2, v3, Lcom/android/server/am/ProcessRecord;->info:",
    "    sget-boolean v2, Lcom/projectryu/Build;->IS_RYU_BUILD:Z\n"
    "    invoke-virtual {v3}, Lcom/android/server/am/ProcessRecord;->hasForegroundServices()Z\n"
    "    iget-object v2, v3, Lcom/android/server/am/ProcessRecord;->info:",
)
assert m.foreground_service_protection(original_ryu) == original_ryu

with tempfile.TemporaryDirectory() as d:
    root = Path(d)
    bq = root / "smali/com/android/server/am/BroadcastQueueModernStubImpl.smali"
    bq.parent.mkdir(parents=True)
    bq.write_text(bq_src)
    ps = root / "smali/com/android/server/am/ProcessSceneCleaner.smali"
    ps.write_text(ps_src)
    m.main(root)
    a, b = bq.read_bytes(), ps.read_bytes()
    assert b"com.google.android.c2dm.intent.RECEIVE" in a
    assert b"move-object/from16 v0, p2" in a
    assert b"iget-object v0, p2," not in a.split(b":hypermos_ryu_autostart_original")[0]
    assert marker.encode() in b
    m.main(root)
    assert (a, b) == (bq.read_bytes(), ps.read_bytes()), "patch not idempotent"
    ps.write_text(ps.read_text().replace("isProcessHasActivityInOtherTaskLocked", "unknownMethod"))
    try:
        m.main(root)
    except ValueError:
        print("[OK] fail-closed on unknown Xiaomi smali method")
    else:
        raise AssertionError("target drift not rejected")

print("[PASS] RYU FCM preserved; FGS guard matches RYU branch and return true")
