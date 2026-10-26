# Android 16 notification / PowerKeeper policy

## China
The existing CN `frameworkpatcher_cn_a16.py` and `CN/PowerKeeper.sh` are unchanged.

## Xiaomi.eu (HAOTIAN EU309)
The older, working ZK304 ZIP-backed method-level route is consolidated into
just **two files** in `EU/`:

- `zk_patch.py`: integrates the exact historical ContentCatcher, broadcast
  guard, NotificationManager, Greeze/Doze and PowerKeeper method-port
  algorithms, with DEX compilation and post-build checks.
- `zk_methods.json`: 177 **original ZK304 Smali method bodies**, plus
  class fields and source hashes. It is actual source data, not a list of
  method names or base64-wrapped JARs.

There is no ZK ZIP, Zstandard binary, separate donor script, extra service,
daemon, or runtime fetch. Only existing HyperMOS baksmali/smali tools are used.
ROMs running Android versions other than 16 and the China route are unchanged.

### Tested against original EU309 source files
Using the supplied EU309 base `miui-services.jar` and `PowerKeeper.apk`,
the historical algorithms selected:
- **8** ZK304 Greeze/Doze/ProcessManager method ports
- **1** ZK304 NotificationManager initializer port
- **61** compatible PowerKeeper method ports (including GmsObserver, DeviceIdle,
  ActiveState and KillProcess controllers)
- ContentCatcher/broadcast compatibility gates are checked and retained
  without replacing entire EU classes.

An offline JAR reassembly and PowerKeeper DEX reassembly succeeded. All
**523 non-DEX entries** of the 524-member EU APK were checked unchanged in
a ZIP smoke test. The developer build's actual `zipalign` implementation,
ROM boot, and FCM/battery/temperature behavior have **not** been verified on
a running device; tests do not guarantee identical ROM-level behavior.

The modified PowerKeeper classes.dex makes its **original cryptographic
signature invalid**, even though the ZIP member data in META-INF is retained.
Do not describe this as preserving a valid Xiaomi signature.

Historical original donor: GitHub Actions run `39751679932`,
`zk-haotian-304-framework-powerkeeper-39751679932`. The hash-pinned
source remains recoverable there. On unknown EU versions or missing ABI,
the script aborts instead of inventing an adaptation.
