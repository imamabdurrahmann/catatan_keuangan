import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../router.dart';
import 'error_service.dart';
import '../config/app_config.dart';
import '../utils/platform_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Deduplication: tracks recently shown notification keys within the current session.
  // Cleared when checkAndNotify() starts, so each call is a fresh session.
  final Set<String> _shownNotifKeys = {};

  // SharedPreferences keys
  static const String _prefBudget = 'notif_budget';
  static const String _prefDebt = 'notif_debt';
  static const String _prefSavings = 'notif_savings';
  static const String _prefRecurring = 'notif_recurring';

  // Channel IDs
  static const String budgetChannelId = 'budget_channel';
  static const String debtChannelId = 'debt_channel';
  static const String savingsChannelId = 'savings_channel';
  static const String achievementChannelId = 'achievement_channel';
  static const String recurringChannelId = 'recurring_channel';

  Future<void> initialize() async {
    if (_initialized) return;
    // Notifications are only supported on mobile platforms
    if (!PlatformUtils.isMobile) {
      _initialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannels();

    // Request notification permission (Android 13+)
    // This is non-blocking and will be no-op if already granted
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        await android.requestNotificationsPermission();
      }
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      // Permission request can fail on some devices -- continue without notifications
    }

    await _initDefaults();
    _initialized = true;
  }

  Future<void> _initDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    // Default all notifications to enabled if not previously set
    await prefs.setBool(_prefBudget, prefs.getBool(_prefBudget) ?? true);
    await prefs.setBool(_prefDebt, prefs.getBool(_prefDebt) ?? true);
    await prefs.setBool(_prefSavings, prefs.getBool(_prefSavings) ?? true);
  }

  Future<void> _createChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          budgetChannelId,
          'Budget Alerts',
          description: 'Notifications for budget threshold warnings',
          importance: Importance.high,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          debtChannelId,
          'Debt Reminders',
          description: 'Notifications for debt due dates',
          importance: Importance.high,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          savingsChannelId,
          'Savings Goals',
          description: 'Notifications for savings goal milestones',
          importance: Importance.defaultImportance,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          achievementChannelId,
          'Achievements',
          description: 'Notifications for unlocked achievements',
          importance: Importance.defaultImportance,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          recurringChannelId,
          'Recurring Transactions',
          description: 'Notifications for recurring transaction reminders',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - can navigate based on payload
    // Payload format: type|value (e.g., "budget|Makanan" or "debt|John")
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    if (parts.length < 2) return;

    final type = parts[0];
    // final value = parts.sublist(1).join('|'); // For future: specific item navigation
    // e.g., navigate to budget category or specific debt entry

    // Navigate based on type
    switch (type) {
      case 'budget':
        // Navigate to budget page for the specific category
        // Currently opens budget sheet; could be extended to highlight category
        _navigateTo('/budget');
        break;
      case 'debt':
        // Navigate to debt page
        _navigateTo('/debt');
        break;
      case 'savings':
        // Navigate to tabungan impian page
        _navigateTo('/tabungan-impian');
        break;
      case 'achievement':
        // Navigate to achievements page
        _navigateTo('/achievements');
        break;
      case 'recurring':
        // Navigate to home page
        _navigateTo('/');
        break;
      default:
        // Unknown type, go to home
        _navigateTo('/');
    }
  }

  void _navigateTo(String path) {
    // Use GoRouter's static configuration for navigation
    // Note: This requires the app to be in a state where navigation is possible
    // For app-level navigation, we use the static appRouter
    try {
      appRouter.go(path);
    } catch (e) {
      // If router navigation fails (e.g., app not fully initialized),
      // the navigation will be skipped - this is acceptable for background notifications
      debugPrint('Deep link navigation failed: $e');
    }
  }

  // --- Toggle getters/setters ---
  Future<bool> isBudgetEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefBudget) ?? true;
  }

  Future<void> setBudgetEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefBudget, value);
  }

  Future<bool> isDebtEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefDebt) ?? true;
  }

  Future<void> setDebtEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefDebt, value);
  }

  Future<bool> isSavingsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefSavings) ?? true;
  }

  Future<void> setSavingsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefSavings, value);
  }

  Future<bool> isRecurringEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefRecurring) ?? true;
  }

  Future<void> setRecurringEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefRecurring, value);
  }

  Future<void> showBudgetWarning({
    required String kategori,
    required int percentUsed,
  }) async {
    if (!PlatformUtils.isMobile) return;
    if (!await isBudgetEnabled()) return;
    final key = 'budget_$kategori';
    if (_shownNotifKeys.contains(key)) return;
    _shownNotifKeys.add(key);

    await _plugin.show(
      'budget_$kategori'.hashCode,
      'Peringatan Budget',
      percentUsed >= 100
          ? 'Budget $kategori sudah TERKONSUMSI!'
          : 'Budget $kategori sudah $percentUsed% terpakai',
      NotificationDetails(
        android: AndroidNotificationDetails(
          budgetChannelId,
          'Budget Alerts',
          importance: percentUsed >= 100
              ? Importance.high
              : Importance.defaultImportance,
          priority: percentUsed >= 100
              ? Priority.high
              : Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'budget|$kategori',
    );
  }

  Future<void> showDebtDueReminder({
    required String namaOrang,
    required bool isUtang,
    required int daysRemaining,
  }) async {
    if (!PlatformUtils.isMobile) return;
    if (!await isDebtEnabled()) return;
    final key = 'debt_$namaOrang';
    if (_shownNotifKeys.contains(key)) return;
    _shownNotifKeys.add(key);

    final String title = isUtang
        ? 'Reminder Bayar Utang'
        : 'Reminder Terima Piutang';
    final String body = daysRemaining <= 0
        ? '$namaOrang - jatuh tempo hari ini!'
        : '$namaOrang - $daysRemaining hari lagi';

    await _plugin.show(
      key.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          debtChannelId,
          'Debt Reminders',
          importance: daysRemaining <= 0
              ? Importance.high
              : Importance.defaultImportance,
          priority: daysRemaining <= 0
              ? Priority.high
              : Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'debt|$namaOrang',
    );
  }

  Future<void> showSavingsMilestone({
    required String namaImpian,
    required int percentAchieved,
  }) async {
    if (!PlatformUtils.isMobile) return;
    if (!await isSavingsEnabled()) return;
    if (percentAchieved < 50) return;
    final key = 'savings_$namaImpian';
    if (_shownNotifKeys.contains(key)) return;
    _shownNotifKeys.add(key);

    await _plugin.show(
      key.hashCode,
      'Target Tabungan Mendekati!',
      'Tabungan "$namaImpian" sudah $percentAchieved%',
      NotificationDetails(
        android: AndroidNotificationDetails(
          savingsChannelId,
          'Savings Goals',
          importance: Importance.defaultImportance,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'savings|$namaImpian',
    );
  }

  Future<void> showSavingsComplete({required String namaImpian}) async {
    if (!PlatformUtils.isMobile) return;
    if (!await isSavingsEnabled()) return;
    final key = 'savings_done_$namaImpian';
    if (_shownNotifKeys.contains(key)) return;
    _shownNotifKeys.add(key);

    await _plugin.show(
      key.hashCode,
      'Target Tercapai!',
      'Selamat! Tabungan "$namaImpian" sudah tercapai!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          savingsChannelId,
          'Savings Goals',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'savings|$namaImpian',
    );
  }

  Future<void> showAchievementUnlocked({
    required String namaAchievement,
    required String deskripsi,
  }) async {
    if (!PlatformUtils.isMobile) return;
    await _plugin.show(
      'achievement_$namaAchievement'.hashCode,
      'Lencana Baru Terunlock!',
      '$namaAchievement - $deskripsi',
      NotificationDetails(
        android: AndroidNotificationDetails(
          achievementChannelId,
          'Achievements',
          importance: Importance.defaultImportance,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'achievement|$namaAchievement',
    );
  }

  Future<void> showRecurringAutoCreate({
    required String deskripsi,
    required double jumlah,
    required String jenis,
    required String frequencyLabel,
  }) async {
    if (!PlatformUtils.isMobile) return;
    if (!await isRecurringEnabled()) return;
    final key = 'recurring_$deskripsi';
    if (_shownNotifKeys.contains(key)) return;
    _shownNotifKeys.add(key);

    final typeLabel = jenis == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran';
    final formattedJumlah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(jumlah);

    await _plugin.show(
      key.hashCode,
      'Transaksi Otomatis Hari Ini',
      '$typeLabel $formattedJumlah "$deskripsi" ($frequencyLabel) akan dibuat otomatis',
      NotificationDetails(
        android: AndroidNotificationDetails(
          recurringChannelId,
          'Recurring Transactions',
          importance: Importance.defaultImportance,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'recurring|$deskripsi',
    );
  }

  Future<void> checkAndNotify({
    required List<dynamic> budgets,
    required Map<String, double> categorySummary,
    required List<dynamic> utangPiutangList,
    required List<dynamic> tabunganList,
  }) async {
    // Start fresh session: clear deduplication set so this call can show
    // notifications even if checkAndNotify was called before in this app session.
    _shownNotifKeys.clear();

    // 1. Budget thresholds (80%+)
    if (await isBudgetEnabled()) {
      for (final budget in budgets) {
        if ((budget.nominal as double) <= 0) continue;
        final spent = categorySummary[budget.kategori as String] ?? 0.0;
        final percentUsed = ((spent / (budget.nominal as double)) * 100)
            .round();
        if (percentUsed >= AppConfig.budgetWarningThreshold) {
          await showBudgetWarning(
            kategori: budget.kategori as String,
            percentUsed: percentUsed,
          );
        }
      }
    }

    // 2. Debt due dates (today or overdue)
    if (await isDebtEnabled()) {
      final today = DateTime.now();
      for (final utang in utangPiutangList) {
        if (utang.isLunas as bool) continue;
        if (utang.tenggatWaktu == null) continue;
        final daysLeft = (utang.tenggatWaktu as DateTime)
            .difference(today)
            .inDays;
        if (daysLeft <= AppConfig.debtReminderDaysBefore) {
          await showDebtDueReminder(
            namaOrang: utang.namaOrang as String,
            isUtang: (utang.jenis as String) == 'utang',
            daysRemaining: daysLeft,
          );
        }
      }
    }

    // 3. Savings milestones
    if (await isSavingsEnabled()) {
      for (final tabungan in tabunganList) {
        if ((tabungan.targetNominal as double) <= 0) continue;
        final percent =
            ((tabungan.terkumpul as double) /
                    (tabungan.targetNominal as double) *
                    100)
                .round();

        if (percent >= 100) {
          await showSavingsComplete(namaImpian: tabungan.namaImpian as String);
        } else if (percent >= AppConfig.savingsMilestoneThresholds[1] &&
            percent < 100) {
          await showSavingsMilestone(
            namaImpian: tabungan.namaImpian as String,
            percentAchieved: percent,
          );
        }
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
