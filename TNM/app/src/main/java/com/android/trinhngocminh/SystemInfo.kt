package com.android.trinhngocminh

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.StatFs
import java.io.File

data class DeviceInfo(
    val device: String,
    val soc: String,
    val cpuMax: String,
    val cpuCurrent: String,
    val ram: String,
    val storage: String,
    val android: String,
    val hyperos: String,
    val batteryTemp: String,
    val socTemp: String,
    val gpuTemp: String,
    val root: String,
    val thermal: String,
    val thermalNotice: String? = null,
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
        val zones = File("/sys/class/thermal").listFiles()
            ?.filter { it.name.startsWith("thermal_zone") }
            .orEmpty()

        for (zone in zones) {
            val type = read(File(zone, "type").path).lowercase()
            if (keys.any { type.contains(it.lowercase()) }) {
                val raw = read(File(zone, "temp").path).toDoubleOrNull() ?: continue
                val celsius = if (raw > 1000) raw / 1000.0 else raw
                if (celsius in -20.0..150.0) return "%.1f °C".format(celsius)
            }
        }
        return "—"
    }

    private fun cpuMaxGHz(): String {
        val maxKHz = File("/sys/devices/system/cpu/cpufreq").listFiles()
            ?.filter { it.name.startsWith("policy") }
            ?.mapNotNull {
                read(File(it, "cpuinfo_max_freq").path).toLongOrNull()
                    ?: read(File(it, "scaling_max_freq").path).toLongOrNull()
            }
            ?.maxOrNull()
        return maxKHz?.let { "%.2f GHz".format(it / 1_000_000.0) } ?: "—"
    }

    private fun cpuCurrentGHz(): String {
        val currentKHz = File("/sys/devices/system/cpu/cpufreq").listFiles()
            ?.filter { it.name.startsWith("policy") }
            ?.mapNotNull {
                read(File(it, "scaling_cur_freq").path).toLongOrNull()
                    ?: read(File(it, "cpuinfo_cur_freq").path).toLongOrNull()
            }
            ?.filter { it > 0 }
            ?.maxOrNull()
        return currentKHz?.let { "%.2f GHz".format(it / 1_000_000.0) } ?: "—"
    }

    private fun ramUsage(context: Context): String {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mem = ActivityManager.MemoryInfo().also(am::getMemoryInfo)
        val total = mem.totalMem / 1024.0 / 1024 / 1024
        val used = (mem.totalMem - mem.availMem) / 1024.0 / 1024 / 1024
        return "%.1f / %.1f GB".format(used, total)
    }

    private fun batteryTemp(): String {
        val raw = read("/sys/class/power_supply/battery/temp").toDoubleOrNull() ?: return "—"
        val celsius = when {
            raw > 1000 -> raw / 1000.0
            raw > 100 -> raw / 10.0
            else -> raw
        }
        return "%.1f °C".format(celsius)
    }

    private fun thermalState(context: Context): Pair<String, String?> {
        val raw = read("/sys/class/thermal/thermal_message/sconfig")
            .lineSequence()
            .firstOrNull()
            ?.trim()
            .orEmpty()

        if (raw.isBlank()) {
            return "Không đọc được" to "Không tìm thấy thermal sconfig trên thiết bị"
        }

        val id = raw.substringBefore(' ').substringBefore(':').trim()
        val selected = ThermalManager.selected(context)

        if (id == "0") {
            return if (selected == "eco") {
                "Eco" to null
            } else {
                "Stock Xiaomi" to null
            }
        }

        val name = when (id) {
            "1" -> "Huanji"
            "2" -> "Abnormal"
            "5" -> "Phone"
            "6" -> "No Limits"
            "7" -> "Class 0"
            "10" -> "Navigation"
            "11" -> "Video"
            "15" -> "Camera"
            "16", "17" -> "4K"
            "18" -> "TGame"
            "19" -> "MGame"
            "27" -> "Charge"
            "50" -> "Performance Normal"
            "57" -> "Performance Class 0"
            "61" -> "Performance Video"
            "500" -> "HP Normal"
            "501" -> "HP MGame"
            "700" -> "CGame"
            else -> "Profile #$id"
        }
        return name to "Phát hiện thermal profile khác Eco/Stock: $name"
    }

    fun readStatic(context: Context): DeviceInfo {
        val stat = StatFs(context.filesDir.absolutePath)
        val totalStorage = stat.totalBytes / 1024.0 / 1024 / 1024

        val soc = prop("ro.soc.model")
            .ifBlank { prop("ro.board.platform") }
            .ifBlank { Build.HARDWARE }

        val hyper = listOf(
            prop("ro.mi.os.version.name"),
            prop("ro.mi.os.version.incremental"),
            prop("ro.build.version.incremental"),
        ).firstOrNull { it.isNotBlank() } ?: "—"

        val base = DeviceInfo(
            device = "${Build.MANUFACTURER} ${Build.MODEL} (${Build.DEVICE})",
            soc = soc,
            cpuMax = cpuMaxGHz(),
            cpuCurrent = "—",
            ram = "—",
            storage = "%.0f GB".format(totalStorage),
            android = "Android ${Build.VERSION.RELEASE} · SDK ${Build.VERSION.SDK_INT}",
            hyperos = hyper,
            batteryTemp = "—",
            socTemp = "—",
            gpuTemp = "—",
            root = if (RootShell.hasRoot()) "Có" else "Không",
            thermal = "—",
        )
        return readRealtime(context, base)
    }

    fun readRealtime(context: Context, base: DeviceInfo): DeviceInfo {
        val thermal = thermalState(context)
        return base.copy(
            cpuCurrent = cpuCurrentGHz(),
            ram = ramUsage(context),
            batteryTemp = batteryTemp(),
            socTemp = tempFor("cpu", "soc", "ap", "quiet_therm"),
            gpuTemp = tempFor("gpu"),
            thermal = thermal.first,
            thermalNotice = thermal.second,
        )
    }
}
