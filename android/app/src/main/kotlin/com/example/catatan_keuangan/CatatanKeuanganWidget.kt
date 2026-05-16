package com.example.catatan_keuangan

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class CatatanKeuanganWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_catatan_keuangan)

            // Read data from shared preferences (written by Flutter via home_widget)
            val prefs = context.getSharedPreferences("HomeWidgetInformation", Context.MODE_PRIVATE)

            val saldo = prefs.getString("saldo", "Rp 0") ?: "Rp 0"
            val pemasukan = prefs.getString("pemasukan", "+ Rp 0") ?: "+ Rp 0"
            val pengeluaran = prefs.getString("pengeluaran", "- Rp 0") ?: "- Rp 0"
            val tanggal = prefs.getString("tanggal", "-") ?: "-"

            views.setTextViewText(R.id.widget_saldo, saldo)
            views.setTextViewText(R.id.widget_pemasukan, pemasukan)
            views.setTextViewText(R.id.widget_pengeluaran, pengeluaran)
            views.setTextViewText(R.id.widget_tanggal, tanggal)

            // Main widget body click -- opens the app via deep link
            val mainClickIntent = Intent(context, CatatanKeuanganWidget::class.java).apply {
                action = "QUICK_ADD"
                putExtra("type", "pemasukan")
            }
            val mainClickPendingIntent = PendingIntent.getBroadcast(
                context, 0, mainClickIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, mainClickPendingIntent)

            // Quick-add button: + Pemasukan
            val PemasukanIntent = Intent(context, CatatanKeuanganWidget::class.java).apply {
                action = "QUICK_ADD"
                putExtra("type", "pemasukan")
            }
            val PemasukanPendingIntent = PendingIntent.getBroadcast(
                context, 1, PemasukanIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_btn_pemasukan, PemasukanPendingIntent)

            // Quick-add button: - Pengeluaran
            val PengeluaranIntent = Intent(context, CatatanKeuanganWidget::class.java).apply {
                action = "QUICK_ADD"
                putExtra("type", "pengeluaran")
            }
            val PengeluaranPendingIntent = PendingIntent.getBroadcast(
                context, 2, PengeluaranIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_btn_pengeluaran, PengeluaranPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "QUICK_ADD") {
            val type = intent.getStringExtra("type") ?: "pemasukan"
            // Use package manager to safely find the launcher activity
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                data = Uri.parse("catatankeuangan://quickadd?type=$type")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            if (launchIntent != null) {
                context.startActivity(launchIntent)
            }
        }
        super.onReceive(context, intent)
    }
}
