import '../utils/platform_utils.dart';

// Conditionally import home_widget only on mobile
// On desktop, all methods are no-ops.
import 'package:home_widget/home_widget.dart'
    if (dart.library.io) 'package:home_widget/home_widget.dart';

/// Service for managing the Android home screen widget.
/// All methods are no-ops on desktop platforms.
///
/// Optimizations:
/// - Throttles update calls to prevent excessive widget refreshes
/// - Batches data saves before triggering widget update
/// - Uses debouncing to avoid rapid consecutive updates
class HomeWidgetService {
  static const _appGroupId = 'catatan_keuangan_widget';
  static const _androidWidgetName = 'CatatanKeuanganWidget';

  /// Throttle duration in milliseconds
  static const _throttleDuration = 1000;

  /// Last update timestamp
  static DateTime? _lastUpdate;

  /// Cached values to avoid redundant saves
  static String? _cachedSaldo;
  static String? _cachedPemasukan;
  static String? _cachedPengeluaran;
  static List<double>? _cachedDailyTotals;

  /// Initializes the home widget.
  static Future<void> initialize() async {
    if (!PlatformUtils.isMobile) return;
    // Set app group ID for shared data (used for widget updates)
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Checks if an update should be throttled
  static bool _shouldThrottle() {
    final now = DateTime.now();
    if (_lastUpdate != null) {
      final elapsed = now.difference(_lastUpdate!).inMilliseconds;
      if (elapsed < _throttleDuration) {
        return true;
      }
    }
    _lastUpdate = now;
    return false;
  }

  /// Updates the widget with current balance data.
  /// Automatically throttles to prevent excessive updates.
  static Future<void> updateWidget({
    required double totalSaldo,
    required double totalPemasukan,
    required double totalPengeluaran,
  }) async {
    if (!PlatformUtils.isMobile) return;

    // Check if values actually changed
    final newSaldo = 'Rp ${_formatNumber(totalSaldo)}';
    final newPemasukan = '+ Rp ${_formatNumber(totalPemasukan)}';
    final newPengeluaran = '- Rp ${_formatNumber(totalPengeluaran)}';

    if (newSaldo == _cachedSaldo &&
        newPemasukan == _cachedPemasukan &&
        newPengeluaran == _cachedPengeluaran) {
      return; // No change, skip update
    }

    // Cache the values
    _cachedSaldo = newSaldo;
    _cachedPemasukan = newPemasukan;
    _cachedPengeluaran = newPengeluaran;

    // Check throttle
    if (_shouldThrottle()) {
      return;
    }

    await HomeWidget.saveWidgetData('saldo', newSaldo);
    await HomeWidget.saveWidgetData('pemasukan', newPemasukan);
    await HomeWidget.saveWidgetData('pengeluaran', newPengeluaran);
    await HomeWidget.saveWidgetData('tanggal', _formatTanggal(DateTime.now()));
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  /// Clears widget data (shown when no data available).
  static Future<void> clearWidget() async {
    if (!PlatformUtils.isMobile) return;

    _cachedSaldo = null;
    _cachedPemasukan = null;
    _cachedPengeluaran = null;
    _cachedDailyTotals = null;

    await HomeWidget.saveWidgetData('saldo', 'Rp 0');
    await HomeWidget.saveWidgetData('pemasukan', '+ Rp 0');
    await HomeWidget.saveWidgetData('pengeluaran', '- Rp 0');
    await HomeWidget.saveWidgetData('tanggal', '-');
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  /// Saves weekly chart data for the widget.
  /// Only updates if data has changed.
  static Future<void> saveWeeklyChartData(List<double> dailyTotals) async {
    if (!PlatformUtils.isMobile) return;

    // Check if data changed
    if (_cachedDailyTotals != null &&
        _cachedDailyTotals!.length == dailyTotals.length) {
      bool changed = false;
      for (var i = 0; i < dailyTotals.length; i++) {
        if ((_cachedDailyTotals![i] - dailyTotals[i]).abs() > 0.01) {
          changed = true;
          break;
        }
      }
      if (!changed) return;
    }

    _cachedDailyTotals = List.from(dailyTotals);

    final padded = List<double>.from(dailyTotals);
    while (padded.length < 7) {
      padded.add(0);
    }

    // Batch all saves then single update
    await HomeWidget.saveWidgetData('chart_day1', padded[0].toStringAsFixed(0));
    await HomeWidget.saveWidgetData('chart_day2', padded[1].toStringAsFixed(0));
    await HomeWidget.saveWidgetData('chart_day3', padded[2].toStringAsFixed(0));
    await HomeWidget.saveWidgetData('chart_day4', padded[3].toStringAsFixed(0));
    await HomeWidget.saveWidgetData('chart_day5', padded[4].toStringAsFixed(0));
    await HomeWidget.saveWidgetData('chart_day6', padded[5].toStringAsFixed(0));
    await HomeWidget.saveWidgetData('chart_day7', padded[6].toStringAsFixed(0));

    final max = padded.reduce((a, b) => a > b ? a : b);
    await HomeWidget.saveWidgetData('chart_max', max.toStringAsFixed(0));

    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  /// Returns the click URL that opens the app.
  static String get clickAction => 'home_widget_example';

  static String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}rb';
    }
    return value.toStringAsFixed(0);
  }

  static String _formatTanggal(DateTime dt) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  /// Clears all cached values (call on logout or data reset)
  static void clearCache() {
    _cachedSaldo = null;
    _cachedPemasukan = null;
    _cachedPengeluaran = null;
    _cachedDailyTotals = null;
    _lastUpdate = null;
  }
}
