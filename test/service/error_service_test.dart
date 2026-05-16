import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/services/error_service.dart';

void main() {
  group('ErrorService Tests', () {
    late ErrorService errorService;

    setUp(() {
      errorService = ErrorService.instance;
    });

    test('ErrorService singleton pattern', () {
      final instance1 = ErrorService.instance;
      final instance2 = ErrorService.instance;
      expect(instance1, same(instance2));
    });

    group('recordError', () {
      test('handles exception without stack trace', () {
        // Should not throw
        expect(
          () => errorService.recordError(Exception('Test error'), null),
          returnsNormally,
        );
      });

      test('handles exception with stack trace', () {
        final stackTrace = StackTrace.current;
        expect(
          () => errorService.recordError(Exception('Test'), stackTrace),
          returnsNormally,
        );
      });

      test('handles string errors', () {
        expect(
          () => errorService.recordError('String error', null),
          returnsNormally,
        );
      });

      test('handles null error object', () {
        expect(
          () => errorService.recordError(null, null),
          returnsNormally,
        );
      });
    });

    group('recordFatalError', () {
      test('handles fatal errors', () {
        expect(
          () => errorService.recordFatalError(
            Exception('Fatal error'),
            StackTrace.current,
          ),
          returnsNormally,
        );
      });
    });

    group('getErrorLog', () {
      test('returns list (may be empty)', () {
        final logs = errorService.getErrorLog();
        expect(logs, isA<List>());
      });
    });

    group('clearErrorLog', () {
      test('clears error log without error', () {
        expect(
          () => errorService.clearErrorLog(),
          returnsNormally,
        );
      });
    });
  });
}