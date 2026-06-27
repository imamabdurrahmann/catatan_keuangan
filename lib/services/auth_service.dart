import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/supabase_config.dart';
import '../services/sync_service.dart';

/// Authentication service that wraps Supabase Auth.
///
/// Provides sign up, sign in, sign out, and auth state listening.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool _isGoogleSignInInitialized = false;

  SupabaseClient get _client => SupabaseConfig.client;

  // ---------------------------------------------------------------------------
  // Auth state
  // ---------------------------------------------------------------------------

  /// Stream of auth state changes (sign in, sign out, token refresh, etc.)
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// The currently signed-in user, or null.
  User? get currentUser => _client.auth.currentUser;

  /// The current session, or null.
  Session? get currentSession => _client.auth.currentSession;

  /// Whether a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  // ---------------------------------------------------------------------------
  // Email / Password auth
  // ---------------------------------------------------------------------------

  /// Register a new user with email and password.
  ///
  /// Returns the [AuthResponse]. Throws on failure.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );
      return response;
    } catch (e) {
      debugPrint('AuthService.signUpWithEmail error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Trigger sync after successful login
      if (response.session != null) {
        // Run asynchronously without awaiting to not block UI navigation
        SyncService.instance.syncAll();
      }
      
      return response;
    } catch (e) {
      debugPrint('AuthService.signInWithEmail error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In (OAuth)
  // ---------------------------------------------------------------------------

  /// Sign in with Google using native Google Sign-In package.
  Future<AuthResponse> signInWithGoogle() async {
    try {
      if (SupabaseConfig.googleWebClientId.isEmpty) {
        throw Exception('Google Web Client ID belum disetting di config.');
      }

      if (!_isGoogleSignInInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: SupabaseConfig.googleWebClientId,
          clientId: SupabaseConfig.googleIosClientId.isNotEmpty ? SupabaseConfig.googleIosClientId : null,
        );
        _isGoogleSignInInitialized = true;
      }

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await GoogleSignIn.instance.authenticate();
      } catch (e) {
        throw AuthException('Google Sign-In gagal atau dibatalkan: $e');
      }

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid',
      ]);
      final accessToken = clientAuth.accessToken;

      if (idToken == null) {
        throw AuthException('Gagal mendapatkan ID Token dari Google.');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Trigger sync after successful login
      if (response.session != null) {
        SyncService.instance.syncAll();
      }

      return response;
    } catch (e) {
      debugPrint('AuthService.signInWithGoogle error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Password reset
  // ---------------------------------------------------------------------------

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('AuthService.resetPassword error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      try {
        await GoogleSignIn.instance.signOut();
      } catch (ge) {
        debugPrint('GoogleSignIn.signOut error: $ge');
      }
    } catch (e) {
      debugPrint('AuthService.signOut error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Seed data after first sign-up
  // ---------------------------------------------------------------------------

  /// Creates the initial user data in Supabase after a fresh sign-up:
  /// default profil, default dompet, and default pengaturan.
  Future<void> seedUserData() async {
    final userId = currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Default profil
      final profilResult = await _client
          .from('profil')
          .insert({
            'nama': 'Pribadi',
            'icon': 'person',
            'user_id': userId,
          })
          .select('id')
          .single();

      final profilId = profilResult['id'];

      // 2. Default dompet
      await _client.from('dompet').insert({
        'nama': 'Dompet Utama',
        'saldo': 0.0,
        'warna': 'green',
        'currency': 'IDR',
        'profil_id': profilId,
        'user_id': userId,
      });

      // 3. Default pengaturan
      await _client.from('pengaturan').insert({
        'is_dark_mode': false,
        'user_id': userId,
      });
    } catch (e) {
      debugPrint('AuthService.seedUserData error: $e');
      // Non-critical: seed failure should not block the user
    }
  }

  // ---------------------------------------------------------------------------
  // Helper: friendly error messages
  // ---------------------------------------------------------------------------

  /// Converts a Supabase [AuthException] into a user-friendly Indonesian message.
  static String friendlyError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid_credentials')) {
        return 'Email atau password salah.';
      }
      if (msg.contains('email not confirmed')) {
        return 'Email belum diverifikasi. Cek inbox email kamu.';
      }
      if (msg.contains('user already registered') ||
          msg.contains('already been registered')) {
        return 'Email sudah terdaftar. Silakan login.';
      }
      if (msg.contains('password') && msg.contains('short')) {
        return 'Password minimal 6 karakter.';
      }
      if (msg.contains('rate limit')) {
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      }
      return error.message;
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
