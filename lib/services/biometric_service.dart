import 'package:flutter/services.dart';
import '../utils/platform_utils.dart';

// Conditionally use local_auth only on mobile
import 'package:local_auth/local_auth.dart';

/// Service for biometric authentication (fingerprint / face unlock).
/// Returns safe defaults on desktop platforms where biometrics are unavailable.
class BiometricService {
  static final BiometricService instance = BiometricService._init();
  static final _auth = LocalAuthentication();

  BiometricService._init();

  /// Returns true if biometric authentication is available on this device.
  Future<bool> isAvailable() async {
    if (!PlatformUtils.isMobile) return false;
    try {
      final canAuth = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canAuth && isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of available biometric types.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (!PlatformUtils.isMobile) return [];
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Returns true if any biometric (fingerprint, face, etc.) is enrolled.
  Future<bool> hasEnrolledBiometrics() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.isNotEmpty;
  }

  /// Authenticates the user using biometrics.
  /// Returns true if authentication succeeded.
  Future<bool> authenticate({
    String reason = 'Verifikasi identitas Anda',
  }) async {
    if (!PlatformUtils.isMobile) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
