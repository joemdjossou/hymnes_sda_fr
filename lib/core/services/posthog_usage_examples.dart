import 'package:hymnes_sda_fr/core/services/posthog_service.dart';

/// Examples of how to use PostHogService throughout the app
/// This file demonstrates best practices for event tracking
class PostHogUsageExamples {
  final PostHogService _posthog = PostHogService();

  // ============================================================================
  // USER AUTHENTICATION EXAMPLES
  // ============================================================================

  /// Example: Track user login
  Future<void> onUserLogin(
      String userId, String email, String authMethod) async {
    // Identify the user
    await _posthog.identifyUser(
      userId: userId,
      email: email,
      additionalProperties: {
        'login_method': authMethod,
        'login_timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Track login event
    await _posthog.trackAuthEvent(
      eventType: 'login',
      method: authMethod,
      additionalProperties: {
        'user_id': userId,
        'is_first_login': false, // You can determine this from your data
      },
    );

    // Track app launch after login
    await _posthog.trackAppLaunch();
  }

  /// Example: Track user logout
  Future<void> onUserLogout() async {
    await _posthog.trackAuthEvent(
      eventType: 'logout',
      additionalProperties: {
        'logout_timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Reset user identification
    await _posthog.resetUser();
  }

  // ============================================================================
  // HYMN INTERACTION EXAMPLES
  // ============================================================================

  /// Example: Track hymn view
  Future<void> onHymnViewed(
      String hymnNumber, String hymnTitle, String source) async {
    await _posthog.trackHymnEvent(
      eventType: 'viewed',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      additionalProperties: {
        'source': source, // e.g., 'search', 'favorites', 'browse'
        'view_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example: Track hymn play
  Future<void> onHymnPlayed(String hymnNumber, String hymnTitle) async {
    await _posthog.trackHymnEvent(
      eventType: 'played',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      additionalProperties: {
        'play_timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Also track as audio event
    await _posthog.trackAudioEvent(
      eventType: 'play',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
    );
  }

  /// Example: Track hymn share
  Future<void> onHymnShared(
      String hymnNumber, String hymnTitle, String shareMethod) async {
    await _posthog.trackHymnEvent(
      eventType: 'shared',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      additionalProperties: {
        'share_method': shareMethod, // e.g., 'whatsapp', 'email', 'copy_link'
        'share_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================================
  // AUDIO PLAYBACK EXAMPLES
  // ============================================================================

  /// Example: Track audio play
  Future<void> onAudioPlay(
      String hymnNumber, String hymnTitle, double duration) async {
    await _posthog.trackAudioEvent(
      eventType: 'play',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      duration: duration,
      additionalProperties: {
        'play_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example: Track audio pause
  Future<void> onAudioPause(
      String hymnNumber, double position, double duration) async {
    await _posthog.trackAudioEvent(
      eventType: 'pause',
      hymnNumber: hymnNumber,
      position: position,
      duration: duration,
      additionalProperties: {
        'pause_timestamp': DateTime.now().toIso8601String(),
        'playback_progress': (position / duration) * 100,
      },
    );
  }

  /// Example: Track audio completion
  Future<void> onAudioCompleted(
      String hymnNumber, String hymnTitle, double duration) async {
    await _posthog.trackAudioEvent(
      eventType: 'completed',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      duration: duration,
      additionalProperties: {
        'completion_timestamp': DateTime.now().toIso8601String(),
        'full_playback': true,
      },
    );
  }

  // ============================================================================
  // FAVORITES EXAMPLES
  // ============================================================================

  /// Example: Track favorite added
  Future<void> onFavoriteAdded(String hymnNumber, String hymnTitle) async {
    await _posthog.trackFavoritesEvent(
      eventType: 'added',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      additionalProperties: {
        'add_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example: Track favorite removed
  Future<void> onFavoriteRemoved(String hymnNumber, String hymnTitle) async {
    await _posthog.trackFavoritesEvent(
      eventType: 'removed',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      additionalProperties: {
        'remove_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example: Track favorites list viewed
  Future<void> onFavoritesViewed(int favoritesCount) async {
    await _posthog.trackFavoritesEvent(
      eventType: 'viewed',
      additionalProperties: {
        'favorites_count': favoritesCount,
        'view_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================================
  // SEARCH EXAMPLES
  // ============================================================================

  /// Example: Track search performed
  Future<void> onSearchPerformed(
      String query, int resultCount, String searchType) async {
    await _posthog.trackSearchEvent(
      eventType: 'performed',
      query: query,
      resultCount: resultCount,
      searchType: searchType,
      additionalProperties: {
        'search_timestamp': DateTime.now().toIso8601String(),
        'query_length': query.length,
      },
    );
  }

  /// Example: Track search result clicked
  Future<void> onSearchResultClicked(
      String query, String hymnNumber, int resultPosition) async {
    await _posthog.trackSearchEvent(
      eventType: 'result_clicked',
      query: query,
      additionalProperties: {
        'hymn_number': hymnNumber,
        'result_position': resultPosition,
        'click_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================================
  // NAVIGATION EXAMPLES
  // ============================================================================

  /// Example: Track screen navigation
  Future<void> onScreenChanged(String fromScreen, String toScreen) async {
    await _posthog.trackNavigationEvent(
      eventType: 'screen_changed',
      fromScreen: fromScreen,
      toScreen: toScreen,
      additionalProperties: {
        'navigation_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example: Track tab navigation
  Future<void> onTabChanged(String fromTab, String toTab) async {
    await _posthog.trackNavigationEvent(
      eventType: 'tab_changed',
      fromScreen: fromTab,
      toScreen: toTab,
      additionalProperties: {
        'tab_change_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================================
  // SETTINGS EXAMPLES
  // ============================================================================

  /// Example: Track theme change
  Future<void> onThemeChanged(String oldTheme, String newTheme) async {
    await _posthog.trackSettingsEvent(
      eventType: 'changed',
      settingName: 'theme',
      oldValue: oldTheme,
      newValue: newTheme,
      additionalProperties: {
        'change_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example: Track language change
  Future<void> onLanguageChanged(String oldLanguage, String newLanguage) async {
    await _posthog.trackSettingsEvent(
      eventType: 'changed',
      settingName: 'language',
      oldValue: oldLanguage,
      newValue: newLanguage,
      additionalProperties: {
        'change_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================================
  // ERROR TRACKING EXAMPLES
  // ============================================================================

  /// Example: Track network error
  Future<void> onNetworkError(String errorMessage, String screen) async {
    await _posthog.trackError(
      errorType: 'network_error',
      errorMessage: errorMessage,
      screen: screen,
      additionalProperties: {
        'error_timestamp': DateTime.now().toIso8601String(),
        'connection_type': 'wifi', // You can get this from connectivity package
      },
    );
  }

  /// Example: Track audio error
  Future<void> onAudioError(String errorMessage, String hymnNumber) async {
    await _posthog.trackError(
      errorType: 'audio_error',
      errorMessage: errorMessage,
      additionalProperties: {
        'hymn_number': hymnNumber,
        'error_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================================
  // PERFORMANCE TRACKING EXAMPLES
  // ============================================================================

  /// Example: Track app startup time
  Future<void> onAppStartup(double startupTimeMs) async {
    await _posthog.trackPerformance(
      metricName: 'app_startup_time',
      value: startupTimeMs,
      unit: 'milliseconds',
      additionalProperties: {
        'startup_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example: Track screen load time
  Future<void> onScreenLoadTime(String screenName, double loadTimeMs) async {
    await _posthog.trackPerformance(
      metricName: 'screen_load_time',
      value: loadTimeMs,
      unit: 'milliseconds',
      additionalProperties: {
        'screen_name': screenName,
        'load_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================================
  // FEATURE FLAG EXAMPLES
  // ============================================================================

  /// Example: Check feature flag and track usage
  Future<void> checkNewFeatureFlag() async {
    final isNewFeatureEnabled =
        await _posthog.getFeatureFlag('new_hymn_player');

    if (isNewFeatureEnabled) {
      await _posthog.trackEvent(
        eventName: 'new_feature_used',
        properties: {
          'feature_name': 'new_hymn_player',
          'usage_timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  // ============================================================================
  // SESSION MANAGEMENT EXAMPLES
  // ============================================================================

  /// Example: Start new session
  Future<void> startNewSession() async {
    await _posthog.startSession();
    await _posthog.trackEvent(
      eventName: 'session_started',
      properties: {
        'session_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example: End session
  Future<void> endSession() async {
    await _posthog.trackEvent(
      eventName: 'session_ended',
      properties: {
        'session_end_timestamp': DateTime.now().toIso8601String(),
      },
    );
    await _posthog.endSession();
  }
}
