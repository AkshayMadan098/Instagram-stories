package com.example.instagram_stories

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.instagram_stories/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isInstagramInstalled" -> {
                    val installed = isAppInstalled("com.instagram.android")
                    result.success(installed)
                }
                "shareToInstagramStory" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val caption = call.argument<String>("caption")
                    val topColor = call.argument<String>("topColor") ?: "#000000"
                    val bottomColor = call.argument<String>("bottomColor") ?: "#000000"

                    if (imagePath == null) {
                        result.error("INVALID_ARGUMENT", "Image path cannot be null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val file = File(imagePath)
                        if (!file.exists()) {
                            result.error("FILE_NOT_FOUND", "File does not exist: $imagePath", null)
                            return@setMethodCallHandler
                        }

                        val fileUri: Uri = FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            file
                        )

                        // Directly construct intent for Instagram Stories:
                        val intent = Intent("com.instagram.share.ADD_TO_STORY").apply {
                            setDataAndType(fileUri, "image/png")
                            setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
                            setPackage("com.instagram.android")
                            putExtra("source_application", packageName)
                            putExtra("top_background_color", topColor)
                            putExtra("bottom_background_color", bottomColor)
                            if (!caption.isNullOrBlank()) {
                                putExtra("content_url", caption)
                            }
                        }

                        // Explicitly grant read URI permission to Instagram package
                        grantUriPermission(
                            "com.instagram.android",
                            fileUri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION
                        )

                        // Check if Instagram can handle the story intent
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success("success")
                        } else {
                            // Fallback check if package is installed
                            if (isAppInstalled("com.instagram.android")) {
                                startActivity(intent)
                                result.success("success")
                            } else {
                                result.success("instagram_not_installed")
                            }
                        }
                    } catch (e: Exception) {
                        result.error("SHARE_ERROR", e.localizedMessage, e.stackTraceToString())
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: Exception) {
            false
        }
    }
}
