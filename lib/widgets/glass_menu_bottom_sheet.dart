import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../pages/wallets_categories/kelola_dompet_sheet.dart';
import '../pages/wallets_categories/kelola_kategori_sheet.dart';
import '../pages/budget_savings/budget_sheet.dart';
import '../pages/actions/recurring_transaksi_sheet.dart';
import '../pages/actions/trash_sheet.dart';
import '../pages/settings_security/backup_page.dart';

void showGlassMenu(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Menu', style: AppTypography.titleLarge(context)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildMenuTile(ctx, Icons.settings_rounded, 'Pengaturan', () {
              Navigator.pop(ctx);
              context.push('/settings');
            }),
            _buildMenuTile(
              ctx,
              Icons.account_balance_wallet_rounded,
              'Kelola Dompet',
              () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (c) => Material(
                    color: Colors.transparent,
                    child: Consumer(
                      builder: (c, sheetRef, _) => KelolaDompetSheet(
                        onSaved: () => sheetRef.invalidate(dompetProvider),
                      ),
                    ),
                  ),
                );
              },
            ),
            _buildMenuTile(ctx, Icons.savings_rounded, 'Atur Budget', () {
              Navigator.pop(ctx);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (c) => Material(
                  color: Colors.transparent,
                  child: BudgetSheet(
                    tahun: ref.read(selectedYearProvider),
                    bulan: ref.read(selectedMonthProvider),
                  ),
                ),
              );
            }),
            _buildMenuTile(ctx, Icons.category_rounded, 'Kelola Kategori', () {
              Navigator.pop(ctx);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (c) => const Material(
                  color: Colors.transparent,
                  child: KelolaKategoriSheet(onChanged: null),
                ),
              );
            }),
            _buildMenuTile(ctx, Icons.pie_chart_rounded, 'Statistik', () {
              Navigator.pop(ctx);
              final tahun = ref.read(selectedYearProvider);
              final bulan = ref.read(selectedMonthProvider);
              context.push('/statistik?tahun=$tahun&bulan=$bulan');
            }),
            _buildMenuTile(ctx, Icons.repeat_rounded, 'Transaksi Berulang', () {
              Navigator.pop(ctx);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (c) => Material(
                  color: Colors.transparent,
                  child: Consumer(
                    builder: (c, sheetRef, _) => RecurringTransaksiSheet(
                      onSaved: () => sheetRef
                          .read(updateSignalsProvider.notifier)
                          .signal('transaksi'),
                    ),
                  ),
                ),
              );
            }),
            _buildMenuTile(ctx, Icons.upload_rounded, 'Backup & Pulihkan', () {
              Navigator.pop(ctx);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const BackupPage()));
            }),
            _buildMenuTile(
              ctx,
              Icons.delete_outline_rounded,
              'Tong Sampah',
              () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (c) => Material(
                    color: Colors.transparent,
                    child: TrashSheet(
                      onPulihkan: () => ref
                          .read(updateSignalsProvider.notifier)
                          .signal('transaksi'),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  'Made by Abdurahman',
                  style: AppTypography.labelSmall(
                    ctx,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMenuTile(
  BuildContext ctx,
  IconData icon,
  String title,
  VoidCallback onTap,
) {
  final isDark = Theme.of(ctx).brightness == Brightness.dark;
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.emerald : AppColors.primaryMid,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTypography.bodyLarge(
                ctx,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );
}
