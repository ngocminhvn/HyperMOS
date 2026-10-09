#!/usr/bin/env python3
"""Synthetic contract test: audit only, never import the RYU AppOp/PerfHook."""
import importlib.util
import tempfile
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "audit", Path(__file__).with_name("ryu_targeted_notification_a16.py"))
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


def klass(root, name, definitions):
    p = root / (name + ".smali")
    p.write_text(
        ".class public Ltest/" + name + ";\n.super Ljava/lang/Object;\n" +
        "".join(".method public " + signature + "\n    .locals 1\n" +
                instructions + "\n.end method\n"
                for signature, instructions in definitions.items()),
        encoding="utf-8")


with tempfile.TemporaryDirectory() as folder:
    stock = Path(folder) / "stock"
    ryu = Path(folder) / "ryu"
    stock.mkdir()
    ryu.mkdir()
    for directory in (stock, ryu):
        klass(directory, "BroadcastQueueModernStubImpl",
              {"checkApplicationAutoStart()Z": "    const/4 v0, 0x0\n    return v0"})
        klass(directory, "ProcessManagerService",
              {"isForceStopEnable()Z": "    const/4 v0, 0x1\n    return v0"})
        klass(directory, "ProcessSceneCleaner",
              {"handleSwipeKill()V": "    return-void",
               "killAppForHasOtherTask()Z": "    const/4 v0, 0x1\n    return v0"})
    klass(stock, "NotificationManagerServiceImpl", {
        "checkFullScreenIntent()Z": "    const/4 v0, 0x1\n    return v0",
        "onNotificationPosted()V": "    return-void"})
    klass(ryu, "NotificationManagerServiceImpl", {
        "checkFullScreenIntent()Z": "    const/4 v0, 0x0\n    return v0",
        "onNotificationPosted()V": "    return-void"})

    a = mod.audit(stock, ryu)
    assert a["focused"]["ProcessSceneCleaner.handleSwipeKill()V"]["state"] == "identical"
    assert a["focused"]["ProcessManagerService.isForceStopEnable()Z"]["state"] == "identical"
    assert "DO_NOT_PORT" in a["notification_manager"]["checkFullScreenIntent()Z"]["port_decision"]
    assert not a["policy"]["port_fullscreen_intent_appop_bypass"]
    assert not a["policy"]["port_force_stop_override"]
    assert not a["policy"]["port_private_perf_hook"]
    assert len(a["notification_manager"]) == 1
    assert "swipe" in mod.markdown(a).lower()

print("[PASS] RYU focused audit is read-only; unrelated AppOp and force-stop hooks excluded")
