import 'package:flutter/material.dart';

// ==================== COLOR PALETTE ====================
class AppColors {
  // Core palette
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryMid = Color(0xFF2E7D32);

  // Accent
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color coral = Color(0xFFF87171);
  static const Color coralLight = Color(0xFFFCA5A5);
  static const Color gold = Color(0xFFFBBF24);
  static const Color goldLight = Color(0xFFFCD34D);
  static const Color teal = Color(0xFF14B8A6);

  // Dark theme surfaces
  static const Color darkBg = Color(0xFF0A0E14);
  static const Color darkSurface = Color(0xFF131820);
  static const Color darkCard = Color(0xFF1A2030);
  static const Color darkCardElevated = Color(0xFF222840);
  static const Color darkBorder = Color(0xFF2A3040);
  static const Color darkDivider = Color(0xFF1E2535);

  // Light theme surfaces
  static const Color lightBg = Color(0xFFF1F0ED);
  static const Color lightSurface = Color(0xFFF7F6F3);
  static const Color lightCard = Color(0xFFF7F6F3);
  static const Color lightBorder = Color(0xFFDAD7D0);
  static const Color lightDivider = Color(0xFFE5E2DC);

  // Glass effect
  static Color glassLight = Colors.white.withValues(alpha: 0.7);
  static Color glassDark = Colors.black.withValues(alpha: 0.3);

  // Gradients
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF14532D), Color(0xFF166534), Color(0xFF1B7A40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    colors: [Color(0xFF0D2818), Color(0xFF1B5E20), Color(0xFF2E7D32)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
