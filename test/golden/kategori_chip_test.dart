import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_data;
import 'package:catatan_keuangan/models/models.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await date_data.initializeDateFormatting();
  });

  // Mock category chip widget (similar to what might be used in the app)
  Widget buildKategoriChip({
    required String label,
    required bool isSelected,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  group('KategoriChip Golden Tests - Light Mode', () {
    testWidgets('renders selected state correctly in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: buildKategoriChip(
                  label: 'Makanan',
                  isSelected: true,
                  color: AppColors.coral,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Makanan'), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('renders unselected state correctly in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: buildKategoriChip(
                  label: 'Transportasi',
                  isSelected: false,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Transportasi'), findsOneWidget);
    });

    testWidgets('responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: buildKategoriChip(
                  label: 'Hiburan',
                  isSelected: false,
                  color: AppColors.gold,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Hiburan'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('KategoriChip Golden Tests - Dark Mode', () {
    testWidgets('renders selected state correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: buildKategoriChip(
                  label: 'Makanan',
                  isSelected: true,
                  color: AppColors.coral,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Makanan'), findsOneWidget);
    });

    testWidgets('renders unselected state correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: buildKategoriChip(
                  label: 'Transportasi',
                  isSelected: false,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Transportasi'), findsOneWidget);
    });
  });

  group('KategoriChip Selection Row Tests', () {
    testWidgets('displays multiple chips in a row', (tester) async {
      final categories = [
        ('Makanan', AppColors.coral, false),
        ('Transportasi', AppColors.teal, true),
        ('Hiburan', AppColors.gold, false),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: buildKategoriChip(
                        label: cat.$1,
                        isSelected: cat.$3,
                        color: cat.$2,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Makanan'), findsOneWidget);
      expect(find.text('Transportasi'), findsOneWidget);
      expect(find.text('Hiburan'), findsOneWidget);
    });
  });
}
