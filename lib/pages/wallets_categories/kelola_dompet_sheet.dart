import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../data/database_helper.dart';
import '../../utils/formatters.dart';
import '../../utils/ui_utils.dart';

class KelolaDompetSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;

  const KelolaDompetSheet({super.key, required this.onSaved});

  @override
  ConsumerState<KelolaDompetSheet> createState() => _KelolaDompetSheetState();
}

class _KelolaDompetSheetState extends ConsumerState<KelolaDompetSheet> {
  List<Dompet> _dompetList = [];
  final _namaController = TextEditingController();
  String _warna = 'green';
  String _currency = 'IDR';

  final _warnaList = [
    'green',
    'blue',
    'red',
    'orange',
    'purple',
    'teal',
    'pink',
    'amber',
  ];

  final _currencyList = ['IDR', 'USD', 'EUR', 'JPY', 'SGD', 'MYR'];

  @override
  void initState() {
    super.initState();
    _loadDompet();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _loadDompet() async {
    final list = await DatabaseHelper.instance.getAllDompet();
    // Compute and sync saldo for each dompet
    for (var dompet in list) {
      if (dompet.id != null) {
        await DatabaseHelper.instance.syncDompetSaldo(dompet.id!);
      }
    }
    // Reload to get updated saldo
    final updatedList = await DatabaseHelper.instance.getAllDompet();
    setState(() => _dompetList = updatedList);
  }

  Future<void> _tambahDompet() async {
    if (_namaController.text.isEmpty) return;
    await DatabaseHelper.instance.insertDompet(
      Dompet(nama: _namaController.text, warna: _warna, currency: _currency),
    );
    _namaController.clear();
    await _loadDompet();
    widget.onSaved();
  }

  Future<void> _hapusDompet(Dompet dompet) async {
    if (_dompetList.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal harus ada 1 dompet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final dompetId = dompet.id;
    if (dompetId == null) return;
    final txCount = await DatabaseHelper.instance.getTransactionCountByDompet(
      dompetId,
    );
    if (!mounted) return;
    String message = 'Hapus "${dompet.nama}"?';
    if (txCount > 0) {
      message =
          '"${dompet.nama}" masih digunakan oleh $txCount transaksi. Tetap hapus?';
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dompet'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              txCount > 0 ? 'Tetap Hapus' : 'Hapus',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (dompet.id != null) {
        await DatabaseHelper.instance.deleteDompet(dompet.id!);
        await _loadDompet();
        widget.onSaved();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kelola Dompet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Dompet',
                      hintText: 'Dompet baru',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  initialValue: _warna,
                  onSelected: (v) => setState(() => _warna = v),
                  itemBuilder: (context) => _warnaList
                      .map(
                        (w) => PopupMenuItem(
                          value: w,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: getAppColor(w),
                          ),
                        ),
                      )
                      .toList(),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: getAppColor(_warna),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  initialValue: _currency,
                  onSelected: (v) => setState(() => _currency = v),
                  tooltip: 'Mata uang',
                  itemBuilder: (context) => _currencyList
                      .map(
                        (c) => PopupMenuItem(
                          value: c,
                          child: Text(
                            '$c (${getCurrencySymbol(c)})',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currency,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _tambahDompet,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _dompetList.length,
                itemBuilder: (context, index) {
                  final dompet = _dompetList[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: getAppColor(dompet.warna),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(dompet.nama),
                      subtitle: Text(
                        'Saldo: ${formatCurrency(dompet.saldo, dompet.currency)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusDompet(dompet),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
