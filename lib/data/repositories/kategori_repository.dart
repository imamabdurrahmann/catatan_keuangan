import '../../models/models.dart';
import 'base_repository.dart';

/// Repository for kategori (category) data in Supabase.
class KategoriRepository with SupabaseRepositoryMixin {
  @override
  String get tableName => 'kategori';

  /// Get all categories: global defaults + user-created.
  Future<List<Kategori>> getAllKategori() async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .or('user_id.is.null,user_id.eq.$currentUserId');
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToKategori)
        .toList();
  }

  /// Get categories by jenis (pengeluaran/pemasukan).
  Future<List<Kategori>> getKategoriByJenis(String jenis) async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .or('user_id.is.null,user_id.eq.$currentUserId')
        .eq('jenis', jenis);
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToKategori)
        .toList();
  }

  /// Insert a user-owned category.
  Future<int> insertKategori(Kategori kategori) async {
    final map = {
      'nama': kategori.nama,
      'jenis': kategori.jenis,
      'icon': kategori.icon,
      'is_default': kategori.isDefault,
    };
    final result = await insertRow(map);
    return result['id'] as int;
  }

  /// Update a user-owned category.
  Future<void> updateKategori(Kategori kategori) async {
    if (kategori.id == null) return;
    await updateRow(kategori.id!, {
      'nama': kategori.nama,
      'jenis': kategori.jenis,
      'icon': kategori.icon,
      'is_default': kategori.isDefault,
    });
  }

  /// Delete a user-owned category.
  Future<void> deleteKategori(int id) async {
    await deleteRow(id);
  }

  Kategori _mapToKategori(Map<String, dynamic> map) {
    return Kategori(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      jenis: map['jenis'] as String,
      icon: map['icon'] as String? ?? 'category',
      isDefault: map['is_default'] == true,
    );
  }
}
