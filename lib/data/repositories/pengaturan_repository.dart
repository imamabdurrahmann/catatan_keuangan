import '../../models/models.dart';
import 'base_repository.dart';

/// Repository for pengaturan (settings) data in Supabase.
class PengaturanRepository with SupabaseRepositoryMixin {
  @override
  String get tableName => 'pengaturan';

  /// Get the user's settings (single row per user).
  Future<Pengaturan> getPengaturan() async {
    final data = await supabaseClient
        .from(tableName)
        .select()
        .eq('user_id', currentUserId)
        .maybeSingle();

    if (data == null) {
      // Auto-create default settings if none exist
      final result = await insertRow({
        'is_dark_mode': false,
      });
      return _mapToPengaturan(result);
    }
    return _mapToPengaturan(data);
  }

  /// Update user settings.
  Future<void> updatePengaturan(Pengaturan pengaturan) async {
    await supabaseClient
        .from(tableName)
        .upsert({
          'is_dark_mode': pengaturan.isDarkMode,
          'pin': pengaturan.pin,
          'use_biometric': pengaturan.useBiometric,
          'user_id': currentUserId,
        }, onConflict: 'user_id')
        .select();
  }

  Pengaturan _mapToPengaturan(Map<String, dynamic> map) {
    return Pengaturan(
      id: map['id'] as int?,
      isDarkMode: map['is_dark_mode'] == true,
      pin: map['pin'] as String?,
      useBiometric: map['use_biometric'] == true,
    );
  }
}
