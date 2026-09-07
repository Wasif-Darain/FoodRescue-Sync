package com.foodrescue.foodrescue_sync

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

/**
 * Creates the "high_importance_channel" notification channel the manifest's
 * `default_notification_channel_id` meta-data points FCM at. On Android 8+
 * (API 26+), a channel must exist before the system will post a notification
 * to it — otherwise background/terminated pushes are silently dropped, with
 * no crash or log. This runs in Application.onCreate() (not MainActivity)
 * so the channel exists even when the process is started in the background
 * to handle an incoming push, without the user ever having opened the app.
 */
class FoodRescueApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "high_importance_channel",
                "Important Notifications",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
