import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database_helper.dart';
import '../data/database.dart';
import '../services/error_service.dart';

/// Service for exporting data to Excel (.xlsx) format with multiple sheets,
/// proper formatting, and Indonesian locale support.
class ExcelExportService {
  static final ExcelExportService _instance = ExcelExportService._();
  static ExcelExportService get instance => _instance;
  ExcelExportService._();

  /// Locale-aware formatters for Indonesian locale.
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
  final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy', 'id_ID');
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Creates a header cell style with dark green background.
  CellStyle _createHeaderStyle() {
    return CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      fontSize: 12,
    );
  }

  /// Creates an alternate row style with light green background.
  CellStyle _createAlternateRowStyle() {
    return CellStyle();
  }

  /// Creates a currency cell style.
  CellStyle _createCurrencyStyle({bool isBold = false}) {
    return CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      fontSize: 11,
      bold: isBold,
    );
  }

  /// Creates a section title style.
  CellStyle _createSectionTitleStyle() {
    return CellStyle(
      bold: true,
      fontSize: 14,
    );
  }

  /// Sets column widths for Transaksi sheet.
  void _setTransaksiColumnWidths(Sheet sheet) {
    sheet.setColumnWidth(0, 18.0); // Tanggal
    sheet.setColumnWidth(1, 12.0); // Jenis
    sheet.setColumnWidth(2, 16.0); // Jumlah
    sheet.setColumnWidth(3, 20.0); // Kategori
    sheet.setColumnWidth(4, 35.0); // Deskripsi
    sheet.setColumnWidth(5, 18.0); // Dompet
    sheet.setColumnWidth(6, 15.0); // Lampiran
  }

  /// Sets column widths for summary sheet.
  void _setSummaryColumnWidths(Sheet sheet) {
    sheet.setColumnWidth(0, 25.0);
    sheet.setColumnWidth(1, 18.0);
    sheet.setColumnWidth(2, 18.0);
  }

  /// Sets column widths for budget sheet.
  void _setBudgetColumnWidths(Sheet sheet) {
    sheet.setColumnWidth(0, 25.0);
    sheet.setColumnWidth(1, 18.0);
    sheet.setColumnWidth(2, 18.0);
    sheet.setColumnWidth(3, 18.0);
  }

  /// Formats a number as Indonesian Rupiah currency string.
  String _formatRupiah(double amount) {
    return _currencyFormatter.format(amount);
  }

  /// Helper to create CellIndex by column and row numbers.
  CellIndex _cellIndex(int col, int row) {
    return CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
  }

  /// Exports all non-deleted transactions to an Excel file.
  /// Returns the file path on success, null on failure.
  Future<String?> exportTransactionsToExcel({
    int? bulan,
    int? tahun,
    int? idDompet,
  }) async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1'); // Remove default sheet

      // Build filter conditions
      final whereClauses = <String>['deleted_at IS NULL'];
      final whereArgs = <dynamic>[];

      if (bulan != null && tahun != null) {
        whereClauses.add("strftime('%m', tanggal) = ?");
        whereArgs.add(bulan.toString().padLeft(2, '0'));
        whereClauses.add("strftime('%Y', tanggal) = ?");
        whereArgs.add(tahun.toString());
      }

      if (idDompet != null) {
        whereClauses.add('id_dompet = ?');
        whereArgs.add(idDompet);
      }

      // Query transactions
      final db = await DatabaseHelper.instance.database;
      final transaksiMaps = await db.query(
        TABLE_TRANSAKSI,
        where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'tanggal DESC',
      );

      // Pre-fetch all wallets for name lookup
      final dompetMaps = await db.query(TABLE_DOMPET);
      final dompetById = <int, String>{};
      for (final row in dompetMaps) {
        final id = row['id'] as int?;
        if (id != null) {
          dompetById[id] = row['nama'] as String;
        }
      }

      // Pre-fetch budgets
      final budgetMaps = await db.query(
        TABLE_BUDGET,
        where: 'profil_id = ?',
        whereArgs: [1],
      );
      final budgets = budgetMaps.map((map) => _budgetFromMap(map)).toList();

      // Parse lampiran for each transaction
      final transaksis = transaksiMaps.map((map) {
        List<String> parsedLampiran = [];
        if (map['lampiran'] != null && map['lampiran'].toString().isNotEmpty) {
          try {
            final decoded = jsonDecode(map['lampiran'] as String);
            if (decoded is List) {
              parsedLampiran = decoded.cast<String>();
            }
          } catch (_) {
            parsedLampiran = [];
          }
        }
        return {...map, '_lampiran_list': parsedLampiran};
      }).toList();

      // === SHEET 1: Transaksi ===
      final transaksiSheet = excel['Transaksi'];
      _buildTransaksiSheet(transaksiSheet, transaksis, dompetById);

      // === SHEET 2: Ringkasan (Summary) ===
      final summarySheet = excel['Ringkasan'];
      _buildSummarySheet(
        summarySheet,
        transaksis,
        dompetById,
        bulan,
        tahun,
      );

      // === SHEET 3: Budget ===
      final budgetSheet = excel['Budget'];
      _buildBudgetSheet(budgetSheet, budgets, transaksis, bulan, tahun);

      // Save to temporary file
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final bulanLabel = bulan != null
          ? DateFormat('MMMM_yyyy', 'id_ID').format(DateTime(tahun ?? 2024, bulan))
          : 'semua';
      final fileName = 'DompetKu_export_$bulanLabel\_$timestamp.xlsx';
      final file = File('${dir.path}/$fileName');

      final List<int>? fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception('Failed to encode Excel file');
      }
      await file.writeAsBytes(fileBytes);

      return file.path;
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      return null;
    }
  }

  /// Builds the Transaksi sheet with all transactions and formatting.
  void _buildTransaksiSheet(
    Sheet sheet,
    List<Map<String, dynamic>> transaksis,
    Map<int, String> dompetById,
  ) {
    _setTransaksiColumnWidths(sheet);
    final headerStyle = _createHeaderStyle();
    final alternateStyle = _createAlternateRowStyle();
    final currencyStyle = _createCurrencyStyle();
    final sectionStyle = _createSectionTitleStyle();
    final boldCurrencyStyle = _createCurrencyStyle(isBold: true);

    // Header row
    final headers = ['Tanggal', 'Jenis', 'Jumlah', 'Kategori', 'Deskripsi', 'Dompet', 'Lampiran'];
    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(_cellIndex(col, 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    double totalPemasukan = 0;
    double totalPengeluaran = 0;

    for (var row = 0; row < transaksis.length; row++) {
      final tx = transaksis[row];
      final isAlternate = row % 2 == 1;
      final rowStyle = isAlternate ? alternateStyle : null;

      final jenisValue = tx['jenis'] as String;
      final jenisLabel = jenisValue == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran';
      final jumlah = (tx['jumlah'] as num).toDouble();

      if (jenisValue == 'pemasukan') {
        totalPemasukan += jumlah;
      } else {
        totalPengeluaran += jumlah;
      }

      final tanggal = DateTime.parse(tx['tanggal'] as String);
      final idDompet = tx['id_dompet'] as int?;
      final dompetNama = idDompet != null
          ? (dompetById[idDompet] ?? '-')
          : '-';
      final lampiranList = tx['_lampiran_list'] as List<String>;
      final lampiranValue = lampiranList.isEmpty
          ? '-'
          : '${lampiranList.length} lampiran';

      // Set values
      sheet.cell(_cellIndex(0, row + 1)).value = TextCellValue(_dateFormatter.format(tanggal));
      sheet.cell(_cellIndex(1, row + 1)).value = TextCellValue(jenisLabel);
      sheet.cell(_cellIndex(2, row + 1)).value = TextCellValue(_formatRupiah(jumlah));
      sheet.cell(_cellIndex(3, row + 1)).value = TextCellValue(tx['kategori'] as String);
      sheet.cell(_cellIndex(4, row + 1)).value = TextCellValue(tx['deskripsi'] as String);
      sheet.cell(_cellIndex(5, row + 1)).value = TextCellValue(dompetNama);
      sheet.cell(_cellIndex(6, row + 1)).value = TextCellValue(lampiranValue);

      // Apply row styling
      if (rowStyle != null) {
        for (var col = 0; col < 7; col++) {
          sheet.cell(_cellIndex(col, row + 1)).cellStyle = rowStyle;
        }
      }
    }

    // Summary footer
    final footerRow = transaksis.length + 1;
    sheet.cell(_cellIndex(0, footerRow)).value = TextCellValue('TOTAL');
    sheet.cell(_cellIndex(0, footerRow)).cellStyle = sectionStyle;
    sheet.cell(_cellIndex(1, footerRow)).cellStyle = sectionStyle;
    sheet.cell(_cellIndex(2, footerRow)).value = TextCellValue(_formatRupiah(totalPemasukan - totalPengeluaran));
    sheet.cell(_cellIndex(2, footerRow)).cellStyle = boldCurrencyStyle;

    // Total rows
    final totalPemasukanRow = transaksis.length + 2;
    sheet.cell(_cellIndex(0, totalPemasukanRow)).value = TextCellValue('Total Pemasukan');
    sheet.cell(_cellIndex(0, totalPemasukanRow)).cellStyle = currencyStyle;
    sheet.cell(_cellIndex(2, totalPemasukanRow)).value = TextCellValue(_formatRupiah(totalPemasukan));
    sheet.cell(_cellIndex(2, totalPemasukanRow)).cellStyle = currencyStyle;

    final totalPengeluaranRow = transaksis.length + 3;
    sheet.cell(_cellIndex(0, totalPengeluaranRow)).value = TextCellValue('Total Pengeluaran');
    sheet.cell(_cellIndex(0, totalPengeluaranRow)).cellStyle = currencyStyle;
    sheet.cell(_cellIndex(2, totalPengeluaranRow)).value = TextCellValue(_formatRupiah(totalPengeluaran));
    sheet.cell(_cellIndex(2, totalPengeluaranRow)).cellStyle = currencyStyle;
  }

  /// Builds the Ringkasan (Summary) sheet with totals by category and wallet.
  void _buildSummarySheet(
    Sheet sheet,
    List<Map<String, dynamic>> transaksis,
    Map<int, String> dompetById,
    int? bulan,
    int? tahun,
  ) {
    _setSummaryColumnWidths(sheet);
    final headerStyle = _createHeaderStyle();
    final sectionStyle = _createSectionTitleStyle();
    final currencyStyle = _createCurrencyStyle();
    final boldCurrencyStyle = _createCurrencyStyle(isBold: true);

    // Title
    String title = 'Ringkasan Keuangan';
    if (bulan != null && tahun != null) {
      title = 'Ringkasan ${_monthYearFormatter.format(DateTime(tahun, bulan))}';
    }
    sheet.cell(_cellIndex(0, 0)).value = TextCellValue(title);
    sheet.cell(_cellIndex(0, 0)).cellStyle = sectionStyle;

    // Headers
    sheet.cell(_cellIndex(0, 2)).value = TextCellValue('Kategori');
    sheet.cell(_cellIndex(1, 2)).value = TextCellValue('Pemasukan');
    sheet.cell(_cellIndex(2, 2)).value = TextCellValue('Pengeluaran');

    for (var col = 0; col < 3; col++) {
      sheet.cell(_cellIndex(col, 2)).cellStyle = headerStyle;
    }

    // Aggregate by category
    final categoryTotals = <String, Map<String, double>>{};
    for (final tx in transaksis) {
      final kategori = tx['kategori'] as String;
      final jenis = tx['jenis'] as String;
      final jumlah = (tx['jumlah'] as num).toDouble();

      categoryTotals.putIfAbsent(kategori, () => {'pemasukan': 0, 'pengeluaran': 0});
      if (jenis == 'pemasukan') {
        categoryTotals[kategori]!['pemasukan'] = categoryTotals[kategori]!['pemasukan']! + jumlah;
      } else {
        categoryTotals[kategori]!['pengeluaran'] = categoryTotals[kategori]!['pengeluaran']! + jumlah;
      }
    }

    var row = 3;
    double totalPemasukan = 0;
    double totalPengeluaran = 0;

    for (final entry in categoryTotals.entries) {
      final pemasukkan = entry.value['pemasukan']!;
      final pengeluaran = entry.value['pengeluaran']!;
      totalPemasukan += pemasukkan;
      totalPengeluaran += pengeluaran;

      sheet.cell(_cellIndex(0, row)).value = TextCellValue(entry.key);
      sheet.cell(_cellIndex(1, row)).value = TextCellValue(_formatRupiah(pemasukkan));
      sheet.cell(_cellIndex(2, row)).value = TextCellValue(_formatRupiah(pengeluaran));

      for (var col = 0; col < 3; col++) {
        sheet.cell(_cellIndex(col, row)).cellStyle = currencyStyle;
      }
      row++;
    }

    // Total row
    row++;
    sheet.cell(_cellIndex(0, row)).value = TextCellValue('TOTAL');
    sheet.cell(_cellIndex(0, row)).cellStyle = sectionStyle;
    sheet.cell(_cellIndex(1, row)).value = TextCellValue(_formatRupiah(totalPemasukan));
    sheet.cell(_cellIndex(2, row)).cellStyle = currencyStyle;

    // Saldo row
    row++;
    sheet.cell(_cellIndex(0, row)).value = TextCellValue('SALDO');
    sheet.cell(_cellIndex(0, row)).cellStyle = sectionStyle;
    sheet.cell(_cellIndex(1, row)).value = TextCellValue(_formatRupiah(totalPemasukan - totalPengeluaran));
    sheet.cell(_cellIndex(1, row)).cellStyle = boldCurrencyStyle;

    // Summary by wallet
    row += 2;
    sheet.cell(_cellIndex(0, row)).value = TextCellValue('Per Dompet');
    sheet.cell(_cellIndex(0, row)).cellStyle = sectionStyle;

    row++;
    sheet.cell(_cellIndex(0, row)).value = TextCellValue('Dompet');
    sheet.cell(_cellIndex(1, row)).value = TextCellValue('Jumlah Transaksi');

    for (var col = 0; col < 3; col++) {
      sheet.cell(_cellIndex(col, row)).cellStyle = headerStyle;
    }

    // Aggregate by wallet
    final walletCounts = <int, int>{};
    for (final tx in transaksis) {
      final idDompet = tx['id_dompet'] as int?;
      if (idDompet != null) {
        walletCounts[idDompet] = (walletCounts[idDompet] ?? 0) + 1;
      }
    }

    row++;
    for (final entry in walletCounts.entries) {
      final dompetNama = dompetById[entry.key] ?? 'Unknown';
      sheet.cell(_cellIndex(0, row)).value = TextCellValue(dompetNama);
      sheet.cell(_cellIndex(1, row)).value = TextCellValue(entry.value.toString());

      for (var col = 0; col < 3; col++) {
        sheet.cell(_cellIndex(col, row)).cellStyle = currencyStyle;
      }
      row++;
    }
  }

  /// Builds the Budget sheet with budget vs actual comparison.
  void _buildBudgetSheet(
    Sheet sheet,
    List<Budget> budgets,
    List<Map<String, dynamic>> transaksis,
    int? bulan,
    int? tahun,
  ) {
    _setBudgetColumnWidths(sheet);
    final headerStyle = _createHeaderStyle();
    final sectionStyle = _createSectionTitleStyle();
    final currencyStyle = _createCurrencyStyle();

    // Title
    String title = 'Budget';
    if (bulan != null && tahun != null) {
      title = 'Budget ${_monthYearFormatter.format(DateTime(tahun, bulan))}';
    }
    sheet.cell(_cellIndex(0, 0)).value = TextCellValue(title);
    sheet.cell(_cellIndex(0, 0)).cellStyle = sectionStyle;

    // Headers
    sheet.cell(_cellIndex(0, 2)).value = TextCellValue('Kategori');
    sheet.cell(_cellIndex(1, 2)).value = TextCellValue('Budget');
    sheet.cell(_cellIndex(2, 2)).value = TextCellValue('Terpakai');
    sheet.cell(_cellIndex(3, 2)).value = TextCellValue('Sisa');

    for (var col = 0; col < 4; col++) {
      sheet.cell(_cellIndex(col, 2)).cellStyle = headerStyle;
    }

    // Filter transactions for the period (pengeluaran only)
    final filteredTxs = transaksis.where((tx) => tx['jenis'] == 'pengeluaran').toList();

    // Aggregate pengeluaran by category
    final pengeluaranByKategori = <String, double>{};
    for (final tx in filteredTxs) {
      final kategori = tx['kategori'] as String;
      final jumlah = (tx['jumlah'] as num).toDouble();
      pengeluaranByKategori[kategori] = (pengeluaranByKategori[kategori] ?? 0) + jumlah;
    }

    var row = 3;
    for (final budget in budgets) {
      final terpakai = pengeluaranByKategori[budget.kategori] ?? 0;
      final sisa = budget.totalBudget - terpakai;

      sheet.cell(_cellIndex(0, row)).value = TextCellValue(budget.kategori);
      sheet.cell(_cellIndex(1, row)).value = TextCellValue(_formatRupiah(budget.totalBudget));
      sheet.cell(_cellIndex(2, row)).value = TextCellValue(_formatRupiah(terpakai));
      sheet.cell(_cellIndex(3, row)).value = TextCellValue(_formatRupiah(sisa));

      for (var col = 0; col < 4; col++) {
        sheet.cell(_cellIndex(col, row)).cellStyle = currencyStyle;
      }
      row++;
    }

    // No budgets message
    if (budgets.isEmpty) {
      row++;
      sheet.cell(_cellIndex(0, row)).value = TextCellValue('Tidak ada budget untuk periode ini');
      sheet.cell(_cellIndex(0, row)).cellStyle = currencyStyle;
    }
  }

  /// Converts a budget map to a Budget object.
  Budget _budgetFromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      bulan: map['bulan'] as int,
      tahun: map['tahun'] as int,
      nominal: (map['nominal'] as num).toDouble(),
      kategori: map['kategori'] as String,
      profilId: map['profil_id'] as int? ?? 1,
      sisaRollover: (map['sisa_rollover'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Shares the Excel file via share_plus.
  /// Returns the file path on success, null on failure.
  Future<String?> shareExcelFile(String filePath) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          subject: 'Export Excel DompetKu',
        ),
      );
      return filePath;
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      return null;
    }
  }

  /// Full pipeline: export transactions to Excel and share the file.
  /// Returns the file path on success, null on failure.
  Future<String?> exportAndShareTransactionsExcel({
    int? bulan,
    int? tahun,
    int? idDompet,
  }) async {
    final filePath = await exportTransactionsToExcel(
      bulan: bulan,
      tahun: tahun,
      idDompet: idDompet,
    );
    if (filePath != null) {
      return await shareExcelFile(filePath);
    }
    return null;
  }
}

/// Budget class for the export service (duplicated from models to avoid import issues).
class Budget {
  final int? id;
  final int bulan;
  final int tahun;
  final double nominal;
  final String kategori;
  final int profilId;
  final double sisaRollover;

  Budget({
    this.id,
    required this.bulan,
    required this.tahun,
    required this.nominal,
    required this.kategori,
    this.profilId = 1,
    this.sisaRollover = 0,
  });

  double get totalBudget => nominal + sisaRollover;
}