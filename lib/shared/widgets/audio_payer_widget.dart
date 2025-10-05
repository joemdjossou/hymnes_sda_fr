import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

import '../../features/audio/bloc/audio_bloc.dart';
import '../constants/app_colors.dart';
import 'custom_toast.dart';

class AudioPlayerWidget extends StatelessWidget {
  final String hymnNumber;
  final String hymnTitle;

  const AudioPlayerWidget({
    super.key,
    required this.hymnNumber,
    required this.hymnTitle,
  });

  void _showComingSoonToast(BuildContext context, String voiceName) {
    final l10n = AppLocalizations.of(context)!;
    ToastService.showInfo(
      context,
      title: voiceName,
      message: l10n.comingSoon,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AudioBloc, AudioState>(
      listener: (context, state) {
        // Force rebuild on any state change
        debugPrint('AudioPlayerWidget - State changed: ${state.runtimeType}');
      },
      child: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          String? currentHymnNumber;
          bool isPlaying = false;
          Duration position = Duration.zero;
          Duration duration = Duration.zero;
          String? lastError;
          bool isLoading = false;
          bool isRetrying = false;
          int retryCount = 0;

          if (state is AudioLoaded) {
            currentHymnNumber = state.currentHymnNumber;
            isPlaying = state.isPlaying;
            position = state.position;
            duration = state.duration;
            lastError = state.lastError;
            isLoading = state.isLoading;
            isRetrying = state.isRetrying;
            retryCount = state.retryCount;

            // Debug logging
            debugPrint(
                'AudioPlayerWidget - State: ${state.playerState}, isPlaying: $isPlaying, isLoading: $isLoading, currentHymn: $currentHymnNumber, thisHymn: $hymnNumber');
          }

          final isCurrentHymn = currentHymnNumber == hymnNumber;

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
                // Header with hymn info
                Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hymn $hymnNumber',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            hymnTitle,
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Gap(16),

                // Loading indicator
                if (isCurrentHymn && isLoading) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'Loading audio...',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                ],

                // Retrying indicator
                if (isCurrentHymn && isRetrying) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'Retrying... (${retryCount}/3)',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                ],

                // Error message display
                if (isCurrentHymn && lastError != null) ...[
                  Container(
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
                              onPressed: () => context
                                  .read<AudioBloc>()
                                  .add(ClearAudioError()),
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
                        if (lastError.contains('Unable to play audio')) ...[
                          const Gap(8),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  context.read<AudioBloc>().add(RetryAudio()),
                              icon: Icon(Icons.refresh, size: 16),
                              label: Text('Retry'),
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
                  ),
                  const Gap(16),
                ],

                // Progress bar
                if (isCurrentHymn && duration > Duration.zero) ...[
                  Column(
                    children: [
                      Slider(
                        value: position.inMilliseconds.toDouble(),
                        max: duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          context.read<AudioBloc>().add(
                              SeekAudio(Duration(milliseconds: value.toInt())));
                        },
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
                  ),
                  const Gap(16),
                ],

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Play/All Voices button
                    _buildControlButton(
                      context,
                      icon:
                          isLoading ? Icons.hourglass_empty : Icons.play_arrow,
                      label: l10n.allVoices,
                      onTap: isLoading
                          ? null
                          : () => context
                              .read<AudioBloc>()
                              .add(PlayAudio(hymnNumber)),
                      isActive: isCurrentHymn && isPlaying,
                      isLoading: isLoading,
                    ),

                    // Soprano button
                    _buildControlButton(
                      context,
                      icon: Icons.mic,
                      label: l10n.soprano,
                      onTap: () => _showComingSoonToast(context, l10n.soprano),
                      isActive: false,
                    ),

                    // Alto button
                    _buildControlButton(
                      context,
                      icon: Icons.music_note,
                      label: l10n.alto,
                      onTap: () => _showComingSoonToast(context, l10n.alto),
                      isActive: false,
                    ),

                    // Tenor button
                    _buildControlButton(
                      context,
                      icon: Icons.piano,
                      label: l10n.tenor,
                      onTap: () => _showComingSoonToast(context, l10n.tenor),
                      isActive: false,
                    ),

                    // Bass button
                    _buildControlButton(
                      context,
                      icon: Icons.music_note,
                      label: l10n.bass,
                      onTap: () => _showComingSoonToast(context, l10n.bass),
                      isActive: false,
                    ),
                  ],
                ),

                // Play/Pause/Stop controls
                if (isCurrentHymn) ...[
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: isPlaying
                            ? () => context.read<AudioBloc>().add(PauseAudio())
                            : () =>
                                context.read<AudioBloc>().add(ResumeAudio()),
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const Gap(16),
                      IconButton(
                        onPressed: () =>
                            context.read<AudioBloc>().add(StopAudio()),
                        icon: Icon(
                          Icons.stop,
                          color: AppColors.error,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
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
              Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isActive ? Colors.white : AppColors.primary,
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
