import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/database_helper.dart';
import 'services/error_service.dart';
import 'services/home_widget_service.dart';
import 'services/notification_service.dart';
import 'services/recurring_scheduler.dart';
import 'services/budget_alert_service.dart';
import 'pages/core/app.dart';
import 'utils/platform_utils.dart';

// Desktop database support
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI for desktop platforms (Windows, macOS, Linux)
  if (PlatformUtils.isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting('id_ID', null);
  await DatabaseHelper.instance.database;

  // Sync all dompet saldo from transactions on startup
  // This ensures saldo is correct even if app was updated and old
  // transactions were never synced to the stored saldo column.
  await _syncAllDompetSaldo();

  // Global error handler for Flutter errors
  FlutterError.onError = (details) {
    ErrorService.instance.recordFlutterError(details);
    FlutterError.presentError(details);
  };

  // Initialize home screen widget (no-op on desktop)
  await HomeWidgetService.initialize();

  // Initialize notification service (no-op on desktop)
  await NotificationService.instance.initialize();

  // Process recurring transactions on app start
  await RecurringScheduler.instance.checkAndCreateRecurring();
  await RecurringScheduler.instance.showRecurringReminder();

  // Check budget alerts and trigger notifications if thresholds exceeded
  await BudgetAlertService.instance.checkBudgetAlerts();

  runApp(const ProviderScope(child: CatatanKeuanganApp()));
}

/// Syncs the stored saldo for ALL dompet wallets from all existing transactions.
/// This runs on every app startup to ensure the stored saldo is always correct.
Future<void> _syncAllDompetSaldo() async {
  try {
    final dompets = await DatabaseHelper.instance.getAllDompet();
    for (var d in dompets) {
      if (d.id != null) {
        await DatabaseHelper.instance.syncDompetSaldo(d.id!);
      }
    }
  } catch (e) {
    // Non-critical — saldo sync failure should not crash the app
    debugPrint('Failed to sync dompet saldo on startup: $e');
  }
}
