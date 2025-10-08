class AppConstants {
  // App Information
  static const String appName = 'Hymnes & Louanges Adventiste';
  static const String musicSheetBaseUrl =
      'https://troisanges.org/Musique/HymnesEtLouanges/PDF/';

  // Asset Paths
  static const String audioPath = 'assets/audio/';
  static const String midiPath = 'assets/midi/';
  static const String imagesPath = 'assets/images/';
  static const String iconPath = 'assets/icon/';

  // Storage Keys
  static const String favoritesKey = 'favorites';
  static const String lastPlayedKey = 'last_played';
  static const String settingsKey = 'settings';
  static const String isFirstLaunchKey = 'is_first_launch';

  // Audio Settings
  static const double defaultVolume = 1.0;
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Search Constants
  static const int searchDebounceMs = 300;
  static const int maxSearchResults = 50;

  // Pagination
  static const int itemsPerPage = 20;
}
