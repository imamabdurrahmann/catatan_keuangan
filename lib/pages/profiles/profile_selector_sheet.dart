import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../theme/theme.dart';
import 'manage_profiles_page.dart';

class ProfileSelectorSheet extends ConsumerWidget {
  const ProfileSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeProfilId = ref.watch(activeProfilProvider);
    final profilListAsync = ref.watch(profilListProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pilih Profil',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.settings_rounded,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  tooltip: 'Kelola Profil',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ManageProfilesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          profilListAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Gagal memuat profil: $e'),
            ),
            data: (profilList) {
              if (profilList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Belum ada profil'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: profilList.length,
                itemBuilder: (context, index) {
                  final profil = profilList[index];
                  final isActive = profil.id == activeProfilId;
                  final iconData = _getProfilIcon(profil.icon);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ProfilTile(
                      profil: profil,
                      isActive: isActive,
                      isDark: isDark,
                      iconData: iconData,
                      onTap: () {
                        ref
                            .read(activeProfilProvider.notifier)
                            .setProfil(profil.id!);
                        Navigator.pop(context);
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
                                Text('Profil "${profil.nama}" aktif'),
                              ],
                            ),
                            backgroundColor: AppColors.emerald,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
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
}

class _ProfilTile extends StatelessWidget {
  final dynamic profil;
  final bool isActive;
  final bool isDark;
  final IconData iconData;
  final VoidCallback onTap;

  const _ProfilTile({
    required this.profil,
    required this.isActive,
    required this.isDark,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? AppColors.emerald : AppColors.primaryMid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive
                ? accentColor.withValues(alpha: 0.12)
                : (isDark ? AppColors.darkCardElevated : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? accentColor
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive
                      ? accentColor
                      : (isDark ? Colors.white10 : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.white54 : Colors.grey),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profil.nama,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isActive)
                      Text(
                        'Profil aktif',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: accentColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
