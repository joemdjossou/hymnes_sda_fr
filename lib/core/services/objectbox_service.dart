import 'dart:io';

import 'package:path_provider/path_provider.dart';

// Import generated ObjectBox files
import '../../objectbox.g.dart';
import '../models/objectbox_entities.dart';
import 'error_logging_service.dart';

class ObjectBoxService {
  static final ObjectBoxService _instance = ObjectBoxService._internal();
  factory ObjectBoxService() => _instance;
  ObjectBoxService._internal();

  Store? _store;
  late Box<HymnEntity> _hymnBox;
  late Box<FavoriteHymnEntity> _favoriteBox;
  late Box<RecentlyPlayedEntity> _recentlyPlayedBox;
  late Box<SettingEntity> _settingBox;

  // Error logging service
  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  bool get isInitialized => _store != null;

  Future<void> initialize() async {
    try {
      if (_store != null) return;

      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String objectboxDir = '${appDir.path}/objectbox';

      // Create the store
      _store = await openStore(directory: objectboxDir);

      // Initialize boxes
      _hymnBox = _store!.box<HymnEntity>();
      _favoriteBox = _store!.box<FavoriteHymnEntity>();
      _recentlyPlayedBox = _store!.box<RecentlyPlayedEntity>();
      _settingBox = _store!.box<SettingEntity>();

      await _errorLogger.logInfo(
        'ObjectBoxService',
        'ObjectBox service initialized successfully',
        context: {
          'directory': objectboxDir,
          'boxes': ['hymns', 'favorites', 'recently_played', 'settings'],
        },
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'initialize',
        'Failed to initialize ObjectBox service',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  // Hymn Management
  Future<void> saveHymn(HymnEntity hymn) async {
    try {
      await _hymnBox.putAsync(hymn);
      await _errorLogger.logDebug(
        'ObjectBoxService',
        'Saved hymn to database',
        context: {
          'hymnNumber': hymn.number,
          'hymnTitle': hymn.title,
        },
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'saveHymn',
        'Failed to save hymn',
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

  Future<HymnEntity?> getHymnByNumber(String number) async {
    try {
      final query = _hymnBox.query(HymnEntity_.number.equals(number)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'getHymnByNumber',
        'Failed to get hymn by number',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {'hymnNumber': number},
      );
      return null;
    }
  }

  Future<List<HymnEntity>> getAllHymns() async {
    try {
      return _hymnBox.getAll();
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'getAllHymns',
        'Failed to get all hymns',
        error: e,
        stackTrace: StackTrace.current,
      );
      return [];
    }
  }

  // Favorites Management
  Future<void> addToFavorites(FavoriteHymnEntity favorite) async {
    try {
      await _favoriteBox.putAsync(favorite);
      await _errorLogger.logDebug(
        'ObjectBoxService',
        'Added hymn to favorites',
        context: {
          'hymnNumber': favorite.hymnNumber,
          'hymnTitle': favorite.title,
        },
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'addToFavorites',
        'Failed to add hymn to favorites',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {
          'hymnNumber': favorite.hymnNumber,
          'hymnTitle': favorite.title,
        },
      );
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String hymnNumber) async {
    try {
      final query = _favoriteBox
          .query(FavoriteHymnEntity_.hymnNumber.equals(hymnNumber))
          .build();
      final result = query.findFirst();
      query.close();

      if (result != null) {
        await _favoriteBox.removeAsync(result.id);
        await _errorLogger.logDebug(
          'ObjectBoxService',
          'Removed hymn from favorites',
          context: {'hymnNumber': hymnNumber},
        );
      }
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'removeFromFavorites',
        'Failed to remove hymn from favorites',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {'hymnNumber': hymnNumber},
      );
      rethrow;
    }
  }

  bool isFavorite(String hymnNumber) {
    try {
      final query = _favoriteBox
          .query(FavoriteHymnEntity_.hymnNumber.equals(hymnNumber))
          .build();
      final result = query.findFirst() != null;
      query.close();
      return result;
    } catch (e) {
      _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'isFavorite',
        'Failed to check if hymn is favorite',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {'hymnNumber': hymnNumber},
      );
      return false;
    }
  }

  Future<List<FavoriteHymnEntity>> getFavorites() async {
    try {
      final query = _favoriteBox
          .query()
          .order(FavoriteHymnEntity_.dateAdded, flags: Order.descending)
          .build();
      final result = query.find();
      query.close();
      return result;
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'getFavorites',
        'Failed to get favorites',
        error: e,
        stackTrace: StackTrace.current,
      );
      return [];
    }
  }

  // Recently Played Management
  Future<void> addToRecentlyPlayed(RecentlyPlayedEntity recentlyPlayed) async {
    try {
      // Remove existing entry if it exists
      final existingQuery = _recentlyPlayedBox
          .query(RecentlyPlayedEntity_.hymnNumber
              .equals(recentlyPlayed.hymnNumber))
          .build();
      final existing = existingQuery.findFirst();
      existingQuery.close();

      if (existing != null) {
        await _recentlyPlayedBox.removeAsync(existing.id);
      }

      // Add new entry
      await _recentlyPlayedBox.putAsync(recentlyPlayed);

      // Keep only last 20 items
      final allQuery = _recentlyPlayedBox
          .query()
          .order(RecentlyPlayedEntity_.lastPlayed, flags: Order.descending)
          .build();
      final all = allQuery.find();
      allQuery.close();

      if (all.length > 20) {
        final toRemove = all.skip(20);
        for (final item in toRemove) {
          await _recentlyPlayedBox.removeAsync(item.id);
        }
      }

      await _errorLogger.logDebug(
        'ObjectBoxService',
        'Added hymn to recently played',
        context: {
          'hymnNumber': recentlyPlayed.hymnNumber,
          'hymnTitle': recentlyPlayed.title,
        },
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'addToRecentlyPlayed',
        'Failed to add hymn to recently played',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {
          'hymnNumber': recentlyPlayed.hymnNumber,
          'hymnTitle': recentlyPlayed.title,
        },
      );
      rethrow;
    }
  }

  Future<List<RecentlyPlayedEntity>> getRecentlyPlayed() async {
    try {
      final query = _recentlyPlayedBox
          .query()
          .order(RecentlyPlayedEntity_.lastPlayed, flags: Order.descending)
          .build();
      final result = query.find();
      query.close();
      return result;
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'getRecentlyPlayed',
        'Failed to get recently played',
        error: e,
        stackTrace: StackTrace.current,
      );
      return [];
    }
  }

  // Settings Management
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      final setting = SettingEntity(key: key, value: value.toString());
      await _settingBox.putAsync(setting);
      await _errorLogger.logDebug(
        'ObjectBoxService',
        'Saved setting',
        context: {'key': key, 'value': value.toString()},
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'saveSetting',
        'Failed to save setting',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {'key': key, 'value': value.toString()},
      );
      rethrow;
    }
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      final query = _settingBox.query(SettingEntity_.key.equals(key)).build();
      final result = query.findFirst();
      query.close();

      if (result == null) return defaultValue;

      // Convert string value to requested type
      final value = result.value;
      if (T == String) return value as T;
      if (T == int) return int.tryParse(value) as T? ?? defaultValue;
      if (T == double) return double.tryParse(value) as T? ?? defaultValue;
      if (T == bool)
        return (value.toLowerCase() == 'true') as T? ?? defaultValue;

      return defaultValue;
    } catch (e) {
      _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'getSetting',
        'Failed to get setting',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {'key': key},
      );
      return defaultValue;
    }
  }

  Future<void> removeSetting(String key) async {
    try {
      final query = _settingBox.query(SettingEntity_.key.equals(key)).build();
      final result = query.findFirst();
      query.close();

      if (result != null) {
        await _settingBox.removeAsync(result.id);
        await _errorLogger.logDebug(
          'ObjectBoxService',
          'Removed setting',
          context: {'key': key},
        );
      }
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'removeSetting',
        'Failed to remove setting',
        error: e,
        stackTrace: StackTrace.current,
        queryContext: {'key': key},
      );
      rethrow;
    }
  }

  // Data Management
  Future<void> clearAllData() async {
    try {
      await _favoriteBox.removeAllAsync();
      await _settingBox.removeAllAsync();
      await _recentlyPlayedBox.removeAllAsync();
      await _errorLogger.logInfo(
        'ObjectBoxService',
        'Cleared all data',
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'clearAllData',
        'Failed to clear all data',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      final favorites = await getFavorites();
      final recentlyPlayed = await getRecentlyPlayed();
      final settings = _settingBox.getAll();

      return {
        'favorites': favorites.map((f) => f.toJson()).toList(),
        'recently_played': recentlyPlayed.map((r) => r.toJson()).toList(),
        'settings': settings.map((s) => s.toJson()).toList(),
      };
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'exportData',
        'Failed to export data',
        error: e,
        stackTrace: StackTrace.current,
      );
      return {};
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data['favorites'] != null) {
        final favorites = (data['favorites'] as List)
            .map((json) => FavoriteHymnEntity.fromJson(json))
            .toList();

        // Get existing favorites to compare
        final existingFavorites = await getFavorites();
        final existingHymnNumbers =
            existingFavorites.map((f) => f.hymnNumber).toSet();
        final newHymnNumbers = favorites.map((f) => f.hymnNumber).toSet();

        // Remove favorites that are no longer in the new data
        final toRemove = existingHymnNumbers.difference(newHymnNumbers);
        for (final hymnNumber in toRemove) {
          await removeFromFavorites(hymnNumber);
        }

        // Add or update favorites (putManyAsync will update existing entries)
        await _favoriteBox.putManyAsync(favorites);
      }

      if (data['recently_played'] != null) {
        final recentlyPlayed = (data['recently_played'] as List)
            .map((json) => RecentlyPlayedEntity.fromJson(json))
            .toList();

        // Get existing recently played to compare
        final existingRecentlyPlayed = await getRecentlyPlayed();
        final existingHymnNumbers =
            existingRecentlyPlayed.map((r) => r.hymnNumber).toSet();
        final newHymnNumbers = recentlyPlayed.map((r) => r.hymnNumber).toSet();

        // Remove recently played that are no longer in the new data
        final toRemove = existingHymnNumbers.difference(newHymnNumbers);
        for (final hymnNumber in toRemove) {
          final query = _recentlyPlayedBox
              .query(RecentlyPlayedEntity_.hymnNumber.equals(hymnNumber))
              .build();
          final result = query.findFirst();
          query.close();
          if (result != null) {
            await _recentlyPlayedBox.removeAsync(result.id);
          }
        }

        // Add or update recently played
        await _recentlyPlayedBox.putManyAsync(recentlyPlayed);
      }

      if (data['settings'] != null) {
        final settings = (data['settings'] as List)
            .map((json) => SettingEntity.fromJson(json))
            .toList();

        // Get existing settings to compare
        final existingSettings = _settingBox.getAll();
        final existingKeys = existingSettings.map((s) => s.key).toSet();
        final newKeys = settings.map((s) => s.key).toSet();

        // Remove settings that are no longer in the new data
        final toRemove = existingKeys.difference(newKeys);
        for (final key in toRemove) {
          await removeSetting(key);
        }

        // Add or update settings
        await _settingBox.putManyAsync(settings);
      }

      await _errorLogger.logInfo(
        'ObjectBoxService',
        'Imported data successfully using atomic operations',
      );
    } catch (e) {
      await _errorLogger.logDatabaseError(
        'ObjectBoxService',
        'importData',
        'Failed to import data',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  // Stream support for real-time updates
  Stream<List<FavoriteHymnEntity>> get favoritesStream {
    return _favoriteBox
        .query()
        .order(FavoriteHymnEntity_.dateAdded, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) {
      final result = query.find();
      query.close();
      return result;
    });
  }

  Stream<List<RecentlyPlayedEntity>> get recentlyPlayedStream {
    return _recentlyPlayedBox
        .query()
        .order(RecentlyPlayedEntity_.lastPlayed, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) {
      final result = query.find();
      query.close();
      return result;
    });
  }

  void dispose() {
    _store?.close();
    _store = null;
  }
}
