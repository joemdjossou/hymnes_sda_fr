import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hymn.dart';

class HymnDataService {
  static final HymnDataService _instance = HymnDataService._internal();
  factory HymnDataService() => _instance;
  HymnDataService._internal();

  List<Hymn>? _hymnsCache;

  /// Load hymns from JSON file
  Future<List<Hymn>> getHymns() async {
    // Return cached data if available
    if (_hymnsCache != null) {
      return _hymnsCache!;
    }

    try {
      // Load JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/hymns.json');
      
      // Parse JSON to List<Map<String, dynamic>>
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Convert to List<Hymn>
      _hymnsCache = jsonList.map((json) => Hymn.fromJson(json)).toList();
      
      return _hymnsCache!;
    } catch (e) {
      print('Error loading hymns from JSON: $e');
      // Return empty list if loading fails
      return [];
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
  }

  /// Get total number of hymns
  Future<int> getHymnCount() async {
    final hymns = await getHymns();
    return hymns.length;
  }

  /// Get hymns by author
  Future<List<Hymn>> getHymnsByAuthor(String author) async {
    final hymns = await getHymns();
    return hymns.where((hymn) => 
      hymn.author.toLowerCase().contains(author.toLowerCase())
    ).toList();
  }

  /// Get hymns by composer
  Future<List<Hymn>> getHymnsByComposer(String composer) async {
    final hymns = await getHymns();
    return hymns.where((hymn) => 
      hymn.composer.toLowerCase().contains(composer.toLowerCase())
    ).toList();
  }

  /// Get hymns by style
  Future<List<Hymn>> getHymnsByStyle(String style) async {
    final hymns = await getHymns();
    return hymns.where((hymn) => 
      hymn.style.toLowerCase().contains(style.toLowerCase())
    ).toList();
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
