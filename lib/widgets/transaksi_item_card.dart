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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPemasukan = transaksi.jenis == AppConstants.jenisPemasukan;
    final accentColor = isPemasukan ? AppColors.emerald : AppColors.coral;

    Widget card = GestureDetector(
      onTap: () async {
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
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardElevated.withValues(alpha: 0.5)
              : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Semantics(
                    label: isPemasukan
                        ? 'Ikon transaksi pemasukan'
                        : 'Ikon transaksi pengeluaran',
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
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          if (transaksi.isRecurring)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Otomatis',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
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
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (transaksi.lampiran.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: 12,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${transaksi.lampiran.length}',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
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
                      DateFormat(
                        'dd MMM · HH:mm',
                        'id_ID',
                      ).format(transaksi.tanggal),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: AppColors.coral),
        ),
        onDismissed: (_) => onDismissed!(),
        child: card,
      );
    }

    return card;
  }
}
