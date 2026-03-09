package com.example.finwise_personal.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
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

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                setTextViewText(R.id.tv_remaining_budget, remainingBudget)
                setTextViewText(R.id.tv_daily_limit, dailyLimit)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
