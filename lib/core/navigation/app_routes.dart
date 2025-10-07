/// Route constants and path definitions for the app
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route paths
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String hymnDetail = 'hymn/:hymnNumber';

  // Route names (for named navigation)
  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String loginName = 'login';
  static const String signupName = 'signup';
  static const String forgotPasswordName = 'forgot-password';
  static const String homeName = 'home';
  static const String searchName = 'search';
  static const String favoritesName = 'favorites';
  static const String settingsName = 'settings';
  static const String hymnDetailName = 'hymn-detail';
  static const String hymnDetailFromSearchName = 'hymn-detail-search';
  static const String hymnDetailFromFavoritesName = 'hymn-detail-favorites';

  // Route parameters
  static const String hymnNumberParam = 'hymnNumber';

  // Query parameters
  static const String searchQueryParam = 'q';
  static const String themeParam = 'theme';
  static const String sortParam = 'sort';

  /// Generate hymn detail route with hymn number
  static String getHymnDetailRoute(String hymnNumber) {
    return '/hymn/$hymnNumber';
  }

  /// Generate search route with query
  static String getSearchRoute(String query) {
    return '/search?q=${Uri.encodeComponent(query)}';
  }

  /// Check if a route is a main tab route
  static bool isMainTabRoute(String location) {
    const mainTabRoutes = [
      home,
      search,
      favorites,
      settings,
    ];
    return mainTabRoutes.contains(location);
  }

  /// Get the main tab index from route location
  static int getMainTabIndex(String location) {
    // Only match exact main tab routes, not nested routes
    if (location == home) return 0;
    if (location == search) return 1;
    if (location == favorites) return 2;
    if (location == settings) return 3;
    return 0; // Default to home
  }

  /// Get the main tab route from index
  static String getMainTabRoute(int index) {
    switch (index) {
      case 0:
        return home;
      case 1:
        return search;
      case 2:
        return favorites;
      case 3:
        return settings;
      default:
        return home;
    }
  }
}
