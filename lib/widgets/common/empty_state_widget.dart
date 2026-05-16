import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// ==================== EMPTY STATE WIDGET ====================

/// Enum for empty state types
enum EmptyStateType {
  noTransactions,
  noBudgets,
  noDebts,
  noSavingsGoals,
  noCategories,
  noDompet,
  noData,
}

/// Empty state widget with icon-based illustrations.
class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getConfig(type, isDark);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with gradient background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    config.iconColor.withValues(alpha: 0.15),
                    config.iconColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                config.icon,
                size: 48,
                color: config.iconColor,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title ?? config.title,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              subtitle ?? config.subtitle,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            // Optional action button
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: config.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: config.iconColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: config.iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateConfig _getConfig(EmptyStateType type, bool isDark) {
    switch (type) {
      case EmptyStateType.noTransactions:
        return _EmptyStateConfig(
          icon: Icons.receipt_long_rounded,
          iconColor: AppColors.emerald,
          title: 'Belum Ada Transaksi',
          subtitle: 'Mulai catat keuanganmu dengan\nmenambahkan transaksi pertama',
        );
      case EmptyStateType.noBudgets:
        return _EmptyStateConfig(
          icon: Icons.pie_chart_outline_rounded,
          iconColor: AppColors.gold,
          title: 'Belum Ada Anggaran',
          subtitle: 'Tetapkan anggaran bulanan untuk\nmengontrol pengeluaranmu',
        );
      case EmptyStateType.noDebts:
        return _EmptyStateConfig(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.coral,
          title: 'Tidak Ada Utang/Piutang',
          subtitle: 'Keuanganmu bersih tanpa\nutang atau piutang aktif',
        );
      case EmptyStateType.noSavingsGoals:
        return _EmptyStateConfig(
          icon: Icons.savings_outlined,
          iconColor: AppColors.teal,
          title: 'Belum Ada Tabungan Impian',
          subtitle: 'Tetapkan tujuan tabungan\nuntuk masa depanmu',
        );
      case EmptyStateType.noCategories:
        return _EmptyStateConfig(
          icon: Icons.category_outlined,
          iconColor: AppColors.primaryMid,
          title: 'Belum Ada Kategori',
          subtitle: 'Tambahkan kategori untuk\nmempermudah pencatatan',
        );
      case EmptyStateType.noDompet:
        return _EmptyStateConfig(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.primaryMid,
          title: 'Belum Ada Dompet',
          subtitle: 'Buat dompet pertamamu\nuntuk mulai mencatat',
        );
      case EmptyStateType.noData:
        return _EmptyStateConfig(
          icon: Icons.inbox_outlined,
          iconColor: isDark ? Colors.white54 : Colors.grey,
          title: 'Tidak Ada Data',
          subtitle: 'Data belum tersedia',
        );
    }
  }
}

class _EmptyStateConfig {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _EmptyStateConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

/// Compact empty state for cards and lists.
class CompactEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;

  const CompactEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = color ?? (isDark ? Colors.white24 : Colors.grey.shade400);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.3)
            : Colors.grey.shade100.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: displayColor.withValues(alpha: 0.7)),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: displayColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated empty state with pulse effect for transactions.
class AnimatedEmptyState extends StatefulWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;

  const AnimatedEmptyState({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getConfig(widget.type);

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          config.iconColor.withValues(alpha: 0.15),
                          config.iconColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      config.icon,
                      size: 40,
                      color: config.iconColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title ?? config.title,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle ?? config.subtitle,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _EmptyStateConfig _getConfig(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noTransactions:
        return _EmptyStateConfig(
          icon: Icons.receipt_long_rounded,
          iconColor: AppColors.emerald,
          title: 'Belum Ada Transaksi',
          subtitle: 'Mulai catat keuanganmu',
        );
      case EmptyStateType.noBudgets:
        return _EmptyStateConfig(
          icon: Icons.pie_chart_outline_rounded,
          iconColor: AppColors.gold,
          title: 'Belum Ada Anggaran',
          subtitle: 'Tetapkan anggaran bulanan',
        );
      case EmptyStateType.noDebts:
        return _EmptyStateConfig(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.coral,
          title: 'Tidak Ada Utang/Piutang',
          subtitle: 'Keuanganmu bersih',
        );
      case EmptyStateType.noSavingsGoals:
        return _EmptyStateConfig(
          icon: Icons.savings_outlined,
          iconColor: AppColors.teal,
          title: 'Belum Ada Tabungan',
          subtitle: 'Tetapkan tujuan tabungan',
        );
      case EmptyStateType.noCategories:
        return _EmptyStateConfig(
          icon: Icons.category_outlined,
          iconColor: AppColors.primaryMid,
          title: 'Belum Ada Kategori',
          subtitle: 'Tambahkan kategori',
        );
      case EmptyStateType.noDompet:
        return _EmptyStateConfig(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.primaryMid,
          title: 'Belum Ada Dompet',
          subtitle: 'Buat dompet pertamamu',
        );
      case EmptyStateType.noData:
        return _EmptyStateConfig(
          icon: Icons.inbox_outlined,
          iconColor: Colors.grey,
          title: 'Tidak Ada Data',
          subtitle: 'Data belum tersedia',
        );
    }
  }
}