import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../theme/theme.dart';

class UserLevelWidget extends ConsumerWidget {
  const UserLevelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelAsync = ref.watch(userLevelProvider);

    return levelAsync.when(
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
      data: (level) => _buildLevelCard(context, level),
    );
  }

  Widget _buildLevelCard(BuildContext context, UserLevel level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, icon) = _getLevelStyle(level.levelIndex);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level: ${level.levelName}',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      '${level.transaksiCount} transaksi dicatat',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLevelBadge(level.levelIndex, color),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          if (level.levelIndex < 2) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: level.progressPercent,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${level.progressPercent * 100 ~/ 1}%',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${level.transaksiMenujuLevelBerikut} transaksi lagi menuju level berikutnya',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Level tertinggi tercapai!',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelBadge(int index, Color color) {
    if (index == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            const Text(
              'MAX',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Lv.${index + 1}',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  (Color, IconData) _getLevelStyle(int index) {
    switch (index) {
      case 0:
        return (AppColors.coral, Icons.school_rounded);
      case 1:
        return (AppColors.teal, Icons.trending_up_rounded);
      case 2:
        return (AppColors.gold, Icons.workspace_premium_rounded);
      default:
        return (AppColors.primaryMid, Icons.star_rounded);
    }
  }
}
