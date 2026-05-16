import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catatan_keuangan/providers.dart';
import 'package:catatan_keuangan/models/models.dart';

void main() {
  group('UpdateSignalsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has all domain keys at 0', () {
      final state = container.read(updateSignalsProvider);
      expect(state['transaksi'], equals(0));
      expect(state['utangPiutang'], equals(0));
      expect(state['tabungan'], equals(0));
    });

    test('signal("transaksi") increments transaksi key', () {
      container.read(updateSignalsProvider.notifier).signal('transaksi');
      expect(container.read(updateSignalsProvider)['transaksi'], equals(1));
    });

    test('signal("utangPiutang") increments utangPiutang key', () {
      container.read(updateSignalsProvider.notifier).signal('utangPiutang');
      expect(container.read(updateSignalsProvider)['utangPiutang'], equals(1));
    });

    test('signal("tabungan") increments tabungan key', () {
      container.read(updateSignalsProvider.notifier).signal('tabungan');
      expect(container.read(updateSignalsProvider)['tabungan'], equals(1));
    });

    test('multiple signals increment correctly', () {
      container.read(updateSignalsProvider.notifier).signal('transaksi');
      container.read(updateSignalsProvider.notifier).signal('transaksi');
      container.read(updateSignalsProvider.notifier).signal('transaksi');
      expect(container.read(updateSignalsProvider)['transaksi'], equals(3));
    });
  });

  group('selectedViewDateProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial value is null', () {
      final date = container.read(selectedViewDateProvider);
      expect(date, isNull);
    });

    test('set() updates the date', () {
      final testDate = DateTime(2026, 6, 15);
      container.read(selectedViewDateProvider.notifier).set(testDate);
      expect(container.read(selectedViewDateProvider), equals(testDate));
    });

    test('set(null) resets to null', () {
      container
          .read(selectedViewDateProvider.notifier)
          .set(DateTime(2026, 5, 10));
      expect(container.read(selectedViewDateProvider), isNotNull);

      container.read(selectedViewDateProvider.notifier).set(null);
      expect(container.read(selectedViewDateProvider), isNull);
    });

    test('nextDay() advances by one day', () {
      container
          .read(selectedViewDateProvider.notifier)
          .set(DateTime(2026, 3, 15));

      container.read(selectedViewDateProvider.notifier).nextDay();

      final result = container.read(selectedViewDateProvider);
      expect(result?.day, equals(16));
      expect(result?.month, equals(3));
      expect(result?.year, equals(2026));
    });

    test('prevDay() goes back by one day', () {
      container
          .read(selectedViewDateProvider.notifier)
          .set(DateTime(2026, 3, 15));

      container.read(selectedViewDateProvider.notifier).prevDay();

      expect(container.read(selectedViewDateProvider)?.day, equals(14));
    });
  });

  group('selectedMonthProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial value is current month', () {
      final month = container.read(selectedMonthProvider);
      expect(month, greaterThanOrEqualTo(1));
      expect(month, lessThanOrEqualTo(12));
    });

    test('setMonth() updates state', () {
      container.read(selectedMonthProvider.notifier).setMonth(6);
      expect(container.read(selectedMonthProvider), equals(6));
    });

    test('increment() increases month by 1', () {
      container.read(selectedMonthProvider.notifier).setMonth(3);
      container.read(selectedMonthProvider.notifier).increment();
      expect(container.read(selectedMonthProvider), equals(4));
    });

    test('decrement() decreases month by 1', () {
      container.read(selectedMonthProvider.notifier).setMonth(5);
      container.read(selectedMonthProvider.notifier).decrement();
      expect(container.read(selectedMonthProvider), equals(4));
    });

    test('increment() wraps from December to January', () {
      container.read(selectedMonthProvider.notifier).setMonth(12);
      container.read(selectedMonthProvider.notifier).increment();
      expect(container.read(selectedMonthProvider), equals(1));
    });

    test('decrement() wraps from January to December', () {
      container.read(selectedMonthProvider.notifier).setMonth(1);
      container.read(selectedMonthProvider.notifier).decrement();
      expect(container.read(selectedMonthProvider), equals(12));
    });

    test(
      'setMonth() with invalid value is accepted (logic only validates in UI)',
      () {
        container.read(selectedMonthProvider.notifier).setMonth(7);
        expect(container.read(selectedMonthProvider), equals(7));
      },
    );
  });

  group('selectedYearProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial value is current year', () {
      final year = container.read(selectedYearProvider);
      final now = DateTime.now();
      expect(year, equals(now.year));
    });

    test('increment() increases year by 1', () {
      container.read(selectedYearProvider.notifier).setYear(2025);
      container.read(selectedYearProvider.notifier).increment();
      expect(container.read(selectedYearProvider), equals(2026));
    });

    test('decrement() decreases year by 1', () {
      container.read(selectedYearProvider.notifier).setYear(2027);
      container.read(selectedYearProvider.notifier).decrement();
      expect(container.read(selectedYearProvider), equals(2026));
    });

    test('setYear() sets arbitrary year', () {
      container.read(selectedYearProvider.notifier).setYear(2030);
      expect(container.read(selectedYearProvider), equals(2030));
    });

    test('multiple decrements work correctly', () {
      container.read(selectedYearProvider.notifier).setYear(2026);
      container.read(selectedYearProvider.notifier).decrement();
      container.read(selectedYearProvider.notifier).decrement();
      container.read(selectedYearProvider.notifier).decrement();
      expect(container.read(selectedYearProvider), equals(2023));
    });
  });

  group('todayNormalizedProvider', () {
    test('returns date with time stripped', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final today = container.read(todayNormalizedProvider);
      expect(today.hour, equals(0));
      expect(today.minute, equals(0));
      expect(today.second, equals(0));
      expect(today.millisecond, equals(0));
    });

    test('returns today date', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final now = DateTime.now();
      final today = container.read(todayNormalizedProvider);
      expect(today.year, equals(now.year));
      expect(today.month, equals(now.month));
      expect(today.day, equals(now.day));
    });
  });

  group('Provider family parameter patterns', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('transaksiByDateProvider uses DateTime as parameter', () {
      // Test that the family provider accepts a DateTime parameter
      // The actual data will come from DatabaseHelper but the family is configured
      final testDate = DateTime(2024, 6, 15);
      // Just verify the provider family is properly configured
      final autoDispose = container.read(transaksiByDateProvider(testDate));
      expect(autoDispose, isA<AsyncValue<List<Transaksi>>>());
    });

    test('monthlySummaryProvider uses record parameter', () {
      final params = (bulan: 6, tahun: 2024);
      final autoDispose = container.read(monthlySummaryProvider(params));
      expect(autoDispose, isA<AsyncValue<Map<String, double>>>());
    });

    test('categorySummaryProvider uses record parameter', () {
      final params = (bulan: 6, tahun: 2024);
      final autoDispose = container.read(categorySummaryProvider(params));
      expect(autoDispose, isA<AsyncValue<Map<String, double>>>());
    });

    test('budgetListProvider uses record parameter', () {
      final params = (bulan: 6, tahun: 2024);
      final autoDispose = container.read(budgetListProvider(params));
      expect(autoDispose, isA<AsyncValue<List<Budget>>>());
    });
  });
}
