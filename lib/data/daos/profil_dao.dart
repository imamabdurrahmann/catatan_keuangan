import 'package:sqflite/sqflite.dart';
import '../../models/models.dart';
import '../../data/database.dart';

class ProfilDao {
  final Database db;

  ProfilDao(this.db);

  Future<int> insertProfil(Profil profil) async {
    return await db.insert(TABLE_PROFIL, profil.toMap());
  }

  Future<List<Profil>> getAllProfil() async {
    final result = await db.query(TABLE_PROFIL, orderBy: 'id ASC');
    return result.map((map) => Profil.fromMap(map)).toList();
  }

  Future<Profil?> getProfilById(int id) async {
    final result = await db.query(
      TABLE_PROFIL,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Profil.fromMap(result.first);
  }

  Future<int> updateProfil(Profil profil) async {
    return await db.update(
      TABLE_PROFIL,
      profil.toMap(),
      where: 'id = ?',
      whereArgs: [profil.id],
    );
  }

  Future<int> deleteProfil(int id) async {
    // Prevent deleting the last profil
    final all = await getAllProfil();
    if (all.length <= 1) return 0;
    return await db.delete(TABLE_PROFIL, where: 'id = ?', whereArgs: [id]);
  }
}
