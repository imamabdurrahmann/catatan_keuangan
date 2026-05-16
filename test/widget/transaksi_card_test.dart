import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_data;
import 'package:catatan_keuangan/models/models.dart';
import 'package:catatan_keuangan/widgets/transaksi_item_card.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await date_data.initializeDateFormatting();
  });
  group('TransaksiItemCard', () {
    testWidgets('displays transaksi description', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 500000,
        kategori: 'Gaji',
        deskripsi: 'Gaji Juni 2024',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransaksiItemCard(transaksi: transaksi),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Gaji Juni 2024'), findsOneWidget);
    });

    testWidgets('displays correct amount for income (green)', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 500000,
        kategori: 'Gaji',
        deskripsi: 'Gaji',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransaksiItemCard(transaksi: transaksi),
              ),
            ),
          ),
        ),
      );

      // Income shows with +Rp prefix
      expect(find.textContaining('+Rp'), findsOneWidget);
    });

    testWidgets('displays correct amount for expense (coral)', (tester) async {
      final transaksi = Transaksi(
        id: 2,
        jenis: 'pengeluaran',
        jumlah: 250000,
        kategori: 'Makan',
        deskripsi: 'Makan siang',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransaksiItemCard(transaksi: transaksi),
              ),
            ),
          ),
        ),
      );

      // Expense shows with -Rp prefix
      expect(find.textContaining('-Rp'), findsOneWidget);
    });

    testWidgets('displays kategori label', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Bonus',
        deskripsi: 'Bonus bulanan',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransaksiItemCard(transaksi: transaksi),
              ),
            ),
          ),
        ),
      );

      expect(find.text('BONUS'), findsOneWidget);
    });

    testWidgets('displays recurring badge for recurring transactions', (
      tester,
    ) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pengeluaran',
        jumlah: 100000,
        kategori: 'Tagihan',
        deskripsi: 'Langganan streaming',
        tanggal: DateTime(2024, 6, 15),
        isRecurring: true,
        recurringFrequency: 'monthly',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransaksiItemCard(transaksi: transaksi),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Otomatis'), findsOneWidget);
    });

    testWidgets('displays attachment count when attachments exist', (
      tester,
    ) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Gaji',
        tanggal: DateTime(2024, 6, 15),
        lampiran: ['/path/to/file1.jpg', '/path/to/file2.pdf'],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransaksiItemCard(transaksi: transaksi),
              ),
            ),
          ),
        ),
      );

      // Should show attachment count
      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
    });

    testWidgets('uses Dismissible for swipe-to-delete', (tester) async {
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
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransaksiItemCard(
                  transaksi: transaksi,
                  onDismissed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('has icon for transaction type', (tester) async {
      final transaksi = Transaksi(
        id: 1,
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Test icon',
        tanggal: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransaksiItemCard(transaksi: transaksi),
              ),
            ),
          ),
        ),
      );

      // Income icon
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });
  });
}
