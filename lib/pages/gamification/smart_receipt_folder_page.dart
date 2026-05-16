import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../models/models.dart';
import '../../../providers.dart';
import '../../../theme/theme.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/attachment_image.dart';
import '../../../services/file_service.dart';

class SmartReceiptFolderPage extends ConsumerStatefulWidget {
  const SmartReceiptFolderPage({super.key});

  @override
  ConsumerState<SmartReceiptFolderPage> createState() =>
      _SmartReceiptFolderPageState();
}

class _SmartReceiptFolderPageState
    extends ConsumerState<SmartReceiptFolderPage> {
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
    final receiptAsync = ref.watch(smartReceiptProvider(params));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.gold,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Folder Struk Pintar',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Month/Year Navigator ───
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
            child: receiptAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.coral.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat struk: $e',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              data: (receipts) {
                if (receipts.isEmpty) {
                  return _buildEmptyState(context, isDark);
                }
                return _buildReceiptGrid(context, ref, receipts, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/81b2e2d0-61f4-419b-aef7-b2f15f92dbce/8N7VfPIfPZ.json',
              width: 160,
              height: 160,
              errorBuilder: (_, __, ___) => Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 56,
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Struk Tersimpan',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan foto struk saat mencatat transaksi untuk melihatnya di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptGrid(
    BuildContext context,
    WidgetRef ref,
    List<Transaksi> receipts,
    bool isDark,
  ) {
    // Sort by date descending
    final sorted = List<Transaksi>.from(receipts)
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final tx = sorted[index];
        return _ReceiptCard(
          transaksi: tx,
          onTap: () => _showReceiptDetail(context, tx),
        );
      },
    );
  }

  void _showReceiptDetail(BuildContext context, Transaksi tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.gold, AppColors.goldLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.kategori,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy, HH:mm',
                            'id_ID',
                          ).format(tx.tanggal),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            // Image(s)
            Expanded(
              child: PageView.builder(
                itemCount: tx.lampiran.length,
                itemBuilder: (_, i) {
                  final path = tx.lampiran[i];
                  if (FileService.instance.isImage(path)) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: AttachmentImage(
                        path: path,
                        mode: AttachmentDisplayMode.full,
                        fit: BoxFit.contain,
                        errorBuilder: (_, e, __) => _buildImageError(e, isDark),
                      ),
                    );
                  }
                  return _buildFilePreview(path, isDark);
                },
              ),
            ),
            // Info row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCardElevated
                    : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(
                    'Jumlah',
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(tx.jumlah)}',
                    isDark,
                  ),
                  _infoItem('Kategori', tx.kategori, isDark),
                  _infoItem('Lampiran', '${tx.lampiran.length} file', isDark),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError(Object e, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat gambar',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(String path, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_rounded,
            size: 56,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            path.split('/').last,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
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

// ─── Date Navigation Button ───
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
          padding: const EdgeInsets.all(6),
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

// ─── Receipt Card ───
class _ReceiptCard extends StatelessWidget {
  final Transaksi transaksi;
  final VoidCallback onTap;

  const _ReceiptCard({required this.transaksi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = transaksi.jenis == 'pemasukan'
        ? AppColors.emerald
        : AppColors.coral;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              // Thumbnail preview
              _buildThumbnail(context),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaksi.kategori,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${transaksi.jenis == 'pemasukan' ? '+' : '-'}Rp ${NumberFormat('#,##0', 'id_ID').format(transaksi.jumlah)}',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaksi.deskripsi.isEmpty ? '-' : transaksi.deskripsi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'dd MMM yyyy',
                            'id_ID',
                          ).format(transaksi.tanggal),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.attachment_rounded,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${transaksi.lampiran.length} lampiran',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (transaksi.lampiran.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardElevated : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.receipt_long_rounded,
          color: isDark ? Colors.white24 : Colors.grey.shade300,
          size: 24,
        ),
      );
    }

    final firstPath = transaksi.lampiran.first;
    final isImg = FileService.instance.isImage(firstPath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          children: [
            isImg
                ? AttachmentImage(
                    path: firstPath,
                    mode: AttachmentDisplayMode.thumbnail,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    borderRadius: 10,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: isDark
                          ? AppColors.darkCardElevated
                          : Colors.grey.shade100,
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: Colors.grey.shade300,
                        size: 24,
                      ),
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: isDark
                        ? AppColors.darkCardElevated
                        : Colors.grey.shade100,
                    child: Icon(
                      Icons.insert_drive_file_rounded,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
            if (transaksi.lampiran.length > 1)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    '+${transaksi.lampiran.length - 1}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
