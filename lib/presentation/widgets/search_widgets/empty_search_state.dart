import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../../shared/constants/app_colors.dart';

class EmptySearchState extends StatelessWidget {
  final VoidCallback onClearFilters;

  const EmptySearchState({
    super.key,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding * 2),
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.textSecondary(context),
              ),
            ),
            const Gap(24),
            Text(
              l10n.noHymnsAvailableAtMoment,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            Text(
              l10n.tryModifyingSearchCriteria,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.clearFilters),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largePadding,
                  vertical: AppConstants.defaultPadding - 4,
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
