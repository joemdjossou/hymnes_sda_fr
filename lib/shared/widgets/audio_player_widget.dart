import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

import '../../features/audio/bloc/audio_bloc.dart';
import '../constants/app_colors.dart';
import 'custom_toast.dart';
import 'shimmer_loading.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String hymnNumber;
  final String hymnTitle;
  final String? sopranoFile;
  final String? altoFile;
  final String? tenorFile;
  final String? bassFile;
  final String? countertenorFile;
  final String? baritoneFile;

  const AudioPlayerWidget({
    super.key,
    required this.hymnNumber,
    required this.hymnTitle,
    this.sopranoFile,
    this.altoFile,
    this.tenorFile,
    this.bassFile,
    this.countertenorFile,
    this.baritoneFile,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  void _showComingSoonToast(String voiceName) {
    ToastService.showInfo(
      context,
      title: voiceName,
      message: _l10n.comingSoon,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioBloc, AudioState>(
      listener: (context, state) {
        // Handle state changes if needed
      },
      child: BlocBuilder<AudioBloc, AudioState>(
        buildWhen: (previous, current) {
          // Smart rebuild: only rebuild when relevant state changes
          if (previous.runtimeType != current.runtimeType) return true;

          if (previous is AudioLoaded && current is AudioLoaded) {
            // Only rebuild if current hymn is affected or relevant properties changed
            final isCurrentHymn =
                current.currentHymnNumber == widget.hymnNumber;
            final wasCurrentHymn =
                previous.currentHymnNumber == widget.hymnNumber;

            if (isCurrentHymn || wasCurrentHymn) {
              return previous.currentHymnNumber != current.currentHymnNumber ||
                  previous.currentVoiceType != current.currentVoiceType ||
                  previous.isPlaying != current.isPlaying ||
                  previous.isLoading != current.isLoading ||
                  previous.isRetrying != current.isRetrying ||
                  previous.lastError != current.lastError ||
                  previous.position != current.position ||
                  previous.duration != current.duration;
            }
          }

          return false;
        },
        builder: (context, state) {
          String? currentHymnNumber;
          bool isPlaying = false;
          bool isPaused = false;
          Duration position = Duration.zero;
          Duration duration = Duration.zero;
          String? lastError;
          bool isLoading = false;
          bool isRetrying = false;
          int retryCount = 0;
          VoiceType currentVoiceType = VoiceType.allVoices;
          bool isLooping = false;

          if (state is AudioLoaded) {
            currentHymnNumber = state.currentHymnNumber;
            isPlaying = state.isPlaying;
            isPaused = state.isPaused;
            position = state.position;
            duration = state.duration;
            lastError = state.lastError;
            isLoading = state.isLoading;
            isRetrying = state.isRetrying;
            retryCount = state.retryCount;
            currentVoiceType = state.currentVoiceType;
            isLooping = state.isLooping;

            // Debug logging
            // debugPrint(
            //     'AudioPlayerWidget - State: ${state.playerState}, isPlaying: $isPlaying, isLoading: $isLoading, currentHymn: $currentHymnNumber, thisHymn: $hymnNumber');
          }

          final isCurrentHymn = currentHymnNumber == widget.hymnNumber;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentHymn
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentHymn
                    ? AppColors.primary
                    : AppColors.border(context),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loading indicator
                if (isCurrentHymn && isLoading) ...[
                  _buildLoadingIndicator(),
                  const Gap(16),
                ],

                // Retrying indicator
                if (isCurrentHymn && isRetrying) ...[
                  _buildRetryingIndicator(retryCount),
                  const Gap(16),
                ],

                // Error message display
                if (isCurrentHymn && lastError != null) ...[
                  _buildErrorDisplay(lastError),
                  const Gap(16),
                ],

                // Progress bar
                if (isCurrentHymn && duration > Duration.zero) ...[
                  _buildProgressBar(position, duration),
                  const Gap(16),
                ],

                // Control buttons
                _buildControlButtons(isCurrentHymn, isPlaying, isPaused,
                    isLoading, currentVoiceType),

                // Play/Pause/Stop controls
                if (isCurrentHymn) ...[
                  const Gap(16),
                  _buildPlaybackControls(isPlaying, isLooping),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          ShimmerLoading(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              _l10n.loadingAudio,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryingIndicator(int retryCount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          ShimmerLoading(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              _l10n.retrying(retryCount),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(String lastError) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 20,
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  lastError,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                onPressed: _handleClearError,
                icon: Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (lastError.contains(_l10n.unableToPlayAudio)) ...[
            const Gap(8),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleRetry,
                icon: Icon(Icons.refresh, size: 16),
                label: Text(_l10n.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(Duration position, Duration duration) {
    // Ensure position never exceeds duration to prevent slider bounds error
    final safePosition = position.inMilliseconds.toDouble();
    final maxDuration = duration.inMilliseconds.toDouble();
    final clampedPosition = safePosition.clamp(0.0, maxDuration);

    return Column(
      children: [
        Slider(
          value: clampedPosition,
          max: maxDuration > 0 ? maxDuration : 1.0, // Ensure max is never 0
          onChanged: _handleSeek,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border(context),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(position),
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
            Text(
              _formatDuration(duration),
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(bool isCurrentHymn, bool isPlaying, bool isPaused,
      bool isLoading, VoiceType currentVoiceType) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Play/All Voices button
          _buildControlButton(
            icon: isLoading ? Icons.hourglass_empty : Icons.play_arrow,
            label: _l10n.allVoices,
            onTap: isLoading ? null : _handlePlayAllVoices,
            isActive: isCurrentHymn &&
                currentVoiceType == VoiceType.allVoices &&
                (isPlaying || isPaused),
            isLoading: isLoading,
          ),

          Gap(MediaQuery.sizeOf(context).width * 0.03),
          // Soprano button
          _buildControlButton(
            icon: Icons.mic,
            label: _l10n.soprano,
            onTap: widget.sopranoFile != null && widget.sopranoFile!.isNotEmpty
                ? () => _handlePlayVoice(VoiceType.soprano, widget.sopranoFile!)
                : () => _showComingSoonToast(_l10n.soprano),
            isActive: isCurrentHymn &&
                currentVoiceType == VoiceType.soprano &&
                (isPlaying || isPaused),
          ),
          Gap(MediaQuery.sizeOf(context).width * 0.03),
          // Alto button
          _buildControlButton(
            icon: Icons.music_note,
            label: _l10n.alto,
            onTap: widget.altoFile != null && widget.altoFile!.isNotEmpty
                ? () => _handlePlayVoice(VoiceType.alto, widget.altoFile!)
                : () => _showComingSoonToast(_l10n.alto),
            isActive: isCurrentHymn &&
                currentVoiceType == VoiceType.alto &&
                (isPlaying || isPaused),
          ),

          // Countertenor button (only show if file exists)
          if (widget.countertenorFile != null &&
              widget.countertenorFile!.isNotEmpty) ...[
            Gap(MediaQuery.sizeOf(context).width * 0.03),
            _buildControlButton(
              icon: Icons.speaker,
              label: _l10n.countertenor,
              onTap: () => _handlePlayVoice(
                  VoiceType.countertenor, widget.countertenorFile!),
              isActive: isCurrentHymn &&
                  currentVoiceType == VoiceType.countertenor &&
                  (isPlaying || isPaused),
            ),
          ],
          // Baritone button (only show if file exists)
          if (widget.baritoneFile != null &&
              widget.baritoneFile!.isNotEmpty) ...[
            Gap(MediaQuery.sizeOf(context).width * 0.03),
            _buildControlButton(
              icon: Icons.voice_chat,
              label: _l10n.baritone,
              onTap: () =>
                  _handlePlayVoice(VoiceType.baritone, widget.baritoneFile!),
              isActive: isCurrentHymn &&
                  currentVoiceType == VoiceType.baritone &&
                  (isPlaying || isPaused),
            ),
          ],

          Gap(MediaQuery.sizeOf(context).width * 0.03),
          // Tenor button
          _buildControlButton(
            icon: Icons.piano,
            label: _l10n.tenor,
            onTap: widget.tenorFile != null && widget.tenorFile!.isNotEmpty
                ? () => _handlePlayVoice(VoiceType.tenor, widget.tenorFile!)
                : () => _showComingSoonToast(_l10n.tenor),
            isActive: isCurrentHymn &&
                currentVoiceType == VoiceType.tenor &&
                (isPlaying || isPaused),
          ),
          Gap(MediaQuery.sizeOf(context).width * 0.03),
          // Bass button
          _buildControlButton(
            icon: Icons.headphones,
            label: _l10n.bass,
            onTap: widget.bassFile != null && widget.bassFile!.isNotEmpty
                ? () => _handlePlayVoice(VoiceType.bass, widget.bassFile!)
                : () => _showComingSoonToast(_l10n.bass),
            isActive: isCurrentHymn &&
                currentVoiceType == VoiceType.bass &&
                (isPlaying || isPaused),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(bool isPlaying, bool isLooping) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: isPlaying ? _handlePause : _handleResume,
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const Gap(16),
        IconButton(
          onPressed: _handleStop,
          icon: Icon(
            Icons.stop,
            color: AppColors.error,
            size: 32,
          ),
        ),
        const Gap(16),
        IconButton(
          onPressed: _handleToggleLoop,
          icon: Icon(
            Icons.repeat_rounded,
            color: isLooping
                ? AppColors.primary
                : AppColors.textSecondary(context),
            size: 32,
          ),
        ),
      ],
    );
  }

  // Event handlers with proper error handling
  void _handlePlayAllVoices() {
    if (!mounted) return;
    try {
      context.read<AudioBloc>().add(PlayAudio(
            widget.hymnNumber,
            voiceType: VoiceType.allVoices,
          ));
    } catch (e) {
      debugPrint('Error accessing AudioBloc for play all voices: $e');
    }
  }

  void _handlePlayVoice(VoiceType voiceType, String voiceFile) {
    if (!mounted) return;
    try {
      context.read<AudioBloc>().add(PlayAudio(widget.hymnNumber,
          voiceType: voiceType, voiceFile: voiceFile));
    } catch (e) {
      debugPrint('Error accessing AudioBloc for voice play: $e');
    }
  }

  void _handlePause() {
    if (!mounted) return;
    try {
      context.read<AudioBloc>().add(PauseAudio());
    } catch (e) {
      debugPrint('Error accessing AudioBloc for pause: $e');
    }
  }

  void _handleResume() {
    if (!mounted) return;
    try {
      context.read<AudioBloc>().add(ResumeAudio());
    } catch (e) {
      debugPrint('Error accessing AudioBloc for resume: $e');
    }
  }

  void _handleStop() {
    if (!mounted) return;
    try {
      context.read<AudioBloc>().add(StopAudio());
    } catch (e) {
      debugPrint('Error accessing AudioBloc for stop: $e');
    }
  }

  void _handleSeek(double value) {
    if (!mounted) return;
    try {
      context
          .read<AudioBloc>()
          .add(SeekAudio(Duration(milliseconds: value.toInt())));
    } catch (e) {
      debugPrint('Error accessing AudioBloc for seek: $e');
    }
  }

  void _handleClearError() {
    if (!mounted) return;
    try {
      context.read<AudioBloc>().add(ClearAudioError());
    } catch (e) {
      debugPrint('Error accessing AudioBloc for clear error: $e');
    }
  }

  void _handleRetry() {
    if (!mounted) return;
    try {
      context.read<AudioBloc>().add(RetryAudio());
    } catch (e) {
      debugPrint('Error accessing AudioBloc for retry: $e');
    }
  }

  void _handleToggleLoop() {
    if (!mounted) return;
    try {
      context.read<AudioBloc>().add(ToggleLoop());
    } catch (e) {
      debugPrint('Error accessing AudioBloc for toggle loop: $e');
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isActive,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primary : AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border(context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              ShimmerLoading(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              Icon(
                icon,
                color:
                    isActive ? Colors.white : AppColors.textSecondary(context),
                size: 20,
              ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                color:
                    isActive ? Colors.white : AppColors.textSecondary(context),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
