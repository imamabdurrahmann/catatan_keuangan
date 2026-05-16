import 'package:flutter/material.dart';
import '../models/constants.dart';
import '../theme/theme.dart';

/// Premium confirmation dialog for destructive actions.
Future<bool> showDeleteConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Hapus',
  String cancelLabel = 'Batal',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.coral,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Premium toggle button for transaksi jenis (pemasukan/pengeluaran).
Widget buildJenisButton({
  required BuildContext context,
  required String selectedJenis,
  required ValueChanged<String> onChanged,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1,
      ),
    ),
    padding: const EdgeInsets.all(4),
    child: Row(
      children: [
        Expanded(
          child: _PremiumJenisButton(
            jenis: AppConstants.jenisPengeluaran,
            label: 'Pengeluaran',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.coral,
            isSelected: selectedJenis == AppConstants.jenisPengeluaran,
            onTap: () => onChanged(AppConstants.jenisPengeluaran),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PremiumJenisButton(
            jenis: AppConstants.jenisPemasukan,
            label: 'Pemasukan',
            icon: Icons.arrow_downward_rounded,
            color: AppColors.emerald,
            isSelected: selectedJenis == AppConstants.jenisPemasukan,
            onTap: () => onChanged(AppConstants.jenisPemasukan),
          ),
        ),
      ],
    ),
  );
}

class _PremiumJenisButton extends StatelessWidget {
  final String jenis;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumJenisButton({
    required this.jenis,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
