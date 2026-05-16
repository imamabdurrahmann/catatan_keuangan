import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Tab label for today view
  ///
  /// In id, this message translates to:
  /// **'Hari Ini'**
  String get homeTabToday;

  /// Tab label for date-based view
  ///
  /// In id, this message translates to:
  /// **'Per Tanggal'**
  String get homeTabByDate;

  /// Tab label for monthly view
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get homeTabMonthly;

  /// Tab label for other/miscellaneous view
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get homeTabOther;

  /// Tab label for dashboard view
  ///
  /// In id, this message translates to:
  /// **'Dashboard'**
  String get homeTabDashboard;

  /// Settings page title
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// Statistics page title
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get statisticsTitle;

  /// Backup and restore page title
  ///
  /// In id, this message translates to:
  /// **'Backup & Pulihkan'**
  String get backupRestoreTitle;

  /// Debt and receivable page title
  ///
  /// In id, this message translates to:
  /// **'Utang & Piutang'**
  String get debtTitle;

  /// Savings goals page title
  ///
  /// In id, this message translates to:
  /// **'Tabungan Impian'**
  String get savingsTitle;

  /// Menu title
  ///
  /// In id, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// Light theme option label
  ///
  /// In id, this message translates to:
  /// **'Mode Terang'**
  String get lightMode;

  /// Dark theme option label
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkMode;

  /// Search transaction placeholder
  ///
  /// In id, this message translates to:
  /// **'Cari Transaksi'**
  String get searchTransaction;

  /// Add transaction button label
  ///
  /// In id, this message translates to:
  /// **'Tambah Transaksi'**
  String get addTransaction;

  /// Scan receipt button label
  ///
  /// In id, this message translates to:
  /// **'Pindai Struk (A.I)'**
  String get scanReceipt;

  /// Recurring transaction label
  ///
  /// In id, this message translates to:
  /// **'Transaksi Berulang'**
  String get recurringTransaction;

  /// Save transaction button label
  ///
  /// In id, this message translates to:
  /// **'SIMPAN TRANSAKSI'**
  String get saveTransaction;

  /// Saving transaction loading text
  ///
  /// In id, this message translates to:
  /// **'Menyimpan...'**
  String get savingTransaction;

  /// New export button label
  ///
  /// In id, this message translates to:
  /// **'Ekspor Baru'**
  String get newExport;

  /// Restore from file button label
  ///
  /// In id, this message translates to:
  /// **'Pulihkan dari File'**
  String get restoreFromFile;

  /// Trash page title
  ///
  /// In id, this message translates to:
  /// **'Tong Sampah'**
  String get trash;

  /// Manage wallet label
  ///
  /// In id, this message translates to:
  /// **'Kelola Dompet'**
  String get manageWallet;

  /// Set budget label
  ///
  /// In id, this message translates to:
  /// **'Atur Budget'**
  String get setBudget;

  /// Manage category label
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get manageCategory;

  /// Backup and restore menu label
  ///
  /// In id, this message translates to:
  /// **'Backup & Pulihkan'**
  String get backupRestore;

  /// Settings menu label
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// Amount field label
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get amount;

  /// Description field label
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get description;

  /// Category field label
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get category;

  /// Attachment field label
  ///
  /// In id, this message translates to:
  /// **'Lampiran'**
  String get attachment;

  /// Wallet name field label
  ///
  /// In id, this message translates to:
  /// **'Nama Dompet'**
  String get walletName;

  /// New wallet label
  ///
  /// In id, this message translates to:
  /// **'Dompet baru'**
  String get newWallet;

  /// Wallet balance label
  ///
  /// In id, this message translates to:
  /// **'Saldo'**
  String get walletBalance;

  /// Category name field label
  ///
  /// In id, this message translates to:
  /// **'Nama Kategori'**
  String get categoryName;

  /// New category label
  ///
  /// In id, this message translates to:
  /// **'Kategori baru'**
  String get newCategory;

  /// Expense category type label
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expenseCategory;

  /// Income category type label
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get incomeCategory;

  /// Default category label
  ///
  /// In id, this message translates to:
  /// **'Default'**
  String get defaultCategory;

  /// Borrower or lender name field label
  ///
  /// In id, this message translates to:
  /// **'Nama Peminjam / Yang Dihutangi'**
  String get borrowerLenderName;

  /// Total amount field label
  ///
  /// In id, this message translates to:
  /// **'Nominal Total'**
  String get totalAmount;

  /// Due date optional field label
  ///
  /// In id, this message translates to:
  /// **'Set Tenggat Waktu (Opsional)'**
  String get dueDateOptional;

  /// Notes optional field label
  ///
  /// In id, this message translates to:
  /// **'Catatan (Opsional)'**
  String get notesOptional;

  /// Savings amount field label
  ///
  /// In id, this message translates to:
  /// **'Nominal Tabung (Rp)'**
  String get savingsAmount;

  /// Savings goal name field label
  ///
  /// In id, this message translates to:
  /// **'Nama Barang/Tujuan (Cth: Laptop)'**
  String get savingsGoalName;

  /// Target amount field label
  ///
  /// In id, this message translates to:
  /// **'Target Nominal'**
  String get targetAmount;

  /// Target date optional field label
  ///
  /// In id, this message translates to:
  /// **'Set Target Tanggal (Opsional)'**
  String get targetDateOptional;

  /// Budget amount field label
  ///
  /// In id, this message translates to:
  /// **'Nominal Anggaran'**
  String get budgetAmount;

  /// Delete wallet action label
  ///
  /// In id, this message translates to:
  /// **'Hapus Dompet'**
  String get deleteWallet;

  /// Delete category action label
  ///
  /// In id, this message translates to:
  /// **'Hapus Kategori'**
  String get deleteCategory;

  /// Delete permanently action label
  ///
  /// In id, this message translates to:
  /// **'Hapus Permanen'**
  String get deletePermanently;

  /// Delete data action label
  ///
  /// In id, this message translates to:
  /// **'Hapus Data'**
  String get deleteData;

  /// Delete target action label
  ///
  /// In id, this message translates to:
  /// **'Hapus Target'**
  String get deleteTarget;

  /// Cancel button label
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// Save button label
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// Save PIN button label
  ///
  /// In id, this message translates to:
  /// **'Simpan PIN'**
  String get savePin;

  /// Save target button label
  ///
  /// In id, this message translates to:
  /// **'Simpan Target'**
  String get saveTarget;

  /// Confirm delete button label
  ///
  /// In id, this message translates to:
  /// **'Tetap Hapus'**
  String get confirmDelete;

  /// Choose file button label
  ///
  /// In id, this message translates to:
  /// **'Pilih File'**
  String get chooseFile;

  /// Restore button label
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get restore;

  /// Decrypt button label
  ///
  /// In id, this message translates to:
  /// **'Dekripsi'**
  String get decrypt;

  /// Export button label
  ///
  /// In id, this message translates to:
  /// **'Ekspor'**
  String get export;

  /// Share button label
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get share;

  /// Delete button label
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// Delete backup action label
  ///
  /// In id, this message translates to:
  /// **'Hapus Cadangan'**
  String get deleteBackup;

  /// Close button label
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// I owe (debt) label
  ///
  /// In id, this message translates to:
  /// **'Saya Berutang (Utang)'**
  String get iOwe;

  /// They owe (receivable) label
  ///
  /// In id, this message translates to:
  /// **'Orang Berutang (Piutang)'**
  String get theyOwe;

  /// Pay debt action label
  ///
  /// In id, this message translates to:
  /// **'Bayar Utang'**
  String get payDebt;

  /// Receive installment action label
  ///
  /// In id, this message translates to:
  /// **'Terima Cicilan'**
  String get receiveInstallment;

  /// Payment history label
  ///
  /// In id, this message translates to:
  /// **'Riwayat Pembayaran'**
  String get paymentHistory;

  /// Create target button label
  ///
  /// In id, this message translates to:
  /// **'Buat Target'**
  String get createTarget;

  /// New target label
  ///
  /// In id, this message translates to:
  /// **'Target Baru'**
  String get newTarget;

  /// Save savings button label
  ///
  /// In id, this message translates to:
  /// **'Tabungkan'**
  String get saveSavings;

  /// Create PIN button label
  ///
  /// In id, this message translates to:
  /// **'Buat PIN'**
  String get createPin;

  /// Confirm PIN label
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi PIN'**
  String get confirmPin;

  /// Enter PIN label
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN'**
  String get enterPin;

  /// PIN minimum 4 digits validation message
  ///
  /// In id, this message translates to:
  /// **'PIN minimal 4 digit'**
  String get pinMin4Digits;

  /// PIN does not match error message
  ///
  /// In id, this message translates to:
  /// **'PIN tidak cocok'**
  String get pinNotMatch;

  /// Wrong PIN error message
  ///
  /// In id, this message translates to:
  /// **'PIN salah'**
  String get wrongPin;

  /// Verify fingerprint instruction message
  ///
  /// In id, this message translates to:
  /// **'Verifikasi sidik jari untuk membuka aplikasi'**
  String get verifyFingerprint;

  /// Use fingerprint button label
  ///
  /// In id, this message translates to:
  /// **'Gunakan Sidik Jari'**
  String get useFingerprint;

  /// Enable fingerprint label
  ///
  /// In id, this message translates to:
  /// **'Aktifkan sidik jari'**
  String get enableFingerprint;

  /// Open with fingerprint label
  ///
  /// In id, this message translates to:
  /// **'Buka dengan sidik jari'**
  String get openWithFingerprint;

  /// Enter same PIN for confirmation instruction
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN yang sama untuk konfirmasi'**
  String get enterSamePin;

  /// Open button label
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get open;

  /// Export data label
  ///
  /// In id, this message translates to:
  /// **'Ekspor Data'**
  String get exportData;

  /// Protect backup with password prompt
  ///
  /// In id, this message translates to:
  /// **'Lindungi cadangan dengan kata sandi?'**
  String get protectBackupPassword;

  /// Use password label
  ///
  /// In id, this message translates to:
  /// **'Gunakan kata sandi'**
  String get usePassword;

  /// Password field label
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get password;

  /// Confirm password field label
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Kata Sandi'**
  String get confirmPassword;

  /// Repeat password field label
  ///
  /// In id, this message translates to:
  /// **'Ulangi kata sandi'**
  String get repeatPassword;

  /// Password empty validation message
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak boleh kosong'**
  String get passwordEmpty;

  /// Password does not match error message
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak cocok'**
  String get passwordNotMatch;

  /// Wrong password or corrupt file error message
  ///
  /// In id, this message translates to:
  /// **'Kata sandi salah atau file rusak'**
  String get wrongPasswordCorrupt;

  /// Export success message
  ///
  /// In id, this message translates to:
  /// **'Ekspor Berhasil'**
  String get exportSuccess;

  /// Encrypted file note
  ///
  /// In id, this message translates to:
  /// **'(File terenkripsi AES-256)'**
  String get encryptedFile;

  /// Restore data label
  ///
  /// In id, this message translates to:
  /// **'Pulihkan Data'**
  String get restoreData;

  /// Restore will replace all data warning message
  ///
  /// In id, this message translates to:
  /// **'Ini akan MENGGANTIKAN semua data saat ini dengan data dari file cadangan. Lanjutkan?'**
  String get restoreWillReplace;

  /// Restore backup button label
  ///
  /// In id, this message translates to:
  /// **'Pulihkan Cadangan'**
  String get restoreBackup;

  /// File encrypted label
  ///
  /// In id, this message translates to:
  /// **'File Terenkripsi'**
  String get fileEncrypted;

  /// Enter password to open backup file instruction
  ///
  /// In id, this message translates to:
  /// **'Masukkan kata sandi untuk membuka file cadangan.'**
  String get enterPasswordBackup;

  /// Restoring data loading message
  ///
  /// In id, this message translates to:
  /// **'Memulihkan data...'**
  String get restoringData;

  /// Restore success message
  ///
  /// In id, this message translates to:
  /// **'Data berhasil dipulihkan'**
  String get restoreSuccess;

  /// Backup file name prefix
  ///
  /// In id, this message translates to:
  /// **'Backup DompetKu'**
  String get backupFilename;

  /// Encrypted label
  ///
  /// In id, this message translates to:
  /// **'Terenkripsi'**
  String get encrypted;

  /// Export failed error message
  ///
  /// In id, this message translates to:
  /// **'Gagal mengekspor'**
  String get exportFailed;

  /// Read file failed error message
  ///
  /// In id, this message translates to:
  /// **'Gagal membaca file'**
  String get readFileFailed;

  /// Restore failed error message
  ///
  /// In id, this message translates to:
  /// **'Gagal memulihkan'**
  String get restoreFailed;

  /// No transactions this month empty state
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi\nbulan ini'**
  String get noTransactionsThisMonth;

  /// No statistics data empty state
  ///
  /// In id, this message translates to:
  /// **'Tidak ada data statistik'**
  String get noStatisticsData;

  /// No backup data empty state
  ///
  /// In id, this message translates to:
  /// **'Belum ada cadangan data'**
  String get noBackupData;

  /// Click export new to create backup instruction
  ///
  /// In id, this message translates to:
  /// **'Klik \"Ekspor Baru\" untuk membuat backup'**
  String get clickExportBackup;

  /// Trash empty message
  ///
  /// In id, this message translates to:
  /// **'Tong Sampah kosong'**
  String get trashEmpty;

  /// No debts message
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki utang.'**
  String get noDebts;

  /// No receivables message
  ///
  /// In id, this message translates to:
  /// **'Tidak ada piutang pending.'**
  String get noReceivables;

  /// No payments message
  ///
  /// In id, this message translates to:
  /// **'Belum ada pembayaran.'**
  String get noPayments;

  /// No recurring transactions empty state
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi berulang'**
  String get noRecurringTransactions;

  /// No savings goals message
  ///
  /// In id, this message translates to:
  /// **'Anda belum memiliki target tabungan.'**
  String get noSavingsGoals;

  /// No active debt or receivable message
  ///
  /// In id, this message translates to:
  /// **'Tidak ada utang atau piutang aktif'**
  String get noActiveDebt;

  /// No budget message
  ///
  /// In id, this message translates to:
  /// **'Belum ada anggaran'**
  String get noBudget;

  /// No category data empty state
  ///
  /// In id, this message translates to:
  /// **'Belum ada data kategori'**
  String get noCategoryData;

  /// No savings empty state
  ///
  /// In id, this message translates to:
  /// **'Belum ada tabungan impian'**
  String get noSavings;

  /// Dark mode active status message
  ///
  /// In id, this message translates to:
  /// **'Aktif — tema gelap digunakan'**
  String get darkModeActive;

  /// Dark mode inactive status message
  ///
  /// In id, this message translates to:
  /// **'Nonaktif — tema terang digunakan'**
  String get darkModeInactive;

  /// Fingerprint active status message
  ///
  /// In id, this message translates to:
  /// **'Aktif — buka dengan sidik jari'**
  String get fingerprintActive;

  /// Fingerprint inactive status message
  ///
  /// In id, this message translates to:
  /// **'Nonaktif — buka dengan PIN saja'**
  String get fingerprintInactive;

  /// Set PIN first warning message
  ///
  /// In id, this message translates to:
  /// **'Atur PIN terlebih dahulu'**
  String get setPinFirst;

  /// Fingerprint not available message
  ///
  /// In id, this message translates to:
  /// **'Tidak tersedia di perangkat ini'**
  String get fingerprintNotAvailable;

  /// App description for about page
  ///
  /// In id, this message translates to:
  /// **'Aplikasi pencatatan keuangan personal'**
  String get appDescription;

  /// Designed with Flutter and Riverpod message
  ///
  /// In id, this message translates to:
  /// **'Dirancang dengan Flutter & Riverpod'**
  String get designedWith;

  /// Appearance settings section title
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get appearance;

  /// Security settings section title
  ///
  /// In id, this message translates to:
  /// **'Keamanan'**
  String get security;

  /// About settings section title
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get about;

  /// Income label
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get income;

  /// Expense label
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expense;

  /// Monthly balance card title
  ///
  /// In id, this message translates to:
  /// **'Saldo Bulan Ini'**
  String get monthlyBalance;

  /// Transactions this month label
  ///
  /// In id, this message translates to:
  /// **'Transaksi Bulan Ini'**
  String get transactionsThisMonth;

  /// Total expense label
  ///
  /// In id, this message translates to:
  /// **'Total Pengeluaran'**
  String get totalExpense;

  /// Trash page description
  ///
  /// In id, this message translates to:
  /// **'Transaksi yang dihapus dapat dipulihkan dalam 30 hari.'**
  String get trashDescription;

  /// Recurring transactions auto-created snackbar message
  ///
  /// In id, this message translates to:
  /// **'Transaksi berulang telah dibuat otomatis'**
  String get recurringAutoCreated;

  /// Record new transaction label
  ///
  /// In id, this message translates to:
  /// **'Catat Baru'**
  String get recordNew;

  /// Active status label
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get activeStatus;

  /// Cannot delete last wallet error message
  ///
  /// In id, this message translates to:
  /// **'Minimal harus ada 1 dompet'**
  String get deletedWalletError;

  /// Cannot delete default category error message
  ///
  /// In id, this message translates to:
  /// **'Kategori bawaan tidak bisa dihapus'**
  String get defaultCategoryError;

  /// Total balance label
  ///
  /// In id, this message translates to:
  /// **'Total Saldo'**
  String get totalBalance;

  /// Number of active wallets label
  ///
  /// In id, this message translates to:
  /// **'{count} dompet aktif'**
  String walletsActive(int count);

  /// Budget this month label
  ///
  /// In id, this message translates to:
  /// **'Anggaran Bulan Ini'**
  String get budgetThisMonth;

  /// Savings dream label
  ///
  /// In id, this message translates to:
  /// **'Tabungan Impian'**
  String get savingsDream;

  /// Debts and receivables label
  ///
  /// In id, this message translates to:
  /// **'Utang & Piutang'**
  String get debtsReceivables;

  /// Weekly spending label
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran 7 Hari Terakhir'**
  String get weeklySpending;

  /// Expense by category label
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran per Kategori'**
  String get expenseByCategory;

  /// Balance card subtitle
  ///
  /// In id, this message translates to:
  /// **'Saldo Bulan Ini'**
  String get balanceCardSubtitle;

  /// Budget remaining suffix
  ///
  /// In id, this message translates to:
  /// **'tersisa'**
  String get budgetRemaining;

  /// Over budget warning message
  ///
  /// In id, this message translates to:
  /// **'Melebihi budget {kategori}!'**
  String overBudget(String kategori);

  /// Budget percentage used message
  ///
  /// In id, this message translates to:
  /// **'{percent}% budget {kategori} terpakai'**
  String budgetPercentage(int percent, String kategori);

  /// Currency symbol for Indonesian Rupiah
  ///
  /// In id, this message translates to:
  /// **'Rp'**
  String get currencySymbol;

  /// Yes confirmation label
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get yes;

  /// No confirmation label
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get no;

  /// OK button label
  ///
  /// In id, this message translates to:
  /// **'OK'**
  String get ok;

  /// Error label
  ///
  /// In id, this message translates to:
  /// **'Error'**
  String get error;

  /// Loading text
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// Retry button label
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// Today label
  ///
  /// In id, this message translates to:
  /// **'Hari Ini'**
  String get today;

  /// Yesterday label
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get yesterday;

  /// This week label
  ///
  /// In id, this message translates to:
  /// **'Minggu Ini'**
  String get thisWeek;

  /// This month label
  ///
  /// In id, this message translates to:
  /// **'Bulan Ini'**
  String get thisMonth;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
