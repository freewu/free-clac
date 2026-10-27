package com.freewu.free_clac

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * 把导出的图片写进系统相册 / 下载目录。
 *
 * Android 10（API 29）起走 MediaStore，不需要任何权限，位图落在
 * 「相册 / Pictures/free-clac」，SVG 落在「下载 / Download/free-clac」；
 * 更老的系统直接写公共目录，首次写入前申请 WRITE_EXTERNAL_STORAGE。
 *
 * 之所以不用应用缓存目录：写缓存虽然不会报错，但文件管理器与相册里都看不到，
 * 和界面上「保存位置」的说明对不上。
 */
class MainActivity : FlutterActivity() {
    private var pendingCall: MethodCall? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "saveImage") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q &&
                    checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) !=
                    PackageManager.PERMISSION_GRANTED
                ) {
                    pendingCall = call
                    pendingResult = result
                    requestPermissions(
                        arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                        REQUEST_WRITE,
                    )
                    return@setMethodCallHandler
                }
                handleSave(call, result)
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_WRITE) return
        val call = pendingCall
        val result = pendingResult
        pendingCall = null
        pendingResult = null
        if (call == null || result == null) return
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            handleSave(call, result)
        } else {
            result.error("permission_denied", "没有写入相册的权限", null)
        }
    }

    private fun handleSave(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType")
        if (bytes == null || fileName == null || mimeType == null) {
            result.error("bad_args", "缺少 bytes / fileName / mimeType", null)
            return
        }
        try {
            result.success(saveImage(bytes, fileName, mimeType))
        } catch (error: Exception) {
            result.error("save_failed", error.message ?: "写入系统目录失败", null)
        }
    }

    private fun saveImage(
        bytes: ByteArray,
        fileName: String,
        mimeType: String,
    ): Map<String, String> {
        // SVG 不是相册认识的位图，放进下载目录，其余（PNG / WebP）进相册
        val isImage = mimeType.startsWith("image/") && mimeType != "image/svg+xml"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val collection = if (isImage) {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            } else {
                MediaStore.Downloads.EXTERNAL_CONTENT_URI
            }
            val relativePath = if (isImage) {
                "${Environment.DIRECTORY_PICTURES}/$FOLDER"
            } else {
                "${Environment.DIRECTORY_DOWNLOADS}/$FOLDER"
            }
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                // 写完整前标记 pending，避免相册扫描到半截文件
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val resolver = applicationContext.contentResolver
            val uri = resolver.insert(collection, values)
                ?: throw IllegalStateException("无法在系统目录创建文件")
            try {
                val stream = resolver.openOutputStream(uri)
                    ?: throw IllegalStateException("无法写入系统目录")
                stream.use { it.write(bytes) }
            } catch (error: Exception) {
                resolver.delete(uri, null, null)
                throw error
            }
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return mapOf(
                "location" to uri.toString(),
                "displayPath" to "$relativePath/$fileName",
            )
        }

        // Android 9 及以下：直接写公共目录，再通知相册扫描
        val base = if (isImage) {
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        } else {
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        }
        val dir = File(base, FOLDER)
        if (!dir.exists() && !dir.mkdirs()) {
            throw IllegalStateException("无法创建目录 ${dir.absolutePath}")
        }
        val target = uniqueFile(dir, fileName)
        target.writeBytes(bytes)
        MediaScannerConnection.scanFile(
            applicationContext,
            arrayOf(target.absolutePath),
            arrayOf(mimeType),
            null,
        )
        return mapOf(
            "location" to target.absolutePath,
            "displayPath" to "${base.name}/$FOLDER/${target.name}",
        )
    }

    private fun uniqueFile(dir: File, fileName: String): File {
        val dot = fileName.lastIndexOf('.')
        val base = if (dot <= 0) fileName else fileName.substring(0, dot)
        val extension = if (dot <= 0) "" else fileName.substring(dot)
        var candidate = File(dir, fileName)
        var index = 1
        while (candidate.exists()) {
            candidate = File(dir, "$base ($index)$extension")
            index++
        }
        return candidate
    }

    private companion object {
        const val CHANNEL = "free_clac/media_store"
        const val FOLDER = "free-clac"
        const val REQUEST_WRITE = 0x5A17
    }
}
