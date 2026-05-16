import 'package:sqflite/sqflite.dart';
import '../../models/models.dart';
import '../../data/database.dart';

class UtangPiutangDao {
  final Database db;

  UtangPiutangDao(this.db);

  Future<int> insertUtangPiutang(UtangPiutang data) async {
    return await db.insert(TABLE_UTANG_PIUTANG, data.toMap());
  }

  Future<List<UtangPiutang>> getAllUtangPiutang() async {
    final result = await db.query(
      TABLE_UTANG_PIUTANG,
      orderBy: 'is_lunas ASC, tanggal DESC',
    );
    return result.map((m) => UtangPiutang.fromMap(m)).toList();
  }

  Future<int> updateUtangPiutang(UtangPiutang data) async {
    return await db.update(
      TABLE_UTANG_PIUTANG,
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  Future<int> deleteUtangPiutang(int id) async {
    return await db.delete(
      TABLE_UTANG_PIUTANG,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertHistoryCicilan(HistoryCicilan cc) async {
    return await db.transaction((txn) async {
      int id = await txn.insert(TABLE_HISTORY_CICILAN, cc.toMap());
      // Update saldo dibayar of main utang
      final List<Map<String, dynamic>> res = await txn.query(
        TABLE_UTANG_PIUTANG,
        where: 'id = ?',
        whereArgs: [cc.idUtangPiutang],
      );
      if (res.isNotEmpty) {
        final current = UtangPiutang.fromMap(res.first);
        final newDibayar = current.nominalDibayar + cc.nominal;
        final isLunas = newDibayar >= current.nominalTotal;
        await txn.update(
          TABLE_UTANG_PIUTANG,
          {'nominal_dibayar': newDibayar, 'is_lunas': isLunas ? 1 : 0},
          where: 'id = ?',
          whereArgs: [current.id],
        );
      }
      return id;
    });
  }

  Future<List<HistoryCicilan>> getHistoryCicilan(int idUtangPiutang) async {
    final res = await db.query(
      TABLE_HISTORY_CICILAN,
      where: 'id_utang_piutang = ?',
      whereArgs: [idUtangPiutang],
      orderBy: 'tanggal DESC',
    );
    return res.map((m) => HistoryCicilan.fromMap(m)).toList();
  }
}
