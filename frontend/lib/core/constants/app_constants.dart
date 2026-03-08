class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8787',
  );
  static const String apiPrefix = '/api/v1';
  static const String apiUrl = '$baseUrl$apiPrefix';

  // Storage keys
  static const String keyLocale = 'locale';
  static const String keyDefaultProfileId = 'default_profile_id';
  static const String keyOnboardingDone = 'onboarding_done';

  // UI
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Compatibility
  static const String compatOk = 'ok';
  static const String compatCaution = 'caution';
  static const String compatDanger = 'danger';

  // Intake status
  static const String statusPending = 'pending';
  static const String statusTaken = 'taken';
  static const String statusSkipped = 'skipped';
  static const String statusSnoozed = 'snoozed';
}
