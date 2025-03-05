package com.example.classet_admin

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.annotation.NonNull
import android.util.Log
import com.example.classet_admin.IconManager

class MainActivity: FlutterActivity() {
    override fun onCreate(@NonNull savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "onCreate called")
        updateIcon()
    }

    private fun updateIcon() {
        try {
            IconManager(this).updateAppIcon()
        } catch (e: Exception) {
            Log.e("MainActivity", "Error updating icon", e)
            e.printStackTrace()
        }
    }
}
