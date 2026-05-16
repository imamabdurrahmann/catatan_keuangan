import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/services/export_service.dart';
import 'package:catatan_keuangan/data/database_helper.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() async {
    // Reset any cached instance from previous test files to force fresh schema
    initializeTestEnvironment();
    await DatabaseHelper.resetForTesting();
    final db = await DatabaseHelper.instance.database;
    await db.delete('transaksi');
    // Ensure budget table has all required columns (may have been created
    // with old schema; migrate missing columns)
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

  group('ExportService singleton', () {
    test('instance returns same object', () {
      final a = ExportService.instance;
      final b = ExportService.instance;
      expect(a, same(b));
    });
  });

  group('exportTransactionsToCsv', () {
    test('returns string starting with UTF-8 BOM', () async {
      final csv = await ExportService.instance.exportTransactionsToCsv();
      expect(csv.codeUnitAt(0), equals(0xFEFF)); // UTF-8 BOM
    });

    test('contains header row with expected columns', () async {
      final csv = await ExportService.instance.exportTransactionsToCsv();
      // Remove BOM and check first line
      final contentWithoutBom = csv.substring(1);
      final firstLine = contentWithoutBom.split('\r\n').first;
      expect(firstLine, contains('Tanggal'));
      expect(firstLine, contains('Jenis'));
      expect(firstLine, contains('Jumlah'));
      expect(firstLine, contains('Kategori'));
      expect(firstLine, contains('Deskripsi'));
      expect(firstLine, contains('Dompet'));
      expect(firstLine, contains('Lampiran'));
    });

    test('uses semicolon as delimiter', () async {
      final csv = await ExportService.instance.exportTransactionsToCsv();
      final contentWithoutBom = csv.substring(1);
      final firstLine = contentWithoutBom.split('\r\n').first;
      // Count semicolons — 6 delimiters between 7 columns
      final semicolons = ';'.allMatches(firstLine).length;
      expect(semicolons, equals(6));
    });

    test('has no data rows when database is empty', () async {
      final csv = await ExportService.instance.exportTransactionsToCsv();
      final contentWithoutBom = csv.substring(1);
      final lines = contentWithoutBom
          .split('\r\n')
          .where((l) => l.isNotEmpty)
          .toList();
      // Only header row
      expect(lines.length, equals(1));
    });
  });
}
