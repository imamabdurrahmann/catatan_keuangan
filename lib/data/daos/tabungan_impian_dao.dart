import 'package:sqflite/sqflite.dart';
import '../../models/models.dart';
import '../../data/database.dart';

class TabunganImpianDao {
  final Database db;

  TabunganImpianDao(this.db);

  Future<int> insertTabunganImpian(TabunganImpian data) async {
    return await db.insert(TABLE_TABUNGAN_IMPIAN, data.toMap());
  }

  Future<List<TabunganImpian>> getAllTabunganImpian() async {
    final result = await db.query(TABLE_TABUNGAN_IMPIAN);
    return result.map((m) => TabunganImpian.fromMap(m)).toList();
  }

  Future<int> updateTabunganImpian(TabunganImpian data) async {
    return await db.update(
      TABLE_TABUNGAN_IMPIAN,
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  Future<int> deleteTabunganImpian(int id) async {
    return await db.delete(
      TABLE_TABUNGAN_IMPIAN,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addProgressTabunganImpian(int id, double amount) async {
    final res = await db.query(
      TABLE_TABUNGAN_IMPIAN,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) {
      final current = TabunganImpian.fromMap(res.first);
      final newTerkumpul = current.terkumpul + amount;
      await db.update(
        TABLE_TABUNGAN_IMPIAN,
        {'terkumpul': newTerkumpul},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> markTabunganComplete(int id) async {
    await db.update(
      TABLE_TABUNGAN_IMPIAN,
      {'terkumpul': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
