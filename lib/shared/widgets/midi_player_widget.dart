import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../features/midi/bloc/midi_bloc.dart';
import '../constants/app_colors.dart';

class MidiPlayerWidget extends StatelessWidget {
  final String hymnNumber;
  final String hymnTitle;

  const MidiPlayerWidget({
    super.key,
    required this.hymnNumber,
    required this.hymnTitle,
  });

  void _showComingSoonSnackBar(BuildContext context, String voiceName) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$voiceName - ${l10n.comingSoon}'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<MidiBloc, MidiState>(
      builder: (context, state) {
        String? currentMidiFile;
        bool isPlaying = false;
        Duration position = Duration.zero;
        Duration duration = Duration.zero;
        String? lastError;

        if (state is MidiLoaded) {
          currentMidiFile = state.currentMidiFile;
          isPlaying = state.isPlaying;
          position = state.position;
          duration = state.duration;
          lastError = state.lastError;
        }

        final isCurrentHymn = currentMidiFile == 'h$hymnNumber';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentHymn
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isCurrentHymn ? AppColors.primary : AppColors.border(context),
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
                  const SizedBox(width: 8),
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

              const SizedBox(height: 16),

              // Error message display
              if (isCurrentHymn && lastError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
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
                        onPressed: () =>
                            context.read<MidiBloc>().add(ClearMidiError()),
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
                ),
                const SizedBox(height: 16),
              ],

              // Progress bar
              if (isCurrentHymn && duration > Duration.zero) ...[
                Column(
                  children: [
                    Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        context.read<MidiBloc>().add(
                            SeekMidi(Duration(milliseconds: value.toInt())));
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
                const SizedBox(height: 16),
              ],

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Play/All Voices button
                  _buildControlButton(
                    context,
                    icon: Icons.play_arrow,
                    label: l10n.allVoices,
                    onTap: () =>
                        context.read<MidiBloc>().add(PlayMidi('h$hymnNumber')),
                    isActive: isCurrentHymn && isPlaying,
                  ),

                  // Soprano button
                  _buildControlButton(
                    context,
                    icon: Icons.mic,
                    label: l10n.soprano,
                    onTap: () => _showComingSoonSnackBar(context, l10n.soprano),
                    isActive: false,
                  ),

                  // Alto button
                  _buildControlButton(
                    context,
                    icon: Icons.music_note,
                    label: l10n.alto,
                    onTap: () => _showComingSoonSnackBar(context, l10n.alto),
                    isActive: false,
                  ),

                  // Tenor button
                  _buildControlButton(
                    context,
                    icon: Icons.piano,
                    label: l10n.tenor,
                    onTap: () => _showComingSoonSnackBar(context, l10n.tenor),
                    isActive: false,
                  ),

                  // Bass button
                  _buildControlButton(
                    context,
                    icon: Icons.music_note,
                    label: l10n.bass,
                    onTap: () => _showComingSoonSnackBar(context, l10n.bass),
                    isActive: false,
                  ),
                ],
              ),

              // Play/Pause/Stop controls
              if (isCurrentHymn) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: isPlaying
                          ? () => context.read<MidiBloc>().add(PauseMidi())
                          : () => context.read<MidiBloc>().add(ResumeMidi()),
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => context.read<MidiBloc>().add(StopMidi()),
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
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
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
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.textSecondary(context),
              size: 20,
            ),
            const SizedBox(height: 4),
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
