import '../../models/models.dart';
import 'base_repository.dart';

/// Repository for transaksi (transactions) data in Supabase.
class TransaksiRepository with SupabaseRepositoryMixin {
  @override
  String get tableName => 'transaksi';

  /// Get all active (non-deleted) transactions, newest first.
  Future<List<Transaksi>> getAllTransaksi() async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .isFilter('deleted_at', null)
        .order('tanggal', ascending: false);
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToTransaksi)
        .toList();
  }

  /// Get transactions for a specific month.
  Future<List<Transaksi>> getTransaksiByMonth(
    int year,
    int month, {
    int? idDompet,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    var query = supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .isFilter('deleted_at', null)
        .gte('tanggal', startDate.toIso8601String())
        .lte('tanggal', endDate.toIso8601String());

    if (idDompet != null) {
      query = query.eq('id_dompet', idDompet);
    }

    final data = await query.order('tanggal', ascending: false);
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToTransaksi)
        .toList();
  }

  /// Get transactions for a specific date.
  Future<List<Transaksi>> getTransaksiByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .isFilter('deleted_at', null)
        .gte('tanggal', startDate.toIso8601String())
        .lt('tanggal', endDate.toIso8601String())
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(data)
        .map(_mapToTransaksi)
        .toList();
  }

  /// Insert a new transaction. Returns the server-generated ID.
  Future<int> insertTransaksi(Transaksi transaksi) async {
    final map = _transaksiToSupabase(transaksi);
    final result = await insertRow(map);
    return result['id'] as int;
  }

  /// Update an existing transaction.
  Future<void> updateTransaksi(Transaksi transaksi) async {
    if (transaksi.id == null) return;
    final map = _transaksiToSupabase(transaksi);
    await updateRow(transaksi.id!, map);
  }

  /// Soft-delete a transaction (set deleted_at).
  Future<void> softDeleteTransaksi(int id) async {
    await supabaseClient
        .from(tableName)
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', currentUserId);
  }

  /// Permanently delete a transaction.
  Future<void> hardDeleteTransaksi(int id) async {
    await deleteRow(id);
  }

  /// Restore a soft-deleted transaction.
  Future<void> restoreTransaksi(int id) async {
    await supabaseClient
        .from(tableName)
        .update({'deleted_at': null})
        .eq('id', id)
        .eq('user_id', currentUserId);
  }

  /// Get soft-deleted transactions (trash).
  Future<List<Transaksi>> getDeletedTransaksi() async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false);
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToTransaksi)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _transaksiToSupabase(Transaksi t) {
    return {
      'jenis': t.jenis,
      'jumlah': t.jumlah,
      'deskripsi': t.deskripsi,
      'kategori': t.kategori,
      'tanggal': t.tanggal.toIso8601String(),
      'id_dompet': t.idDompet,
      'is_recurring': t.isRecurring,
      'recurring_frequency': t.recurringFrequency,
      'lampiran': t.lampiran.isNotEmpty ? t.lampiran : null,
      'deleted_at': t.deletedAt?.toIso8601String(),
    };
  }

  Transaksi _mapToTransaksi(Map<String, dynamic> map) {
    List<String> parsedLampiran = [];
    if (map['lampiran'] != null) {
      if (map['lampiran'] is List) {
        parsedLampiran = List<String>.from(map['lampiran']);
      }
    }

    return Transaksi(
      id: map['id'] as int?,
      jenis: map['jenis'] as String,
      jumlah: (map['jumlah'] as num).toDouble(),
      deskripsi: map['deskripsi'] as String,
      kategori: map['kategori'] as String,
      tanggal: DateTime.parse(map['tanggal'] as String),
      lampiran: parsedLampiran,
      isRecurring: map['is_recurring'] == true,
      recurringFrequency: map['recurring_frequency'] as String?,
      idDompet: map['id_dompet'] as int?,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
    );
  }
}
