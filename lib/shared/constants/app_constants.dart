class AppConstants {
  // App Information
  static const String musicSheetBaseUrl =
      'https://troisanges.org/Musique/HymnesEtLouanges/PDF/';

  // Asset Paths

  // Storage Keys
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Audio Settings
  static const double defaultVolume = 1.0;
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double extraSmallPadding = 5.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 20.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 40.0;
  static const double borderRadius = 12.0;
  static const double mediumBorderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 20.0;
  static const double extraLargeBorderRadius = 28.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Search Constants
  static const int searchDebounceMs = 300;
  static const int maxSearchResults = 50;

  // Pagination
  static const int itemsPerPage = 20;

  // Home Widgets Stuff
  static const String appGroupId = 'group.hymnesHomeWidget';
  static const String iOSWidgetName = 'HymnesHomeWidget';
  static const String androidWidgetName = 'HymnesHomeWidget';
  static const String dataKey = 'widget_data';
}
