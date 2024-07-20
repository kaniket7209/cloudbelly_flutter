package com.app.cloudbelly_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent?.let { handleIntent(it) }
    }

    private fun handleIntent(intent: Intent) {
        val data: Uri? = intent.data
        if (data != null) {
            Log.d("DeepLink", "Deep link received: " + data.toString());
            // Handle your deep link here
            // Example: Pass the data to Flutter
            val profileId = data.getQueryParameter("profileId")
            if (profileId != null) {
                // Process the profileId or pass it to Flutter
                // For example, use a method channel to pass data to Flutter
            }
        } else {
            Log.d("DeepLink", "No data in intent");
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}