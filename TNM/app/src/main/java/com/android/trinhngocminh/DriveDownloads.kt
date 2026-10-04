package com.android.trinhngocminh

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.MediaStore
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.security.MessageDigest
import java.util.Locale

data class DriveFile(
    val id: String,
    val name: String,
    val mimeType: String,
    val sizeBytes: Long?,
    val modifiedTime: String?,
)

data class DriveLoadResult(
    val files: List<DriveFile>,
    val error: String? = null,
)

data class DriveDownloadResult(
    val uri: Uri? = null,
    val message: String,
    val error: String? = null,
)

object DriveDownloads {
    private const val FOLDER_ID = "1AWIrWdjLn5ptJOV1Rwd7DZa7_9euUkfR"

    private fun apiKey(): String = BuildConfig.DRIVE_API_KEY

    private fun certSha1(context: Context): String? = try {
        val signature = if (android.os.Build.VERSION.SDK_INT >= 28) {
            context.packageManager.getPackageInfo(
                context.packageName,
                PackageManager.PackageInfoFlags.of(PackageManager.GET_SIGNING_CERTIFICATES.toLong()),
            ).signingInfo?.apkContentsSigners?.firstOrNull()
        } else {
            @Suppress("DEPRECATION")
            context.packageManager.getPackageInfo(
                context.packageName,
                PackageManager.GET_SIGNATURES,
            ).signatures?.firstOrNull()
        } ?: return null

        MessageDigest.getInstance("SHA-1")
            .digest(signature.toByteArray())
            .joinToString(":") { "%02X".format(Locale.US, it) }
    } catch (_: Throwable) {
        null
    }

    private fun applyGoogleHeaders(context: Context, connection: HttpURLConnection) {
        connection.setRequestProperty("X-Android-Package", context.packageName)
        certSha1(context)?.let {
            connection.setRequestProperty("X-Android-Cert", it.replace(":", ""))
        }
    }

    fun list(context: Context): DriveLoadResult {
        val key = apiKey()
        if (key.isBlank()) {
            return DriveLoadResult(
                emptyList(),
                "Google Drive API key chưa được cấu hình trong bản build này.",
            )
        }

        return try {
            val query = "'$FOLDER_ID' in parents and trashed = false"
            val encodedQuery = Uri.encode(query)
            val fields = Uri.encode("files(id,name,mimeType,size,modifiedTime)")
            val endpoint =
                "https://www.googleapis.com/drive/v3/files" +
                    "?q=$encodedQuery" +
                    "&fields=$fields" +
                    "&pageSize=1000" +
                    "&orderBy=name" +
                    "&key=${Uri.encode(key)}"

            val connection = (URL(endpoint).openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 15_000
                readTimeout = 20_000
                setRequestProperty("Accept", "application/json")
                applyGoogleHeaders(context, this)
            }

            val code = connection.responseCode
            val response = (if (code in 200..299) connection.inputStream else connection.errorStream)
                ?.bufferedReader()
                ?.use { it.readText() }
                .orEmpty()

            if (code !in 200..299) {
                return DriveLoadResult(
                    emptyList(),
                    "Drive API HTTP $code" +
                        if (response.isNotBlank()) ": ${response.take(180)}" else "",
                )
            }

            val root = JSONObject(response)
            val array = root.optJSONArray("files")
            val files = buildList {
                if (array != null) {
                    for (i in 0 until array.length()) {
                        val item = array.optJSONObject(i) ?: continue
                        val mime = item.optString("mimeType")
                        if (mime == "application/vnd.google-apps.folder") continue
                        add(
                            DriveFile(
                                id = item.optString("id"),
                                name = item.optString("name"),
                                mimeType = mime,
                                sizeBytes = item.optString("size").toLongOrNull(),
                                modifiedTime = item.optString("modifiedTime").ifBlank { null },
                            )
                        )
                    }
                }
            }
            DriveLoadResult(files)
        } catch (t: Throwable) {
            DriveLoadResult(emptyList(), t.message ?: t.javaClass.simpleName)
        }
    }

    private fun openMediaConnection(
        context: Context,
        file: DriveFile,
        key: String,
    ): Pair<HttpURLConnection?, String?> {
        val publicUrl =
            "https://drive.usercontent.google.com/download" +
                "?id=${Uri.encode(file.id)}&export=download&confirm=t"

        fun open(url: String, googleApiHeaders: Boolean): HttpURLConnection {
            return (URL(url).openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                instanceFollowRedirects = true
                connectTimeout = 20_000
                readTimeout = 60_000
                setRequestProperty("Accept", "*/*")
                setRequestProperty(
                    "User-Agent",
                    "Mozilla/5.0 (Linux; Android) AppleWebKit/537.36 Chrome/140 Mobile Safari/537.36",
                )
                if (googleApiHeaders) {
                    applyGoogleHeaders(context, this)
                }
            }
        }

        fun isHtml(connection: HttpURLConnection): Boolean {
            val type = connection.contentType.orEmpty().lowercase(Locale.ROOT)
            return type.contains("text/html")
        }

        // Public Drive endpoint handles large public files better than files.get?alt=media.
        var connection = open(publicUrl, false)
        var code = connection.responseCode
        if (code in 200..299 && !isHtml(connection)) {
            return connection to null
        }
        connection.disconnect()

        // Fallback to Drive API media endpoint.
        val apiUrl =
            "https://www.googleapis.com/drive/v3/files/${Uri.encode(file.id)}" +
                "?alt=media&key=${Uri.encode(key)}"
        connection = open(apiUrl, true)
        code = connection.responseCode
        if (code in 200..299 && !isHtml(connection)) {
            return connection to null
        }

        val message = when (code) {
            401, 403 -> "Drive từ chối tải (HTTP $code). Kiểm tra file/folder đang để Anyone with the link."
            404 -> "Không tìm thấy file trên Drive."
            else -> "Drive tải thất bại HTTP $code."
        }
        connection.disconnect()
        return null to message
    }

    fun download(
        context: Context,
        file: DriveFile,
        onProgress: (downloadedBytes: Long, totalBytes: Long?) -> Unit = { _, _ -> },
    ): DriveDownloadResult {
        val key = apiKey()
        if (key.isBlank()) {
            return DriveDownloadResult(
                message = "API key chưa được cấu hình",
                error = "API key chưa được cấu hình",
            )
        }

        if (file.mimeType.startsWith("application/vnd.google-apps.")) {
            return DriveDownloadResult(
                message = "File Google Docs/Sheets/Slides chưa hỗ trợ tải trực tiếp",
                error = "Loại file chưa hỗ trợ",
            )
        }

        var targetUri: Uri? = null
        return try {
            val opened = openMediaConnection(context, file, key)
            val connection = opened.first
                ?: return DriveDownloadResult(
                    message = opened.second ?: "Không mở được kết nối tải Drive",
                    error = opened.second ?: "Không mở được kết nối tải Drive",
                )

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, file.name)
                put(
                    MediaStore.MediaColumns.MIME_TYPE,
                    file.mimeType.ifBlank { "application/octet-stream" },
                )
                put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/TNM")
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val collection = MediaStore.Downloads.getContentUri(
                MediaStore.VOLUME_EXTERNAL_PRIMARY
            )
            targetUri = context.contentResolver.insert(collection, values)
                ?: return DriveDownloadResult(
                    message = "Không tạo được file trong Downloads/TNM",
                    error = "Không tạo được file đích",
                )

            val output = context.contentResolver.openOutputStream(targetUri!!)
                ?: return DriveDownloadResult(
                    message = "Không mở được file đích",
                    error = "Không mở được file đích",
                )

            val totalBytes = file.sizeBytes
                ?.takeIf { it > 0 }
                ?: connection.contentLengthLong.takeIf { it > 0 }

            val buffer = ByteArray(256 * 1024)
            var downloaded = 0L
            var lastProgressAt = 0L
            onProgress(0L, totalBytes)

            connection.inputStream.use { input ->
                output.use { out ->
                    while (true) {
                        val count = input.read(buffer)
                        if (count < 0) break
                        out.write(buffer, 0, count)
                        downloaded += count

                        val now = android.os.SystemClock.elapsedRealtime()
                        if (now - lastProgressAt >= 150L ||
                            (totalBytes != null && downloaded >= totalBytes)
                        ) {
                            onProgress(downloaded, totalBytes)
                            lastProgressAt = now
                        }
                    }
                    out.flush()
                }
            }
            connection.disconnect()

            val done = ContentValues().apply {
                put(MediaStore.MediaColumns.IS_PENDING, 0)
            }
            context.contentResolver.update(targetUri!!, done, null, null)
            onProgress(downloaded, totalBytes)

            DriveDownloadResult(
                uri = targetUri,
                message = "Đã tải ${file.name} vào Downloads/TNM",
            )
        } catch (t: Throwable) {
            targetUri?.let {
                try {
                    context.contentResolver.delete(it, null, null)
                } catch (_: Throwable) {
                }
            }
            DriveDownloadResult(
                message = "Không thể tải: ${t.message ?: t.javaClass.simpleName}",
                error = t.message ?: t.javaClass.simpleName,
            )
        }
    }

    fun installApk(context: Context, uri: Uri): String? {
        return try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            null
        } catch (t: Throwable) {
            "Không mở được trình cài đặt: ${t.message ?: t.javaClass.simpleName}"
        }
    }

    fun formatSize(bytes: Long?): String {
        if (bytes == null || bytes < 0) return "Không rõ dung lượng"
        val mb = bytes / 1024.0 / 1024.0
        return if (mb >= 1024.0) {
            String.format(Locale.US, "%.2f GB", mb / 1024.0)
        } else {
            String.format(Locale.US, "%.1f MB", mb)
        }
    }
}
