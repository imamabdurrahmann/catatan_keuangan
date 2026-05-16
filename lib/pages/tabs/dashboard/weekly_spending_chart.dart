import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers.dart';
import '../../../theme/theme.dart';
import 'shared_dashboard_widgets.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../utils/formatters.dart';

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

  String _buildSemanticLabel(List<double> dailyTotals, List<DateTime> days) {
    final dayNames = [
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return FutureBuilder<List<dynamic>>(
      future: Future.wait(
        days.map((d) => ref.read(transaksiByDateProvider(d).future)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: AppColors.coral),
            ),
          );
        }

        final dailyTotals = snapshot.data!
            .map<List<double>>((txList) {
              double expense = 0;
              for (var t in txList) {
                if (t.jenis == 'pengeluaran') expense += t.jumlah;
              }
              return [expense];
            })
            .expand((x) => x)
            .toList();

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
                      if (index < 0 || index >= days.length)
                        return const SizedBox();
                      final dayNames = [
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
    );
  }
}
