import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import '../../providers.dart';
import '../../theme/theme.dart';
import '../../widgets/common/glass_container.dart';
import '../../utils/formatters.dart';

class StatistikPage extends ConsumerWidget {
  final int tahun;
  final int bulan;

  const StatistikPage({super.key, required this.tahun, required this.bulan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (bulan: bulan, tahun: tahun);
    final summaryAsync = ref.watch(categorySummaryProvider(params));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Statistik',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0D2818),
                          const Color(0xFF1B5E20).withValues(alpha: 0.3),
                          AppColors.darkBg,
                        ]
                      : [
                          const Color(0xFF1B5E20),
                          const Color(0xFF2E7D32),
                          AppColors.lightBg,
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Month header
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  DateFormat(
                    'MMMM yyyy',
                    'id_ID',
                  ).format(DateTime(tahun, bulan)),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: AppColors.coral),
                ),
              ),
              data: (summary) {
                if (summary.isEmpty) {
                  return _buildEmpty(context);
                }
                final total = summary.values.fold(0.0, (a, b) => a + b);
                final sortedEntries = summary.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppColors.expenseGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.pie_chart_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Pengeluaran',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: total),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Text(
                                      'Rp ${formatRupiah(value)}',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A2E),
                                        letterSpacing: -0.5,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.coral.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${sortedEntries.length} kategori',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.coral,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    total > 0
                        ? Container(
                            height: 220,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: RepaintBoundary(
                              child: Semantics(
                                label:
                                    'Diagram pengeluaran bulanan per kategori',
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 45,
                                    sections: sortedEntries.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final catEntry = entry.value;
                                      final percentage =
                                          catEntry.value / total * 100;
                                      final colors = [
                                        AppColors.coral,
                                        AppColors.emerald,
                                        AppColors.gold,
                                        AppColors.teal,
                                        const Color(0xFF8B5CF6),
                                        const Color(0xFFF97316),
                                        const Color(0xFF06B6D4),
                                        const Color(0xFFEC4899),
                                      ];
                                      final color =
                                          colors[index % colors.length];
                                      return PieChartSectionData(
                                        color: color,
                                        value: catEntry.value,
                                        title:
                                            '${percentage.toStringAsFixed(0)}%',
                                        radius: 55,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    ...sortedEntries.map((entry) {
                      final percentage = total > 0
                          ? (entry.value / total * 100)
                          : 0.0;
                      return _CategoryStatCard(
                        category: entry.key,
                        amount: entry.value,
                        percentage: percentage,
                        index: sortedEntries.indexOf(entry),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            child: Lottie.network(
              'https://lottie.host/81b2e2d0-61f4-419b-aef7-b2f15f92dbce/8N7VfPIfPZ.json',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.emerald : AppColors.primaryMid)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 48,
                    color: (isDark ? AppColors.emerald : AppColors.primaryMid)
                        .withValues(alpha: 0.4),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data statistik',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStatCard extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final int index;

  const _CategoryStatCard({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      AppColors.coral,
      AppColors.emerald,
      AppColors.gold,
      AppColors.teal,
      const Color(0xFF8B5CF6),
      const Color(0xFFF97316),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.category_rounded, size: 16, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${formatRupiah(amount)}',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage / 100),
              duration: Duration(milliseconds: 600 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.5)
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
