import 'package:flutter/material.dart';
import 'app_colors.dart';

// ==================== CUSTOM SHAPES & DECORATIONS ====================
class AppDecorations {
  static BoxDecoration glassCard(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? AppColors.darkCard.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? AppColors.darkBorder.withValues(alpha: 0.5)
            : AppColors.lightBorder.withValues(alpha: 0.8),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        if (!isDark)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
      ],
    );
  }

  static BoxDecoration glassCardElevated(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.darkCardElevated : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? AppColors.darkBorder.withValues(alpha: 0.6)
            : AppColors.lightBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration pillBadge(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
    );
  }

  static BoxDecoration summaryCardGlass(BuildContext ctx, Color accentColor) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? accentColor.withValues(alpha: 0.15)
          : accentColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
        width: 1,
      ),
    );
  }
}
