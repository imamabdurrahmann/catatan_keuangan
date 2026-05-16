import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/database_helper.dart';
import '../../services/crypto_service.dart';
import '../../services/file_service.dart';
import '../../providers.dart';

// ==================== BACKUP LIST PROVIDER ====================

class BackupFile {
  final String path;
  final String fileName;
  final DateTime modified;
  final int sizeBytes;
  final bool isEncrypted;
  final String? error;

  BackupFile({
    required this.path,
    required this.fileName,
    required this.modified,
    required this.sizeBytes,
    required this.isEncrypted,
    this.error,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

final backupListProvider = FutureProvider<List<BackupFile>>((ref) async {
  final folder = await FileService.instance.getBackupFolder();
  if (folder == null) return [];
  final dir = Directory(folder.path);

  if (!await dir.exists()) return [];

  final files = await dir.list().toList();
  final backups = <BackupFile>[];

  for (final file in files) {
    if (file is File && file.path.endsWith('.json')) {
      try {
        final stat = await file.stat();
        final content = await file.readAsString();
        final isEncrypted = CryptoService.isEncrypted(content);

        backups.add(
          BackupFile(
            path: file.path,
            fileName: file.path.split(Platform.pathSeparator).last,
            modified: stat.modified,
            sizeBytes: stat.size,
            isEncrypted: isEncrypted,
          ),
        );
      } catch (e) {
        backups.add(
          BackupFile(
            path: file.path,
            fileName: file.path.split(Platform.pathSeparator).last,
            modified: DateTime.now(),
            sizeBytes: 0,
            isEncrypted: false,
            error: e.toString(),
          ),
        );
      }
    }
  }

  // Sort by modified date, newest first
  backups.sort((a, b) => b.modified.compareTo(a.modified));
  return backups;
});

// ==================== BACKUP PAGE ====================

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  bool _isEksporing = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final backupsAsync = ref.watch(backupListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Pulihkan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isEksporing ? null : _showEksporDialog,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Ekspor Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRestoring ? null : _showPulihkanFromFile,
                    icon: const Icon(Icons.download),
                    label: const Text('Pulihkan dari File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Backup list
          Expanded(
            child: backupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (backups) {
                if (backups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada cadangan data',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Klik "Ekspor Baru" untuk membuat backup',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(backupListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: backups.length,
                    itemBuilder: (context, index) {
                      final backup = backups[index];
                      return _buildBackupItem(backup);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupItem(BackupFile backup) {
    return Dismissible(
      key: Key(backup.path),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(backup),
      onDismissed: (_) => _deleteBackup(backup),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(
              backup.isEncrypted ? Icons.lock : Icons.file_copy,
              color: backup.isEncrypted ? Colors.orange : Colors.green,
            ),
          ),
          title: Text(
            backup.fileName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(backup.modified)} • ${backup.formattedSize}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (backup.isEncrypted)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Terenkripsi',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (backup.error != null)
                Text(
                  'Error: ${backup.error}',
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'restore') {
                _restoreBackup(backup);
              } else if (value == 'share') {
                _shareBackup(backup);
              } else if (value == 'delete') {
                _confirmDelete(backup).then((confirmed) {
                  if (confirmed == true) _deleteBackup(backup);
                });
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'restore',
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Pulihkan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Bagikan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Hapus', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }

  // ==================== EXPORT ====================

  void _showEksporDialog() {
    bool usePassword = false;
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Ekspor Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Lindungi cadangan dengan kata sandi?'),
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Gunakan kata sandi'),
                  value: usePassword,
                  onChanged: (v) =>
                      setDialogState(() => usePassword = v ?? false),
                ),
                if (usePassword) ...[
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Kata Sandi',
                      hintText: 'Masukkan kata sandi',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Kata Sandi',
                      hintText: 'Ulangi kata sandi',
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (usePassword) {
                    if (passwordCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Kata sandi tidak boleh kosong'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (passwordCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Kata sandi tidak cocok'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  }
                  Navigator.pop(
                    dialogCtx,
                    usePassword ? passwordCtrl.text : '',
                  );
                },
                child: const Text('Ekspor'),
              ),
            ],
          );
        },
      ),
    ).then((passwordResult) async {
      if (passwordResult == null) return;
      await _doEkspor(passwordResult as String);
    });
  }

  Future<void> _doEkspor(String password) async {
    setState(() => _isEksporing = true);

    try {
      final json = await DatabaseHelper.instance.exportToJson();
      final dataToWrite = password.isNotEmpty
          ? CryptoService.encryptData(json, password)
          : json;
      final dir = await FileService.instance.getBackupFolder();
      if (dir == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin penyimpanan ditolak. Buka Pengaturan > Aplikasi > DompetKu > Izin untuk mengaktifkan.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      final file = File(
        '${dir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(dataToWrite);

      // Refresh list
      ref.invalidate(backupListProvider);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Ekspor Berhasil'),
          content: Text(
            'Cadangan tersimpan di:\n${file.path}${password.isNotEmpty ? '\n\n(File terenkripsi AES-256)' : ''}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(c);
                SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    text: 'Backup DompetKu',
                  ),
                );
              },
              child: const Text('Bagikan'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEksporing = false);
    }
  }

  // ==================== RESTORE ====================

  void _showPulihkanFromFile() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Pulihkan Data'),
        content: const Text(
          'Ini akan MENGGANTIKAN semua data saat ini dengan data dari file cadangan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _pickAndPulihkan();
            },
            child: const Text('Pilih File'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndPulihkan() async {
    setState(() => _isRestoring = true);

    try {
      final file = await FileService.instance.pickAnyFile();
      if (file == null) {
        setState(() => _isRestoring = false);
        return;
      }

      String content;
      try {
        content = await file.readAsString();
      } catch (e) {
        setState(() => _isRestoring = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membaca file: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        await _processPulihkanContent(content);
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _restoreBackup(BackupFile backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pulihkan Cadangan'),
        content: Text(
          'Yakin ingin memulihkan "${backup.fileName}"?\n\nIni akan MENGGANTIKAN semua data saat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);

    try {
      final file = File(backup.path);
      String content = await file.readAsString();
      await _processPulihkanContent(content);
    } catch (e) {
      setState(() => _isRestoring = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulihkan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPulihkanContent(String content) async {
    if (CryptoService.isEncrypted(content)) {
      final passwordCtrl = TextEditingController();
      final enteredPassword = await showDialog<String>(
        context: context,
        builder: (pwdCtx) => AlertDialog(
          title: const Text('File Terenkripsi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan kata sandi untuk membuka file cadangan.'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi'),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(pwdCtx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(pwdCtx, passwordCtrl.text),
              child: const Text('Dekripsi'),
            ),
          ],
        ),
      );

      if (enteredPassword == null || enteredPassword.isEmpty) {
        setState(() => _isRestoring = false);
        return;
      }

      try {
        content = CryptoService.decryptData(content, enteredPassword);
      } catch (e) {
        setState(() => _isRestoring = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kata sandi salah atau file rusak'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memulihkan data...'),
          ],
        ),
      ),
    );

    try {
      await DatabaseHelper.instance.importFromJson(content);
      if (!mounted) return;

      // Pop the loading dialog
      Navigator.of(context).pop();

      // Invalidate all providers to ensure fresh data after restore
      ref.invalidate(transaksiProvider);
      ref.invalidate(dompetProvider);
      ref.invalidate(kategoriProvider);
      ref.invalidate(tabunganImpianListProvider);
      ref.invalidate(utangPiutangListProvider);
      ref.read(updateSignalsProvider.notifier).signal('transaksi');
      ref.read(updateSignalsProvider.notifier).signal('dompet');
      ref.read(updateSignalsProvider.notifier).signal('tabungan');
      ref.read(updateSignalsProvider.notifier).signal('utangPiutang');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dipulihkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulihkan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  // ==================== SHARE ====================

  void _shareBackup(BackupFile backup) {
    SharePlus.instance.share(
      ShareParams(files: [XFile(backup.path)], text: 'Backup DompetKu'),
    );
  }

  // ==================== DELETE ====================

  Future<bool?> _confirmDelete(BackupFile backup) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Cadangan'),
        content: Text('Yakin ingin menghapus "${backup.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBackup(BackupFile backup) async {
    try {
      await FileService.instance.deleteFile(backup.path);
      ref.invalidate(backupListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup "${backup.fileName}" dihapus'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ref.invalidate(backupListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
