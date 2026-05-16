import 'dart:io' show Platform;

/// Platform detection utilities.
/// Centralizes all platform checks to avoid scattered `Platform.isXxx` calls.
class PlatformUtils {
  PlatformUtils._();

  /// True when running on Android.
  static bool get isAndroid => Platform.isAndroid;

  /// True when running on a desktop OS (Windows, macOS, Linux).
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// True when running on a mobile OS (Android, iOS).
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
