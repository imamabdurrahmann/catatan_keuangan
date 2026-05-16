import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../data/database.dart';

class TransaksiDao {
  final Database db;

  TransaksiDao(this.db);

  Future<int> insertTransaksi(Transaksi transaksi) async {
    return await db.transaction((txn) async {
      int id = await txn.insert(TABLE_TRANSAKSI, transaksi.toMap());
      if (transaksi.idDompet != null) {
        await _syncDompetSaldoTxn(txn, transaksi.idDompet!);
      }
      return id;
    });
  }

  Future<List<Transaksi>> getAllTransaksi() async {
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: 'deleted_at IS NULL',
      orderBy: 'tanggal DESC',
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<List<Transaksi>> getTransaksiByDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final nextDateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(date.add(const Duration(days: 1)));
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: 'tanggal >= ? AND tanggal < ? AND deleted_at IS NULL',
      whereArgs: ['$dateStr 00:00:00', '$nextDateStr 00:00:00'],
      orderBy: 'id DESC',
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<List<Transaksi>> getTransaksiByMonth(
    int year,
    int month, {
    int? idDompet,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    String where = 'tanggal >= ? AND tanggal < ? AND deleted_at IS NULL';
    List<dynamic> whereArgs = [
      '${DateFormat('yyyy-MM-dd').format(startDate)} 00:00:00',
      '${DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)))} 00:00:00',
    ];

    if (idDompet != null) {
      where += ' AND id_dompet = ?';
      whereArgs.add(idDompet);
    }

    final result = await db.query(
      TABLE_TRANSAKSI,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'tanggal DESC',
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<List<Transaksi>> searchTransaksi(String query) async {
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: '(deskripsi LIKE ? OR kategori LIKE ?) AND deleted_at IS NULL',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'tanggal DESC',
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  /// Advanced search with multiple filter options.
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
    final conditions = <String>['deleted_at IS NULL'];
    final args = <dynamic>[];

    if (query != null && query.isNotEmpty) {
      conditions.add('(deskripsi LIKE ? OR kategori LIKE ?)');
      args.add('%$query%');
      args.add('%$query%');
    }

    if (jenis != null && jenis.isNotEmpty && jenis != 'semua') {
      conditions.add('jenis = ?');
      args.add(jenis);
    }

    if (dariTanggal != null) {
      conditions.add('tanggal >= ?');
      args.add('${DateFormat('yyyy-MM-dd').format(dariTanggal)} 00:00:00');
    }

    if (sampaiTanggal != null) {
      conditions.add('tanggal < ?');
      args.add(
        '${DateFormat('yyyy-MM-dd').format(sampaiTanggal.add(const Duration(days: 1)))} 00:00:00',
      );
    }

    if (jumlahMin != null && jumlahMin > 0) {
      conditions.add('jumlah >= ?');
      args.add(jumlahMin);
    }

    if (jumlahMax != null && jumlahMax > 0) {
      conditions.add('jumlah <= ?');
      args.add(jumlahMax);
    }

    final where = conditions.join(' AND ');
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: where,
      whereArgs: args,
      orderBy: orderBy,
      limit: limit,
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<List<String>> getUniqueDates() async {
    final result = await db.rawQuery(
      'SELECT DISTINCT substr(tanggal, 1, 10) as tanggal FROM transaksi WHERE deleted_at IS NULL ORDER BY tanggal DESC',
    );
    return result.map((map) => map['tanggal'] as String).toList();
  }

  Future<int> deleteTransaksi(int id) async {
    return await db.transaction((txn) async {
      final oldRes = await txn.query(
        TABLE_TRANSAKSI,
        columns: ['id_dompet'],
        where: 'id = ?',
        whereArgs: [id],
      );
      int? idDompet = oldRes.isNotEmpty
          ? oldRes.first['id_dompet'] as int?
          : null;

      int rows = await txn.delete(
        TABLE_TRANSAKSI,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (idDompet != null) {
        await _syncDompetSaldoTxn(txn, idDompet);
      }
      return rows;
    });
  }

  Future<int> softDeleteTransaksi(int id) async {
    return await db.transaction((txn) async {
      final oldRes = await txn.query(
        TABLE_TRANSAKSI,
        columns: ['id_dompet'],
        where: 'id = ?',
        whereArgs: [id],
      );
      int? idDompet = oldRes.isNotEmpty
          ? oldRes.first['id_dompet'] as int?
          : null;

      final now = DateTime.now();
      final deletedAt =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      int rows = await txn.update(
        TABLE_TRANSAKSI,
        {'deleted_at': deletedAt},
        where: 'id = ?',
        whereArgs: [id],
      );

      if (idDompet != null) {
        await _syncDompetSaldoTxn(txn, idDompet);
      }
      return rows;
    });
  }

  Future<List<Transaksi>> getDeletedTransaksi() async {
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<int> restoreTransaksi(int id) async {
    return await db.transaction((txn) async {
      int rows = await txn.update(
        TABLE_TRANSAKSI,
        {'deleted_at': null},
        where: 'id = ?',
        whereArgs: [id],
      );

      final res = await txn.query(
        TABLE_TRANSAKSI,
        columns: ['id_dompet'],
        where: 'id = ?',
        whereArgs: [id],
      );
      if (res.isNotEmpty) {
        int? idDompet = res.first['id_dompet'] as int?;
        if (idDompet != null) {
          await _syncDompetSaldoTxn(txn, idDompet);
        }
      }
      return rows;
    });
  }

  Future<int> permanentDeleteTransaksi(int id) async {
    return await db.transaction((txn) async {
      final oldRes = await txn.query(
        TABLE_TRANSAKSI,
        columns: ['id_dompet'],
        where: 'id = ?',
        whereArgs: [id],
      );
      int? idDompet = oldRes.isNotEmpty
          ? oldRes.first['id_dompet'] as int?
          : null;

      int rows = await txn.delete(
        TABLE_TRANSAKSI,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (idDompet != null) {
        await _syncDompetSaldoTxn(txn, idDompet);
      }
      return rows;
    });
  }

  Future<int> updateTransaksi(Transaksi transaksi) async {
    return await db.transaction((txn) async {
      final oldRes = await txn.query(
        TABLE_TRANSAKSI,
        columns: ['id_dompet'],
        where: 'id = ?',
        whereArgs: [transaksi.id],
      );
      int? oldDompet = oldRes.isNotEmpty
          ? oldRes.first['id_dompet'] as int?
          : null;

      int rows = await txn.update(
        TABLE_TRANSAKSI,
        transaksi.toMap(),
        where: 'id = ?',
        whereArgs: [transaksi.id],
      );

      if (transaksi.idDompet != null) {
        await _syncDompetSaldoTxn(txn, transaksi.idDompet!);
      }
      if (oldDompet != null && oldDompet != transaksi.idDompet) {
        await _syncDompetSaldoTxn(txn, oldDompet);
      }
      return rows;
    });
  }

  Future<Map<String, double>> getMonthlySummary(
    int year,
    int month, {
    int? idDompet,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    // 1. Calculate Pemasukan and Pengeluaran for the CURRENT month
    String whereMonthly = 'tanggal >= ? AND tanggal < ? AND deleted_at IS NULL';
    List<dynamic> whereArgsMonthly = [
      '${DateFormat('yyyy-MM-dd').format(startDate)} 00:00:00',
      '${DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)))} 00:00:00',
    ];

    if (idDompet != null) {
      whereMonthly += ' AND id_dompet = ?';
      whereArgsMonthly.add(idDompet);
    }

    final resultMonthly = await db.rawQuery(
      'SELECT jenis, SUM(jumlah) as total FROM transaksi WHERE $whereMonthly GROUP BY jenis',
      whereArgsMonthly,
    );

    double totalPemasukan = 0;
    double totalPengeluaran = 0;
    for (var row in resultMonthly) {
      final jenis = row['jenis'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (jenis == 'pemasukan') {
        totalPemasukan = total;
      } else {
        totalPengeluaran = total;
      }
    }

    // 2. Calculate Saldo CUMULATIVE up to the end of the current month
    String whereCumulative = 'tanggal < ? AND deleted_at IS NULL';
    List<dynamic> whereArgsCumulative = [
      '${DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)))} 00:00:00',
    ];

    if (idDompet != null) {
      whereCumulative += ' AND id_dompet = ?';
      whereArgsCumulative.add(idDompet);
    }

    final resultCumulative = await db.rawQuery(
      'SELECT jenis, SUM(jumlah) as total FROM transaksi WHERE $whereCumulative GROUP BY jenis',
      whereArgsCumulative,
    );

    double cumulativePemasukan = 0;
    double cumulativePengeluaran = 0;
    for (var row in resultCumulative) {
      final jenis = row['jenis'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (jenis == 'pemasukan') {
        cumulativePemasukan = total;
      } else {
        cumulativePengeluaran = total;
      }
    }

    return {
      'pemasukan': totalPemasukan,
      'pengeluaran': totalPengeluaran,
      'saldo': cumulativePemasukan - cumulativePengeluaran,
    };
  }

  Future<Map<String, double>> getCategorySummary(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final result = await db.rawQuery(
      '''
      SELECT kategori, SUM(jumlah) as total
      FROM transaksi
      WHERE jenis = 'pengeluaran' AND tanggal >= ? AND tanggal < ? AND deleted_at IS NULL
      GROUP BY kategori
      ''',
      [
        '${DateFormat('yyyy-MM-dd').format(startDate)} 00:00:00',
        '${DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)))} 00:00:00',
      ],
    );

    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['kategori'] as String] = (row['total'] as num)
          .toDouble();
    }
    return categoryTotals;
  }

  Future<List<Transaksi>> getRecurringTransaksi() async {
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: 'is_recurring = 1 AND deleted_at IS NULL',
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  /// Computes the computed saldo for a dompet by summing transaksi.
  /// This does NOT update the dompet table.
  Future<double> getComputedDompetSaldo(int idDompet) async {
    final result = await db.rawQuery(
      'SELECT jenis, SUM(jumlah) as total FROM transaksi WHERE id_dompet = ? AND deleted_at IS NULL GROUP BY jenis',
      [idDompet],
    );
    double saldo = 0;
    for (var row in result) {
      final jenis = row['jenis'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (jenis == 'pemasukan') {
        saldo += total;
      } else {
        saldo -= total;
      }
    }
    return saldo;
  }

  /// Syncs the stored saldo in the dompet table to match computed transaksi sum.
  Future<void> syncDompetSaldo(int idDompet) async {
    final saldo = await getComputedDompetSaldo(idDompet);
    await db.update(
      TABLE_DOMPET,
      {'saldo': saldo},
      where: 'id = ?',
      whereArgs: [idDompet],
    );
  }

  // --- Transaction-scoped helpers for atomic updates ---
  Future<double> _getComputedDompetSaldoTxn(
    Transaction txn,
    int idDompet,
  ) async {
    final result = await txn.rawQuery(
      'SELECT jenis, SUM(jumlah) as total FROM transaksi WHERE id_dompet = ? AND deleted_at IS NULL GROUP BY jenis',
      [idDompet],
    );
    double saldo = 0;
    for (var row in result) {
      final jenis = row['jenis'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (jenis == 'pemasukan') {
        saldo += total;
      } else {
        saldo -= total;
      }
    }
    return saldo;
  }

  Future<void> _syncDompetSaldoTxn(Transaction txn, int idDompet) async {
    final saldo = await _getComputedDompetSaldoTxn(txn, idDompet);
    await txn.update(
      TABLE_DOMPET,
      {'saldo': saldo},
      where: 'id = ?',
      whereArgs: [idDompet],
    );
  }

  // ==================== PAGINATION ====================

  /// Get all transactions with pagination support.
  Future<List<Transaksi>> getTransaksiPaginated({
    int? limit,
    int? offset,
  }) async {
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: 'deleted_at IS NULL',
      orderBy: 'tanggal DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  /// Get transactions for a specific date with pagination support.
  Future<List<Transaksi>> getTransaksiByDatePaginated(
    DateTime date, {
    int? limit,
    int? offset,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final nextDateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(date.add(const Duration(days: 1)));
    final result = await db.query(
      TABLE_TRANSAKSI,
      where: 'tanggal >= ? AND tanggal < ? AND deleted_at IS NULL',
      whereArgs: ['$dateStr 00:00:00', '$nextDateStr 00:00:00'],
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  /// Get transactions for a specific month with pagination support.
  Future<List<Transaksi>> getTransaksiByMonthPaginated(
    int year,
    int month, {
    int? idDompet,
    int? limit,
    int? offset,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    String where = 'tanggal >= ? AND tanggal < ? AND deleted_at IS NULL';
    List<dynamic> whereArgs = [
      '${DateFormat('yyyy-MM-dd').format(startDate)} 00:00:00',
      '${DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)))} 00:00:00',
    ];

    if (idDompet != null) {
      where += ' AND id_dompet = ?';
      whereArgs.add(idDompet);
    }

    final result = await db.query(
      TABLE_TRANSAKSI,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'tanggal DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  /// Get total count of non-deleted transactions.
  Future<int> getTotalTransaksiCount() async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $TABLE_TRANSAKSI WHERE deleted_at IS NULL',
    );
    return result.first['count'] as int;
  }

  /// Get count of non-deleted transactions for a specific date.
  Future<int> getTransaksiCountByDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final nextDateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(date.add(const Duration(days: 1)));
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $TABLE_TRANSAKSI WHERE deleted_at IS NULL AND tanggal >= ? AND tanggal < ?',
      ['$dateStr 00:00:00', '$nextDateStr 00:00:00'],
    );
    return result.first['count'] as int;
  }

  /// Get count of non-deleted transactions, optionally filtered by year/month and dompet.
  Future<int> getTransaksiCount({int? tahun, int? bulan, int? idDompet}) async {
    if (tahun != null && bulan != null) {
      final startDate = DateTime(tahun, bulan, 1);
      final endDate = DateTime(tahun, bulan + 1, 0);
      String where = 'deleted_at IS NULL AND tanggal >= ? AND tanggal < ?';
      List<dynamic> whereArgs = [
        '${DateFormat('yyyy-MM-dd').format(startDate)} 00:00:00',
        '${DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)))} 00:00:00',
      ];
      if (idDompet != null) {
        where += ' AND id_dompet = ?';
        whereArgs.add(idDompet);
      }
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $TABLE_TRANSAKSI WHERE $where',
        whereArgs,
      );
      return result.first['count'] as int;
    }
    return getTotalTransaksiCount();
  }

  /// Returns the average daily expense for a given month.
  ///
  /// Algorithm:
  ///   1. Sum all 'pengeluaran' transactions from day 1 to today (inclusive).
  ///   2. Divide by the number of days that have already passed this month.
  ///
  /// If no spending data exists, returns 0.
  Future<double> getAverageDailyExpense(int year, int month) async {
    final now = DateTime.now();
    final isCurrentMonth = (now.year == year) && (now.month == month);

    // Determine the "up-to" date for the calculation window.
    final DateTime windowEnd;
    if (isCurrentMonth) {
      // Only count days that have elapsed — today is included.
      windowEnd = DateTime(now.year, now.month, now.day + 1);
    } else {
      // For past months, count the entire month.
      windowEnd = DateTime(year, month + 1, 1);
    }
    final windowStart = DateTime(year, month, 1);

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(jumlah), 0) as total
      FROM transaksi
      WHERE jenis = 'pengeluaran'
        AND tanggal >= ?
        AND tanggal < ?
        AND deleted_at IS NULL
      ''',
      [
        '${DateFormat('yyyy-MM-dd').format(windowStart)} 00:00:00',
        '${DateFormat('yyyy-MM-dd').format(windowEnd)} 00:00:00',
      ],
    );

    final totalPengeluaran = (result.first['total'] as num?)?.toDouble() ?? 0;

    // Number of days elapsed in the window.
    final int elapsedDays;
    if (isCurrentMonth) {
      elapsedDays = now.day; // today counts as a full day of data
    } else {
      elapsedDays = DateTime(year, month + 1, 0).day; // total days in the month
    }

    if (elapsedDays <= 0 || totalPengeluaran <= 0) return 0;

    return totalPengeluaran / elapsedDays;
  }
}
