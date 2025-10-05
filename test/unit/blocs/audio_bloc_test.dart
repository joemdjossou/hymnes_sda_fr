import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/services/audio_service.dart';
import 'package:hymnes_sda_fr/features/audio/bloc/audio_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'audio_bloc_test.mocks.dart';

@GenerateMocks([AudioService])
void main() {
  group('AudioBloc Tests', () {
    late AudioBloc audioBloc;
    late MockAudioService mockAudioService;

    setUp(() {
      mockAudioService = MockAudioService();
      audioBloc = AudioBloc();
    });

    tearDown(() {
      audioBloc.close();
    });

    test('initial state should be AudioInitial', () {
      expect(audioBloc.state, equals(AudioInitial()));
    });

    group('InitializeAudio', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio service initializes successfully',
        build: () {
          when(mockAudioService.initialize()).thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.playing);
          when(mockAudioService.currentHymnNumber).thenReturn('1');
          when(mockAudioService.position).thenReturn(Duration.zero);
          when(mockAudioService.duration)
              .thenReturn(const Duration(minutes: 3));
          when(mockAudioService.isPlaying).thenReturn(true);
          when(mockAudioService.isPaused).thenReturn(false);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(0);
          return audioBloc;
        },
        act: (bloc) => bloc.add(InitializeAudio()),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.initialize()).called(1);
        },
      );

      blocTest<AudioBloc, AudioState>(
        'emits [AudioError] when audio service initialization fails',
        build: () {
          when(mockAudioService.initialize())
              .thenThrow(Exception('Initialization failed'));
          return audioBloc;
        },
        act: (bloc) => bloc.add(InitializeAudio()),
        expect: () => [
          isA<AudioError>(),
        ],
      );
    });

    group('PlayAudio', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio plays successfully',
        build: () {
          when(mockAudioService.playHymn(
            '1',
          )).thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.playing);
          when(mockAudioService.currentHymnNumber).thenReturn('1');
          when(mockAudioService.position).thenReturn(Duration.zero);
          when(mockAudioService.duration)
              .thenReturn(const Duration(minutes: 3));
          when(mockAudioService.isPlaying).thenReturn(true);
          when(mockAudioService.isPaused).thenReturn(false);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(0);
          return audioBloc;
        },
        act: (bloc) => bloc.add(PlayAudio('1')),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.playHymn('1')).called(1);
        },
      );

      blocTest<AudioBloc, AudioState>(
        'emits [AudioError] when audio play fails',
        build: () {
          when(mockAudioService.playHymn('1'))
              .thenThrow(Exception('Play failed'));
          return audioBloc;
        },
        act: (bloc) => bloc.add(PlayAudio('1')),
        expect: () => [
          isA<AudioError>(),
        ],
      );
    });

    group('PauseAudio', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio pauses successfully',
        build: () {
          when(mockAudioService.pause()).thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.paused);
          when(mockAudioService.currentHymnNumber).thenReturn('1');
          when(mockAudioService.position)
              .thenReturn(const Duration(seconds: 30));
          when(mockAudioService.duration)
              .thenReturn(const Duration(minutes: 3));
          when(mockAudioService.isPlaying).thenReturn(false);
          when(mockAudioService.isPaused).thenReturn(true);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(0);
          return audioBloc;
        },
        act: (bloc) => bloc.add(PauseAudio()),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.pause()).called(1);
        },
      );

      blocTest<AudioBloc, AudioState>(
        'emits [AudioError] when audio pause fails',
        build: () {
          when(mockAudioService.pause()).thenThrow(Exception('Pause failed'));
          return audioBloc;
        },
        act: (bloc) => bloc.add(PauseAudio()),
        expect: () => [
          isA<AudioError>(),
        ],
      );
    });

    group('ResumeAudio', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio resumes successfully',
        build: () {
          when(mockAudioService.resume()).thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.playing);
          when(mockAudioService.currentHymnNumber).thenReturn('1');
          when(mockAudioService.position)
              .thenReturn(const Duration(seconds: 30));
          when(mockAudioService.duration)
              .thenReturn(const Duration(minutes: 3));
          when(mockAudioService.isPlaying).thenReturn(true);
          when(mockAudioService.isPaused).thenReturn(false);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(0);
          return audioBloc;
        },
        act: (bloc) => bloc.add(ResumeAudio()),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.resume()).called(1);
        },
      );

      blocTest<AudioBloc, AudioState>(
        'emits [AudioError] when audio resume fails',
        build: () {
          when(mockAudioService.resume()).thenThrow(Exception('Resume failed'));
          return audioBloc;
        },
        act: (bloc) => bloc.add(ResumeAudio()),
        expect: () => [
          isA<AudioError>(),
        ],
      );
    });

    group('StopAudio', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio stops successfully',
        build: () {
          when(mockAudioService.stop()).thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.stopped);
          when(mockAudioService.currentHymnNumber).thenReturn(null);
          when(mockAudioService.position).thenReturn(Duration.zero);
          when(mockAudioService.duration).thenReturn(Duration.zero);
          when(mockAudioService.isPlaying).thenReturn(false);
          when(mockAudioService.isPaused).thenReturn(false);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(0);
          return audioBloc;
        },
        act: (bloc) => bloc.add(StopAudio()),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.stop()).called(1);
        },
      );

      blocTest<AudioBloc, AudioState>(
        'emits [AudioError] when audio stop fails',
        build: () {
          when(mockAudioService.stop()).thenThrow(Exception('Stop failed'));
          return audioBloc;
        },
        act: (bloc) => bloc.add(StopAudio()),
        expect: () => [
          isA<AudioError>(),
        ],
      );
    });

    group('SeekAudio', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio seeks successfully',
        build: () {
          when(mockAudioService.seekTo(const Duration(seconds: 60)))
              .thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.playing);
          when(mockAudioService.currentHymnNumber).thenReturn('1');
          when(mockAudioService.position)
              .thenReturn(const Duration(seconds: 60));
          when(mockAudioService.duration)
              .thenReturn(const Duration(minutes: 3));
          when(mockAudioService.isPlaying).thenReturn(true);
          when(mockAudioService.isPaused).thenReturn(false);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(0);
          return audioBloc;
        },
        act: (bloc) => bloc.add(SeekAudio(const Duration(seconds: 60))),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.seekTo(const Duration(seconds: 60)))
              .called(1);
        },
      );

      blocTest<AudioBloc, AudioState>(
        'emits [AudioError] when audio seek fails',
        build: () {
          when(mockAudioService.seekTo(const Duration(seconds: 60)))
              .thenThrow(Exception('Seek failed'));
          return audioBloc;
        },
        act: (bloc) => bloc.add(SeekAudio(const Duration(seconds: 60))),
        expect: () => [
          isA<AudioError>(),
        ],
      );
    });

    group('SetAudioVolume', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio volume is set successfully',
        build: () {
          when(mockAudioService.setVolume(0.5)).thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.playing);
          when(mockAudioService.currentHymnNumber).thenReturn('1');
          when(mockAudioService.position).thenReturn(Duration.zero);
          when(mockAudioService.duration)
              .thenReturn(const Duration(minutes: 3));
          when(mockAudioService.isPlaying).thenReturn(true);
          when(mockAudioService.isPaused).thenReturn(false);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(0);
          return audioBloc;
        },
        act: (bloc) => bloc.add(SetAudioVolume(0.5)),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.setVolume(0.5)).called(1);
        },
      );

      blocTest<AudioBloc, AudioState>(
        'emits [AudioError] when audio volume setting fails',
        build: () {
          when(mockAudioService.setVolume(0.5))
              .thenThrow(Exception('Volume setting failed'));
          return audioBloc;
        },
        act: (bloc) => bloc.add(SetAudioVolume(0.5)),
        expect: () => [
          isA<AudioError>(),
        ],
      );
    });

    group('ClearAudioError', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio error is cleared successfully',
        build: () {
          when(mockAudioService.clearError()).thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.playing);
          when(mockAudioService.currentHymnNumber).thenReturn('1');
          when(mockAudioService.position).thenReturn(Duration.zero);
          when(mockAudioService.duration)
              .thenReturn(const Duration(minutes: 3));
          when(mockAudioService.isPlaying).thenReturn(true);
          when(mockAudioService.isPaused).thenReturn(false);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(0);
          return audioBloc;
        },
        act: (bloc) => bloc.add(ClearAudioError()),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.clearError()).called(1);
        },
      );
    });

    group('RetryAudio', () {
      blocTest<AudioBloc, AudioState>(
        'emits [AudioLoaded] when audio retry succeeds',
        build: () {
          when(mockAudioService.retryPlay()).thenAnswer((_) async {});
          when(mockAudioService.state).thenReturn(AudioPlayerState.playing);
          when(mockAudioService.currentHymnNumber).thenReturn('1');
          when(mockAudioService.position).thenReturn(Duration.zero);
          when(mockAudioService.duration)
              .thenReturn(const Duration(minutes: 3));
          when(mockAudioService.isPlaying).thenReturn(true);
          when(mockAudioService.isPaused).thenReturn(false);
          when(mockAudioService.isLoading).thenReturn(false);
          when(mockAudioService.isRetrying).thenReturn(false);
          when(mockAudioService.lastError).thenReturn(null);
          when(mockAudioService.retryCount).thenReturn(1);
          return audioBloc;
        },
        act: (bloc) => bloc.add(RetryAudio()),
        expect: () => [
          isA<AudioLoaded>(),
        ],
        verify: (bloc) {
          verify(mockAudioService.retryPlay()).called(1);
        },
      );

      blocTest<AudioBloc, AudioState>(
        'emits [AudioError] when audio retry fails',
        build: () {
          when(mockAudioService.retryPlay())
              .thenThrow(Exception('Retry failed'));
          return audioBloc;
        },
        act: (bloc) => bloc.add(RetryAudio()),
        expect: () => [
          isA<AudioError>(),
        ],
      );
    });
  });
}
