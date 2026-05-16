import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../theme/theme.dart';
import '../../../utils/formatters.dart';

class IncomeExpenseRow extends ConsumerWidget {
  final ({int bulan, int tahun}) params;

  const IncomeExpenseRow({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider(params));

    return summaryAsync.when(
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox(height: 100),
      data: (summary) {
        final pemasukan = summary['pemasukan'] ?? 0.0;
        final pengeluaran = summary['pengeluaran'] ?? 0.0;

        return Row(
          children: [
            Expanded(
              child: _MiniCard(
                label: 'Pemasukan',
                amount: pemasukan,
                icon: Icons.arrow_downward_rounded,
                gradient: AppColors.incomeGradient,
                accentColor: AppColors.emerald,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniCard(
                label: 'Pengeluaran',
                amount: pengeluaran,
                icon: Icons.arrow_upward_rounded,
                gradient: AppColors.expenseGradient,
                accentColor: AppColors.coral,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;

  const _MiniCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: Rp ${formatRupiahCompact(amount)}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  label: 'Ikon $label',
                  child: Icon(
                    icon,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: amount),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp ${formatRupiahCompact(value)}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
