import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers.dart';
import '../../services/recurring_scheduler.dart';
import '../../services/budget_alert_service.dart';
import '../actions/tambah_transaksi_sheet.dart';
import '../actions/transaksi_search_delegate.dart';

// Tabs
import '../../widgets/tab_hari_ini.dart';
import '../tabs/tab_per_tanggal.dart';
import '../tabs/tab_bulanan.dart';
import '../tabs/tab_lainnya.dart';
import '../tabs/tab_dashboard.dart';
import '../../theme/theme.dart';
import '../../widgets/glass_menu_bottom_sheet.dart';

// ==================== GLASS ICON BUTTON ====================
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// ==================== HOME PAGE ====================
class HomePage extends ConsumerStatefulWidget {
  final String? quickAddType;

  const HomePage({super.key, this.quickAddType});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int _headerTapCount = 0;
  DateTime? _headerLastTapTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    // Show quick-add sheet if launched from widget
    if (widget.quickAddType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTambahTransaksi(prefillType: widget.quickAddType);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.microtask(() {
        ref.invalidate(todayNormalizedProvider);
        // Reset selected date so "Tambah Transaksi" picks up today's date
        // instead of a stale previously-selected calendar date.
        ref.read(selectedViewDateProvider.notifier).set(null);
        ref.read(selectedYearProvider.notifier).setYear(DateTime.now().year);
        ref.read(selectedMonthProvider.notifier).setMonth(DateTime.now().month);
        RecurringScheduler.instance.checkAndCreateRecurring();
        BudgetAlertService.instance.checkBudgetAlerts();
      });
    }
  }

  void _handleHeaderTap() {
    final now = DateTime.now();
    if (_headerLastTapTime != null &&
        now.difference(_headerLastTapTime!).inMilliseconds > 500) {
      _headerTapCount = 0;
    }
    _headerTapCount++;
    _headerLastTapTime = now;
    if (_headerTapCount >= 3) {
      _headerTapCount = 0;
      ref.read(pengaturanProvider.notifier).toggleDarkMode();
      HapticFeedback.mediumImpact();
      final isDark = Theme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDark ? 'Dark mode enabled' : 'Dark mode disabled',
            style: const TextStyle(fontFamily: 'PlusJakartaSans'),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showSearch() async {
    final result = await showSearch<Transaksi?>(
      context: context,
      delegate: TransaksiSearchDelegate(),
    );
    if (result != null && context.mounted) {
      showEditTransaksiSheet(
        context,
        result,
        onSave: () {
          ref.read(updateSignalsProvider.notifier).signal('transaksi');
          ref.invalidate(transaksiProvider);
          ref.invalidate(dompetProvider);
        },
      );
    }
  }

  void _showTambahTransaksi({String? prefillType}) {
    final tanggalAwal = ref.read(selectedViewDateProvider) ?? DateTime.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Consumer(
          builder: (ctx, sheetRef, _) => TambahTransaksiSheet(
            selectedDate: tanggalAwal,
            prefillType: prefillType,
            onSave: () {
              sheetRef.read(updateSignalsProvider.notifier).signal('transaksi');
              sheetRef.invalidate(transaksiProvider);
              sheetRef.invalidate(dompetProvider);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pengaturan = ref.watch(pengaturanProvider);
    final isDarkMode = pengaturan.isDarkMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF0D2818),
                        const Color(0xFF1B5E20),
                        const Color(0xFF2E7D32).withValues(alpha: 0.3),
                      ]
                    : [
                        const Color(0xFF14532D),
                        const Color(0xFF166534),
                        const Color(0xFF15803D),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _handleHeaderTap,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'DompetKu',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _GlassIconButton(
                        icon: isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        tooltip: isDarkMode ? 'Mode Terang' : 'Mode Gelap',
                        onPressed: () => ref
                            .read(pengaturanProvider.notifier)
                            .toggleDarkMode(),
                      ),
                      _GlassIconButton(
                        icon: Icons.search_rounded,
                        tooltip: 'Cari Transaksi',
                        onPressed: _showSearch,
                      ),
                      _GlassIconButton(
                        icon: Icons.more_vert_rounded,
                        tooltip: 'Menu',
                        onPressed: () => showGlassMenu(context, ref),
                      ),
                    ],
                  ),
                ),
                _buildCustomTabBar(),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TabHariIni(),
                TabPerTanggal(),
                TabBulanan(),
                TabLainnya(),
                TabDashboard(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.emerald : AppColors.primaryMid)
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showTambahTransaksi,
          elevation: 0,
          tooltip: 'Tambah Transaksi',
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Semantics(
      label: 'Tab navigasi utama',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          indicator: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(4),
          tabs: [
            Tab(
              child: Semantics(
                label: 'Tab Hari Ini',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.today_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Hari Ini',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Tab Per Tanggal',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Per Tanggal',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Tab Bulanan',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.calendar_view_month_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Bulanan',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Tab Lainnya',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.more_horiz_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Lainnya',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Tab Dashboard',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.dashboard_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
