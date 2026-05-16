import 'package:flutter/foundation.dart';

/// Simple error tracking service.
/// Currently logs to console in debug mode.
/// Can be extended to send to Sentry/Firebase Crashlytics later.
class ErrorService {
  static final ErrorService _instance = ErrorService._();
  static ErrorService get instance => ErrorService._instance;
  ErrorService._();

  void recordError(dynamic error, [StackTrace? stack]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('ERROR [${DateTime.now()}]: $error');
      if (stack != null) {
        // ignore: avoid_print
        print('STACK: $stack');
      }
    }
    // TODO(extension): Add Sentry/Crashlytics integration here
  }

  void recordFlutterError(FlutterErrorDetails details) {
    recordError(details.exception, details.stack);
  }
}
