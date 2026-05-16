import '../data/database_helper.dart';
import '../services/notification_service.dart';
import '../services/error_service.dart';

/// Service that checks budget status and triggers push notifications
/// when budget thresholds are exceeded.
class BudgetAlertService {
  static final BudgetAlertService _instance = BudgetAlertService._();
  static BudgetAlertService get instance => _instance;
  BudgetAlertService._();

  /// Checks all budgets for the current month and sends notifications
  /// if any category exceeds the warning threshold.
  ///
  /// Call this:
  /// - On app startup (main.dart)
  /// - When budget is updated (budget_sheet.dart)
  /// - Periodically via background scheduler (future enhancement)
  Future<void> checkBudgetAlerts() async {
    try {
      final now = DateTime.now();
      final bulan = now.month;
      final tahun = now.year;

      await _checkBudgetAlertsForMonth(bulan, tahun);
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
    }
  }

  /// Checks budgets for a specific month/year and sends notifications.
  Future<void> checkBudgetAlertsForMonth(int bulan, int tahun) async {
    try {
      await _checkBudgetAlertsForMonth(bulan, tahun);
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
    }
  }

  Future<void> _checkBudgetAlertsForMonth(int bulan, int tahun) async {
    final budgets = await DatabaseHelper.instance.getAllBudget(bulan, tahun);
    final categorySummary = await DatabaseHelper.instance.getCategorySummary(
      tahun,
      bulan,
    );
    final utangList = await DatabaseHelper.instance.getAllUtangPiutang();
    final tabunganList = await DatabaseHelper.instance.getAllTabunganImpian();

    // Filter budgets with nominal > 0 to avoid division by zero
    final activeBudgets = budgets.where((b) => b.nominal > 0).toList();

    await NotificationService.instance.checkAndNotify(
      budgets: activeBudgets,
      categorySummary: categorySummary,
      utangPiutangList: utangList,
      tabunganList: tabunganList,
    );
  }
}
