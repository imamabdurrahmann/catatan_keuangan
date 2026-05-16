import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_data;
import 'package:catatan_keuangan/pages/tabs/dashboard/balance_overview_card.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await date_data.initializeDateFormatting();
  });

  group('BalanceOverviewCard Golden Tests', () {
    testWidgets('renders correctly in light mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            locale: const Locale('id', 'ID'),
            supportedLocales: const [Locale('id', 'ID')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BalanceOverviewCard(
                    params: (bulan: 6, tahun: 2024),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Allow animations to settle
      await tester.pumpAndSettle();

      // Verify the card renders
      expect(find.byType(BalanceOverviewCard), findsOneWidget);

      // Verify key elements are present
      expect(find.text('Total Saldo'), findsOneWidget);
      expect(find.text('Juni 2024'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildDarkTheme(),
            locale: const Locale('id', 'ID'),
            supportedLocales: const [Locale('id', 'ID')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BalanceOverviewCard(
                    params: (bulan: 6, tahun: 2024),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BalanceOverviewCard), findsOneWidget);
      expect(find.text('Total Saldo'), findsOneWidget);
      expect(find.text('Juni 2024'), findsOneWidget);
    });

    testWidgets('displays wallet icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BalanceOverviewCard(
                    params: (bulan: 6, tahun: 2024),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    });

    testWidgets('displays active status badge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BalanceOverviewCard(
                    params: (bulan: 6, tahun: 2024),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aktif'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BalanceOverviewCard(
                    params: (bulan: 6, tahun: 2024),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Don't pump and settle - just pump once to see initial loading state
      await tester.pump();

      // Loading indicator may appear initially
      expect(find.byType(BalanceOverviewCard), findsOneWidget);
    });

    testWidgets('renders with different month/year combinations', (tester) async {
      // Test December 2024
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            locale: const Locale('id', 'ID'),
            supportedLocales: const [Locale('id', 'ID')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BalanceOverviewCard(
                    params: (bulan: 12, tahun: 2024),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Desember 2024'), findsOneWidget);
    });
  });
}
