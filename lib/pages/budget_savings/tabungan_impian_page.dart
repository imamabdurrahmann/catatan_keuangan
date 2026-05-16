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

class TabunganImpianPage extends ConsumerWidget {
  const TabunganImpianPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(tabunganImpianListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tabungan Impian',
          style: AppTypography.titleLarge(
            context,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 60,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Anda belum memiliki target tabungan.',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16).copyWith(bottom: 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _TabunganCard(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        backgroundColor: AppColors.emerald,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Target', style: TextStyle(color: Colors.white)),
      ),
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
      builder: (ctx) =>
          Material(color: Colors.transparent, child: const _AddTabunganSheet()),
    );
  }
}

class _TabunganCard extends ConsumerWidget {
  final TabunganImpian item;

  const _TabunganCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = item.targetNominal > 0
        ? (item.terkumpul / item.targetNominal).clamp(0.0, 1.0)
        : 0.0;
    final isDone = progress >= 1.0;

    return GestureDetector(
      onTap: () => _showDetailDialog(context, ref),
      child: Container(
        decoration: AppDecorations.glassCardElevated(context),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      isDone ? AppColors.gold : AppColors.emerald,
                    ),
                  ),
                ),
                Icon(
                  getAppIcon(item.icon),
                  color: isDone ? AppColors.gold : AppColors.emerald,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.namaImpian,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDone ? AppColors.gold : AppColors.emerald,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              formatRupiahCompact(item.terkumpul),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              'dari ${formatRupiahCompact(item.targetNominal)}',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: _TabunganActionSheet(item: item),
      ),
    );
  }
}

class _TabunganActionSheet extends ConsumerStatefulWidget {
  final TabunganImpian item;
  const _TabunganActionSheet({required this.item});

  @override
  ConsumerState<_TabunganActionSheet> createState() =>
      _TabunganActionSheetState();
}

class _TabunganActionSheetState extends ConsumerState<_TabunganActionSheet> {
  final _amount = TextEditingController();
  int? _selectedDompetId;
  bool _syncToDompet = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                widget.item.namaImpian,
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
          const SizedBox(height: 8),
          Text(
            'Kekurangan: Rp ${formatRupiahCompact(widget.item.targetNominal - widget.item.terkumpul)}',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal Tabung (Rp)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Ambil Porsi dari Dompet / Kas',
              style: TextStyle(fontSize: 14),
            ),
            value: _syncToDompet,
            activeColor: AppColors.emerald,
            onChanged: (val) => setState(() => _syncToDompet = val ?? true),
          ),
          if (_syncToDompet)
            ref
                .watch(dompetProvider)
                .when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (dompetList) {
                    if (dompetList.isEmpty)
                      return const Text('Belum ada dompet');
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
                            if (val != null)
                              setState(() => _selectedDompetId = val);
                          },
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final val = double.tryParse(_amount.text) ?? 0;
                    if (val > 0) {
                      await DatabaseHelper.instance.addProgressTabunganImpian(
                        widget.item.id!,
                        val,
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
                          final tx = Transaksi(
                            jenis: AppConstants.jenisPengeluaran,
                            jumlah: val,
                            deskripsi:
                                'Menabung untuk ${widget.item.namaImpian}',
                            kategori: 'Tabungan',
                            tanggal: DateTime.now(),
                            idDompet: finalDompetId,
                          );
                          await DatabaseHelper.instance.insertTransaksi(tx);
                          ref
                              .read(updateSignalsProvider.notifier)
                              .signal('transaksi');
                          ref
                              .read(updateSignalsProvider.notifier)
                              .signal('dompet');
                        }
                      }

                      ref
                          .read(updateSignalsProvider.notifier)
                          .signal('tabungan');
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Tabungkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.coral.withValues(alpha: 0.1),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Target'),
                      content: const Text(
                        'Anda yakin ingin menghapus Tabungan Impian ini?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await DatabaseHelper.instance.deleteTabunganImpian(
                              widget.item.id!,
                            );
                            ref
                                .read(updateSignalsProvider.notifier)
                                .signal('tabungan');
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete, color: AppColors.coral),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AddTabunganSheet extends ConsumerStatefulWidget {
  const _AddTabunganSheet();

  @override
  ConsumerState<_AddTabunganSheet> createState() => _AddTabunganSheetState();
}

class _AddTabunganSheetState extends ConsumerState<_AddTabunganSheet> {
  final _nama = TextEditingController();
  final _nominal = TextEditingController();
  DateTime? _tenggatWaktu;

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
                'Target Baru',
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
          TextField(
            controller: _nama,
            decoration: const InputDecoration(
              labelText: 'Nama Barang/Tujuan (Cth: Laptop)',
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
              labelText: 'Target Nominal',
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
                  ? 'Set Target Tanggal (Opsional)'
                  : DateFormat('dd MMMM yyyy').format(_tenggatWaktu!),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2050),
              );
              if (picked != null) setState(() => _tenggatWaktu = picked);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              if (_nama.text.isEmpty || _nominal.text.isEmpty) return;
              final val = parseRupiah(_nominal.text);
              if (val <= 0) return;

              await DatabaseHelper.instance.insertTabunganImpian(
                TabunganImpian(
                  namaImpian: _nama.text,
                  targetNominal: val,
                  targetTanggal: _tenggatWaktu,
                  icon: 'star',
                ),
              );
              ref.read(updateSignalsProvider.notifier).signal('tabungan');
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              'Simpan Target',
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
