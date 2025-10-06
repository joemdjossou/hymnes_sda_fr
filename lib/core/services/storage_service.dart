import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/favorites/models/favorite_hymn.dart';
import '../models/hymn.dart';
import 'error_logging_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _favoritesBox = 'favorites';
  static const String _settingsBox = 'settings';
  static const String _recentlyPlayedBox = 'recently_played';

  late Box _favoritesBoxInstance;
  late Box _settingsBoxInstance;
  late Box _recentlyPlayedBoxInstance;

  // Error logging service
  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Open boxes
      _favoritesBoxInstance = await Hive.openBox(_favoritesBox);
      _settingsBoxInstance = await Hive.openBox(_settingsBox);
      _recentlyPlayedBoxInstance = await Hive.openBox(_recentlyPlayedBox);

      await _errorLogger.logInfo(
        'StorageService',
        'Storage service initialized successfully',
        context: {
          'boxes': [_favoritesBox, _settingsBox, _recentlyPlayedBox],
        },
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'StorageService',
        'initialize',
        'Failed to initialize storage service',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  // Favorites Management
  Future<void> addToFavorites(Hymn hymn) async {
    try {
      final hymnData = hymn.toJson();
      hymnData['dateAdded'] = DateTime.now().millisecondsSinceEpoch;
      await _favoritesBoxInstance.put(hymn.number, hymnData);

      await _errorLogger.logDebug(
        'StorageService',
        'Added hymn to favorites',
        context: {
          'hymnNumber': hymn.number,
          'hymnTitle': hymn.title,
        },
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'StorageService',
        'addToFavorites',
        'Failed to add hymn to favorites',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {
          'hymnNumber': hymn.number,
          'hymnTitle': hymn.title,
        },
      );
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String hymnNumber) async {
    await _favoritesBoxInstance.delete(hymnNumber);
  }

  bool isFavorite(String hymnNumber) {
    return _favoritesBoxInstance.containsKey(hymnNumber);
  }

  Future<List<FavoriteHymn>> getFavorites() async {
    try {
      final jsonList = _favoritesBoxInstance.values.toList();
      return jsonList.map((json) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        final Map<String, dynamic> hymnJson = Map<String, dynamic>.from(json);
        return FavoriteHymn.fromJson(hymnJson);
      }).toList();
    } catch (e) {
      Logger().d('Error loading favorites: $e');
      // Return empty list if there's an error
      return [];
    }
  }

  Future<List<Hymn>> getFavoritesAsHymns() async {
    final favorites = await getFavorites();
    return favorites.map((favorite) => favorite.hymn).toList();
  }

  // Recently Played Management
  Future<void> addToRecentlyPlayed(Hymn hymn) async {
    final recentlyPlayed = await getRecentlyPlayed();

    // Remove if already exists
    recentlyPlayed.removeWhere((h) => h.number == hymn.number);

    // Add to beginning
    recentlyPlayed.insert(0, hymn);

    // Keep only last 20 items
    if (recentlyPlayed.length > 20) {
      recentlyPlayed.removeRange(20, recentlyPlayed.length);
    }

    // Save back to storage
    final jsonList = recentlyPlayed.map((h) => h.toJson()).toList();
    await _recentlyPlayedBoxInstance.put('recently_played', jsonList);
  }

  Future<List<Hymn>> getRecentlyPlayed() async {
    try {
      final jsonList = _recentlyPlayedBoxInstance
          .get('recently_played', defaultValue: <Map<String, dynamic>>[]);
      return jsonList.map((json) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        final Map<String, dynamic> hymnJson = Map<String, dynamic>.from(json);
        return Hymn.fromJson(hymnJson);
      }).toList();
    } catch (e) {
      Logger().d('Error loading recently played: $e');
      // Return empty list if there's an error
      return [];
    }
  }

  // Settings Management
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBoxInstance.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBoxInstance.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> removeSetting(String key) async {
    await _settingsBoxInstance.delete(key);
  }

  // Legacy SharedPreferences support
  Future<void> migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Migrate favorites
    final favoritesList = prefs.getStringList('favorites') ?? [];
    for (final hymnNumber in favoritesList) {
      // This would need to be implemented based on your hymn data structure
      // For now, we'll just store the hymn number
      await _settingsBoxInstance.put('legacy_favorite_$hymnNumber', true);
    }

    // Clear old data
    await prefs.clear();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _favoritesBoxInstance.clear();
    await _settingsBoxInstance.clear();
    await _recentlyPlayedBoxInstance.clear();
  }

  // Export data
  Future<Map<String, dynamic>> exportData() async {
    final favorites = await getFavorites();
    final recentlyPlayed = await getRecentlyPlayed();

    return {
      'favorites': favorites.map((h) => h.toJson()).toList(),
      'recently_played': recentlyPlayed.map((h) => h.toJson()).toList(),
      'settings': Map<String, dynamic>.from(_settingsBoxInstance.toMap()),
    };
  }

  // Import data
  Future<void> importData(Map<String, dynamic> data) async {
    if (data['favorites'] != null) {
      final favorites = (data['favorites'] as List).map((json) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        final Map<String, dynamic> hymnJson = Map<String, dynamic>.from(json);
        return Hymn.fromJson(hymnJson);
      }).toList();

      await _favoritesBoxInstance.clear();
      for (final hymn in favorites) {
        await _favoritesBoxInstance.put(hymn.number, hymn.toJson());
      }
    }

    if (data['recently_played'] != null) {
      final recentlyPlayed = (data['recently_played'] as List).map((json) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        final Map<String, dynamic> hymnJson = Map<String, dynamic>.from(json);
        return Hymn.fromJson(hymnJson);
      }).toList();

      final jsonList = recentlyPlayed.map((h) => h.toJson()).toList();
      await _recentlyPlayedBoxInstance.put('recently_played', jsonList);
    }

    if (data['settings'] != null) {
      final settings = data['settings'] as Map<String, dynamic>;
      await _settingsBoxInstance.clear();
      for (final entry in settings.entries) {
        await _settingsBoxInstance.put(entry.key, entry.value);
      }
    }
  }

  void dispose() {
    _favoritesBoxInstance.close();
    _settingsBoxInstance.close();
    _recentlyPlayedBoxInstance.close();
  }
}
