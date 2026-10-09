# Experimental Android 16 Xiaomi AppOps on newly installed apps

This test-branch feature adds a one-shot hook in services.jar:
com.android.server.pm.BroadcastHelper.sendPackageAddedForNewUsers(...).
Unlike PACKAGE_REPLACED, this call receives the new-user install list.

Supported Xiaomi AppOps: 10020 (show on lock screen), 10021 (launch an
activity from background), 10017 (install home-screen shortcuts).
No other runtime permissions or notification channels are changed.

COREPATCH/update.sh supplies the --auto-app-ops flag on Android 16,
and COREPATCH/jar_patcher_a16.sh runs AUTO_APP_OPS/patch.py after
disassembling services.jar, before its reassembly. The separate
HyperMOSAutoOps.smali class calls AppOpsManager.setMode for each new
user. Each failure is logged individually. No TNM runtime, root daemon,
install polling loop, PowerKeeper patch, or boot image changes.

SECURITY: granting AppOp 10021 to every newly installed app makes
background launches less restricted. This prototype is on a dedicated
test branch only and is not confirmed safe or functional on Xiaomi 15
Pro. Do not merge into main until testing on the actual target ROM.

Verification commands:

    python3 -m unittest discover -s bin/package/AUTO_APP_OPS/tests -p 'test_*.py' -v
    python3 -m py_compile bin/package/AUTO_APP_OPS/patch.py
    bash -n bin/package/COREPATCH/jar_patcher_a16.sh
    bash -n bin/package/COREPATCH/update.sh

The patcher requires an exact Android 16 method signature and context
field. If absent, ROM construction aborts rather than shipping an
unverified patch. Unit tests check only code structure, not runtime
behavior. On-device tests must check cold boot, clean install, Xiaomi
SecurityCenter switches, install-vs-update behavior, and rejected mode
log output (logcat -s HyperMOSAutoOps). Install from Google Play,
InstallerX and adb for source-independence.
