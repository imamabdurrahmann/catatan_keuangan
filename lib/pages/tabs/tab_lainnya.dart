import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers.dart';
import '../../theme/theme.dart';
import '../../widgets/common/glass_container.dart';
import '../wallets_categories/kelola_dompet_sheet.dart';
import '../wallets_categories/kelola_kategori_sheet.dart';
import '../budget_savings/budget_sheet.dart';
import '../actions/recurring_transaksi_sheet.dart';
import '../actions/trash_sheet.dart';
import '../reports_stats/laporan_sheet.dart';
import '../settings_security/backup_page.dart';
import '../insights/insights_page.dart';
import '../profiles/profile_selector_sheet.dart';
import '../gamification/smart_receipt_folder_page.dart';
import '../gamification/user_level_widget.dart';
import '../../services/auth_service.dart';

class TabLainnya extends ConsumerStatefulWidget {
  const TabLainnya({super.key});

  @override
  ConsumerState<TabLainnya> createState() => _TabLainnyaState();
}

class _TabLainnyaState extends ConsumerState<TabLainnya>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Header card
          GlassContainer(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'DompetKu',
                  style: AppTypography.titleLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola keuanganmu dengan mudah',
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: AppDecorations.pillBadge(
                    isDark ? AppColors.emerald : AppColors.primaryMid,
                  ),
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.emerald : AppColors.primaryMid,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Profil Chip
          _buildProfilChip(context, ref, isDark),
          const SizedBox(height: 8),
          // User Level Widget
          const UserLevelWidget(),
          const SizedBox(height: 8),
          // Menu grid
          _buildMenuGrid(context, ref, isDark),
          const SizedBox(height: 12),
          // Panduan button
          _GlassMenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Panduan Aplikasi',
            subtitle: 'Pelajari cara menggunakan aplikasi',
            onTap: () => _showPanduan(context),
          ),
          const SizedBox(height: 8),
          // Logout button
          _GlassMenuTile(
            icon: Icons.logout_rounded,
            title: 'Keluar Akun',
            subtitle: 'Keluar dari akun Google Anda',
            isDestructive: true,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  title: Text(
                    'Keluar Akun',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin keluar dari aplikasi?',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await AuthService.instance.signOut();
              }
            },
          ),
        ],
      ),
    );
  }

  // ─── Profil Chip ───
  Widget _buildProfilChip(BuildContext context, WidgetRef ref, bool isDark) {
    final activeProfilId = ref.watch(activeProfilProvider);
    final profilListAsync = ref.watch(profilListProvider);
    final accentColor = isDark ? AppColors.emerald : AppColors.primaryMid;

    return profilListAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (profilList) {
        final active = profilList
            .where((p) => p.id == activeProfilId)
            .firstOrNull;
        final profilName = active?.nama ?? 'Profil';
        final iconData = _getProfilIcon(active?.icon ?? 'person');

        return GestureDetector(
          onTap: () => _showProfilSheet(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(iconData, size: 18, color: accentColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profil Aktif',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                    Text(
                      profilName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.swap_horiz_rounded, size: 18, color: accentColor),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfilSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const ProfileSelectorSheet(),
    );
  }

  IconData _getProfilIcon(String icon) {
    switch (icon) {
      case 'person':
        return Icons.person_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'family':
        return Icons.family_restroom_rounded;
      case 'business':
        return Icons.business_center_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  // ─── Menu Grid ───
  Widget _buildMenuGrid(BuildContext context, WidgetRef ref, bool isDark) {
    void showKelolaDompet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Material(
          color: Colors.transparent,
          child: Consumer(
            builder: (ctx, sheetRef, _) => KelolaDompetSheet(
              onSaved: () => sheetRef.invalidate(dompetProvider),
            ),
          ),
        ),
      );
    }

    void showBudget() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Material(
          color: Colors.transparent,
          child: BudgetSheet(
            tahun: ref.read(selectedYearProvider),
            bulan: ref.read(selectedMonthProvider),
          ),
        ),
      );
    }

    void showKelolaKategori() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => const Material(
          color: Colors.transparent,
          child: KelolaKategoriSheet(onChanged: null),
        ),
      );
    }

    void showLaporan() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) =>
            const Material(color: Colors.transparent, child: LaporanSheet()),
      );
    }

    void showRecurring() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Material(
          color: Colors.transparent,
          child: Consumer(
            builder: (ctx, sheetRef, _) => RecurringTransaksiSheet(
              onSaved: () => sheetRef
                  .read(updateSignalsProvider.notifier)
                  .signal('transaksi'),
            ),
          ),
        ),
      );
    }

    void showTrash() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Material(
          color: Colors.transparent,
          child: TrashSheet(
            onPulihkan: () =>
                ref.read(updateSignalsProvider.notifier).signal('transaksi'),
          ),
        ),
      );
    }

    final menuItems = [
      ('Pengaturan', Icons.settings_rounded, () => context.push('/settings')),
      ('Kelola Dompet', Icons.account_balance_wallet_rounded, showKelolaDompet),
      ('Atur Budget', Icons.savings_rounded, showBudget),
      ('Kelola Kategori', Icons.category_rounded, showKelolaKategori),
      (
        'Folder Struk',
        Icons.receipt_long_rounded,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SmartReceiptFolderPage()),
        ),
      ),
      (
        'Smart Insights',
        Icons.lightbulb_outline_rounded,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const InsightsPage())),
      ),
      (
        'Statistik',
        Icons.pie_chart_rounded,
        () {
          final tahun = ref.read(selectedYearProvider);
          final bulan = ref.read(selectedMonthProvider);
          context.push('/statistik?tahun=$tahun&bulan=$bulan');
        },
      ),
      ('Export Laporan', Icons.file_download_rounded, showLaporan),
      ('Transaksi Berulang', Icons.repeat_rounded, showRecurring),
      (
        'Utang & Piutang',
        Icons.handshake_rounded,
        () => context.push('/utang-piutang'),
      ),
      (
        'Tabungan Impian',
        Icons.savings_rounded,
        () => context.push('/tabungan-impian'),
      ),
      (
        'Lencana Pencapaian',
        Icons.emoji_events_rounded,
        () => context.push('/achievements'),
      ),
      (
        'Backup & Pulihkan',
        Icons.backup_rounded,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BackupPage())),
      ),
      ('Tong Sampah', Icons.delete_outline_rounded, showTrash),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _GlassMenuGridItem(
          icon: item.$2,
          title: item.$1,
          onTap: item.$3,
        );
      },
    );
  }

  // ─── Panduan ───
  void _showPanduan(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Panduan Aplikasi',
                        style: AppTypography.titleLarge(context),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                        onPressed: () => Navigator.pop(c),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      _panduanItem(
                        context,
                        Icons.add_circle_rounded,
                        'Menambah Transaksi',
                        'Tekan tombol (+) di kanan bawah untuk menambah transaksi baru.',
                      ),
                      _panduanItem(
                        context,
                        Icons.edit_rounded,
                        'Edit Transaksi',
                        'Klik transaksi untuk melihat detail, tekan edit untuk mengubah.',
                      ),
                      _panduanItem(
                        context,
                        Icons.delete_rounded,
                        'Hapus Transaksi',
                        'Geser transaksi ke kiri untuk menghapus.',
                      ),
                      _panduanItem(
                        context,
                        Icons.account_balance_wallet_rounded,
                        'Kelola Dompet',
                        'Atur berbagai dompet/wallet di menu grid.',
                      ),
                      _panduanItem(
                        context,
                        Icons.savings_rounded,
                        'Atur Budget',
                        'Tetapkan budget bulanan per kategori.',
                      ),
                      _panduanItem(
                        context,
                        Icons.pie_chart_rounded,
                        'Statistik',
                        'Lihat statistik pengeluaran per kategori.',
                      ),
                      _panduanItem(
                        context,
                        Icons.repeat_rounded,
                        'Transaksi Berulang',
                        'Buat transaksi yang berulang otomatis.',
                      ),
                      _panduanItem(
                        context,
                        Icons.backup_rounded,
                        'Backup Data',
                        'Ekspor & pulihkan data dengan aman.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _panduanItem(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.emerald : AppColors.primaryMid;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───
class _GlassMenuGridItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _GlassMenuGridItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.emerald : AppColors.primaryMid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: AppDecorations.glassCard(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: accentColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _GlassMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDestructive
        ? Colors.redAccent
        : (isDark ? AppColors.emerald : AppColors.primaryMid);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: AppDecorations.glassCard(context),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium(
                        context,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.redAccent
                            : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: isDestructive
                            ? Colors.redAccent.withValues(alpha: 0.7)
                            : (isDark ? Colors.white54 : const Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDestructive
                    ? Colors.redAccent.withValues(alpha: 0.5)
                    : (isDark ? Colors.white38 : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
