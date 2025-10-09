import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/favorites/models/favorite_hymn.dart';
import '../models/hymn.dart';
import '../models/objectbox_entities.dart';
import 'error_logging_service.dart';
import 'objectbox_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ObjectBox service
  final ObjectBoxService _objectBoxService = ObjectBoxService();

  // Error logging service
  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  Future<void> initialize() async {
    try {
      await _objectBoxService.initialize();

      await _errorLogger.logInfo(
        'StorageService',
        'Storage service initialized successfully with ObjectBox',
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
      final hymnEntity = HymnEntity.fromJson(hymn.toJson());
      final favoriteEntity =
          FavoriteHymnEntity.fromHymnEntity(hymnEntity, DateTime.now());
      await _objectBoxService.addToFavorites(favoriteEntity);

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
    await _objectBoxService.removeFromFavorites(hymnNumber);
  }

  bool isFavorite(String hymnNumber) {
    return _objectBoxService.isFavorite(hymnNumber);
  }

  Future<List<FavoriteHymn>> getFavorites() async {
    try {
      final favoriteEntities = await _objectBoxService.getFavorites();
      return favoriteEntities.map((entity) {
        final hymn = Hymn(
          number: entity.hymnNumber,
          title: entity.title,
          lyrics: entity.lyrics,
          author: entity.author,
          composer: entity.composer,
          style: entity.style,
          sopranoFile: entity.sopranoFile,
          altoFile: entity.altoFile,
          tenorFile: entity.tenorFile,
          bassFile: entity.bassFile,
          countertenorFile: entity.countertenorFile,
          baritoneFile: entity.baritoneFile,
          midiFile: entity.midiFile,
          theme: entity.theme,
          subtheme: entity.subtheme,
          story: entity.story,
        );
        return FavoriteHymn(hymn: hymn, dateAdded: entity.dateAdded);
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
    try {
      final hymnEntity = HymnEntity.fromJson(hymn.toJson());
      final recentlyPlayedEntity =
          RecentlyPlayedEntity.fromHymnEntity(hymnEntity, DateTime.now());
      await _objectBoxService.addToRecentlyPlayed(recentlyPlayedEntity);
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'StorageService',
        'addToRecentlyPlayed',
        'Failed to add hymn to recently played',
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

  Future<List<Hymn>> getRecentlyPlayed() async {
    try {
      final recentlyPlayedEntities =
          await _objectBoxService.getRecentlyPlayed();
      return recentlyPlayedEntities.map((entity) {
        return Hymn(
          number: entity.hymnNumber,
          title: entity.title,
          lyrics: entity.lyrics,
          author: entity.author,
          composer: entity.composer,
          style: entity.style,
          sopranoFile: entity.sopranoFile,
          altoFile: entity.altoFile,
          tenorFile: entity.tenorFile,
          bassFile: entity.bassFile,
          countertenorFile: entity.countertenorFile,
          baritoneFile: entity.baritoneFile,
          midiFile: entity.midiFile,
          theme: entity.theme,
          subtheme: entity.subtheme,
          story: entity.story,
        );
      }).toList();
    } catch (e) {
      Logger().d('Error loading recently played: $e');
      // Return empty list if there's an error
      return [];
    }
  }

  // Settings Management
  Future<void> saveSetting(String key, dynamic value) async {
    await _objectBoxService.saveSetting(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _objectBoxService.getSetting<T>(key, defaultValue: defaultValue);
  }

  Future<void> removeSetting(String key) async {
    await _objectBoxService.removeSetting(key);
  }

  // Legacy SharedPreferences support
  Future<void> migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Migrate favorites
    final favoritesList = prefs.getStringList('favorites') ?? [];
    for (final hymnNumber in favoritesList) {
      // This would need to be implemented based on your hymn data structure
      // For now, we'll just store the hymn number
      await _objectBoxService.saveSetting('legacy_favorite_$hymnNumber', true);
    }

    // Clear old data
    await prefs.clear();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _objectBoxService.clearAllData();
  }

  // Export data
  Future<Map<String, dynamic>> exportData() async {
    return await _objectBoxService.exportData();
  }

  // Import data
  Future<void> importData(Map<String, dynamic> data) async {
    await _objectBoxService.importData(data);
  }

  void dispose() {
    _objectBoxService.dispose();
  }
}
