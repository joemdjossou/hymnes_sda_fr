import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/audio/bloc/audio_bloc.dart';

enum AudioPlayerState {
  stopped,
  loading,
  playing,
  paused,
  error,
  retrying,
}

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayerState _state = AudioPlayerState.stopped;
  String? _currentHymnNumber;
  VoiceType _currentVoiceType = VoiceType.allVoices;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isInitialized = false;
  String? _lastError;
  bool _isPlaying = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Audio player for online MP3 playback
  AudioPlayer? _audioPlayer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // Getters
  AudioPlayerState get state => _state;
  String? get currentHymnNumber => _currentHymnNumber;
  VoiceType get currentVoiceType => _currentVoiceType;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _state == AudioPlayerState.paused;
  bool get isLoading => _state == AudioPlayerState.loading;
  bool get isRetrying => _state == AudioPlayerState.retrying;
  String? get lastError => _lastError;
  int get retryCount => _retryCount;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();

      // Listen to position changes
      _positionSubscription = _audioPlayer!.positionStream.listen((position) {
        _position = position;
        notifyListeners();
      });

      // Listen to duration changes
      _durationSubscription = _audioPlayer!.durationStream.listen((duration) {
        if (duration != null) {
          _duration = duration;
          notifyListeners();
        }
      });

      // Listen to player state changes
      _playerStateSubscription =
          _audioPlayer!.playerStateStream.listen((state) {
        debugPrint(
            'Player state changed: ${state.processingState}, playing: ${state.playing}');

        switch (state.processingState) {
          case ProcessingState.loading:
          case ProcessingState.buffering:
            // Only set loading if we're not already playing
            if (_state != AudioPlayerState.playing) {
              _state = AudioPlayerState.loading;
            }
            _isPlaying = false;
            break;
          case ProcessingState.ready:
            if (state.playing) {
              _state = AudioPlayerState.playing;
              _isPlaying = true;
            } else {
              _state = AudioPlayerState.paused;
              _isPlaying = false;
            }
            break;
          case ProcessingState.completed:
            _state = AudioPlayerState.stopped;
            _isPlaying = false;
            _position = Duration.zero;
            break;
          case ProcessingState.idle:
            _state = AudioPlayerState.stopped;
            _isPlaying = false;
            break;
        }
        debugPrint('Updated state: $_state, isPlaying: $_isPlaying');
        notifyListeners();
      });

      _isInitialized = true;
      debugPrint('Audio Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Audio Service: $e');
      _state = AudioPlayerState.error;
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> playHymn(String hymnNumber,
      {VoiceType voiceType = VoiceType.allVoices, String? voiceFile}) async {
    if (!_isInitialized) await initialize();

    try {
      _state = AudioPlayerState.loading;
      _currentHymnNumber = hymnNumber;
      _currentVoiceType = voiceType;
      _lastError = null;
      _retryCount = 0;
      notifyListeners();

      await _loadAndPlayHymn(hymnNumber,
          voiceType: voiceType, voiceFile: voiceFile);

      // Add a timeout to ensure loading state is cleared
      Future.delayed(Duration(seconds: 2), () {
        if (_state == AudioPlayerState.loading && _isPlaying) {
          debugPrint('Timeout: Clearing loading state, audio is playing');
          _state = AudioPlayerState.playing;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _handlePlayError(e);
    }
  }

  Future<void> _loadAndPlayHymn(String hymnNumber,
      {VoiceType voiceType = VoiceType.allVoices, String? voiceFile}) async {
    String mp3Url;

    if (voiceType == VoiceType.allVoices) {
      // Use the original URL for all voices
      final paddedNumber = hymnNumber.padLeft(3, '0');
      mp3Url =
          'https://troisanges.org/Musique/HymnesEtLouanges/MP3/H$paddedNumber.mp3';
    } else {
      // Use the new voice-specific URL
      if (voiceFile == null || voiceFile.isEmpty) {
        throw Exception('Voice file is required for individual voice playback');
      }
      mp3Url = 'https://joemdjossou.github.io/hymnes_voices/output$voiceFile';
    }

    debugPrint('Attempting to play audio: $mp3Url (Voice: $voiceType)');

    try {
      // Load the MP3 file
      await _audioPlayer!.setUrl(mp3Url);

      // Start playing
      await _audioPlayer!.play();

      // Wait a bit for the player to actually start
      await Future.delayed(Duration(milliseconds: 500));

      // Check if the player is actually playing and update state accordingly
      if (_audioPlayer!.playing) {
        _state = AudioPlayerState.playing;
        _isPlaying = true;
        debugPrint('Audio confirmed playing, updating state');
      } else {
        _state = AudioPlayerState.paused;
        _isPlaying = false;
        debugPrint('Audio not playing yet, setting to paused');
      }
      notifyListeners();

      debugPrint('Playing audio: $mp3Url');
    } catch (e) {
      debugPrint('Error in _loadAndPlayHymn: $e');
      _state = AudioPlayerState.error;
      _lastError = 'Failed to play audio: $e';
      notifyListeners();
      rethrow;
    }
  }

  void _handlePlayError(dynamic error) {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      _state = AudioPlayerState.retrying;
      _lastError =
          'Connection failed. Retrying... (${_retryCount}/$_maxRetries)';
      notifyListeners();

      // Retry after a delay
      Future.delayed(Duration(seconds: 2 * _retryCount), () {
        if (_state == AudioPlayerState.retrying) {
          _loadAndPlayHymn(_currentHymnNumber!, voiceType: _currentVoiceType)
              .catchError(_handlePlayError);
        }
      });
    } else {
      _state = AudioPlayerState.error;
      _lastError =
          'Unable to play audio. Please check your internet connection and try again.';
      notifyListeners();
    }
  }

  Future<void> retryPlay() async {
    if (_currentHymnNumber != null) {
      _retryCount = 0;
      await playHymn(_currentHymnNumber!, voiceType: _currentVoiceType);
    }
  }

  bool isPlayingHymn(String hymnNumber) {
    return _currentHymnNumber == hymnNumber && _isPlaying;
  }

  Future<void> pause() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.pause();
        _state = AudioPlayerState.paused;
        _isPlaying = false;
        notifyListeners();
        debugPrint('Audio playback paused');
      }
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.play();
        _state = AudioPlayerState.playing;
        _isPlaying = true;
        notifyListeners();
        debugPrint('Audio playback resumed');
      }
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        _state = AudioPlayerState.stopped;
        _isPlaying = false;
        _position = Duration.zero;
        _currentHymnNumber = null;
        _currentVoiceType = VoiceType.allVoices;
        _lastError = null;
        notifyListeners();
        debugPrint('Audio playback stopped');
      }
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.seek(position);
        debugPrint('Audio playback seeked to: ${position.inSeconds} seconds');
      }
    } catch (e) {
      debugPrint('Error seeking audio: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.setVolume(volume.clamp(0.0, 1.0));
        debugPrint('Audio volume set to: ${(volume * 100).toInt()}%');
      }
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  Future<void> stopIfPlaying(String hymnNumber) async {
    if (_currentHymnNumber == hymnNumber && _isPlaying) {
      await stop();
    }
  }

  Future<void> disposeAsync() async {
    try {
      await _audioPlayer?.stop();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _playerStateSubscription?.cancel();
      await _audioPlayer?.dispose();
      _audioPlayer = null;
      _isInitialized = false;
      _state = AudioPlayerState.stopped;
      _currentHymnNumber = null;
      _currentVoiceType = VoiceType.allVoices;
      _position = Duration.zero;
      _duration = Duration.zero;
      _isPlaying = false;
      _lastError = null;
      _retryCount = 0;
    } catch (e) {
      debugPrint('Error disposing AudioService: $e');
    }
  }

  @override
  void dispose() {
    try {
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _playerStateSubscription?.cancel();
      _audioPlayer?.dispose();
      _audioPlayer = null;
      _isInitialized = false;
      _state = AudioPlayerState.stopped;
      _currentHymnNumber = null;
      _currentVoiceType = VoiceType.allVoices;
      _position = Duration.zero;
      _duration = Duration.zero;
      _isPlaying = false;
      _lastError = null;
      _retryCount = 0;
    } catch (e) {
      debugPrint('Error disposing AudioService: $e');
    }
    super.dispose();
  }
}
