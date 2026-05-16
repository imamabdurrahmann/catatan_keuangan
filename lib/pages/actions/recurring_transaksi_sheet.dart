import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../data/database_helper.dart';
import '../../utils/formatters.dart';

class RecurringTransaksiSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const RecurringTransaksiSheet({super.key, required this.onSaved});

  @override
  State<RecurringTransaksiSheet> createState() =>
      _RecurringTransaksiSheetState();
}

class _RecurringTransaksiSheetState extends State<RecurringTransaksiSheet> {
  List<Transaksi> _recurringList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseHelper.instance.getRecurringTransaksi();
    setState(() {
      _recurringList = list;
      _isLoading = false;
    });
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Berulang',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_recurringList.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.repeat, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi berulang',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _recurringList.length,
                  itemBuilder: (context, index) {
                    final tx = _recurringList[index];
                    final isPemasukan = tx.jenis == 'pemasukan';
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isPemasukan
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: isPemasukan ? Colors.green : Colors.red,
                        ),
                        title: Text(tx.deskripsi),
                        subtitle: Text(
                          '${tx.kategori} • ${tx.recurringFrequency ?? "bulanan"}',
                        ),
                        trailing: Text(
                          'Rp ${formatRupiah(tx.jumlah)}',
                          style: TextStyle(
                            color: isPemasukan ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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
