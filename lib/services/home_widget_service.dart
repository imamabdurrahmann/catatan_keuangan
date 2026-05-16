import '../utils/platform_utils.dart';

// Conditionally import home_widget only on mobile
// On desktop, all methods are no-ops.
import 'package:home_widget/home_widget.dart'
    if (dart.library.io) 'package:home_widget/home_widget.dart';

/// Service for managing the Android home screen widget.
/// All methods are no-ops on desktop platforms.
class HomeWidgetService {
  static const _appGroupId = 'catatan_keuangan_widget';
  static const _androidWidgetName = 'CatatanKeuanganWidget';

  /// Initializes the home widget.
  static Future<void> initialize() async {
    if (!PlatformUtils.isMobile) return;
    // Set app group ID for shared data (used for widget updates)
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Updates the widget with current balance data.
  static Future<void> updateWidget({
    required double totalSaldo,
    required double totalPemasukan,
    required double totalPengeluaran,
  }) async {
    if (!PlatformUtils.isMobile) return;
    await HomeWidget.saveWidgetData('saldo', 'Rp ${_formatNumber(totalSaldo)}');
    await HomeWidget.saveWidgetData(
      'pemasukan',
      '+ Rp ${_formatNumber(totalPemasukan)}',
    );
    await HomeWidget.saveWidgetData(
      'pengeluaran',
      '- Rp ${_formatNumber(totalPengeluaran)}',
    );
    await HomeWidget.saveWidgetData('tanggal', _formatTanggal(DateTime.now()));
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  /// Clears widget data (shown when no data available).
  static Future<void> clearWidget() async {
    if (!PlatformUtils.isMobile) return;
    await HomeWidget.saveWidgetData('saldo', 'Rp 0');
    await HomeWidget.saveWidgetData('pemasukan', '+ Rp 0');
    await HomeWidget.saveWidgetData('pengeluaran', '- Rp 0');
    await HomeWidget.saveWidgetData('tanggal', '-');
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  /// Saves weekly chart data for the widget.
  static Future<void> saveWeeklyChartData(List<double> dailyTotals) async {
    if (!PlatformUtils.isMobile) return;
    final padded = List<double>.from(dailyTotals);
    while (padded.length < 7) {
      padded.add(0);
    }

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
    final bulan = [
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
}
