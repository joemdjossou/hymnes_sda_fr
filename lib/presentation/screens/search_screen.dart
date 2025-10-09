import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';

import '../../core/models/hymn.dart';
import '../../core/services/hymn_data_service.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/hymn_card.dart';
import '../../shared/widgets/modern_sliver_app_bar.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../widgets/glass_navigation_bar.dart';
import '../widgets/search_widgets/empty_search_state.dart';
import '../widgets/search_widgets/filter_chips_section.dart';
import '../widgets/search_widgets/filter_controls.dart';
import '../widgets/search_widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final HymnDataService _hymnDataService = HymnDataService();
  final ScrollController _scrollController = ScrollController();

  List<Hymn> _allHymns = [];
  List<Hymn> _filteredHymns = [];
  List<String> _themes = [];

  String? _selectedTheme;
  String? _selectedSubtheme;
  bool _isLoading = true;
  bool _showCollapsedAppBar = false;
  bool _showFilters = true;

  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _searchFadeAnimation;
  late Animation<double> _filterSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHymns();
    _searchController.addListener(_performSearch);
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOut,
    ));

    _filterSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeOut,
    ));

    _searchAnimationController.forward();
    // Start with filters shown, so forward the animation
    if (_showFilters) {
      _filterAnimationController.forward();
    }
  }

  void _onScroll() {
    // Show collapsed app bar when scrolled past the search section (around 100px)
    final shouldShow = _scrollController.offset > 70;
    if (shouldShow != _showCollapsedAppBar) {
      setState(() {
        _showCollapsedAppBar = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadHymns() async {
    try {
      final hymns = await _hymnDataService.getHymns();
      setState(() {
        _allHymns = hymns;
        _filteredHymns = hymns;
        _themes = hymns.map((h) => h.theme).toSet().toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading hymns: $e');
    }
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHymns = _allHymns.where((hymn) {
        final matchesText = query.isEmpty ||
            hymn.title.toLowerCase().contains(query) ||
            hymn.lyrics.toLowerCase().contains(query) ||
            hymn.author.toLowerCase().contains(query) ||
            hymn.composer.toLowerCase().contains(query) ||
            hymn.style.toLowerCase().contains(query) ||
            hymn.number.contains(query) ||
            hymn.theme.toLowerCase().contains(query) ||
            hymn.subtheme.toLowerCase().contains(query);

        final matchesTheme =
            _selectedTheme == null || hymn.theme == _selectedTheme;
        final matchesSubtheme =
            _selectedSubtheme == null || hymn.subtheme == _selectedSubtheme;

        return matchesText && matchesTheme && matchesSubtheme;
      }).toList();
    });
  }

  void _onHymnTap(Hymn hymn) {
    NavigationService.toHymnDetail(hymn.number);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTheme = null;
      _selectedSubtheme = null;
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern App Bar
              ModernSliverAppBar(
                title: l10n.search,
                subtitle: l10n.searchAmongHymns(_allHymns.length),
                icon: Icons.search_rounded,
                expandedHeight: 120,
                showCollapsedAppBar: _showCollapsedAppBar,
                actions: _showCollapsedAppBar
                    ? [
                        if (_selectedTheme != null ||
                            _selectedSubtheme != null ||
                            _searchController.text.isNotEmpty)
                          IconButton(
                            onPressed: _clearFilters,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.clear_all_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                          ),
                      ]
                    : null,
                animationController: _searchAnimationController,
                fadeAnimation: _searchFadeAnimation,
              ),

              // Search and Filter Section
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _searchAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _searchFadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  // Modern Search Bar
                                  CustomSearchBar(
                                    controller: _searchController,
                                    hintText: l10n.searchHymns,
                                    onClear: () => _searchController.clear(),
                                  ),

                                  const Gap(16),

                                  // Filter Controls Row
                                  FilterControls(
                                    showFilters: _showFilters,
                                    hasActiveFilters: _selectedTheme != null ||
                                        _selectedSubtheme != null ||
                                        _searchController.text.isNotEmpty,
                                    onToggleFilters: _toggleFilters,
                                    onClearFilters: _clearFilters,
                                  ),

                                  const Gap(16),
                                ],
                              ),
                            ),

                            // Filter Chips with Animation
                            FilterChipsSection(
                              showFilters: _showFilters,
                              filterSlideAnimation: _filterSlideAnimation,
                              selectedTheme: _selectedTheme,
                              selectedSubtheme: _selectedSubtheme,
                              themes: _themes,
                              allHymns: _allHymns,
                              onThemeChanged: (value) {
                                setState(() {
                                  _selectedTheme = value;
                                  _selectedSubtheme = null;
                                });
                                _performSearch();
                              },
                              onSubthemeChanged: (value) {
                                setState(() {
                                  _selectedSubtheme = value;
                                });
                                _performSearch();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Results Section
              _isLoading
                  ? SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const ShimmerHymnCard();
                          },
                          childCount: 8,
                        ),
                      ),
                    )
                  : _filteredHymns.isEmpty
                      ? SliverFillRemaining(
                          child: EmptySearchState(
                            onClearFilters: _clearFilters,
                          ),
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
}
