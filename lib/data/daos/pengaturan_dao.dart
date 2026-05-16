import 'package:sqflite/sqflite.dart';
import '../../models/models.dart';
import '../../data/database.dart';

class PengaturanDao {
  final Database db;

  PengaturanDao(this.db);

  Future<Pengaturan> getPengaturan() async {
    final result = await db.query(
      TABLE_PENGATURAN,
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isEmpty) {
      return Pengaturan(id: 1, isDarkMode: false);
    }
    return Pengaturan.fromMap(result.first);
  }

  Future<int> updatePengaturan(Pengaturan pengaturan) async {
    return await db.update(
      TABLE_PENGATURAN,
      pengaturan.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
