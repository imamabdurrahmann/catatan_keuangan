import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class TrashSheet extends ConsumerWidget {
  final VoidCallback onPulihkan;

  const TrashSheet({super.key, required this.onPulihkan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedAsync = ref.watch(deletedTransaksiProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tong Sampah',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Transaksi yang dihapus dapat dipulihkan dalam 30 hari.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: deletedAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (deletedList) {
                    if (deletedList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tong sampah kosong',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: deletedList.length,
                      itemBuilder: (context, index) {
                        final tx = deletedList[index];
                        return _DeletedTransaksiItem(
                          transaksi: tx,
                          onPulihkan: () async {
                            if (tx.id == null) return;
                            await ref
                                .read(transaksiProvider.notifier)
                                .restore(tx.id!);
                            ref.invalidate(deletedTransaksiProvider);
                            ref
                                .read(updateSignalsProvider.notifier)
                                .signal('transaksi');
                            onPulihkan();
                          },
                          onPermanentDelete: () async {
                            if (tx.id == null) return;
                            final confirm = await showDeleteConfirmation(
                              context,
                              title: 'Hapus Permanen',
                              message:
                                  'Transaksi "${tx.deskripsi}" akan dihapus permanen dan tidak dapat dipulihkan.',
                              confirmLabel: 'Hapus Permanen',
                            );
                            if (confirm) {
                              await ref
                                  .read(transaksiProvider.notifier)
                                  .permanentDelete(tx.id!);
                              ref.invalidate(deletedTransaksiProvider);
                              ref
                                  .read(updateSignalsProvider.notifier)
                                  .signal('transaksi');
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeletedTransaksiItem extends StatelessWidget {
  final Transaksi transaksi;
  final VoidCallback onPulihkan;
  final VoidCallback onPermanentDelete;

  const _DeletedTransaksiItem({
    required this.transaksi,
    required this.onPulihkan,
    required this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPemasukan = transaksi.jenis == 'pemasukan';
    final color = isPemasukan ? Colors.green : Colors.red;
    final icon = isPemasukan ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          transaksi.deskripsi,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${transaksi.kategori} • ${DateFormat('d MMM', 'id_ID').format(transaksi.tanggal)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (transaksi.deletedAt != null)
              Text(
                'Dihapus: ${DateFormat('d MMM yyyy', 'id_ID').format(transaksi.deletedAt!)}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.blue),
              tooltip: 'Pulihkan',
              onPressed: onPulihkan,
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'Hapus permanen',
              onPressed: onPermanentDelete,
            ),
          ],
        ),
      ),
    );
  }
}
