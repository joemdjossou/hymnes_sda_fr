import 'package:flutter/material.dart';

import '../services/posthog_service.dart';

/// Mixin to easily add PostHog tracking to widgets
mixin PostHogTrackingMixin<T extends StatefulWidget> on State<T> {
  final PostHogService _posthog = PostHogService();

  /// Track screen view when widget is built
  void trackScreenView(String screenName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _posthog.trackNavigationEvent(
        eventType: 'screen_viewed',
        toScreen: screenName,
      );
    });
  }

  /// Track hymn view
  void trackHymnView(String hymnNumber, String hymnTitle, {String? source}) {
    _posthog.trackHymnEvent(
      eventType: 'viewed',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      additionalProperties: {
        if (source != null) 'source': source,
        'screen': widget.runtimeType.toString(),
      },
    );
  }

  /// Track hymn share
  void trackHymnShare(String hymnNumber, String hymnTitle, String shareMethod) {
    _posthog.trackHymnEvent(
      eventType: 'shared',
      hymnNumber: hymnNumber,
      hymnTitle: hymnTitle,
      additionalProperties: {
        'share_method': shareMethod,
        'screen': widget.runtimeType.toString(),
      },
    );
  }

  /// Track search
  void trackSearch(String query, int resultCount, {String? searchType}) {
    _posthog.trackSearchEvent(
      eventType: 'performed',
      query: query,
      resultCount: resultCount,
      searchType: searchType ?? 'hymn',
      additionalProperties: {
        'screen': widget.runtimeType.toString(),
      },
    );
  }

  /// Track search result click
  void trackSearchResultClick(String query, String hymnNumber, int position) {
    _posthog.trackSearchEvent(
      eventType: 'result_clicked',
      query: query,
      additionalProperties: {
        'hymn_number': hymnNumber,
        'result_position': position,
        'screen': widget.runtimeType.toString(),
      },
    );
  }

  /// Track error
  void trackError(String errorType, String errorMessage) {
    _posthog.trackError(
      errorType: errorType,
      errorMessage: errorMessage,
      screen: widget.runtimeType.toString(),
    );
  }

  /// Track custom event
  void trackCustomEvent(String eventName, Map<String, dynamic>? properties) {
    _posthog.trackEvent(
      eventName: eventName,
      properties: {
        'screen': widget.runtimeType.toString(),
        ...?properties,
      },
    );
  }
}
