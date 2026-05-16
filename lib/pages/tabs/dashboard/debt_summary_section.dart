import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../theme/theme.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../utils/formatters.dart';
import 'shared_dashboard_widgets.dart';

class DebtSummarySection extends ConsumerWidget {
  const DebtSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final utangPiutangAsync = ref.watch(utangPiutangListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Utang & Piutang', isDark: isDark),
        const SizedBox(height: 10),
        utangPiutangAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
          data: (list) {
            final unpaidUtang = list
                .where((e) => e.jenis == 'utang' && !e.isLunas)
                .toList();
            final unpaidPiutang = list
                .where((e) => e.jenis == 'piutang' && !e.isLunas)
                .toList();

            final totalUtang = unpaidUtang.fold<double>(
              0.0,
              (sum, e) => sum + (e.nominalTotal - e.nominalDibayar),
            );
            final totalPiutang = unpaidPiutang.fold<double>(
              0.0,
              (sum, e) => sum + (e.nominalTotal - e.nominalDibayar),
            );

            if (unpaidUtang.isEmpty && unpaidPiutang.isEmpty) {
              return const EmptyStateCard(
                message: 'Tidak ada utang atau piutang aktif',
              );
            }

            return GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _DebtItem(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Utang',
                      count: unpaidUtang.length,
                      amount: totalUtang,
                      color: AppColors.coral,
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.3)
                        : AppColors.lightBorder,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: _DebtItem(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Piutang',
                      count: unpaidPiutang.length,
                      amount: totalPiutang,
                      color: AppColors.emerald,
                      isDark: isDark,
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

class _DebtItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final double amount;
  final Color color;
  final bool isDark;

  const _DebtItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.amount,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: amount),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              'Rp ${formatRupiahCompact(value)}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count item',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
