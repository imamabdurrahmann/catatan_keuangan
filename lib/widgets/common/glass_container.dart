import 'package:flutter/material.dart';
import 'package:catatan_keuangan/theme/app_colors.dart';

// ==================== GLASS CONTAINER ====================
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color? borderColor;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color:
              borderColor ??
              (isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.4)
                  : AppColors.lightBorder.withValues(alpha: 0.6)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
