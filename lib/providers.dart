import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/models.dart';
import 'data/database_helper.dart';
import 'config/app_config.dart';

// =============================================================================
// STATE PROVIDERS
// Lightweight notifier state — month/year selection, date picker, app startup
// =============================================================================

// Stable top-level provider — DateTime.now() is captured ONCE at app startup,
// NOT on every rebuild. This avoids infinite loading caused by a new provider
// instance being created on every widget build.
final todayNormalizedProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// ==================== DATE / MONTH PICKER STATE ====================
// Replaces setState calls in home_page.dart for tab navigation state.

class SelectedViewDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void set(DateTime? date) => state = date;
  void nextDay() =>
      state = (state ?? DateTime.now()).add(const Duration(days: 1));
  void prevDay() =>
      state = (state ?? DateTime.now()).subtract(const Duration(days: 1));
}

final selectedViewDateProvider =
    NotifierProvider<SelectedViewDateNotifier, DateTime?>(() {
      return SelectedViewDateNotifier();
    });

class SelectedMonthNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().month;

  void decrement() {
    if (state == 1) {
      state = 12;
    } else {
      state = state - 1;
    }
  }

  void increment() {
    if (state == 12) {
      state = 1;
    } else {
      state = state + 1;
    }
  }

  void setMonth(int month) => state = month;
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, int>(() {
  return SelectedMonthNotifier();
});

class SelectedYearNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().year;

  void increment() => state = state + 1;
  void decrement() => state = state - 1;
  void setYear(int year) => state = year;
}

final selectedYearProvider = NotifierProvider<SelectedYearNotifier, int>(() {
  return SelectedYearNotifier();
});

// ==================== UPDATE SIGNAL PROVIDERS ====================
// Unified signal provider — replaces separate TransaksiUpdateNotifier,
// UtangPiutangUpdateNotifier, and TabunganImpianUpdateNotifier.
// Uses a Map to track signal version for each domain. Consumers
// watch the specific domain key via ref.watch(updateSignalsProvider)[key].

class UpdateSignalsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {
    'transaksi': 0,
    'utangPiutang': 0,
    'tabungan': 0,
    'dompet': 0,
  };

  void signal(String key) {
    state = {...state, key: (state[key] ?? 0) + 1};
  }
}

final updateSignalsProvider =
    NotifierProvider<UpdateSignalsNotifier, Map<String, int>>(
      () => UpdateSignalsNotifier(),
    );

// =============================================================================
// PAGINATION STATE
// =============================================================================

// Generic pagination notifiers — used for all three pagination scopes.
// Replaces separate TransaksiPageNotifier, BulananPageNotifier,
// PerTanggalPageNotifier (and their Size counterparts) with one class.

class PaginationNotifier extends Notifier<int> {
  final int initialPage;
  PaginationNotifier({this.initialPage = 1});

  @override
  int build() => initialPage;
  void reset() => state = initialPage;
  void increment() => state++;
}

class PaginationSizeNotifier extends Notifier<int> {
  final int initialSize;
  PaginationSizeNotifier({this.initialSize = AppConfig.defaultPageSize});

  @override
  int build() => initialSize;
}

// ==================== TRANSAKSI PAGINATION ====================
final transaksiPageProvider = NotifierProvider<PaginationNotifier, int>(
  () => PaginationNotifier(),
);
final transaksiPageSizeProvider = NotifierProvider<PaginationSizeNotifier, int>(
  () => PaginationSizeNotifier(),
);

final paginatedTransaksiProvider = FutureProvider.autoDispose<List<Transaksi>>((
  ref,
) async {
  final page = ref.watch(transaksiPageProvider);
  final pageSize = ref.watch(transaksiPageSizeProvider);
  final offset = (page - 1) * pageSize;
  return await DatabaseHelper.instance.transaksiDao.getTransaksiPaginated(
    limit: pageSize,
    offset: offset,
  );
});

final hasMoreTransaksiProvider = FutureProvider.autoDispose<bool>((ref) async {
  final page = ref.watch(transaksiPageProvider);
  final pageSize = ref.watch(transaksiPageSizeProvider);
  final offset = (page - 1) * pageSize;
  final total = await DatabaseHelper.instance.transaksiDao
      .getTotalTransaksiCount();
  return (offset + pageSize) < total;
});

// ==================== BULANAN PAGINATION ====================
final bulananPageProvider = NotifierProvider<PaginationNotifier, int>(
  () => PaginationNotifier(),
);
final bulananPageSizeProvider = NotifierProvider<PaginationSizeNotifier, int>(
  () => PaginationSizeNotifier(),
);

// ==================== DOMPET FILTER ====================
// null = Semua Dompet, int = filter by specific dompet id
class SelectedDompetFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? id) => state = id;
  void reset() => state = null;
}

final selectedDompetFilterProvider =
    NotifierProvider<SelectedDompetFilterNotifier, int?>(() {
      return SelectedDompetFilterNotifier();
    });

final paginatedTransaksiByMonthProvider = FutureProvider.autoDispose
    .family<List<Transaksi>, ({int bulan, int tahun})>((ref, params) async {
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      final page = ref.watch(bulananPageProvider);
      final pageSize = ref.watch(bulananPageSizeProvider);
      final dompetFilter = ref.watch(selectedDompetFilterProvider);
      final offset = (page - 1) * pageSize;
      return await DatabaseHelper.instance.transaksiDao
          .getTransaksiByMonthPaginated(
            params.tahun,
            params.bulan,
            idDompet: dompetFilter,
            limit: pageSize,
            offset: offset,
          );
    });

final hasMoreBulananProvider = FutureProvider.autoDispose
    .family<bool, ({int bulan, int tahun})>((ref, params) async {
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      final page = ref.watch(bulananPageProvider);
      final pageSize = ref.watch(bulananPageSizeProvider);
      final dompetFilter = ref.watch(selectedDompetFilterProvider);
      final offset = (page - 1) * pageSize;
      final total = await DatabaseHelper.instance.transaksiDao
          .getTransaksiCount(
            tahun: params.tahun,
            bulan: params.bulan,
            idDompet: dompetFilter,
          );
      return (offset + pageSize) < total;
    });

// ==================== PER-TANGGAL PAGINATION ====================
final perTanggalPageProvider = NotifierProvider<PaginationNotifier, int>(
  () => PaginationNotifier(),
);
final perTanggalPageSizeProvider =
    NotifierProvider<PaginationSizeNotifier, int>(
      () => PaginationSizeNotifier(),
    );

final paginatedTransaksiByDateProvider = FutureProvider.autoDispose
    .family<List<Transaksi>, DateTime>((ref, date) async {
      // Watch both the pagination state AND the update signal.
      // - perTanggalPageProvider: ensures refetch when page resets/changes (fixes Per Tanggal tab not updating on date change)
      // - updateSignalsProvider.select(): ensures refetch when transactions change
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      final page = ref.watch(perTanggalPageProvider);
      final pageSize = ref.watch(perTanggalPageSizeProvider);
      final offset = (page - 1) * pageSize;
      return await DatabaseHelper.instance.transaksiDao
          .getTransaksiByDatePaginated(date, limit: pageSize, offset: offset);
    });

final hasMorePerTanggalProvider = FutureProvider.autoDispose
    .family<bool, DateTime>((ref, date) async {
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      final page = ref.watch(perTanggalPageProvider);
      final pageSize = ref.watch(perTanggalPageSizeProvider);
      final offset = (page - 1) * pageSize;
      final total = await DatabaseHelper.instance.transaksiDao
          .getTransaksiCountByDate(date);
      return (offset + pageSize) < total;
    });

// =============================================================================
// DATA PROVIDERS
// CRUD and data-fetching providers per domain
// =============================================================================

// ==================== TRANSAKSI ====================
class TransaksiNotifier extends AsyncNotifier<List<Transaksi>> {
  @override
  Future<List<Transaksi>> build() async {
    return await DatabaseHelper.instance.getAllTransaksi();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => DatabaseHelper.instance.getAllTransaksi(),
    );
  }

  Future<void> insert(Transaksi tx) async {
    await DatabaseHelper.instance.insertTransaksi(tx);
    ref.read(updateSignalsProvider.notifier).signal('transaksi');
    await refresh();
  }

  Future<void> updateTransaksi(Transaksi tx) async {
    await DatabaseHelper.instance.updateTransaksi(tx);
    ref.read(updateSignalsProvider.notifier).signal('transaksi');
    await refresh();
  }

  Future<void> delete(int id) async {
    await DatabaseHelper.instance.softDeleteTransaksi(id);
    ref.read(updateSignalsProvider.notifier).signal('transaksi');
    await refresh();
  }

  Future<void> restore(int id) async {
    await DatabaseHelper.instance.restoreTransaksi(id);
    ref.read(updateSignalsProvider.notifier).signal('transaksi');
    await refresh();
  }

  Future<void> permanentDelete(int id) async {
    await DatabaseHelper.instance.permanentDeleteTransaksi(id);
    ref.read(updateSignalsProvider.notifier).signal('transaksi');
    await refresh();
  }
}

final transaksiProvider =
    AsyncNotifierProvider<TransaksiNotifier, List<Transaksi>>(() {
      return TransaksiNotifier();
    });

final deletedTransaksiProvider = FutureProvider<List<Transaksi>>((ref) async {
  return await DatabaseHelper.instance.getDeletedTransaksi();
});

// ==================== TRANSACTION HELPERS ====================
// Depends on transaksi update signal to refresh when data changes.

final transaksiByDateProvider =
    FutureProvider.family<List<Transaksi>, DateTime>((ref, date) async {
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      return await DatabaseHelper.instance.getTransaksiByDate(date);
    });

final transaksiByMonthProvider =
    FutureProvider.family<List<Transaksi>, ({int bulan, int tahun})>((
      ref,
      params,
    ) async {
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      return await DatabaseHelper.instance.getTransaksiByMonth(
        params.tahun,
        params.bulan,
      );
    });

// ==================== ACTIVE PROFIL ====================

class ActiveProfilNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void setProfil(int profilId) {
    state = profilId;
    // Signal all domains to refresh when profile changes
    ref.read(updateSignalsProvider.notifier).signal('transaksi');
    ref.read(updateSignalsProvider.notifier).signal('dompet');
  }
}

final activeProfilProvider = NotifierProvider<ActiveProfilNotifier, int>(() {
  return ActiveProfilNotifier();
});

final profilListProvider = FutureProvider<List<Profil>>((ref) async {
  ref.watch(activeProfilProvider);
  return await DatabaseHelper.instance.getAllProfil();
});

// ==================== DOMPET ====================
class DompetNotifier extends AsyncNotifier<List<Dompet>> {
  @override
  Future<List<Dompet>> build() async {
    ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
    // Filter dompet by active profil
    final profilId = ref.watch(activeProfilProvider);
    return await DatabaseHelper.instance.getAllDompet(profilId: profilId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final profilId = ref.read(activeProfilProvider);
    state = await AsyncValue.guard(
      () => DatabaseHelper.instance.getAllDompet(profilId: profilId),
    );
  }

  Future<void> insert(Dompet dompet) async {
    final profilId = ref.read(activeProfilProvider);
    final withProfil = dompet.copyWith(profilId: profilId);
    await DatabaseHelper.instance.insertDompet(withProfil);
    await refresh();
  }

  Future<void> delete(int id) async {
    await DatabaseHelper.instance.deleteDompet(id);
    await refresh();
  }
}

final dompetProvider = AsyncNotifierProvider<DompetNotifier, List<Dompet>>(() {
  return DompetNotifier();
});

// ==================== KATEGORI ====================
final kategoriProvider = FutureProvider<List<Kategori>>((ref) async {
  return await DatabaseHelper.instance.getAllKategori();
});

final kategoriByJenisProvider = FutureProvider.family<List<Kategori>, String>((
  ref,
  jenis,
) async {
  return await DatabaseHelper.instance.getKategoriByJenis(jenis);
});

// ==================== BUDGET ====================
final budgetListProvider = FutureProvider.autoDispose
    .family<List<Budget>, ({int bulan, int tahun})>((ref, params) async {
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      ref.watch(bulananPageProvider);
      final profilId = ref.watch(activeProfilProvider);
      return await DatabaseHelper.instance.getAllBudget(
        params.bulan,
        params.tahun,
        profilId: profilId,
      );
    });

final categorySummaryProvider = FutureProvider.autoDispose
    .family<Map<String, double>, ({int bulan, int tahun})>((ref, params) async {
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      ref.watch(bulananPageProvider);
      ref.watch(activeProfilProvider);
      return await DatabaseHelper.instance.getCategorySummary(
        params.tahun,
        params.bulan,
      );
    });

final monthlySummaryProvider = FutureProvider.autoDispose
    .family<Map<String, double>, ({int bulan, int tahun})>((ref, params) async {
      ref.watch(selectedMonthProvider);
      ref.watch(selectedYearProvider);
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      ref.watch(bulananPageProvider);
      ref.watch(activeProfilProvider);
      final dompetFilter = ref.watch(selectedDompetFilterProvider);
      return await DatabaseHelper.instance.getMonthlySummary(
        params.tahun,
        params.bulan,
        idDompet: dompetFilter,
      );
    });

// ==================== UTANG PIUTANG ====================
final utangPiutangListProvider = FutureProvider<List<UtangPiutang>>((
  ref,
) async {
  ref.watch(updateSignalsProvider.select((s) => s['utangPiutang']));
  return await DatabaseHelper.instance.getAllUtangPiutang();
});

final historyCicilanProvider = FutureProvider.family<List<HistoryCicilan>, int>(
  (ref, idUtang) async {
    ref.watch(updateSignalsProvider.select((s) => s['utangPiutang']));
    return await DatabaseHelper.instance.getHistoryCicilan(idUtang);
  },
);

// ==================== TABUNGAN IMPIAN ====================
final tabunganImpianListProvider = FutureProvider<List<TabunganImpian>>((
  ref,
) async {
  ref.watch(updateSignalsProvider.select((s) => s['tabungan']));
  return await DatabaseHelper.instance.getAllTabunganImpian();
});

// ==================== PENGATURAN ====================
class PengaturanNotifier extends Notifier<Pengaturan> {
  @override
  Pengaturan build() {
    _load();
    return Pengaturan(id: 1, isDarkMode: false);
  }

  Future<void> _load() async {
    state = await DatabaseHelper.instance.getPengaturan();
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await DatabaseHelper.instance.updatePengaturan(state);
  }

  Future<void> toggleBiometric() async {
    state = state.copyWith(useBiometric: !state.useBiometric);
    await DatabaseHelper.instance.updatePengaturan(state);
  }
}

final pengaturanProvider = NotifierProvider<PengaturanNotifier, Pengaturan>(() {
  return PengaturanNotifier();
});

// =============================================================================
// COMPUTED / FAMILY PROVIDERS
// Derived values and parameterized providers
// =============================================================================

// ==================== CASHFLOW PREDICTION ====================

/// Holds the result of cashflow analysis for a given month.
class CashflowPrediction {
  /// Average daily expense for the month (Rp).
  final double rataRataHarian;

  /// How many days the current balance can last at the current burn rate.
  final double estimasiHariTersisa;

  /// True if the predicted remaining days exceeds the actual calendar
  /// days left in the month — the user is "safe" financially.
  final bool statusAman;

  /// Total current balance across all dompet (Rp).
  final double saldoSaatIni;

  /// Number of days elapsed so far this month.
  final int hariBerlalu;

  /// Total days in the target month.
  final int totalHariBulan;

  CashflowPrediction({
    required this.rataRataHarian,
    required this.estimasiHariTersisa,
    required this.statusAman,
    required this.saldoSaatIni,
    required this.hariBerlalu,
    required this.totalHariBulan,
  });
}

final cashflowPredictionProvider = FutureProvider.autoDispose
    .family<CashflowPrediction, ({int tahun, int bulan})>((ref, params) async {
      final now = DateTime.now();

      // 1. Aggregate current balance from all dompet of active profil.
      // Watch activeProfilProvider so cashflow re-computes on profile switch.
      final profilId = ref.watch(activeProfilProvider);
      final dompets = await DatabaseHelper.instance.getAllDompet(
        profilId: profilId,
      );
      final saldoSaatIni = dompets.fold<double>(0, (sum, d) => sum + d.saldo);

      // 2. Fetch average daily expense from DAO.
      final rataRataHarian = await DatabaseHelper.instance.transaksiDao
          .getAverageDailyExpense(params.tahun, params.bulan);

      // 3. Compute how many days the current balance can last.
      final estimasiHariTersisa = rataRataHarian > 0
          ? saldoSaatIni / rataRataHarian
          : 0.0;

      // 4. Determine "safe" status: predicted remaining days > calendar days left.
      final int hariBerlalu;
      final int totalHariBulan = DateTime(
        params.tahun,
        params.bulan + 1,
        0,
      ).day;
      final int hariSisaKalender;

      if (now.year == params.tahun && now.month == params.bulan) {
        hariBerlalu = now.day;
        hariSisaKalender = totalHariBulan - now.day;
      } else {
        // For past or future months, treat all days as "remaining".
        hariBerlalu = totalHariBulan;
        hariSisaKalender = totalHariBulan;
      }

      // Safe if estimated remaining days exceed actual calendar days left.
      final statusAman = estimasiHariTersisa > hariSisaKalender;

      return CashflowPrediction(
        rataRataHarian: rataRataHarian,
        estimasiHariTersisa: estimasiHariTersisa,
        statusAman: statusAman,
        saldoSaatIni: saldoSaatIni,
        hariBerlalu: hariBerlalu,
        totalHariBulan: totalHariBulan,
      );
    });

// ==================== USER LEVEL (GAMIFIKASI) ====================

class UserLevel {
  final String levelName;
  final int levelIndex; // 0=Pemula, 1=Pencatat Rutin, 2=Master Keuangan
  final int transaksiCount;
  final int transaksiMenujuLevelBerikut;
  final double progressPercent;

  UserLevel({
    required this.levelName,
    required this.levelIndex,
    required this.transaksiCount,
    required this.transaksiMenujuLevelBerikut,
    required this.progressPercent,
  });
}

final userLevelProvider = FutureProvider<UserLevel>((ref) async {
  // Reactive: re-compute when any transaksi CRUD happens (add/edit/delete/restore)
  ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
  final count = await DatabaseHelper.instance.transaksiDao
      .getTotalTransaksiCount();

  if (count < 50) {
    final progress = count / 50;
    return UserLevel(
      levelName: 'Pemula',
      levelIndex: 0,
      transaksiCount: count,
      transaksiMenujuLevelBerikut: 50 - count,
      progressPercent: progress,
    );
  } else if (count < 150) {
    final progress = (count - 50) / 100;
    return UserLevel(
      levelName: 'Pencatat Rutin',
      levelIndex: 1,
      transaksiCount: count,
      transaksiMenujuLevelBerikut: 150 - count,
      progressPercent: progress,
    );
  } else {
    return UserLevel(
      levelName: 'Master Keuangan',
      levelIndex: 2,
      transaksiCount: count,
      transaksiMenujuLevelBerikut: 0,
      progressPercent: 1.0,
    );
  }
});

// ==================== COMPUTED PROFIL ====================

/// Computed provider for active profil ID.
/// Watches activeProfilProvider and returns the value directly.
final computedActiveProfilIdProvider = Provider<int>((ref) {
  return ref.watch(activeProfilProvider);
});

/// Computed provider for whether dark mode is enabled.
/// Uses select() to only rebuild when isDarkMode changes.
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(pengaturanProvider.select((p) => p.isDarkMode));
});

// ==================== COMPUTED TRANSAKSI ====================

/// Computed provider for total transaction count.
final computedTotalTransaksiCountProvider = FutureProvider<int>((ref) async {
  ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
  return await DatabaseHelper.instance.transaksiDao.getTotalTransaksiCount();
});

/// Computed provider for whether there are any transactions.
final hasTransactionsProvider = FutureProvider<bool>((ref) async {
  final count = await ref.watch(computedTotalTransaksiCountProvider.future);
  return count > 0;
});

// ==================== COMPUTED DOMPET ====================

/// Computed provider for total saldo across all dompet of active profil.
/// Uses select() to minimize rebuilds.
final computedTotalSaldoProvider = FutureProvider<double>((ref) async {
  ref.watch(updateSignalsProvider.select((s) => s['dompet']));
  ref.watch(activeProfilProvider);
  final dompets = await DatabaseHelper.instance.getAllDompet(
    profilId: ref.watch(activeProfilProvider),
  );
  return dompets.fold<double>(0, (sum, d) => sum + d.saldo);
});

/// Computed provider for dompet by ID.
/// Returns null if not found.
final dompetByIdProvider = FutureProvider.family<Dompet?, int>((ref, id) async {
  ref.watch(updateSignalsProvider.select((s) => s['dompet']));
  final dompets = await DatabaseHelper.instance.getAllDompet();
  return dompets.where((d) => d.id == id).firstOrNull;
});

// ==================== SMART RECEIPT (GAMIFIKASI) ====================

/// Returns transaksi list for a given year/month where lampiran is not empty.
/// Filters by active profil via dompet scoping.
final smartReceiptProvider = FutureProvider.autoDispose
    .family<List<Transaksi>, ({int tahun, int bulan})>((ref, params) async {
      ref.watch(updateSignalsProvider.select((s) => s['transaksi']));
      ref.watch(activeProfilProvider);
      final allTransaksi = await DatabaseHelper.instance.getTransaksiByMonth(
        params.tahun,
        params.bulan,
      );
      return allTransaksi.where((t) => t.lampiran.isNotEmpty).toList();
    });
