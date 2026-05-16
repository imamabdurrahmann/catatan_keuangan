import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers.dart';
import '../../data/database_helper.dart';
import '../../data/daos/budget_dao.dart';
import '../../services/budget_alert_service.dart';
import '../../utils/formatters.dart';
import '../../utils/ui_utils.dart';

/// Provider for budget with rollover (ensures rollover is calculated)
final budgetWithRolloverProvider =
    FutureProvider.family<
      Budget?,
      ({int bulan, int tahun, String kategori, int? profilId})
    >((ref, params) async {
      final db = await DatabaseHelper.instance.database;
      final dao = BudgetDao(db);
      return dao.getOrCreateBudgetWithRollover(
        params.bulan,
        params.tahun,
        params.kategori,
        profilId: params.profilId,
      );
    });

/// Provider for all budgets with rollover for a month
final budgetListWithRolloverProvider =
    FutureProvider.family<
      List<Budget>,
      ({int bulan, int tahun, int? profilId})
    >((ref, params) async {
      final db = await DatabaseHelper.instance.database;
      final dao = BudgetDao(db);

      // First get all regular budgets
      final budgets = await dao.getAllBudget(
        params.bulan,
        params.tahun,
        profilId: params.profilId,
      );

      // Sync rollover for any budgets that don't have it yet
      for (var budget in budgets) {
        if (budget.sisaRollover == 0) {
          final rolloverAmount = await dao.calculateRemainingBudget(
            params.bulan,
            params.tahun,
            budget.kategori,
            profilId: params.profilId,
          );
          if (rolloverAmount > 0) {
            final updatedBudget = budget.copyWith(sisaRollover: rolloverAmount);
            await dao.updateBudget(updatedBudget);
          }
        }
      }

      // Return updated list
      return dao.getAllBudget(
        params.bulan,
        params.tahun,
        profilId: params.profilId,
      );
    });

class BudgetSheet extends ConsumerWidget {
  final int tahun;
  final int bulan;

  const BudgetSheet({super.key, required this.tahun, required this.bulan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (bulan: bulan, tahun: tahun);
    // Use budget list with rollover provider
    final budgetAsync = ref.watch(
      budgetListWithRolloverProvider((
        bulan: bulan,
        tahun: tahun,
        profilId: null,
      )),
    );
    final kategoriAsync = ref.watch(kategoriByJenisProvider('pengeluaran'));
    final summaryAsync = ref.watch(categorySummaryProvider(params));

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(tahun, bulan))}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: kategoriAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (kategoriList) => budgetAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (budgetList) => summaryAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (categorySummary) => ListView.builder(
                      controller: scrollController,
                      itemCount: kategoriList.length,
                      itemBuilder: (context, index) {
                        final k = kategoriList[index];
                        final budget = budgetList
                            .where((b) => b.kategori == k.nama)
                            .firstOrNull;
                        final spent = categorySummary[k.nama] ?? 0;
                        final budgetAmount = budget?.nominal ?? 0;
                        final rolloverAmount = budget?.sisaRollover ?? 0;
                        final totalBudget = budgetAmount + rolloverAmount;
                        final progress = totalBudget > 0
                            ? (spent / totalBudget).clamp(0.0, 1.0)
                            : 0.0;
                        final isOverBudget =
                            spent > totalBudget && totalBudget > 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      getAppIcon(k.icon),
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        k.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      rolloverAmount > 0
                                          ? 'Rp ${formatRupiah(spent)} / Rp ${formatRupiah(totalBudget)} (+${formatRupiah(rolloverAmount)} rollover)'
                                          : 'Rp ${formatRupiah(spent)} / Rp ${formatRupiah(budgetAmount)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isOverBudget
                                            ? Colors.red
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _setBudget(
                                        context,
                                        ref,
                                        k,
                                        budget,
                                        params,
                                      ),
                                      tooltip: 'Edit budget ${k.nama}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(
                                    isOverBudget
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setBudget(
    BuildContext context,
    WidgetRef ref,
    Kategori kategori,
    Budget? existing,
    ({int bulan, int tahun}) params,
  ) async {
    final controller = TextEditingController();
    if (existing != null) {
      if (existing.nominal > 0) {
        controller.text = formatRupiah(existing.nominal);
      }
    }

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Budget: ${kategori.nama}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          decoration: const InputDecoration(
            labelText: 'Nominal Anggaran',
            prefixText: 'Rp ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = parseRupiah(controller.text);
              Navigator.pop(ctx, value);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      if (existing != null) {
        // Preserve existing rollover when updating nominal
        await DatabaseHelper.instance.updateBudget(
          Budget(
            id: existing.id,
            bulan: params.bulan,
            tahun: params.tahun,
            nominal: result,
            kategori: kategori.nama,
            profilId: existing.profilId,
            sisaRollover: existing.sisaRollover,
          ),
        );
      } else {
        await DatabaseHelper.instance.insertBudget(
          Budget(
            bulan: params.bulan,
            tahun: params.tahun,
            nominal: result,
            kategori: kategori.nama,
          ),
        );
      }
      ref.invalidate(budgetListProvider(params));
      ref.invalidate(
        budgetListWithRolloverProvider((
          bulan: params.bulan,
          tahun: params.tahun,
          profilId: null,
        )),
      );
      ref.invalidate(categorySummaryProvider(params));

      // Trigger budget alert check after saving
      await BudgetAlertService.instance.checkBudgetAlertsForMonth(
        params.bulan,
        params.tahun,
      );
    }
  }
}
