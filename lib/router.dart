import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/core/home_page.dart';
import 'pages/settings_security/settings_page.dart';
import 'pages/reports_stats/statistik_page.dart';
import 'pages/debts/utang_piutang_page.dart';
import 'pages/budget_savings/tabungan_impian_page.dart';
import 'pages/budget_savings/budget_sheet.dart';
import 'pages/gamification/achievement_page.dart';
import 'pages/settings_security/backup_restore_page.dart';

/// App router configuration with deep linking support.
///
/// Deep link scheme: `catatankeuangan://` or `https://catatankeuangan.app/`
///
/// Supported routes:
///   /                    → HomePage
///   /settings            → SettingsPage
///   /statistik           → StatistikPage
///   /transaksi/:id       → (future: detail page)
///   /budget              → BudgetSheet (current month/year)
///   /reports             → StatistikPage (alias for /statistik)
///   /debt                → UtangPiutangPage
///   /dompet              → (future: dompet management)
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        final quickadd = state.uri.queryParameters['quickadd'];
        return HomePage(quickAddType: quickadd);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/backup-restore',
      name: 'backup-restore',
      builder: (context, state) => const BackupRestorePage(),
    ),
    GoRoute(
      path: '/statistik',
      name: 'statistik',
      builder: (context, state) {
        final tahun = int.tryParse(state.uri.queryParameters['tahun'] ?? '');
        final bulan = int.tryParse(state.uri.queryParameters['bulan'] ?? '');
        return StatistikPage(
          tahun: tahun ?? DateTime.now().year,
          bulan: bulan ?? DateTime.now().month,
        );
      },
    ),
    // Alias for /statistik - reports page
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) {
        final tahun = int.tryParse(state.uri.queryParameters['tahun'] ?? '');
        final bulan = int.tryParse(state.uri.queryParameters['bulan'] ?? '');
        return StatistikPage(
          tahun: tahun ?? DateTime.now().year,
          bulan: bulan ?? DateTime.now().month,
        );
      },
    ),
    GoRoute(
      path: '/utang-piutang',
      name: 'utang-piutang',
      builder: (context, state) => const UtangPiutangPage(),
    ),
    // Alias for /utang-piutang - debt page
    GoRoute(
      path: '/debt',
      name: 'debt',
      builder: (context, state) => const UtangPiutangPage(),
    ),
    GoRoute(
      path: '/tabungan-impian',
      name: 'tabungan-impian',
      builder: (context, state) => const TabunganImpianPage(),
    ),
    // Budget management page (current month/year)
    GoRoute(
      path: '/budget',
      name: 'budget',
      builder: (context, state) {
        final tahun = int.tryParse(state.uri.queryParameters['tahun'] ?? '');
        final bulan = int.tryParse(state.uri.queryParameters['bulan'] ?? '');
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: BudgetSheet(
            tahun: tahun ?? DateTime.now().year,
            bulan: bulan ?? DateTime.now().month,
          ),
        );
      },
    ),
    GoRoute(
      path: '/achievements',
      name: 'achievements',
      builder: (context, state) => const AchievementPage(),
    ),
    // Future: Transaction detail page
    // GoRoute(
    //   path: '/transaksi/:id',
    //   name: 'transaksi-detail',
    //   builder: (context, state) {
    //     final id = int.tryParse(state.pathParameters['id'] ?? '');
    //     return TransaksiDetailPage(transactionId: id);
    //   },
    // ),
  ],
  redirect: (context, state) {
    // Handle deep link redirects if needed
    // For example, redirect root to specific locale version
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Halaman tidak ditemukan: ${state.uri.path}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    ),
  ),
);
