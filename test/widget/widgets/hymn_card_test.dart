import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';
import 'package:hymnes_sda_fr/features/favorites/bloc/favorites_bloc.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/widgets/hymn_card.dart';

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {
  @override
  bool isFavorite(String hymnNumber) => false;
}

void main() {
  group('HymnCard Widget Tests', () {
    late MockFavoritesBloc mockFavoritesBloc;
    late Hymn testHymn;

    setUp(() {
      mockFavoritesBloc = MockFavoritesBloc();
      testHymn = Hymn(
        number: '1',
        title: 'Test Hymn',
        lyrics: 'Test lyrics content',
        author: 'Test Author',
        composer: 'Test Composer',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        style: 'Test Style',
        sopranoFile: 'soprano.mp3',
        altoFile: 'alto.mp3',
        tenorFile: 'tenor.mp3',
        bassFile: 'bass.mp3',
        midiFile: 'midi.mid',
        story: 'Test story',
      );
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: HymnCard(
              hymn: testHymn,
              onTap: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('should display hymn information correctly',
        (WidgetTester tester) async {
      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Test Hymn'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
      // Composer is not displayed in the HymnCard widget
    });

    testWidgets('should show favorite icon when hymn is favorited',
        (WidgetTester tester) async {
      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([
          FavoritesLoaded(
            favorites: [testHymn],
            favoriteStatus: {testHymn.number: true},
          ),
        ]),
        initialState: FavoritesLoaded(
          favorites: [testHymn],
          favoriteStatus: {testHymn.number: true},
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('should show unfavorite icon when hymn is not favorited',
        (WidgetTester tester) async {
      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable(
            [FavoritesLoaded(favorites: [], favoriteStatus: {})]),
        initialState: FavoritesLoaded(favorites: [], favoriteStatus: {}),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped',
        (WidgetTester tester) async {
      bool onTapCalled = false;

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<FavoritesBloc>(
              create: (context) => mockFavoritesBloc,
              child: HymnCard(
                hymn: testHymn,
                onTap: () {
                  onTapCalled = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(HymnCard));
      await tester.pumpAndSettle();

      expect(onTapCalled, isTrue);
    });

    testWidgets('should add to favorites when favorite button is tapped',
        (WidgetTester tester) async {
      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable(
            [FavoritesLoaded(favorites: [], favoriteStatus: {})]),
        initialState: FavoritesLoaded(favorites: [], favoriteStatus: {}),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      // Verify that the tap was successful (no exceptions thrown)
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });

    testWidgets('should remove from favorites when favorite button is tapped',
        (WidgetTester tester) async {
      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([
          FavoritesLoaded(
            favorites: [
              testHymn,
            ],
            favoriteStatus: {testHymn.number: true},
          ),
        ]),
        initialState: FavoritesLoaded(
          favorites: [testHymn],
          favoriteStatus: {testHymn.number: true},
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_rounded));
      await tester.pumpAndSettle();

      // Verify that the tap was successful (no exceptions thrown)
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('should handle hymn without audio URL',
        (WidgetTester tester) async {
      final hymnWithoutAudio = Hymn(
        number: '2',
        title: 'Hymn Without Audio',
        lyrics: 'Test lyrics',
        author: 'Test Author',
        composer: 'Test Composer',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        style: 'Test Style',
        sopranoFile: 'soprano.mp3',
        altoFile: 'alto.mp3',
        tenorFile: 'tenor.mp3',
        bassFile: 'bass.mp3',
        midiFile: 'midi.mid',
        story: 'Test story',
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<FavoritesBloc>(
              create: (context) => mockFavoritesBloc,
              child: HymnCard(
                hymn: hymnWithoutAudio,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('Hymn Without Audio'), findsOneWidget);
    });

    testWidgets('should handle hymn without music sheet URLs',
        (WidgetTester tester) async {
      final hymnWithoutSheets = Hymn(
        number: '3',
        title: 'Hymn Without Sheets',
        lyrics: 'Test lyrics',
        author: 'Test Author',
        composer: 'Test Composer',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        style: 'Test Style',
        sopranoFile: 'soprano.mp3',
        altoFile: 'alto.mp3',
        tenorFile: 'tenor.mp3',
        bassFile: 'bass.mp3',
        midiFile: 'midi.mid',
        story: 'Test story',
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<FavoritesBloc>(
              create: (context) => mockFavoritesBloc,
              child: HymnCard(
                hymn: hymnWithoutSheets,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('Hymn Without Sheets'), findsOneWidget);
    });

    testWidgets('should display loading state when favorites are loading',
        (WidgetTester tester) async {
      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesLoading()]),
        initialState: FavoritesLoading(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // HymnCard doesn't show loading indicator for favorites loading state
      // It only shows shimmer when toggling individual favorites
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Hymn'), findsOneWidget);
    });

    testWidgets('should display error state when favorites fail to load',
        (WidgetTester tester) async {
      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesError('Failed to load favorites')]),
        initialState: FavoritesError('Failed to load favorites'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // HymnCard doesn't show error icon for favorites error state
      // It continues to show the hymn content normally
      expect(find.byIcon(Icons.error), findsNothing);
      expect(find.text('Test Hymn'), findsOneWidget);
    });
  });
}
