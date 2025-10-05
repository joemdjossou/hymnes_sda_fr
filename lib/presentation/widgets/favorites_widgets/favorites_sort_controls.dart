import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

import '../../../features/favorites/models/favorites_sort_option.dart';
import '../../../shared/constants/app_colors.dart';

class FavoritesSortControls extends StatelessWidget {
  final FavoritesSortOption currentSortOption;
  final ValueChanged<FavoritesSortOption> onSortChanged;

  const FavoritesSortControls({
    super.key,
    required this.currentSortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortChip(
              context: context,
              l10n: l10n,
              currentSortOption: currentSortOption,
              onSortChanged: onSortChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip({
    required BuildContext context,
    required AppLocalizations l10n,
    required FavoritesSortOption currentSortOption,
    required ValueChanged<FavoritesSortOption> onSortChanged,
  }) {
    final sortOptions = [
      FavoritesSortOption.numberAscending,
      FavoritesSortOption.numberDescending,
      FavoritesSortOption.dateAddedNewestFirst,
      FavoritesSortOption.dateAddedOldestFirst,
      FavoritesSortOption.titleAscending,
      FavoritesSortOption.titleDescending,
      FavoritesSortOption.authorAscending,
      FavoritesSortOption.authorDescending,
    ];

    final sortLabels = [
      '${l10n.sortByNumber} (${l10n.sortAscending})',
      '${l10n.sortByNumber} (${l10n.sortDescending})',
      '${l10n.sortByDateAdded} (${l10n.sortNewestFirst})',
      '${l10n.sortByDateAdded} (${l10n.sortOldestFirst})',
      '${l10n.sortByTitle} (${l10n.sortAscending})',
      '${l10n.sortByTitle} (${l10n.sortDescending})',
      '${l10n.sortByAuthor} (${l10n.sortAscending})',
      '${l10n.sortByAuthor} (${l10n.sortDescending})',
    ];

    final currentLabel = sortLabels[sortOptions.indexOf(currentSortOption)];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary,
        ),
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSortSelectorBottomSheet(
            context: context,
            l10n: l10n,
            currentSortOption: currentSortOption,
            sortOptions: sortOptions,
            sortLabels: sortLabels,
            onSortChanged: onSortChanged,
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const Gap(8),
                Text(
                  currentLabel,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Gap(4),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSortSelectorBottomSheet({
    required BuildContext context,
    required AppLocalizations l10n,
    required FavoritesSortOption currentSortOption,
    required List<FavoritesSortOption> sortOptions,
    required List<String> sortLabels,
    required ValueChanged<FavoritesSortOption> onSortChanged,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.sortBy,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Sort options
            ...sortOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final sortOption = entry.value;
              final label = sortLabels[index];
              final isSelected = sortOption == currentSortOption;

              return ListTile(
                leading: Icon(
                  _getSortIcon(sortOption),
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary(context),
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary(context),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  onSortChanged(sortOption);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(FavoritesSortOption sortOption) {
    switch (sortOption) {
      case FavoritesSortOption.numberAscending:
      case FavoritesSortOption.numberDescending:
        return Icons.format_list_numbered_rounded;
      case FavoritesSortOption.dateAddedOldestFirst:
      case FavoritesSortOption.dateAddedNewestFirst:
        return Icons.schedule_rounded;
      case FavoritesSortOption.titleAscending:
      case FavoritesSortOption.titleDescending:
        return Icons.title_rounded;
      case FavoritesSortOption.authorAscending:
      case FavoritesSortOption.authorDescending:
        return Icons.person_rounded;
    }
  }
}
