# HAOTIAN Android 16: stock-first PowerKeeper notification patch

## Active implementation (China base, no EU/RYU/ZK DEX transplant)

The current build starts from the Xiaomi-signed China base ROM's PowerKeeper.apk
and its OWN classes.dex. The previous whole Xiaomi.eu classes.dex transplant
and seven EU/ZK gates are retired.

- bin/package/NOTIFICATION_FIX/A16/PowerKeeper.sh
- bin/package/NOTIFICATION_FIX/A16/powerkeeper_stock_patches.json
- bin/package/NOTIFICATION_FIX/A16/patch_stock_powerkeeper_a16.py
- bin/package/NOTIFICATION_FIX/A16/preserve_powerkeeper_identity.py

Only four specific international-build field reads are selected:
1. GmsObserver.<init>(Context) (one read).
2. GmsObserver.updateGoogleSync(boolean) (one read).
3. DeviceIdleController$1.<init>() (one read).
4. DeviceIdleController$2.<init>() (one read).

Each replaces a two-code-unit sget-boolean field read with const/4 true plus
nop, preserving length and method boundaries. If the China stock APK does not
match the expected method/field/read inventory, the build FAILS instead of
using the whole EU DEX as a fallback. Every other DEX byte must remain identical
except the DEX SHA-1/Adler32 header checksums. The build records actual stock
and patched DEX hashes; the China source bytes are not stored in Git.

DisplayFrameSetting (both formerly forced methods, three gates), the entire
KillProcessController and ActiveStateController class methods remain **stock**.
The rest of PowerKeeper thermal, FPS, app rules, performance, GMS Millet and
background workers remain stock; no PerfHook or RYU UID-kill is transplanted.
This does not imply China and EU have identical behavior outside these reads.

### Build/compatibility requirements

APK identity (com.miui.powerkeeper v40200, minSdk 36) and its Xiaomi certificate
are checked before patching. The APK is built from original non-DEX entries,
with original META-INF certificate data carried over and all other APK members
compared against Xiaomi stock. Modifying any DEX INVALIDATES the original Xiaomi
cryptographic signature; retaining certificate metadata is NOT equivalent to a
valid Xiaomi signature. The ROM's existing compatible signature handling is
required. No silent fallback or testkey signing.

Reports:
- build/reports/powerkeeper-a16/stock-identity.json
- build/reports/powerkeeper-a16/stock-scoped-gates.json
- build/reports/powerkeeper-a16/stock-final-metadata.json
- build/reports/powerkeeper-a16/stock-dex-report.json

There is NO performance or FCM claim until actual HAOTIAN runtime tests.
In particular, a persisted/cloud gms_control=true can still override default
GmsObserver decisions after dirty flash; reverting donor code does not clear
user/cloud data. Verify FCM connected/reconnect behavior across screen-off and
Wi-Fi/mobile transitions, exit-info stopped state, idle power and temperature.

## Historical implementation (removed)

Previous builds transplanted the entire EU v4.2.00 DEX and forced seven gates,
including three DisplayFrameSetting reads. The archived history of this file
describes that previous design; it is not the current build.
