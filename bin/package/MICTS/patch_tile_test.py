#!/usr/bin/env python3
"""MiCTS v2.6 experimental rootless TileFix test.

Keep the ORIGINAL MiCTS package so the HyperMOS services.jar bridge continues
to match caller UID -> com.parallelc.micts. Do not start su, use adb, or use a
long-running service. The tile asks Android to collapse Quick Settings via
TileService.startActivityAndCollapse, launches a transparent *trampoline*, and
finishes that Activity BEFORE dispatching the Circle to Search request.

The APK is debug-signed, not signed with the official author's certificate.
It can only replace the official APK if installation policy allows it.
"""
import argparse
from pathlib import Path

TILE = r'''package com.parallelc.micts

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.service.quicksettings.TileService
import android.util.Log
import com.parallelc.micts.ui.activity.MainActivity

/** No su or root, no Xposed dependency, no permanent background process. */
class LaunchTileService : TileService() {
    @SuppressLint("StartActivityAndCollapseDeprecated")
    override fun onClick() {
        super.onClick()
        val intent = Intent(this, MainActivity::class.java).apply {
            putExtra("tilefix_finish_before_trigger", true)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_ANIMATION)
        }
        try {
            Log.i("MiCTSTileFix", "tile tap; requesting shade collapse through Android API")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val pending = PendingIntent.getActivity(
                    this, 22602, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                startActivityAndCollapse(pending)
            } else {
                startActivityAndCollapse(intent)
            }
        } catch (e: Throwable) {
            Log.e("MiCTSTileFix", "System rejected tile launch", e)
        }
    }
}
'''

ACTIVITY_INJECTION = r'''        if (intent.getBooleanExtra("tilefix_finish_before_trigger", false)) {
            // Unlike upstream, leave the window stack BEFORE calling Google:
            // a still-running transparent Activity can appear as the top app.
            val appContext = applicationContext
            Log.i("MiCTSTileFix", "trampoline entered; finishing before CTS")
            finish()
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                val success = triggerCircleToSearch(1, appContext, false)
                Log.i("MiCTSTileFix", "CTS dispatched after Activity.finish(): $success")
                if (!success) {
                    android.widget.Toast.makeText(
                        appContext, "Circle to Search chưa được chấp nhận",
                        android.widget.Toast.LENGTH_LONG
                    ).show()
                }
            }, 850L)
            return
        }
'''

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--source", type=Path, required=True)
    a = p.parse_args()
    root = a.source
    tile = root / "app/src/main/java/com/parallelc/micts/LaunchTileService.kt"
    activity = root / "app/src/main/java/com/parallelc/micts/ui/activity/MainActivity.kt"
    gradle = root / "app/build.gradle.kts"
    original_tile = tile.read_text(encoding="utf-8")
    original_activity = activity.read_text(encoding="utf-8")
    old = "        super.onCreate(savedInstanceState)\n        enableEdgeToEdge()"
    if "startActivityAndCollapse(pendingIntent)" not in original_tile:
        raise SystemExit("MiCTS Tile does not match pinned v2.6 upstream")
    if original_activity.count(old) != 1:
        raise SystemExit("MiCTS MainActivity.onCreate does not match pinned v2.6 upstream")
    if "fun triggerCircleToSearch" not in original_activity:
        raise SystemExit("MiCTS trigger API missing")
    content = gradle.read_text(encoding="utf-8")
    for marker in ('versionCode = commitCount', 'versionName = latestTag'):
        if content.count(marker) != 1:
            raise SystemExit("MiCTS Gradle version field differs: " + marker)
    tile.write_text(TILE, encoding="utf-8")
    activity.write_text(
        original_activity.replace(old,
            "        super.onCreate(savedInstanceState)\n" + ACTIVITY_INJECTION +
            "        enableEdgeToEdge()"),
        encoding="utf-8"
    )
    content = content.replace('versionCode = commitCount', 'versionCode = 2601002')
    content = content.replace('versionName = latestTag', 'versionName = "2.6-tilefix-test2"')
    gradle.write_text(content, encoding="utf-8")
    print("MiCTS 2.6 TileFix TEST2: no-su, close QS, finish Activity first.")
    print("Retains package com.parallelc.micts for existing HyperMOS bridge.")
    print("Debug certificate differs from official MiCTS; do NOT blindly uninstall system app.")

if __name__ == "__main__":
    main()
