import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers.dart';
import '../../../data/database_helper.dart';
import '../../../theme/theme.dart';
import 'shared_dashboard_widgets.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../utils/formatters.dart';

// Provider for cached weekly spending data
final weeklySpendingProvider = FutureProvider.autoDispose<List<double>>((ref) async {
  ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

  // Fetch all transactions for the week in one query
  final startDate = days.first;
  final endDate = days.last.add(const Duration(days: 1));

  // Use a single query to get all transactions for the week
  final db = await DatabaseHelper.instance.database;
  final result = await db.query(
    'transaksi',
    where: 'tanggal >= ? AND tanggal < ? AND deleted_at IS NULL AND jenis = ?',
    whereArgs: [
      '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} 00:00:00',
      '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} 00:00:00',
      'pengeluaran',
    ],
  );

  // Build daily totals from transaction results
  final dailyTotals = List<double>.filled(7, 0.0);
  for (var row in result) {
    final tanggal = row['tanggal'] as String;
    final jumlah = (row['jumlah'] as num?)?.toDouble() ?? 0.0;
    // Parse date part from timestamp
    final datePart = tanggal.substring(0, 10);
    for (var i = 0; i < days.length; i++) {
      final dayStr = '${days[i].year}-${days[i].month.toString().padLeft(2, '0')}-${days[i].day.toString().padLeft(2, '0')}';
      if (datePart == dayStr) {
        dailyTotals[i] += jumlah;
        break;
      }
    }
  }

  return dailyTotals;
});

class WeeklySpendingChart extends ConsumerWidget {
  const WeeklySpendingChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Pengeluaran 7 Hari Terakhir', isDark: isDark),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: SizedBox(height: 180, child: _WeeklyBarChart(isDark: isDark)),
        ),
      ],
    );
  }
}

class _WeeklyBarChart extends ConsumerWidget {
  final bool isDark;

  const _WeeklyBarChart({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    final asyncData = ref.watch(weeklySpendingProvider);

    return asyncData.when(
      data: (dailyTotals) {
        final maxY = dailyTotals.isEmpty
            ? 100.0
            : dailyTotals.reduce((a, b) => a > b ? a : b);
        final chartMaxY = maxY > 0 ? maxY * 1.2 : 100.0;

        return Semantics(
          label: _buildSemanticLabel(dailyTotals, days),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: chartMaxY,
              minY: 0,
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= days.length) {
                        return const SizedBox();
                      }
                      const dayNames = [
                        'Sen',
                        'Sel',
                        'Rab',
                        'Kam',
                        'Jum',
                        'Sab',
                        'Min',
                      ];
                      final dayIndex = days[index].weekday - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          dayNames[dayIndex],
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox();
                      return Text(
                        formatRupiahCompact(value),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 9,
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: chartMaxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : AppColors.lightBorder,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (index) {
                final value = index < dailyTotals.length
                    ? dailyTotals[index]
                    : 0.0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      width: 20,
                      color: AppColors.coral,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: chartMaxY,
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.2)
                            : AppColors.lightBorder.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Error: $e',
          style: const TextStyle(color: AppColors.coral),
        ),
      ),
    );
  }

  String _buildSemanticLabel(List<double> dailyTotals, List<DateTime> days) {
    const dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final buffer = StringBuffer('Grafik pengeluaran 7 hari terakhir. ');
    for (var i = 0; i < days.length; i++) {
      final dayName = dayNames[days[i].weekday - 1];
      final value = i < dailyTotals.length ? dailyTotals[i] : 0.0;
      buffer.write('$dayName: Rp ${formatRupiah(value.toDouble())}. ');
    }
    return buffer.toString();
  }
}
