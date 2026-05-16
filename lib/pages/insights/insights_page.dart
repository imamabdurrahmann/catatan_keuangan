import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers.dart';
import '../../theme/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/glass_container.dart';
import '../tabs/shared_tab_widgets.dart';

class InsightsPage extends ConsumerStatefulWidget {
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends ConsumerState<InsightsPage> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final params = (bulan: _selectedMonth, tahun: _selectedYear);
    final predictionAsync = ref.watch(cashflowPredictionProvider(params));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.gold,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Smart Insights',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ─── Bulan/Tahun Navigator ───
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCardElevated.withValues(alpha: 0.5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DateNavBtn(
                  icon: Icons.chevron_left_rounded,
                  onPressed: () => _navigateMonth(-1),
                ),
                GestureDetector(
                  onTap: _pickMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat(
                            'MMMM yyyy',
                            'id_ID',
                          ).format(DateTime(_selectedYear, _selectedMonth)),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                _DateNavBtn(
                  icon: Icons.chevron_right_rounded,
                  onPressed: () => _navigateMonth(1),
                ),
              ],
            ),
          ),

          // ─── Content ───
          Expanded(
            child: predictionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  buildErrorWidget('Gagal memuat data: $err'),
              data: (prediction) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  // ─── Card 1: Saldo & Rata-rata Harian ───
                  _SaldoCard(prediction: prediction),

                  const SizedBox(height: 16),

                  // ─── Card 2: Prediksi Hari Tersisa & Status ───
                  _PrediksiCard(prediction: prediction),

                  const SizedBox(height: 16),

                  // ─── Card 3: Info Tambahan ───
                  _InfoCard(prediction: prediction),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked.month;
        _selectedYear = picked.year;
      });
    }
  }
}

// ==================== Date Navigation Button ====================
class _DateNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _DateNavBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ==================== Card 1: Saldo & Rata-rata Harian ====================
class _SaldoCard extends StatelessWidget {
  final CashflowPrediction prediction;

  const _SaldoCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ringkasan Keuangan',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Saldo Saat Ini
          _InfoRow(
            label: 'Total Saldo',
            value: 'Rp ${formatRupiah(prediction.saldoSaatIni)}',
            valueColor: isDark ? AppColors.emerald : const Color(0xFF059669),
            icon: Icons.wallet_rounded,
          ),

          const Divider(height: 28),

          // Rata-rata Harian
          _InfoRow(
            label: 'Rata-rata Pengeluaran',
            value: 'Rp ${formatRupiah(prediction.rataRataHarian)} / hari',
            valueColor: isDark ? Colors.white70 : const Color(0xFF6B7280),
            icon: Icons.trending_down_rounded,
          ),

          const SizedBox(height: 12),

          // Progress hari
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : AppColors.primaryMid).withValues(
                alpha: 0.06,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hari ke-${prediction.hariBerlalu} dari ${prediction.totalHariBulan}',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ),
                Text(
                  '${((prediction.hariBerlalu / prediction.totalHariBulan) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Card 2: Prediksi & Status ====================
class _PrediksiCard extends StatelessWidget {
  final CashflowPrediction prediction;

  const _PrediksiCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = prediction.statusAman
        ? AppColors.emerald
        : AppColors.coral;
    final statusIcon = prediction.statusAman
        ? Icons.check_circle_rounded
        : Icons.warning_rounded;
    final statusLabel = prediction.statusAman ? 'Aman' : 'Waspada';
    final statusDesc = prediction.statusAman
        ? 'Saldo cukup hingga akhir bulan'
        : 'Kurangi pengeluaran Anda!';

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Prediksi Cashflow',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Estimasi Hari Tersisa
          Center(
            child: Column(
              children: [
                Text(
                  prediction.estimasiHariTersisa.toStringAsFixed(0),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                    color: statusColor,
                  ),
                ),
                Text(
                  'Hari Tersisa',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Status Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Status: $statusLabel',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              statusDesc,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Card 3: Info Tambahan ====================
class _InfoCard extends StatelessWidget {
  final CashflowPrediction prediction;

  const _InfoCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hariSisa = prediction.totalHariBulan - prediction.hariBerlalu;
    final cukup = prediction.estimasiHariTersisa > hariSisa;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Detail Analisis',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _DetailRow(label: 'Sisa hari di bulan ini', value: '$hariSisa hari'),
          _DetailRow(
            label: 'Total saldo saat ini',
            value: 'Rp ${formatRupiah(prediction.saldoSaatIni)}',
          ),
          _DetailRow(
            label: 'Rata-rata pengeluaran harian',
            value: 'Rp ${formatRupiah(prediction.rataRataHarian)}',
          ),
          _DetailRow(
            label: 'Estimasi saldo habis dalam',
            value: '${prediction.estimasiHariTersisa.toStringAsFixed(1)} hari',
          ),
          const SizedBox(height: 12),

          // Perbandingan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (cukup ? AppColors.emerald : AppColors.coral).withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  cukup ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                  size: 18,
                  color: cukup ? AppColors.emerald : AppColors.coral,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cukup
                        ? 'Estimasi ${prediction.estimasiHariTersisa.toStringAsFixed(0)} hari > $hariSisa hari sisa. Keuangan Anda dalam kondisi baik!'
                        : 'Estimasi ${prediction.estimasiHariTersisa.toStringAsFixed(0)} hari < $hariSisa hari sisa. Pertimbangkan mengurangi pengeluaran.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cukup ? AppColors.emerald : AppColors.coral,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Helper Widgets ====================
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white38 : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: isDark ? Colors.white54 : const Color(0xFF6B7280),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
