package com.example.finwise_personal.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import com.example.finwise_personal.R
import es.antonborri.home_widget.HomeWidgetProvider

class RunwayWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val runwayDaily = widgetData.getString("runwayDaily", "Rp 0")
        val runwayStatus = widgetData.getString("runwayStatus", "WASPADA")
        val runwayHint = widgetData.getString("runwayHint", "Pantau pengeluaran harian.")
        val daysRemaining = resolveDaysRemaining(widgetData)
        val lastSync = "Sync ${widgetData.getString("widgetLastSync", "--:--")}"

        val statusUpper = runwayStatus?.uppercase() ?: "WASPADA"
        val statusPanelRes = when (statusUpper) {
            "AMAN" -> R.drawable.widget_hd_panel_blue
            "KRITIS" -> R.drawable.widget_hd_panel_red
            else -> R.drawable.widget_hd_panel_yellow
        }
        val statusTextColor = when (statusUpper) {
            "AMAN" -> Color.parseColor("#2D5DA1")
            "KRITIS" -> Color.parseColor("#B32020")
            else -> Color.parseColor("#7A5A00")
        }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_runway_layout).apply {
                setTextViewText(R.id.tv_runway_daily, runwayDaily)
                setTextViewText(R.id.tv_runway_status, statusUpper)
                setTextViewText(R.id.tv_runway_hint, runwayHint)
                setTextViewText(R.id.tv_runway_days, daysRemaining)
                setTextViewText(R.id.tv_last_sync, lastSync)
                setTextColor(R.id.tv_runway_status, statusTextColor)
                setInt(R.id.runway_status_panel, "setBackgroundResource", statusPanelRes)
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
