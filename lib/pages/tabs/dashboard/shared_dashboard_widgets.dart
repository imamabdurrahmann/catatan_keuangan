import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../widgets/common/glass_container.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const SectionTitle({super.key, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.incomeGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final String message;

  const EmptyStateCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
