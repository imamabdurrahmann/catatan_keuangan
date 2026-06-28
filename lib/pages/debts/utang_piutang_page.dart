import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../models/constants.dart';
import '../../providers.dart';
import '../../data/database_helper.dart';
import '../../theme/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/ui_utils.dart';

class UtangPiutangPage extends ConsumerWidget {
  const UtangPiutangPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(utangPiutangListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Utang & Piutang',
            style: AppTypography.titleLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primaryMid,
            labelColor: isDark ? AppColors.emerald : AppColors.primaryMid,
            unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
            tabs: const [
              Tab(text: 'Saya Berutang (Utang)'),
              Tab(text: 'Orang Berutang (Piutang)'),
            ],
          ),
        ),
        body: listAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (data) {
            final utang = data.where((e) => e.jenis == 'utang').toList();
            final piutang = data.where((e) => e.jenis == 'piutang').toList();

            return TabBarView(
              children: [
                _buildList(context, ref, utang, 'utang', isDark),
                _buildList(context, ref, piutang, 'piutang', isDark),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddDialog(context, ref),
          backgroundColor: AppColors.primaryMid,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Catat Baru',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<UtangPiutang> list,
    String jenis,
    bool isDark,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              jenis == 'utang'
                  ? 'Anda tidak memiliki utang.'
                  : 'Tidak ada piutang pending.',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final progress = item.nominalTotal > 0
            ? (item.nominalDibayar / item.nominalTotal).clamp(0.0, 1.0)
            : 0.0;
        final color = item.jenis == 'utang'
            ? AppColors.coral
            : AppColors.emerald;

        final card = Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            title: Text(
              item.namaOrang,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                decoration: item.isLunas ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ${formatRupiahCompact(item.nominalTotal)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      item.isLunas ? AppColors.gold : color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terbayar: ${formatRupiahCompact(item.nominalDibayar)} (${(progress * 100).toInt()}%)',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (item.tenggatWaktu != null)
                      Text(
                        'Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(item.tenggatWaktu!)}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    if (item.deskripsi != null &&
                        item.deskripsi!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Catatan: ${item.deskripsi}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!item.isLunas)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMid,
                            ),
                            onPressed: () => _showPayDialog(context, ref, item),
                            icon: const Icon(
                              Icons.payment,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              item.jenis == 'utang'
                                  ? 'Bayar Utang'
                                  : 'Terima Cicilan',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        TextButton.icon(
                          onPressed: () => _deleteItem(context, ref, item.id!),
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.coral,
                            size: 18,
                          ),
                          label: const Text(
                            'Hapus',
                            style: TextStyle(color: AppColors.coral),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Riwayat Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _HistoryListView(idUtangPiutang: item.id!),
                  ],
                ),
              ),
            ],
          ),
        );

        return Dismissible(
          key: Key('utang_piutang_${item.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_rounded, color: AppColors.coral),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Hapus Data'),
                content: const Text(
                  'Yakin ingin menghapus riwayat ini secara permanen?',
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
          },
          onDismissed: (_) async {
            await DatabaseHelper.instance.deleteUtangPiutang(item.id!);
            ref.read(updateSignalsProvider.notifier).signal('utangPiutang');
          },
          child: card,
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: const _AddUtangPiutangSheet(),
      ),
    );
  }

  void _showPayDialog(BuildContext context, WidgetRef ref, UtangPiutang item) {
    showDialog(
      context: context,
      builder: (ctx) => _PayDialog(item: item),
    );
  }

  void _deleteItem(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text(
          'Yakin ingin menghapus riwayat ini secara permanen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteUtangPiutang(id);
              ref.read(updateSignalsProvider.notifier).signal('utangPiutang');
              if (context.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AddUtangPiutangSheet extends ConsumerStatefulWidget {
  const _AddUtangPiutangSheet();

  @override
  ConsumerState<_AddUtangPiutangSheet> createState() =>
      _AddUtangPiutangSheetState();
}

class _AddUtangPiutangSheetState extends ConsumerState<_AddUtangPiutangSheet> {
  final _namaOrang = TextEditingController();
  final _nominal = TextEditingController();
  final _deskripsi = TextEditingController();
  DateTime? _tenggatWaktu;
  String _jenis = 'utang';
  int? _selectedDompetId;
  bool _syncToDompet = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catat Baru',
                style: AppTypography.titleLarge(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'utang',
                label: Text('Saya Berutang'),
                icon: Icon(Icons.arrow_upward),
              ),
              ButtonSegment(
                value: 'piutang',
                label: Text('Orang Berutang'),
                icon: Icon(Icons.arrow_downward),
              ),
            ],
            selected: {_jenis},
            onSelectionChanged: (val) => setState(() => _jenis = val.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _namaOrang,
            decoration: const InputDecoration(
              labelText: 'Nama Peminjam / Yang Dihutangi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nominal,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Nominal Total',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              _tenggatWaktu == null
                  ? 'Set Tenggat Waktu (Opsional)'
                  : DateFormat('dd MMMM yyyy').format(_tenggatWaktu!),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2050),
              );
              if (picked != null) setState(() => _tenggatWaktu = picked);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _deskripsi,
            decoration: const InputDecoration(
              labelText: 'Catatan (Opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Sinkronkan ke Dompet',
              style: TextStyle(fontSize: 14),
            ),
            value: _syncToDompet,
            activeColor: AppColors.primaryMid,
            onChanged: (val) => setState(() => _syncToDompet = val ?? true),
          ),
          if (_syncToDompet)
            ref
                .watch(dompetProvider)
                .when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (dompetList) {
                    if (dompetList.isEmpty) {
                      return const Text('Belum ada dompet');
                    }
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard.withValues(alpha: 0.5)
                            : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(8),
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
                              child: Text(
                                d.nama,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
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
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMid,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              if (_namaOrang.text.isEmpty || _nominal.text.isEmpty) return;
              final val = parseRupiah(_nominal.text);
              if (val <= 0) return;

              await DatabaseHelper.instance.insertUtangPiutang(
                UtangPiutang(
                  namaOrang: _namaOrang.text,
                  jenis: _jenis,
                  nominalTotal: val,
                  tanggal: DateTime.now(),
                  tenggatWaktu: _tenggatWaktu,
                  deskripsi: _deskripsi.text,
                ),
              );

              if (_syncToDompet) {
                int? finalDompetId = _selectedDompetId;
                if (finalDompetId == null) {
                  final dompets = ref.read(dompetProvider).value;
                  if (dompets != null && dompets.isNotEmpty) {
                    finalDompetId = dompets.first.id;
                  }
                }

                if (finalDompetId != null) {
                  // Utang: We receive cash (Pemasukan)
                  // Piutang: We give cash (Pengeluaran)
                  final isUtang = _jenis == 'utang';
                  final tx = Transaksi(
                    jenis: isUtang
                        ? AppConstants.jenisPemasukan
                        : AppConstants.jenisPengeluaran,
                    jumlah: val,
                    deskripsi: isUtang
                        ? 'Terima pinjaman dari ${_namaOrang.text}'
                        : 'Memberi pinjaman ke ${_namaOrang.text}',
                    kategori: isUtang ? 'Utang' : 'Piutang',
                    tanggal: DateTime.now(),
                    idDompet: finalDompetId,
                  );
                  await DatabaseHelper.instance.insertTransaksi(tx);
                }
              }

              ref.read(updateSignalsProvider.notifier).signal('utangPiutang');
              ref.read(updateSignalsProvider.notifier).signal('dompet');
              ref.read(updateSignalsProvider.notifier).signal('transaksi');
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Simpan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _HistoryListView extends ConsumerWidget {
  final int idUtangPiutang;
  const _HistoryListView({required this.idUtangPiutang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actAsync = ref.watch(historyCicilanProvider(idUtangPiutang));

    return actAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Text('Error: $err'),
      data: (data) {
        if (data.isEmpty) {
          return const Text(
            'Belum ada pembayaran.',
            style: TextStyle(fontStyle: FontStyle.italic),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final cicilan = data[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(
                Icons.check_circle,
                color: AppColors.emerald,
                size: 16,
              ),
              title: Text('Rp ${formatRupiahCompact(cicilan.nominal)}'),
              subtitle: Text(
                DateFormat('dd MMM yyyy HH:mm').format(cicilan.tanggal),
                style: const TextStyle(fontSize: 10),
              ),
            );
          },
        );
      },
    );
  }
}

class _PayDialog extends ConsumerStatefulWidget {
  final UtangPiutang item;
  const _PayDialog({required this.item});

  @override
  ConsumerState<_PayDialog> createState() => _PayDialogState();
}

class _PayDialogState extends ConsumerState<_PayDialog> {
  final controller = TextEditingController();
  int? _selectedDompetId;
  bool _syncToDompet = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        widget.item.jenis == 'utang' ? 'Bayar Utang' : 'Terima Pembayaran',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sisa: ${formatRupiahCompact(widget.item.nominalTotal - widget.item.nominalDibayar)}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Sinkronkan ke Dompet',
                style: TextStyle(fontSize: 14),
              ),
              value: _syncToDompet,
              activeColor: AppColors.primaryMid,
              onChanged: (val) => setState(() => _syncToDompet = val ?? true),
            ),
            if (_syncToDompet)
              ref
                  .watch(dompetProvider)
                  .when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (dompetList) {
                      if (dompetList.isEmpty) {
                        return const Text('Belum ada dompet');
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard.withValues(alpha: 0.5)
                              : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(8),
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
                                      size: 16,
                                      color: getAppColor(d.warna),
                                    ),
                                    const SizedBox(width: 8),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final val = parseRupiah(controller.text);
            if (val > 0) {
              await DatabaseHelper.instance.insertHistoryCicilan(
                HistoryCicilan(
                  idUtangPiutang: widget.item.id!,
                  nominal: val,
                  tanggal: DateTime.now(),
                ),
              );

              if (_syncToDompet) {
                int? finalDompetId = _selectedDompetId;
                if (finalDompetId == null) {
                  final dompets = ref.read(dompetProvider).value;
                  if (dompets != null && dompets.isNotEmpty) {
                    finalDompetId = dompets.first.id;
                  }
                }

                if (finalDompetId != null) {
                  final isUtang = widget.item.jenis == 'utang';
                  final tx = Transaksi(
                    jenis: isUtang
                        ? AppConstants.jenisPengeluaran
                        : AppConstants.jenisPemasukan,
                    jumlah: val,
                    deskripsi: isUtang
                        ? 'Bayar utang ke ${widget.item.namaOrang}'
                        : 'Terima cicilan piutang dari ${widget.item.namaOrang}',
                    kategori: isUtang
                        ? 'Pembayaran Utang'
                        : 'Penerimaan Piutang',
                    tanggal: DateTime.now(),
                    idDompet: finalDompetId,
                  );
                  await DatabaseHelper.instance.insertTransaksi(tx);
                }
              }

              ref.read(updateSignalsProvider.notifier).signal('utangPiutang');
              ref.read(updateSignalsProvider.notifier).signal('dompet');
              ref.read(updateSignalsProvider.notifier).signal('transaksi');
              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
