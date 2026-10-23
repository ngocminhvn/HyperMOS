Xiaomi.eu A16 Global303 method-level policy

Historical ZK304 source backup: bin/package/NOTIFICATION_FIX/A16/EU/backupzk.zip
Active patch: bin/package/NOTIFICATION_FIX/A16/EU/patch.sh
JAR: original EU miui-services.jar with three Global303
MiuiBatteryIntelligence methods and matching MAP_APP field.
Greeze, BroadcastQueue, Doze remain original EU (verified Global-equivalent).
PerfShielder constructor is not imported: Global-only WMServiceConnection
class and field would be missing in EU.
PowerKeeper: original EU DEX, seven Global303 policy methods.
Original non-DEX APK members and META-INF retained. No signing.
CorePatch, Kaorios, TNM, China and thermal stay unchanged.
Real donor audit: GitHub Actions run 40001161352.
Host assembly does not establish on-device boot, heat or FCM delivery.
