import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/staggered_list_item.dart';
import '../../widgets/transaksi_item_card.dart';
import '../../data/database_helper.dart';
import 'shared_tab_widgets.dart';

class TabPerTanggal extends ConsumerStatefulWidget {
  const TabPerTanggal({super.key});

  @override
  ConsumerState<TabPerTanggal> createState() => _TabPerTanggalState();
}

class _TabPerTanggalState extends ConsumerState<TabPerTanggal>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // Use the provider's selected date if available, else today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDate = ref.read(selectedViewDateProvider);
      if (selectedDate != null) {
        setState(() => _focusedDay = selectedDate);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final selectedDate =
          ref.read(selectedViewDateProvider) ??
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
      final hasMore =
          ref.read(hasMorePerTanggalProvider(selectedDate)).value ?? false;
      if (hasMore) {
        ref.read(perTanggalPageProvider.notifier).increment();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final now = DateTime.now();
    final selectedDate =
        ref.watch(selectedViewDateProvider) ??
        DateTime(now.year, now.month, now.day);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch this month's data to display markers
    final monthlyTxAsync = ref.watch(
      transaksiByMonthProvider((
        bulan: _focusedDay.month,
        tahun: _focusedDay.year,
      )),
    );
    final dailyTxAsync = ref.watch(
      paginatedTransaksiByDateProvider(selectedDate),
    );
    final hasMoreAsync = ref.watch(hasMorePerTanggalProvider(selectedDate));

    Map<DateTime, List<Transaksi>> groupedTx = {};
    if (monthlyTxAsync.hasValue) {
      for (var tx in monthlyTxAsync.value!) {
        if (tx.deletedAt != null) continue;
        final d = DateTime(tx.tanggal.year, tx.tanggal.month, tx.tanggal.day);
        if (!groupedTx.containsKey(d)) groupedTx[d] = [];
        groupedTx[d]!.add(tx);
      }
    }

    return Column(
      children: [
        GlassContainer(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(8),
          child: TableCalendar<Transaksi>(
            locale: 'id_ID',
            firstDay: DateTime(2020),
            lastDay: DateTime(2050),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Sebulan',
              CalendarFormat.twoWeeks: '2 Minggu',
              CalendarFormat.week: 'Seminggu',
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() => _focusedDay = focusedDay);
              ref.read(selectedViewDateProvider.notifier).set(selectedDay);
              ref.read(perTanggalPageProvider.notifier).reset();
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
            eventLoader: (day) {
              final d = DateTime(day.year, day.month, day.day);
              return groupedTx[d] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox();
                bool hasIncome = events.any((e) => e.jenis == 'pemasukan');
                bool hasExpense = events.any((e) => e.jenis == 'pengeluaran');
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasIncome)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.emerald,
                          ),
                        ),
                      if (hasExpense)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.coral,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primaryMid,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryMid.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                color: isDark ? AppColors.coralLight : AppColors.coral,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              formatButtonTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              formatButtonDecoration: BoxDecoration(
                color: AppColors.primaryMid,
                borderRadius: BorderRadius.circular(12),
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? Colors.white : Colors.black87,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              weekendStyle: TextStyle(
                color: isDark ? AppColors.coralLight : AppColors.coral,
              ),
            ),
          ),
        ),

        // Header Transaksi Harian
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi ${DateFormat('d MMM yyyy', 'id_ID').format(selectedDate)}',
                style: AppTypography.titleMedium(context),
              ),
            ],
          ),
        ),

        Expanded(
          child: dailyTxAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => buildErrorWidget(e.toString()),
            data: (transaksi) {
              if (transaksi.isEmpty) {
                return buildEmptyState(
                  context,
                  Icons.event_busy_rounded,
                  'Tidak ada transaksi pada\nhari ini',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(
                  paginatedTransaksiByDateProvider(selectedDate),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: transaksi.length + 1,
                  itemBuilder: (context, index) {
                    if (index == transaksi.length) {
                      return hasMoreAsync.when(
                        data: (hasMore) => hasMore
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(height: 0),
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (_, __) => const SizedBox(height: 0),
                      );
                    }
                    return StaggeredListItem(
                      index: index,
                      child: TransaksiItemCard(
                        transaksi: transaksi[index],
                        onDismissed: () async {
                          final tx = transaksi[index];
                          final id = tx.id;
                          if (id != null) {
                            await DatabaseHelper.instance.softDeleteTransaksi(id);
                            ref.read(updateSignalsProvider.notifier).signal('transaksi');
                            ref.invalidate(transaksiProvider);
                            ref.invalidate(dompetProvider);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Transaksi "${tx.deskripsi.isEmpty ? tx.kategori : tx.deskripsi}" dihapus'),
                                  action: SnackBarAction(
                                    label: 'BATAL',
                                    onPressed: () async {
                                      await DatabaseHelper.instance.restoreTransaksi(id);
                                      ref.read(updateSignalsProvider.notifier).signal('transaksi');
                                      ref.invalidate(transaksiProvider);
                                      ref.invalidate(dompetProvider);
                                    },
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
