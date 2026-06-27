import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/services/budget_alert_service.dart';
import 'package:catatan_keuangan/data/database_helper.dart';
import 'package:catatan_keuangan/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    initializeTestEnvironment();
    await DatabaseHelper.resetForTesting();
    await DatabaseHelper.instance.database;
  });

  setUp(() async {
    final db = DatabaseHelper.instance;
    final database = await db.database;
    await database.delete('transaksi');
    await database.delete('budget');
    await database.delete('dompet');
    await database.delete('kategori');
    // Ensure budget table has all required columns (may have been created
    // with old schema; migrate missing columns)
    try {
      await database.execute(
        "ALTER TABLE budget ADD COLUMN profil_id INTEGER DEFAULT 1",
      );
    } catch (_) {}
    try {
      await database.execute(
        "ALTER TABLE budget ADD COLUMN sisa_rollover REAL DEFAULT 0",
      );
    } catch (_) {}
    await db.insertDompet(
      Dompet(nama: 'Test Dompet', saldo: 0, warna: 'green'),
    );
  });

  tearDownAll(() async {
    await DatabaseHelper.resetForTesting();
  });

  group('BudgetAlertService singleton', () {
    test('instance returns same object', () {
      final a = BudgetAlertService.instance;
      final b = BudgetAlertService.instance;
      expect(a, same(b));
    });
  });

  group('checkBudgetAlertsForMonth', () {
    test('does not throw when budget list is empty', () async {
      // Should complete without exception even with no budgets
      await BudgetAlertService.instance.checkBudgetAlertsForMonth(6, 2024);
      expect(true, isTrue);
    });

    test('checkBudgetAlerts runs without throwing', () async {
      await BudgetAlertService.instance.checkBudgetAlerts();
      expect(true, isTrue);
    });
  });
}
