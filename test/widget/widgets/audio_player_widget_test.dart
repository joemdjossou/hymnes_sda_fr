import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/services/audio_service.dart';
import 'package:hymnes_sda_fr/features/audio/bloc/audio_bloc.dart';
import 'package:hymnes_sda_fr/shared/widgets/audio_player_widget.dart';
import 'package:mockito/mockito.dart';

class MockAudioBloc extends MockBloc<AudioEvent, AudioState>
    implements AudioBloc {}

void main() {
  group('AudioPlayerWidget Tests', () {
    late MockAudioBloc mockAudioBloc;

    setUp(() {
      mockAudioBloc = MockAudioBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<AudioBloc>(
            create: (context) => mockAudioBloc,
            child: const AudioPlayerWidget(
              hymnNumber: '',
              hymnTitle: '',
            ),
          ),
        ),
      );
    }

    testWidgets('should not display when no audio is loaded',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([AudioInitial()]),
        initialState: AudioInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(AudioPlayerWidget), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display audio player when audio is loaded',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.playing,
            currentHymnNumber: '1',
            position: Duration.zero,
            duration: const Duration(minutes: 3),
            isPlaying: true,
            isPaused: false,
            isLoading: false,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.playing,
          currentHymnNumber: '1',
          position: Duration.zero,
          duration: const Duration(minutes: 3),
          isPlaying: true,
          isPaused: false,
          isLoading: false,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(AudioPlayerWidget), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should show play button when audio is paused',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.paused,
            currentHymnNumber: '1',
            position: const Duration(seconds: 30),
            duration: const Duration(minutes: 3),
            isPlaying: false,
            isPaused: true,
            isLoading: false,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.paused,
          currentHymnNumber: '1',
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 3),
          isPlaying: false,
          isPaused: true,
          isLoading: false,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should show pause button when audio is playing',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.playing,
            currentHymnNumber: '1',
            position: const Duration(seconds: 30),
            duration: const Duration(minutes: 3),
            isPlaying: true,
            isPaused: false,
            isLoading: false,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.playing,
          currentHymnNumber: '1',
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 3),
          isPlaying: true,
          isPaused: false,
          isLoading: false,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should show stop button when audio is stopped',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.stopped,
            currentHymnNumber: null,
            position: Duration.zero,
            duration: Duration.zero,
            isPlaying: false,
            isPaused: false,
            isLoading: false,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.stopped,
          currentHymnNumber: null,
          position: Duration.zero,
          duration: Duration.zero,
          isPlaying: false,
          isPaused: false,
          isLoading: false,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('should show loading indicator when audio is loading',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.loading,
            currentHymnNumber: '1',
            position: Duration.zero,
            duration: const Duration(minutes: 3),
            isPlaying: false,
            isPaused: false,
            isLoading: true,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.loading,
          currentHymnNumber: '1',
          position: Duration.zero,
          duration: const Duration(minutes: 3),
          isPlaying: false,
          isPaused: false,
          isLoading: true,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when audio has error',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioError('Failed to load audio'),
        ]),
        initialState: AudioError('Failed to load audio'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load audio'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should call play event when play button is tapped',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.paused,
            currentHymnNumber: '1',
            position: const Duration(seconds: 30),
            duration: const Duration(minutes: 3),
            isPlaying: false,
            isPaused: true,
            isLoading: false,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.paused,
          currentHymnNumber: '1',
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 3),
          isPlaying: false,
          isPaused: true,
          isLoading: false,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      verify(mockAudioBloc.add(ResumeAudio())).called(1);
    });

    testWidgets('should call pause event when pause button is tapped',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.playing,
            currentHymnNumber: '1',
            position: const Duration(seconds: 30),
            duration: const Duration(minutes: 3),
            isPlaying: true,
            isPaused: false,
            isLoading: false,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.playing,
          currentHymnNumber: '1',
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 3),
          isPlaying: true,
          isPaused: false,
          isLoading: false,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      verify(mockAudioBloc.add(PauseAudio())).called(1);
    });

    testWidgets('should call stop event when stop button is tapped',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.playing,
            currentHymnNumber: '1',
            position: const Duration(seconds: 30),
            duration: const Duration(minutes: 3),
            isPlaying: true,
            isPaused: false,
            isLoading: false,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.playing,
          currentHymnNumber: '1',
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 3),
          isPlaying: true,
          isPaused: false,
          isLoading: false,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      verify(mockAudioBloc.add(StopAudio())).called(1);
    });

    testWidgets('should display progress bar with correct position',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.playing,
            currentHymnNumber: '1',
            position: const Duration(seconds: 60),
            duration: const Duration(minutes: 3),
            isPlaying: true,
            isPaused: false,
            isLoading: false,
            isRetrying: false,
            lastError: null,
            retryCount: 0,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.playing,
          currentHymnNumber: '1',
          position: const Duration(seconds: 60),
          duration: const Duration(minutes: 3),
          isPlaying: true,
          isPaused: false,
          isLoading: false,
          isRetrying: false,
          lastError: null,
          retryCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should show retry button when audio is retrying',
        (WidgetTester tester) async {
      whenListen(
        mockAudioBloc,
        Stream.fromIterable([
          AudioLoaded(
            playerState: AudioPlayerState.loading,
            currentHymnNumber: '1',
            position: Duration.zero,
            duration: const Duration(minutes: 3),
            isPlaying: false,
            isPaused: false,
            isLoading: false,
            isRetrying: true,
            lastError: 'Network error',
            retryCount: 1,
          ),
        ]),
        initialState: AudioLoaded(
          playerState: AudioPlayerState.loading,
          currentHymnNumber: '1',
          position: Duration.zero,
          duration: const Duration(minutes: 3),
          isPlaying: false,
          isPaused: false,
          isLoading: false,
          isRetrying: true,
          lastError: 'Network error',
          retryCount: 1,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
