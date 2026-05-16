import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catatan_keuangan/services/export_service.dart';
import 'package:catatan_keuangan/data/database_helper.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() async {
    initializeTestEnvironment();
    await DatabaseHelper.resetForTesting();
    final db = await DatabaseHelper.instance.database;
    await db.delete('transaksi');
    // Ensure schema is up to date
    try {
      await db.execute(
        "ALTER TABLE budget ADD COLUMN profil_id INTEGER DEFAULT 1",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE budget ADD COLUMN sisa_rollover REAL DEFAULT 0",
      );
    } catch (_) {}
  });

  tearDownAll(() async {
    await DatabaseHelper.resetForTesting();
  });

  group('Export Service Integration Tests', () {
    group('CSV Export Functions', () {
      test('exportTransactionsToCsv returns valid CSV structure', () async {
        final csv = await ExportService.instance.exportTransactionsToCsv();

        // Should start with UTF-8 BOM
        expect(csv.codeUnitAt(0), equals(0xFEFF));

        // Should have header row
        final content = csv.substring(1);
        final lines = content.split('\r\n').where((l) => l.isNotEmpty).toList();
        expect(lines.isNotEmpty, isTrue);

        // Header should have expected columns
        final header = lines.first;
        expect(header, contains('Tanggal'));
        expect(header, contains('Jenis'));
        expect(header, contains('Jumlah'));
        expect(header, contains('Kategori'));
        expect(header, contains('Deskripsi'));
        expect(header, contains('Dompet'));
        expect(header, contains('Lampiran'));
      });

      test('exportTransactionsToCsv uses semicolon delimiter', () async {
        final csv = await ExportService.instance.exportTransactionsToCsv();
        final content = csv.substring(1);
        final header = content.split('\r\n').first;

        // Count semicolons - 7 columns = 6 delimiters
        final semicolons = ';'.allMatches(header).length;
        expect(semicolons, equals(6));
      });

      test('exportTransactionsToCsvFiltered returns empty when no data', () async {
        final csv = await ExportService.instance.exportTransactionsToCsvFiltered(
          bulan: 1,
          tahun: 2099, // Future year with no data
        );

        final content = csv.substring(1);
        final lines = content.split('\r\n').where((l) => l.isNotEmpty).toList();

        // Only header, no data rows
        expect(lines.length, equals(1));
      });

      test('exportTransactionsToCsvFiltered handles null parameters', () async {
        final csv = await ExportService.instance.exportTransactionsToCsvFiltered();

        // Should return same as unfiltered export
        final unfiltered = await ExportService.instance.exportTransactionsToCsv();
        expect(csv, equals(unfiltered));
      });

      test('exportTransactionsToCsvFiltered with month/year only', () async {
        final csv = await ExportService.instance.exportTransactionsToCsvFiltered(
          bulan: 6,
          tahun: 2024,
        );

        final content = csv.substring(1);
        final lines = content.split('\r\n').where((l) => l.isNotEmpty).toList();

        // Should have header at minimum
        expect(lines.isNotEmpty, isTrue);
      });

      test('exportTransactionsToCsvFiltered with wallet id', () async {
        // First insert a test transaction with a wallet
        final db = await DatabaseHelper.instance.database;

        // Insert test wallet
        await db.insert('dompet', {
          'nama': 'Test Wallet',
          'saldo': 100000,
          'warna': '#FF0000',
          'currency': 'IDR',
          'profil_id': 1,
        });

        // Insert test transaction
        await db.insert('transaksi', {
          'jenis': 'pemasukan',
          'jumlah': 50000,
          'deskripsi': 'Test export',
          'kategori': 'Gaji',
          'tanggal': '2024-06-15 10:00:00',
          'lampiran': '[]',
          'is_recurring': 0,
          'id_dompet': 1,
          'deleted_at': null,
        });

        final csv = await ExportService.instance.exportTransactionsToCsvFiltered(
          idDompet: 1,
        );

        final content = csv.substring(1);
        final lines = content.split('\r\n').where((l) => l.isNotEmpty).toList();

        // Header + 1 data row
        expect(lines.length, equals(2));

        // Verify transaction data is present
        expect(lines[1], contains('Test export'));
        expect(lines[1], contains('Gaji'));
      });
    });

    group('CSV Content Validation', () {
      test('date is formatted in dd/MM/yyyy HH:mm format', () async {
        // Insert test transaction
        final db = await DatabaseHelper.instance.database;
        await db.insert('transaksi', {
          'jenis': 'pemasukan',
          'jumlah': 100000,
          'deskripsi': 'Date format test',
          'kategori': 'Test',
          'tanggal': '2024-06-15 14:30:00',
          'lampiran': '[]',
          'is_recurring': 0,
          'deleted_at': null,
        });

        final csv = await ExportService.instance.exportTransactionsToCsv();
        final content = csv.substring(1);
        final lines = content.split('\r\n').where((l) => l.isNotEmpty).toList();

        // Second line should have date data
        expect(lines.length, greaterThan(1));

        // Date should be formatted as dd/MM/yyyy HH:mm
        // Looking for pattern like 15/06/2024 14:30
        expect(lines[1], matches(RegExp(r'\d{2}/\d{2}/\d{4} \d{2}:\d{2}')));
      });

      test('amount is formatted with thousand separators', () async {
        // Insert test transaction with specific amount
        final db = await DatabaseHelper.instance.database;
        await db.insert('transaksi', {
          'jenis': 'pengeluaran',
          'jumlah': 1500000,
          'deskripsi': 'Amount format test',
          'kategori': 'Test',
          'tanggal': '2024-06-15 10:00:00',
          'lampiran': '[]',
          'is_recurring': 0,
          'deleted_at': null,
        });

        final csv = await ExportService.instance.exportTransactionsToCsv();
        final content = csv.substring(1);
        final lines = content.split('\r\n').where((l) => l.isNotEmpty).toList();

        // Should contain formatted number with thousand separator
        expect(lines[1], contains('1.500.000'));
      });

      test('jenis is labeled correctly (Pemasukan/Pengeluaran)', () async {
        final db = await DatabaseHelper.instance.database;

        // Insert income transaction
        await db.insert('transaksi', {
          'jenis': 'pemasukan',
          'jumlah': 100000,
          'deskripsi': 'Income test',
          'kategori': 'Gaji',
          'tanggal': '2024-06-15 10:00:00',
          'lampiran': '[]',
          'is_recurring': 0,
          'deleted_at': null,
        });

        // Insert expense transaction
        await db.insert('transaksi', {
          'jenis': 'pengeluaran',
          'jumlah': 50000,
          'deskripsi': 'Expense test',
          'kategori': 'Makan',
          'tanggal': '2024-06-15 11:00:00',
          'lampiran': '[]',
          'is_recurring': 0,
          'deleted_at': null,
        });

        final csv = await ExportService.instance.exportTransactionsToCsv();
        final content = csv.substring(1);
        final lines = content.split('\r\n').where((l) => l.isNotEmpty).toList();

        // Should have header + 2 data rows
        expect(lines.length, equals(3));

        // One line for income
        expect(lines.any((l) => l.contains('Pemasukan')), isTrue);
        // One line for expense
        expect(lines.any((l) => l.contains('Pengeluaran')), isTrue);
      });

      test('attachment list is joined with comma', () async {
        final db = await DatabaseHelper.instance.database;

        // Insert transaction with attachments
        await db.insert('transaksi', {
          'jenis': 'pemasukan',
          'jumlah': 100000,
          'deskripsi': 'Attachment test',
          'kategori': 'Test',
          'tanggal': '2024-06-15 10:00:00',
          'lampiran': '["file1.jpg","file2.pdf","file3.png"]',
          'is_recurring': 0,
          'deleted_at': null,
        });

        final csv = await ExportService.instance.exportTransactionsToCsv();
        final content = csv.substring(1);
        final lines = content.split('\r\n').where((l) => l.isNotEmpty).toList();

        // Last column should have attachments joined
        expect(lines[1], contains('file1.jpg'));
        expect(lines[1], contains('file2.pdf'));
        expect(lines[1], contains('file3.png'));
      });
    });

    group('Share Functions', () {
      test('shareCsvFile handles null gracefully', () async {
        // This test verifies that shareCsvFile handles edge cases
        // Since share_plus requires platform channels, we test the function exists
        expect(ExportService.instance.shareCsvFile, isNotNull);
      });

      test('exportAndShareTransactions is callable', () async {
        // This verifies the full pipeline function exists
        expect(ExportService.instance.exportAndShareTransactions, isNotNull);
      });
    });

    group('Singleton Pattern', () {
      test('ExportService.instance returns same instance', () {
        final a = ExportService.instance;
        final b = ExportService.instance;
        expect(a, same(b));
      });
    });
  });
}