#!/usr/bin/env python3
"""Check RYU A16 FCM and stock-Xiaomi foreground service gate parity."""
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

# The exact stock HAOTIAN OS3.0.308.0 FGS branch structure:
# Xiaomi checks FGS only for IS_INTERNATIONAL_BUILD, whereas RYUOS
# replaces this gate with IS_RYU_BUILD (true on RYU).
ps_src = """
.class public Lcom/android/server/am/ProcessSceneCleaner;
.super Ljava/lang/Object;
.method private killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z
    .registers 14
    .param p1, "taskId"    # I
    .param p2, "config"    # Lmiui/process/ProcessConfig;
    invoke-static {p1}, Lcom/android/server/wm/WindowProcessUtils;->getTaskTopApp(I)Lcom/android/server/wm/WindowProcessController;
    move-result-object v1
    if-eqz v1, :cond_done
    iget-object v3, v1, Lcom/android/server/wm/WindowProcessController;->mOwner:Ljava/lang/Object;
    check-cast v3, Lcom/android/server/am/ProcessRecord;
    invoke-virtual {v3}, Lcom/android/server/am/ProcessRecord;->getWindowProcessController()Lcom/android/server/wm/WindowProcessController;
    move-result-object v0
    invoke-static {v0, p1}, Lcom/android/server/wm/WindowProcessUtils;->isProcessHasActivityInOtherTaskLocked(Lcom/android/server/wm/WindowProcessController;I)Z
    move-result v0
    if-nez v0, :cond_done
    sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    if-eqz v2, :cond_after_fgs
    iget-object v2, v3, Lcom/android/server/am/ProcessRecord;->mServices:Lcom/android/server/am/ProcessServiceRecord;
    .line 246
    invoke-virtual {v2}, Lcom/android/server/am/ProcessServiceRecord;->hasForegroundServices()Z
    move-result v2
    if-nez v2, :cond_done
:cond_after_fgs
    iget-object v2, v3, Lcom/android/server/am/ProcessRecord;->info:Landroid/content/pm/ApplicationInfo;
    iget-object v2, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;
    invoke-virtual {p0, v2}, Lcom/android/server/am/ProcessSceneCleaner;->killOnce(Ljava/lang/String;)V
:cond_done
    const/4 v0, 0x1
    return v0
.end method
"""

edited = m.foreground_service_protection(ps_src)
body = m.method(edited, "killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z").group()
assert "# HyperMOS RYU FGS: enable existing Xiaomi guard" in body
assert "const/4 v2, 0x1\n    if-eqz v2, :cond_after_fgs" in body
assert "IS_INTERNATIONAL_BUILD:Z" not in body
assert body.count("hasForegroundServices()Z") == 1
assert "if-nez v2, :cond_done" in body
assert ":cond_done\n    const/4 v0, 0x1\n    return v0" in body
assert "killOnce(" in body
assert m.foreground_service_protection(edited) == edited

# The original RYU implementation must remain completely untouched.
original_ryu = ps_src.replace(
    "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
    "Lcom/projectryu/Build;->IS_RYU_BUILD:Z",
)
assert m.foreground_service_protection(original_ryu) == original_ryu

# Fail on drift, do not silently rewrite unrelated native code.
variants = [
    ps_src.replace("isProcessHasActivityInOtherTaskLocked", "unknownMethod"),
    ps_src.replace("IS_INTERNATIONAL_BUILD:Z", "IS_GLOBAL_BUILD:Z"),
    ps_src.replace("hasForegroundServices()Z", "isRunningService()Z"),
    ps_src.replace("if-nez v2, :cond_done", "if-eqz v2, :cond_done"),
    ps_src.replace(":cond_done\n    const/4 v0, 0x1", ":cond_done\n    const/4 v0, 0x0"),
    ps_src.replace("if-eqz v2, :cond_after_fgs", "if-nez v2, :cond_after_fgs"),
]
for src in variants:
    try:
        m.foreground_service_protection(src)
    except ValueError:
        pass
    else:
        raise AssertionError("Unknown Xiaomi FGS layout accepted")

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
    assert b"# HyperMOS RYU FGS: enable existing Xiaomi guard" in b
    m.main(root)
    assert (a, b) == (bq.read_bytes(), ps.read_bytes()), "patch not idempotent"

    # Run drift test on unmodified method so the idempotency marker is absent.
    bq.write_text(bq_src)
    ps.write_text(ps_src.replace("hasForegroundServices()Z", "unexpectedFGS()Z"))
    try:
        m.main(root)
    except ValueError:
        assert bq.read_text() == bq_src, "partial write on failed patch"
        print("[OK] Fail-closed on unknown Xiaomi FGS layout")
    else:
        raise AssertionError("unknown layout was not rejected")

print("[PASS] FCM preserved, existing FGS gate enabled for CN, return-true unchanged")
