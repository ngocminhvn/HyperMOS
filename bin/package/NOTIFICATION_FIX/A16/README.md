# Android 16 notification patch folders

- `CN/`: used only for Android 16 China builds: `FrameworkPatcher.sh`, `PowerKeeper.sh`, and their source/data/test dependencies. The CN PowerKeeper script internally uses an EU-derived DEX archive, but **the patch executes only on CN ROMs**.
- `EU/`: used only for Android 16 Xiaomi.eu builds: `ContentCatcher_EU.sh` and the ZK-style BroadcastQueue/Greeze policy helper, with their tests.

The route is selected in `../notificationFIX.sh`.

Run tests separately:

```bash
python3 -m unittest discover -s bin/package/NOTIFICATION_FIX/A16/CN/tests -v
python3 -m unittest discover -s bin/package/NOTIFICATION_FIX/A16/EU/tests -v
```

**Important:** ZK-style international BroadcastQueue/Greeze gates on EU are an experimental policy approximation, not a verified cure for `Greezer Denial`. `GreezeManagerService.isRestrictReceiver` and `isAllowBroadcast` remain unchanged. Build, boot, notification-latency and standby-battery verification are still required.
