/// Application configuration constants.
/// Centralizes app-wide settings for easy maintenance.
class AppConfig {
  AppConfig._();

  static const String appName = 'DompetKu';

  /// Default page size for paginated lists
  static const int defaultPageSize = 20;

  /// Budget warning threshold (percentage)
  static const int budgetWarningThreshold = 80;

  /// Savings milestone notification thresholds (percentages)
  static const List<int> savingsMilestoneThresholds = [50, 75, 100];

  /// Days before debt due date to send reminder
  static const int debtReminderDaysBefore = 3;

  /// Enable verbose logging (set to false in production)
  static const bool enableLogging = true;

  /// Enable crash reporting (requires external service setup)
  static const bool enableCrashReporting = false;
}
