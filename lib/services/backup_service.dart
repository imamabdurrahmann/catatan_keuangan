import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../data/database.dart';
import '../services/error_service.dart';
import '../services/file_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._();
  static BackupService get instance => _instance;
  BackupService._();

  static const String _lastBackupDateKey = 'last_backup_date';

  /// Creates a JSON backup of all app data and returns the JSON string.
  Future<String> createBackup() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final transaksis = await db.query(TABLE_TRANSAKSI);
      final dompets = await db.query(TABLE_DOMPET);
      final kategoris = await db.query(TABLE_KATEGORI);
      final budgets = await db.query(TABLE_BUDGET);
      final utangPiutangs = await db.query(TABLE_UTANG_PIUTANG);
      final historyCicilans = await db.query(TABLE_HISTORY_CICILAN);
      final tabungans = await db.query(TABLE_TABUNGAN_IMPIAN);
      final pengaturans = await db.query(TABLE_PENGATURAN);

      final backup = {
        'version': '1.0.0',
        'createdAt': DateTime.now().toIso8601String(),
        'tables': {
          'transaksi': transaksis,
          'dompet': dompets,
          'kategori': kategoris,
          'budget': budgets,
          'utang_piutang': utangPiutangs,
          'history_cicilan': historyCicilans,
          'tabungan_impian': tabungans,
          'pengaturan': pengaturans,
        },
      };

      return jsonEncode(backup);
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      rethrow;
    }
  }

  /// Saves the backup JSON to a file and shares it.
  Future<String?> saveBackupFile(String jsonString) async {
    try {
      final dir = await FileService.instance.getBackupFolder();
      if (dir == null) return null;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'catatan_keuangan_backup_$timestamp.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Backup DompetKu'),
      );

      // Save last backup date
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastBackupDateKey,
        DateTime.now().toIso8601String(),
      );

      return file.path;
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      return null;
    }
  }

  /// Restores app data from a JSON backup string.
  Future<void> restoreBackup(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final tables = data['tables'] as Map<String, dynamic>;

      final db = await DatabaseHelper.instance.database;

      await db.transaction((txn) async {
        // Clear existing data in reverse dependency order
        await txn.delete(TABLE_HISTORY_CICILAN);
        await txn.delete(TABLE_UTANG_PIUTANG);
        await txn.delete(TABLE_TABUNGAN_IMPIAN);
        await txn.delete(TABLE_TRANSAKSI);
        await txn.delete(TABLE_BUDGET);
        await txn.delete(TABLE_KATEGORI);
        await txn.delete(TABLE_DOMPET);
        await txn.delete(TABLE_PENGATURAN);

        // Restore all tables
        final tableOrder = [
          TABLE_DOMPET,
          TABLE_KATEGORI,
          TABLE_PENGATURAN,
          TABLE_BUDGET,
          TABLE_TRANSAKSI,
          TABLE_UTANG_PIUTANG,
          TABLE_HISTORY_CICILAN,
          TABLE_TABUNGAN_IMPIAN,
        ];

        for (final table in tableOrder) {
          final key = _tableToKey(table);
          if (tables.containsKey(key) && tables[key] != null) {
            final rows = tables[key] as List;
            for (final row in rows) {
              await txn.insert(table, Map<String, dynamic>.from(row as Map));
            }
          }
        }
      });

      // Sync all dompet saldo from imported transaksi after restore
      final dompets = await DatabaseHelper.instance.getAllDompet();
      for (var d in dompets) {
        if (d.id != null) {
          await DatabaseHelper.instance.syncDompetSaldo(d.id!);
        }
      }
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      rethrow;
    }
  }

  /// Picks a backup JSON file from the device.
  Future<String?> pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          final file = File(path);
          return await file.readAsString();
        }
      }
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
    }
    return null;
  }

  /// Gets the last backup date from SharedPreferences.
  Future<DateTime?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_lastBackupDateKey);
    if (dateStr != null) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _tableToKey(String table) {
    switch (table) {
      case TABLE_TRANSAKSI:
        return 'transaksi';
      case TABLE_DOMPET:
        return 'dompet';
      case TABLE_KATEGORI:
        return 'kategori';
      case TABLE_BUDGET:
        return 'budget';
      case TABLE_UTANG_PIUTANG:
        return 'utang_piutang';
      case TABLE_HISTORY_CICILAN:
        return 'history_cicilan';
      case TABLE_TABUNGAN_IMPIAN:
        return 'tabungan_impian';
      case TABLE_PENGATURAN:
        return 'pengaturan';
      default:
        return table;
    }
  }
}
