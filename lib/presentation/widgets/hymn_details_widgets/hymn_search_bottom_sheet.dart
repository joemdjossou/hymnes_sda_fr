import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/core/repositories/hymn_repository.dart';
import 'package:hymnes_sda_fr/features/audio/bloc/audio_bloc.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../../core/models/hymn.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/hymn_card.dart';
import '../search_widgets/search_bar.dart';

/// Bottom sheet widget for searching hymns from the detail screen
class HymnSearchBottomSheet extends StatefulWidget {
  const HymnSearchBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HymnSearchBottomSheet(),
    );
  }

  @override
  State<HymnSearchBottomSheet> createState() => _HymnSearchBottomSheetState();
}

class _HymnSearchBottomSheetState extends State<HymnSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final HymnRepository _hymnRepository = HymnRepository();
  List<Hymn> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
    // Load all hymns initially
    _loadAllHymns();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllHymns() async {
    setState(() {
      _isSearching = true;
    });
    try {
      final hymns = await _hymnRepository.getAllHymns();
      if (mounted) {
        setState(() {
          _searchResults = hymns;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      await _loadAllHymns();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _hymnRepository.searchHymns(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _onHymnTap(Hymn hymn) {
    Navigator.of(context).pop();
    // Stop audio if playing
    try {
      context.read<AudioBloc>().add(StopAudio());
    } catch (e) {
      // AudioBloc might not be available, continue anyway
    }
    // Navigate to the selected hymn
    NavigationService.pushReplacement('/hymn/${hymn.number}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.bottomNavigationBarBackground(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.largeBorderRadius),
          topRight: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.defaultPadding,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    l10n.search,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary(context),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
            ),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: l10n.searchHymns,
              onClear: () => _searchController.clear(),
            ),
          ),

          const Gap(16),

          // Results
          Flexible(
            child: _isSearching
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: AppColors.textSecondary(context)
                                    .withValues(alpha: 0.5),
                              ),
                              const Gap(16),
                              Text(
                                _searchController.text.isEmpty
                                    ? l10n.searchHymns
                                    : 'No results found',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.largePadding,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final hymn = _searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HymnCard(
                              hymn: hymn,
                              onTap: () => _onHymnTap(hymn),
                            ),
                          );
                        },
                      ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
