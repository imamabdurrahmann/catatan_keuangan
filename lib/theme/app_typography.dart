import 'package:flutter/material.dart';

// ==================== CUSTOM TYPOGRAPHY ====================
class AppTypography {
  static const String _fontFamily = 'PlusJakartaSans';

  static TextStyle displayLarge(BuildContext ctx) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    color: Theme.of(ctx).colorScheme.onSurface,
  );

  static TextStyle displayMedium(BuildContext ctx) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Theme.of(ctx).colorScheme.onSurface,
  );

  static TextStyle titleLarge(BuildContext ctx) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Theme.of(ctx).colorScheme.onSurface,
  );

  static TextStyle titleMedium(BuildContext ctx) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(ctx).colorScheme.onSurface,
  );

  static TextStyle bodyLarge(BuildContext ctx) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Theme.of(ctx).colorScheme.onSurface,
  );

  static TextStyle bodyMedium(BuildContext ctx) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
  );

  static TextStyle labelLarge(BuildContext ctx) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Theme.of(ctx).colorScheme.onSurface,
  );

  static TextStyle labelSmall(BuildContext ctx) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
  );
}
