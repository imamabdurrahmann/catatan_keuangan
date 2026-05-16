import 'package:sqflite/sqflite.dart';
import '../../models/models.dart';
import '../../data/database.dart';

class KategoriDao {
  final Database db;

  KategoriDao(this.db);

  Future<List<Kategori>> getAllKategori() async {
    final result = await db.query(TABLE_KATEGORI, orderBy: 'jenis, nama');
    return result.map((map) => Kategori.fromMap(map)).toList();
  }

  Future<List<Kategori>> getKategoriByJenis(String jenis) async {
    final result = await db.query(
      TABLE_KATEGORI,
      where: 'jenis = ?',
      whereArgs: [jenis],
      orderBy: 'nama',
    );
    return result.map((map) => Kategori.fromMap(map)).toList();
  }

  Future<int> insertKategori(Kategori kategori) async {
    return await db.insert(TABLE_KATEGORI, kategori.toMap());
  }

  Future<int> updateKategori(Kategori kategori) async {
    return await db.update(
      TABLE_KATEGORI,
      kategori.toMap(),
      where: 'id = ?',
      whereArgs: [kategori.id],
    );
  }

  Future<int> deleteKategori(int id) async {
    return await db.delete(TABLE_KATEGORI, where: 'id = ?', whereArgs: [id]);
  }
}
