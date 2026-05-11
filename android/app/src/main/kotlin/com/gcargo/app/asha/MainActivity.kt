package com.gcargo.app.asha

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val downloadsChannel = "gcargo/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, downloadsChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "savePdfToDownloads" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")

                    if (fileName.isNullOrBlank() || bytes == null) {
                        result.error("INVALID_ARGS", "Missing fileName or bytes", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val savedPath = savePdfToDownloads(fileName, bytes)
                        result.success(savedPath)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun savePdfToDownloads(fileName: String, bytes: ByteArray): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = applicationContext.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
                put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                put(MediaStore.Downloads.IS_PENDING, 1)
            }

            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Cannot create Downloads entry")

            resolver.openOutputStream(uri)?.use { output ->
                output.write(bytes)
            } ?: throw IllegalStateException("Cannot open Downloads output stream")

            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            "Downloads/$fileName"
        } else {
            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadsDir.exists()) downloadsDir.mkdirs()
            val file = File(downloadsDir, fileName)
            FileOutputStream(file).use { output ->
                output.write(bytes)
            }
            file.absolutePath
        }
    }
}
