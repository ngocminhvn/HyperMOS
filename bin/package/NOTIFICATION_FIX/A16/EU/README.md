# EU Android 16: stock notification policy

The HyperMOS EU-specific A16 notification fix is disabled. The dispatcher
returns without modifying the Xiaomi.eu base `miui-services.jar` or
`PowerKeeper.apk`. No Global303 cloud, RYU policy, GMS/FCM exception,
wakelock, Greeze or Millet injection runs here.

`backupzk.zip` is a **reference backup only**, retained at the user's request.
It is not loaded, extracted or installed during a ROM build.

**Pending:** Obtain the Taiwan ROM extraction artifact and compare original
Taiwan JAR/APK behavior with the original Xiaomi.eu baseline before making
any new battery/notification changes.
