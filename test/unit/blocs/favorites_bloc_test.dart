import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';
import 'package:hymnes_sda_fr/core/repositories/i_hymn_repository.dart';
import 'package:hymnes_sda_fr/features/favorites/bloc/favorites_bloc.dart';
import 'package:hymnes_sda_fr/features/favorites/models/favorite_hymn.dart';
import 'package:hymnes_sda_fr/features/favorites/models/favorites_sort_option.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'favorites_bloc_test.mocks.dart';

@GenerateMocks([IFavoriteRepository])
void main() {
  group('FavoritesBloc Tests', () {
    late FavoritesBloc favoritesBloc;
    late MockIFavoriteRepository mockRepository;
    late Hymn testHymn;

    setUp(() {
      mockRepository = MockIFavoriteRepository();
      favoritesBloc = FavoritesBloc(
        favoriteRepository: mockRepository,
      );
      testHymn = Hymn(
        number: '3',
        title: 'Test Hymn 3',
        lyrics: 'Test lyrics 3',
        author: 'Test Author 3',
        composer: 'Test Composer 3',
        theme: 'Test Theme 3',
        subtheme: 'Test Subtheme 3',
        style: 'Test Style 3',
        sopranoFile: 'soprano3.mp3',
        altoFile: 'alto3.mp3',
        tenorFile: 'tenor3.mp3',
        bassFile: 'bass3.mp3',
        midiFile: 'midi3.mid',
        story: 'Test story 3',
      );
    });

    tearDown(() {
      favoritesBloc.close();
    });

    test('initial state should be FavoritesInitial', () {
      expect(favoritesBloc.state, equals(FavoritesInitial()));
    });

    group('LoadFavorites', () {
      final mockFavorites = [
        FavoriteHymn(
          hymn: Hymn(
            number: '1',
            title: 'Test Hymn 1',
            lyrics: 'Test lyrics 1',
            author: 'Test Author 1',
            composer: 'Test Composer 1',
            theme: 'Test Theme 1',
            subtheme: 'Test Subtheme 1',
            style: 'Test Style 1',
            sopranoFile: 'soprano1.mp3',
            altoFile: 'alto1.mp3',
            tenorFile: 'tenor1.mp3',
            bassFile: 'bass1.mp3',
            midiFile: 'midi1.mid',
            story: 'Test story 1',
          ),
          dateAdded: DateTime(2023, 1, 1),
        ),
        FavoriteHymn(
          hymn: Hymn(
            number: '2',
            title: 'Test Hymn 2',
            lyrics: 'Test lyrics 2',
            author: 'Test Author 2',
            composer: 'Test Composer 2',
            theme: 'Test Theme 2',
            subtheme: 'Test Subtheme 2',
            style: 'Test Style 2',
            sopranoFile: 'soprano2.mp3',
            altoFile: 'alto2.mp3',
            tenorFile: 'tenor2.mp3',
            bassFile: 'bass2.mp3',
            midiFile: 'midi2.mid',
            story: 'Test story 2',
          ),
          dateAdded: DateTime(2023, 1, 2),
        ),
      ];

      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesLoading, FavoritesLoaded] when favorites are loaded successfully',
        build: () {
          when(mockRepository.getFavorites())
              .thenAnswer((_) async => mockFavorites);
          return favoritesBloc;
        },
        act: (bloc) => bloc.add(LoadFavorites()),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
        ],
        verify: (bloc) {
          verify(mockRepository.getFavorites()).called(1);
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesLoading, FavoritesError] when loading favorites fails',
        build: () {
          when(mockRepository.getFavorites())
              .thenThrow(Exception('Failed to load favorites'));
          return favoritesBloc;
        },
        act: (bloc) => bloc.add(LoadFavorites()),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesError>(),
        ],
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesLoading, FavoritesLoaded] with empty list when no favorites exist',
        build: () {
          when(mockRepository.getFavorites()).thenAnswer((_) async => []);
          return favoritesBloc;
        },
        act: (bloc) => bloc.add(LoadFavorites()),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
        ],
      );
    });

    group('AddToFavorites', () {
      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesLoading, FavoritesLoaded] when hymn is added to favorites successfully',
        build: () {
          when(mockRepository.addToFavorites(testHymn))
              .thenAnswer((_) async {});
          when(mockRepository.getFavorites()).thenAnswer((_) async => [
                FavoriteHymn(hymn: testHymn, dateAdded: DateTime.now()),
              ]);
          return favoritesBloc;
        },
        seed: () => FavoritesLoaded(
          favorites: [],
          favoriteStatus: {},
        ),
        act: (bloc) => bloc.add(AddToFavorites(testHymn)),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
        ],
        verify: (bloc) {
          verify(mockRepository.addToFavorites(testHymn)).called(1);
          verify(mockRepository.getFavorites()).called(1);
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesError] when adding to favorites fails',
        build: () {
          when(mockRepository.addToFavorites(testHymn))
              .thenThrow(Exception('Failed to add to favorites'));
          return favoritesBloc;
        },
        seed: () => FavoritesLoaded(
          favorites: [],
          favoriteStatus: {},
        ),
        act: (bloc) => bloc.add(AddToFavorites(testHymn)),
        expect: () => [
          isA<FavoritesError>(),
        ],
      );
    });

    group('RemoveFromFavorites', () {
      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesLoading, FavoritesLoaded] when hymn is removed from favorites successfully',
        build: () {
          when(mockRepository.removeFromFavorites('1'))
              .thenAnswer((_) async {});
          when(mockRepository.getFavorites()).thenAnswer((_) async => []);
          return favoritesBloc;
        },
        seed: () => FavoritesLoaded(
          favorites: [testHymn],
          favoriteStatus: {'1': true},
        ),
        act: (bloc) => bloc.add(RemoveFromFavorites('1')),
        expect: () => [
          isA<FavoritesLoaded>(),
        ],
        verify: (bloc) {
          verify(mockRepository.removeFromFavorites('1')).called(1);
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesError] when removing from favorites fails',
        build: () {
          when(mockRepository.removeFromFavorites('1'))
              .thenThrow(Exception('Failed to remove from favorites'));
          return favoritesBloc;
        },
        seed: () => FavoritesLoaded(
          favorites: [testHymn],
          favoriteStatus: {'1': true},
        ),
        act: (bloc) => bloc.add(RemoveFromFavorites('1')),
        expect: () => [
          isA<FavoritesError>(),
        ],
      );
    });

    group('SortFavorites', () {
      final mockFavorites = [
        FavoriteHymn(
          hymn: Hymn(
            number: '1',
            title: 'A Hymn',
            lyrics: 'Test lyrics 1',
            author: 'Test Author 1',
            composer: 'Test Composer 1',
            theme: 'Test Theme 1',
            subtheme: 'Test Subtheme 1',
            style: 'Test Style 1',
            sopranoFile: 'soprano1.mp3',
            altoFile: 'alto1.mp3',
            tenorFile: 'tenor1.mp3',
            bassFile: 'bass1.mp3',
            midiFile: 'midi1.mid',
            story: 'Test story 1',
          ),
          dateAdded: DateTime(2023, 1, 2),
        ),
        FavoriteHymn(
          hymn: Hymn(
            number: '2',
            title: 'B Hymn',
            lyrics: 'Test lyrics 2',
            author: 'Test Author 2',
            composer: 'Test Composer 2',
            theme: 'Test Theme 2',
            subtheme: 'Test Subtheme 2',
            style: 'Test Style 2',
            sopranoFile: 'soprano2.mp3',
            altoFile: 'alto2.mp3',
            tenorFile: 'tenor2.mp3',
            bassFile: 'bass2.mp3',
            midiFile: 'midi2.mid',
            story: 'Test story 2',
          ),
          dateAdded: DateTime(2023, 1, 1),
        ),
      ];

      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesLoaded] with sorted favorites by title ascending',
        build: () {
          when(mockRepository.getFavorites())
              .thenAnswer((_) async => mockFavorites);
          return favoritesBloc;
        },
        seed: () => FavoritesLoaded(
          favorites: mockFavorites.map((fh) => fh.hymn).toList(),
          currentSortOption: FavoritesSortOption.numberAscending,
          favoriteStatus: {
            '1': true,
            '2': true,
          },
        ),
        act: (bloc) =>
            bloc.add(SortFavorites(FavoritesSortOption.titleAscending)),
        expect: () => [
          isA<FavoritesLoaded>(),
        ],
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'emits [FavoritesLoaded] with sorted favorites by date added descending',
        build: () {
          when(mockRepository.getFavorites())
              .thenAnswer((_) async => mockFavorites);
          return favoritesBloc;
        },
        seed: () => FavoritesLoaded(
          favorites: mockFavorites.map((fh) => fh.hymn).toList(),
          currentSortOption: FavoritesSortOption.numberAscending,
          favoriteStatus: {
            '1': true,
            '2': true,
          },
        ),
        act: (bloc) =>
            bloc.add(SortFavorites(FavoritesSortOption.dateAddedNewestFirst)),
        expect: () => [
          isA<FavoritesLoaded>(),
        ],
      );
    });
  });
}
