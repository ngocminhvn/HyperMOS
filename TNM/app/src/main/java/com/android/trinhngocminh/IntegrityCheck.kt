package com.android.trinhngocminh

import android.content.Context
import android.util.Base64
import com.google.android.gms.tasks.Task
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import kotlinx.coroutines.suspendCancellableCoroutine
import org.json.JSONObject
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.security.MessageDigest
import java.util.UUID
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

data class IntegrityDiagnostics(
    val summary: String,
    val verifiedBoot: String,
    val bootloader: String,
    val vbmeta: String,
    val selinux: String,
    val buildTags: String,
    val root: String,
)

object IntegrityChecker {
    private fun prop(name: String): String = try {
        ProcessBuilder("getprop", name).start().inputStream.bufferedReader().readText().trim()
    } catch (_: Throwable) {
        ""
    }

    private fun selinux(): String = try {
        ProcessBuilder("getenforce").start().inputStream.bufferedReader().readText().trim()
    } catch (_: Throwable) {
        "Không rõ"
    }

    fun local(): IntegrityDiagnostics {
        val verifiedBoot = prop("ro.boot.verifiedbootstate").ifBlank { "Không rõ" }
        val vbmeta = prop("ro.boot.vbmeta.device_state").ifBlank { "Không rõ" }
        val flashLocked = prop("ro.boot.flash.locked")
        val bootloader = when {
            flashLocked == "1" || vbmeta.equals("locked", true) -> "Locked"
            flashLocked == "0" || vbmeta.equals("unlocked", true) -> "Unlocked"
            else -> "Không rõ"
        }
        val tags = prop("ro.build.tags").ifBlank { "Không rõ" }
        val enforcing = selinux()
        val root = if (RootShell.hasRoot()) "Có" else "Không"

        val modified = root == "Có" ||
            bootloader == "Unlocked" ||
            !verifiedBoot.equals("green", true) ||
            (tags != "Không rõ" && !tags.contains("release-keys")) ||
            (enforcing != "Không rõ" && !enforcing.equals("Enforcing", true))

        val summary = if (modified) {
            "Có dấu hiệu hệ thống đã chỉnh sửa"
        } else {
            "Không thấy dấu hiệu rõ ràng từ kiểm tra cục bộ"
        }

        return IntegrityDiagnostics(
            summary = summary,
            verifiedBoot = verifiedBoot,
            bootloader = bootloader,
            vbmeta = vbmeta,
            selinux = enforcing,
            buildTags = tags,
            root = root,
        )
    }

    suspend fun official(context: Context): String {
        val project = BuildConfig.PLAY_CLOUD_PROJECT_NUMBER
        val backend = BuildConfig.PLAY_INTEGRITY_BACKEND_URL

        if (project <= 0L || backend.isBlank()) {
            return "Chưa cấu hình Google Cloud project/backend"
        }

        return try {
            val manager = IntegrityManagerFactory.createStandard(context.applicationContext)
            val provider = manager.prepareIntegrityToken(
                StandardIntegrityManager.PrepareIntegrityTokenRequest.builder()
                    .setCloudProjectNumber(project)
                    .build()
            ).awaitTask()

            val requestHash = sha256Base64Url(
                "${context.packageName}:${System.currentTimeMillis()}:${UUID.randomUUID()}"
            )
            val token = provider.request(
                StandardIntegrityManager.StandardIntegrityTokenRequest.builder()
                    .setRequestHash(requestHash)
                    .build()
            ).awaitTask().token()

            decodeViaBackend(backend, token, requestHash, context.packageName)
        } catch (t: Throwable) {
            "Play Integrity lỗi: ${t.message ?: t.javaClass.simpleName}"
        }
    }

    private fun sha256Base64Url(value: String): String {
        val digest = MessageDigest.getInstance("SHA-256").digest(value.toByteArray())
        return Base64.encodeToString(
            digest,
            Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING,
        )
    }

    private fun decodeViaBackend(
        endpoint: String,
        token: String,
        requestHash: String,
        packageName: String,
    ): String {
        val conn = (URL(endpoint).openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            connectTimeout = 15_000
            readTimeout = 20_000
            doOutput = true
            setRequestProperty("Content-Type", "application/json")
        }

        val body = JSONObject()
            .put("token", token)
            .put("requestHash", requestHash)
            .put("packageName", packageName)
            .toString()

        conn.outputStream.use { it.write(body.toByteArray()) }
        val code = conn.responseCode
        val response = (if (code in 200..299) conn.inputStream else conn.errorStream)
            ?.bufferedReader()
            ?.readText()
            .orEmpty()

        if (code !in 200..299) return "Backend trả HTTP $code"
        if (response.isBlank()) return "Backend không trả dữ liệu"

        val root = JSONObject(response)
        val payload = when {
            root.has("tokenPayloadExternal") -> root.getJSONObject("tokenPayloadExternal")
            root.has("payload") && root.opt("payload") is JSONObject -> root.getJSONObject("payload")
            else -> root
        }

        val device = payload.optJSONObject("deviceIntegrity")
        val verdict = device?.optJSONArray("deviceRecognitionVerdict")
        val labels = buildList {
            if (verdict != null) {
                for (i in 0 until verdict.length()) add(verdict.optString(i))
            }
        }

        val readable = buildList {
            if ("MEETS_BASIC_INTEGRITY" in labels) add("BASIC")
            if ("MEETS_DEVICE_INTEGRITY" in labels) add("DEVICE")
            if ("MEETS_STRONG_INTEGRITY" in labels) add("STRONG")
        }

        val appVerdict = payload.optJSONObject("appIntegrity")
            ?.optString("appRecognitionVerdict")
            .orEmpty()

        return buildString {
            append(if (readable.isEmpty()) "Không có device integrity label" else readable.joinToString(" · "))
            if (appVerdict.isNotBlank()) append(" · App: ").append(appVerdict)
        }
    }

    private suspend fun <T> Task<T>.awaitTask(): T =
        suspendCancellableCoroutine { continuation ->
            addOnSuccessListener { result ->
                if (continuation.isActive) continuation.resume(result)
            }
            addOnFailureListener { error ->
                if (continuation.isActive) continuation.resumeWithException(error)
            }
        }
}
