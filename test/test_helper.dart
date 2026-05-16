import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Initializes test environment for Flutter tests.
/// Call this in setUpAll of test files that use SQLite or intl locales.
void initializeTestEnvironment() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  initializeDateFormatting('id_ID', null);
}
