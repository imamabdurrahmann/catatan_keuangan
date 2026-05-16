import 'package:flutter/material.dart';
import 'package:catatan_keuangan/theme/app_colors.dart';
import 'package:catatan_keuangan/utils/formatters.dart';

// ==================== ANIMATED CURRENCY TEXT ====================
class AnimatedCurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String prefix;
  final bool showSign;
  final Color? positiveColor;
  final Color? negativeColor;

  const AnimatedCurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.prefix = '',
    this.showSign = false,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    final color = isPositive
        ? (positiveColor ?? AppColors.emerald)
        : (negativeColor ?? AppColors.coral);
    final sign = showSign ? (isPositive ? '+' : '-') : (amount < 0 ? '-' : '');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount.abs()),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '$sign$prefix${formatRupiah(value)}',
          style: (style ?? const TextStyle()).copyWith(color: color),
        );
      },
    );
  }
}
