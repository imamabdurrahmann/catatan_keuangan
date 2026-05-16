import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database_helper.dart';
import '../data/database.dart';
import '../services/error_service.dart';

/// Service for exporting data to various formats (CSV, etc.).
class ExportService {
  static final ExportService _instance = ExportService._();
  static ExportService get instance => _instance;
  ExportService._();

  static const String _csvDelimiter = ';';

  /// UTF-8 BOM prefix for Excel compatibility.
  static const String _utf8Bom = '\uFEFF';

  /// Converts a single field value to a CSV-safe string.
  /// Encloses the value in double quotes if it contains the delimiter, newline, or double quotes,
  /// and escapes internal double quotes by doubling them.
  String _escapeCsvField(String value) {
    if (value.contains(_csvDelimiter) ||
        value.contains('\n') ||
        value.contains('\r') ||
        value.contains('"')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Exports all non-deleted transactions to a CSV string.
  /// Returns the CSV content with UTF-8 BOM prefix.
  Future<String> exportTransactionsToCsv() async {
    return _buildCsvContent(
      whereClauses: ['deleted_at IS NULL'],
      whereArgs: [],
      orderBy: 'tanggal DESC',
    );
  }

  /// Exports transactions filtered by month/year and optionally by dompet.
  /// Returns CSV string with UTF-8 BOM.
  Future<String> exportTransactionsToCsvFiltered({
    int? bulan,
    int? tahun,
    int? idDompet,
  }) async {
    final whereClauses = <String>['deleted_at IS NULL'];
    final whereArgs = <dynamic>[];

    if (bulan != null && tahun != null) {
      // Filter by month/year using SQLite strftime
      whereClauses.add("strftime('%m', tanggal) = ?");
      whereArgs.add(bulan.toString().padLeft(2, '0'));
      whereClauses.add("strftime('%Y', tanggal) = ?");
      whereArgs.add(tahun.toString());
    }

    if (idDompet != null) {
      whereClauses.add('id_dompet = ?');
      whereArgs.add(idDompet);
    }

    return _buildCsvContent(
      whereClauses: whereClauses,
      whereArgs: whereArgs,
      orderBy: 'tanggal DESC',
    );
  }

  /// Internal helper that builds CSV content from the given filter conditions.
  Future<String> _buildCsvContent({
    required List<String> whereClauses,
    required List<dynamic> whereArgs,
    required String orderBy,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final transaksiMaps = await db.query(
        TABLE_TRANSAKSI,
        where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: orderBy,
      );

      final transaksis = transaksiMaps.map((map) {
        List<String> parsedLampiran = [];
        if (map['lampiran'] != null && map['lampiran'].toString().isNotEmpty) {
          try {
            final decoded = jsonDecode(map['lampiran'] as String);
            if (decoded is List) {
              parsedLampiran = decoded.cast<String>();
            }
          } catch (_) {
            parsedLampiran = [];
          }
        }
        return {...map, '_lampiran_list': parsedLampiran};
      }).toList();

      // Pre-fetch all wallets in a single query for efficient name lookup.
      final dompetMaps = await db.query(TABLE_DOMPET);
      final dompetById = <int, String>{};
      for (final row in dompetMaps) {
        final id = row['id'] as int?;
        if (id != null) {
          dompetById[id] = row['nama'] as String;
        }
      }

      // Locale-aware formatters for Indonesian locale.
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
      final numberFormatter = NumberFormat.decimalPattern('id_ID');

      final header = [
        'Tanggal',
        'Jenis',
        'Jumlah',
        'Kategori',
        'Deskripsi',
        'Dompet',
        'Lampiran',
      ].join(_csvDelimiter);

      final rows = <String>[header];

      for (final tx in transaksis) {
        final jenisValue = tx['jenis'] as String;
        final jenisLabel = jenisValue == 'pemasukan'
            ? 'Pemasukan'
            : 'Pengeluaran';

        final jumlah = (tx['jumlah'] as num).toDouble();
        final jumlahFormatted = numberFormatter.format(jumlah);

        final tanggal = DateTime.parse(tx['tanggal'] as String);
        final tanggalFormatted = dateFormatter.format(tanggal);

        final kategori = tx['kategori'] as String;
        final deskripsi = tx['deskripsi'] as String;
        final idDompet = tx['id_dompet'] as int?;
        final dompetNama = idDompet != null
            ? (dompetById[idDompet] ?? '-')
            : '-';
        final lampiranList = tx['_lampiran_list'] as List<String>;
        final lampiranValue = lampiranList.isEmpty
            ? '-'
            : lampiranList.join(', ');

        rows.add(
          [
            _escapeCsvField(tanggalFormatted),
            _escapeCsvField(jenisLabel),
            _escapeCsvField(jumlahFormatted),
            _escapeCsvField(kategori),
            _escapeCsvField(deskripsi),
            _escapeCsvField(dompetNama),
            _escapeCsvField(lampiranValue),
          ].join(_csvDelimiter),
        );
      }

      // Prepend UTF-8 BOM for Excel compatibility.
      return '$_utf8Bom${rows.join('\r\n')}\r\n';
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      rethrow;
    }
  }

  /// Saves the CSV string to a temporary file and shares it via share_plus.
  /// Returns the file path on success, null on failure.
  Future<String?> shareCsvFile(String csvContent) async {
    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'catatan_keuangan_$timestamp.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvContent);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Export Transaksi DompetKu',
        ),
      );

      return file.path;
    } catch (e, stack) {
      ErrorService.instance.recordError(e, stack);
      return null;
    }
  }

  /// Full pipeline: export transactions to CSV and share the file.
  /// Returns the file path on success, null on failure.
  Future<String?> exportAndShareTransactions() async {
    final csvContent = await exportTransactionsToCsv();
    return await shareCsvFile(csvContent);
  }
}
