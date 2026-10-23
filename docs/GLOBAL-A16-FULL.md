# Xiaomi.eu Android 16: port only seven Global303 methods

HyperMOS main preserves the original Xiaomi.eu PowerKeeper DEX and only
transplants the seven methods with confirmed different Global303 logic:
CloudUpdateReceiver.onReceive; LocalUpdateUtils.getCloudServer and
setServerConfigurations; InternationalAdapter.<clinit>;
PowerModeAdapter.<clinit>; Utils.isSleepModeViewVisable; f/h.c.

The previous full Global DEX substitution is disabled. The original EU
classes, fields, methods, resources, AndroidManifest, JNI, assets, and
META-INF members remain. Only the seven method bodies are copied into
the disassembled EU DEX and reassembled with smali. The resulting APK
is not signed. Original Xiaomi signature verification does NOT remain
cryptographically valid after any modification to the DEX.

Donor: pinned Global303 classes.dex in
bin/package/GLOBAL_A16/global-powerkeeper.dex.zst,
SHA256 21c20b3ddbaab981276bab60ab6c2a0f62587ea6d87b84bc54aa33def6df25bf.

Preflight: original EU vs donor defined-method/field ABI, SHA256,
exact seven-method diff allowlist, real smali rebuild and re-disassembly,
all 18332 method signatures retained and no more than these seven
method bodies changed, original non-DEX APK members verified.
A standalone Action test-global-a16-port.yml runs the method port on
real donors without building a full ROM.

Greeze, Doze and BroadcastQueue continue to use original Xiaomi.eu
methods verified comparable with Global303, without ZK304 patches.
Kaorios, CorePatch, TNM, China builds and thermal are unchanged.
No device boot, heat or notification guarantees from host-only tests.
