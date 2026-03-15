package com.example.finwise_personal.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.example.finwise_personal.R

class DashboardWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val remainingBudget = widgetData.getString("remainingBudget", "Rp 0")
        val dailyLimit = widgetData.getString("dailyLimit", "Rp 0")
        val daysRemaining = resolveDaysRemaining(widgetData)
        val lastSync = "Sync ${widgetData.getString("widgetLastSync", "--:--")}"
        val remainingRaw = widgetData.getString("remainingBudgetRaw", "0")?.toLongOrNull() ?: 0L
        val dailyLimitRaw = widgetData.getString("dailyLimitRaw", "0")?.toLongOrNull() ?: 0L

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                setTextViewText(R.id.tv_remaining_budget, remainingBudget)
                setTextViewText(R.id.tv_daily_limit, dailyLimit)
                setTextViewText(R.id.tv_days_remaining, daysRemaining)
                setTextViewText(R.id.tv_last_sync, lastSync)
                setTextColor(
                    R.id.tv_remaining_budget,
                    if (remainingRaw <= 0L) Color.parseColor("#FF4D4D") else Color.parseColor("#2D2D2D")
                )
                setTextColor(
                    R.id.tv_daily_limit,
                    if (dailyLimitRaw <= 0L) Color.parseColor("#FF4D4D") else Color.parseColor("#2D5DA1")
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun resolveDaysRemaining(widgetData: SharedPreferences): String {
        val fallback = widgetData.getString("daysRemaining", "0 hari") ?: "0 hari"
        val cycleEndEpoch = widgetData.getString("cycleEndEpoch", null)?.toLongOrNull() ?: return fallback
        val remainingMs = cycleEndEpoch - System.currentTimeMillis()
        if (remainingMs <= 0L) return "0 hari"
        val days = remainingMs / MILLIS_PER_DAY
        return "$days hari"
    }

    companion object {
        private const val MILLIS_PER_DAY = 24L * 60L * 60L * 1000L
    }
}
