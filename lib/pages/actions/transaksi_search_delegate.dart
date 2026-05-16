import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../data/database_helper.dart';
import '../../utils/formatters.dart';
import 'edit_transaksi_sheet.dart';

enum JenisFilter { semua, pemasukan, pengeluaran }

enum TanggalFilter {
  semua,
  hariIni,
  tujuhHari,
  tigaPuluhHari,
  bulanIni,
  custom,
}

enum SortOption { terbaru, terlama, terbesar, terkecil }

class SearchFilters {
  final String? query;
  final JenisFilter jenisFilter;
  final TanggalFilter tanggalFilter;
  final DateTime? dariTanggal;
  final DateTime? sampaiTanggal;
  final double? jumlahMin;
  final double? jumlahMax;
  final SortOption sortOption;

  const SearchFilters({
    this.query,
    this.jenisFilter = JenisFilter.semua,
    this.tanggalFilter = TanggalFilter.semua,
    this.dariTanggal,
    this.sampaiTanggal,
    this.jumlahMin,
    this.jumlahMax,
    this.sortOption = SortOption.terbaru,
  });

  String? get jenis {
    switch (jenisFilter) {
      case JenisFilter.semua:
        return null;
      case JenisFilter.pemasukan:
        return 'pemasukan';
      case JenisFilter.pengeluaran:
        return 'pengeluaran';
    }
  }

  String get orderBy {
    switch (sortOption) {
      case SortOption.terbaru:
        return 'tanggal DESC';
      case SortOption.terlama:
        return 'tanggal ASC';
      case SortOption.terbesar:
        return 'jumlah DESC';
      case SortOption.terkecil:
        return 'jumlah ASC';
    }
  }

  DateTime? get dariTanggalResolved {
    if (tanggalFilter != TanggalFilter.custom) return dariTanggal;
    return dariTanggal;
  }

  DateTime? get sampaiTanggalResolved {
    if (tanggalFilter != TanggalFilter.custom) return sampaiTanggal;
    return sampaiTanggal;
  }

  SearchFilters copyWith({
    String? query,
    JenisFilter? jenisFilter,
    TanggalFilter? tanggalFilter,
    DateTime? dariTanggal,
    DateTime? sampaiTanggal,
    double? jumlahMin,
    double? jumlahMax,
    SortOption? sortOption,
    bool clearDariTanggal = false,
    bool clearSampaiTanggal = false,
    bool clearJumlahMin = false,
    bool clearJumlahMax = false,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      jenisFilter: jenisFilter ?? this.jenisFilter,
      tanggalFilter: tanggalFilter ?? this.tanggalFilter,
      dariTanggal: clearDariTanggal ? null : (dariTanggal ?? this.dariTanggal),
      sampaiTanggal: clearSampaiTanggal
          ? null
          : (sampaiTanggal ?? this.sampaiTanggal),
      jumlahMin: clearJumlahMin ? null : (jumlahMin ?? this.jumlahMin),
      jumlahMax: clearJumlahMax ? null : (jumlahMax ?? this.jumlahMax),
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class TransaksiSearchDelegate extends SearchDelegate<Transaksi?> {
  SearchFilters _filters = const SearchFilters();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _filters = _filters.copyWith(query: '');
            showSuggestions(context);
          },
        ),
      IconButton(
        icon: const Icon(Icons.filter_list),
        tooltip: 'Filter',
        onPressed: () => _showFilterSheet(context),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults(context);

  Future<void> _showFilterSheet(BuildContext context) async {
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(initialFilters: _filters),
    );

    if (result != null) {
      _filters = result;
      showResults(context);
    }
  }

  Future<List<Transaksi>> _fetchResults(String q) async {
    final effectiveQuery = q.isEmpty ? null : q;
    final now = DateTime.now();

    DateTime? dariTanggal;
    DateTime? sampaiTanggal;

    switch (_filters.tanggalFilter) {
      case TanggalFilter.hariIni:
        dariTanggal = now;
        sampaiTanggal = now;
        break;
      case TanggalFilter.tujuhHari:
        dariTanggal = now.subtract(const Duration(days: 6));
        sampaiTanggal = now;
        break;
      case TanggalFilter.tigaPuluhHari:
        dariTanggal = now.subtract(const Duration(days: 29));
        sampaiTanggal = now;
        break;
      case TanggalFilter.bulanIni:
        dariTanggal = DateTime(now.year, now.month, 1);
        sampaiTanggal = now;
        break;
      case TanggalFilter.custom:
        dariTanggal = _filters.dariTanggal;
        sampaiTanggal = _filters.sampaiTanggal;
        break;
      case TanggalFilter.semua:
        break;
    }

    return DatabaseHelper.instance.searchTransaksiAdvanced(
      query: effectiveQuery,
      jenis: _filters.jenis,
      dariTanggal: dariTanggal,
      sampaiTanggal: sampaiTanggal,
      jumlahMin: _filters.jumlahMin,
      jumlahMax: _filters.jumlahMax,
      orderBy: _filters.orderBy,
    );
  }

  Widget _buildResults(BuildContext context) {
    if (query.isEmpty &&
        _filters.jenisFilter == JenisFilter.semua &&
        _filters.tanggalFilter == TanggalFilter.semua &&
        _filters.jumlahMin == null &&
        _filters.jumlahMax == null) {
      return _buildEmptyState(context);
    }

    return FutureBuilder<List<Transaksi>>(
      future: _fetchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return _buildNoResults(context);
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final tx = results[index];
            final isPemasukan = tx.jenis == 'pemasukan';
            return ListTile(
              leading: Icon(
                isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                color: isPemasukan ? Colors.green : Colors.red,
              ),
              title: Text(tx.deskripsi),
              subtitle: Text(
                '${tx.kategori} • ${DateFormat('d MMM yyyy', 'id_ID').format(tx.tanggal)}',
              ),
              trailing: Text(
                '${isPemasukan ? '+' : '-'}Rp ${formatRupiah(tx.jumlah)}',
                style: TextStyle(
                  color: isPemasukan ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => close(context, tx),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Ketik untuk mencari transaksi',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.filter_list),
            label: const Text('Buka Filter'),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada hasil',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _filters = const SearchFilters();
              query = '';
              showSuggestions(context);
            },
            child: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final SearchFilters initialFilters;

  const _FilterSheet({required this.initialFilters});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late JenisFilter _jenisFilter;
  late TanggalFilter _tanggalFilter;
  late DateTime? _dariTanggal;
  late DateTime? _sampaiTanggal;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late SortOption _sortOption;

  @override
  void initState() {
    super.initState();
    _jenisFilter = widget.initialFilters.jenisFilter;
    _tanggalFilter = widget.initialFilters.tanggalFilter;
    _dariTanggal = widget.initialFilters.dariTanggal;
    _sampaiTanggal = widget.initialFilters.sampaiTanggal;
    _minController = TextEditingController(
      text: widget.initialFilters.jumlahMin?.toStringAsFixed(0) ?? '',
    );
    _maxController = TextEditingController(
      text: widget.initialFilters.jumlahMax?.toStringAsFixed(0) ?? '',
    );
    _sortOption = widget.initialFilters.sortOption;
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String _getJenisLabel(JenisFilter jenis) {
    switch (jenis) {
      case JenisFilter.semua:
        return 'Semua';
      case JenisFilter.pemasukan:
        return 'Pemasukan';
      case JenisFilter.pengeluaran:
        return 'Pengeluaran';
    }
  }

  String _getTanggalLabel(TanggalFilter filter) {
    switch (filter) {
      case TanggalFilter.semua:
        return 'Semua Tanggal';
      case TanggalFilter.hariIni:
        return 'Hari Ini';
      case TanggalFilter.tujuhHari:
        return '7 Hari Terakhir';
      case TanggalFilter.tigaPuluhHari:
        return '30 Hari Terakhir';
      case TanggalFilter.bulanIni:
        return 'Bulan Ini';
      case TanggalFilter.custom:
        return 'Custom';
    }
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.terbaru:
        return 'Terbaru';
      case SortOption.terlama:
        return 'Terlama';
      case SortOption.terbesar:
        return 'Terbesar';
      case SortOption.terkecil:
        return 'Terkecil';
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_dariTanggal ?? now) : (_sampaiTanggal ?? now),
      firstDate: DateTime(2000),
      lastDate: now,
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _dariTanggal = picked;
        } else {
          _sampaiTanggal = picked;
        }
      });
    }
  }

  void _apply() {
    final minText = _minController.text.trim();
    final maxText = _maxController.text.trim();
    final filters = SearchFilters(
      jenisFilter: _jenisFilter,
      tanggalFilter: _tanggalFilter,
      dariTanggal: _dariTanggal,
      sampaiTanggal: _sampaiTanggal,
      jumlahMin: minText.isEmpty ? null : double.tryParse(minText),
      jumlahMax: maxText.isEmpty ? null : double.tryParse(maxText),
      sortOption: _sortOption,
    );
    Navigator.of(context).pop(filters);
  }

  void _reset() {
    setState(() {
      _jenisFilter = JenisFilter.semua;
      _tanggalFilter = TanggalFilter.semua;
      _dariTanggal = null;
      _sampaiTanggal = null;
      _minController.clear();
      _maxController.clear();
      _sortOption = SortOption.terbaru;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Pencarian',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: _reset, child: const Text('Reset')),
                ],
              ),
            ),
            const Divider(height: 1),
            // Filters
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jenis Filter
                    const Text(
                      'Jenis Transaksi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: JenisFilter.values.map((j) {
                        return ChoiceChip(
                          label: Text(_getJenisLabel(j)),
                          selected: _jenisFilter == j,
                          onSelected: (_) => setState(() => _jenisFilter = j),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Tanggal Filter
                    const Text(
                      'Rentang Tanggal',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TanggalFilter.values.map((t) {
                        return ChoiceChip(
                          label: Text(_getTanggalLabel(t)),
                          selected: _tanggalFilter == t,
                          onSelected: (_) => setState(() => _tanggalFilter = t),
                        );
                      }).toList(),
                    ),
                    // Custom date pickers
                    if (_tanggalFilter == TanggalFilter.custom) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'Dari Tanggal',
                              date: _dariTanggal,
                              onTap: () => _pickDate(true),
                              onClear: () =>
                                  setState(() => _dariTanggal = null),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateField(
                              label: 'Sampai Tanggal',
                              date: _sampaiTanggal,
                              onTap: () => _pickDate(false),
                              onClear: () =>
                                  setState(() => _sampaiTanggal = null),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Jumlah Range
                    const Text(
                      'Rentang Jumlah',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Min (Rp)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Max (Rp)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Sort Option
                    const Text(
                      'Urutkan Berdasarkan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: SortOption.values.map((s) {
                        return ChoiceChip(
                          label: Text(_getSortLabel(s)),
                          selected: _sortOption == s,
                          onSelected: (_) => setState(() => _sortOption = s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Terapkan Filter'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          date != null
              ? DateFormat('d MMM yyyy', 'id_ID').format(date!)
              : 'Pilih Tanggal',
          style: TextStyle(color: date != null ? null : Colors.grey),
        ),
      ),
    );
  }
}

Future<void> showEditTransaksiSheet(
  BuildContext context,
  Transaksi transaksi, {
  VoidCallback? onSave,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Material(
      color: Colors.transparent,
      child: EditTransaksiSheet(transaksi: transaksi, onSave: onSave ?? () {}),
    ),
  );
}
