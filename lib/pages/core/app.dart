import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catatan_keuangan/l10n/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../data/database_helper.dart';
import '../../services/home_widget_service.dart';
import '../../services/notification_service.dart';
import '../../services/recurring_scheduler.dart';
import '../../theme/theme.dart';
import 'home_page.dart';
import '../settings_security/pin_lock_screen.dart';

// Re-export theme classes and utilities for backward compatibility
export '../../theme/theme.dart';
export '../../utils/formatters.dart';
export '../../widgets/common/glass_container.dart';
export '../../widgets/common/glass_button.dart';
export '../../widgets/common/animated_currency_text.dart';

// ==================== APP ROOT ====================
class CatatanKeuanganApp extends ConsumerStatefulWidget {
  const CatatanKeuanganApp({super.key});

  @override
  ConsumerState<CatatanKeuanganApp> createState() => _CatatanKeuanganAppState();
}

class _CatatanKeuanganAppState extends ConsumerState<CatatanKeuanganApp>
    with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _pinConfigured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPin();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _pinConfigured) {
      setState(() => _isLocked = true);
    }
  }

  Future<void> _checkPin() async {
    final pengaturan = await DatabaseHelper.instance.getPengaturan();
    setState(() {
      _pinConfigured = pengaturan.pin != null && pengaturan.pin!.isNotEmpty;
      _isLocked = _pinConfigured;
    });
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    final pengaturan = ref.watch(pengaturanProvider);

    return MaterialApp.router(
      title: 'DompetKu',
      debugShowCheckedModeBanner: false,
      themeMode: pengaturan.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      localeResolutionCallback: (locale, supportedLocales) {
        // Default to Indonesian; could be extended to respect system locale
        return const Locale('id', 'ID');
      },
      builder: (context, child) {
        // Lock screen overlay on top of all routes
        if (_isLocked) {
          return PinLockScreen(onUnlocked: _onUnlocked);
        }
        return child ?? const _AppHome();
      },
    );
  }
}

class _AppHome extends ConsumerStatefulWidget {
  const _AppHome();

  @override
  ConsumerState<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends ConsumerState<_AppHome> {
  @override
  void initState() {
    super.initState();
    // Listen for transaction changes and update home widget
    ref.listen(transaksiProvider, (prev, next) {
      next.whenData((transactions) {
        _updateHomeWidget(transactions);
      });
    });

    // Trigger notification check on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotifications();
      _checkRecurringOnResume();
    });
  }

  Future<void> _updateHomeWidget(List transactions) async {
    try {
      final now = DateTime.now();
      double totalPemasukan = 0;
      double totalPengeluaran = 0;

      for (var t in transactions) {
        if (t.deletedAt != null) continue;
        if (t.tanggal.year == now.year && t.tanggal.month == now.month) {
          if (t.jenis == 'pemasukan') {
            totalPemasukan += t.jumlah;
          } else {
            totalPengeluaran += t.jumlah;
          }
        }
      }

      final totalSaldo = totalPemasukan - totalPengeluaran;
      await HomeWidgetService.updateWidget(
        totalSaldo: totalSaldo,
        totalPemasukan: totalPemasukan,
        totalPengeluaran: totalPengeluaran,
      );
    } catch (e) {
      // Silently fail - widget update is non-critical
    }
  }

  Future<void> _checkNotifications() async {
    try {
      final now = DateTime.now();
      final budgets = await DatabaseHelper.instance.getAllBudget(
        now.month,
        now.year,
      );
      final summary = await DatabaseHelper.instance.getCategorySummary(
        now.year,
        now.month,
      );
      final utangList = await DatabaseHelper.instance.getAllUtangPiutang();
      final tabunganList = await DatabaseHelper.instance.getAllTabunganImpian();

      await NotificationService.instance.checkAndNotify(
        budgets: budgets,
        categorySummary: summary,
        utangPiutangList: utangList,
        tabunganList: tabunganList,
      );
    } catch (e) {
      // Don't crash the app if notification check fails
      debugPrint('Notification check failed: $e');
    }
  }

  Future<void> _checkRecurringOnResume() async {
    try {
      final created = await RecurringScheduler.instance
          .checkAndCreateRecurring();
      if (created > 0 && mounted) {
        await ref.read(transaksiProvider.notifier).refresh();
        ref.read(updateSignalsProvider.notifier).signal('transaksi');
      }
    } catch (e) {
      debugPrint('Recurring scheduler check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
