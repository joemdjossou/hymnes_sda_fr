import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

import '../../core/models/hymn.dart';
import '../../core/services/error_logging_service.dart';
import '../../core/services/hymn_data_service.dart';
import '../../core/utils/global_error_handler.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/hymn_card.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../screens/hymn_detail_screen.dart';
import '../widgets/glass_navigation_bar.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Hymn> _hymns = [];
  List<Hymn> _filteredHymns = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _showCollapsedAppBar = false;
  late AnimationController _heroAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _searchFadeAnimation;

  // Error logging service
  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHymns();
    _searchController.addListener(_filterHymns);
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      curve: Curves.easeOutCubic,
    ));

    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOut,
    ));

    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _searchAnimationController.forward();
    });
  }

  Future<void> _loadHymns() async {
    try {
      final hymns = await HymnDataService().getHymns();
      setState(() {
        _hymns = hymns;
        _filteredHymns = hymns;
        _isLoading = false;
      });

      await _errorLogger.logInfo(
        'HomeScreen',
        'Hymns loaded successfully',
        context: {
          'hymnCount': hymns.length,
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      await _errorLogger.logUIError(
        'HomeScreen',
        'HomeScreen',
        'Failed to load hymns',
        error: e,
        stackTrace: StackTrace.current,
        uiContext: {
          'screen': 'HomeScreen',
          'operation': 'loadHymns',
        },
      );

      // Show error to user
      if (mounted) {
        context.showErrorSnackBar(
          'Failed to load hymns. Please try again.',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
    }
  }

  void _filterHymns() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredHymns = _hymns;
      } else {
        _filteredHymns = _hymns.where((hymn) {
          return hymn.title.toLowerCase().contains(query) ||
              hymn.lyrics.toLowerCase().contains(query) ||
              hymn.author.toLowerCase().contains(query) ||
              hymn.composer.toLowerCase().contains(query) ||
              hymn.style.toLowerCase().contains(query) ||
              hymn.number.contains(query);
        }).toList();
      }
    });
  }

  void _onScroll() {
    // Show collapsed app bar when scrolled past the hero section (around 120px)
    final shouldShow = _scrollController.offset > 150;
    if (shouldShow != _showCollapsedAppBar) {
      setState(() {
        _showCollapsedAppBar = shouldShow;
      });
    }
  }

  void _onHymnTap(Hymn hymn) {
    try {
      _errorLogger.logDebug(
        'HomeScreen',
        'User tapped on hymn',
        context: {
          'hymnNumber': hymn.number,
          'hymnTitle': hymn.title,
        },
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HymnDetailScreen(hymnId: hymn.number),
        ),
      );
    } catch (e) {
      _errorLogger.logUIError(
        'HomeScreen',
        'HomeScreen',
        'Failed to navigate to hymn detail',
        error: e,
        stackTrace: StackTrace.current,
        uiContext: {
          'hymnNumber': hymn.number,
          'hymnTitle': hymn.title,
          'operation': 'navigateToHymnDetail',
        },
      );

      if (mounted) {
        context.showErrorSnackBar(
          'Failed to open hymn. Please try again.',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern App Bar with Hero Section
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: _showCollapsedAppBar
                    ? AppColors.surface(context)
                    : Colors.transparent,
                surfaceTintColor: _showCollapsedAppBar
                    ? AppColors.surface(context)
                    : Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      Theme.of(context).brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark,
                  statusBarBrightness:
                      Theme.of(context).brightness == Brightness.dark
                          ? Brightness.dark
                          : Brightness.light,
                ),
                title: _showCollapsedAppBar
                    ? Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient(context),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.music_note_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.appTitle,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: AppColors.textPrimary(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_hymns.length} ${l10n.hymns.toLowerCase()}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : null,
                actions: _showCollapsedAppBar
                    ? [
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            if (authState is Authenticated) {
                              return PopupMenuButton<String>(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient:
                                        AppColors.primaryGradient(context),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    authState.user.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                onSelected: (value) {
                                  if (value == 'signout') {
                                    context
                                        .read<AuthBloc>()
                                        .add(SignOutRequested());
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'signout',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.logout, size: 20),
                                        const Gap(8),
                                        Text(l10n.signOut),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.login),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ]
                    : null,
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
                                  AppColors.primary.withValues(alpha: 0.1),
                                  AppColors.secondary.withValues(alpha: 0.05),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Welcome Section
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.welcome,
                                                style: theme
                                                    .textTheme.headlineSmall
                                                    ?.copyWith(
                                                  color: AppColors.textPrimary(
                                                      context),
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              const Gap(4),
                                              BlocBuilder<AuthBloc, AuthState>(
                                                builder: (context, state) {
                                                  String title = l10n.appTitle;
                                                  if (state is Authenticated) {
                                                    title = state.user
                                                        .displayNameOrEmail;
                                                  }
                                                  return Text(
                                                    title,
                                                    style: theme.textTheme
                                                        .headlineMedium
                                                        ?.copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        // User Avatar
                                        BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, state) {
                                            if (state is Authenticated) {
                                              return PopupMenuButton<String>(
                                                icon: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    gradient: AppColors
                                                        .primaryGradient(
                                                            context),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.primary
                                                            .withValues(
                                                                alpha: 0.3),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    state.user.initials,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                onSelected: (value) {
                                                  if (value == 'signout') {
                                                    context
                                                        .read<AuthBloc>()
                                                        .add(
                                                            SignOutRequested());
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 'signout',
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.logout,
                                                            size: 20),
                                                        const Gap(8),
                                                        Text(l10n.signOut),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: AppColors.primary
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.login),
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const LoginScreen(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const Gap(16),
                                    // Quick Stats
                                    Row(
                                      children: [
                                        _isLoading
                                            ? const ShimmerStatCard()
                                            : _buildStatCard(
                                                icon: Icons.music_note,
                                                value: _hymns.length.toString(),
                                                label: l10n.hymns,
                                                context: context,
                                              ),
                                        const Gap(12),
                                        BlocBuilder<FavoritesBloc,
                                            FavoritesState>(
                                          builder: (context, favoritesState) {
                                            final favoritesCount =
                                                favoritesState
                                                        is FavoritesLoaded
                                                    ? favoritesState
                                                        .favorites.length
                                                    : 0;
                                            return _buildStatCard(
                                              icon: Icons.favorite,
                                              value: favoritesCount.toString(),
                                              label: l10n.favorites,
                                              context: context,
                                            );
                                          },
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

              // Search Section
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _searchAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _searchFadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Modern Search Bar
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.cardBackground(context),
                                    AppColors.cardBackground(context)
                                        .withValues(alpha: 0.8),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.border(context)
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: AppColors.textPrimary(context)
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.searchHymns,
                                  hintStyle: TextStyle(
                                    color: AppColors.textHint(context),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient:
                                          AppColors.primaryGradient(context),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.textHint(context)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.clear_rounded,
                                              color:
                                                  AppColors.textHint(context),
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                            },
                                          ),
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                ),
                              ),
                            ),

                            const Gap(16),

                            // Results Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (_searchController.text.isNotEmpty)
                                  Text(
                                    l10n.hymnsFound(_filteredHymns.length),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: AppColors.textSecondary(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (_searchController.text.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                    icon: Icon(
                                      Icons.clear_all_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    label: Text(
                                      l10n.clear,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Hymns List
              _isLoading
                  ? SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const ShimmerHymnCard();
                          },
                          childCount: 6, // Show 6 shimmer cards
                        ),
                      ),
                    )
                  : _filteredHymns.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(l10n, theme),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final hymn = _filteredHymns[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: HymnCard(
                                    hymn: hymn,
                                    onTap: () => _onHymnTap(hymn),
                                  ),
                                );
                              },
                              childCount: _filteredHymns.length,
                            ),
                          ),
                        ),
            ],
          ),
          // Glass Navigation Bar
          const GlassNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required BuildContext context,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border(context).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary(context).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _searchController.text.isEmpty
                    ? Icons.music_note_rounded
                    : Icons.search_off_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const Gap(24),
            Text(
              _searchController.text.isEmpty
                  ? l10n.noHymnsAvailable
                  : l10n.noHymnsFound,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              _searchController.text.isEmpty
                  ? l10n.noHymnsAvailableAtMoment
                  : l10n.tryModifyingSearchCriteria,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const Gap(24),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.clear),
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
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _heroAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }
}
