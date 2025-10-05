import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';
import 'package:hymnes_sda_fr/features/favorites/models/favorite_hymn.dart';

void main() {
  group('FavoriteHymn Model Tests', () {
    late FavoriteHymn favoriteHymn;
    late Hymn hymn;

    setUp(() {
      hymn = Hymn(
        number: '1',
        title: 'Test Hymn',
        lyrics: 'Test lyrics content',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Traditional',
        sopranoFile: 'soprano.mp3',
        altoFile: 'alto.mp3',
        tenorFile: 'tenor.mp3',
        bassFile: 'bass.mp3',
        midiFile: 'midi.mid',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );

      favoriteHymn = FavoriteHymn(
        hymn: hymn,
        dateAdded: DateTime(2023, 1, 1),
      );
    });

    test('should create favorite hymn with all properties', () {
      expect(favoriteHymn.hymn, hymn);
      expect(favoriteHymn.dateAdded, DateTime(2023, 1, 1));
    });

    test('should convert favorite hymn to JSON', () {
      final json = favoriteHymn.toJson();

      expect(json['number'], hymn.number);
      expect(json['title'], hymn.title);
      expect(json['lyrics'], hymn.lyrics);
      expect(json['author'], hymn.author);
      expect(json['composer'], hymn.composer);
      expect(json['theme'], hymn.theme);
      expect(json['subtheme'], hymn.subtheme);
      expect(json['style'], hymn.style);
      expect(json['sopranoFile'], hymn.sopranoFile);
      expect(json['altoFile'], hymn.altoFile);
      expect(json['tenorFile'], hymn.tenorFile);
      expect(json['bassFile'], hymn.bassFile);
      expect(json['midiFile'], hymn.midiFile);
      expect(json['dateAdded'], DateTime(2023, 1, 1).millisecondsSinceEpoch);
    });

    test('should create favorite hymn from JSON', () {
      final json = {
        'number': '2',
        'title': 'Another Hymn',
        'lyrics': 'Another lyrics content',
        'author': 'Another Author',
        'composer': 'Another Composer',
        'style': 'Modern',
        'sopranoFile': 'soprano2.mp3',
        'altoFile': 'alto2.mp3',
        'tenorFile': 'tenor2.mp3',
        'bassFile': 'bass2.mp3',
        'midiFile': 'midi2.mid',
        'theme': 'Another Theme',
        'subtheme': 'Another Subtheme',
        'story': 'Another story',
        'dateAdded': DateTime(2023, 2, 1).millisecondsSinceEpoch,
      };

      final createdFavoriteHymn = FavoriteHymn.fromJson(json);

      expect(createdFavoriteHymn.hymn.number, '2');
      expect(createdFavoriteHymn.hymn.title, 'Another Hymn');
      expect(createdFavoriteHymn.hymn.lyrics, 'Another lyrics content');
      expect(createdFavoriteHymn.hymn.author, 'Another Author');
      expect(createdFavoriteHymn.hymn.composer, 'Another Composer');
      expect(createdFavoriteHymn.hymn.theme, 'Another Theme');
      expect(createdFavoriteHymn.hymn.subtheme, 'Another Subtheme');
      expect(createdFavoriteHymn.hymn.style, 'Modern');
      expect(createdFavoriteHymn.hymn.sopranoFile, 'soprano2.mp3');
      expect(createdFavoriteHymn.hymn.altoFile, 'alto2.mp3');
      expect(createdFavoriteHymn.hymn.tenorFile, 'tenor2.mp3');
      expect(createdFavoriteHymn.hymn.bassFile, 'bass2.mp3');
      expect(createdFavoriteHymn.hymn.midiFile, 'midi2.mid');
      expect(createdFavoriteHymn.dateAdded, DateTime(2023, 2, 1));
    });

    test('should create favorite hymn with current date', () {
      final favoriteFromHymn = FavoriteHymn(
        hymn: hymn,
        dateAdded: DateTime.now(),
      );

      expect(favoriteFromHymn.hymn, hymn);
      expect(favoriteFromHymn.dateAdded, isA<DateTime>());
      expect(
          favoriteFromHymn.dateAdded
              .isBefore(DateTime.now().add(const Duration(seconds: 1))),
          isTrue);
    });

    test('should be equal when properties are the same', () {
      final favoriteHymn1 = FavoriteHymn(
        hymn: hymn,
        dateAdded: DateTime(2023, 1, 1),
      );

      final favoriteHymn2 = FavoriteHymn(
        hymn: hymn,
        dateAdded: DateTime(2023, 1, 1),
      );

      expect(favoriteHymn1, equals(favoriteHymn2));
    });

    test('should not be equal when dates are different', () {
      final favoriteHymn1 = FavoriteHymn(
        hymn: hymn,
        dateAdded: DateTime(2023, 1, 1),
      );

      final favoriteHymn2 = FavoriteHymn(
        hymn: hymn,
        dateAdded: DateTime(2023, 1, 2),
      );

      expect(favoriteHymn1, isNot(equals(favoriteHymn2)));
    });

    test('should not be equal when hymns are different', () {
      final hymn2 = Hymn(
        number: '2',
        title: 'Different Hymn',
        lyrics: 'Different lyrics',
        author: 'Different Author',
        composer: 'Different Composer',
        style: 'Modern',
        sopranoFile: 'different_soprano.mp3',
        altoFile: 'different_alto.mp3',
        tenorFile: 'different_tenor.mp3',
        bassFile: 'different_bass.mp3',
        midiFile: 'different_midi.mid',
        theme: 'Different Theme',
        subtheme: 'Different Subtheme',
        story: 'Different story',
      );

      final favoriteHymn1 = FavoriteHymn(
        hymn: hymn,
        dateAdded: DateTime(2023, 1, 1),
      );

      final favoriteHymn2 = FavoriteHymn(
        hymn: hymn2,
        dateAdded: DateTime(2023, 1, 1),
      );

      expect(favoriteHymn1, isNot(equals(favoriteHymn2)));
    });
  });
}
