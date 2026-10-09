#!/usr/bin/env python3
"""Regression checks for selective RYU FCM exception without early-return."""
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
.field private mSecurityInternal:Lmiui/security/SecurityManagerInternal;
.field private mIsBlockBroadcastFirstBoot:Z

.method private updateBlockBroadcast()V
    .registers 4
    iget-object v0, p0, Lcom/android/server/am/BroadcastQueueModernStubImpl;->mSecurityInternal:Lmiui/security/SecurityManagerInternal;
    invoke-virtual {v0}, Lmiui/security/SecurityManagerInternal;->isAllowedDeviceProvision()Z
    const-string v1, "is_block_broadcast_first_boot"
    iput-boolean v0, p0, Lcom/android/server/am/BroadcastQueueModernStubImpl;->mIsBlockBroadcastFirstBoot:Z
    return-void
.end method

.method public checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Landroid/content/pm/ResolveInfo;)Z
    .registers 22
    move-object/from16 v1, p2
    move-object/from16 v6, p3
    iget-object v2, v1, Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;
    invoke-virtual {v2}, Landroid/content/Intent;->getAction()Ljava/lang/String;
    move-result-object v9
    iget-object v2, v1, Lcom/android/server/am/BroadcastRecord;->callerPackage:Ljava/lang/String;
    iget-object v2, v1, Lcom/android/server/am/BroadcastRecord;->callerApp:Lcom/android/server/am/ProcessRecord;
    invoke-static {v10}, Landroid/app/AppOpsManagerInjector;->isAutoStartRestriction(Ljava/lang/String;)Z
    move-result v2
    if-nez v2, :cond_denied
    const/4 v2, 0x1
    return v2
    :cond_denied
    const/4 v2, 0x0
    return v2
.end method
"""

ps_src = """
.class public Lcom/android/server/am/ProcessSceneCleaner;
.super Ljava/lang/Object;
.method private killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z
    .registers 14
    const/4 v0, 0x0
    .local v0, "taskTopApp":Lcom/android/server/am/ProcessRecord;
    move-object v3, v0
    .end local v0
    .local v3, "taskTopApp":Lcom/android/server/am/ProcessRecord;
    invoke-virtual {v3}, Lcom/android/server/am/ProcessRecord;->getWindowProcessController()Lcom/android/server/wm/WindowProcessController;
    move-result-object v0
    invoke-static {v0, p1}, Lcom/android/server/wm/WindowProcessUtils;->isProcessHasActivityInOtherTaskLocked(Lcom/android/server/wm/WindowProcessController;I)Z
    move-result v0
    .local v0, "processHasOtherTask":Z
    if-nez v0, :cond_4d
    iget-object v2, v3, Lcom/android/server/am/ProcessRecord;->info:Landroid/content/pm/ApplicationInfo;
    const/4 v0, 0x0
    return v0
    :cond_4d
    const/4 v0, 0x1
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

    original_first_boot = m.method(bq_src, "updateBlockBroadcast()V").group()
    m.main(root)
    a, b = bq.read_text(), ps.read_text()
    assert m.method(a, "updateBlockBroadcast()V").group() == original_first_boot
    assert 'isAllowedDeviceProvision()Z' in a
    assert ':hypermos_ryu_first_boot_marker' not in a
    fcm = m.method(a,
        "checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;"
        "Lcom/android/server/am/BroadcastRecord;"
        "Landroid/content/pm/ResolveInfo;)Z").group()
    check_idx = fcm.index('isAutoStartRestriction')
    assert fcm.index('com.google.android.c2dm.intent.RECEIVE') > check_idx
    assert fcm.index('callerPackage:Ljava/lang/String;') >= 0
    assert fcm.count('const-string v5, "com.google.android.gms"') == 1
    assert 'ProcessRecord;->info:Landroid/content/pm/ApplicationInfo;' in fcm
    # Targeted exemption sets the policy-result register, never returns early.
    exemption = fcm.split('    # RYU-inspired:')[1].split(':hypermos_ryu_fcm_autostart_only')[0]
    assert "return " not in exemption
    assert "const/4 v2, 0x0" in fcm
    fgs = m.method(b, "killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z").group()
    assert fgs.index("isProcessHasActivityInOtherTaskLocked") < fgs.index("hasForegroundServices")
    assert "if-nez v2, :cond_4d" in fgs
    assert "return v0" in fgs and "return v2" not in fgs
    m.main(root)
    assert (a, b) == (bq.read_text(), ps.read_text()), "patch not idempotent"

    # Alter target, verify failing without leaving partial BQ/PSC edits.
    ps.write_text(ps_src.replace("isProcessHasActivityInOtherTaskLocked", "changedXiaomiMethod"))
    bq.write_text(bq_src)
    try:
        m.main(root)
    except ValueError:
        assert bq.read_text() == bq_src, "partial changes on failure"
    else:
        raise AssertionError("changed Xiaomi method incorrectly accepted")

print("[PASS] trusted FCM sender guards / Xiaomi autostart-only / original first-boot / task-only FGS")
