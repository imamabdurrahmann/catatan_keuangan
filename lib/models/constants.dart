/// Application-wide constants to avoid magic strings and numbers.
class AppConstants {
  // === Transaksi jenis ===
  static const String jenisPemasukan = 'pemasukan';
  static const String jenisPengeluaran = 'pengeluaran';

  // === Date formats ===
  static const String dateFormatDisplay = 'EEEE, d MMMM yyyy HH:mm';
  static const String dateFormatDisplayShort = 'd MMMM yyyy';
  static const String dateFormatMonth = 'MMMM yyyy';
  static const String dateFormatDayMonth = 'd MMM';
  static const String dateFormatSql = 'yyyy-MM-dd 00:00:00';
  static const String localeId = 'id_ID';

  // === Date bounds ===
  static const int minYear = 2020;
  static const int maxFutureDays = 365;

  // === Recurring frequencies ===
  static const String freqDaily = 'daily';
  static const String freqWeekly = 'weekly';
  static const String freqMonthly = 'monthly';
  static const String freqQuarterly = 'quarterly';
  static const String freqYearly = 'yearly';

  static const List<String> recurringFrequencies = [
    freqDaily,
    freqWeekly,
    freqMonthly,
    freqQuarterly,
    freqYearly,
  ];

  static String frequencyLabel(String freq) {
    switch (freq) {
      case freqDaily:
        return 'Harian';
      case freqWeekly:
        return 'Mingguan';
      case freqMonthly:
        return 'Bulanan';
      case freqQuarterly:
        return 'Triwulanan';
      case freqYearly:
        return 'Tahunan';
      default:
        return freq;
    }
  }
}
