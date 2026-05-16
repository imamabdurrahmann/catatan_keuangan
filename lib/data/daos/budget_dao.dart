import 'package:sqflite/sqflite.dart';
import '../../models/models.dart';
import '../../data/database.dart';

class BudgetDao {
  final Database db;

  BudgetDao(this.db);

  Future<int> insertBudget(Budget budget) async {
    return await db.insert(TABLE_BUDGET, budget.toMap());
  }

  Future<Budget?> getBudget(
    int bulan,
    int tahun,
    String kategori, {
    int? profilId,
  }) async {
    final where = profilId != null
        ? 'bulan = ? AND tahun = ? AND kategori = ? AND profil_id = ?'
        : 'bulan = ? AND tahun = ? AND kategori = ?';
    final whereArgs = profilId != null
        ? [bulan, tahun, kategori, profilId]
        : [bulan, tahun, kategori];
    final result = await db.query(
      TABLE_BUDGET,
      where: where,
      whereArgs: whereArgs,
    );
    if (result.isEmpty) return null;
    return Budget.fromMap(result.first);
  }

  Future<List<Budget>> getAllBudget(
    int bulan,
    int tahun, {
    int? profilId,
  }) async {
    final where = profilId != null
        ? 'bulan = ? AND tahun = ? AND profil_id = ?'
        : 'bulan = ? AND tahun = ?';
    final whereArgs = profilId != null
        ? [bulan, tahun, profilId]
        : [bulan, tahun];
    final result = await db.query(
      TABLE_BUDGET,
      where: where,
      whereArgs: whereArgs,
    );
    return result.map((map) => Budget.fromMap(map)).toList();
  }

  Future<int> updateBudget(Budget budget) async {
    return await db.update(
      TABLE_BUDGET,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Calculates remaining budget from previous month for a given category.
  /// Returns the amount left over (budget + rollover - spent).
  /// Returns 0 if no previous month budget exists.
  Future<double> calculateRemainingBudget(
    int bulan,
    int tahun,
    String kategori, {
    int? profilId,
  }) async {
    // Calculate previous month
    int prevBulan = bulan - 1;
    int prevTahun = tahun;
    if (prevBulan < 1) {
      prevBulan = 12;
      prevTahun -= 1;
    }

    final prevBudget = await getBudget(
      prevBulan,
      prevTahun,
      kategori,
      profilId: profilId,
    );
    if (prevBudget == null) return 0;

    // Get spending for previous month category
    final startDate = DateTime(prevTahun, prevBulan, 1);
    final endDate = DateTime(prevTahun, prevBulan + 1, 0, 23, 59, 59);

    final where = profilId != null
        ? "kategori = ? AND jenis = 'pengeluaran' AND tanggal >= ? AND tanggal <= ? AND deleted_at IS NULL"
        : "kategori = ? AND jenis = 'pengeluaran' AND tanggal >= ? AND tanggal <= ? AND deleted_at IS NULL";

    final whereArgs = profilId != null
        ? [kategori, startDate.toIso8601String(), endDate.toIso8601String()]
        : [kategori, startDate.toIso8601String(), endDate.toIso8601String()];

    final result = await db.rawQuery(
      'SELECT SUM(jumlah) as total FROM transaksi WHERE $where',
      whereArgs,
    );

    final spent = (result.first['total'] as num?)?.toDouble() ?? 0;
    final effectiveBudget = prevBudget.nominal + prevBudget.sisaRollover;
    final remaining = effectiveBudget - spent;

    return remaining > 0 ? remaining : 0;
  }

  /// Gets or creates a budget for the current month with rollover from previous month.
  /// If a budget exists for previous month with remaining balance, it is carried over.
  Future<Budget?> getOrCreateBudgetWithRollover(
    int bulan,
    int tahun,
    String kategori, {
    int? profilId,
  }) async {
    // Check if budget already exists for current month
    var budget = await getBudget(bulan, tahun, kategori, profilId: profilId);

    if (budget != null) {
      // If budget exists but has no rollover yet, check and add rollover
      if (budget.sisaRollover == 0) {
        final rolloverAmount = await calculateRemainingBudget(
          bulan,
          tahun,
          kategori,
          profilId: profilId,
        );
        if (rolloverAmount > 0) {
          budget = budget.copyWith(sisaRollover: rolloverAmount);
          await updateBudget(budget);
        }
      }
      return budget;
    }

    // Calculate rollover from previous month
    final rolloverAmount = await calculateRemainingBudget(
      bulan,
      tahun,
      kategori,
      profilId: profilId,
    );

    // Create new budget with rollover if any
    final newBudget = Budget(
      bulan: bulan,
      tahun: tahun,
      nominal: 0,
      kategori: kategori,
      profilId: profilId ?? 1,
      sisaRollover: rolloverAmount,
    );

    await insertBudget(newBudget);
    return newBudget;
  }
}
