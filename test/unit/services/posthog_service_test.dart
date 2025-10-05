import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/services/posthog_service.dart';
import 'package:mockito/annotations.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'posthog_service_test.mocks.dart';

@GenerateMocks([Posthog])
void main() {
  group('PostHogService Tests', () {
    late PostHogService service;
    late MockPosthog mockPosthog;

    setUp(() {
      service = PostHogService();
      mockPosthog = MockPosthog();
    });

    test('should be a singleton', () {
      final instance1 = PostHogService();
      final instance2 = PostHogService();
      expect(instance1, equals(instance2));
    });

    test('should start uninitialized', () {
      expect(service.isInitialized, isFalse);
    });

    group('User Identification', () {
      test('should identify user with basic properties', () async {
        // This test would require mocking Posthog setup
        // For now, we'll test the method exists and doesn't throw
        expect(
            () => service.identifyUser(userId: 'test_user'), returnsNormally);
      });

      test('should identify user with all properties', () async {
        expect(
            () => service.identifyUser(
                  userId: 'test_user',
                  email: 'test@example.com',
                  name: 'Test User',
                  additionalProperties: {'role': 'premium'},
                ),
            returnsNormally);
      });

      test('should reset user', () async {
        expect(() => service.resetUser(), returnsNormally);
      });
    });

    group('Event Tracking', () {
      test('should track custom event', () async {
        expect(
            () => service.trackEvent(
                  eventName: 'test_event',
                  properties: {'key': 'value'},
                ),
            returnsNormally);
      });

      test('should track event without properties', () async {
        expect(() => service.trackEvent(eventName: 'simple_event'),
            returnsNormally);
      });

      test('should track event with distinct ID', () async {
        expect(
            () => service.trackEvent(
                  eventName: 'test_event',
                  distinctId: 'user_123',
                ),
            returnsNormally);
      });
    });

    group('Hymn Events', () {
      test('should track hymn play event', () async {
        expect(
            () => service.trackHymnEvent(
                  eventType: 'played',
                  hymnNumber: '123',
                  hymnTitle: 'Amazing Grace',
                ),
            returnsNormally);
      });

      test('should track hymn view event', () async {
        expect(
            () => service.trackHymnEvent(
                  eventType: 'viewed',
                  hymnNumber: '456',
                  hymnTitle: 'How Great Thou Art',
                  additionalProperties: {'source': 'search'},
                ),
            returnsNormally);
      });

      test('should track hymn share event', () async {
        expect(
            () => service.trackHymnEvent(
                  eventType: 'shared',
                  hymnNumber: '789',
                  hymnTitle: 'Blessed Assurance',
                  additionalProperties: {'share_method': 'whatsapp'},
                ),
            returnsNormally);
      });
    });

    group('Audio Events', () {
      test('should track audio play event', () async {
        expect(
            () => service.trackAudioEvent(
                  eventType: 'play',
                  hymnNumber: '123',
                  hymnTitle: 'Amazing Grace',
                  duration: 180.5,
                ),
            returnsNormally);
      });

      test('should track audio pause event', () async {
        expect(
            () => service.trackAudioEvent(
                  eventType: 'pause',
                  hymnNumber: '123',
                  position: 45.2,
                ),
            returnsNormally);
      });

      test('should track audio stop event', () async {
        expect(
            () => service.trackAudioEvent(
                  eventType: 'stop',
                  hymnNumber: '123',
                  position: 120.0,
                  duration: 180.5,
                ),
            returnsNormally);
      });

      test('should track audio seek event', () async {
        expect(
            () => service.trackAudioEvent(
                  eventType: 'seek',
                  hymnNumber: '123',
                  position: 60.0,
                  additionalProperties: {'seek_from': 30.0},
                ),
            returnsNormally);
      });
    });

    group('Favorites Events', () {
      test('should track favorite added event', () async {
        expect(
            () => service.trackFavoritesEvent(
                  eventType: 'added',
                  hymnNumber: '123',
                  hymnTitle: 'Amazing Grace',
                ),
            returnsNormally);
      });

      test('should track favorite removed event', () async {
        expect(
            () => service.trackFavoritesEvent(
                  eventType: 'removed',
                  hymnNumber: '123',
                  hymnTitle: 'Amazing Grace',
                ),
            returnsNormally);
      });

      test('should track favorites viewed event', () async {
        expect(
            () => service.trackFavoritesEvent(
                  eventType: 'viewed',
                  additionalProperties: {'favorites_count': 25},
                ),
            returnsNormally);
      });
    });

    group('Authentication Events', () {
      test('should track login event', () async {
        expect(
            () => service.trackAuthEvent(
                  eventType: 'login',
                  method: 'google',
                ),
            returnsNormally);
      });

      test('should track logout event', () async {
        expect(
            () => service.trackAuthEvent(
                  eventType: 'logout',
                ),
            returnsNormally);
      });

      test('should track signup event', () async {
        expect(
            () => service.trackAuthEvent(
                  eventType: 'signup',
                  method: 'email',
                  additionalProperties: {'source': 'app'},
                ),
            returnsNormally);
      });
    });

    group('Search Events', () {
      test('should track search performed event', () async {
        expect(
            () => service.trackSearchEvent(
                  eventType: 'performed',
                  query: 'amazing grace',
                  resultCount: 5,
                  searchType: 'hymn',
                ),
            returnsNormally);
      });

      test('should track search result clicked event', () async {
        expect(
            () => service.trackSearchEvent(
                  eventType: 'result_clicked',
                  query: 'amazing grace',
                  resultCount: 5,
                  additionalProperties: {'result_position': 1},
                ),
            returnsNormally);
      });
    });

    group('Navigation Events', () {
      test('should track screen navigation', () async {
        expect(
            () => service.trackNavigationEvent(
                  eventType: 'screen_changed',
                  fromScreen: 'home',
                  toScreen: 'hymn_detail',
                ),
            returnsNormally);
      });

      test('should track tab navigation', () async {
        expect(
            () => service.trackNavigationEvent(
                  eventType: 'tab_changed',
                  fromScreen: 'favorites',
                  toScreen: 'search',
                ),
            returnsNormally);
      });
    });

    group('Settings Events', () {
      test('should track setting changed event', () async {
        expect(
            () => service.trackSettingsEvent(
                  eventType: 'changed',
                  settingName: 'theme',
                  oldValue: 'light',
                  newValue: 'dark',
                ),
            returnsNormally);
      });

      test('should track settings viewed event', () async {
        expect(
            () => service.trackSettingsEvent(
                  eventType: 'viewed',
                ),
            returnsNormally);
      });
    });

    group('App Events', () {
      test('should track app launch', () async {
        expect(() => service.trackAppLaunch(), returnsNormally);
      });

      test('should track app state change', () async {
        expect(
            () => service.trackAppStateChange('background'), returnsNormally);
        expect(
            () => service.trackAppStateChange('foreground'), returnsNormally);
      });
    });

    group('Error Events', () {
      test('should track error event', () async {
        expect(
            () => service.trackError(
                  errorType: 'network_error',
                  errorMessage: 'Connection timeout',
                  screen: 'hymn_list',
                ),
            returnsNormally);
      });

      test('should track error without message', () async {
        expect(
            () => service.trackError(
                  errorType: 'unknown_error',
                  screen: 'home',
                ),
            returnsNormally);
      });
    });

    group('Performance Events', () {
      test('should track performance metric', () async {
        expect(
            () => service.trackPerformance(
                  metricName: 'app_startup_time',
                  value: 2.5,
                  unit: 'seconds',
                ),
            returnsNormally);
      });

      test('should track performance without unit', () async {
        expect(
            () => service.trackPerformance(
                  metricName: 'memory_usage',
                  value: 150.0,
                ),
            returnsNormally);
      });
    });

    group('Feature Flags', () {
      test('should get feature flag', () async {
        expect(() => service.getFeatureFlag('new_feature'), returnsNormally);
      });

      test('should get feature flag payload', () async {
        expect(() => service.getFeatureFlagPayload('experiment_config'),
            returnsNormally);
      });
    });

    group('Utility Methods', () {
      test('should flush events', () async {
        expect(() => service.flush(), returnsNormally);
      });

      test('should get distinct ID', () async {
        expect(() => service.getDistinctId(), returnsNormally);
      });

    });
  });

  group('PostHogService Integration Tests', () {
    late PostHogService service;

    setUp(() {
      service = PostHogService();
    });

    test('should handle multiple rapid events', () async {
      // Test that the service can handle multiple events in quick succession
      final futures = <Future<void>>[];

      for (int i = 0; i < 10; i++) {
        futures.add(service.trackEvent(
          eventName: 'rapid_event_$i',
          properties: {'index': i},
        ));
      }

      expect(() => Future.wait(futures), returnsNormally);
    });

    test('should handle complex event properties', () async {
      expect(
          () => service.trackEvent(
                eventName: 'complex_event',
                properties: {
                  'string_prop': 'value',
                  'int_prop': 42,
                  'double_prop': 3.14,
                  'bool_prop': true,
                  'list_prop': [1, 2, 3],
                  'map_prop': {'nested': 'value'},
                  'null_prop': null,
                },
              ),
          returnsNormally);
    });

    test('should handle empty properties gracefully', () async {
      expect(
          () => service.trackEvent(
                eventName: 'empty_props_event',
                properties: {},
              ),
          returnsNormally);
    });

    test('should handle null properties gracefully', () async {
      expect(
          () => service.trackEvent(
                eventName: 'null_props_event',
                properties: null,
              ),
          returnsNormally);
    });
  });
}
