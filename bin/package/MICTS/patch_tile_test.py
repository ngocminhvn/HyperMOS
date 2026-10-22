#!/usr/bin/env python3
"""Patch upstream MiCTS v2.6 Quick Settings tile for rooted HyperOS tests.

Keep the upstream applicationId com.parallelc.micts and its CSService request
marker intact. This changes the tile path only: do not open MainActivity
while the shade is being dismissed. It must NOT be treated as a vendor-signed
drop-in replacement: custom builds have a different signing certificate.
"""
from pathlib import Path
import argparse

TILE = r'''package com.parallelc.micts

import android.service.quicksettings.TileService
import android.os.SystemClock
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import com.parallelc.micts.ui.activity.triggerCircleToSearch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Experimental MiCTS Tile for rooted HyperMOS.
 * Unlike the upstream Tile it never launches a foreground Activity.
 * A foreground application must be observed twice before invoking CTS.
 * No background daemon; this process only runs on direct tile taps.
 */
class LaunchTileService : TileService() {
    companion object {
        private const val TAG = "MiCTSTileFix"
        private val running = AtomicBoolean(false)
    }

    override fun onClick() {
        super.onClick()
        if (!running.compareAndSet(false, true)) return
        Thread({
            try {
                val collapse = rootCommand("/system/bin/cmd statusbar collapse", 6000L)
                if (collapse.first != 0) {
                    report("Không đóng được Control Center: hãy cấp root cho MiCTS.")
                    return@Thread
                }

                // A fixed 400/1000 ms delay alone is unreliable on HyperOS.
                // Wait for a non-shade focused window to return, then observe
                // the same target on a second pass. The extra 350 ms allows
                // panel close animation to settle after the final focus change.
                var previous = ""
                var consecutive = 0
                var foreground = ""
                for (attempt in 0 until 10) {
                    SystemClock.sleep(170L)
                    val probe = rootCommand(
                        "/system/bin/dumpsys window | /system/bin/grep -m 1 mCurrentFocus",
                        5000L
                    )
                    if (probe.first != 0) {
                        report("Không lấy được cửa sổ đang mở; xem quyền root.")
                        return@Thread
                    }
                    val focus = probe.second.trim().substringAfter("mCurrentFocus=", "")
                    val isTarget = focus.isNotBlank() &&
                        !focus.contains("null", true) &&
                        !focus.contains("systemui", true) &&
                        !focus.contains("ControlCenter", true) &&
                        !focus.contains("StatusBar", true) &&
                        !focus.contains("NotificationShade", true) &&
                        !focus.contains("com.parallelc.micts", true) &&
                        !focus.contains("com.google.android.googlequicksearchbox", true)
                    Log.i(TAG, "focus[$attempt] ready=$isTarget $focus")
                    consecutive = if (isTarget && focus == previous) consecutive + 1
                        else if (isTarget) 1 else 0
                    previous = focus
                    if (consecutive >= 2) {
                        foreground = focus
                        break
                    }
                }
                if (foreground.isEmpty()) {
                    report("Chưa xác nhận Control Center đã đóng. Không kích hoạt nhầm màn hình.")
                    return@Thread
                }

                SystemClock.sleep(350L)
                // Re-check after the animation guard; do not trust a stale app.
                val finalProbe = rootCommand(
                    "/system/bin/dumpsys window | /system/bin/grep -m 1 mCurrentFocus",
                    5000L
                )
                if (finalProbe.first != 0 || !finalProbe.second.contains(foreground)) {
                    report("Cửa sổ đã thay đổi trong lúc đóng Control Center; hủy yêu cầu.")
                    return@Thread
                }
                val ok = triggerCircleToSearch(1, this@LaunchTileService, false)
                Log.i(TAG, "invoke returned=$ok, foreground=$foreground")
                if (!ok) report("MiCTS/CSService không chấp nhận yêu cầu.")
            } catch (e: Throwable) {
                Log.e(TAG, "tile failed", e)
                report("MiCTS Tile gặp lỗi; xem logcat -s MiCTSTileFix:* MiCTSBridge:*")
            } finally {
                running.set(false)
            }
        }, "MiCTS-tile-test").start()
    }

    private fun rootCommand(cmd: String, timeout: Long): Pair<Int, String> {
        val process = ProcessBuilder("su", "-c", cmd)
            .redirectErrorStream(true)
            .start()
        val text = StringBuilder()
        val drain = Thread {
            try {
                process.inputStream.bufferedReader().use { reader ->
                    // Output is deliberately bounded by grep or short cmd.
                    reader.forEachLine { line ->
                        if (text.length < 4096) text.append(line).append('\n')
                    }
                }
            } catch (_: Exception) { }
        }
        drain.isDaemon = true
        drain.start()
        val exited = process.waitFor(timeout, TimeUnit.MILLISECONDS)
        if (!exited) process.destroyForcibly()
        drain.join(500L)
        return (if (exited) process.exitValue() else 124) to text.toString()
    }

    private fun report(message: String) {
        Log.w(TAG, message)
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(applicationContext, message, Toast.LENGTH_LONG).show()
        }
    }
}
'''
def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--source",type=Path,required=True)
    a=parser.parse_args()
    src=a.source
    tile=src/"app/src/main/java/com/parallelc/micts/LaunchTileService.kt"
    gradle=src/"app/build.gradle.kts"
    before=tile.read_text(encoding="utf-8")
    if "startActivityAndCollapse(pendingIntent)" not in before:
        raise SystemExit("Unsupported upstream Tile: expected MiCTS v2.6 LaunchTileService")
    if "fun triggerCircleToSearch" not in (
        src/"app/src/main/java/com/parallelc/micts/ui/activity/MainActivity.kt"
    ).read_text():
        raise SystemExit("Missing original MiCTS trigger API")
    content=gradle.read_text(encoding="utf-8")
    for old in ('versionCode = commitCount','versionName = latestTag'):
        if content.count(old)!=1: raise SystemExit("Unexpected Gradle version field: "+old)
    content=content.replace('versionCode = commitCount','versionCode = 2601001')
    content=content.replace('versionName = latestTag','versionName = "2.6-tilefix-test1"')
    tile.write_text(TILE,encoding="utf-8")
    gradle.write_text(content,encoding="utf-8")
    print("MiCTS v2.6 root-only Quick Settings tile fix staged.")
    print("Package is com.parallelc.micts; official certificate is NOT preserved.")
    print("Only use test APK after planning for signing conflicts with ROM preload.")
if __name__=="__main__": main()
