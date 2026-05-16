import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../theme/theme.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../utils/formatters.dart';
import 'shared_dashboard_widgets.dart';

class SavingsGoalsSection extends ConsumerWidget {
  const SavingsGoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabunganAsync = ref.watch(tabunganImpianListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Tabungan Impian', isDark: isDark),
        const SizedBox(height: 10),
        tabunganAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
          data: (list) {
            if (list.isEmpty) {
              return const EmptyStateCard(message: 'Belum ada tabungan impian');
            }

            return Column(
              children: list.map((tabungan) {
                final percentage = tabungan.targetNominal > 0
                    ? (tabungan.terkumpul / tabungan.targetNominal).clamp(
                        0.0,
                        1.0,
                      )
                    : 0.0;
                final pct = (percentage * 100).toInt();

                Color barColor;
                if (percentage > 0.75) {
                  barColor = AppColors.emerald;
                } else if (percentage > 0.5) {
                  barColor = AppColors.gold;
                } else {
                  barColor = AppColors.coral;
                }

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
                                color: barColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.savings_rounded,
                                size: 16,
                                color: barColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tabungan.namaImpian,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: barColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$pct%',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: barColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: percentage),
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp ${formatRupiahCompact(tabungan.terkumpul)}',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: barColor,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Target: Rp ${formatRupiahCompact(tabungan.targetNominal)}',
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
