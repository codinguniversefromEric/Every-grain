package com.chia.riceJourney

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar

class RiceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.rice_widget_layout).apply {
                val stage = widgetData.getString("growth_stage", "未知")
                val weather = widgetData.getString("weather", "晴朗")
                val hasUnread = widgetData.getBoolean("has_unread_journal", false)

                setTextViewText(R.id.tv_stage, stage)
                setTextViewText(R.id.tv_weather, weather)

                if (hasUnread) {
                    setViewVisibility(R.id.tv_notification, View.VISIBLE)
                } else {
                    setViewVisibility(R.id.tv_notification, View.GONE)
                }

                // Determine background gradient based on time and weather
                val calendar = Calendar.getInstance()
                val hour = calendar.get(Calendar.HOUR_OF_DAY)
                
                val bgResource = when (weather) {
                    "多雲" -> R.drawable.bg_sky_cloudy
                    "有雨", "雷雨" -> R.drawable.bg_sky_rainy
                    else -> { // Clear or unknown
                        when (hour) {
                            in 6..16 -> R.drawable.bg_sky_day_clear
                            in 17..18 -> R.drawable.bg_sky_sunset
                            else -> R.drawable.bg_sky_night
                        }
                    }
                }
                setInt(R.id.widget_root, "setBackgroundResource", bgResource)

                // Adjust text colors for better contrast against light skies
                val isLightSky = (weather == "晴朗" || weather == "未知") && (hour in 6..16) || weather == "多雲"
                val primaryTextColor = if (isLightSky) 0xFF222222.toInt() else 0xFFFFFFFF.toInt()
                val secondaryTextColor = if (isLightSky) 0xFF444444.toInt() else 0xFFA0A0A0.toInt()
                
                setTextColor(R.id.tv_stage, primaryTextColor)
                setTextColor(R.id.tv_weather, secondaryTextColor)
                // tv_title ("粒粒") stays gold (#D4AF37)
                // tv_notification stays green

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
