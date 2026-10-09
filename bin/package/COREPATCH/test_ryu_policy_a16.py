#!/usr/bin/env python3
"""Pure synthetic regression test for HyperMOS selective RYU A16 framework port."""
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
ps_src = """
.class public Lcom/android/server/am/ProcessSceneCleaner;
.super Ljava/lang/Object;
.method public killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z
    .locals 10
    invoke-static {p1}, Lcom/android/server/wm/WindowProcessUtils;->getTaskTopApp(I)Lcom/android/server/wm/WindowProcessController;
    invoke-static {}, Lcom/android/server/wm/WindowProcessUtils;->isProcessHasActivityInOtherTaskLocked()Z
    const/4 v0, 0x0
    return v0
.end method
"""
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
    assert b"hasForegroundServices" in b
    m.main(root)
    assert (a, b) == (bq.read_bytes(), ps.read_bytes()), "patch not idempotent"
    ps.write_text(ps.read_text().replace("isProcessHasActivityInOtherTaskLocked", "unknownMethod"))
    try:
        m.main(root)
    except ValueError:
        print("[OK] fail-closed on unknown Xiaomi smali method")
    else:
        raise AssertionError("target drift not rejected")

print("[OK] RYU selective FCM/FGS/first-boot smali patch selftest passed")
