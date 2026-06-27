import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_data;
import 'package:catatan_keuangan/models/models.dart';
import 'package:catatan_keuangan/widgets/transaksi_item_card.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await date_data.initializeDateFormatting();
  });

  group('TransaksiItemCard Golden Tests - Light Mode', () {
    testWidgets('renders income transaction correctly in light mode', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 500000,
        kategori: 'Gaji',
        deskripsi: 'Gaji Juni 2024',
        tanggal: DateTime(2024, 6, 15, 10, 30),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            locale: const Locale('id', 'ID'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TransaksiItemCard), findsOneWidget);
      expect(find.text('Gaji Juni 2024'), findsOneWidget);
      expect(find.text('GAJI'), findsOneWidget);
      expect(find.textContaining('+Rp'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });

    testWidgets('renders expense transaction correctly in light mode', (tester) async {
      final transaksi = Transaksi(
        id: 2,
        jenis: 'pengeluaran',
        jumlah: 250000,
        kategori: 'Makan',
        deskripsi: 'Makan siang',
        tanggal: DateTime(2024, 6, 15, 12, 0),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            locale: const Locale('id', 'ID'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TransaksiItemCard), findsOneWidget);
      expect(find.text('Makan siang'), findsOneWidget);
      expect(find.text('MAKAN'), findsOneWidget);
      expect(find.textContaining('-Rp'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('renders with recurring badge', (tester) async {
      final transaksi = Transaksi(
        id: 3,
        jenis: 'pengeluaran',
        jumlah: 150000,
        kategori: 'Tagihan',
        deskripsi: 'Langganan streaming',
        tanggal: DateTime(2024, 6, 1),
        isRecurring: true,
        recurringFrequency: 'monthly',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Otomatis'), findsOneWidget);
    });

    testWidgets('renders with attachments', (tester) async {
      final transaksi = Transaksi(
        id: 4,
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Bonus',
        deskripsi: 'Bonus performance',
        tanggal: DateTime(2024, 6, 15),
        lampiran: ['/path/to/file1.jpg', '/path/to/file2.pdf'],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
    });
  });

  group('TransaksiItemCard Golden Tests - Dark Mode', () {
    testWidgets('renders income transaction correctly in dark mode', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 500000,
        kategori: 'Gaji',
        deskripsi: 'Gaji Juni 2024',
        tanggal: DateTime(2024, 6, 15, 10, 30),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildDarkTheme(),
            locale: const Locale('id', 'ID'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TransaksiItemCard), findsOneWidget);
      expect(find.text('Gaji Juni 2024'), findsOneWidget);
    });

    testWidgets('renders expense transaction correctly in dark mode', (tester) async {
      final transaksi = Transaksi(
        id: 2,
        jenis: 'pengeluaran',
        jumlah: 250000,
        kategori: 'Makan',
        deskripsi: 'Makan siang',
        tanggal: DateTime(2024, 6, 15, 12, 0),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildDarkTheme(),
            locale: const Locale('id', 'ID'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TransaksiItemCard), findsOneWidget);
      expect(find.text('Makan siang'), findsOneWidget);
    });
  });

  group('TransaksiItemCard - Dismissible Behavior', () {
    testWidgets('shows dismissible when onDismissed provided', (tester) async {
      bool dismissed = false;
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Test dismiss',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(
                    transaksi: transaksi,
                    onDismissed: () => dismissed = true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsOneWidget);

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('does not show dismissible when onDismissed is null', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Test no dismiss',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsNothing);
    });
  });

  group('TransaksiItemCard - Edge Cases', () {
    testWidgets('uses kategori as description when deskripsi is empty', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Bonus',
        deskripsi: '',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show kategori (Bonus) instead of empty deskripsi
      expect(find.text('Bonus'), findsOneWidget);
    });

    testWidgets('handles large amounts correctly', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 1000000000, // 1 billion
        kategori: 'Gaji',
        deskripsi: 'Year-end bonus',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TransaksiItemCard), findsOneWidget);
      expect(find.textContaining('+Rp'), findsOneWidget);
    });
  });
}
