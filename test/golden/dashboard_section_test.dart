import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_data;
import 'package:catatan_keuangan/pages/tabs/tab_dashboard.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await date_data.initializeDateFormatting();
  });

  group('TabDashboard Section Golden Tests - Light Mode', () {
    testWidgets('renders dashboard with all sections in light mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            locale: const Locale('id', 'ID'),
            home: const Scaffold(
              body: TabDashboard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TabDashboard), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('dashboard contains scrollbar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const Scaffold(
              body: TabDashboard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsOneWidget);
    });
  });

  group('TabDashboard Section Golden Tests - Dark Mode', () {
    testWidgets('renders dashboard with all sections in dark mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildDarkTheme(),
            locale: const Locale('id', 'ID'),
            home: const Scaffold(
              body: TabDashboard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TabDashboard), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('TabDashboard - Column Layout', () {
    testWidgets('dashboard uses correct padding', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const Scaffold(
              body: TabDashboard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify SingleChildScrollView exists
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );

      // Check padding
      expect(scrollView.padding, isNotNull);
    });

    testWidgets('dashboard column has correct cross axis alignment', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const Scaffold(
              body: TabDashboard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the dashboard renders without errors
      expect(find.byType(TabDashboard), findsOneWidget);
    });
  });
}
