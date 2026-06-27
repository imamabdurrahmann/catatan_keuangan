import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

/// Base repository mixin providing common Supabase CRUD helpers.
///
/// Each repository targets a single Supabase table and automatically
/// scopes all queries to the current authenticated user via [currentUserId].
mixin SupabaseRepositoryMixin {
  /// The Supabase table name this repository operates on.
  String get tableName;

  SupabaseClient get supabaseClient => SupabaseConfig.client;

  String get currentUserId {
    final uid = SupabaseConfig.currentUserId;
    if (uid == null) throw StateError('User is not authenticated');
    return uid;
  }

  /// SELECT all rows belonging to the current user.
  Future<List<Map<String, dynamic>>> selectAll({
    String orderBy = 'id',
    bool ascending = true,
  }) async {
    try {
      final response = await supabaseClient
          .from(tableName)
          .select()
          .eq('user_id', currentUserId)
          .order(orderBy, ascending: ascending);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('SupabaseRepo.selectAll($tableName) error: $e');
      rethrow;
    }
  }

  /// SELECT a single row by [id] belonging to the current user.
  Future<Map<String, dynamic>?> selectById(int id) async {
    try {
      final response = await supabaseClient
          .from(tableName)
          .select()
          .eq('id', id)
          .eq('user_id', currentUserId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('SupabaseRepo.selectById($tableName, $id) error: $e');
      rethrow;
    }
  }

  /// INSERT a row, automatically injecting `user_id`.
  /// Returns the inserted row (with server-generated `id`).
  Future<Map<String, dynamic>> insertRow(Map<String, dynamic> data) async {
    try {
      final payload = {...data, 'user_id': currentUserId};
      payload.remove('id'); // Let Supabase auto-generate
      final response =
          await supabaseClient.from(tableName).insert(payload).select().single();
      return response;
    } catch (e) {
      debugPrint('SupabaseRepo.insertRow($tableName) error: $e');
      rethrow;
    }
  }

  /// UPDATE a row by [id], scoped to the current user.
  Future<Map<String, dynamic>> updateRow(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final payload = {...data};
      payload.remove('id');
      payload.remove('user_id');
      final response = await supabaseClient
          .from(tableName)
          .update(payload)
          .eq('id', id)
          .eq('user_id', currentUserId)
          .select()
          .single();
      return response;
    } catch (e) {
      debugPrint('SupabaseRepo.updateRow($tableName, $id) error: $e');
      rethrow;
    }
  }

  /// DELETE a row by [id], scoped to the current user.
  Future<void> deleteRow(int id) async {
    try {
      await supabaseClient
          .from(tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId);
    } catch (e) {
      debugPrint('SupabaseRepo.deleteRow($tableName, $id) error: $e');
      rethrow;
    }
  }
}
