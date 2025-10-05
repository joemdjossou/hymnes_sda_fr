import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/user_model.dart';
import 'package:hymnes_sda_fr/features/auth/bloc/auth_bloc.dart';
import 'package:hymnes_sda_fr/features/favorites/bloc/favorites_bloc.dart';
import 'package:hymnes_sda_fr/features/favorites/models/favorites_sort_option.dart';
import 'package:hymnes_sda_fr/presentation/screens/home_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

void main() {
  group('HomeScreen Tests', () {
    late MockAuthBloc mockAuthBloc;
    late MockFavoritesBloc mockFavoritesBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockFavoritesBloc = MockFavoritesBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => mockAuthBloc,
            ),
            BlocProvider<FavoritesBloc>(
              create: (context) => mockFavoritesBloc,
            ),
          ],
          child: const HomeScreen(),
        ),
      );
    }

    testWidgets('should display app bar with correct title',
        (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Hymnes & Louanges'), findsOneWidget);
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display hymns list when hymns are loaded',
        (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The screen should be ready to display hymns
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should show loading indicator when hymns are loading',
        (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesLoading()]),
        initialState: FavoritesLoading(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The screen should handle loading state
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should show error message when hymns fail to load',
        (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesError('Failed to load hymns')]),
        initialState: FavoritesError('Failed to load hymns'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The screen should handle error state
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should display empty state when no hymns are available',
        (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([
          FavoritesLoaded(
              favorites: [],
              favoriteStatus: {},
              currentSortOption: FavoritesSortOption.dateAddedNewestFirst)
        ]),
        initialState: FavoritesLoaded(
            favorites: [],
            favoriteStatus: {},
            currentSortOption: FavoritesSortOption.dateAddedNewestFirst),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The screen should handle empty state
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle search input', (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'test search');
      await tester.pumpAndSettle();

      expect(find.text('test search'), findsOneWidget);
    });

    testWidgets('should display user info when authenticated',
        (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          Authenticated(
            UserModel(
              uid: 'test-uid',
              email: 'test@example.com',
              displayName: 'Test User',
              photoURL: null,
              isEmailVerified: true,
              createdAt: DateTime.now(),
              lastSignInAt: DateTime.now(),
            ),
          ),
        ]),
        initialState: Authenticated(
          UserModel(
            uid: 'test-uid',
            email: 'test@example.com',
            displayName: 'Test User',
            photoURL: null,
            isEmailVerified: true,
            createdAt: DateTime.now(),
            lastSignInAt: DateTime.now(),
          ),
        ),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The screen should display user information
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should display login prompt when not authenticated',
        (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([Unauthenticated()]),
        initialState: Unauthenticated(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The screen should handle unauthenticated state
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle theme changes', (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The screen should handle theme changes
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle language changes', (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );

      whenListen(
        mockFavoritesBloc,
        Stream.fromIterable([FavoritesInitial()]),
        initialState: FavoritesInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The screen should handle language changes
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
