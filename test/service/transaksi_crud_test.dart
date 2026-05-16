import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/services/recurring_scheduler.dart';
import 'package:catatan_keuangan/data/database_helper.dart';
import 'package:catatan_keuangan/models/models.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() async {
    // Reset any cached instance from previous test files to force fresh schema
    initializeTestEnvironment();
    await DatabaseHelper.resetForTesting();
  });

  setUp(() async {
    final db = DatabaseHelper.instance;
    final database = await db.database;
    await database.delete('transaksi');
    await database.delete('dompet');
    await database.delete('kategori');
  });

  tearDownAll(() async {
    await DatabaseHelper.resetForTesting();
  });

  group('RecurringScheduler._calculateNextOccurrence unit tests', () {
    test('daily increments by 1 day', () {
      final scheduler = RecurringScheduler.instance;
      expect(
        scheduler.calculateNextOccurrence(DateTime(2024, 6, 1), 'daily'),
        DateTime(2024, 6, 2),
      );
    });

    test('weekly increments by 7 days', () {
      final scheduler = RecurringScheduler.instance;
      expect(
        scheduler.calculateNextOccurrence(DateTime(2024, 6, 1), 'weekly'),
        DateTime(2024, 6, 8),
      );
    });

    test('monthly increments month by 1', () {
      final scheduler = RecurringScheduler.instance;
      expect(
        scheduler.calculateNextOccurrence(DateTime(2024, 6, 1), 'monthly'),
        DateTime(2024, 7, 1),
      );
    });

    test('quarterly increments month by 3', () {
      final scheduler = RecurringScheduler.instance;
      expect(
        scheduler.calculateNextOccurrence(DateTime(2024, 3, 1), 'quarterly'),
        DateTime(2024, 6, 1),
      );
    });

    test('yearly increments year by 1', () {
      final scheduler = RecurringScheduler.instance;
      expect(
        scheduler.calculateNextOccurrence(DateTime(2024, 6, 1), 'yearly'),
        DateTime(2025, 6, 1),
      );
    });

    test('invalid frequency returns null', () {
      final scheduler = RecurringScheduler.instance;
      expect(
        scheduler.calculateNextOccurrence(DateTime(2024, 6, 1), 'biweekly'),
        isNull,
      );
      expect(
        scheduler.calculateNextOccurrence(DateTime(2024, 6, 1), ''),
        isNull,
      );
    });

    test('formatDateKey formats as YYYY-MM-DD', () {
      final scheduler = RecurringScheduler.instance;
      expect(scheduler.formatDateKey(DateTime(2024, 6, 5)), '2024-06-05');
      expect(scheduler.formatDateKey(DateTime(2024, 1, 1)), '2024-01-01');
    });
  });

  group('Transaction soft-delete and restore flow', () {
    setUp(() async {
      final db = DatabaseHelper.instance;
      final database = await db.database;
      await database.delete('transaksi');
      await database.delete('dompet');
      await DatabaseHelper.instance.insertDompet(
        Dompet(nama: 'Test', saldo: 0, warna: 'green'),
      );
    });

    test('softDeleteTransaksi sets deleted_at timestamp', () async {
      final db = DatabaseHelper.instance;
      final dompets = await db.getAllDompet();

      final tx = Transaksi(
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Test delete flow',
        tanggal: DateTime(2024, 6, 1),
        idDompet: dompets.first.id,
      );

      final id = await db.insertTransaksi(tx);
      await db.softDeleteTransaksi(id);

      // Verify deleted_at is set
      final dbRaw = await db.database;
      final result = await dbRaw.query(
        'transaksi',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(result.first['deleted_at'], isNotNull);
    });

    test('restoreTransaksi clears deleted_at', () async {
      final db = DatabaseHelper.instance;
      final dompets = await db.getAllDompet();

      final tx = Transaksi(
        jenis: 'pemasukan',
        jumlah: 200000,
        kategori: 'Bonus',
        deskripsi: 'Test restore flow',
        tanggal: DateTime(2024, 6, 2),
        idDompet: dompets.first.id,
      );

      final id = await db.insertTransaksi(tx);
      await db.softDeleteTransaksi(id);
      await db.restoreTransaksi(id);

      // Verify deleted_at is cleared
      final dbRaw = await db.database;
      final result = await dbRaw.query(
        'transaksi',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(result.first['deleted_at'], isNull);
    });

    test('permanentDeleteTransaksi removes row completely', () async {
      final db = DatabaseHelper.instance;
      final dompets = await db.getAllDompet();

      final tx = Transaksi(
        jenis: 'pengeluaran',
        jumlah: 30000,
        kategori: 'Makanan',
        deskripsi: 'Test permanent delete',
        tanggal: DateTime(2024, 6, 3),
        idDompet: dompets.first.id,
      );

      final id = await db.insertTransaksi(tx);
      await db.softDeleteTransaksi(id);
      await db.permanentDeleteTransaksi(id);

      final deleted = await db.getDeletedTransaksi();
      expect(deleted.any((t) => t.id == id), false);
    });

    test('getDeletedTransaksi returns only soft-deleted transactions', () async {
      final db = DatabaseHelper.instance;
      final dompets = await db.getAllDompet();

      // Create 3 transactions (tx1 is not stored to verify isolation of active items)
      await db.insertTransaksi(
        Transaksi(
          jenis: 'pemasukan',
          jumlah: 50000,
          kategori: 'Gaji',
          deskripsi: 'Active 1',
          tanggal: DateTime(2024, 6, 4),
          idDompet: dompets.first.id,
        ),
      );
      final id2 = await db.insertTransaksi(
        Transaksi(
          jenis: 'pengeluaran',
          jumlah: 10000,
          kategori: 'Makanan',
          deskripsi: 'Deleted 1',
          tanggal: DateTime(2024, 6, 5),
          idDompet: dompets.first.id,
        ),
      );
      await db.insertTransaksi(
        Transaksi(
          jenis: 'pemasukan',
          jumlah: 20000,
          kategori: 'Bonus',
          deskripsi: 'Deleted 2',
          tanggal: DateTime(2024, 6, 6),
          idDompet: dompets.first.id,
        ),
      );

      await db.softDeleteTransaksi(id2);

      final deleted = await db.getDeletedTransaksi();
      expect(deleted.length, equals(1));
      expect(deleted.first.deskripsi, equals('Deleted 1'));
    });
  });
}
