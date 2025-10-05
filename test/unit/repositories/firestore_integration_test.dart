import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';
import 'package:hymnes_sda_fr/core/repositories/firestore_favorites_repository.dart';
import 'package:hymnes_sda_fr/core/repositories/hybrid_favorites_repository.dart';
import 'package:hymnes_sda_fr/core/services/storage_service.dart';
import 'package:hymnes_sda_fr/features/favorites/models/favorite_hymn.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'firestore_integration_test.mocks.dart';

@GenerateMocks([StorageService, FirestoreFavoritesRepository])
void main() {
  group('Firestore Integration Tests', () {
    late HybridFavoritesRepository repository;
    late MockStorageService mockLocalStorage;
    late MockFirestoreFavoritesRepository mockFirestoreRepository;

    setUp(() {
      mockLocalStorage = MockStorageService();
      mockFirestoreRepository = MockFirestoreFavoritesRepository();
      repository = HybridFavoritesRepository();
    });

    test('should initialize successfully', () async {
      when(mockLocalStorage.initialize()).thenAnswer((_) async {});

      expect(() => repository.initialize(), returnsNormally);
    });

    test('should get favorites from local storage when offline', () async {
      final testHymns = [
        FavoriteHymn(
          hymn: Hymn(
            number: '1',
            title: 'Test Hymn 1',
            lyrics: 'Test lyrics 1',
            author: 'Test Author 1',
            composer: 'Test Composer 1',
            style: 'Test Style',
            sopranoFile: 'test_soprano.mp3',
            altoFile: 'test_alto.mp3',
            tenorFile: 'test_tenor.mp3',
            bassFile: 'test_bass.mp3',
            midiFile: 'test_midi.mid',
            theme: 'Test Theme',
            subtheme: 'Test Subtheme',
            story: 'Test story',
          ),
          dateAdded: DateTime.now(),
        ),
      ];

      when(mockLocalStorage.getFavorites()).thenAnswer((_) async => testHymns);
      when(mockFirestoreRepository.isAuthenticated).thenReturn(false);

      await repository.initialize();
      repository.setOnlineStatus(false);
      final result = await repository.getFavorites();

      expect(result, equals(testHymns));
      verify(mockLocalStorage.getFavorites()).called(1);
    });

    test(
        'should add to favorites locally and to Firestore when online and authenticated',
        () async {
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

      when(mockLocalStorage.addToFavorites(any)).thenAnswer((_) async {});
      when(mockFirestoreRepository.addToFavorites(any))
          .thenAnswer((_) async {});
      when(mockFirestoreRepository.isAuthenticated).thenReturn(true);

      await repository.initialize();
      repository.setOnlineStatus(true);
      await repository.addToFavorites(testHymn);

      verify(mockLocalStorage.addToFavorites(testHymn)).called(1);
      verify(mockFirestoreRepository.addToFavorites(testHymn)).called(1);
    });

    test(
        'should remove from favorites locally and from Firestore when online and authenticated',
        () async {
      const hymnNumber = '1';

      when(mockLocalStorage.removeFromFavorites(any)).thenAnswer((_) async {});
      when(mockFirestoreRepository.removeFromFavorites(any))
          .thenAnswer((_) async {});
      when(mockFirestoreRepository.isAuthenticated).thenReturn(true);

      await repository.initialize();
      repository.setOnlineStatus(true);
      await repository.removeFromFavorites(hymnNumber);

      verify(mockLocalStorage.removeFromFavorites(hymnNumber)).called(1);
      verify(mockFirestoreRepository.removeFromFavorites(hymnNumber)).called(1);
    });

    test('should return sync status correctly', () async {
      when(mockLocalStorage.getFavorites()).thenAnswer((_) async => []);
      when(mockFirestoreRepository.getFavorites()).thenAnswer((_) async => []);
      when(mockFirestoreRepository.isAuthenticated).thenReturn(true);

      await repository.initialize();
      repository.setOnlineStatus(true);
      final syncStatus = await repository.getSyncStatus();

      expect(syncStatus['isOnline'], isTrue);
      expect(syncStatus['isAuthenticated'], isTrue);
      expect(syncStatus['localCount'], isA<int>());
      expect(syncStatus['firestoreCount'], isA<int>());
    });

    test('should handle offline mode gracefully', () async {
      final testHymns = [
        FavoriteHymn(
          hymn: Hymn(
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
          ),
          dateAdded: DateTime.now(),
        ),
      ];

      when(mockLocalStorage.getFavorites()).thenAnswer((_) async => testHymns);
      when(mockFirestoreRepository.isAuthenticated).thenReturn(false);

      await repository.initialize();
      repository.setOnlineStatus(false);
      final result = await repository.getFavorites();

      expect(result, equals(testHymns));
      verifyNever(mockFirestoreRepository.getFavorites());
    });

    test('should handle Firestore errors gracefully', () async {
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

      when(mockLocalStorage.addToFavorites(any)).thenAnswer((_) async {});
      when(mockFirestoreRepository.addToFavorites(any))
          .thenThrow(Exception('Firestore error'));
      when(mockFirestoreRepository.isAuthenticated).thenReturn(true);

      await repository.initialize();
      repository.setOnlineStatus(true);

      // Should not throw, should handle error gracefully
      expect(() => repository.addToFavorites(testHymn), returnsNormally);
      verify(mockLocalStorage.addToFavorites(testHymn)).called(1);
    });
  });

  group('Firestore Repository Tests', () {
    late FirestoreFavoritesRepository repository;

    setUp(() {
      repository = FirestoreFavoritesRepository();
    });

    test('should return empty list when not authenticated', () async {
      final favorites = await repository.getFavorites();
      expect(favorites, isEmpty);
    });

    test('should return 0 count when not authenticated', () async {
      final count = await repository.getFavoritesCount();
      expect(count, equals(0));
    });

    test('should handle async favorite check when not authenticated', () async {
      final isFavorite = await repository.isFavoriteAsync('1');
      expect(isFavorite, isFalse);
    });

    test('should throw exception when trying to add without authentication',
        () async {
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

      expect(() => repository.addToFavorites(testHymn), throwsException);
    });
  });
}
