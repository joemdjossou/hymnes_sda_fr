import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/core/services/home_widget_service.dart';
import 'package:hymnes_sda_fr/shared/constants/app_colors.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';
import 'package:upgrader/upgrader.dart';

import '../../core/models/hymn.dart';
import '../../core/services/error_logging_service.dart';
import '../../core/services/hymn_data_service.dart';
import '../../core/utils/global_error_handler.dart';
import '../../core/utils/text_utils.dart';
import '../../shared/widgets/hymn_card.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../widgets/home_widgets/collapsed_app_bar.dart';
import '../widgets/home_widgets/empty_state_widget.dart';
import '../widgets/home_widgets/glass_navigation_bar.dart';
import '../widgets/home_widgets/hero_section.dart';
import '../widgets/home_widgets/search_section.dart';

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
    // Initialize home widget service
    HomeWidgetService.initialize();
    // Start periodic featured hymn updates
    _startPeriodicFeaturedHymnUpdate();
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

      // Update home widget with hymns count and featured hymn
      await HomeWidgetService.updateHymnsCount(hymns.length);

      // Set a random featured hymn
      await HomeWidgetService.updateRandomFeaturedHymn(hymns);

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
    final query = TextUtils.normalizeText(_searchController.text);
    setState(() {
      if (query.isEmpty) {
        _filteredHymns = _hymns;
      } else {
        _filteredHymns = _hymns.where((hymn) {
          return TextUtils.normalizeText(hymn.title).contains(query) ||
              TextUtils.normalizeText(hymn.lyrics).contains(query) ||
              TextUtils.normalizeText(hymn.author).contains(query) ||
              TextUtils.normalizeText(hymn.composer).contains(query) ||
              TextUtils.normalizeText(hymn.style).contains(query) ||
              hymn.number.contains(_searchController.text);
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

  void _startPeriodicFeaturedHymnUpdate() {
    // Update featured hymn every 30 minutes
    Timer.periodic(const Duration(minutes: 30), (timer) {
      if (mounted && _hymns.isNotEmpty) {
        HomeWidgetService.updateRandomFeaturedHymn(_hymns);
      }
    });
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

      NavigationService.toHymnDetail(hymn.number);
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
    return UpgradeAlert(
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // App Bar with Hero Section
                _showCollapsedAppBar
                    ? CollapsedAppBar(hymnsCount: _hymns.length)
                    : SliverAppBar(
                        expandedHeight: 200,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
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
                        flexibleSpace: FlexibleSpaceBar(
                          background: HeroSection(
                            fadeAnimation: _heroFadeAnimation,
                            slideAnimation: _heroSlideAnimation,
                            hymnsCount: _hymns.length,
                            isLoading: _isLoading,
                          ),
                        ),
                      ),

                // Search Section
                SliverToBoxAdapter(
                  child: SearchSection(
                    searchController: _searchController,
                    filteredHymnsCount: _filteredHymns.length,
                    fadeAnimation: _searchFadeAnimation,
                  ),
                ),

                // Hymns List
                _isLoading
                    ? SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const ShimmerHymnCard(),
                            childCount: 6,
                          ),
                        ),
                      )
                    : _filteredHymns.isEmpty
                        ? SliverFillRemaining(
                            child: EmptyStateWidget(
                              searchQuery: _searchController.text,
                              onClearSearch: () => _searchController.clear(),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final hymn = _filteredHymns[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppConstants.defaultPadding),
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
            const GlassNavigationBar(),
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
