import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../services/biometric_service.dart';
import '../../services/notification_service.dart';
import '../../theme/theme.dart';
import '../../widgets/common/glass_container.dart';
import 'backup_restore_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _biometricAvailable = false;
  bool _biometricEnrolled = false;
  bool _notifBudget = true;
  bool _notifDebt = true;
  bool _notifSavings = true;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _loadNotificationSettings();
  }

  Future<void> _checkBiometric() async {
    final available = await BiometricService.instance.isAvailable();
    final enrolled = await BiometricService.instance.hasEnrolledBiometrics();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnrolled = enrolled;
      });
    }
  }

  Future<void> _loadNotificationSettings() async {
    final budget = await NotificationService.instance.isBudgetEnabled();
    final debt = await NotificationService.instance.isDebtEnabled();
    final savings = await NotificationService.instance.isSavingsEnabled();
    if (mounted) {
      setState(() {
        _notifBudget = budget;
        _notifDebt = debt;
        _notifSavings = savings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pengaturan = ref.watch(pengaturanProvider);
    final isDarkMode = pengaturan.isDarkMode;
    final useBiometric = pengaturan.useBiometric;
    final hasPin = pengaturan.pin != null && pengaturan.pin!.isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pengaturan',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0D2818),
                          const Color(0xFF1B5E20).withValues(alpha: 0.3),
                          AppColors.darkBg,
                        ]
                      : [
                          const Color(0xFF1B5E20),
                          const Color(0xFF2E7D32),
                          AppColors.lightBg,
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              children: [
                const SizedBox(height: 8),

                // ========== APPEARANCE SECTION ==========
                _SectionHeader(title: 'Tampilan', isDark: isDark),
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _SettingsTile(
                    icon: isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    iconColor: AppColors.primaryMid,
                    title: 'Mode Gelap',
                    subtitle: isDarkMode
                        ? 'Aktif — tema gelap digunakan'
                        : 'Nonaktif — tema terang digunakan',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) => ref
                          .read(pengaturanProvider.notifier)
                          .toggleDarkMode(),
                      activeTrackColor: AppColors.emerald,
                    ),
                  ),
                ),

                // ========== ACCESSIBILITY SECTION ==========
                _SectionHeader(title: 'Aksesibilitas', isDark: isDark),
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Semantics(
                        label: 'Mode kontras tinggi',
                        hint: 'Aktifkan untuk meningkatkan kontras warna sesuai standar WCAG',
                        child: _SettingsTile(
                          icon: Icons.contrast_rounded,
                          iconColor: AppColors.gold,
                          title: 'Mode Kontras Tinggi',
                          subtitle: 'Meningkatkan kontras warna untuk keterbacaan lebih baik',
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              // TODO: Implement high contrast mode toggle
                              // This would toggle a high contrast preference in settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Mode kontras tinggi akan segera hadir',
                                    textAlign: TextAlign.center,
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            activeTrackColor: AppColors.emerald,
                          ),
                        ),
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                        height: 1,
                      ),
                      Semantics(
                        label: 'Ukuran font besar',
                        hint: 'Aktifkan untuk menggunakan ukuran font yang lebih besar',
                        child: _SettingsTile(
                          icon: Icons.text_fields_rounded,
                          iconColor: AppColors.coral,
                          title: 'Ukuran Font Besar',
                          subtitle: 'Gunakan ukuran font lebih besar',
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              // TODO: Implement large font mode
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Mode font besar akan segera hadir',
                                    textAlign: TextAlign.center,
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            activeTrackColor: AppColors.emerald,
                          ),
                        ),
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                        height: 1,
                      ),
                      Semantics(
                        label: 'Deskripsi audio',
                        hint: 'Aktifkan deskripsi audio untuk elemen visual',
                        child: _SettingsTile(
                          icon: Icons.record_voice_over_rounded,
                          iconColor: AppColors.teal,
                          title: 'Deskripsi Audio',
                          subtitle: 'Memberikan deskripsi untuk elemen visual',
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              // TODO: Implement audio description mode
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Deskripsi audio akan segera hadir',
                                    textAlign: TextAlign.center,
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            activeTrackColor: AppColors.emerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ========== ACCESSIBILITY INFO ==========
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMid.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.accessibility_new_rounded,
                          color: AppColors.primaryMid,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dukungan Aksesibilitas',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Aplikasi ini mendukung TalkBack dan VoiceOver dengan label semantik yang lengkap.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ========== SECURITY SECTION ==========
                if (hasPin) ...[
                  _SectionHeader(title: 'Keamanan', isDark: isDark),
                  GlassContainer(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        if (_biometricAvailable && _biometricEnrolled)
                          _SettingsTile(
                            icon: Icons.fingerprint_rounded,
                            iconColor: AppColors.emerald,
                            title: 'Sidik Jari / Wajah',
                            subtitle: useBiometric
                                ? 'Aktif — buka dengan sidik jari'
                                : 'Nonaktif — buka dengan PIN saja',
                            trailing: Switch(
                              value: useBiometric,
                              onChanged: (value) => ref
                                  .read(pengaturanProvider.notifier)
                                  .toggleBiometric(),
                              activeTrackColor: AppColors.emerald,
                            ),
                          ),
                        if (!_biometricAvailable || !_biometricEnrolled)
                          _SettingsTile(
                            icon: Icons.fingerprint_rounded,
                            iconColor: Colors.grey,
                            title: 'Sidik Jari / Wajah',
                            subtitle: !hasPin
                                ? 'Atur PIN terlebih dahulu'
                                : 'Tidak tersedia di perangkat ini',
                            trailing: Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey.shade400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // ========== NOTIFICATIONS SECTION ==========
                _SectionHeader(title: 'Pemberitahuan', isDark: isDark),
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: AppColors.coral,
                        title: 'Peringatan Budget',
                        subtitle: _notifBudget
                            ? 'Aktif — notifikasi saat budget menipis'
                            : 'Nonaktif',
                        trailing: Switch(
                          value: _notifBudget,
                          onChanged: (value) async {
                            await NotificationService.instance.setBudgetEnabled(
                              value,
                            );
                            setState(() => _notifBudget = value);
                          },
                          activeTrackColor: AppColors.emerald,
                        ),
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                        height: 1,
                      ),
                      _SettingsTile(
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppColors.gold,
                        title: 'Reminder Utang',
                        subtitle: _notifDebt
                            ? 'Aktif — notifikasi saat jatuh tempo'
                            : 'Nonaktif',
                        trailing: Switch(
                          value: _notifDebt,
                          onChanged: (value) async {
                            await NotificationService.instance.setDebtEnabled(
                              value,
                            );
                            setState(() => _notifDebt = value);
                          },
                          activeTrackColor: AppColors.emerald,
                        ),
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                        height: 1,
                      ),
                      _SettingsTile(
                        icon: Icons.savings_rounded,
                        iconColor: AppColors.teal,
                        title: 'Milestone Tabungan',
                        subtitle: _notifSavings
                            ? 'Aktif — notifikasi target tabungan'
                            : 'Nonaktif',
                        trailing: Switch(
                          value: _notifSavings,
                          onChanged: (value) async {
                            await NotificationService.instance
                                .setSavingsEnabled(value);
                            setState(() => _notifSavings = value);
                          },
                          activeTrackColor: AppColors.emerald,
                        ),
                      ),
                    ],
                  ),
                ),

                // ========== DATA SECTION ==========
                _SectionHeader(title: 'Data', isDark: isDark),
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _SettingsTile(
                    icon: Icons.backup_rounded,
                    iconColor: AppColors.gold,
                    title: 'Backup & Restore',
                    subtitle: 'Ekspor dan impor data aplikasi',
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const _BackupRestorePageWrapper(),
                      ),
                    ),
                  ),
                ),

                // ========== ABOUT SECTION ==========
                _SectionHeader(title: 'Tentang', isDark: isDark),
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.primaryMid,
                        title: 'Versi Aplikasi',
                        subtitle: '1.0.0',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '1.0.0',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.emerald
                                  : AppColors.primaryMid,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                        height: 1,
                      ),
                      _SettingsTile(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: AppColors.primaryMid,
                        title: 'DompetKu',
                        subtitle: 'Aplikasi pencatatan keuangan personal',
                        trailing: null,
                      ),
                    ],
                  ),
                ),

                // App info card
                GlassContainer(
                  padding: const EdgeInsets.all(20),
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
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dirancang dengan Flutter & Riverpod',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? AppColors.emerald : AppColors.primaryMid,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          (trailing != null) ? trailing! : const SizedBox.shrink(),
        ],
      ),
    );
    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: tile,
          )
        : tile;
  }
}

class _BackupRestorePageWrapper extends StatelessWidget {
  const _BackupRestorePageWrapper();

  @override
  Widget build(BuildContext context) {
    return const BackupRestorePage();
  }
}
