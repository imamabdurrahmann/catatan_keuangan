import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../models/models.dart';
import '../services/error_service.dart';
import '../services/notification_service.dart';
import '../models/constants.dart';

/// Service that automatically creates recurring transactions on schedule.
/// Runs on app startup and app resume, respecting a once-per-day check pattern.
class RecurringScheduler {
  static final RecurringScheduler _instance = RecurringScheduler._();
  static RecurringScheduler get instance => _instance;
  RecurringScheduler._();

  static const String _prefLastCheck = 'recurring_scheduler_last_check';

  /// Checks all recurring transactions and creates any that are due today.
  /// Only processes once per calendar day (tracked via SharedPreferences).
  /// Returns the number of transactions created.
  Future<int> checkAndCreateRecurring() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayStr = formatDateKey(today);
      final lastCheck = prefs.getString(_prefLastCheck);

      // Already checked today — skip
      if (lastCheck == todayStr) {
        return 0;
      }

      final created = await _processRecurring();

      // Record today's check date
      await prefs.setString(_prefLastCheck, todayStr);

      return created;
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      return 0;
    }
  }

  /// Shows a notification reminder for transactions that will be auto-created today.
  Future<void> showRecurringReminder() async {
    try {
      final recurring = await DatabaseHelper.instance.getRecurringTransaksi();
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);

      for (var tx in recurring) {
        if (tx.recurringFrequency == null) continue;

        final nextDate = calculateNextOccurrence(
          tx.tanggal,
          tx.recurringFrequency!,
        );
        if (nextDate == null) continue;

        final nextNormalized = DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
        );
        if (nextNormalized.isAtSameMomentAs(todayNormalized)) {
          await NotificationService.instance.showRecurringAutoCreate(
            deskripsi: tx.deskripsi,
            jumlah: tx.jumlah,
            jenis: tx.jenis,
            frequencyLabel: AppConstants.frequencyLabel(tx.recurringFrequency!),
          );
        }
      }
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
    }
  }

  Future<int> _processRecurring() async {
    final recurring = await DatabaseHelper.instance.getRecurringTransaksi();
    int created = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var tx in recurring) {
      if (tx.id == null) continue;
      if (tx.recurringFrequency == null) continue;

      final db = await DatabaseHelper.instance.database;
      final existing = await db.rawQuery(
        '''
        SELECT MAX(tanggal) as last_date FROM transaksi
        WHERE deleted_at IS NULL
          AND deskripsi = ?
          AND kategori = ?
          AND jenis = ?
          AND ABS(jumlah - ?) < 0.01
          AND id != ?
        ''',
        [tx.deskripsi, tx.kategori, tx.jenis, tx.jumlah, tx.id],
      );

      DateTime startDate;
      final lastDateStr = existing.first['last_date'] as String?;
      if (lastDateStr != null) {
        startDate = DateTime.parse(lastDateStr);
      } else {
        startDate = tx.tanggal;
      }

      final normalizedStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final frequency = tx.recurringFrequency!;

      DateTime? nextDate = calculateNextOccurrence(normalizedStart, frequency);

      while (nextDate != null &&
          (nextDate.isBefore(today) || nextDate.isAtSameMomentAs(today))) {
        final newTx = Transaksi(
          jenis: tx.jenis,
          jumlah: tx.jumlah,
          deskripsi: tx.deskripsi,
          kategori: tx.kategori,
          tanggal: nextDate,
          lampiran: tx.lampiran,
          idDompet: tx.idDompet,
          isRecurring: false,
          recurringFrequency: null,
        );
        await DatabaseHelper.instance.insertTransaksi(newTx);
        created++;
        nextDate = calculateNextOccurrence(nextDate, frequency);
      }
    }

    return created;
  }

  /// Calculates the next occurrence date based on frequency string.
  DateTime? calculateNextOccurrence(DateTime from, String frequency) {
    switch (frequency) {
      case AppConstants.freqDaily:
        return from.add(const Duration(days: 1));
      case AppConstants.freqWeekly:
        return from.add(const Duration(days: 7));
      case AppConstants.freqMonthly:
        return DateTime(from.year, from.month + 1, from.day);
      case AppConstants.freqQuarterly:
        return DateTime(from.year, from.month + 3, from.day);
      case AppConstants.freqYearly:
        return DateTime(from.year + 1, from.month, from.day);
      default:
        return null;
    }
  }

  String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
