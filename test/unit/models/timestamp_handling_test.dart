import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';
import 'package:hymnes_sda_fr/features/favorites/models/favorite_hymn.dart';

void main() {
  group('Timestamp Handling Tests', () {
    late Hymn testHymn;

    setUp(() {
      testHymn = Hymn(
        number: '999',
        title: 'Timestamp Test Hymn',
        lyrics: 'Testing timestamp conversion',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Test Style',
        sopranoFile: 'test_soprano.mp3',
        altoFile: 'test_alto.mp3',
        tenorFile: 'test_tenor.mp3',
        bassFile: 'test_bass.mp3',
        midiFile: 'test_midi.mid',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );
    });

    test('should handle local storage format (int milliseconds)', () {
      final now = DateTime.now();
      final favorite = FavoriteHymn(
        hymn: testHymn,
        dateAdded: now,
      );

      final json = favorite.toJson();
      expect(json['dateAdded'], isA<int>());
      expect(json['dateAdded'], equals(now.millisecondsSinceEpoch));

      // Test reconstruction
      final reconstructed = FavoriteHymn.fromJson(json);
      expect(reconstructed.dateAdded.millisecondsSinceEpoch,
          equals(now.millisecondsSinceEpoch));
    });

    test('should handle Firestore Timestamp format', () {
      final timestamp = Timestamp.now();
      final json = {
        ...testHymn.toJson(),
        'dateAdded': timestamp,
      };

      final favorite = FavoriteHymn.fromJson(json);
      expect(favorite.dateAdded, isA<DateTime>());
      expect(favorite.dateAdded, equals(timestamp.toDate()));
    });

    test('should handle null dateAdded with fallback', () {
      final json = {
        ...testHymn.toJson(),
        'dateAdded': null,
      };

      final favorite = FavoriteHymn.fromJson(json);
      expect(favorite.dateAdded, isA<DateTime>());
      // Should be close to current time (within 1 second)
      final now = DateTime.now();
      final difference = favorite.dateAdded.difference(now).abs();
      expect(difference.inSeconds, lessThan(1));
    });

    test('should handle invalid dateAdded type with fallback', () {
      final json = {
        ...testHymn.toJson(),
        'dateAdded': 'invalid_date',
      };

      final favorite = FavoriteHymn.fromJson(json);
      expect(favorite.dateAdded, isA<DateTime>());
    });

    test('should maintain consistency between toJson and fromJson', () {
      final original = FavoriteHymn(
        hymn: testHymn,
        dateAdded: DateTime(2024, 1, 15, 10, 30, 45),
      );

      final json = original.toJson();
      final reconstructed = FavoriteHymn.fromJson(json);

      expect(reconstructed.hymn.number, equals(original.hymn.number));
      expect(reconstructed.hymn.title, equals(original.hymn.title));
      expect(reconstructed.dateAdded, equals(original.dateAdded));
    });

    test('should handle Firestore server timestamp placeholder', () {
      final json = {
        ...testHymn.toJson(),
        'dateAdded': FieldValue.serverTimestamp(),
      };

      // This should handle the FieldValue gracefully and use current time as fallback
      final favorite = FavoriteHymn.fromJson(json);
      expect(favorite.dateAdded, isA<DateTime>());
      // Should be close to current time (within 1 second)
      final now = DateTime.now();
      final difference = favorite.dateAdded.difference(now).abs();
      expect(difference.inSeconds, lessThan(1));
    });

    test('should create Firestore-compatible JSON', () {
      final favorite = FavoriteHymn(
        hymn: testHymn,
        dateAdded: DateTime.now(),
      );

      final firestoreJson = favorite.toFirestoreJson();
      expect(firestoreJson['dateAdded'], isA<FieldValue>());
      expect(firestoreJson['userId'], isNull);
      expect(firestoreJson['number'], equals(testHymn.number));
      expect(firestoreJson['title'], equals(testHymn.title));
    });
  });

  group('FavoriteHymn Model Tests', () {
    test('should create FavoriteHymn with required parameters', () {
      final hymn = Hymn(
        number: '1',
        title: 'Test Hymn',
        lyrics: 'Test lyrics',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Test Style',
        sopranoFile: 'test_soprano.mp3',
        altoFile: 'test_alto.mp3',
        tenorFile: 'test_tenor.mp3',
        bassFile: 'test_bass.mp3',
        midiFile: 'test_midi.mid',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );

      final dateAdded = DateTime.now();
      final favorite = FavoriteHymn(
        hymn: hymn,
        dateAdded: dateAdded,
      );

      expect(favorite.hymn, equals(hymn));
      expect(favorite.dateAdded, equals(dateAdded));
    });

    test('should support copyWith method', () {
      final testHymn = Hymn(
        number: '1',
        title: 'Test Hymn',
        lyrics: 'Test lyrics',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Test Style',
        sopranoFile: 'test_soprano.mp3',
        altoFile: 'test_alto.mp3',
        tenorFile: 'test_tenor.mp3',
        bassFile: 'test_bass.mp3',
        midiFile: 'test_midi.mid',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );

      final original = FavoriteHymn(
        hymn: testHymn,
        dateAdded: DateTime(2024, 1, 1),
      );

      final newDate = DateTime(2024, 2, 1);
      final copied = original.copyWith(dateAdded: newDate);

      expect(copied.hymn, equals(original.hymn));
      expect(copied.dateAdded, equals(newDate));
    });

    test('should implement Equatable correctly', () {
      final hymn1 = Hymn(
        number: '1',
        title: 'Test Hymn',
        lyrics: 'Test lyrics',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Test Style',
        sopranoFile: 'test_soprano.mp3',
        altoFile: 'test_alto.mp3',
        tenorFile: 'test_tenor.mp3',
        bassFile: 'test_bass.mp3',
        midiFile: 'test_midi.mid',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );

      final date = DateTime(2024, 1, 1);
      final favorite1 = FavoriteHymn(hymn: hymn1, dateAdded: date);
      final favorite2 = FavoriteHymn(hymn: hymn1, dateAdded: date);

      expect(favorite1, equals(favorite2));
      expect(favorite1.hashCode, equals(favorite2.hashCode));
    });
  });
}
