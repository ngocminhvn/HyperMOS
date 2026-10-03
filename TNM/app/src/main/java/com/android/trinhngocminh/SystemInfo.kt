package com.android.trinhngocminh

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.StatFs
import java.io.File

data class DeviceInfo(
    val device: String,
    val soc: String,
    val cpu: String,
    val ram: String,
    val storage: String,
    val android: String,
    val hyperos: String,
    val batteryTemp: String,
    val socTemp: String,
    val gpuTemp: String,
    val root: String,
    val thermal: String,
)

object SystemInfo {
    private fun prop(name: String): String = try {
        ProcessBuilder("getprop", name).start().inputStream.bufferedReader().readText().trim()
    } catch (_: Throwable) {
        ""
    }

    private fun read(path: String): String = try {
        File(path).readText().trim()
    } catch (_: Throwable) {
        ""
    }

    private fun tempFor(vararg keys: String): String {
        val root = File("/sys/class/thermal")
        val zones = root.listFiles()?.filter { it.name.startsWith("thermal_zone") }.orEmpty()
        for (z in zones) {
            val type = read(File(z, "type").path).lowercase()
            if (keys.any { type.contains(it.lowercase()) }) {
                val raw = read(File(z, "temp").path).toDoubleOrNull() ?: continue
                val c = if (raw > 1000) raw / 1000.0 else raw
                if (c in -20.0..150.0) return "%.1f °C".format(c)
            }
        }
        return "—"
    }

    fun read(context: Context): DeviceInfo {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mem = ActivityManager.MemoryInfo().also(am::getMemoryInfo)
        val totalRam = mem.totalMem / 1024.0 / 1024 / 1024

        val stat = StatFs(context.filesDir.absolutePath)
        val totalStorage = stat.totalBytes / 1024.0 / 1024 / 1024

        val soc = prop("ro.soc.model")
            .ifBlank { prop("ro.board.platform") }
            .ifBlank { Build.HARDWARE }

        val maxKHz = File("/sys/devices/system/cpu/cpufreq").listFiles()
            ?.filter { it.name.startsWith("policy") }
            ?.mapNotNull { read(File(it, "cpuinfo_max_freq").path).toLongOrNull() }
            ?.maxOrNull()

        val cpu = if (maxKHz != null) {
            "$soc · %.2f GHz max".format(maxKHz / 1_000_000.0)
        } else {
            soc
        }

        val batteryRaw = read("/sys/class/power_supply/battery/temp").toDoubleOrNull()
        val battery = batteryRaw?.let {
            val c = if (it > 1000) it / 1000.0 else if (it > 100) it / 10.0 else it
            "%.1f °C".format(c)
        } ?: "—"

        val hyper = listOf(
            prop("ro.mi.os.version.name"),
            prop("ro.mi.os.version.incremental"),
            prop("ro.build.version.incremental"),
        ).firstOrNull { it.isNotBlank() } ?: "—"

        val sconfig = read("/sys/class/thermal/thermal_message/sconfig").ifBlank { "—" }

        return DeviceInfo(
            device = "${Build.MANUFACTURER} ${Build.MODEL} (${Build.DEVICE})",
            soc = soc,
            cpu = cpu,
            ram = "%.1f GB".format(totalRam),
            storage = "%.0f GB".format(totalStorage),
            android = "Android ${Build.VERSION.RELEASE} · SDK ${Build.VERSION.SDK_INT}",
            hyperos = hyper,
            batteryTemp = battery,
            socTemp = tempFor("cpu", "soc", "ap", "quiet_therm"),
            gpuTemp = tempFor("gpu"),
            root = if (RootShell.hasRoot()) "Có" else "Không",
            thermal = "sconfig $sconfig",
        )
    }
}
