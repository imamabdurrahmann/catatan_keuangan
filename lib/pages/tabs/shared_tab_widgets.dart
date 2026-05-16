import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/theme.dart';

Widget buildEmptyState(BuildContext context, IconData icon, String message) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.network(
          'https://lottie.host/81b2e2d0-61f4-419b-aef7-b2f15f92dbce/8N7VfPIfPZ.json',
          width: 150,
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.emerald : AppColors.primaryMid)
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: (isDark ? AppColors.emerald : AppColors.primaryMid)
                    .withValues(alpha: 0.4),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(context).copyWith(
            color: isDark ? Colors.white54 : Colors.grey.shade400,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

Widget buildErrorWidget(String error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: AppColors.coral.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 12),
        Text(
          error,
          style: const TextStyle(color: AppColors.coral, fontSize: 14),
        ),
      ],
    ),
  );
}

class DateNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const DateNavButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
