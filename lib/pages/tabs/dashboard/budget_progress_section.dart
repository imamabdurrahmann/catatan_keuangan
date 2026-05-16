import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../theme/theme.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../utils/formatters.dart';
import 'shared_dashboard_widgets.dart';

class BudgetProgressSection extends ConsumerWidget {
  final ({int bulan, int tahun}) params;

  const BudgetProgressSection({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetAsync = ref.watch(budgetListProvider(params));
    final summaryAsync = ref.watch(categorySummaryProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Anggaran Bulan Ini', isDark: isDark),
        const SizedBox(height: 10),
        budgetAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
          data: (budgets) {
            if (budgets.isEmpty)
              return const EmptyStateCard(message: 'Belum ada anggaran');

            final summaries = summaryAsync.value ?? {};

            final budgetsWithValues = budgets
                .where((b) => b.nominal > 0)
                .toList();

            if (budgetsWithValues.isEmpty) {
              return const EmptyStateCard(message: 'Belum ada anggaran');
            }

            return GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: budgetsWithValues.map((budget) {
                  final spent = summaries[budget.kategori] ?? 0.0;
                  final percentage = budget.nominal > 0
                      ? (spent / budget.nominal).clamp(0.0, 1.5)
                      : 0.0;
                  final pct = (percentage * 100).toInt();

                  Color barColor;
                  if (percentage < 0.6) {
                    barColor = AppColors.emerald;
                  } else if (percentage < 0.8) {
                    barColor = AppColors.gold;
                  } else {
                    barColor = AppColors.coral;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                budget.kategori,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: barColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: percentage.clamp(0.0, 1.0),
                          ),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkBorder.withValues(
                                            alpha: 0.5,
                                          )
                                        : AppColors.lightBorder,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: value,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          barColor,
                                          barColor.withValues(alpha: 0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: barColor.withValues(
                                            alpha: 0.3,
                                          ),
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
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${formatRupiahCompact(spent)} / Rp ${formatRupiahCompact(budget.nominal)}',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
