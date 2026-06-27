import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import '../../models/constants.dart';
import '../../models/models.dart';
import '../../providers.dart';
import '../../data/database_helper.dart';
import '../../services/file_service.dart';

import '../../widgets/shared_widgets.dart';
import '../../widgets/common/widgets.dart';
import '../../utils/ui_utils.dart';
import '../../theme/theme.dart';
import 'tambah_transaksi_widgets.dart';

class TambahTransaksiSheet extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onSave;
  final String? prefillType;

  const TambahTransaksiSheet({
    super.key,
    required this.selectedDate,
    required this.onSave,
    this.prefillType,
  });

  @override
  ConsumerState<TambahTransaksiSheet> createState() =>
      _TambahTransaksiSheetState();
}

class _TambahTransaksiSheetState extends ConsumerState<TambahTransaksiSheet> {
  late DateTime _tanggal;
  String _jenis = AppConstants.jenisPengeluaran;
  final _jumlahController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _kategori;
  int? _selectedDompetId;
  final List<File> _attachments = [];
  bool _isRecurring = false;
  String _recurringFrequency = AppConstants.freqMonthly;
  bool _isSaving = false;

  // Currency formatter: Rp IDR format, decimal 0 digits
  static final _currencyFmt = CurrencyTextInputFormatter.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _tanggal = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      now.hour,
      now.minute,
    );
    if (widget.prefillType == 'pemasukan') {
      _jenis = AppConstants.jenisPemasukan;
    } else if (widget.prefillType == 'pengeluaran') {
      _jenis = AppConstants.jenisPengeluaran;
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.attach_file_rounded, color: AppColors.primaryMid),
            const SizedBox(width: 10),
            const Text('Tambah Lampiran'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx, 'camera'),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Kamera'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx, 'gallery'),
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Galeri'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx, 'file'),
            icon: const Icon(Icons.insert_drive_file_rounded),
            label: const Text('File'),
          ),
        ],
      ),
    );
    if (choice == null) return;
    File? file;
    if (choice == 'camera') {
      file = await FileService.instance.pickImageFromCamera();
    } else if (choice == 'gallery') {
      file = await FileService.instance.pickImageFromGallery();
    } else {
      file = await FileService.instance.pickAnyFile();
    }
    if (file != null) {
      setState(() => _attachments.add(file!));
    }
  }

  Future<void> _simpan() async {
    if (_jumlahController.text.isEmpty || _kategori == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Text('Lengkapi jumlah dan kategori'),
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
    final clean = _jumlahController.text.replaceAll(RegExp(r'[^\d]'), '');
    final jumlah = double.tryParse(clean) ?? 0.0;
    if (jumlah <= 0 || jumlah > 999999999999) {
      ScaffoldMessenger.of(context).clearSnackBars();
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

    // ── Edge Case: Wajib pilih dompet ──
    final dompets = ref.read(dompetProvider).value;
    if (dompets == null || dompets.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              const Text('Buat dompet terlebih dahulu di menu Kelola Dompet'),
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

    final int? finalDompetId = _selectedDompetId ?? dompets.first.id;
    if (finalDompetId == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Text('Dompet wajib dipilih'),
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

    setState(() => _isSaving = true);
    final tx = Transaksi(
      jenis: _jenis,
      jumlah: jumlah,
      deskripsi: _deskripsiController.text,
      kategori: _kategori!,
      tanggal: _tanggal,
      lampiran: _attachments.map((f) => f.path).toList(),
      isRecurring: _isRecurring,
      recurringFrequency: _isRecurring ? _recurringFrequency : null,
      idDompet: finalDompetId,
    );
    await DatabaseHelper.instance.insertTransaksi(tx);
    widget.onSave();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Builder(
        builder: (scaffoldContext) {
          try {
            return Semantics(
              label: 'Form tambah transaksi baru',
              scopesRoute: true,
              explicitChildNodes: true,
              child: _buildContent(scaffoldContext),
            );
          } catch (e, st) {
            return _buildFallbackSheet(scaffoldContext, e, st);
          }
        },
      ),
    );
  }

  Widget _buildFallbackSheet(
    BuildContext context,
    Object error,
    StackTrace st,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            40,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.error_outline, size: 48, color: AppColors.coral),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat form',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '$error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kategoriAsync = ref.watch(kategoriByJenisProvider(_jenis));
    final accentColor = _jenis == AppConstants.jenisPemasukan
        ? AppColors.emerald
        : AppColors.coral;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            40,
      ),
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
        mainAxisSize: MainAxisSize.min,
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
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Tambah Transaksi',
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
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup form',
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jenis toggle
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
                  // Jumlah
                  Semantics(
                    label: 'Masukkan jumlah transaksi dalam Rupiah',
                    hint: 'Wajib diisi, hanya angka',
                    child: TextField(
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
                  ),
                  const SizedBox(height: 16),
                  // Dompet Selector
                  Semantics(
                    label: 'Pilih dompet untuk transaksi ini',
                    hint: 'Wajib dipilih',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              loading: () => const ShimmerFormField(),
                              error: (e, _) => Text('Error: $e'),
                              data: (dompetList) {
                                if (dompetList.isEmpty) {
                                  return const Text('Belum ada dompet');
                                }
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
                                        if (val != null) {
                                          setState(() => _selectedDompetId = val);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Deskripsi
                  Semantics(
                    label: 'Masukkan deskripsi transaksi',
                    hint: 'Opsional, maksimal 255 karakter',
                    child: TextField(
                      controller: _deskripsiController,
                      maxLength: 255,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        counterText: '',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkCard.withValues(alpha: 0.5)
                            : AppColors.lightBg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Recurring toggle
                  RecurringToggle(
                    isRecurring: _isRecurring,
                    recurringFrequency: _recurringFrequency,
                    onRecurringChanged: (v) => setState(() => _isRecurring = v),
                    onFrequencyChanged: (v) =>
                        setState(() => _recurringFrequency = v),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  // Kategori
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
                        const SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ShimmerContainer(height: 40, width: 80),
                              ShimmerContainer(height: 40, width: 100),
                              ShimmerContainer(height: 40, width: 90),
                              ShimmerContainer(height: 40, width: 70),
                            ],
                          ),
                        ),
                    error: (e, _) => Text('Error: $e'),
                    data: (kategoriList) => KategoriSelector(
                      kategoriList: kategoriList,
                      selectedKategori: _kategori,
                      onChanged: (val) => setState(() => _kategori = val),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Lampiran
                  Row(
                    children: [
                      Text(
                        'Lampiran',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const Spacer(),
                      Semantics(
                        label: 'Tambah lampiran',
                        hint: 'Tekan untuk menambahkan file lampiran',
                        button: true,
                        child: IconButton(
                          icon: Icon(
                            Icons.attach_file_rounded,
                            color: accentColor,
                          ),
                          onPressed: _pickAttachment,
                          tooltip: 'Tambah Lampiran',
                        ),
                      ),
                    ],
                  ),
                  AttachmentList(
                    attachments: _attachments,
                    onRemove: (index) =>
                        setState(() => _attachments.removeAt(index)),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  // Simpan button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GlassButton(
                      label: _isSaving ? 'Menyimpan...' : 'SIMPAN TRANSAKSI',
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
