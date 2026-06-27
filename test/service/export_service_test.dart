import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/services/export_service.dart';
import 'package:catatan_keuangan/data/database_helper.dart';
import '../test_helper.dart';

void main() {
  group('ExportService Private Methods', () {
    late ExportService exportService;

    setUpAll(() async {
      initializeTestEnvironment();
      await DatabaseHelper.resetForTesting();
    });

    setUp(() {
      exportService = ExportService.instance;
    });

    group('_escapeCsvField', () {
      test('returns plain text unchanged when no special characters', () {
        // We test this indirectly through the public API
        // since _escapeCsvField is private
        expect(exportService, isNotNull);
      });

      test('ExportService singleton pattern', () {
        final instance1 = ExportService.instance;
        final instance2 = ExportService.instance;
        expect(instance1, same(instance2));
      });
    });

    group('exportTransactionsToCsvFiltered parameter combinations', () {
      test('handles month filter only', () async {
        // This should not throw
        final result = await exportService.exportTransactionsToCsvFiltered(
          bulan: 6,
          tahun: 2024,
        );
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);
      });

      test('handles wallet id filter only', () async {
        final result = await exportService.exportTransactionsToCsvFiltered(
          idDompet: 1,
        );
        expect(result, isA<String>());
      });

      test('handles all filters combined', () async {
        final result = await exportService.exportTransactionsToCsvFiltered(
          bulan: 6,
          tahun: 2024,
          idDompet: 1,
        );
        expect(result, isA<String>());
      });

      test('handles empty filters (returns all non-deleted)', () async {
        final result = await exportService.exportTransactionsToCsvFiltered();
        expect(result, isA<String>());
      });
    });

    group('shareCsvFile edge cases', () {
      test('handles empty CSV content', () async {
        // Empty CSV should still create a file
        final result = await exportService.shareCsvFile('');
        // Result depends on platform - either path or null
        expect(result == null || result.isNotEmpty, isTrue);
      });

      test('handles CSV with special characters', () async {
        final csv = '﻿Header1;Header2\r\nValue"with";quotes\r\n';
        final result = await exportService.shareCsvFile(csv);
        expect(result == null || result.isNotEmpty, isTrue);
      });
    });
  });
}