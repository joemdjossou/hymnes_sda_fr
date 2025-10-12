import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../core/repositories/hymn_repository.dart';
import '../../features/audio/bloc/audio_bloc.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../../features/hymns/hymn_detail_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/audio_player_widget.dart';
import '../../shared/widgets/custom_toast.dart';
import '../../shared/widgets/favorite_button_shimmer.dart';
import '../../shared/widgets/modern_sliver_app_bar.dart';
import '../widgets/hymn_details_widgets/hymn_history_bottom_sheet.dart';
import '../widgets/hymn_details_widgets/hymn_history_widget.dart';
import '../widgets/hymn_details_widgets/hymn_lyrics_widget.dart';
import '../widgets/hymn_details_widgets/hymn_music_sheet_widget.dart';

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
  AudioBloc? _audioBloc; // Store reference to AudioBloc

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get the AudioBloc reference when dependencies are available
    _audioBloc ??= context.read<AudioBloc>();
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
    final shouldShow = _scrollController.offset > 150;
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

    // Stop audio when leaving the page - use stored reference to avoid context issues
    if (_controller.hymn != null && _audioBloc != null) {
      _audioBloc!.add(StopAudio());
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

  Widget _buildFavoriteButton(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state is FavoritesLoaded
            ? state.favoriteStatus[widget.hymnId] ?? false
            : false;

        // Check if this hymn is currently being toggled
        final isToggling = state is FavoritesLoaded &&
            state.togglingHymnNumber == widget.hymnId;

        // Show shimmer when toggling
        if (isToggling) {
          return const FavoriteButtonShimmer(
            size: 48,
            iconSize: 25,
          );
        }

        return IconButton(
          icon: Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: isFavorite
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.textSecondary(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                  context
                      .read<FavoritesBloc>()
                      .add(ToggleFavorite(_controller.hymn!));
                  ToastService.showSuccess(
                    context,
                    title: l10n.favorite,
                    message:
                        context.read<FavoritesBloc>().isFavorite(widget.hymnId)
                            ? l10n.favoriteRemoved
                            : l10n.favoriteAdded,
                  );
                }
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _audioBloc != null) {
          // Stop audio when navigating back
          _audioBloc!.add(StopAudio());
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
                      ModernSliverAppBar(
                        title: l10n.hymnTitleWithNumber(
                          _controller.hymn!.number,
                          _controller.hymn!.title,
                        ),
                        subtitle: _controller.hymn!.author,
                        style: _controller.hymn!.style,
                        author: _controller.hymn!.author,
                        composer: _controller.hymn!.composer,
                        icon: Icons.music_note_rounded,
                        expandedHeight: 210,
                        showCollapsedAppBar: _showCollapsedAppBar,
                        leading: IconButton(
                          icon: Container(
                            padding:
                                const EdgeInsets.all(AppConstants.smallPadding),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary(context)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textSecondary(context),
                              size: 25,
                            ),
                          ),
                          onPressed: () => NavigationService.pop(),
                        ),
                        actions: [
                          _buildFavoriteButton(context, l10n),
                        ],
                        animationController: _heroAnimationController,
                        fadeAnimation: _heroFadeAnimation,
                        slideAnimation: _heroSlideAnimation,
                      ),

                      // Content Section
                      SliverPadding(
                        padding:
                            const EdgeInsets.all(AppConstants.largePadding),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Audio Player
                            AudioPlayerWidget(
                              hymnNumber: _controller.hymn?.number ?? '',
                              hymnTitle: _controller.hymn?.title ?? '',
                              sopranoFile: _controller.hymn?.sopranoFile,
                              altoFile: _controller.hymn?.altoFile,
                              tenorFile: _controller.hymn?.tenorFile,
                              bassFile: _controller.hymn?.bassFile,
                              countertenorFile:
                                  _controller.hymn?.countertenorFile,
                              baritoneFile: _controller.hymn?.baritoneFile,
                            ),

                            const Gap(24),

                            // Lyrics - using extracted widget
                            HymnLyricsWidget(hymn: _controller.hymn!),
                            const Gap(24),

                            // Music Sheet - new widget following SOLID principles
                            HymnMusicSheetWidget(hymn: _controller.hymn!),
                            const Gap(24),

                            // Hymn history - using extracted widget
                            HymnHistoryWidget(
                              hymn: _controller.hymn!,
                              onTap: () => HymnHistoryBottomSheet.show(
                                  context, _controller.hymn!),
                            ),
                            const Gap(100),
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
              borderRadius:
                  BorderRadius.circular(AppConstants.largeBorderRadius),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const Gap(24),
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
        padding: const EdgeInsets.all(AppConstants.extraLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(AppConstants.largeBorderRadius),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.textSecondary(context),
              ),
            ),
            const Gap(24),
            Text(
              l10n.hymnNotFound,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            Text(
              AppLocalizations.of(context)!.hymnNotFoundDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            ElevatedButton.icon(
              onPressed: () => NavigationService.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(AppLocalizations.of(context)!.back),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
