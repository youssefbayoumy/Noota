class AppConfig {
  // App Information
  static const String appName = 'Private Classes App';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableQRScanning = true;
  static const bool enableLocationTracking = true;
  static const bool enablePushNotifications = true;

  // Attendance Configuration
  static const int attendanceWindowMinutes =
      15; // 15 minutes before to 30 minutes after
  static const int lateThresholdMinutes = 5;
  static const int qrCodeTTLSeconds = 30;

  // Payment Configuration
  static const String defaultCurrency = 'EGP';
  static const double minimumPayoutAmount = 100.0;

  // Localization
  static const List<String> supportedLocales = ['en', 'ar'];
  static const String defaultLocale = 'en';

  // Security
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const int sessionTimeoutMinutes = 30;
}
