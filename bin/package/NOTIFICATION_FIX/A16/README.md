# Android 16 notification patch folders

- `CN/`: used only for Android 16 China builds: `FrameworkPatcher.sh`, `PowerKeeper.sh`, and their source/data/test dependencies. The CN PowerKeeper script internally uses an EU-derived DEX archive, but **the patch executes only on CN ROMs**.
- `EU/`: used only for Android 16 Xiaomi.eu builds: `ContentCatcher_EU.sh` and the ZK304 exact BroadcastQueue/Greeze gate-parity helper, with their tests.

The route is selected in `../notificationFIX.sh`.

Run tests separately:

```bash
python3 -m unittest discover -s bin/package/NOTIFICATION_FIX/A16/CN/tests -v
python3 -m unittest discover -s bin/package/NOTIFICATION_FIX/A16/EU/tests -v
```

**Important:** ZK304 and stock EU309 have identical decision logic in the 4 BroadcastQueue methods and the Greeze PolicyManager region gate. We explicitly preserve these original dynamic gates; the previous constant-true/false override is removed. This parity check is not a fix for all `Greezer Denial` events. `GreezeManagerService.isRestrictReceiver` and `isAllowBroadcast` remain unchanged. Verify runtime notification delivery and battery independently.
