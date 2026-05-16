import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import '../../models/constants.dart';
import '../../models/models.dart';
import '../../providers.dart';
import '../../data/database_helper.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/ui_utils.dart';
import '../../theme/theme.dart';
import '../../widgets/common/glass_button.dart';
import 'tambah_transaksi_widgets.dart';

class EditTransaksiSheet extends ConsumerStatefulWidget {
  final Transaksi transaksi;
  final VoidCallback onSave;

  const EditTransaksiSheet({
    super.key,
    required this.transaksi,
    required this.onSave,
  });

  @override
  ConsumerState<EditTransaksiSheet> createState() => _EditTransaksiSheetState();
}

class _EditTransaksiSheetState extends ConsumerState<EditTransaksiSheet> {
  late DateTime _tanggal;
  late String _jenis;
  late TextEditingController _jumlahController;
  late TextEditingController _deskripsiController;
  String? _kategori;
  int? _selectedDompetId;
  List<String> _attachments = [];
  bool _isSaving = false;

  // Currency formatter: Rp IDR format, decimal 0 digits
  static final _currencyFmt = CurrencyTextInputFormatter.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  double _parseJumlah() {
    // CurrencyTextInputFormatter stores numeric value internally.
    // We extract by stripping all non-digit characters.
    final clean = _jumlahController.text.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _tanggal = widget.transaksi.tanggal;
    _jenis = widget.transaksi.jenis;
    _jumlahController = TextEditingController(
      text: _currencyFmt
          .formatEditUpdate(
            const TextEditingValue(text: ''),
            TextEditingValue(text: widget.transaksi.jumlah.toInt().toString()),
          )
          .text,
    );
    _deskripsiController = TextEditingController(
      text: widget.transaksi.deskripsi,
    );
    _kategori = widget.transaksi.kategori;
    _selectedDompetId = widget.transaksi.idDompet;
    _attachments = List.from(widget.transaksi.lampiran);
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _hapus() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.coral,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Transaksi'),
          ],
        ),
        content: const Text(
          'Transaksi akan dipindahkan ke tong sampah dan dapat dipulihkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final id = widget.transaksi.id;
      if (id != null) {
        await DatabaseHelper.instance.softDeleteTransaksi(id);
        widget.onSave();
        if (mounted) Navigator.pop(context);
      }
    }
  }

  Future<void> _simpan() async {
    if (_jumlahController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Text('Lengkapi semua kolom'),
            ],
          ),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    final jumlah = _parseJumlah();
    if (jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Text('Jumlah tidak valid'),
            ],
          ),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    int? finalDompetId = _selectedDompetId;
    if (finalDompetId == null) {
      final dompets = ref.read(dompetProvider).value;
      if (dompets != null && dompets.isNotEmpty) {
        finalDompetId = dompets.first.id;
      }
    }

    setState(() => _isSaving = true);
    final tx = widget.transaksi.copyWith(
      jenis: _jenis,
      jumlah: jumlah,
      deskripsi: _deskripsiController.text,
      kategori: _kategori,
      tanggal: _tanggal,
      lampiran: _attachments,
      idDompet: finalDompetId,
      clearDeletedAt: false,
    );
    await DatabaseHelper.instance.updateTransaksi(tx);
    widget.onSave();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kategoriAsync = ref.watch(kategoriByJenisProvider(_jenis));
    final accentColor = _jenis == AppConstants.jenisPemasukan
        ? AppColors.emerald
        : AppColors.coral;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Edit Transaksi',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.coral,
                  ),
                  onPressed: _hapus,
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildJenisButton(
                    context: context,
                    selectedJenis: _jenis,
                    onChanged: (jenis) {
                      setState(() {
                        _jenis = jenis;
                        _kategori = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tanggal
                  PremiumDatePicker(
                    tanggal: _tanggal,
                    onChanged: (newDate) => setState(() => _tanggal = newDate),
                    isDark: isDark,
                    jenis: _jenis,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _jumlahController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _currencyFmt,
                    ],
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: accentColor,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard.withValues(alpha: 0.5)
                          : AppColors.lightBg,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dompet Selector
                  Text(
                    'Pilih Dompet',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ref
                      .watch(dompetProvider)
                      .when(
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                        data: (dompetList) {
                          if (dompetList.isEmpty)
                            return const Text('Belum ada dompet');
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard.withValues(alpha: 0.5)
                                  : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: _selectedDompetId ?? dompetList.first.id,
                                dropdownColor: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                items: dompetList.map((d) {
                                  return DropdownMenuItem<int>(
                                    value: d.id,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_rounded,
                                          color: getAppColor(d.warna),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          d.nama,
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedDompetId = val);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _deskripsiController,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard.withValues(alpha: 0.5)
                          : AppColors.lightBg,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Kategori',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 10),
                  kategoriAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (kategoriList) => KategoriSelector(
                      kategoriList: kategoriList,
                      selectedKategori: _kategori,
                      onChanged: (val) => setState(() => _kategori = val),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GlassButton(
                      label: _isSaving ? 'Memperbarui...' : 'UPDATE TRANSAKSI',
                      icon: Icons.check_rounded,
                      isLoading: _isSaving,
                      color: accentColor,
                      onPressed: _simpan,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
