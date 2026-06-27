import '../../models/models.dart';
import 'base_repository.dart';

/// Repository for tabungan_impian (dream savings) data in Supabase.
class TabunganImpianRepository with SupabaseRepositoryMixin {
  @override
  String get tableName => 'tabungan_impian';

  /// Get all dream savings.
  Future<List<TabunganImpian>> getAll() async {
    final data = await selectAll(orderBy: 'id', ascending: true);
    return data.map(_mapToTabunganImpian).toList();
  }

  /// Get a single dream saving by ID.
  Future<TabunganImpian?> getById(int id) async {
    final map = await selectById(id);
    return map != null ? _mapToTabunganImpian(map) : null;
  }

  /// Insert a new dream saving.
  Future<int> insert(TabunganImpian item) async {
    final result = await insertRow({
      'nama_impian': item.namaImpian,
      'target_nominal': item.targetNominal,
      'terkumpul': item.terkumpul,
      'target_tanggal': item.targetTanggal?.toIso8601String(),
      'icon': item.icon,
    });
    return result['id'] as int;
  }

  /// Update a dream saving.
  Future<void> update(TabunganImpian item) async {
    if (item.id == null) return;
    await updateRow(item.id!, {
      'nama_impian': item.namaImpian,
      'target_nominal': item.targetNominal,
      'terkumpul': item.terkumpul,
      'target_tanggal': item.targetTanggal?.toIso8601String(),
      'icon': item.icon,
    });
  }

  /// Add amount to terkumpul.
  Future<void> addAmount(int id, double amount) async {
    final current = await getById(id);
    if (current == null) return;
    final newAmount = current.terkumpul + amount;
    await supabaseClient
        .from(tableName)
        .update({'terkumpul': newAmount})
        .eq('id', id)
        .eq('user_id', currentUserId);
  }

  /// Delete a dream saving.
  Future<void> delete(int id) async {
    await deleteRow(id);
  }

  TabunganImpian _mapToTabunganImpian(Map<String, dynamic> map) {
    return TabunganImpian(
      id: map['id'] as int?,
      namaImpian: map['nama_impian'] as String,
      targetNominal: (map['target_nominal'] as num).toDouble(),
      terkumpul: (map['terkumpul'] as num).toDouble(),
      targetTanggal: map['target_tanggal'] != null
          ? DateTime.parse(map['target_tanggal'] as String)
          : null,
      icon: map['icon'] as String? ?? 'savings',
    );
  }
}
