package com.chia.riceJourney

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class RiceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.rice_widget_layout).apply {
                // Get data from shared preferences written by Flutter
                val stage = widgetData.getString("growth_stage", "未更新")
                val weather = widgetData.getString("weather", "未知")
                val hasUnread = widgetData.getBoolean("has_unread_journal", false)

                setTextViewText(R.id.tv_stage, stage)
                setTextViewText(R.id.tv_weather, weather)

                if (hasUnread) {
                    setViewVisibility(R.id.tv_notification, View.VISIBLE)
                } else {
                    setViewVisibility(R.id.tv_notification, View.GONE)
                }

                // Create intent to open the app on click
                val pendingIntent = es.antonborri.home_widget.HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("ricejourney://widget")
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
