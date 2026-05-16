import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
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

    return Scrollbar(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceOverviewCard(params: params),
            const SizedBox(height: 12),
            const UserLevelWidget(),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: DompetSwitcher(),
            ),
            const SizedBox(height: 12),
            IncomeExpenseRow(params: params),
            const SizedBox(height: 20),
            BudgetProgressSection(params: params),
            const SizedBox(height: 20),
            const SavingsGoalsSection(),
            const SizedBox(height: 20),
            const DebtSummarySection(),
            const SizedBox(height: 20),
            const WeeklySpendingChart(),
            const SizedBox(height: 20),
            CategoryPieChart(params: params),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
