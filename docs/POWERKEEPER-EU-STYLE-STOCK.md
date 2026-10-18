# HAOTIAN Android 16 PowerKeeper: EU-like, stock-first integration

## Active build policy

The base ROM's PowerKeeper.apk is retained byte-for-byte after Android
apksigner verification against the original Xiaomi certificate. No DEX donor
is injected. This is the conservative way to approach the original Xiaomi/EU
behavior without silently grafting an APK built for a different ROM release.

The previous pipeline reconstructed ZKOS DEX, grafted two conditional UID
methods from RYU, restored an interface ABI and added a GMS-specific helper.
That could diverge from EU and invalidated the authentic APK signature even
when original v1 certificate metadata was copied. It is now disabled.

## Preserved or removed

| Area | Active policy |
| --- | --- |
| KillProcessController, GmsObserver, ActiveStateController | Base Xiaomi bytecode untouched |
| DeviceIdle / AppStandby / background rules | Base Xiaomi bytecode untouched |
| ThermalManager, temp_state, performance | Base Xiaomi bytecode and vendor/ODM configs untouched |
| DisplayFrameSetting / FPS | Base Xiaomi bytecode untouched |
| RYU/TNM PerfHook | Not imported |
| ZKOS SettingsHelper / build gate | Not imported |
| RYU policy methods and GMS-only kill helper | Not imported |
| Xiaomi APK cryptographic signature | Verified and retained; no APK rebuild |
| Separate framework notification patches/GMS sysconfig | Unchanged by this PowerKeeper migration |
| TNM on-demand CPU percent control | Remains independent of PowerKeeper |

## EU comparison and limitations

In the supplied EU/RYU reference APKs, 18,281 common DEX methods had
equivalent normalized instructions and 51 differed; the selected
KillProcessController/ActiveStateController/DeviceIdleController methods
were equivalent. The EU and ZKOS APKs differ much more across versions.
That evidence supports using conservative Xiaomi behavior, but does not
establish byte-for-byte EU parity for the base OS3.0.308.0 ROM.

Since the base APK is not modified, no Xiaomi signature bypass is required
for the PowerKeeper APK itself. Separate signature-policy changes elsewhere
in HyperMOS are not affected by this migration.

At build time the script requires exactly one PowerKeeper.apk, checks its
Xiaomi certificate and valid APK signature using apksigner, confirms a
nonempty DEX inventory, writes a stock-identity JSON report, and verifies
the APK SHA-256 has not changed. It intentionally makes no smali edits.

The change requires a complete ROM build and device tests before drawing
conclusions about standby drain, temperature or notification latency.
