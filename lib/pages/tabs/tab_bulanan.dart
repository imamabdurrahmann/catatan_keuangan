import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers.dart';
import '../../theme/theme.dart';
import '../../widgets/common/glass_container.dart';
import '../../utils/formatters.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/transaksi_item_card.dart';
import '../../data/database_helper.dart';
import 'shared_tab_widgets.dart';

class TabBulanan extends ConsumerStatefulWidget {
  const TabBulanan({super.key});

  @override
  ConsumerState<TabBulanan> createState() => _TabBulananState();
}

class _TabBulananState extends ConsumerState<TabBulanan>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bulan = ref.watch(selectedMonthProvider);
    final tahun = ref.watch(selectedYearProvider);
    final params = (bulan: bulan, tahun: tahun);

    final summaryAsync = ref.watch(monthlySummaryProvider(params));

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: AppDecorations.glassCard(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DateNavButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () {
                  ref.read(bulananPageProvider.notifier).reset();
                  if (bulan == 1) {
                    ref.read(selectedMonthProvider.notifier).setMonth(12);
                    ref.read(selectedYearProvider.notifier).decrement();
                  } else {
                    ref.read(selectedMonthProvider.notifier).decrement();
                  }
                },
                tooltip: 'Bulan sebelumnya',
              ),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(tahun, bulan),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    ref.read(bulananPageProvider.notifier).reset();
                    ref
                        .read(selectedMonthProvider.notifier)
                        .setMonth(picked.month);
                    ref
                        .read(selectedYearProvider.notifier)
                        .setYear(picked.year);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _BulananDateLabel(bulan: bulan, tahun: tahun),
                ),
              ),
              DateNavButton(
                icon: Icons.chevron_right_rounded,
                onPressed: () {
                  ref.read(bulananPageProvider.notifier).reset();
                  if (bulan == 12) {
                    ref.read(selectedMonthProvider.notifier).setMonth(1);
                    ref.read(selectedYearProvider.notifier).increment();
                  } else {
                    ref.read(selectedMonthProvider.notifier).increment();
                  }
                },
                tooltip: 'Bulan berikutnya',
              ),
            ],
          ),
        ),
        Expanded(
          child: summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => buildErrorWidget(e.toString()),
            data: (summary) => Column(
              children: [
                const _DompetDropdown(),
                const SizedBox(height: 4),
                Expanded(
                  child: _BulananContent(summary: summary, params: params),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BulananDateLabel extends StatelessWidget {
  final int bulan;
  final int tahun;

  const _BulananDateLabel({required this.bulan, required this.tahun});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('MMMM yyyy', 'id_ID').format(DateTime(tahun, bulan)),
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1A1A2E),
      ),
    );
  }
}

class _BulananContent extends ConsumerStatefulWidget {
  final Map<String, double> summary;
  final ({int bulan, int tahun}) params;

  const _BulananContent({required this.summary, required this.params});

  @override
  ConsumerState<_BulananContent> createState() => _BulananContentState();
}

class _BulananContentState extends ConsumerState<_BulananContent> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _BulananContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.params.bulan != widget.params.bulan ||
        oldWidget.params.tahun != widget.params.tahun) {
      ref.read(bulananPageProvider.notifier).reset();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final hasMore =
          ref.read(hasMoreBulananProvider(widget.params)).value ?? false;
      if (hasMore) {
        ref.read(bulananPageProvider.notifier).increment();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pemasukan = widget.summary['pemasukan'] ?? 0;
    final pengeluaran = widget.summary['pengeluaran'] ?? 0;
    final saldo = widget.summary['saldo'] ?? 0;
    final txAsync = ref.watch(paginatedTransaksiByMonthProvider(widget.params));
    final hasMoreAsync = ref.watch(hasMoreBulananProvider(widget.params));

    return Scrollbar(
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _SummaryMiniCard(
                          label: 'Pemasukan',
                          amount: pemasukan,
                          gradient: AppColors.incomeGradient,
                          icon: Icons.arrow_downward_rounded,
                          accentColor: AppColors.emerald,
                        ),
                        const SizedBox(width: 12),
                        _SummaryMiniCard(
                          label: 'Pengeluaran',
                          amount: pengeluaran,
                          gradient: AppColors.expenseGradient,
                          icon: Icons.arrow_upward_rounded,
                          accentColor: AppColors.coral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SummaryBalanceCard(amount: saldo, isDark: isDark),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _BudgetWarningList(params: widget.params),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'Transaksi Bulan Ini',
                    style: AppTypography.titleMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: AppDecorations.pillBadge(
                      isDark ? AppColors.emerald : AppColors.primaryMid,
                    ),
                    child: Text(
                      DateFormat('MMM yyyy', 'id_ID').format(
                        DateTime(widget.params.tahun, widget.params.bulan),
                      ),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.emerald
                            : AppColors.primaryMid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          txAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox()),
            error: (e, _) =>
                SliverToBoxAdapter(child: buildErrorWidget(e.toString())),
            data: (txList) {
              if (txList.isEmpty) {
                return SliverFillRemaining(
                  child: buildEmptyState(
                    context,
                    Icons.inbox_rounded,
                    'Belum ada transaksi\nbulan ini',
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == txList.length) {
                    return hasMoreAsync.when(
                      data: (hasMore) => hasMore
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 0),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox(height: 0),
                    );
                  }
                  return TransaksiItemCard(
                    transaksi: txList[index],
                    onDismissed: () async {
                      final tx = txList[index];
                      final id = tx.id;
                      if (id != null) {
                        await DatabaseHelper.instance.softDeleteTransaksi(id);
                        ref.read(updateSignalsProvider.notifier).signal('transaksi');
                        ref.invalidate(transaksiProvider);
                        ref.invalidate(dompetProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Transaksi "${tx.deskripsi.isEmpty ? tx.kategori : tx.deskripsi}" dihapus'),
                              action: SnackBarAction(
                                label: 'BATAL',
                                onPressed: () async {
                                  await DatabaseHelper.instance.restoreTransaksi(id);
                                  ref.read(updateSignalsProvider.notifier).signal('transaksi');
                                  ref.invalidate(transaksiProvider);
                                  ref.invalidate(dompetProvider);
                                },
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  );
                }, childCount: txList.length + 1),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  final String label;
  final double amount;
  final LinearGradient gradient;
  final IconData icon;
  final Color accentColor;

  const _SummaryMiniCard({
    required this.label,
    required this.amount,
    required this.gradient,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
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

class _SummaryBalanceCard extends StatelessWidget {
  final double amount;
  final bool isDark;

  const _SummaryBalanceCard({required this.amount, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    final balanceColor = isPositive ? AppColors.gold : AppColors.coral;
    final sign = isPositive ? '+' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardElevated.withValues(alpha: 0.5)
            : AppColors.lightBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: balanceColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: balanceColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 20,
              color: balanceColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Bulan Ini',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: amount),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$sign Rp ${formatRupiah(value)}',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: balanceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: balanceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              size: 16,
              color: balanceColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetWarningList extends ConsumerWidget {
  final ({int bulan, int tahun}) params;

  const _BudgetWarningList({required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetListProvider(params));
    final summaryAsync = ref.watch(categorySummaryProvider(params));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!budgetAsync.hasValue || !summaryAsync.hasValue) {
      return const SizedBox();
    }

    final budgets = budgetAsync.value!;
    final summaries = summaryAsync.value!;

    final warnings = <Widget>[];

    for (var budget in budgets) {
      if (budget.nominal <= 0) continue;
      final spent = summaries[budget.kategori] ?? 0.0;
      final percentage = spent / budget.nominal;

      if (percentage >= 0.8) {
        final isOver = percentage > 1.0;
        final color = isOver ? AppColors.coral : AppColors.gold;
        final message = isOver
            ? 'Melebihi budget ${budget.kategori}!'
            : '${(percentage * 100).toInt()}% budget ${budget.kategori} terpakai';

        warnings.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: AppDecorations.glassCardElevated(
              context,
            ).copyWith(border: Border.all(color: color.withValues(alpha: 0.5))),
            child: Row(
              children: [
                Icon(
                  isOver ? Icons.warning_rounded : Icons.info_outline_rounded,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '${formatRupiahCompact(spent)} / ${formatRupiahCompact(budget.nominal)}',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (warnings.isEmpty) return const SizedBox();

    return Column(children: warnings);
  }
}

class _DompetDropdown extends ConsumerWidget {
  const _DompetDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dompetAsync = ref.watch(dompetProvider);
    final selectedId = ref.watch(selectedDompetFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return dompetAsync.when(
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox(height: 48),
      data: (dompetList) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: AppDecorations.glassCard(context),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: selectedId,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkCardElevated : Colors.white,
              borderRadius: BorderRadius.circular(16),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white70 : AppColors.primaryMid,
              ),
              hint: const Text('Pilih Dompet'),
              selectedItemBuilder: (BuildContext context) {
                final List<Widget> items = [
                  const Row(
                    children: [
                      Icon(Icons.wallet_rounded, color: AppColors.emerald, size: 20),
                      SizedBox(width: 10),
                      Text('Semua Dompet', style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700)),
                    ],
                  ),
                ];
                items.addAll(dompetList.map((d) {
                  final color = getAppColor(d.warna);
                  return Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, color: color, size: 20),
                      const SizedBox(width: 10),
                      Text(d.nama, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700)),
                    ],
                  );
                }));
                return items;
              },
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.wallet_rounded, color: isDark ? AppColors.emerald : AppColors.primaryMid, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Semua Dompet',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                ...dompetList.map((d) {
                  final color = getAppColor(d.warna);
                  return DropdownMenuItem<int?>(
                    value: d.id,
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, color: color, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          d.nama,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                ref.read(selectedDompetFilterProvider.notifier).set(value);
                ref.read(bulananPageProvider.notifier).reset();
              },
            ),
          ),
        );
      },
    );
  }
}
