import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../data/database_helper.dart';
import '../../providers.dart';
import '../../utils/ui_utils.dart';

class KelolaKategoriSheet extends ConsumerStatefulWidget {
  final VoidCallback? onChanged;

  const KelolaKategoriSheet({super.key, this.onChanged});

  @override
  ConsumerState<KelolaKategoriSheet> createState() =>
      _KelolaKategoriSheetState();
}

class _KelolaKategoriSheetState extends ConsumerState<KelolaKategoriSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Kategori> _kategoriList = [];
  final _namaController = TextEditingController();
  String _selectedIcon = 'category';
  String _jenis = 'pengeluaran';
  bool _isLoading = true;

  final _iconOptions = [
    'restaurant',
    'directions_car',
    'shopping_bag',
    'movie',
    'receipt',
    'local_hospital',
    'home',
    'school',
    'checkroom',
    'phone_android',
    'business',
    'more_horiz',
    'payments',
    'card_giftcard',
    'store',
    'trending_up',
    'redeem',
    'category',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(
        () => _jenis = _tabController.index == 0 ? 'pengeluaran' : 'pemasukan',
      );
    });
    _loadKategori();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _loadKategori() async {
    final list = await DatabaseHelper.instance.getAllKategori();
    setState(() {
      _kategoriList = list;
      _isLoading = false;
    });
  }

  List<Kategori> get _filtered =>
      _kategoriList.where((k) => k.jenis == _jenis).toList();

  Future<void> _tambahKategori() async {
    if (_namaController.text.isEmpty) return;
    await DatabaseHelper.instance.insertKategori(
      Kategori(nama: _namaController.text, jenis: _jenis, icon: _selectedIcon),
    );
    _namaController.clear();
    ref.invalidate(kategoriProvider);
    await _loadKategori();
    widget.onChanged?.call();
  }

  Future<void> _hapusKategori(Kategori kategori) async {
    if (kategori.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori bawaan tidak bisa dihapus'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final kategoriId = kategori.id;
    if (kategoriId == null) return;
    final txCount = await DatabaseHelper.instance.getTransactionCountByKategori(
      kategori.nama,
    );
    if (!mounted) return;
    String message = 'Hapus "${kategori.nama}"?';
    if (txCount > 0) {
      message =
          '"${kategori.nama}" masih digunakan oleh $txCount transaksi. Tetap hapus?';
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
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
      if (kategori.id != null) {
        await DatabaseHelper.instance.deleteKategori(kategori.id!);
        ref.invalidate(kategoriProvider);
        await _loadKategori();
        widget.onChanged?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kelola Kategori',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              tabs: const [
                Tab(text: 'Pengeluaran'),
                Tab(text: 'Pemasukan'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kategori',
                      hintText: 'Kategori baru',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  initialValue: _selectedIcon,
                  onSelected: (v) => setState(() => _selectedIcon = v),
                  itemBuilder: (context) => _iconOptions
                      .map(
                        (icon) => PopupMenuItem(
                          value: icon,
                          child: Row(
                            children: [
                              Icon(getAppIcon(icon), size: 20),
                              const SizedBox(width: 8),
                              Text(icon),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(getAppIcon(_selectedIcon)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _tambahKategori,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final k = _filtered[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Icon(
                                getAppIcon(k.icon),
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            title: Text(k.nama),
                            subtitle: k.isDefault
                                ? const Text(
                                    'Default',
                                    style: TextStyle(fontSize: 11),
                                  )
                                : null,
                            trailing: k.isDefault
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _hapusKategori(k),
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
