import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/presentation/widgets/hymn_details_widgets/hymn_navigation_bar.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../core/repositories/hymn_repository.dart';
import '../../core/services/posthog_service.dart';
import '../../core/utils/hymn_navigation_helper.dart';
import '../../core/utils/scroll_behavior_manager.dart';
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
import '../widgets/hymn_details_widgets/hymn_search_bottom_sheet.dart';

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
  bool _showBottomNavBar = true;
  AudioBloc? _audioBloc; // Store reference to AudioBloc

  late final ScrollBehaviorManager _scrollBehaviorManager;
  late final HymnNavigationHelper _hymnNavigationHelper;
  final PostHogService _posthog = PostHogService();

  late AnimationController _heroAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Dependency injection following Dependency Inversion Principle
    final repository = HymnRepository();
    _controller = HymnDetailController(
      hymnRepository: repository,
      favoriteRepository: repository,
    );
    _controller.addListener(_onControllerChanged);
    _controller.loadHymn(widget.hymnId);

    // Initialize scroll behavior manager
    _scrollBehaviorManager = ScrollBehaviorManager(
      onCollapsedAppBarChanged: (shouldShow) {
        if (!mounted) return;
        if (shouldShow != _showCollapsedAppBar) {
          setState(() {
            _showCollapsedAppBar = shouldShow;
          });
        }
      },
      onBottomNavBarVisibilityChanged: (shouldShow) {
        if (!mounted) return;
        if (shouldShow != _showBottomNavBar) {
          setState(() {
            _showBottomNavBar = shouldShow;
          });
        }
      },
    );

    // Initialize hymn navigation helper
    _hymnNavigationHelper = HymnNavigationHelper(repository);

    _scrollController.addListener(_onScroll);
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
    if (!_scrollController.hasClients) return;
    _scrollBehaviorManager.handleScroll(_scrollController.offset);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _heroAnimationController.dispose();
    _scrollBehaviorManager.dispose();

    // Stop audio when leaving the page - use stored reference to avoid context issues
    if (_controller.hymn != null && _audioBloc != null) {
      _audioBloc!.add(StopAudio());
    }

    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (_controller.error != null) {
      final l10n = AppLocalizations.of(context)!;
      ToastService.showError(
        context,
        title: l10n.error,
        message: _controller.error!,
      );
    }
    setState(() {}); // Trigger rebuild when controller state changes
  }

  /// Get the previous hymn number
  Future<String?> _getPreviousHymnNumber() async {
    return await _hymnNavigationHelper.getPreviousHymnNumber(widget.hymnId);
  }

  /// Get the next hymn number
  Future<String?> _getNextHymnNumber() async {
    return await _hymnNavigationHelper.getNextHymnNumber(widget.hymnId);
  }

  /// Handle horizontal swipe gesture
  void _handleHorizontalSwipe(DragEndDetails details) {
    // Only handle swipes if the scroll view is at the top (not scrolled)
    // This prevents conflicts with vertical scrolling
    if (_scrollController.hasClients && _scrollController.offset > 50) {
      return; // Don't handle swipe if user is scrolling vertically
    }

    final velocity = details.primaryVelocity ?? 0;
    const swipeThreshold = 300.0; // Minimum velocity to trigger navigation

    // Check if horizontal velocity is significant enough
    if (velocity.abs() < swipeThreshold) {
      return; // Swipe not strong enough
    }

    if (velocity > 0) {
      // Swipe right - go to previous hymn
      _navigateToPreviousHymn();
    } else {
      // Swipe left - go to next hymn
      _navigateToNextHymn();
    }
  }

  /// Navigate to previous hymn
  Future<void> _navigateToPreviousHymn() async {
    final previousHymnNumber = await _getPreviousHymnNumber();
    if (previousHymnNumber != null && mounted) {
      // Stop audio before navigating
      if (_audioBloc != null) {
        _audioBloc!.add(StopAudio());
      }
      // Use pushReplacement so back button returns to the original screen (home/search/etc)
      NavigationService.pushReplacement('/hymn/$previousHymnNumber');
    }
  }

  /// Navigate to next hymn
  Future<void> _navigateToNextHymn() async {
    final nextHymnNumber = await _getNextHymnNumber();
    if (nextHymnNumber != null && mounted) {
      // Stop audio before navigating
      if (_audioBloc != null) {
        _audioBloc!.add(StopAudio());
      }
      // Use pushReplacement so back button returns to the original screen (home/search/etc)
      NavigationService.pushReplacement('/hymn/$nextHymnNumber');
    }
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: AppColors.textSecondary(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary(context),
          size: 25,
        ),
      ),
      onPressed: () {
        // Track search button click
        _posthog.trackSearchEvent(
          eventType: 'button_clicked',
          searchType: 'hymn_detail',
          additionalProperties: {
            'screen': 'hymn_detail_screen',
            'current_hymn_number': _controller.hymn?.number ?? '',
            'current_hymn_title': _controller.hymn?.title ?? '',
          },
        );
        HymnSearchBottomSheet.show(context);
      },
    );
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
        bottomNavigationBar: _controller.hymn != null && _showBottomNavBar
            ? AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                offset: _showBottomNavBar ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showBottomNavBar ? 1.0 : 0.0,
                  child: HymnNavigationBar(
                    currentHymnId: _controller.hymn!.number,
                    onHymnTap: (hymnNumber) async {
                      // Determine if it's previous or next hymn
                      final currentHymnNum =
                          int.tryParse(_controller.hymn!.number) ?? 0;
                      final targetHymnNum = int.tryParse(hymnNumber) ?? 0;
                      final isPrevious = targetHymnNum < currentHymnNum;
                      final buttonType = isPrevious ? 'previous' : 'next';

                      // Track navigation button click
                      await _posthog.trackHymnEvent(
                        eventType: 'navigation_button_clicked',
                        hymnNumber: hymnNumber,
                        hymnTitle: _controller.hymn?.title,
                        additionalProperties: {
                          'button_type': buttonType,
                          'current_hymn_number': _controller.hymn!.number,
                          'target_hymn_number': hymnNumber,
                          'screen': 'hymn_detail_screen',
                        },
                      );

                      // Stop audio before navigating
                      if (_audioBloc != null) {
                        _audioBloc!.add(StopAudio());
                      }
                      // Use pushReplacement to maintain navigation history
                      NavigationService.pushReplacement('/hymn/$hymnNumber');
                    },
                  ),
                ),
              )
            : null,
        body: GestureDetector(
          onHorizontalDragEnd: _handleHorizontalSwipe,
          behavior: HitTestBehavior.translucent,
          child: _controller.isLoading
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
                              padding: const EdgeInsets.all(
                                  AppConstants.smallPadding),
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
                            onPressed: () => NavigationService.back(),
                          ),
                          actions: [
                            _buildSearchButton(context),
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
