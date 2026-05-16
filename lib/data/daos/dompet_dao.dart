import 'package:sqflite/sqflite.dart';
import '../../models/models.dart';
import '../../data/database.dart';

class DompetDao {
  final Database db;

  DompetDao(this.db);

  Future<int> insertDompet(Dompet dompet) async {
    return await db.insert(TABLE_DOMPET, dompet.toMap());
  }

  Future<List<Dompet>> getAllDompet({int? profilId}) async {
    final result = profilId != null
        ? await db.query(
            TABLE_DOMPET,
            where: 'profil_id = ?',
            whereArgs: [profilId],
          )
        : await db.query(TABLE_DOMPET);
    return result.map((map) => Dompet.fromMap(map)).toList();
  }

  Future<Dompet?> getDompetById(int id) async {
    final result = await db.query(
      TABLE_DOMPET,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Dompet.fromMap(result.first);
  }

  Future<List<Dompet>> getDompetByProfil(int profilId) async {
    final result = await db.query(
      TABLE_DOMPET,
      where: 'profil_id = ?',
      whereArgs: [profilId],
    );
    return result.map((map) => Dompet.fromMap(map)).toList();
  }

  Future<int> updateDompet(Dompet dompet) async {
    return await db.update(
      TABLE_DOMPET,
      dompet.toMap(),
      where: 'id = ?',
      whereArgs: [dompet.id],
    );
  }

  Future<int> deleteDompet(int id) async {
    return await db.delete(TABLE_DOMPET, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTransactionCountByDompet(int idDompet) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transaksi WHERE id_dompet = ? AND deleted_at IS NULL',
      [idDompet],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getTransactionCountByKategori(String namaKategori) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transaksi WHERE kategori = ? AND deleted_at IS NULL',
      [namaKategori],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
