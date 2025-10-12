import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../../core/models/hymn.dart';
import '../../../shared/constants/app_colors.dart';

/// Widget responsible only for displaying hymn history section
/// Follows Single Responsibility Principle
class HymnHistoryWidget extends StatelessWidget {
  final Hymn hymn;
  final VoidCallback? onTap;

  const HymnHistoryWidget({
    super.key,
    required this.hymn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.history_edu_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.hymnHistory,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        l10n.discoverStory,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary(context),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
