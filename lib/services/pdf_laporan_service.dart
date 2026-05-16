import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../data/database_helper.dart';

class PdfLaporanService {
  static final PdfLaporanService instance = PdfLaporanService._();
  PdfLaporanService._();

  static const _imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
  ];

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return _imageExtensions.any((ext) => lower.endsWith(ext));
  }

  Future<Map<String, Uint8List>> _loadLampiranImages(List<String> paths) async {
    final Map<String, Uint8List> bytesMap = {};
    for (var path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          bytesMap[path] = await file.readAsBytes();
        }
      } catch (_) {
        // Skip unreadable files
      }
    }
    return bytesMap;
  }

  Future<Map<String, Uint8List>> _loadAllLampiranForTransactions(
    List<Transaksi> transactions,
  ) async {
    final Set<String> allPaths = {};
    for (var tx in transactions) {
      for (var lampiran in tx.lampiran) {
        if (_isImage(lampiran)) {
          allPaths.add(lampiran);
        }
      }
    }
    return _loadLampiranImages(allPaths.toList());
  }

  static final _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');

  Future<void> generateAndPrint({
    required int bulan,
    required int tahun,
    int? idDompet,
  }) async {
    final pdf = pw.Document();

    final dompetList = await DatabaseHelper.instance.getAllDompet();
    Dompet? selectedDompet;
    if (idDompet != null) {
      selectedDompet = dompetList.where((d) => d.id == idDompet).firstOrNull;
    }

    final transaksi = await DatabaseHelper.instance.getTransaksiByMonth(
      tahun,
      bulan,
      idDompet: idDompet,
    );
    final summary = await DatabaseHelper.instance.getMonthlySummary(
      tahun,
      bulan,
      idDompet: idDompet,
    );
    final categorySummary = await DatabaseHelper.instance.getCategorySummary(
      tahun,
      bulan,
    );
    final categoryIncome = await _getCategoryPemasukan(bulan, tahun, idDompet);

    final periode = DateTime(tahun, bulan);
    final totalPemasukan = summary['pemasukan'] ?? 0;
    final totalPengeluaran = summary['pengeluaran'] ?? 0;
    final saldo = summary['saldo'] ?? 0;

    // Group transaksi by date
    final grouped = _groupByDate(transaksi);
    final lampiranBytes = await _loadAllLampiranForTransactions(transaksi);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(periode, selectedDompet?.nama),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Ringkasan
          _buildSummaryCard(totalPemasukan, totalPengeluaran, saldo),
          pw.SizedBox(height: 16),

          // Kategori breakdown
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildCategorySection(
                  'Pengeluaran per Kategori',
                  categorySummary,
                  totalPengeluaran,
                  PdfColors.red,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildCategorySection(
                  'Pemasukan per Kategori',
                  categoryIncome,
                  totalPemasukan,
                  PdfColors.green,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Daftar transaksi
          pw.Text(
            'Daftar Transaksi',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 8),

          ...grouped.entries
              .map((entry) {
                final date = entry.key;
                final txs = entry.value;
                final dayTotal = txs.fold<double>(0, (sum, tx) {
                  return sum +
                      (tx.jenis == 'pemasukan' ? tx.jumlah : -tx.jumlah);
                });

                return [
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 8, bottom: 4),
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    color: PdfColors.grey200,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          _dateFormat.format(date),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        pw.Text(
                          dayTotal >= 0
                              ? '+${_rupiahFormat.format(dayTotal)}'
                              : _rupiahFormat.format(dayTotal),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                            color: dayTotal >= 0
                                ? PdfColors.green700
                                : PdfColors.red700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...txs.map((tx) => _buildTransactionRow(tx, lampiranBytes)),
                ];
              })
              .expand((x) => x),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name:
          'Laporan_${_monthYearFormat.format(periode).replaceAll(' ', '_')}.pdf',
    );
  }

  Future<void> generateAndShare({
    required int bulan,
    required int tahun,
    int? idDompet,
  }) async {
    final pdf = pw.Document();

    final dompetList = await DatabaseHelper.instance.getAllDompet();
    Dompet? selectedDompet;
    if (idDompet != null) {
      selectedDompet = dompetList.where((d) => d.id == idDompet).firstOrNull;
    }

    final transaksi = await DatabaseHelper.instance.getTransaksiByMonth(
      tahun,
      bulan,
      idDompet: idDompet,
    );
    final summary = await DatabaseHelper.instance.getMonthlySummary(
      tahun,
      bulan,
      idDompet: idDompet,
    );
    final categorySummary = await DatabaseHelper.instance.getCategorySummary(
      tahun,
      bulan,
    );
    final categoryIncome = await _getCategoryPemasukan(bulan, tahun, idDompet);

    final periode = DateTime(tahun, bulan);
    final totalPemasukan = summary['pemasukan'] ?? 0;
    final totalPengeluaran = summary['pengeluaran'] ?? 0;
    final saldo = summary['saldo'] ?? 0;

    final grouped = _groupByDate(transaksi);
    final lampiranBytes = await _loadAllLampiranForTransactions(transaksi);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(periode, selectedDompet?.nama),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummaryCard(totalPemasukan, totalPengeluaran, saldo),
          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildCategorySection(
                  'Pengeluaran per Kategori',
                  categorySummary,
                  totalPengeluaran,
                  PdfColors.red,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildCategorySection(
                  'Pemasukan per Kategori',
                  categoryIncome,
                  totalPemasukan,
                  PdfColors.green,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Daftar Transaksi',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 8),
          ...grouped.entries
              .map((entry) {
                final date = entry.key;
                final txs = entry.value;
                final dayTotal = txs.fold<double>(0, (sum, tx) {
                  return sum +
                      (tx.jenis == 'pemasukan' ? tx.jumlah : -tx.jumlah);
                });
                return [
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 8, bottom: 4),
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    color: PdfColors.grey200,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          _dateFormat.format(date),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        pw.Text(
                          dayTotal >= 0
                              ? '+${_rupiahFormat.format(dayTotal)}'
                              : _rupiahFormat.format(dayTotal),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                            color: dayTotal >= 0
                                ? PdfColors.green700
                                : PdfColors.red700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...txs.map((tx) => _buildTransactionRow(tx, lampiranBytes)),
                ];
              })
              .expand((x) => x),
        ],
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'Laporan_${_monthYearFormat.format(periode).replaceAll(' ', '_')}.pdf',
    );
  }

  Map<DateTime, List<Transaksi>> _groupByDate(List<Transaksi> transaksi) {
    final Map<DateTime, List<Transaksi>> grouped = {};
    for (var tx in transaksi) {
      final dateKey = DateTime(
        tx.tanggal.year,
        tx.tanggal.month,
        tx.tanggal.day,
      );
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    return grouped;
  }

  pw.Widget _buildHeader(DateTime periode, String? dompetNama) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'LAPORAN KEUANGAN',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                _monthYearFormat.format(periode),
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Divider(thickness: 2, color: PdfColors.green),
          if (dompetNama != null)
            pw.Text(
              'Dompet: $dompetNama',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          pw.Text(
            'Dicetak: ${_dateFormat.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'Halaman ${context.pageNumber} / ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      ),
    );
  }

  pw.Widget _buildSummaryCard(
    double totalPemasukan,
    double totalPengeluaran,
    double saldo,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total Pemasukan',
            totalPemasukan,
            PdfColors.green700,
          ),
          pw.Container(width: 1, height: 40, color: PdfColors.grey400),
          _buildSummaryItem(
            'Total Pengeluaran',
            totalPengeluaran,
            PdfColors.red700,
          ),
          pw.Container(width: 1, height: 40, color: PdfColors.grey400),
          _buildSummaryItem(
            'Saldo',
            saldo,
            saldo >= 0 ? PdfColors.green700 : PdfColors.red700,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, double value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _rupiahFormat.format(value),
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCategorySection(
    String title,
    Map<String, double> categories,
    double total,
    PdfColor color,
  ) {
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(thickness: 0.5),
          if (sorted.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text(
                'Tidak ada data',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey500,
                ),
              ),
            )
          else
            ...sorted.map((entry) {
              final pct = total > 0 ? (entry.value / total * 100) : 0.0;
              return pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            entry.key,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Text(
                          _rupiahFormat.format(entry.value),
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 2),
                      height: 3,
                      decoration: pw.BoxDecoration(
                        color: color.shade(0.85),
                        borderRadius: pw.BorderRadius.circular(2),
                      ),
                      width: double.parse(pct.toStringAsFixed(1)) * 3,
                    ),
                    pw.Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  pw.Widget _buildTransactionRow(
    Transaksi tx,
    Map<String, Uint8List> lampiranBytes,
  ) {
    final isIncome = tx.jenis == 'pemasukan';
    final color = isIncome ? PdfColors.green700 : PdfColors.red700;

    // Build lampiran images
    final List<pw.Widget> lampiranImages = [];
    for (var lampiran in tx.lampiran) {
      if (lampiranBytes.containsKey(lampiran)) {
        try {
          final bytes = lampiranBytes[lampiran]!;
          final image = pw.MemoryImage(bytes);
          lampiranImages.add(
            pw.ClipRRect(
              horizontalRadius: 6,
              verticalRadius: 6,
              child: pw.Image(image, width: 250, fit: pw.BoxFit.contain),
            ),
          );
        } catch (_) {
          // Skip unreadable images
        }
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  tx.deskripsi,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  tx.kategori,
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                width: 90,
                child: pw.Text(
                  '${isIncome ? '+' : '-'}${_rupiahFormat.format(tx.jumlah)}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (tx.lampiran.isNotEmpty) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 6, bottom: 8, top: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'Lampiran (${tx.lampiran.length})',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                if (lampiranImages.isNotEmpty)
                  pw.Wrap(spacing: 12, runSpacing: 12, children: lampiranImages)
                else
                  pw.Text(
                    tx.lampiran.map((p) => p.split('/').last).join(', '),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<Map<String, double>> _getCategoryPemasukan(
    int bulan,
    int tahun,
    int? idDompet,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final startDate = DateTime(tahun, bulan, 1);
    final endDate = DateTime(tahun, bulan + 1, 0);

    String where =
        'jenis = ? AND tanggal >= ? AND tanggal < ? AND deleted_at IS NULL';
    List<dynamic> whereArgs = [
      'pemasukan',
      '${DateFormat('yyyy-MM-dd').format(startDate)} 00:00:00',
      '${DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)))} 00:00:00',
    ];

    if (idDompet != null) {
      where += ' AND id_dompet = ?';
      whereArgs.add(idDompet);
    }

    final result = await db.rawQuery(
      'SELECT kategori, SUM(jumlah) as total FROM transaksi WHERE $where GROUP BY kategori',
      whereArgs,
    );

    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['kategori'] as String] = (row['total'] as num)
          .toDouble();
    }
    return categoryTotals;
  }
}
