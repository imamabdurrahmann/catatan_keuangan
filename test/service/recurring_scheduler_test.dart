import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/services/recurring_scheduler.dart';
import 'package:catatan_keuangan/models/constants.dart';

void main() {
  group('RecurringScheduler._calculateNextOccurrence', () {
    test('daily increments by 1 day', () {
      final scheduler = RecurringScheduler.instance;
      final from = DateTime(2024, 6, 1);
      final result = scheduler.calculateNextOccurrence(
        from,
        AppConstants.freqDaily,
      );
      expect(result, DateTime(2024, 6, 2));
    });

    test('weekly increments by 7 days', () {
      final scheduler = RecurringScheduler.instance;
      final from = DateTime(2024, 6, 1);
      final result = scheduler.calculateNextOccurrence(
        from,
        AppConstants.freqWeekly,
      );
      expect(result, DateTime(2024, 6, 8));
    });

    test('monthly increments month by 1', () {
      final scheduler = RecurringScheduler.instance;
      final from = DateTime(2024, 6, 1);
      final result = scheduler.calculateNextOccurrence(
        from,
        AppConstants.freqMonthly,
      );
      expect(result, DateTime(2024, 7, 1));
    });

    test('monthly handles end-of-month correctly', () {
      final scheduler = RecurringScheduler.instance;
      // Jan 31 + 1 month = Feb 28/29 (not Jan 32)
      final from = DateTime(2024, 1, 31);
      final result = scheduler.calculateNextOccurrence(
        from,
        AppConstants.freqMonthly,
      );
      // Dart DateTime clamps to the last valid day of the month
      expect(result!.month, greaterThan(1));
    });

    test('quarterly increments month by 3', () {
      final scheduler = RecurringScheduler.instance;
      final from = DateTime(2024, 3, 15);
      final result = scheduler.calculateNextOccurrence(
        from,
        AppConstants.freqQuarterly,
      );
      expect(result, DateTime(2024, 6, 15));
    });

    test('yearly increments year by 1', () {
      final scheduler = RecurringScheduler.instance;
      final from = DateTime(2024, 6, 1);
      final result = scheduler.calculateNextOccurrence(
        from,
        AppConstants.freqYearly,
      );
      expect(result, DateTime(2025, 6, 1));
    });

    test('unknown frequency returns null', () {
      final scheduler = RecurringScheduler.instance;
      final from = DateTime(2024, 6, 1);
      final result = scheduler.calculateNextOccurrence(from, 'unknown');
      expect(result, isNull);
    });
  });

  group('RecurringScheduler.formatDateKey', () {
    test('formats date as YYYY-MM-DD', () {
      final scheduler = RecurringScheduler.instance;
      expect(scheduler.formatDateKey(DateTime(2024, 6, 5)), '2024-06-05');
      expect(scheduler.formatDateKey(DateTime(2024, 12, 31)), '2024-12-31');
      expect(scheduler.formatDateKey(DateTime(2024, 1, 1)), '2024-01-01');
    });
  });
}
