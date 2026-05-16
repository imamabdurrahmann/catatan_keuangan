import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database_helper.dart';
import '../../theme/theme.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
  });

  Achievement copyWithUnlock(bool unlock) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      isUnlocked: unlock,
    );
  }
}

final achievementProvider = FutureProvider<List<Achievement>>((ref) async {
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;

  // 1. Check transactions
  final txResult = await db.rawQuery(
    'SELECT COUNT(*) as c, SUM(CASE WHEN jenis = "pemasukan" THEN jumlah ELSE 0 END) as totalIn FROM transaksi WHERE deleted_at IS NULL',
  );
  int txCount = 0;
  double totalIn = 0;
  if (txResult.isNotEmpty) {
    txCount = (txResult.first['c'] as int?) ?? 0;
    totalIn = (txResult.first['totalIn'] as num?)?.toDouble() ?? 0;
  }

  // 2. Check debts
  final utangResult = await db.rawQuery(
    'SELECT COUNT(*) as c FROM utang_piutang WHERE is_lunas = 1 AND jenis = "utang"',
  );
  int lunasCount = (utangResult.first['c'] as int?) ?? 0;

  // 3. Check savings
  final savingsResult = await db.rawQuery(
    'SELECT COUNT(*) as c FROM tabungan_impian',
  );
  int savingsCount = (savingsResult.first['c'] as int?) ?? 0;

  // Define badges
  return [
    Achievement(
      id: 'first_step',
      title: 'Langkah Pertama',
      description: 'Mencatat transaksi pertama kali.',
      icon: Icons.directions_walk_rounded,
      color: Colors.blue,
      isUnlocked: txCount >= 1,
    ),
    Achievement(
      id: 'consistent',
      title: 'Si Konsisten',
      description: 'Mencatat lebih dari 50 transaksi.',
      icon: Icons.auto_graph_rounded,
      color: Colors.deepPurple,
      isUnlocked: txCount >= 50,
    ),
    Achievement(
      id: 'sultan',
      title: 'Sultan',
      description: 'Memiliki riwayat total pendapatan menembus Rp10 Juta.',
      icon: Icons.diamond_rounded,
      color: Colors.amber,
      isUnlocked: totalIn >= 10000000,
    ),
    Achievement(
      id: 'responsible',
      title: 'Tepat Janji',
      description: 'Berhasil melunasi utang untuk pertama kali.',
      icon: Icons.handshake_rounded,
      color: Colors.green,
      isUnlocked: lunasCount >= 1,
    ),
    Achievement(
      id: 'visionary',
      title: 'Sang Visionaris',
      description: 'Membuka minimal 2 target tabungan impian.',
      icon: Icons.lightbulb_rounded,
      color: Colors.orange,
      isUnlocked: savingsCount >= 2,
    ),
    Achievement(
      id: 'big_boss',
      title: 'Bos Besar',
      description: 'Mencatat lebih dari 500 transaksi.',
      icon: Icons.work_rounded,
      color: Colors.redAccent,
      isUnlocked: txCount >= 500,
    ),
  ];
});

class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'Pencapaian',
          style: AppTypography.titleLarge(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (achievements) {
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
          final totalCount = achievements.length;
          final progress = unlockedCount / totalCount;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ruang Trofi Anda',
                      style: AppTypography.titleLarge(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$unlockedCount dari $totalCount Pencapaian Terbuka',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final ach = achievements[index];
                  return _AchievementCard(item: ach);
                },
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement item;
  const _AchievementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: AppDecorations.glassCardElevated(context).copyWith(
        border: Border.all(
          color: item.isUnlocked
              ? item.color.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: item.isUnlocked ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isUnlocked
                  ? item.color.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Icon(
              item.isUnlocked ? item.icon : Icons.lock_rounded,
              size: 36,
              color: item.isUnlocked ? item.color : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: item.isUnlocked
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: item.isUnlocked
                    ? (isDark ? Colors.white70 : Colors.black54)
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
