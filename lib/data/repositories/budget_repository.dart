import '../../models/models.dart';
import 'base_repository.dart';

/// Repository for budget data in Supabase.
class BudgetRepository with SupabaseRepositoryMixin {
  @override
  String get tableName => 'budget';

  /// Get all budgets for a specific month/year.
  Future<List<Budget>> getBudgetByMonth(int tahun, int bulan) async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .eq('tahun', tahun)
        .eq('bulan', bulan);
    return List<Map<String, dynamic>>.from(data)
        .map(_mapToBudget)
        .toList();
  }

  /// Get budget for specific category + month.
  Future<Budget?> getBudgetByKategori(
    int tahun,
    int bulan,
    String kategori,
  ) async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .eq('tahun', tahun)
        .eq('bulan', bulan)
        .eq('kategori', kategori)
        .maybeSingle();
    return data != null ? _mapToBudget(data) : null;
  }

  /// Upsert a budget (insert or update if exists).
  Future<int> upsertBudget(Budget budget) async {
    final map = {
      'bulan': budget.bulan,
      'tahun': budget.tahun,
      'nominal': budget.nominal,
      'kategori': budget.kategori,
      'profil_id': budget.profilId,
      'sisa_rollover': budget.sisaRollover,
      'user_id': currentUserId,
    };

    final result = await supabaseClient
        .from(tableName)
        .upsert(map, onConflict: 'bulan,tahun,kategori,user_id')
        .select()
        .single();
    return result['id'] as int;
  }

  /// Delete a budget.
  Future<void> deleteBudget(int id) async {
    await deleteRow(id);
  }

  Budget _mapToBudget(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      bulan: map['bulan'] as int,
      tahun: map['tahun'] as int,
      nominal: (map['nominal'] as num).toDouble(),
      kategori: map['kategori'] as String,
      profilId: map['profil_id'] as int? ?? 1,
      sisaRollover: (map['sisa_rollover'] as num?)?.toDouble() ?? 0,
    );
  }
}
