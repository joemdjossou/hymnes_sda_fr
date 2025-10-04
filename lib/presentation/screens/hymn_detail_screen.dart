import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/repositories/hymn_repository.dart';
import '../../features/audio/bloc/audio_bloc.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../../features/hymns/hymn_detail_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/audio_player_widget.dart';
import '../../shared/widgets/custom_toast.dart';
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

class _HymnDetailScreenState extends State<HymnDetailScreen>
    with TickerProviderStateMixin {
  late final HymnDetailController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _showCollapsedAppBar = false;

  late AnimationController _heroAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);

    // Dependency injection following Dependency Inversion Principle
    final repository = HymnRepository();
    _controller = HymnDetailController(
      hymnRepository: repository,
      favoriteRepository: repository,
    );
    _controller.addListener(_onControllerChanged);
    _controller.loadHymn(widget.hymnId);
  }

  void _initializeAnimations() {
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.easeOut,
    ));

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.easeOut,
    ));

    _heroAnimationController.forward();
  }

  void _onScroll() {
    // Show collapsed app bar when scrolled past the hero section (around 100px)
    final shouldShow = _scrollController.offset > 100;
    if (shouldShow != _showCollapsedAppBar) {
      setState(() {
        _showCollapsedAppBar = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _scrollController.dispose();
    _heroAnimationController.dispose();

    // Stop audio when leaving the page
    if (_controller.hymn != null) {
      context.read<AudioBloc>().add(StopAudio());
    }

    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.error != null && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ToastService.showError(
        context,
        title: l10n.error,
        message: _controller.error!,
      );
    }
    setState(() {}); // Trigger rebuild when controller state changes
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Stop audio when navigating back
          context.read<AudioBloc>().add(StopAudio());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: _controller.isLoading
            ? _buildLoadingState(l10n)
            : _controller.hymn == null
                ? _buildErrorState(l10n)
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Modern App Bar
                      SliverAppBar(
                        expandedHeight: 160,
                        floating: false,
                        pinned: true,
                        backgroundColor: AppColors.surface(context),
                        surfaceTintColor: AppColors.surface(context),
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary(context),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        title: _showCollapsedAppBar
                            ? Text(
                                l10n.hymnTitleWithNumber(
                                  _controller.hymn!.number,
                                  _controller.hymn!.title,
                                ),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                        actions: [
                          BlocBuilder<FavoritesBloc, FavoritesState>(
                            builder: (context, state) {
                              final isFavorite = state is FavoritesLoaded
                                  ? state.favoriteStatus[widget.hymnId] ?? false
                                  : false;

                              return IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? AppColors.primary
                                            .withValues(alpha: 0.1)
                                        : AppColors.textSecondary(context)
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFavorite
                                        ? AppColors.primary
                                        : AppColors.textSecondary(context),
                                    size: 25,
                                  ),
                                ),
                                onPressed: _controller.hymn != null
                                    ? () {
                                        context.read<FavoritesBloc>().add(
                                            ToggleFavorite(_controller.hymn!));
                                        ToastService.showSuccess(
                                          context,
                                          title: l10n.favorite,
                                          message: context
                                                  .read<FavoritesBloc>()
                                                  .isFavorite(widget.hymnId)
                                              ? l10n.favoriteRemoved
                                              : l10n.favoriteAdded,
                                        );
                                      }
                                    : null,
                              );
                            },
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: AnimatedBuilder(
                            animation: _heroAnimationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _heroFadeAnimation,
                                child: SlideTransition(
                                  position: _heroSlideAnimation,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary
                                              .withValues(alpha: 0.1),
                                          AppColors.secondary
                                              .withValues(alpha: 0.05),
                                          AppColors.surface(context),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Hymn Title
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    gradient: AppColors
                                                        .primaryGradient(
                                                            context),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.primary
                                                            .withValues(
                                                                alpha: 0.3),
                                                        blurRadius: 12,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.music_note_rounded,
                                                    color: Colors.white,
                                                    size: 28,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        l10n.hymnTitleWithNumber(
                                                          _controller
                                                              .hymn!.number,
                                                          _controller
                                                              .hymn!.title,
                                                        ),
                                                        style: theme.textTheme
                                                            .headlineMedium
                                                            ?.copyWith(
                                                          color: AppColors
                                                              .textPrimary(
                                                                  context),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _controller
                                                            .hymn!.author,
                                                        style: theme.textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                          color: AppColors
                                                              .textSecondary(
                                                                  context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Content Section
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Hymn header - using extracted widget
                            HymnHeaderWidget(hymn: _controller.hymn!),
                            const SizedBox(height: 24),

                            // Audio Player
                            AudioPlayerWidget(
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
                            const SizedBox(height: 100), // Bottom padding
                          ]),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.loading,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.hymnNotFound,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Le cantique demandé n\'a pas pu être trouvé',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text('Retour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
