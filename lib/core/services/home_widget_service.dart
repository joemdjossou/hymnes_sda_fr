import 'dart:math';

import 'package:home_widget/home_widget.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';
import 'package:logger/logger.dart';

/// Service to manage home widget data updates
class HomeWidgetService {
  static final Logger _logger = Logger();
  static const String _hymnsCountKey = 'hymns_count';
  static const String _favoritesCountKey = 'favorites_count';
  static const String _featuredHymnNumberKey = 'featured_hymn_number';
  static const String _featuredHymnTitleKey = 'featured_hymn_title';
  static const String _featuredHymnLyricsKey = 'featured_hymn_lyrics';

  /// Initialize the home widget service
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      _logger.d(
          'HomeWidgetService initialized with group ID: ${AppConstants.appGroupId}');
    } catch (e) {
      _logger.e('Failed to initialize HomeWidgetService: $e');
    }
  }

  /// Update hymns count in the home widget
  static Future<void> updateHymnsCount(int count) async {
    try {
      await HomeWidget.saveWidgetData(_hymnsCountKey, count);
      await HomeWidget.updateWidget(
        name: AppConstants.iOSWidgetName,
        androidName: AppConstants.androidWidgetName,
      );
      _logger.d('Updated hymns count: $count');
    } catch (e) {
      _logger.e('Failed to update hymns count: $e');
    }
  }

  /// Update favorites count in the home widget
  static Future<void> updateFavoritesCount(int count) async {
    try {
      await HomeWidget.saveWidgetData(_favoritesCountKey, count);
      await HomeWidget.updateWidget(
        name: AppConstants.iOSWidgetName,
        androidName: AppConstants.androidWidgetName,
      );
      _logger.d('Updated favorites count: $count');
    } catch (e) {
      _logger.e('Failed to update favorites count: $e');
    }
  }

  /// Update both counts at once
  static Future<void> updateCounts({
    required int hymnsCount,
    required int favoritesCount,
  }) async {
    try {
      await HomeWidget.saveWidgetData(_hymnsCountKey, hymnsCount);
      await HomeWidget.saveWidgetData(_favoritesCountKey, favoritesCount);
      await HomeWidget.updateWidget(
        name: AppConstants.iOSWidgetName,
        androidName: AppConstants.androidWidgetName,
      );
      _logger
          .d('Updated counts - Hymns: $hymnsCount, Favorites: $favoritesCount');
    } catch (e) {
      _logger.e('Failed to update counts: $e');
    }
  }

  /// Update featured hymn data
  static Future<void> updateFeaturedHymn({
    required String number,
    required String title,
    required String lyrics,
  }) async {
    try {
      await HomeWidget.saveWidgetData(_featuredHymnNumberKey, number);
      await HomeWidget.saveWidgetData(_featuredHymnTitleKey, title);
      await HomeWidget.saveWidgetData(_featuredHymnLyricsKey, lyrics);
      await HomeWidget.updateWidget(
        name: AppConstants.iOSWidgetName,
        androidName: AppConstants.androidWidgetName,
      );
      _logger.d('Updated featured hymn: #$number - $title');
    } catch (e) {
      _logger.e('Failed to update featured hymn: $e');
    }
  }

  /// Update all widget data at once
  static Future<void> updateAllData({
    required int hymnsCount,
    required int favoritesCount,
    String? featuredHymnNumber,
    String? featuredHymnTitle,
    String? featuredHymnLyrics,
  }) async {
    try {
      await HomeWidget.saveWidgetData(_hymnsCountKey, hymnsCount);
      await HomeWidget.saveWidgetData(_favoritesCountKey, favoritesCount);

      if (featuredHymnNumber != null &&
          featuredHymnTitle != null &&
          featuredHymnLyrics != null) {
        await HomeWidget.saveWidgetData(
            _featuredHymnNumberKey, featuredHymnNumber);
        await HomeWidget.saveWidgetData(
            _featuredHymnTitleKey, featuredHymnTitle);
        await HomeWidget.saveWidgetData(
            _featuredHymnLyricsKey, featuredHymnLyrics);
      }

      await HomeWidget.updateWidget(
        name: AppConstants.iOSWidgetName,
        androidName: AppConstants.androidWidgetName,
      );
      _logger.d(
          'Updated all widget data - Hymns: $hymnsCount, Favorites: $favoritesCount, Featured: #$featuredHymnNumber');
    } catch (e) {
      _logger.e('Failed to update all widget data: $e');
    }
  }

  /// Get current hymns count from widget data
  static Future<int> getHymnsCount() async {
    try {
      final count =
          await HomeWidget.getWidgetData(_hymnsCountKey, defaultValue: 0);
      return count is int ? count : 0;
    } catch (e) {
      _logger.e('Failed to get hymns count: $e');
      return 0;
    }
  }

  /// Get current favorites count from widget data
  static Future<int> getFavoritesCount() async {
    try {
      final count =
          await HomeWidget.getWidgetData(_favoritesCountKey, defaultValue: 0);
      return count is int ? count : 0;
    } catch (e) {
      _logger.e('Failed to get favorites count: $e');
      return 0;
    }
  }

  /// Send Android widget update intent
  static Future<void> sendAndroidUpdateIntent({
    required int hymnsCount,
    required int favoritesCount,
  }) async {
    try {
      // For Android, we'll use the standard updateWidget method
      // The Android widget will read from SharedPreferences
      await HomeWidget.updateWidget(
        name: AppConstants.iOSWidgetName,
        androidName: AppConstants.androidWidgetName,
      );
      _logger.d(
          'Sent Android update intent - Hymns: $hymnsCount, Favorites: $favoritesCount');
    } catch (e) {
      _logger.e('Failed to send Android update intent: $e');
    }
  }

  /// Update featured hymn with a random selection from available hymns
  static Future<void> updateRandomFeaturedHymn(List<dynamic> hymns) async {
    try {
      if (hymns.isNotEmpty) {
        final random = Random();
        final featuredHymn = hymns[random.nextInt(hymns.length)];

        // Get first few lines of lyrics for the widget
        final lyricsLines = featuredHymn.lyrics.split('\n').take(2).join(' ');

        await updateFeaturedHymn(
          number: featuredHymn.number,
          title: featuredHymn.title,
          lyrics: lyricsLines,
        );

        _logger.d(
            'Updated random featured hymn: #${featuredHymn.number} - ${featuredHymn.title}');
      }
    } catch (e) {
      _logger.e('Failed to update random featured hymn: $e');
    }
  }
}
