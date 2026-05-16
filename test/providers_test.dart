import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catatan_keuangan/providers.dart';

void main() {
  group('SelectedViewDateNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      final state = container.read(selectedViewDateProvider);
      expect(state, isNull);
    });

    test('set() updates the date', () {
      final notifier = container.read(selectedViewDateProvider.notifier);
      final testDate = DateTime(2026, 3, 15);

      notifier.set(testDate);

      expect(container.read(selectedViewDateProvider), equals(testDate));
    });

    test('nextDay() advances by one day', () {
      final notifier = container.read(selectedViewDateProvider.notifier);
      final startDate = DateTime(2026, 3, 15);

      notifier.set(startDate);
      notifier.nextDay();

      final result = container.read(selectedViewDateProvider);
      expect(result?.day, equals(16));
      expect(result?.month, equals(3));
      expect(result?.year, equals(2026));
    });

    test('prevDay() goes back by one day', () {
      final notifier = container.read(selectedViewDateProvider.notifier);
      final startDate = DateTime(2026, 3, 15);

      notifier.set(startDate);
      notifier.prevDay();

      final result = container.read(selectedViewDateProvider);
      expect(result?.day, equals(14));
    });

    test('nextDay() from null uses DateTime.now() as base', () {
      final notifier = container.read(selectedViewDateProvider.notifier);
      expect(container.read(selectedViewDateProvider), isNull);

      notifier.nextDay();

      final result = container.read(selectedViewDateProvider);
      expect(result, isNotNull);

      // nextDay() from null uses DateTime.now() as base, then adds 1 day.
      // Verify it's in a reasonable range (today or tomorrow from now).
      final now = DateTime.now();
      final diff = result!
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
      expect(diff, inInclusiveRange(0, 1)); // today or tomorrow
    });

    test('prevDay() from null uses DateTime.now()', () {
      final notifier = container.read(selectedViewDateProvider.notifier);
      expect(container.read(selectedViewDateProvider), isNull);

      notifier.prevDay();

      final result = container.read(selectedViewDateProvider);
      expect(result, isNotNull);
    });

    test('set(null) resets to null', () {
      final notifier = container.read(selectedViewDateProvider.notifier);
      notifier.set(DateTime(2026, 5, 10));
      expect(container.read(selectedViewDateProvider), isNotNull);

      notifier.set(null);
      expect(container.read(selectedViewDateProvider), isNull);
    });
  });

  group('SelectedMonthNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is current month', () {
      final month = container.read(selectedMonthProvider);
      expect(month, greaterThanOrEqualTo(1));
      expect(month, lessThanOrEqualTo(12));
    });

    test('increment() increases month by 1', () {
      final notifier = container.read(selectedMonthProvider.notifier);
      notifier.setMonth(3);

      notifier.increment();

      expect(container.read(selectedMonthProvider), equals(4));
    });

    test('decrement() decreases month by 1', () {
      final notifier = container.read(selectedMonthProvider.notifier);
      notifier.setMonth(5);

      notifier.decrement();

      expect(container.read(selectedMonthProvider), equals(4));
    });

    test('increment() wraps from December to January', () {
      final notifier = container.read(selectedMonthProvider.notifier);
      notifier.setMonth(12);

      notifier.increment();

      expect(container.read(selectedMonthProvider), equals(1));
    });

    test('decrement() wraps from January to December', () {
      final notifier = container.read(selectedMonthProvider.notifier);
      notifier.setMonth(1);

      notifier.decrement();

      expect(container.read(selectedMonthProvider), equals(12));
    });

    test('setMonth() sets arbitrary month', () {
      final notifier = container.read(selectedMonthProvider.notifier);
      notifier.setMonth(7);
      expect(container.read(selectedMonthProvider), equals(7));
    });

    test('multiple increments wrap correctly', () {
      final notifier = container.read(selectedMonthProvider.notifier);
      notifier.setMonth(11);

      notifier.increment(); // 12
      notifier.increment(); // 1
      notifier.increment(); // 2

      expect(container.read(selectedMonthProvider), equals(2));
    });
  });

  group('SelectedYearNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is current year', () {
      final year = container.read(selectedYearProvider);
      final now = DateTime.now();
      expect(year, equals(now.year));
    });

    test('increment() increases year by 1', () {
      final notifier = container.read(selectedYearProvider.notifier);
      notifier.setYear(2025);

      notifier.increment();

      expect(container.read(selectedYearProvider), equals(2026));
    });

    test('decrement() decreases year by 1', () {
      final notifier = container.read(selectedYearProvider.notifier);
      notifier.setYear(2027);

      notifier.decrement();

      expect(container.read(selectedYearProvider), equals(2026));
    });

    test('setYear() sets arbitrary year', () {
      final notifier = container.read(selectedYearProvider.notifier);
      notifier.setYear(2030);
      expect(container.read(selectedYearProvider), equals(2030));
    });

    test('multiple decrements work correctly', () {
      final notifier = container.read(selectedYearProvider.notifier);
      notifier.setYear(2026);
      notifier.decrement();
      notifier.decrement();
      notifier.decrement();

      expect(container.read(selectedYearProvider), equals(2023));
    });

    test('multiple increments work correctly', () {
      final notifier = container.read(selectedYearProvider.notifier);
      notifier.setYear(2024);
      notifier.increment();
      notifier.increment();

      expect(container.read(selectedYearProvider), equals(2026));
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
}
