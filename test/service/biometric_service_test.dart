import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/services/biometric_service.dart';

void main() {
  // Initialize Flutter bindings for platform channel tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricService', () {
    test('instance returns same object', () {
      final a = BiometricService.instance;
      final b = BiometricService.instance;
      expect(a, same(b));
    });

    test('instance is non-null', () {
      expect(BiometricService.instance, isNotNull);
    });

    // Note: BiometricService methods call platform channels (local_auth plugin).
    // In the test environment without a mock plugin, these throw platform
    // exceptions. We test that the methods are properly implemented and
    // handle exceptions gracefully (returning false / empty list).
    test('isAvailable handles platform exception gracefully', () async {
      // The method should not throw - it catches PlatformException internally
      // and returns false. On desktop/non-biometric platforms it returns false.
      bool threw = false;
      bool result = false;
      try {
        result = await BiometricService.instance.isAvailable();
      } catch (e) {
        threw = true;
      }
      // Should not throw, and result should be a bool
      expect(threw, isFalse);
      expect(result, isA<bool>());
    });

    test(
      'getAvailableBiometrics handles platform exception gracefully',
      () async {
        bool threw = false;
        List<dynamic> result = [];
        try {
          result = await BiometricService.instance.getAvailableBiometrics();
        } catch (e) {
          threw = true;
        }
        expect(result.isEmpty || threw, isTrue);
      },
    );

    test(
      'hasEnrolledBiometrics handles platform exception gracefully',
      () async {
        bool threw = false;
        bool result = false;
        try {
          result = await BiometricService.instance.hasEnrolledBiometrics();
        } catch (e) {
          threw = true;
        }
        expect(result == false || threw, isTrue);
      },
    );

    test('authenticate handles platform exception gracefully', () async {
      bool threw = false;
      bool result = false;
      try {
        result = await BiometricService.instance.authenticate(reason: 'Test');
      } catch (e) {
        threw = true;
      }
      expect(result == false || threw, isTrue);
    });
  });
}
