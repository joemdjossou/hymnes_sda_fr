import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../models/hymn.dart';
import '../models/hymns_version_metadata.dart';
import 'hymns_storage_service.dart';
import 'posthog_service.dart';

class HymnDataService {
  static final HymnDataService _instance = HymnDataService._internal();
  factory HymnDataService() => _instance;
  HymnDataService._internal();

  final HymnsStorageService _storage = HymnsStorageService();
  final Logger _logger = Logger();

  List<Hymn>? _hymnsCache;
  HymnsSource? _currentSource;
  bool _versionTracked = false;

  /// Load hymns from best available source (current → previous → assets)
  Future<List<Hymn>> getHymns() async {
    // Return cached data if available
    if (_hymnsCache != null) {
      return _hymnsCache!;
    }

    try {
      // Initialize storage service if not already initialized
      if (!_storage.currentFile.existsSync()) {
        await _storage.initialize();
      }

      // Load from best available source
      final result = await _storage.loadHymns();

      if (!result.success || result.hymns.isEmpty) {
        _logger.e('Failed to load hymns: ${result.error}');
        return [];
      }

      // Cache the source for debugging
      _currentSource = result.source;
      _logger.i('Loaded ${result.hymns.length} hymns from ${result.source}');

      // Convert to List<Hymn>
      _hymnsCache = result.hymns.map((json) => Hymn.fromJson(json)).toList();

      // Track version usage once per app session
      await _trackHymnsVersion(result.source);

      return _hymnsCache!;
    } catch (e, stackTrace) {
      _logger.e('Error loading hymns: $e', error: e, stackTrace: stackTrace);

      // Ultimate fallback: try to load directly from assets
      try {
        final String jsonString =
            await rootBundle.loadString('assets/data/hymns.json');
        final List<dynamic> jsonList = json.decode(jsonString);
        _hymnsCache = jsonList.map((json) => Hymn.fromJson(json)).toList();
        _currentSource = HymnsSource.assets;
        _logger.i('Loaded ${_hymnsCache!.length} hymns from assets (fallback)');
        return _hymnsCache!;
      } catch (fallbackError) {
        _logger.e('Even fallback to assets failed: $fallbackError');
        return [];
      }
    }
  }

  /// Get a specific hymn by number
  Future<Hymn?> getHymnByNumber(String number) async {
    final hymns = await getHymns();
    try {
      return hymns.firstWhere((hymn) => hymn.number == number);
    } catch (e) {
      return null;
    }
  }

  /// Search hymns by query
  Future<List<Hymn>> searchHymns(String query) async {
    if (query.isEmpty) {
      return await getHymns();
    }

    final hymns = await getHymns();
    final lowercaseQuery = query.toLowerCase();

    return hymns.where((hymn) {
      return hymn.title.toLowerCase().contains(lowercaseQuery) ||
          hymn.lyrics.toLowerCase().contains(lowercaseQuery) ||
          hymn.author.toLowerCase().contains(lowercaseQuery) ||
          hymn.composer.toLowerCase().contains(lowercaseQuery) ||
          hymn.number.contains(lowercaseQuery);
    }).toList();
  }

  /// Clear cache (useful for testing or when data needs to be refreshed)
  void clearCache() {
    _hymnsCache = null;
    _currentSource = null;
  }

  /// Get current hymns source (for debugging)
  HymnsSource? getCurrentSource() {
    return _currentSource;
  }

  /// Force reload hymns (clears cache and reloads)
  Future<List<Hymn>> forceReload() async {
    clearCache();
    return await getHymns();
  }

  Future<void> _trackHymnsVersion(HymnsSource source) async {
    if (_versionTracked) return;

    try {
      final metadata = await HymnsMetadataStorage.load();
      final version = metadata?.currentVersion ?? _storage.bundledVersion;

      await PostHogService().trackEvent(
        eventName: 'hymns_version_loaded',
        properties: {
          'version': version,
          'source': source.name,
          'has_metadata': metadata != null,
        },
      );

      _versionTracked = true;
    } catch (e) {
      _logger.w('Failed to track hymns version: $e');
    }
  }

  /// Get total number of hymns
  Future<int> getHymnCount() async {
    final hymns = await getHymns();
    return hymns.length;
  }

  /// Get hymns by author
  Future<List<Hymn>> getHymnsByAuthor(String author) async {
    final hymns = await getHymns();
    return hymns
        .where(
            (hymn) => hymn.author.toLowerCase().contains(author.toLowerCase()))
        .toList();
  }

  /// Get hymns by composer
  Future<List<Hymn>> getHymnsByComposer(String composer) async {
    final hymns = await getHymns();
    return hymns
        .where((hymn) =>
            hymn.composer.toLowerCase().contains(composer.toLowerCase()))
        .toList();
  }

  /// Get hymns by style
  Future<List<Hymn>> getHymnsByStyle(String style) async {
    final hymns = await getHymns();
    return hymns
        .where((hymn) => hymn.style.toLowerCase().contains(style.toLowerCase()))
        .toList();
  }

  /// Get all unique authors
  Future<List<String>> getAllAuthors() async {
    final hymns = await getHymns();
    final authors = hymns.map((hymn) => hymn.author).toSet().toList();
    authors.sort();
    return authors;
  }

  /// Get all unique composers
  Future<List<String>> getAllComposers() async {
    final hymns = await getHymns();
    final composers = hymns.map((hymn) => hymn.composer).toSet().toList();
    composers.sort();
    return composers;
  }

  /// Get all unique styles
  Future<List<String>> getAllStyles() async {
    final hymns = await getHymns();
    final styles = hymns.map((hymn) => hymn.style).toSet().toList();
    styles.sort();
    return styles;
  }
}
