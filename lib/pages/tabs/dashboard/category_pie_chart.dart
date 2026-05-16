import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers.dart';
import '../../../theme/theme.dart';
import '../../../widgets/common/glass_container.dart';
import 'shared_dashboard_widgets.dart';
import '../../../utils/formatters.dart';

class CategoryPieChart extends ConsumerWidget {
  final ({int bulan, int tahun}) params;

  const CategoryPieChart({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(categorySummaryProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Pengeluaran per Kategori', isDark: isDark),
        const SizedBox(height: 10),
        summaryAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
          data: (summary) {
            if (summary.isEmpty) {
              return const EmptyStateCard(message: 'Belum ada data kategori');
            }

            final sorted = summary.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final total = sorted.fold<double>(0.0, (sum, e) => sum + e.value);

            final top5 = sorted.take(5).toList();
            final lainnya = sorted.skip(5).toList();
            final lainnyaTotal = lainnya.fold<double>(
              0.0,
              (sum, e) => sum + e.value,
            );

            final pieEntries = <MapEntry<String, double>>[];
            for (var entry in top5) {
              pieEntries.add(MapEntry(entry.key, entry.value));
            }
            if (lainnyaTotal > 0) {
              pieEntries.add(MapEntry('Lainnya', lainnyaTotal));
            }

            final pieColors = [
              AppColors.coral,
              AppColors.emerald,
              AppColors.gold,
              AppColors.teal,
              const Color(0xFF8B5CF6),
              const Color(0xFFF97316),
            ];

            return GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            label: 'Diagram pengeluaran per kategori',
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 30,
                                sections: pieEntries.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final catEntry = entry.value;
                                  final pct = total > 0
                                      ? (catEntry.value / total * 100)
                                      : 0.0;
                                  return PieChartSectionData(
                                    color: pieColors[index % pieColors.length],
                                    value: catEntry.value,
                                    title: '${pct.toStringAsFixed(0)}%',
                                    radius: 45,
                                    titleStyle: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: pieEntries.asMap().entries.map((entry) {
                              final index = entry.key;
                              final catEntry = entry.value;
                              final color = pieColors[index % pieColors.length];
                              final pct = total > 0
                                  ? (catEntry.value / total * 100)
                                  : 0.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        catEntry.key,
                                        style: TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white70
                                              : const Color(0xFF6B7280),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${pct.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'Total pengeluaran bulanan',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: 'Total pengeluaran bulan ini',
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: AppColors.coral.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Total: Rp ${formatRupiahCompact(total)}',
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
