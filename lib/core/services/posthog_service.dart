import 'package:logger/logger.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../shared/constants/app_configs.dart';

/// Service for managing PostHog analytics across the app
/// Provides centralized event tracking, user identification, and analytics management
class PostHogService {
  static final PostHogService _instance = PostHogService._internal();
  factory PostHogService() => _instance;
  PostHogService._internal();

  final Logger _logger = Logger();
  bool _isInitialized = false;

  /// Initialize PostHog service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final config = PostHogConfig(AppConfigs.posthogApiKey);
      config.host = AppConfigs.posthogHost;
      config.debug = AppConfigs.posthogDebug;
      config.captureApplicationLifecycleEvents =
          AppConfigs.posthogCaptureApplicationLifecycleEvents;
      config.sessionReplay = AppConfigs.posthogSessionReplay;
      config.sessionReplayConfig.maskAllTexts =
          AppConfigs.posthogSessionReplayMaskAllTexts;
      config.sessionReplayConfig.maskAllImages =
          AppConfigs.posthogSessionReplayMaskAllImages;

      await Posthog().setup(config);
      _isInitialized = true;
      _logger.i('PostHog service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize PostHog service: $e');
      rethrow;
    }
  }

  /// Check if PostHog is initialized
  bool get isInitialized => _isInitialized;

  // ============================================================================
  // USER IDENTIFICATION & PROPERTIES
  // ============================================================================

  /// Identify a user with their unique ID and properties
  Future<void> identifyUser({
    required String userId,
    String? email,
    String? name,
    Map<String, dynamic>? additionalProperties,
  }) async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return;
    }

    try {
      final properties = <String, dynamic>{
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        'identified_at': DateTime.now().toIso8601String(),
        ...?additionalProperties,
      };

      await Posthog().identify(
          userId: userId, userProperties: properties.cast<String, Object>());
      _logger.d('User identified: $userId');
    } catch (e) {
      _logger.e('Failed to identify user: $e');
    }
  }

  /// Reset user identification (for logout)
  Future<void> resetUser() async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return;
    }

    try {
      await Posthog().reset();
      _logger.d('User identification reset');
    } catch (e) {
      _logger.e('Failed to reset user: $e');
    }
  }

  // ============================================================================
  // EVENT TRACKING
  // ============================================================================

  /// Track a custom event with properties
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
    String? distinctId,
  }) async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return;
    }

    try {
      final eventProperties = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        ...?properties,
      };

      await Posthog().capture(
        eventName: eventName,
        properties: eventProperties.cast<String, Object>(),
      );
      _logger.d('Event tracked: $eventName');
    } catch (e) {
      _logger.e('Failed to track event $eventName: $e');
    }
  }

  // ============================================================================
  // APP-SPECIFIC EVENTS
  // ============================================================================

  /// Track hymn-related events
  Future<void> trackHymnEvent({
    required String eventType,
    required String hymnNumber,
    String? hymnTitle,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'hymn_$eventType',
      properties: {
        'hymn_number': hymnNumber,
        if (hymnTitle != null) 'hymn_title': hymnTitle,
        'event_type': eventType,
        ...?additionalProperties,
      },
    );
  }

  /// Track audio playback events
  Future<void> trackAudioEvent({
    required String eventType,
    String? hymnNumber,
    String? hymnTitle,
    double? duration,
    double? position,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'audio_$eventType',
      properties: {
        if (hymnNumber != null) 'hymn_number': hymnNumber,
        if (hymnTitle != null) 'hymn_title': hymnTitle,
        if (duration != null) 'duration': duration,
        if (position != null) 'position': position,
        'event_type': eventType,
        ...?additionalProperties,
      },
    );
  }

  /// Track favorites events
  Future<void> trackFavoritesEvent({
    required String eventType,
    String? hymnNumber,
    String? hymnTitle,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'favorites_$eventType',
      properties: {
        if (hymnNumber != null) 'hymn_number': hymnNumber,
        if (hymnTitle != null) 'hymn_title': hymnTitle,
        'event_type': eventType,
        ...?additionalProperties,
      },
    );
  }

  /// Track authentication events
  Future<void> trackAuthEvent({
    required String eventType,
    String? method,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'auth_$eventType',
      properties: {
        if (method != null) 'auth_method': method,
        'event_type': eventType,
        ...?additionalProperties,
      },
    );
  }

  /// Track search events
  Future<void> trackSearchEvent({
    required String eventType,
    String? query,
    int? resultCount,
    String? searchType,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'search_$eventType',
      properties: {
        if (query != null) 'search_query': query,
        if (resultCount != null) 'result_count': resultCount,
        if (searchType != null) 'search_type': searchType,
        'event_type': eventType,
        ...?additionalProperties,
      },
    );
  }

  /// Track navigation events
  Future<void> trackNavigationEvent({
    required String eventType,
    String? fromScreen,
    String? toScreen,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'navigation_$eventType',
      properties: {
        if (fromScreen != null) 'from_screen': fromScreen,
        if (toScreen != null) 'to_screen': toScreen,
        'event_type': eventType,
        ...?additionalProperties,
      },
    );
  }

  /// Track settings events
  Future<void> trackSettingsEvent({
    required String eventType,
    String? settingName,
    dynamic oldValue,
    dynamic newValue,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'settings_$eventType',
      properties: {
        if (settingName != null) 'setting_name': settingName,
        if (oldValue != null) 'old_value': oldValue.toString(),
        if (newValue != null) 'new_value': newValue.toString(),
        'event_type': eventType,
        ...?additionalProperties,
      },
    );
  }

  // ============================================================================
  // CONVENIENCE METHODS FOR COMMON EVENTS
  // ============================================================================

  /// Track app launch
  Future<void> trackAppLaunch() async {
    await trackEvent(
      eventName: 'app_launched',
      properties: {
        'launch_time': DateTime.now().toIso8601String(),
        'app_version': '1.0.0+2', // Update this with actual version
      },
    );
  }

  /// Track app background/foreground
  Future<void> trackAppStateChange(String state) async {
    await trackEvent(
      eventName: 'app_state_changed',
      properties: {
        'state': state,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track error events
  Future<void> trackError({
    required String errorType,
    String? errorMessage,
    String? screen,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'error_occurred',
      properties: {
        'error_type': errorType,
        if (errorMessage != null) 'error_message': errorMessage,
        if (screen != null) 'screen': screen,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalProperties,
      },
    );
  }

  /// Track performance metrics
  Future<void> trackPerformance({
    required String metricName,
    required double value,
    String? unit,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventName: 'performance_metric',
      properties: {
        'metric_name': metricName,
        'value': value,
        if (unit != null) 'unit': unit,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalProperties,
      },
    );
  }

  // ============================================================================
  // FEATURE FLAGS & EXPERIMENTS
  // ============================================================================

  /// Get feature flag value
  Future<bool> getFeatureFlag(String flagKey) async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return false;
    }

    try {
      final result = await Posthog().getFeatureFlag(flagKey);
      _logger.d('Feature flag $flagKey: $result');
      return result == true;
    } catch (e) {
      _logger.e('Failed to get feature flag $flagKey: $e');
      return false;
    }
  }

  /// Get feature flag payload
  Future<dynamic> getFeatureFlagPayload(String flagKey) async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return null;
    }

    try {
      final result = await Posthog().getFeatureFlagPayload(flagKey);
      _logger.d('Feature flag payload $flagKey: $result');
      return result;
    } catch (e) {
      _logger.e('Failed to get feature flag payload $flagKey: $e');
      return null;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Flush events to PostHog
  Future<void> flush() async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return;
    }

    try {
      await Posthog().flush();
      _logger.d('Events flushed to PostHog');
    } catch (e) {
      _logger.e('Failed to flush events: $e');
    }
  }

  /// Get current distinct ID
  Future<String?> getDistinctId() async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return null;
    }

    try {
      final result = await Posthog().getDistinctId();
      _logger.d('Current distinct ID: $result');
      return result;
    } catch (e) {
      _logger.e('Failed to get distinct ID: $e');
      return null;
    }
  }
}
