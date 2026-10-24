# HyperMOS Android 16 — independent CN and EU policies

Active entry: bin/package/NOTIFICATION_FIX/A16/patch.sh.

China remains unchanged: CN/frameworkpatcher_cn_a16.py and CN/PowerKeeper.sh.

Xiaomi.eu main now uses EU/patch.sh, EU/ryu_policy.json,
EU/ryu_policy.py, and EU/PowerKeeper.sh. Selected RYU EU309
international broadcast, alarm, AppOps, process and notification
branches are applied to original EU miui-services.jar by precise
class/method/register JSON rules. RYU policy uses the existing
IS_INTERNATIONAL_BUILD field as the source flag, never a separate
IS_RYU_BUILD field.

PowerKeeper.apk retains its original EU DEX, other ZIP entries, APK
metadata and intact cryptographic signature; RYU GMS/Millet methods
match EU original. RYU PerfHook, changed thermal paths, and FPS
overrides are deliberately excluded. The China-only policies,
MiuiBatteryIntelligence and EU app maps remain untouched.

The previous Global303/ZK304 EU implementation is archived intact on
branch eu_global at commit ae8549d17784b752b418af821c5f07468a133dda.
EU/backupzk.zip remains an inactive reference.

No method SHA pins, whole donor JAR/APK/DEX imports, broad app keepalive,
new daemon or signing operation. Build and device tests are necessary
before treating the new policy as proven to save battery or improve FCM.
