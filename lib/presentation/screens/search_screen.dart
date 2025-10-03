import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/models/hymn.dart';
import '../../core/services/hymn_data_service.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/hymn_card.dart';
import 'hymn_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HymnDataService _hymnDataService = HymnDataService();

  List<Hymn> _allHymns = [];
  List<Hymn> _filteredHymns = [];
  List<String> _themes = [];

  String? _selectedTheme;
  String? _selectedSubtheme;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHymns();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HymnDetailScreen(hymnId: hymn.number),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTheme = null;
      _selectedSubtheme = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          l10n.search,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface(context),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          if (_selectedTheme != null ||
              _selectedSubtheme != null ||
              _searchController.text.isNotEmpty)
            IconButton(
              onPressed: _clearFilters,
              icon: Icon(
                Icons.clear_all,
                color: AppColors.textPrimary(context),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search and Filter Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.searchHymns,
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textHint(context),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: AppColors.textHint(context),
                                    ),
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.cardBackground(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Theme Filter
                              _buildFilterChip(
                                label: 'Thème',
                                value: _selectedTheme,
                                options: _themes,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTheme = value;
                                    _selectedSubtheme =
                                        null; // Reset subtheme when theme changes
                                  });
                                  _performSearch();
                                },
                              ),

                              const SizedBox(width: 8),

                              // Subtheme Filter
                              _buildFilterChip(
                                label: 'Sous-thème',
                                value: _selectedSubtheme,
                                options: _selectedTheme != null
                                    ? () {
                                        final subthemes = _allHymns
                                            .where((h) =>
                                                h.theme == _selectedTheme)
                                            .map((h) => h.subtheme)
                                            .toSet()
                                            .toList();
                                        subthemes.sort();
                                        return subthemes;
                                      }()
                                    : _allHymns
                                        .map((h) => h.subtheme)
                                        .toSet()
                                        .toList()
                                  ..sort(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSubtheme = value;
                                  });
                                  _performSearch();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results Section
                  Expanded(
                    child: _filteredHymns.isEmpty
                        ? _buildEmptyState(l10n)
                        : Column(
                            children: [
                              // Results Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_filteredHymns.length} ${_filteredHymns.length == 1 ? 'hymne trouvé' : 'hymnes trouvés'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary(
                                                context),
                                          ),
                                    ),
                                    if (_selectedTheme != null ||
                                        _selectedSubtheme != null)
                                      TextButton.icon(
                                        onPressed: _clearFilters,
                                        icon: Icon(
                                          Icons.filter_list_off,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        label: Text(
                                          'Effacer filtres',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Hymns List
                              Expanded(
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                  itemCount: _filteredHymns.length,
                                  itemBuilder: (context, index) {
                                    final hymn = _filteredHymns[index];
                                    return HymnCard(
                                      hymn: hymn,
                                      onTap: () => _onHymnTap(hymn),
                                    );
                                  },
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

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 200,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border(context),
            width: 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textHint(context),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Tous les $label',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ...options.map((option) => DropdownMenuItem<String>(
                    value: option,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),
            ],
            onChanged: onChanged,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textHint(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textHint(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun hymne trouvé',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint(context),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Effacer les filtres'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
