import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';

import '../../core/models/hymn.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/hymn_card.dart';
import '../../shared/widgets/modern_sliver_app_bar.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../widgets/auth_required_widget.dart';
import 'hymn_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
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
    // Show collapsed app bar when scrolled past the hero section (around 80px)
    final shouldShow = _scrollController.offset > 80;
    if (shouldShow != _showCollapsedAppBar) {
      setState(() {
        _showCollapsedAppBar = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroAnimationController.dispose();
    super.dispose();
  }

  void _onHymnTap(BuildContext context, Hymn hymn) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HymnDetailScreen(hymnId: hymn.number),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: AuthRequiredWidget(
        message: l10n.authenticationRequiredDescription,
        child: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Modern App Bar
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, favoritesState) {
                    String? subtitle;
                    if (favoritesState is FavoritesLoaded) {
                      subtitle =
                          '${favoritesState.favorites.length} ${favoritesState.favorites.length == 1 ? l10n.hymnSaved : l10n.hymnsSaved}';
                    } else if (favoritesState is FavoritesLoading) {
                      subtitle = l10n.loading;
                    } else {
                      subtitle = l10n.yourFavoriteHymns;
                    }

                    return ModernSliverAppBar(
                      title: l10n.favorites,
                      subtitle: subtitle,
                      icon: Icons.favorite_rounded,
                      expandedHeight: 120,
                      showCollapsedAppBar: _showCollapsedAppBar,
                      animationController: _heroAnimationController,
                      fadeAnimation: _heroFadeAnimation,
                      slideAnimation: _heroSlideAnimation,
                    );
                  },
                ),

                // Gap
                const SliverToBoxAdapter(
                  child: Gap(20),
                ),
                // Content Section
                if (state is FavoritesLoading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: ShimmerHymnCard(),
                          );
                        },
                        childCount: 6,
                      ),
                    ),
                  )
                else if (state is FavoritesError)
                  SliverFillRemaining(
                    child: _buildErrorState(context, l10n, state.message),
                  )
                else if (state is FavoritesLoaded)
                  state.favorites.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(context, l10n),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final hymn = state.favorites[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: HymnCard(
                                    hymn: hymn,
                                    onTap: () => _onHymnTap(context, hymn),
                                  ),
                                );
                              },
                              childCount: state.favorites.length,
                            ),
                          ),
                        )
                else
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        l10n.favoritesToBe,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, AppLocalizations l10n, String message) {
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
              l10n.oopsErrorOccurred,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Logger().d('🔔🚀 $message');
                context.read<FavoritesBloc>().add(LoadFavorites());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
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
                Icons.favorite_border_rounded,
                size: 64,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noFavoritesYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addFavoritesDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to search or home screen
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.search_rounded),
                label: Text(l10n.discoverHymns),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
