import 'package:flutter/material.dart';

/// A wrapper widget that adds proper accessibility semantics to cards.
///
/// This widget provides:
/// - Semantic label for screen readers
/// - Proper tap feedback announcements
/// - Support for both tap and long press actions
///
/// Usage:
/// ```dart
/// AccessibleCard(
///   label: 'Transaction card: Salary income Rp 5,000,000',
///   onTap: () => openTransaction(),
///   child: MyCardContent(),
/// )
/// ```
class AccessibleCard extends StatelessWidget {
  /// Semantic label describing the card content for screen readers.
  final String label;

  /// Hint text for additional context (e.g., "Double tap to edit").
  final String? hint;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether the card represents a button role (for screen readers).
  final bool isButton;

  /// Child widget content.
  final Widget child;

  /// Whether to exclude semantic properties from children.
  /// Set to true if children already have their own semantics.
  final bool excludeSemantics;

  const AccessibleCard({
    super.key,
    required this.label,
    this.hint,
    this.onTap,
    this.onLongPress,
    this.isButton = true,
    required this.child,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = hint != null ? '$label. $hint' : label;

    return Semantics(
      label: semanticLabel,
      button: isButton,
      enabled: onTap != null,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: excludeSemantics,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}

/// A mixin that provides common accessibility utilities for widgets.
mixin AccessibilityUtils {
  /// Creates a semantic label for currency amounts.
  static String formatCurrencyLabel(double amount, String currencySymbol) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$currencySymbol $formatted';
  }

  /// Creates a semantic label for dates.
  static String formatDateLabel(DateTime date, String locale) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  /// Creates a semantic label for transaction types.
  static String getTransactionTypeLabel(String type) {
    return type == 'pemasukan' ? 'pemasukan (pendapatan)' : 'pengeluaran (pengeluaran)';
  }
}

/// Extension to add accessibility support to existing widget builders.
extension AccessibilityExtension on Widget {
  /// Wraps the widget with accessibility semantics.
  Widget withAccessibility({
    required String label,
    String? hint,
    bool isButton = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      child: this,
    );
  }

  /// Excludes this widget's semantics from parent widgets.
  Widget excludeSemantics() {
    return Semantics(
      excludeSemantics: true,
      child: this,
    );
  }
}