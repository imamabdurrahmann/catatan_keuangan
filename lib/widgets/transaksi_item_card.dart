import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../pages/actions/edit_transaksi_sheet.dart';
import '../models/constants.dart';
import '../models/models.dart';
import '../providers.dart';
import '../theme/theme.dart';
import '../utils/formatters.dart';

class TransaksiItemCard extends ConsumerWidget {
  final Transaksi transaksi;
  final VoidCallback? onDismissed;

  const TransaksiItemCard({
    super.key,
    required this.transaksi,
    this.onDismissed,
  });

  // Cached const values for better performance
  static const _dateFormat = 'dd MMM · HH:mm';
  static const _longDateFormat = 'dd MMMM yyyy, jam HH:mm';
  static const _borderRadius = BorderRadius.all(Radius.circular(16));
  static const _iconBorderRadius = BorderRadius.all(Radius.circular(12));

  String _getRecurringText(String? frequency) {
    switch (frequency) {
      case AppConstants.freqDaily:
        return 'harian';
      case AppConstants.freqWeekly:
        return 'mingguan';
      case AppConstants.freqMonthly:
        return 'bulanan';
      case AppConstants.freqYearly:
        return 'tahunan';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPemasukan = transaksi.jenis == AppConstants.jenisPemasukan;
    final accentColor = isPemasukan ? AppColors.emerald : AppColors.coral;

    // Build complete transaction description for screen readers
    final formattedAmount = 'Rp ${formatRupiah(transaksi.jumlah.toDouble())}';
    final signedAmount = '${isPemasukan ? 'positif' : 'negatif'} $formattedAmount';
    final transactionType = isPemasukan ? 'pemasukan' : 'pengeluaran';
    final formattedDate = DateFormat(_longDateFormat, 'id_ID').format(transaksi.tanggal);
    final attachmentCount = transaksi.lampiran.isNotEmpty
        ? 'dengan ${transaksi.lampiran.length} lampiran'
        : 'tanpa lampiran';
    final recurringText = transaksi.isRecurring ? ', transaksi berulang ${_getRecurringText(transaksi.recurringFrequency)}' : '';
    final fullDescription = 'Transaksi $transactionType: ${transaksi.deskripsi.isEmpty ? transaksi.kategori : transaksi.deskripsi}, kategori ${transaksi.kategori}, jumlah $signedAmount, tanggal $formattedDate, $attachmentCount$recurringText';

    final card = GestureDetector(
      onTap: () => _showEditSheet(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardElevated.withValues(alpha: 0.5)
              : AppColors.lightCard,
          borderRadius: _borderRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Semantics(
          label: fullDescription,
          button: true,
          child: _buildCardContent(context, isDark: isDark, isPemasukan: isPemasukan, accentColor: accentColor),
        ),
      ),
    );

    if (onDismissed != null) {
      return Dismissible(
        key: Key('transaksi_${transaksi.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.2),
            borderRadius: _borderRadius,
          ),
          child: Semantics(
            label: 'Hapus transaksi ${transaksi.deskripsi.isEmpty ? transaksi.kategori : transaksi.deskripsi}',
            excludeSemantics: true,
            child: const Icon(Icons.delete_rounded, color: AppColors.coral),
          ),
        ),
        onDismissed: (_) => onDismissed!(),
        child: card,
      );
    }

    return Semantics(
      label: fullDescription,
      excludeSemantics: true,
      child: card,
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: EditTransaksiSheet(
          transaksi: transaksi,
          onSave: () {
            ref.read(updateSignalsProvider.notifier).signal('transaksi');
            ref.invalidate(transaksiProvider);
            ref.invalidate(dompetProvider);
          },
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, {required bool isDark, required bool isPemasukan, required Color accentColor}) {
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: _iconBorderRadius,
              ),
              child: Semantics(
                label: isPemasukan
                    ? 'Ikon transaksi pemasukan'
                    : 'Ikon transaksi pengeluaran',
                excludeSemantics: true,
                child: Icon(
                  isPemasukan
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaksi.kategori.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (transaksi.isRecurring) _buildRecurringBadge(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaksi.deskripsi.isEmpty
                        ? transaksi.kategori
                        : transaksi.deskripsi,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (transaksi.lampiran.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildAttachmentRow(textColor),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPemasukan ? '+' : '-'}Rp ${formatRupiah(transaksi.jumlah.toDouble())}',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat(_dateFormat, 'id_ID').format(transaksi.tanggal),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurringBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Otomatis',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        ),
      ),
    );
  }

  Widget _buildAttachmentRow(Color textColor) {
    return Row(
      children: [
        Icon(
          Icons.attach_file_rounded,
          size: 12,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          '${transaksi.lampiran.length}',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w600,
            fontSize: 10,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
