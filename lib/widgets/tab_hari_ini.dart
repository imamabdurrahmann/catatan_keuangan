import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/constants.dart';
import '../providers.dart';
import '../theme/theme.dart';
import '../utils/formatters.dart';
import 'transaksi_item_card.dart';

class TabHariIni extends ConsumerWidget {
  const TabHariIni({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = ref.watch(todayNormalizedProvider);
    final params = today;

    final todayTx = ref.watch(transaksiByDateProvider(params));

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withValues(alpha: 0.5)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(today),
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: todayTx.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (txList) {
              double pemasukan = 0;
              double pengeluaran = 0;
              for (var tx in txList) {
                if (tx.jenis == AppConstants.jenisPemasukan) {
                  pemasukan += tx.jumlah.toDouble();
                } else {
                  pengeluaran += tx.jumlah.toDouble();
                }
              }
              final saldo = pemasukan - pengeluaran;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCardElevated.withValues(alpha: 0.5)
                          : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _MiniSummary(
                              label: 'Pemasukan',
                              amount: pemasukan,
                              color: AppColors.emerald,
                              icon: Icons.arrow_downward_rounded,
                            ),
                            const SizedBox(width: 12),
                            _MiniSummary(
                              label: 'Pengeluaran',
                              amount: pengeluaran,
                              color: AppColors.coral,
                              icon: Icons.arrow_upward_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _BalanceRow(
                          label: 'Saldo Hari Ini',
                          amount: saldo,
                          isPositive: saldo >= 0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Transaksi Hari Ini',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('dd MMM yyyy', 'id_ID').format(today),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.emerald
                                : AppColors.primaryMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: txList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 48,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada transaksi\nhari ini',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: txList.length,
                            itemBuilder: (context, index) {
                              return TransaksiItemCard(
                                transaksi: txList[index],
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _MiniSummary({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
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
                Icon(
                  icon,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
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
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp ${formatRupiah(value)}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
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

class _BalanceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;

  const _BalanceRow({
    required this.label,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.gold : AppColors.coral;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : const Color(0xFF4B5563),
            ),
          ),
        ),
        SizedBox(
          width: 140,
          height: 24,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '${isPositive ? '+' : '-'} Rp ${formatRupiah(amount)}',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
