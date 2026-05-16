import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers.dart';
import '../../../theme/theme.dart';
import '../../../utils/formatters.dart';

class BalanceOverviewCard extends ConsumerWidget {
  final ({int bulan, int tahun}) params;

  const BalanceOverviewCard({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.incomeGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saldo',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    _MonthYearLabel(bulan: params.bulan, tahun: params.tahun),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Aktif',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _AnimatedBalance(),
        ],
      ),
    );
  }
}

class _MonthYearLabel extends StatelessWidget {
  final int bulan;
  final int tahun;

  const _MonthYearLabel({required this.bulan, required this.tahun});

  @override
  Widget build(BuildContext context) {
    // DateFormat created once per instance rather than per build
    return Text(
      DateFormat('MMMM yyyy', 'id_ID').format(DateTime(tahun, bulan)),
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 10,
        color: Colors.white.withValues(alpha: 0.6),
      ),
    );
  }
}

class _AnimatedBalance extends ConsumerStatefulWidget {
  const _AnimatedBalance();

  @override
  ConsumerState<_AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends ConsumerState<_AnimatedBalance> {
  double _displayedSaldo = 0;
  int _displayedCount = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final dompetAsync = ref.watch(dompetProvider);

    return dompetAsync.when(
      loading: () {
        if (!_isLoading) {
          _isLoading = true;
        }
        return _buildContent(_displayedSaldo, _displayedCount, true);
      },
      error: (_, __) {
        return _buildContent(_displayedSaldo, _displayedCount, false);
      },
      data: (dompetList) {
        double totalSaldo = 0;
        for (var d in dompetList) {
          totalSaldo += d.saldo;
        }
        _displayedSaldo = totalSaldo;
        _displayedCount = dompetList.length;
        _isLoading = false;
        return TweenAnimationBuilder<double>(
          key: ValueKey(totalSaldo),
          tween: Tween(begin: 0, end: totalSaldo),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return _buildContent(value, dompetList.length, false);
          },
        );
      },
    );
  }

  Widget _buildContent(double saldo, int count, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rp ${formatRupiahCompact(saldo)}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white70),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count dompet aktif',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
