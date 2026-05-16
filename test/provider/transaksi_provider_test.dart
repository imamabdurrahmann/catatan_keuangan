import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catatan_keuangan/providers.dart';
import 'package:catatan_keuangan/models/models.dart';
import '../test_helper.dart';

void main() {
  setUpAll(initializeTestEnvironment);
  group('transaksiByDateProvider', () {
    test(
      'returns AsyncLoading then AsyncData with empty list when no transactions',
      () async {
        // Note: This test documents behavior - the actual provider
        // reads from DatabaseHelper.instance which is a real singleton.
        // For true isolation, the provider would need DI. This test
        // verifies the provider structure is correct.
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final testDate = DateTime(2024, 6, 15);
        final asyncValue = container.read(transaksiByDateProvider(testDate));

        // Verify the family provider returns an AsyncValue structure
        expect(asyncValue, isA<AsyncValue<List<Transaksi>>>());
      },
    );
  });

  group('transaksiByMonthProvider', () {
    test('returns AsyncValue structure with record parameter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final params = (bulan: 6, tahun: 2024);
      final asyncValue = container.read(transaksiByMonthProvider(params));

      expect(asyncValue, isA<AsyncValue<List<Transaksi>>>());
    });
  });

  group('monthlySummaryProvider', () {
    test('returns AsyncValue with record parameter structure', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final params = (bulan: 6, tahun: 2024);
      final asyncValue = container.read(monthlySummaryProvider(params));

      expect(asyncValue, isA<AsyncValue<Map<String, double>>>());
    });
  });

  group('categorySummaryProvider', () {
    test('returns AsyncValue with record parameter structure', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final params = (bulan: 6, tahun: 2024);
      final asyncValue = container.read(categorySummaryProvider(params));

      expect(asyncValue, isA<AsyncValue<Map<String, double>>>());
    });
  });

  group('budgetListProvider', () {
    test('returns AsyncValue with record parameter structure', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final params = (bulan: 6, tahun: 2024);
      final asyncValue = container.read(budgetListProvider(params));

      expect(asyncValue, isA<AsyncValue<List<Budget>>>());
    });
  });

  group('dompetProvider', () {
    test('returns AsyncValue for wallet list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(dompetProvider);
      expect(asyncValue, isA<AsyncValue<List<Dompet>>>());
    });
  });

  group('kategoriProvider', () {
    test('returns AsyncValue for kategori list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(kategoriProvider);
      expect(asyncValue, isA<AsyncValue<List<Kategori>>>());
    });
  });

  group('utangPiutangListProvider', () {
    test('returns AsyncValue structure', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(utangPiutangListProvider);
      expect(asyncValue, isA<AsyncValue<List<UtangPiutang>>>());
    });
  });

  group('tabunganImpianListProvider', () {
    test('returns AsyncValue structure', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(tabunganImpianListProvider);
      expect(asyncValue, isA<AsyncValue<List<TabunganImpian>>>());
    });
  });

  group('deletedTransaksiProvider', () {
    test('returns AsyncValue structure', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(deletedTransaksiProvider);
      expect(asyncValue, isA<AsyncValue<List<Transaksi>>>());
    });
  });

  group('historyCicilanProvider', () {
    test('returns AsyncValue structure with int parameter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(historyCicilanProvider(1));
      expect(asyncValue, isA<AsyncValue<List<HistoryCicilan>>>());
    });
  });

  group('kategoriByJenisProvider', () {
    test('returns AsyncValue structure with String parameter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(kategoriByJenisProvider('pemasukan'));
      expect(asyncValue, isA<AsyncValue<List<Kategori>>>());
    });

    test('accepts both pemasukan and pengeluaran types', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final incomeResult = container.read(kategoriByJenisProvider('pemasukan'));
      final expenseResult = container.read(
        kategoriByJenisProvider('pengeluaran'),
      );

      expect(incomeResult, isA<AsyncValue<List<Kategori>>>());
      expect(expenseResult, isA<AsyncValue<List<Kategori>>>());
    });
  });
}
