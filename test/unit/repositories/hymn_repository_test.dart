import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';
import 'package:hymnes_sda_fr/core/repositories/hymn_repository.dart';

void main() {
  group('HymnRepository Tests', () {
    late HymnRepository hymnRepository;

    setUp(() {
      hymnRepository = HymnRepository();
    });

    test('should be singleton', () {
      final instance1 = HymnRepository();
      final instance2 = HymnRepository();

      expect(instance1, same(instance2));
    });

    test('should get all hymns', () async {
      final hymns = await hymnRepository.getAllHymns();

      expect(hymns, isA<List<Hymn>>());
      expect(hymns.isNotEmpty, isTrue);
    });

    test('should get hymn by number', () async {
      final hymns = await hymnRepository.getAllHymns();
      if (hymns.isNotEmpty) {
        final firstHymn = hymns.first;
        final foundHymn =
            await hymnRepository.getHymnByNumber(firstHymn.number);

        expect(foundHymn, isNotNull);
        expect(foundHymn!.number, firstHymn.number);
        expect(foundHymn.title, firstHymn.title);
      }
    });

    test('should return null for non-existent hymn number', () async {
      final foundHymn = await hymnRepository.getHymnByNumber('99999');

      expect(foundHymn, isNull);
    });

    test('should search hymns by title', () async {
      final hymns = await hymnRepository.getAllHymns();
      if (hymns.isNotEmpty) {
        final firstHymn = hymns.first;
        final searchResults = await hymnRepository.searchHymns(firstHymn.title);

        expect(searchResults, isA<List<Hymn>>());
        expect(searchResults.any((hymn) => hymn.number == firstHymn.number),
            isTrue);
      }
    });

    test('should search hymns by lyrics', () async {
      final hymns = await hymnRepository.getAllHymns();
      if (hymns.isNotEmpty) {
        final firstHymn = hymns.first;
        final lyricsWords = firstHymn.lyrics.split(' ').take(3).join(' ');
        final searchResults = await hymnRepository.searchHymns(lyricsWords);

        expect(searchResults, isA<List<Hymn>>());
        expect(searchResults.any((hymn) => hymn.number == firstHymn.number),
            isTrue);
      }
    });

    test('should search hymns by author', () async {
      final hymns = await hymnRepository.getAllHymns();
      if (hymns.isNotEmpty) {
        final firstHymn = hymns.first;
        final searchResults =
            await hymnRepository.searchHymns(firstHymn.author);

        expect(searchResults, isA<List<Hymn>>());
        expect(searchResults.any((hymn) => hymn.number == firstHymn.number),
            isTrue);
      }
    });

    test('should search hymns by composer', () async {
      final hymns = await hymnRepository.getAllHymns();
      if (hymns.isNotEmpty) {
        final firstHymn = hymns.first;
        final searchResults =
            await hymnRepository.searchHymns(firstHymn.composer);

        expect(searchResults, isA<List<Hymn>>());
        expect(searchResults.any((hymn) => hymn.number == firstHymn.number),
            isTrue);
      }
    });

    test('should search hymns by number', () async {
      final hymns = await hymnRepository.getAllHymns();
      if (hymns.isNotEmpty) {
        final firstHymn = hymns.first;
        final searchResults =
            await hymnRepository.searchHymns(firstHymn.number);

        expect(searchResults, isA<List<Hymn>>());
        expect(searchResults.any((hymn) => hymn.number == firstHymn.number),
            isTrue);
      }
    });

    test('should return all hymns for empty search query', () async {
      final allHymns = await hymnRepository.getAllHymns();
      final searchResults = await hymnRepository.searchHymns('');

      expect(searchResults.length, allHymns.length);
    });

    test('should return empty list for non-matching search query', () async {
      final searchResults =
          await hymnRepository.searchHymns('nonexistentquery12345');

      expect(searchResults, isEmpty);
    });

    test('should be case insensitive in search', () async {
      final hymns = await hymnRepository.getAllHymns();
      if (hymns.isNotEmpty) {
        final firstHymn = hymns.first;
        final lowercaseTitle = firstHymn.title.toLowerCase();
        final uppercaseTitle = firstHymn.title.toUpperCase();

        final lowercaseResults =
            await hymnRepository.searchHymns(lowercaseTitle);
        final uppercaseResults =
            await hymnRepository.searchHymns(uppercaseTitle);

        expect(lowercaseResults.length, uppercaseResults.length);
        expect(lowercaseResults.any((hymn) => hymn.number == firstHymn.number),
            isTrue);
        expect(uppercaseResults.any((hymn) => hymn.number == firstHymn.number),
            isTrue);
      }
    });

    test('should cache hymns after first load', () async {
      // Clear any existing cache
      hymnRepository = HymnRepository();

      // First call should load from data source
      final hymns1 = await hymnRepository.getAllHymns();
      expect(hymns1, isA<List<Hymn>>());

      // Second call should use cache
      final hymns2 = await hymnRepository.getAllHymns();
      expect(hymns2, isA<List<Hymn>>());
      expect(hymns1.length, hymns2.length);
    });
  });
}
