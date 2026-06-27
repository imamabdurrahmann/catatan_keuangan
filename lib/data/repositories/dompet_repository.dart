import '../../models/models.dart';
import 'base_repository.dart';

/// Repository for dompet (wallet) data in Supabase.
class DompetRepository with SupabaseRepositoryMixin {
  @override
  String get tableName => 'dompet';

  /// Get all wallets for current user.
  Future<List<Dompet>> getAllDompet({int? profilId}) async {
    var query = supabaseClient.from(tableName).select().eq('user_id', currentUserId);
    if (profilId != null) {
      query = query.eq('profil_id', profilId);
    }
    final data = await query;
    return List<Map<String, dynamic>>.from(data)
        .map((m) => Dompet.fromMap(m))
        .toList();
  }

  /// Get a single wallet by ID.
  Future<Dompet?> getDompetById(int id) async {
    final map = await selectById(id);
    return map != null ? Dompet.fromMap(map) : null;
  }

  /// Get wallets by profil ID.
  Future<List<Dompet>> getDompetByProfil(int profilId) async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .eq('profil_id', profilId);
    return List<Map<String, dynamic>>.from(data)
        .map((m) => Dompet.fromMap(m))
        .toList();
  }

  /// Insert a new wallet. Returns server-generated ID.
  Future<int> insertDompet(Dompet dompet) async {
    final map = {
      'nama': dompet.nama,
      'saldo': dompet.saldo,
      'warna': dompet.warna,
      'currency': dompet.currency,
      'profil_id': dompet.profilId,
    };
    final result = await insertRow(map);
    return result['id'] as int;
  }

  /// Update a wallet.
  Future<void> updateDompet(Dompet dompet) async {
    if (dompet.id == null) return;
    final map = {
      'nama': dompet.nama,
      'saldo': dompet.saldo,
      'warna': dompet.warna,
      'currency': dompet.currency,
      'profil_id': dompet.profilId,
    };
    await updateRow(dompet.id!, map);
  }

  /// Update wallet balance.
  Future<void> updateSaldo(int id, double saldo) async {
    await supabaseClient
        .from(tableName)
        .update({'saldo': saldo})
        .eq('id', id)
        .eq('user_id', currentUserId);
  }

  /// Delete a wallet.
  Future<void> deleteDompet(int id) async {
    await deleteRow(id);
  }
}
