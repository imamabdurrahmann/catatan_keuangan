import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration constants and helper accessors.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL
  static const String url = 'https://xrwtmiljnpifsvmblrqi.supabase.co';

  /// Supabase anon (public) key
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhyd3RtaWxqbnBpZnN2bWJscnFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5OTM3NDcsImV4cCI6MjA5NDU2OTc0N30.DlXDe7V8MORo2NHp8nKyp_r56iSNEd96WxKLho5pcw8';

  /// Shortcut to the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Shortcut to the current authenticated user (nullable).
  static User? get currentUser => client.auth.currentUser;

  /// Shortcut to the current user's UUID (nullable).
  static String? get currentUserId => currentUser?.id;

  /// Web Client ID for Google Sign In (Android/Web).
  /// Get this from Google Cloud Console > APIs & Services > Credentials > OAuth 2.0 Client IDs (Type: Web Application)
  static const String googleWebClientId = '496516129721-9jreedflhh9ak6lrp2l05m35qvottu8h.apps.googleusercontent.com';

  /// iOS Client ID for Google Sign In (if deploying to iOS).
  static const String googleIosClientId = ''; // TODO: Paste iOS Client ID here
}
