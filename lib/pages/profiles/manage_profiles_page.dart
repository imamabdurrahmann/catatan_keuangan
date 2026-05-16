import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers.dart';
import '../../data/database_helper.dart';
import '../../theme/theme.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_button.dart';

class ManageProfilesPage extends ConsumerStatefulWidget {
  const ManageProfilesPage({super.key});

  @override
  ConsumerState<ManageProfilesPage> createState() => _ManageProfilesPageState();
}

class _ManageProfilesPageState extends ConsumerState<ManageProfilesPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeProfilId = ref.watch(activeProfilProvider);
    final profilListAsync = ref.watch(profilListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Kelola Profil',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: profilListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.coral,
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat profil',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '$e',
                style: const TextStyle(fontSize: 12, color: AppColors.coral),
              ),
            ],
          ),
        ),
        data: (profilList) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: profilList.length,
          itemBuilder: (context, index) {
            final profil = profilList[index];
            final isActive = profil.id == activeProfilId;
            final iconData = _getProfilIcon(profil.icon);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.emerald.withValues(alpha: 0.15)
                            : (isDark ? Colors.white10 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        iconData,
                        color: isActive
                            ? AppColors.emerald
                            : (isDark ? Colors.white54 : Colors.grey),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  profil.nama,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                              if (isActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Aktif',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.emerald,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getIconLabel(profil.icon),
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.emerald,
                        ),
                        tooltip: 'Profil sedang aktif',
                        onPressed: null,
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.swap_horiz_rounded,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            tooltip: 'Aktifkan profil ini',
                            onPressed: () => _switchToProfil(profil),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.coral,
                            ),
                            tooltip: 'Hapus profil',
                            onPressed: () => _showDeleteConfirmation(profil),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.emerald : AppColors.primaryMid)
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'manage_profil_fab',
          onPressed: _showAddProfilSheet,
          elevation: 0,
          tooltip: 'Tambah Profil',
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  void _switchToProfil(Profil profil) {
    ref.read(activeProfilProvider.notifier).setProfil(profil.id!);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text('Profil "${profil.nama}" diaktifkan'),
          ],
        ),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmation(Profil profil) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.coral,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Hapus Profil?',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        content: Text(
          'Profil "${profil.nama}" akan dihapus. Dompet & budget di profil ini ikut terhapus. Data transaksi tetap aman.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: isDark ? Colors.white54 : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _deleteProfil(profil.id!);
              if (success && mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text('Profil "${profil.nama}" dihapus'),
                      ],
                    ),
                    backgroundColor: AppColors.coral,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _deleteProfil(int profilId) async {
    try {
      final list = await ref.read(profilListProvider.future);
      if (list.length <= 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Text('Minimal harus ada 1 profil'),
                ],
              ),
              backgroundColor: AppColors.coral,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return false;
      }

      final dompets = await DatabaseHelper.instance.getAllDompet(
        profilId: profilId,
      );
      for (final d in dompets) {
        if (d.id != null) await DatabaseHelper.instance.deleteDompet(d.id!);
      }

      final budgets = await DatabaseHelper.instance.getAllBudget(
        1,
        DateTime.now().year,
        profilId: profilId,
      );
      final db = await DatabaseHelper.instance.database;
      for (final b in budgets) {
        if (b.id != null)
          await db.delete('budget', where: 'id = ?', whereArgs: [b.id]);
      }

      await DatabaseHelper.instance.deleteProfil(profilId);
      ref.invalidate(profilListProvider);
      ref.invalidate(dompetProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showAddProfilSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    String selectedIcon = 'person';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Profil Baru',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nama Profil',
                    hintText: 'Contoh: Bisnis, Keluarga',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkCardElevated
                        : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.badge_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Ikon',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _iconChip(
                      'person',
                      Icons.person_rounded,
                      'Pribadi',
                      selectedIcon,
                      (v) => setSheetState(() => selectedIcon = v),
                    ),
                    _iconChip(
                      'work',
                      Icons.work_rounded,
                      'Kerja',
                      selectedIcon,
                      (v) => setSheetState(() => selectedIcon = v),
                    ),
                    _iconChip(
                      'family',
                      Icons.family_restroom_rounded,
                      'Keluarga',
                      selectedIcon,
                      (v) => setSheetState(() => selectedIcon = v),
                    ),
                    _iconChip(
                      'business',
                      Icons.business_center_rounded,
                      'Bisnis',
                      selectedIcon,
                      (v) => setSheetState(() => selectedIcon = v),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GlassButton(
                    label: 'SIMPAN PROFIL',
                    icon: Icons.check_rounded,
                    color: isDark ? AppColors.emerald : AppColors.primaryMid,
                    onPressed: () async {
                      final nama = nameController.text.trim();
                      if (nama.isEmpty) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text('Nama profil tidak boleh kosong'),
                              ],
                            ),
                            backgroundColor: AppColors.coral,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                        return;
                      }
                      await _addProfil(nama, selectedIcon);
                      if (mounted) Navigator.pop(ctx);
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconChip(
    String value,
    IconData icon,
    String label,
    String selected,
    Function(String) onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == selected;
    final accentColor = isDark ? AppColors.emerald : AppColors.primaryMid;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? accentColor
                  : (isDark ? Colors.white54 : Colors.grey),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? accentColor
                    : (isDark ? Colors.white54 : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProfil(String nama, String icon) async {
    try {
      final profil = Profil(nama: nama, icon: icon, createdAt: DateTime.now());
      await DatabaseHelper.instance.insertProfil(profil);
      ref.invalidate(profilListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text('Profil "$nama" ditambahkan'),
              ],
            ),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text('Gagal menambahkan profil: $e'),
              ],
            ),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
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

  String _getIconLabel(String icon) {
    switch (icon) {
      case 'person':
        return 'Profil Pribadi';
      case 'work':
        return 'Profil Kerja';
      case 'family':
        return 'Profil Keluarga';
      case 'business':
        return 'Profil Bisnis';
      default:
        return 'Profil';
    }
  }
}
