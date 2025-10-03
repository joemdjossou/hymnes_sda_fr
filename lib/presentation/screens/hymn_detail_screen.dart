import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/repositories/hymn_repository.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../../features/hymns/hymn_detail_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/midi_player_widget.dart';
import '../widgets/hymn_header_widget.dart';
import '../widgets/hymn_history_bottom_sheet.dart';
import '../widgets/hymn_history_widget.dart';
import '../widgets/hymn_lyrics_widget.dart';
import '../widgets/hymn_music_sheet_widget.dart';

class HymnDetailScreen extends StatefulWidget {
  final String hymnId;

  const HymnDetailScreen({
    super.key,
    required this.hymnId,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  late final HymnDetailController _controller;

  @override
  void initState() {
    super.initState();
    // Dependency injection following Dependency Inversion Principle
    final repository = HymnRepository();
    _controller = HymnDetailController(
      hymnRepository: repository,
      favoriteRepository: repository,
    );
    _controller.addListener(_onControllerChanged);
    _controller.loadHymn(widget.hymnId);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
    setState(() {}); // Trigger rebuild when controller state changes
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          _controller.isLoading
              ? l10n.loading
              : l10n.hymnTitleWithNumber(
                  _controller.hymn?.number ?? widget.hymnId,
                  _controller.hymn?.title ?? l10n.unknown),
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final isFavorite = state is FavoritesLoaded
                  ? state.favoriteStatus[widget.hymnId] ?? false
                  : false;

              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                color: isFavorite ? AppColors.primary : null,
                onPressed: _controller.hymn != null
                    ? () {
                        context
                            .read<FavoritesBloc>()
                            .add(ToggleFavorite(_controller.hymn!));
                      }
                    : null,
              );
            },
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _controller.hymn == null
              ? Center(
                  child: Text(
                    l10n.hymnNotFound,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 18,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hymn header - using extracted widget
                      HymnHeaderWidget(hymn: _controller.hymn!),
                      const SizedBox(height: 24),

                      // MIDI Player
                      MidiPlayerWidget(
                        hymnNumber: _controller.hymn!.number,
                        hymnTitle: _controller.hymn!.title,
                      ),
                      const SizedBox(height: 24),

                      // Lyrics - using extracted widget
                      HymnLyricsWidget(hymn: _controller.hymn!),
                      const SizedBox(height: 24),

                      // Music Sheet - new widget following SOLID principles
                      HymnMusicSheetWidget(hymn: _controller.hymn!),
                      const SizedBox(height: 24),

                      // Hymn history - using extracted widget
                      HymnHistoryWidget(
                        hymn: _controller.hymn!,
                        onTap: () => HymnHistoryBottomSheet.show(
                            context, _controller.hymn!),
                      ),
                    ],
                  ),
                ),
    );
  }
}
