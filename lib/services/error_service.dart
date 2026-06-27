import 'package:flutter/foundation.dart';

/// Simple error tracking service.
/// Currently logs to console in debug mode.
/// Can be extended to send to Sentry/Firebase Crashlytics later.
class ErrorService {
  static final ErrorService _instance = ErrorService._();
  static ErrorService get instance => ErrorService._instance;
  ErrorService._();

  final List<String> _logs = [];

  void recordError(dynamic error, [StackTrace? stack]) {
    final message = 'ERROR [${DateTime.now()}]: $error';
    _logs.add(message);
    if (kDebugMode) {
      // ignore: avoid_print
      print(message);
      if (stack != null) {
        // ignore: avoid_print
        print('STACK: $stack');
      }
    }
    // TODO(extension): Add Sentry/Crashlytics integration here
  }

  void recordFatalError(dynamic error, [StackTrace? stack]) {
    recordError('FATAL: $error', stack);
  }

  void recordFlutterError(FlutterErrorDetails details) {
    recordError(details.exception, details.stack);
  }

  List<String> getErrorLog() {
    return List.unmodifiable(_logs);
  }

  void clearErrorLog() {
    _logs.clear();
  }
}
