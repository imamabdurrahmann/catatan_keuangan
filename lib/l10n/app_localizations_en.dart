// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTabToday => 'Today';

  @override
  String get homeTabByDate => 'By Date';

  @override
  String get homeTabMonthly => 'Monthly';

  @override
  String get homeTabOther => 'Other';

  @override
  String get homeTabDashboard => 'Dashboard';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get backupRestoreTitle => 'Backup & Restore';

  @override
  String get debtTitle => 'Debt & Receivables';

  @override
  String get savingsTitle => 'Savings Goals';

  @override
  String get menuTitle => 'Menu';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get searchTransaction => 'Search Transaction';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get scanReceipt => 'Scan Receipt (A.I)';

  @override
  String get recurringTransaction => 'Recurring Transaction';

  @override
  String get saveTransaction => 'SAVE TRANSACTION';

  @override
  String get savingTransaction => 'Saving...';

  @override
  String get newExport => 'New Export';

  @override
  String get restoreFromFile => 'Restore from File';

  @override
  String get trash => 'Trash';

  @override
  String get manageWallet => 'Manage Wallet';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get manageCategory => 'Manage Category';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get settings => 'Settings';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get category => 'Category';

  @override
  String get attachment => 'Attachment';

  @override
  String get walletName => 'Wallet Name';

  @override
  String get newWallet => 'New wallet';

  @override
  String get walletBalance => 'Balance';

  @override
  String get categoryName => 'Category Name';

  @override
  String get newCategory => 'New category';

  @override
  String get expenseCategory => 'Expense';

  @override
  String get incomeCategory => 'Income';

  @override
  String get defaultCategory => 'Default';

  @override
  String get borrowerLenderName => 'Borrower / Lender Name';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get dueDateOptional => 'Set Due Date (Optional)';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get savingsAmount => 'Savings Amount (Rp)';

  @override
  String get savingsGoalName => 'Item/Goal Name (Ex: Laptop)';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get targetDateOptional => 'Set Target Date (Optional)';

  @override
  String get budgetAmount => 'Budget Amount';

  @override
  String get deleteWallet => 'Delete Wallet';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get deleteData => 'Delete Data';

  @override
  String get deleteTarget => 'Delete Target';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get savePin => 'Save PIN';

  @override
  String get saveTarget => 'Save Target';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get chooseFile => 'Choose File';

  @override
  String get restore => 'Restore';

  @override
  String get decrypt => 'Decrypt';

  @override
  String get export => 'Export';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get deleteBackup => 'Delete Backup';

  @override
  String get close => 'Close';

  @override
  String get iOwe => 'I Owe (Debt)';

  @override
  String get theyOwe => 'They Owe (Receivable)';

  @override
  String get payDebt => 'Pay Debt';

  @override
  String get receiveInstallment => 'Receive Installment';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get createTarget => 'Create Target';

  @override
  String get newTarget => 'New Target';

  @override
  String get saveSavings => 'Save';

  @override
  String get createPin => 'Create PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get pinMin4Digits => 'PIN must be at least 4 digits';

  @override
  String get pinNotMatch => 'PIN does not match';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get verifyFingerprint => 'Verify fingerprint to open app';

  @override
  String get useFingerprint => 'Use Fingerprint';

  @override
  String get enableFingerprint => 'Enable fingerprint';

  @override
  String get openWithFingerprint => 'Open with fingerprint';

  @override
  String get enterSamePin => 'Enter the same PIN to confirm';

  @override
  String get open => 'Open';

  @override
  String get exportData => 'Export Data';

  @override
  String get protectBackupPassword => 'Protect backup with password?';

  @override
  String get usePassword => 'Use password';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get passwordEmpty => 'Password cannot be empty';

  @override
  String get passwordNotMatch => 'Passwords do not match';

  @override
  String get wrongPasswordCorrupt => 'Wrong password or file is corrupted';

  @override
  String get exportSuccess => 'Export Successful';

  @override
  String get encryptedFile => '(AES-256 encrypted file)';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreWillReplace =>
      'This will REPLACE all current data with data from the backup file. Continue?';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get fileEncrypted => 'File Encrypted';

  @override
  String get enterPasswordBackup => 'Enter password to open backup file.';

  @override
  String get restoringData => 'Restoring data...';

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String get backupFilename => 'DompetKu Backup';

  @override
  String get encrypted => 'Encrypted';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get readFileFailed => 'Failed to read file';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get noTransactionsThisMonth => 'No transactions\nthis month';

  @override
  String get noStatisticsData => 'No statistics data';

  @override
  String get noBackupData => 'No backup data';

  @override
  String get clickExportBackup => 'Click \"New Export\" to create backup';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get noDebts => 'You have no debts.';

  @override
  String get noReceivables => 'No pending receivables.';

  @override
  String get noPayments => 'No payments yet.';

  @override
  String get noRecurringTransactions => 'No recurring transactions';

  @override
  String get noSavingsGoals => 'You have no savings goals yet.';

  @override
  String get noActiveDebt => 'No active debt or receivable';

  @override
  String get noBudget => 'No budget set';

  @override
  String get noCategoryData => 'No category data';

  @override
  String get noSavings => 'No savings goals';

  @override
  String get darkModeActive => 'Active — dark theme enabled';

  @override
  String get darkModeInactive => 'Inactive — light theme enabled';

  @override
  String get fingerprintActive => 'Active — open with fingerprint';

  @override
  String get fingerprintInactive => 'Inactive — open with PIN only';

  @override
  String get setPinFirst => 'Set PIN first';

  @override
  String get fingerprintNotAvailable => 'Not available on this device';

  @override
  String get appDescription => 'Personal financial recording app';

  @override
  String get designedWith => 'Designed with Flutter & Riverpod';

  @override
  String get appearance => 'Appearance';

  @override
  String get security => 'Security';

  @override
  String get about => 'About';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get monthlyBalance => 'This Month\'s Balance';

  @override
  String get transactionsThisMonth => 'Transactions This Month';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get trashDescription =>
      'Deleted transactions can be recovered within 30 days.';

  @override
  String get recurringAutoCreated =>
      'Recurring transactions have been auto-created';

  @override
  String get recordNew => 'Record New';

  @override
  String get activeStatus => 'Active';

  @override
  String get deletedWalletError => 'At least 1 wallet must exist';

  @override
  String get defaultCategoryError => 'Default category cannot be deleted';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String walletsActive(int count) {
    return '$count active wallet(s)';
  }

  @override
  String get budgetThisMonth => 'Budget This Month';

  @override
  String get savingsDream => 'Savings Goals';

  @override
  String get debtsReceivables => 'Debts & Receivables';

  @override
  String get weeklySpending => 'Last 7 Days Spending';

  @override
  String get expenseByCategory => 'Expenses by Category';

  @override
  String get balanceCardSubtitle => 'This Month\'s Balance';

  @override
  String get budgetRemaining => 'remaining';

  @override
  String overBudget(String kategori) {
    return 'Over budget for $kategori!';
  }

  @override
  String budgetPercentage(int percent, String kategori) {
    return '$percent% of $kategori budget used';
  }

  @override
  String get currencySymbol => 'Rp';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';
}
