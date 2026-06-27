import '../../models/models.dart';
import 'base_repository.dart';

/// Repository for profil data in Supabase.
class ProfilRepository with SupabaseRepositoryMixin {
  @override
  String get tableName => 'profil';

  /// Get all profiles for current user.
  Future<List<Profil>> getAll() async {
    final data = await selectAll(orderBy: 'id', ascending: true);
    return data.map(_mapToProfil).toList();
  }

  /// Get a single profile by ID.
  Future<Profil?> getById(int id) async {
    final map = await selectById(id);
    return map != null ? _mapToProfil(map) : null;
  }

  /// Insert a new profile.
  Future<int> insert(Profil profil) async {
    final result = await insertRow({
      'nama': profil.nama,
      'icon': profil.icon,
      'created_at': profil.createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
    return result['id'] as int;
  }

  /// Update a profile.
  Future<void> update(Profil profil) async {
    if (profil.id == null) return;
    await updateRow(profil.id!, {
      'nama': profil.nama,
      'icon': profil.icon,
    });
  }

  /// Delete a profile.
  Future<void> delete(int id) async {
    await deleteRow(id);
  }

  Profil _mapToProfil(Map<String, dynamic> map) {
    return Profil(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      icon: map['icon'] as String? ?? 'person',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
}
