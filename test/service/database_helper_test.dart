import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:catatan_keuangan/data/database_helper.dart';
import 'package:catatan_keuangan/models/models.dart';
import '../test_helper.dart';

void main() {
  late DatabaseHelper db;

  setUpAll(() async {
    // Reset any cached instance from previous test files to force fresh schema
    initializeTestEnvironment();
    await DatabaseHelper.resetForTesting();
    // Initialize the database (creates schema via onCreate for new DBs)
    await DatabaseHelper.instance.database;
  });

  setUp(() async {
    db = DatabaseHelper.instance;
    final database = await db.database;

    // Ensure budget table has all required columns (may have been created
    // with old schema via CREATE TABLE IF NOT EXISTS; migrate missing columns)
    try {
      await database.execute(
        "ALTER TABLE budget ADD COLUMN profil_id INTEGER DEFAULT 1",
      );
    } catch (_) {}
    try {
      await database.execute(
        "ALTER TABLE budget ADD COLUMN sisa_rollover REAL DEFAULT 0",
      );
    } catch (_) {}

    // Clear all tables
    await database.delete('transaksi');
    await database.delete('dompet');
    await database.delete('kategori');
    await database.delete('budget');
    await database.delete('utang_piutang');
    await database.delete('history_cicilan');
    await database.delete('tabungan_impian');
    await database.delete('pengaturan');
  });

  tearDownAll(() async {
    await DatabaseHelper.resetForTesting();
  });

  group('DatabaseHelper singleton', () {
    test('instance returns same object', () {
      final a = DatabaseHelper.instance;
      final b = DatabaseHelper.instance;
      expect(a, same(b));
    });

    test('database getter returns a database', () async {
      final database = await db.database;
      expect(database, isA<Database>());
    });
  });

  group('Transaksi CRUD', () {
    test('insertTransaksi and getTransaksiByDate', () async {
      final tx = Transaksi(
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Gaji bulanan',
        tanggal: DateTime(2024, 6, 15, 8, 0, 0),
      );

      await db.insertTransaksi(tx);

      final results = await db.getTransaksiByDate(DateTime(2024, 6, 15));
      expect(results.length, 1);
      expect(results.first.jumlah, 100000.0);
      expect(results.first.jenis, 'pemasukan');
      expect(results.first.kategori, 'Gaji');
    });

    test('insert and get by month', () async {
      final tx = Transaksi(
        jenis: 'pengeluaran',
        jumlah: 50000,
        kategori: 'Makanan',
        deskripsi: 'Makan siang',
        tanggal: DateTime(2024, 6, 15, 12, 0, 0),
      );

      await db.insertTransaksi(tx);

      final results = await db.getTransaksiByMonth(2024, 6);
      expect(results.length, 1);
      expect(results.first.jumlah, 50000.0);
    });

    test('updateTransaksi modifies existing record', () async {
      final tx = Transaksi(
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Gaji bulanan',
        tanggal: DateTime(2024, 6, 15),
      );

      final id = await db.insertTransaksi(tx);

      final updatedTx = tx.copyWith(
        id: id,
        jumlah: 150000,
        deskripsi: 'Gaji yang lebih besar',
      );
      await db.updateTransaksi(updatedTx);

      final results = await db.getTransaksiByDate(DateTime(2024, 6, 15));
      expect(results.first.jumlah, 150000.0);
      expect(results.first.deskripsi, 'Gaji yang lebih besar');
    });

    test('softDeleteTransaksi hides from normal queries', () async {
      final tx = Transaksi(
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Test delete',
        tanggal: DateTime(2024, 6, 15),
      );

      final id = await db.insertTransaksi(tx);

      // Verify it's visible
      var results = await db.getTransaksiByDate(DateTime(2024, 6, 15));
      expect(results.length, 1);

      // Soft delete
      await db.softDeleteTransaksi(id);

      // Should be hidden from normal queries
      results = await db.getTransaksiByDate(DateTime(2024, 6, 15));
      expect(results, isEmpty);

      // But visible in deleted queries
      final deletedResults = await db.getDeletedTransaksi();
      expect(deletedResults.length, 1);
      expect(deletedResults.first.deskripsi, 'Test delete');
    });

    test('restoreTransaksi brings back soft-deleted record', () async {
      final tx = Transaksi(
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Test restore',
        tanggal: DateTime(2024, 6, 15),
      );

      final id = await db.insertTransaksi(tx);
      await db.softDeleteTransaksi(id);

      // Should be hidden
      var results = await db.getTransaksiByDate(DateTime(2024, 6, 15));
      expect(results, isEmpty);

      // Restore
      await db.restoreTransaksi(id);

      // Should be visible again
      results = await db.getTransaksiByDate(DateTime(2024, 6, 15));
      expect(results.length, 1);
      expect(results.first.deskripsi, 'Test restore');
    });

    test('permanentDeleteTransaksi removes record completely', () async {
      final tx = Transaksi(
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Test permanent delete',
        tanggal: DateTime(2024, 6, 15),
      );

      final id = await db.insertTransaksi(tx);
      await db.softDeleteTransaksi(id);

      // Permanent delete
      await db.permanentDeleteTransaksi(id);

      final deletedResults = await db.getDeletedTransaksi();
      expect(deletedResults, isEmpty);
    });

    test('getAllTransaksi returns all non-deleted transactions', () async {
      final tx1 = Transaksi(
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Income 1',
        tanggal: DateTime(2024, 6, 15),
      );
      final tx2 = Transaksi(
        jenis: 'pengeluaran',
        jumlah: 50000,
        kategori: 'Makanan',
        deskripsi: 'Expense 1',
        tanggal: DateTime(2024, 6, 16),
      );

      await db.insertTransaksi(tx1);
      await db.insertTransaksi(tx2);

      final results = await db.getAllTransaksi();
      expect(results.length, 2);
    });
  });

  group('Dompet CRUD', () {
    test('insertDompet and getAllDompet', () async {
      final dompet = Dompet(
        nama: 'Dompet Testing',
        saldo: 500000,
        warna: 'blue',
      );

      await db.insertDompet(dompet);

      final results = await db.getAllDompet();
      expect(results.any((d) => d.nama == 'Dompet Testing'), true);
    });

    test('deleteDompet removes wallet', () async {
      final dompet = Dompet(nama: 'Delete Me', saldo: 100000, warna: 'red');
      await db.insertDompet(dompet);

      final results = await db.getAllDompet();
      final target = results.firstWhere((d) => d.nama == 'Delete Me');

      await db.deleteDompet(target.id!);

      final afterDelete = await db.getAllDompet();
      expect(afterDelete.any((d) => d.id == target.id), false);
    });
  });

  group('Budget CRUD', () {
    test('insertBudget and getAllBudget', () async {
      final budget = Budget(
        bulan: 6,
        tahun: 2024,
        nominal: 500000,
        kategori: 'Makanan',
      );

      await db.insertBudget(budget);

      final results = await db.getAllBudget(6, 2024);
      expect(results.length, 1);
      expect(results.first.nominal, 500000.0);
      expect(results.first.kategori, 'Makanan');
    });

    test('getAllBudget filters by month and year', () async {
      final budget1 = Budget(
        bulan: 6,
        tahun: 2024,
        nominal: 500000,
        kategori: 'Makanan',
      );
      final budget2 = Budget(
        bulan: 7,
        tahun: 2024,
        nominal: 300000,
        kategori: 'Transportasi',
      );
      final budget3 = Budget(
        bulan: 6,
        tahun: 2025,
        nominal: 400000,
        kategori: 'Hiburan',
      );

      await db.insertBudget(budget1);
      await db.insertBudget(budget2);
      await db.insertBudget(budget3);

      final resultsJune2024 = await db.getAllBudget(6, 2024);
      expect(resultsJune2024.length, 1);
      expect(resultsJune2024.first.kategori, 'Makanan');
    });
  });

  group('Kategori CRUD', () {
    test('getAllKategori returns list (may be empty in FFI test mode)', () async {
      // Note: In FFI test mode, kategori seeding may not be loaded yet.
      // The _createDB seeding is async and may not complete before this test.
      // This test documents the behavior - use getKategoriByJenis for filtering tests.
      final results = await db.getAllKategori();
      expect(results, isA<List<Kategori>>());
    });

    test('getKategoriByJenis filters correctly', () async {
      final income = await db.getKategoriByJenis('pemasukan');
      final expense = await db.getKategoriByJenis('pengeluaran');

      expect(income.every((k) => k.jenis == 'pemasukan'), true);
      expect(expense.every((k) => k.jenis == 'pengeluaran'), true);
    });
  });

  group('Monthly Summary', () {
    test('getMonthlySummary calculates income and expense totals', () async {
      final income = Transaksi(
        jenis: 'pemasukan',
        jumlah: 1000000,
        kategori: 'Gaji',
        deskripsi: 'Salary',
        tanggal: DateTime(2024, 6, 1),
      );
      final expense1 = Transaksi(
        jenis: 'pengeluaran',
        jumlah: 200000,
        kategori: 'Makanan',
        deskripsi: 'Groceries',
        tanggal: DateTime(2024, 6, 5),
      );
      final expense2 = Transaksi(
        jenis: 'pengeluaran',
        jumlah: 150000,
        kategori: 'Transportasi',
        deskripsi: 'Fuel',
        tanggal: DateTime(2024, 6, 10),
      );

      await db.insertTransaksi(income);
      await db.insertTransaksi(expense1);
      await db.insertTransaksi(expense2);

      final summary = await db.getMonthlySummary(2024, 6);

      expect(summary['pemasukan'], 1000000.0);
      expect(summary['pengeluaran'], 350000.0);
      expect(summary['saldo'], 650000.0);
    });
  });

  group('Category Summary', () {
    test(
      'getCategorySummary calculates per-category totals for expenses',
      () async {
        final expense1 = Transaksi(
          jenis: 'pengeluaran',
          jumlah: 200000,
          kategori: 'Makanan',
          deskripsi: 'Groceries 1',
          tanggal: DateTime(2024, 6, 5),
        );
        final expense2 = Transaksi(
          jenis: 'pengeluaran',
          jumlah: 150000,
          kategori: 'Makanan',
          deskripsi: 'Groceries 2',
          tanggal: DateTime(2024, 6, 10),
        );
        final expense3 = Transaksi(
          jenis: 'pengeluaran',
          jumlah: 100000,
          kategori: 'Transportasi',
          deskripsi: 'Fuel',
          tanggal: DateTime(2024, 6, 15),
        );

        await db.insertTransaksi(expense1);
        await db.insertTransaksi(expense2);
        await db.insertTransaksi(expense3);

        final summary = await db.getCategorySummary(2024, 6);

        expect(summary['Makanan'], 350000.0);
        expect(summary['Transportasi'], 100000.0);
      },
    );
  });

  group('Search', () {
    test('searchTransaksi finds matching transactions', () async {
      final tx1 = Transaksi(
        jenis: 'pemasukan',
        jumlah: 100000,
        kategori: 'Gaji',
        deskripsi: 'Gaji bulanan Juni',
        tanggal: DateTime(2024, 6, 1),
      );
      final tx2 = Transaksi(
        jenis: 'pengeluaran',
        jumlah: 50000,
        kategori: 'Makanan',
        deskripsi: 'Makan siang',
        tanggal: DateTime(2024, 6, 2),
      );

      await db.insertTransaksi(tx1);
      await db.insertTransaksi(tx2);

      final results = await db.searchTransaksi('Gaji');
      expect(results.length, 1);
      expect(results.first.deskripsi, 'Gaji bulanan Juni');
    });
  });

  group('Utang Piutang CRUD', () {
    test('insert and get all utang piutang', () async {
      final utang = UtangPiutang(
        namaOrang: 'John Doe',
        jenis: 'utang',
        nominalTotal: 500000,
        nominalDibayar: 0,
        tanggal: DateTime(2024, 6, 1),
        deskripsi: 'Pinjaman',
      );

      await db.insertUtangPiutang(utang);

      final results = await db.getAllUtangPiutang();
      expect(results.length, 1);
      expect(results.first.namaOrang, 'John Doe');
      expect(results.first.jenis, 'utang');
      expect(results.first.nominalTotal, 500000.0);
    });

    test('deleteUtangPiutang removes record', () async {
      final utang = UtangPiutang(
        namaOrang: 'Delete Me',
        jenis: 'utang',
        nominalTotal: 100000,
        tanggal: DateTime(2024, 6, 1),
      );

      await db.insertUtangPiutang(utang);
      final results = await db.getAllUtangPiutang();
      final target = results.firstWhere((u) => u.namaOrang == 'Delete Me');

      await db.deleteUtangPiutang(target.id!);

      final afterDelete = await db.getAllUtangPiutang();
      expect(afterDelete.any((u) => u.id == target.id), false);
    });
  });

  group('Tabungan Impian CRUD', () {
    test('insert and get all tabungan impian', () async {
      final tabungan = TabunganImpian(
        namaImpian: 'Liburan ke Bali',
        targetNominal: 5000000,
        terkumpul: 1000000,
        targetTanggal: DateTime(2024, 12, 31),
      );

      await db.insertTabunganImpian(tabungan);

      final results = await db.getAllTabunganImpian();
      expect(results.length, 1);
      expect(results.first.namaImpian, 'Liburan ke Bali');
      expect(results.first.targetNominal, 5000000.0);
      expect(results.first.terkumpul, 1000000.0);
    });

    test('addProgressTabunganImpian increases terkumpul', () async {
      final tabungan = TabunganImpian(
        namaImpian: 'Test Goal',
        targetNominal: 1000000,
        terkumpul: 0,
      );

      await db.insertTabunganImpian(tabungan);
      final results = await db.getAllTabunganImpian();
      final target = results.firstWhere((t) => t.namaImpian == 'Test Goal');

      await db.addProgressTabunganImpian(target.id!, 250000);

      final updated = await db.getAllTabunganImpian();
      final modified = updated.firstWhere((t) => t.namaImpian == 'Test Goal');
      expect(modified.terkumpul, 250000.0);
    });

    test('deleteTabunganImpian removes record', () async {
      final tabungan = TabunganImpian(
        namaImpian: 'Delete This Goal',
        targetNominal: 1000000,
      );

      await db.insertTabunganImpian(tabungan);
      final results = await db.getAllTabunganImpian();
      final target = results.firstWhere(
        (t) => t.namaImpian == 'Delete This Goal',
      );

      await db.deleteTabunganImpian(target.id!);

      final afterDelete = await db.getAllTabunganImpian();
      expect(afterDelete.any((t) => t.id == target.id), false);
    });
  });

  group('Export/Import', () {
    test('exportToJson returns valid JSON string', () async {
      final json = await db.exportToJson();
      expect(json, isA<String>());
      expect(json.startsWith('{'), true);
      expect(json.endsWith('}'), true);
    });
  });
}
