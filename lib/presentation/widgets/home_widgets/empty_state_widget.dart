import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_colors.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;

  const EmptyStateWidget({
    super.key,
    required this.searchQuery,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.extraLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.largeBorderRadius),
              ),
              child: Icon(
                searchQuery.isEmpty
                    ? Icons.music_note_rounded
                    : Icons.search_off_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const Gap(24),
            Text(
              searchQuery.isEmpty ? l10n.noHymnsAvailable : l10n.noHymnsFound,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              searchQuery.isEmpty
                  ? l10n.noHymnsAvailableAtMoment
                  : l10n.tryModifyingSearchCriteria,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (searchQuery.isNotEmpty) ...[
              const Gap(24),
              ElevatedButton.icon(
                onPressed: onClearSearch,
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
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
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
}
