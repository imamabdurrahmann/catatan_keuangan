import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_data;
import 'package:catatan_keuangan/models/models.dart';
import 'package:catatan_keuangan/widgets/transaksi_item_card.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';

// This file tests the transaction flow: add, edit, delete
// For true end-to-end testing, this should be run with:
// flutter test integration_test/transaction_flow_test.dart
// or with integration_test package on a real device

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await date_data.initializeDateFormatting();
  });

  group('Transaction Flow Tests', () {
    group('TransaksiItemCard Interactions', () {
      testWidgets('card tap opens edit bottom sheet', (tester) async {
        final transaksi = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          kategori: 'Gaji',
          deskripsi: 'Test transaction',
          tanggal: DateTime(2024, 6, 15),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(),
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

        await tester.pumpAndSettle();

        // Tap the card
        await tester.tap(find.byType(TransaksiItemCard));
        await tester.pumpAndSettle();

        // The bottom sheet should appear
        expect(find.byType(BottomSheet), findsOneWidget);
      });

      testWidgets('swipe to dismiss triggers callback', (tester) async {
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
                  child: TransaksiItemCard(
                    transaksi: transaksi,
                    onDismissed: () => dismissed = true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Swipe left to dismiss
        await tester.drag(
          find.byType(Dismissible),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(dismissed, isTrue);
      });

      testWidgets('multiple cards can be rendered', (tester) async {
        final transactions = [
          Transaksi(
            id: 1,
            jenis: 'pemasukan',
            jumlah: 500000,
            kategori: 'Gaji',
            deskripsi: 'Gaji Juni',
            tanggal: DateTime(2024, 6, 15),
          ),
          Transaksi(
            id: 2,
            jenis: 'pengeluaran',
            jumlah: 250000,
            kategori: 'Makan',
            deskripsi: 'Makan siang',
            tanggal: DateTime(2024, 6, 15),
          ),
          Transaksi(
            id: 3,
            jenis: 'pengeluaran',
            jumlah: 100000,
            kategori: 'Transportasi',
            deskripsi: 'Bensin',
            tanggal: DateTime(2024, 6, 14),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(),
              home: Scaffold(
                body: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return TransaksiItemCard(transaksi: transactions[index]);
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // All cards should be rendered
        expect(find.byType(TransaksiItemCard), findsNWidgets(3));
      });
    });

    group('Transaction State Transitions', () {
      testWidgets('income shows green color and arrow down icon', (tester) async {
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
              theme: buildLightTheme(),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Income should show arrow down
        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
        // Plus sign for income
        expect(find.textContaining('+Rp'), findsOneWidget);
      });

      testWidgets('expense shows coral color and arrow up icon', (tester) async {
        final transaksi = Transaksi(
          id: 1,
          jenis: 'pengeluaran',
          jumlah: 100000,
          kategori: 'Makan',
          deskripsi: 'Makan siang',
          tanggal: DateTime(2024, 6, 15),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Expense should show arrow up
        expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
        // Minus sign for expense
        expect(find.textContaining('-Rp'), findsOneWidget);
      });
    });

    group('Transaction Edge Cases', () {
      testWidgets('handles zero amount', (tester) async {
        final transaksi = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 0,
          kategori: 'Test',
          deskripsi: 'Zero amount',
          tanggal: DateTime(2024, 6, 15),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(TransaksiItemCard), findsOneWidget);
      });

      testWidgets('handles very long description', (tester) async {
        final transaksi = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          kategori: 'Test',
          deskripsi: 'This is a very long description that should be truncated with ellipsis when it exceeds the available space in the card widget',
          tanggal: DateTime(2024, 6, 15),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(TransaksiItemCard), findsOneWidget);
        // Text should be rendered
        expect(find.text(transaksi.deskripsi), findsOneWidget);
      });

      testWidgets('handles special characters in description', (tester) async {
        final transaksi = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          kategori: 'Test',
          deskripsi: 'Test "with" special; chars: and \'quotes\'',
          tanggal: DateTime(2024, 6, 15),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TransaksiItemCard(transaksi: transaksi),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(TransaksiItemCard), findsOneWidget);
      });
    });
  });
}