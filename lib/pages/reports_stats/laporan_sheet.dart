import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../data/database_helper.dart';
import '../../services/pdf_laporan_service.dart';
import '../../services/export_service.dart';
import '../../services/excel_export_service.dart';

class LaporanSheet extends StatefulWidget {
  const LaporanSheet({super.key});

  @override
  State<LaporanSheet> createState() => _LaporanSheetState();
}

class _LaporanSheetState extends State<LaporanSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  int? _selectedDompetId;
  List<Dompet> _dompetList = [];
  bool _isGenerating = false;
  // exportMode: 'pdf' | 'csv' | 'excel'
  String _exportMode = 'pdf';

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    _loadDompet();
  }

  Future<void> _loadDompet() async {
    final list = await DatabaseHelper.instance.getAllDompet();
    setState(() {
      _dompetList = list;
    });
  }

  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(5, (i) => currentYear - i);
  }

  List<int> get _months => List.generate(12, (i) => i + 1);

  String _monthName(int month) {
    return DateFormat('MMMM', 'id_ID').format(DateTime(2024, month));
  }

  String _getPreviewLabel(String periodePreview) {
    if (_exportMode == 'csv') return 'Export CSV — $periodePreview';
    if (_exportMode == 'excel') return 'Export Excel — $periodePreview';
    return 'Laporan $periodePreview';
  }

  String _getLoadingMessage() {
    if (_exportMode == 'csv') return 'Sedang export CSV...';
    if (_exportMode == 'excel') return 'Sedang export Excel...';
    return 'Sedang membuat PDF...';
  }

  Future<void> _generate({required bool share}) async {
    setState(() => _isGenerating = true);

    try {
      if (_exportMode == 'csv') {
        // CSV export
        await _exportCsv(share: share);
      } else if (_exportMode == 'excel') {
        // Excel export
        await _exportExcel(share: share);
      } else {
        // PDF export
        if (share) {
          await PdfLaporanService.instance.generateAndShare(
            bulan: _selectedMonth,
            tahun: _selectedYear,
            idDompet: _selectedDompetId,
          );
        } else {
          await PdfLaporanService.instance.generateAndPrint(
            bulan: _selectedMonth,
            tahun: _selectedYear,
            idDompet: _selectedDompetId,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _getErrorMessage(e),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  String _getErrorMessage(dynamic e) {
    if (_exportMode == 'csv') return 'Gagal export CSV: $e';
    if (_exportMode == 'excel') return 'Gagal export Excel: $e';
    return 'Gagal membuat PDF: $e';
  }

  Future<void> _exportCsv({required bool share}) async {
    final csv = await ExportService.instance.exportTransactionsToCsvFiltered(
      bulan: _selectedMonth,
      tahun: _selectedYear,
      idDompet: _selectedDompetId,
    );
    final result = share
        ? await ExportService.instance.shareCsvFile(csv)
        : await ExportService.instance.shareCsvFile(csv);

    if (result == null && mounted) {
      throw Exception('Export gagal');
    }
  }

  Future<void> _exportExcel({required bool share}) async {
    final result = await ExcelExportService.instance.exportAndShareTransactionsExcel(
      bulan: _selectedMonth,
      tahun: _selectedYear,
      idDompet: _selectedDompetId,
    );

    if (result == null && mounted) {
      throw Exception('Export gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodePreview = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(DateTime(_selectedYear, _selectedMonth));

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cetak Laporan PDF',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih periode dan dompet untuk generate laporan.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Preview card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    _exportMode == 'pdf'
                        ? Icons.description
                        : _exportMode == 'csv'
                            ? Icons.table_chart
                            : Icons.grid_on,
                    size: 32,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPreviewLabel(periodePreview),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedDompetId != null && _dompetList.isNotEmpty)
                    Text(
                      _dompetList
                              .where((d) => d.id == _selectedDompetId)
                              .map((d) => d.nama)
                              .firstOrNull ??
                          'Semua Dompet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    )
                  else
                    const Text(
                      'Semua Dompet',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Format toggle
            Row(
              children: [
                const Text(
                  'Format',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'pdf',
                      label: Text('PDF'),
                      icon: Icon(Icons.picture_as_pdf, size: 16),
                    ),
                    ButtonSegment(
                      value: 'csv',
                      label: Text('CSV'),
                      icon: Icon(Icons.table_chart, size: 16),
                    ),
                    ButtonSegment(
                      value: 'excel',
                      label: Text('Excel'),
                      icon: Icon(Icons.grid_on, size: 16),
                    ),
                  ],
                  selected: {_exportMode},
                  onSelectionChanged: (selection) {
                    setState(() => _exportMode = selection.first);
                  },
                  showSelectedIcon: false,
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tahun
                    const Text(
                      'Tahun',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _years.map((year) {
                        final isSelected = year == _selectedYear;
                        return ChoiceChip(
                          label: Text('$year'),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedYear = year),
                          selectedColor: Colors.green.shade100,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Bulan
                    const Text(
                      'Bulan',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _months.map((month) {
                        final isSelected = month == _selectedMonth;
                        return ChoiceChip(
                          label: Text(_monthName(month)),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedMonth = month),
                          selectedColor: Colors.green.shade100,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Dompet
                    const Text(
                      'Dompet',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Semua'),
                          selected: _selectedDompetId == null,
                          onSelected: (_) =>
                              setState(() => _selectedDompetId = null),
                          selectedColor: Colors.green.shade100,
                        ),
                        ..._dompetList.map((dompet) {
                          final isSelected = dompet.id == _selectedDompetId;
                          return ChoiceChip(
                            label: Text(dompet.nama),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _selectedDompetId = dompet.id),
                            selectedColor: Colors.green.shade100,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            if (_isGenerating)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(_getLoadingMessage()),
                  ],
                ),
              )
            else if (_exportMode == 'csv')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _generate(share: true),
                  icon: const Icon(Icons.share),
                  label: const Text('Export & Bagikan CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              )
            else if (_exportMode == 'excel')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _generate(share: true),
                  icon: const Icon(Icons.share),
                  label: const Text('Export & Bagikan Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _generate(share: true),
                      icon: const Icon(Icons.share),
                      label: const Text('Bagikan'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _generate(share: false),
                      icon: const Icon(Icons.print),
                      label: const Text('Cetak / Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
