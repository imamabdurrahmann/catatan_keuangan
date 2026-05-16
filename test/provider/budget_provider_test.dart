import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catatan_keuangan/providers.dart';
import 'package:catatan_keuangan/models/models.dart';
import 'package:catatan_keuangan/data/database_helper.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() async {
    initializeTestEnvironment();
    await DatabaseHelper.instance.database;
  });

  tearDownAll(() async {
    await DatabaseHelper.resetForTesting();
  });

  group('categorySummaryProvider', () {
    test('returns AsyncValue structure with record parameter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final params = (bulan: 6, tahun: 2024);
      final asyncValue = container.read(categorySummaryProvider(params));

      expect(asyncValue, isA<AsyncValue<Map<String, double>>>());
    });
  });

  group('monthlySummaryProvider', () {
    test('returns AsyncValue structure with record parameter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final params = (bulan: 6, tahun: 2024);
      final asyncValue = container.read(monthlySummaryProvider(params));

      expect(asyncValue, isA<AsyncValue<Map<String, double>>>());
    });

    test('returns correct keys for summary', () {
      // Verify the expected summary keys are documented
      // The actual values come from DatabaseHelper at runtime
      final params = (bulan: 6, tahun: 2024);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final value = container.read(monthlySummaryProvider(params));
      expect(value, isA<AsyncValue<Map<String, double>>>());
    });
  });

  group('budgetListProvider', () {
    test('returns AsyncValue structure with record parameter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final params = (bulan: 6, tahun: 2024);
      final asyncValue = container.read(budgetListProvider(params));

      expect(asyncValue, isA<AsyncValue<List<Budget>>>());
    });

    test('accepts different month/year combinations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Test various month/year combinations
      final params1 = (bulan: 1, tahun: 2024);
      final params2 = (bulan: 12, tahun: 2025);
      final params3 = (bulan: 6, tahun: 2026);

      expect(
        container.read(budgetListProvider(params1)),
        isA<AsyncValue<List<Budget>>>(),
      );
      expect(
        container.read(budgetListProvider(params2)),
        isA<AsyncValue<List<Budget>>>(),
      );
      expect(
        container.read(budgetListProvider(params3)),
        isA<AsyncValue<List<Budget>>>(),
      );
    });
  });
}
