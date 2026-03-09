package com.example.finwise_personal.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.example.finwise_personal.R
import es.antonborri.home_widget.HomeWidgetProvider

class HealthSnapshotWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val healthScore = widgetData.getInt("healthScore", 0)
        val healthStatus = widgetData.getString("healthStatus", "Perlu cek")
        val daysRemaining = widgetData.getString("daysRemaining", "0 hari")
        val healthTrend = widgetData.getString("healthTrend", "Pantau")

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_health_layout).apply {
                setTextViewText(R.id.tv_health_score, healthScore.toString())
                setTextViewText(R.id.tv_health_status, healthStatus)
                setTextViewText(R.id.tv_days_remaining, daysRemaining)
                setTextViewText(R.id.tv_health_trend, healthTrend)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
