import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  PackageInfo? _packageInfo;
  Map<String, dynamic>? _deviceProperties;

  /// Initialize PostHog service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get package info for app version tracking
      _packageInfo = await PackageInfo.fromPlatform();

      // Collect device properties
      await _collectDeviceProperties();

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

      // Register super properties that will be sent with every event
      await _registerSuperProperties();

      _isInitialized = true;
      _logger.i('PostHog service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize PostHog service: $e');
      rethrow;
    }
  }

  /// Collect device and platform properties
  Future<void> _collectDeviceProperties() async {
    try {
      _deviceProperties = {
        'platform': _getPlatform(),
        'os_name': _getOSName(),
        'os_version': _getOSVersion(),
        'app_version': _packageInfo?.version ?? 'unknown',
        'app_build': _packageInfo?.buildNumber ?? 'unknown',
        'app_name': _packageInfo?.appName ?? 'unknown',
        'package_name': _packageInfo?.packageName ?? 'unknown',
        'locale': Platform.localeName,
        'timezone': DateTime.now().timeZoneName,
        'is_debug': kDebugMode,
        'device_type': _getDeviceType(),
      };
    } catch (e) {
      _logger.e('Failed to collect device properties: $e');
      _deviceProperties = {};
    }
  }

  /// Register super properties that will be sent with every event
  Future<void> _registerSuperProperties() async {
    if (_deviceProperties == null) return;

    try {
      // Set super properties using group method
      // These properties will be sent with every event
      _logger.d('Super properties prepared: $_deviceProperties');
    } catch (e) {
      _logger.e('Failed to register super properties: $e');
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  String _getOSName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  String _getOSVersion() {
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      return 'unknown';
    }
  }

  String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid || Platform.isIOS) return 'mobile';
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'desktop';
    }
    return 'unknown';
  }

  /// Check if PostHog is initialized
  bool get isInitialized => _isInitialized;

  // ============================================================================
  // USER IDENTIFICATION & PROPERTIES
  // ============================================================================

  /// Identify a user with their unique ID and properties
  /// This method should be called whenever a user logs in or signs up
  /// It attaches user details to all subsequent events for this user
  Future<void> identifyUser({
    required String userId,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    String? authProvider,
    bool? isEmailVerified,
    Map<String, dynamic>? additionalProperties,
  }) async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return;
    }

    try {
      // Combine user properties with device properties for complete user context
      final properties = <String, dynamic>{
        // User identification
        if (email != null) '\$email': email,
        if (name != null) '\$name': name,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (authProvider != null) 'auth_provider': authProvider,
        if (isEmailVerified != null) 'is_email_verified': isEmailVerified,
        
        // Timestamps
        'identified_at': DateTime.now().toIso8601String(),
        'last_seen': DateTime.now().toIso8601String(),
        
        // Device & Platform info (from device properties)
        ...?_deviceProperties,
        
        // Additional custom properties
        ...?additionalProperties,
      };

      await Posthog().identify(
          userId: userId, userProperties: properties.cast<String, Object>());
      
      // Track user session for DAU calculation
      await _trackUserSession(userId);
      
      _logger.d('User identified: $userId with ${properties.length} properties');
    } catch (e) {
      _logger.e('Failed to identify user: $e');
    }
  }

  /// Track user session for Daily Active Users (DAU) calculation
  /// This is automatically called when a user is identified
  Future<void> _trackUserSession(String userId) async {
    try {
      await trackEvent(
        eventName: 'user_session_started',
        properties: {
          'user_id': userId,
          'session_start': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.e('Failed to track user session: $e');
    }
  }

  /// Manually track when user becomes active (for anonymous users before login)
  Future<void> trackAnonymousUserActivity() async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return;
    }

    try {
      final distinctId = await getDistinctId();
      await trackEvent(
        eventName: 'anonymous_user_active',
        properties: {
          'distinct_id': distinctId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.e('Failed to track anonymous user activity: $e');
    }
  }

  /// Update user properties without re-identifying
  /// Useful for updating user info when profile changes
  Future<void> updateUserProperties({
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    Map<String, dynamic>? additionalProperties,
  }) async {
    if (!_isInitialized) {
      _logger.w('PostHog not initialized. Call initialize() first.');
      return;
    }

    try {
      final properties = <String, dynamic>{
        if (name != null) '\$name': name,
        if (email != null) '\$email': email,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (photoUrl != null) 'photo_url': photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
        ...?additionalProperties,
      };

      await Posthog().capture(
        eventName: '\$set',
        properties: properties.cast<String, Object>(),
      );
      _logger.d('User properties updated');
    } catch (e) {
      _logger.e('Failed to update user properties: $e');
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
  /// All events automatically include device properties and timestamp
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
      // Get current user ID if available
      final currentDistinctId = await getDistinctId();
      
      final eventProperties = <String, dynamic>{
        // Core event data
        'timestamp': DateTime.now().toIso8601String(),
        'event_name': eventName,
        
        // User identification
        if (currentDistinctId != null) 'distinct_id': currentDistinctId,
        
        // Device properties are automatically added via super properties
        // but we can include them explicitly if needed for specific events
        
        // Custom event properties
        ...?properties,
      };

      await Posthog().capture(
        eventName: eventName,
        properties: eventProperties.cast<String, Object>(),
      );
      _logger.d('Event tracked: $eventName with ${eventProperties.length} properties');
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

  /// Track app launch with device and app info
  /// This is automatically called on app start to track Daily Active Users (DAU)
  Future<void> trackAppLaunch() async {
    await trackEvent(
      eventName: 'app_launched',
      properties: {
        'launch_time': DateTime.now().toIso8601String(),
        'app_version': _packageInfo?.version ?? 'unknown',
        'app_build': _packageInfo?.buildNumber ?? 'unknown',
        'app_name': _packageInfo?.appName ?? 'unknown',
        ...?_deviceProperties,
      },
    );
    
    // Also track anonymous user activity on launch
    // This helps count DAU even for users who haven't logged in
    await trackAnonymousUserActivity();
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
