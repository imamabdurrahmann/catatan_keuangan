import '../../models/models.dart';
import 'base_repository.dart';

/// Repository for utang_piutang and history_cicilan data in Supabase.
class UtangPiutangRepository with SupabaseRepositoryMixin {
  @override
  String get tableName => 'utang_piutang';

  /// Get all utang/piutang entries.
  Future<List<UtangPiutang>> getAll() async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .order('tanggal', ascending: false);
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToUtangPiutang)
        .toList();
  }

  /// Get by jenis ('utang' or 'piutang').
  Future<List<UtangPiutang>> getByJenis(String jenis) async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .eq('jenis', jenis)
        .order('tanggal', ascending: false);
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToUtangPiutang)
        .toList();
  }

  /// Insert new utang/piutang entry.
  Future<int> insert(UtangPiutang item) async {
    final result = await insertRow({
      'nama_orang': item.namaOrang,
      'jenis': item.jenis,
      'nominal_total': item.nominalTotal,
      'nominal_dibayar': item.nominalDibayar,
      'tanggal': item.tanggal.toIso8601String(),
      'tenggat_waktu': item.tenggatWaktu?.toIso8601String(),
      'deskripsi': item.deskripsi,
      'is_lunas': item.isLunas,
    });
    return result['id'] as int;
  }

  /// Update utang/piutang entry.
  Future<void> update(UtangPiutang item) async {
    if (item.id == null) return;
    await updateRow(item.id!, {
      'nama_orang': item.namaOrang,
      'jenis': item.jenis,
      'nominal_total': item.nominalTotal,
      'nominal_dibayar': item.nominalDibayar,
      'tanggal': item.tanggal.toIso8601String(),
      'tenggat_waktu': item.tenggatWaktu?.toIso8601String(),
      'deskripsi': item.deskripsi,
      'is_lunas': item.isLunas,
    });
  }

  /// Delete utang/piutang entry.
  Future<void> delete(int id) async {
    await deleteRow(id);
  }

  // ---------------------------------------------------------------------------
  // History Cicilan
  // ---------------------------------------------------------------------------

  /// Get cicilan history for a specific utang/piutang.
  Future<List<HistoryCicilan>> getHistoryCicilan(int idUtangPiutang) async {
    final data = await supabaseClient
        .from('history_cicilan')
        .select()
        .eq('user_id', currentUserId)
        .eq('id_utang_piutang', idUtangPiutang)
        .order('tanggal', ascending: false);
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToHistoryCicilan)
        .toList();
  }

  /// Insert a cicilan payment.
  Future<int> insertCicilan(HistoryCicilan cicilan) async {
    final result = await supabaseClient
        .from('history_cicilan')
        .insert({
          'id_utang_piutang': cicilan.idUtangPiutang,
          'nominal': cicilan.nominal,
          'tanggal': cicilan.tanggal.toIso8601String(),
          'user_id': currentUserId,
        })
        .select()
        .single();
    return result['id'] as int;
  }

  /// Delete a cicilan entry.
  Future<void> deleteCicilan(int id) async {
    await supabaseClient
        .from('history_cicilan')
        .delete()
        .eq('id', id)
        .eq('user_id', currentUserId);
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  UtangPiutang _mapToUtangPiutang(Map<String, dynamic> map) {
    return UtangPiutang(
      id: map['id'] as int?,
      namaOrang: map['nama_orang'] as String,
      jenis: map['jenis'] as String,
      nominalTotal: (map['nominal_total'] as num).toDouble(),
      nominalDibayar: (map['nominal_dibayar'] as num).toDouble(),
      tanggal: DateTime.parse(map['tanggal'] as String),
      tenggatWaktu: map['tenggat_waktu'] != null
          ? DateTime.parse(map['tenggat_waktu'] as String)
          : null,
      deskripsi: map['deskripsi'] as String?,
      isLunas: map['is_lunas'] == true,
    );
  }

  HistoryCicilan _mapToHistoryCicilan(Map<String, dynamic> map) {
    return HistoryCicilan(
      id: map['id'] as int?,
      idUtangPiutang: map['id_utang_piutang'] as int,
      nominal: (map['nominal'] as num).toDouble(),
      tanggal: DateTime.parse(map['tanggal'] as String),
    );
  }
}
