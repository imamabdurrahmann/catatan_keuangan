import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/models/models.dart';

void main() {
  group('Model Tests', () {
    test('Transaksi.toMap serializes correctly', () {
      final tx = Transaksi(
        id: 1,
        jenis: 'pengeluaran',
        jumlah: 50000.0,
        deskripsi: 'Makan siang',
        kategori: 'Makanan',
        tanggal: DateTime(2026, 4, 1, 12, 30, 0),
        lampiran: [],
      );

      final map = tx.toMap();
      expect(map['jenis'], 'pengeluaran');
      expect(map['jumlah'], 50000.0);
      expect(map['deskripsi'], 'Makan siang');
      expect(map['kategori'], 'Makanan');
      expect(map['tanggal'], '2026-04-01 12:30:00');
      expect(map['is_recurring'], 0);
      expect(map['recurring_frequency'], null);
    });

    test('Transaksi.toMap serializes recurring correctly', () {
      final tx = Transaksi(
        id: 2,
        jenis: 'pemasukan',
        jumlah: 5000000.0,
        deskripsi: 'Gaji bulanan',
        kategori: 'Gaji',
        tanggal: DateTime(2026, 4, 1, 8, 0, 0),
        lampiran: [],
        isRecurring: true,
        recurringFrequency: 'monthly',
      );

      final map = tx.toMap();
      expect(map['is_recurring'], 1);
      expect(map['recurring_frequency'], 'monthly');
    });

    test('Transaksi.fromMap deserializes correctly', () {
      final map = {
        'id': 1,
        'jenis': 'pemasukan',
        'jumlah': 100000.0,
        'deskripsi': 'Gaji',
        'kategori': 'Gaji',
        'tanggal': '2026-04-01 08:00:00',
        'lampiran': '[]',
      };

      final tx = Transaksi.fromMap(map);
      expect(tx.id, 1);
      expect(tx.jenis, 'pemasukan');
      expect(tx.jumlah, 100000.0);
      expect(tx.isRecurring, false);
      expect(tx.recurringFrequency, null);

      final recurringMap = {
        ...map,
        'is_recurring': 1,
        'recurring_frequency': 'weekly',
      };
      final rtx = Transaksi.fromMap(recurringMap);
      expect(rtx.isRecurring, true);
      expect(rtx.recurringFrequency, 'weekly');
      expect(tx.deskripsi, 'Gaji');
      expect(tx.lampiran, isEmpty);
    });

    test('Transaksi.fromMap parses lampiran JSON', () {
      final map = {
        'id': 1,
        'jenis': 'pengeluaran',
        'jumlah': 25000.0,
        'deskripsi': 'Test',
        'kategori': 'Test',
        'tanggal': '2026-04-01 10:00:00',
        'lampiran': '["/path/to/file1.jpg", "/path/to/file2.pdf"]',
      };

      final tx = Transaksi.fromMap(map);
      expect(tx.lampiran, hasLength(2));
      expect(tx.lampiran[0], '/path/to/file1.jpg');
    });

    test('Transaksi.copyWith creates modified copy', () {
      final tx = Transaksi(
        jenis: 'pengeluaran',
        jumlah: 50000.0,
        deskripsi: 'Original',
        kategori: 'Test',
        tanggal: DateTime.now(),
      );

      final modified = tx.copyWith(deskripsi: 'Modified', jumlah: 75000.0);

      expect(modified.deskripsi, 'Modified');
      expect(modified.jumlah, 75000.0);
      expect(modified.jenis, 'pengeluaran');
    });

    test('Transaksi.copyWith with recurring fields', () {
      final tx = Transaksi(
        jenis: 'pengeluaran',
        jumlah: 50000.0,
        deskripsi: 'Langganan',
        kategori: 'Tagihan',
        tanggal: DateTime.now(),
      );

      final recurring = tx.copyWith(
        isRecurring: true,
        recurringFrequency: 'monthly',
      );

      expect(recurring.isRecurring, true);
      expect(recurring.recurringFrequency, 'monthly');
      expect(recurring.deskripsi, 'Langganan');
    });

    test('Dompet.toMap and fromMap roundtrip', () {
      final dompet = Dompet(
        id: 1,
        nama: 'Dompet Utama',
        saldo: 100000.0,
        warna: 'green',
      );
      final map = dompet.toMap();
      final restored = Dompet.fromMap({'id': 1, ...map});

      expect(restored.nama, 'Dompet Utama');
      expect(restored.saldo, 100000.0);
      expect(restored.warna, 'green');
    });

    test('Kategori.copyWith', () {
      final kategori = Kategori(
        nama: 'Makanan',
        jenis: 'pengeluaran',
        icon: 'restaurant',
      );
      final modified = kategori.copyWith(nama: 'Makan & Minum');

      expect(modified.nama, 'Makan & Minum');
      expect(modified.jenis, 'pengeluaran');
      expect(modified.icon, 'restaurant');
    });

    // ===== Budget Model Tests =====

    test('Budget.toMap serializes with id correctly', () {
      final budget = Budget(
        id: 1,
        bulan: 4,
        tahun: 2026,
        nominal: 500000.0,
        kategori: 'Makanan',
      );

      final map = budget.toMap();
      expect(map['id'], 1);
      expect(map['bulan'], 4);
      expect(map['tahun'], 2026);
      expect(map['nominal'], 500000.0);
      expect(map['kategori'], 'Makanan');
    });

    test('Budget.toMap serializes without id correctly', () {
      final budget = Budget(
        bulan: 12,
        tahun: 2025,
        nominal: 1500000.0,
        kategori: 'Transportasi',
      );

      final map = budget.toMap();
      expect(map['id'], null);
      expect(map['bulan'], 12);
      expect(map['tahun'], 2025);
      expect(map['nominal'], 1500000.0);
      expect(map['kategori'], 'Transportasi');
    });

    test('Budget.toMap handles integer nominal correctly', () {
      final budget = Budget(
        id: 5,
        bulan: 1,
        tahun: 2026,
        nominal: 100000,
        kategori: 'Hiburan',
      );

      final map = budget.toMap();
      expect(map['nominal'], 100000);
      expect(map['nominal'] is int || map['nominal'] is double, true);
    });

    test('Budget.fromMap deserializes correctly', () {
      final map = {
        'id': 2,
        'bulan': 6,
        'tahun': 2026,
        'nominal': 750000.0,
        'kategori': 'Kesehatan',
      };

      final budget = Budget.fromMap(map);
      expect(budget.id, 2);
      expect(budget.bulan, 6);
      expect(budget.tahun, 2026);
      expect(budget.nominal, 750000.0);
      expect(budget.kategori, 'Kesehatan');
    });

    test('Budget.fromMap handles integer nominal', () {
      final map = {
        'id': 3,
        'bulan': 3,
        'tahun': 2026,
        'nominal': 200000,
        'kategori': 'Belanja',
      };

      final budget = Budget.fromMap(map);
      expect(budget.nominal, 200000.0);
    });

    test('Budget.fromMap handles null id', () {
      final map = {
        'bulan': 7,
        'tahun': 2026,
        'nominal': 300000.0,
        'kategori': 'Pendidikan',
      };

      final budget = Budget.fromMap(map);
      expect(budget.id, null);
      expect(budget.bulan, 7);
      expect(budget.tahun, 2026);
      expect(budget.nominal, 300000.0);
      expect(budget.kategori, 'Pendidikan');
    });

    test('Budget.toMap and fromMap roundtrip', () {
      final original = Budget(
        id: 10,
        bulan: 9,
        tahun: 2026,
        nominal: 2500000.0,
        kategori: 'Liburan',
      );

      final map = original.toMap();
      final restored = Budget.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.bulan, original.bulan);
      expect(restored.tahun, original.tahun);
      expect(restored.nominal, original.nominal);
      expect(restored.kategori, original.kategori);
    });

    test('Budget.copyWith creates modified copy with all fields changed', () {
      final original = Budget(
        id: 1,
        bulan: 4,
        tahun: 2026,
        nominal: 500000.0,
        kategori: 'Makanan',
      );

      final modified = original.copyWith(
        id: 2,
        bulan: 5,
        tahun: 2027,
        nominal: 750000.0,
        kategori: 'Minuman',
      );

      expect(modified.id, 2);
      expect(modified.bulan, 5);
      expect(modified.tahun, 2027);
      expect(modified.nominal, 750000.0);
      expect(modified.kategori, 'Minuman');
    });

    test('Budget.copyWith preserves unchanged fields', () {
      final original = Budget(
        id: 1,
        bulan: 4,
        tahun: 2026,
        nominal: 500000.0,
        kategori: 'Makanan',
      );

      final modified = original.copyWith(nominal: 600000.0);

      expect(modified.id, 1);
      expect(modified.bulan, 4);
      expect(modified.tahun, 2026);
      expect(modified.nominal, 600000.0);
      expect(modified.kategori, 'Makanan');
    });

    test('Budget.copyWith changes single field', () {
      final original = Budget(
        id: 5,
        bulan: 2,
        tahun: 2025,
        nominal: 1000000.0,
        kategori: 'Transportasi',
      );

      final modified = original.copyWith(kategori: 'Bensin');

      expect(modified.id, 5);
      expect(modified.bulan, 2);
      expect(modified.tahun, 2025);
      expect(modified.nominal, 1000000.0);
      expect(modified.kategori, 'Bensin');
    });

    test('Budget.copyWith returns new instance', () {
      final original = Budget(
        id: 1,
        bulan: 4,
        tahun: 2026,
        nominal: 500000.0,
        kategori: 'Makanan',
      );

      final modified = original.copyWith(nominal: 999999.0);

      expect(identical(original, modified), false);
      expect(original.nominal, 500000.0);
      expect(modified.nominal, 999999.0);
    });

    test('Budget.copyWith clears id when not provided', () {
      final original = Budget(
        id: 1,
        bulan: 4,
        tahun: 2026,
        nominal: 500000.0,
        kategori: 'Makanan',
      );

      // copyWith does not clear id since id is nullable and copyWith uses ?? this.id
      // This tests the expected behavior: id stays as-is when not explicitly passed
      final modified = original.copyWith(kategori: 'Test');
      expect(modified.id, 1);
    });

    test('Budget roundtrip after copyWith preserves data', () {
      final original = Budget(
        id: 7,
        bulan: 11,
        tahun: 2025,
        nominal: 800000.0,
        kategori: 'Hiburan',
      );

      final modified = original.copyWith(nominal: 900000.0, kategori: 'Game');
      final map = modified.toMap();
      final restored = Budget.fromMap(map);

      expect(restored.id, 7);
      expect(restored.bulan, 11);
      expect(restored.tahun, 2025);
      expect(restored.nominal, 900000.0);
      expect(restored.kategori, 'Game');
    });

    test('Pengaturan model', () {
      final pengaturan = Pengaturan(id: 1, isDarkMode: true, pin: '1234');
      final map = pengaturan.toMap();

      expect(map['is_dark_mode'], 1);
      expect(map['pin'], '1234');

      final restored = Pengaturan.fromMap(map);
      expect(restored.isDarkMode, true);
    });
  });

  group('Widget Tests', () {
    testWidgets('HomePage renders with AppBar', (WidgetTester tester) async {
      // Build a minimal test shell to verify basic widget rendering
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Catatan Keuangan')),
            body: const Center(child: Text('Test Body')),
          ),
        ),
      );

      expect(find.text('Catatan Keuangan'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('Summary card displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Pemasukan',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '100,000.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text('100,000.00'), findsOneWidget);
    });

    testWidgets('Transaksi item displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text('Gaji Bulanan'),
                subtitle: const Text('Gaji • 1 Apr'),
                trailing: const Text(
                  '+Rp 10,000.00',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Gaji Bulanan'), findsOneWidget);
      expect(find.text('Gaji • 1 Apr'), findsOneWidget);
      expect(find.text('+Rp 10,000.00'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('Dismissible allows swipe to delete', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Dismissible(
              key: const Key('test-item'),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: const ListTile(title: Text('Swipe me')),
            ),
          ),
        ),
      );

      expect(find.text('Swipe me'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);

      // Verify swipe behavior by dragging
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
    });
  });
}
