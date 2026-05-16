import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../theme/theme.dart';
import '../../utils/ui_utils.dart';

/// A horizontal chip-style dompet switcher.
/// Shows "Semua Dompet" + each wallet as a selectable chip.
class DompetSwitcher extends ConsumerWidget {
  const DompetSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dompetAsync = ref.watch(dompetProvider);
    final selectedId = ref.watch(selectedDompetFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return dompetAsync.when(
      loading: () => const SizedBox(height: 40),
      error: (_, __) => const SizedBox(height: 40),
      data: (dompetList) {
        // Don't show if only 1 dompet
        if (dompetList.length <= 1) return const SizedBox.shrink();

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _DompetChip(
                label: 'Semua Dompet',
                icon: Icons.wallet_rounded,
                color: isDark ? AppColors.emerald : AppColors.primaryMid,
                isSelected: selectedId == null,
                isDark: isDark,
                onTap: () {
                  ref.read(selectedDompetFilterProvider.notifier).reset();
                  ref.read(bulananPageProvider.notifier).reset();
                },
              ),
              const SizedBox(width: 8),
              ...dompetList.map((d) {
                final isSelected = selectedId == d.id;
                final walletColor = getAppColor(d.warna);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _DompetChip(
                    label: d.nama,
                    icon: Icons.account_balance_wallet_rounded,
                    color: walletColor,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () {
                      ref.read(selectedDompetFilterProvider.notifier).set(d.id);
                      ref.read(bulananPageProvider.notifier).reset();
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _DompetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DompetChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (isDark
                    ? AppColors.darkCard.withValues(alpha: 0.5)
                    : AppColors.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? color
                  : (isDark ? Colors.white54 : Colors.grey),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
