import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../widgets/common/widgets.dart';
import 'dashboard/balance_overview_card.dart';
import 'dashboard/income_expense_row.dart';
import 'dashboard/budget_progress_section.dart';
import 'dashboard/savings_goals_section.dart';
import 'dashboard/debt_summary_section.dart';
import 'dashboard/weekly_spending_chart.dart';
import 'dashboard/category_pie_chart.dart';
import '../gamification/user_level_widget.dart';
import '../../widgets/common/dompet_switcher.dart';

class TabDashboard extends ConsumerWidget {
  const TabDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bulan = ref.watch(selectedMonthProvider);
    final tahun = ref.watch(selectedYearProvider);
    final params = (bulan: bulan, tahun: tahun);

    // Watch loading states from providers
    final dompetAsync = ref.watch(dompetProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider(params));
    final budgetAsync = ref.watch(budgetListProvider(params));

    return Semantics(
      label: 'Halaman utama dompet, menampilkan ringkasan saldo dan statistik keuangan',
      child: Scrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer loading for balance card
              if (dompetAsync.isLoading)
                const ShimmerBalanceCard()
              else
                Semantics(
                  label: 'Kartu ringkasan saldo',
                  child: BalanceOverviewCard(params: params),
                ),
              const SizedBox(height: 12),
              const UserLevelWidget(),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: DompetSwitcher(),
              ),
              const SizedBox(height: 12),
              // Shimmer loading for income/expense row
              if (summaryAsync.isLoading)
                Row(
                  children: [
                    Expanded(child: ShimmerIncomeExpenseCard(isIncome: true)),
                    const SizedBox(width: 10),
                    Expanded(child: ShimmerIncomeExpenseCard(isIncome: false)),
                  ],
                )
              else
                Semantics(
                  label: 'Ringkasan pemasukan dan pengeluaran bulan ini',
                  child: IncomeExpenseRow(params: params),
                ),
              const SizedBox(height: 20),
              // Shimmer loading for budget section
              if (budgetAsync.isLoading)
                const ShimmerDashboardSection(height: 150)
              else
                Semantics(
                  label: 'Progres anggaran',
                  child: BudgetProgressSection(params: params),
                ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Target tabungan',
                child: SavingsGoalsSection(),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Ringkasan hutang',
                child: DebtSummarySection(),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Grafik pengeluaran mingguan',
                child: WeeklySpendingChart(),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Grafik kategori pengeluaran',
                child: CategoryPieChart(params: params),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
