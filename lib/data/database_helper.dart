import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_pkg;
import '../models/models.dart';
import 'database.dart';
import 'daos/transaksi_dao.dart';
import 'daos/dompet_dao.dart';
import 'daos/kategori_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/utang_piutang_dao.dart';
import 'daos/tabungan_impian_dao.dart';
import 'daos/pengaturan_dao.dart';
import 'daos/profil_dao.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;
  static bool _daosInitialized = false;

  DatabaseHelper._();

  late final TransaksiDao transaksiDao;
  late final DompetDao dompetDao;
  late final KategoriDao kategoriDao;
  late final BudgetDao budgetDao;
  late final UtangPiutangDao utangPiutangDao;
  late final TabunganImpianDao tabunganImpianDao;
  late final PengaturanDao pengaturanDao;
  late final ProfilDao profilDao;

  Future<Database> get database async {
    if (_database != null) {
      _initDaos();
      return _database!;
    }
    _database = await _initDB('keuangan.db');
    _initDaos();
    return _database!;
  }

  void _initDaos() {
    if (_daosInitialized) return;
    _daosInitialized = true;
    transaksiDao = TransaksiDao(_database!);
    dompetDao = DompetDao(_database!);
    kategoriDao = KategoriDao(_database!);
    budgetDao = BudgetDao(_database!);
    utangPiutangDao = UtangPiutangDao(_database!);
    tabunganImpianDao = TabunganImpianDao(_database!);
    pengaturanDao = PengaturanDao(_database!);
    profilDao = ProfilDao(_database!);
  }

  /// Resets the cached database instance (for testing only).
  /// Closes the existing connection, nulls the cache, and resets DAO state.
  /// Call AFTER initializeTestEnvironment() has set up the FFI factory.
  static Future<void> resetForTesting() async {
    if (_database != null) {
      await _database!.close();
    }
    _database = null;
    _daosInitialized = false;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path_pkg.join(dbPath, filePath);

    return await openDatabase(
      dbFilePath,
      version: DB_VERSION,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await runMigrations(db, oldVersion, newVersion);
  }

  Future<void> _createDB(Database db, int version) async {
    await createSchema(db, version);
  }

  // -------------------------------------------------------------------------
  // DELEGATE METHODS (backwards compatibility — delegate to DAOs)
  // -------------------------------------------------------------------------

  // --- Transaksi ---
  Future<int> insertTransaksi(Transaksi transaksi) async {
    // Delegate to DAO so syncDompetSaldo is called after insert.
    return await transaksiDao.insertTransaksi(transaksi);
  }

  Future<List<Transaksi>> getAllTransaksi() async {
    final db = await instance.database;
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: 'deleted_at IS NULL',
      orderBy: 'tanggal DESC',
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<List<Transaksi>> getTransaksiByDate(DateTime date) async {
    return transaksiDao.getTransaksiByDate(date);
  }

  Future<List<Transaksi>> getTransaksiByMonth(
    int year,
    int month, {
    int? idDompet,
  }) async {
    return transaksiDao.getTransaksiByMonth(year, month, idDompet: idDompet);
  }

  Future<List<Transaksi>> searchTransaksi(String query) async {
    return transaksiDao.searchTransaksi(query);
  }

  Future<List<Transaksi>> searchTransaksiAdvanced({
    String? query,
    String? jenis,
    DateTime? dariTanggal,
    DateTime? sampaiTanggal,
    double? jumlahMin,
    double? jumlahMax,
    int limit = 50,
    String orderBy = 'tanggal DESC',
  }) async {
    return transaksiDao.searchTransaksiAdvanced(
      query: query,
      jenis: jenis,
      dariTanggal: dariTanggal,
      sampaiTanggal: sampaiTanggal,
      jumlahMin: jumlahMin,
      jumlahMax: jumlahMax,
      limit: limit,
      orderBy: orderBy,
    );
  }

  Future<List<String>> getUniqueDates() async {
    return transaksiDao.getUniqueDates();
  }

  Future<int> deleteTransaksi(int id) async {
    final db = await instance.database;
    return await db.delete(TABLE_TRANSAKSI, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> softDeleteTransaksi(int id) async {
    return transaksiDao.softDeleteTransaksi(id);
  }

  Future<List<Transaksi>> getDeletedTransaksi() async {
    return transaksiDao.getDeletedTransaksi();
  }

  Future<int> restoreTransaksi(int id) async {
    return transaksiDao.restoreTransaksi(id);
  }

  Future<int> permanentDeleteTransaksi(int id) async {
    return transaksiDao.permanentDeleteTransaksi(id);
  }

  Future<int> updateTransaksi(Transaksi transaksi) async {
    // Delegate to DAO so syncDompetSaldo is called after update.
    return await transaksiDao.updateTransaksi(transaksi);
  }

  Future<Map<String, double>> getMonthlySummary(
    int year,
    int month, {
    int? idDompet,
  }) async {
    return transaksiDao.getMonthlySummary(year, month, idDompet: idDompet);
  }

  Future<Map<String, double>> getCategorySummary(int year, int month) async {
    return transaksiDao.getCategorySummary(year, month);
  }

  Future<List<Transaksi>> getRecurringTransaksi() async {
    return transaksiDao.getRecurringTransaksi();
  }

  // --- Dompet ---
  Future<int> insertDompet(Dompet dompet) async {
    final db = await instance.database;
    // Ensure profil_id is set before insert (defaults to 1 in model)
    final map = dompet.toMap();
    map['profil_id'] = dompet.profilId;
    return await db.insert(TABLE_DOMPET, map);
  }

  Future<List<Dompet>> getAllDompet({int? profilId}) async {
    final db = await instance.database;
    final result = profilId != null
        ? await db.query(
            TABLE_DOMPET,
            where: 'profil_id = ?',
            whereArgs: [profilId],
          )
        : await db.query(TABLE_DOMPET);
    return result.map((map) => Dompet.fromMap(map)).toList();
  }

  Future<int> updateDompet(Dompet dompet) async {
    final db = await instance.database;
    return await db.update(
      TABLE_DOMPET,
      dompet.toMap(),
      where: 'id = ?',
      whereArgs: [dompet.id],
    );
  }

  Future<int> deleteDompet(int id) async {
    final db = await instance.database;
    return await db.delete(TABLE_DOMPET, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTransactionCountByDompet(int idDompet) async {
    return dompetDao.getTransactionCountByDompet(idDompet);
  }

  Future<int> getTransactionCountByKategori(String namaKategori) async {
    return dompetDao.getTransactionCountByKategori(namaKategori);
  }

  Future<double> getComputedDompetSaldo(int idDompet) async {
    return transaksiDao.getComputedDompetSaldo(idDompet);
  }

  Future<void> syncDompetSaldo(int idDompet) async {
    await transaksiDao.syncDompetSaldo(idDompet);
  }

  // --- Kategori ---
  Future<List<Kategori>> getAllKategori() async {
    final db = await instance.database;
    final result = await db.query(TABLE_KATEGORI, orderBy: 'jenis, nama');
    return result.map((map) => Kategori.fromMap(map)).toList();
  }

  Future<List<Kategori>> getKategoriByJenis(String jenis) async {
    return kategoriDao.getKategoriByJenis(jenis);
  }

  Future<int> insertKategori(Kategori kategori) async {
    final db = await instance.database;
    return await db.insert(TABLE_KATEGORI, kategori.toMap());
  }

  Future<int> updateKategori(Kategori kategori) async {
    final db = await instance.database;
    return await db.update(
      TABLE_KATEGORI,
      kategori.toMap(),
      where: 'id = ?',
      whereArgs: [kategori.id],
    );
  }

  Future<int> deleteKategori(int id) async {
    final db = await instance.database;
    return await db.delete(TABLE_KATEGORI, where: 'id = ?', whereArgs: [id]);
  }

  // --- Budget ---
  Future<int> insertBudget(Budget budget) async {
    final db = await instance.database;
    return await db.insert(TABLE_BUDGET, budget.toMap());
  }

  Future<Budget?> getBudget(
    int bulan,
    int tahun,
    String kategori, {
    int? profilId,
  }) async {
    return budgetDao.getBudget(bulan, tahun, kategori, profilId: profilId);
  }

  Future<List<Budget>> getAllBudget(
    int bulan,
    int tahun, {
    int? profilId,
  }) async {
    return budgetDao.getAllBudget(bulan, tahun, profilId: profilId);
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await instance.database;
    return await db.update(
      TABLE_BUDGET,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // --- Pengaturan ---
  Future<Pengaturan> getPengaturan() async {
    return pengaturanDao.getPengaturan();
  }

  Future<int> updatePengaturan(Pengaturan pengaturan) async {
    return pengaturanDao.updatePengaturan(pengaturan);
  }

  // --- Profil ---
  Future<int> insertProfil(Profil profil) async {
    return profilDao.insertProfil(profil);
  }

  Future<List<Profil>> getAllProfil() async {
    return profilDao.getAllProfil();
  }

  Future<Profil?> getProfilById(int id) async {
    return profilDao.getProfilById(id);
  }

  Future<int> updateProfil(Profil profil) async {
    return profilDao.updateProfil(profil);
  }

  Future<int> deleteProfil(int id) async {
    return profilDao.deleteProfil(id);
  }

  // --- Utang Piutang ---
  Future<int> insertUtangPiutang(UtangPiutang data) async {
    final db = await instance.database;
    return await db.insert(TABLE_UTANG_PIUTANG, data.toMap());
  }

  Future<List<UtangPiutang>> getAllUtangPiutang() async {
    final db = await instance.database;
    final result = await db.query(
      TABLE_UTANG_PIUTANG,
      orderBy: 'is_lunas ASC, tanggal DESC',
    );
    return result.map((m) => UtangPiutang.fromMap(m)).toList();
  }

  Future<int> updateUtangPiutang(UtangPiutang data) async {
    final db = await instance.database;
    return await db.update(
      TABLE_UTANG_PIUTANG,
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  Future<int> deleteUtangPiutang(int id) async {
    final db = await instance.database;
    return await db.delete(
      TABLE_UTANG_PIUTANG,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertHistoryCicilan(HistoryCicilan cc) async {
    return utangPiutangDao.insertHistoryCicilan(cc);
  }

  Future<List<HistoryCicilan>> getHistoryCicilan(int idUtangPiutang) async {
    return utangPiutangDao.getHistoryCicilan(idUtangPiutang);
  }

  // --- Tabungan Impian ---
  Future<int> insertTabunganImpian(TabunganImpian data) async {
    final db = await instance.database;
    return await db.insert(TABLE_TABUNGAN_IMPIAN, data.toMap());
  }

  Future<List<TabunganImpian>> getAllTabunganImpian() async {
    final db = await instance.database;
    final result = await db.query(TABLE_TABUNGAN_IMPIAN);
    return result.map((m) => TabunganImpian.fromMap(m)).toList();
  }

  Future<int> updateTabunganImpian(TabunganImpian data) async {
    final db = await instance.database;
    return await db.update(
      TABLE_TABUNGAN_IMPIAN,
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  Future<int> deleteTabunganImpian(int id) async {
    final db = await instance.database;
    return await db.delete(
      TABLE_TABUNGAN_IMPIAN,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addProgressTabunganImpian(int id, double amount) async {
    await tabunganImpianDao.addProgressTabunganImpian(id, amount);
  }

  // -------------------------------------------------------------------------
  // ORCHESTRATING / CROSS-DAO METHODS
  // -------------------------------------------------------------------------

  /// Exports ALL app data (8 tables) to a JSON string.
  /// This is the unified export used by both backup_page and backup_service.
  Future<String> exportToJson() async {
    final db = await instance.database;
    final transaksi = await db.query(TABLE_TRANSAKSI);
    final dompet = await db.query(TABLE_DOMPET);
    final budget = await db.query(TABLE_BUDGET);
    final kategori = await db.query(TABLE_KATEGORI);
    final pengaturan = await db.query(TABLE_PENGATURAN);
    final utangPiutang = await db.query(TABLE_UTANG_PIUTANG);
    final historyCicilan = await db.query(TABLE_HISTORY_CICILAN);
    final tabunganImpian = await db.query(TABLE_TABUNGAN_IMPIAN);

    Map<String, dynamic> data = {
      'version': '2.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'tables': {
        'transaksi': transaksi,
        'dompet': dompet,
        'budget': budget,
        'kategori': kategori,
        'pengaturan': pengaturan,
        'utang_piutang': utangPiutang,
        'history_cicilan': historyCicilan,
        'tabungan_impian': tabunganImpian,
      },
      // Legacy keys for backward compatibility with old backups
      'transaksi': transaksi,
      'dompet': dompet,
      'budget': budget,
      'pengaturan': pengaturan,
    };

    return jsonEncode(data);
  }

  /// Restores app data from a JSON string.
  /// Supports both old format (flat keys) and new format (nested 'tables' key).
  Future<void> importFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final db = await instance.database;

    // Support both old format (flat keys) and new format (nested under 'tables')
    final tables = data.containsKey('tables')
        ? data['tables'] as Map<String, dynamic>
        : data;

    await db.transaction((txn) async {
      // Clear ALL tables in reverse dependency order
      await txn.delete(TABLE_HISTORY_CICILAN);
      await txn.delete(TABLE_UTANG_PIUTANG);
      await txn.delete(TABLE_TABUNGAN_IMPIAN);
      await txn.delete(TABLE_TRANSAKSI);
      await txn.delete(TABLE_BUDGET);
      await txn.delete(TABLE_KATEGORI);
      await txn.delete(TABLE_DOMPET);
      await txn.delete(TABLE_PENGATURAN);

      // Restore tables in dependency order
      // Helper to safely import a table (skip if key doesn't exist in backup)
      Future<void> importTable(String key, String tableName) async {
        if (tables.containsKey(key) && tables[key] != null) {
          for (var row in tables[key] as List) {
            await txn.insert(tableName, Map<String, dynamic>.from(row as Map));
          }
        }
      }

      await importTable('dompet', TABLE_DOMPET);
      await importTable('kategori', TABLE_KATEGORI);
      await importTable('pengaturan', TABLE_PENGATURAN);
      await importTable('budget', TABLE_BUDGET);
      await importTable('transaksi', TABLE_TRANSAKSI);
      await importTable('utang_piutang', TABLE_UTANG_PIUTANG);
      await importTable('history_cicilan', TABLE_HISTORY_CICILAN);
      await importTable('tabungan_impian', TABLE_TABUNGAN_IMPIAN);
    });

    // Re-sync all dompet saldo from imported transactions
    final dompets = await getAllDompet();
    for (var d in dompets) {
      if (d.id != null) {
        await syncDompetSaldo(d.id!);
      }
    }
  }
}
