import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_colors.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

class SearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final int filteredHymnsCount;
  final Animation<double> fadeAnimation;

  const SearchSection({
    super.key,
    required this.searchController,
    required this.filteredHymnsCount,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context, l10n),
            const Gap(16),
            _buildResultsHeader(context, l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
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
            margin: const EdgeInsets.all(AppConstants.smallPadding),
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius:
                  BorderRadius.circular(AppConstants.largeBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
          suffixIcon: searchController.text.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textHint(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppColors.textHint(context),
                      size: 20,
                    ),
                    onPressed: () {
                      searchController.clear();
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
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    if (searchController.text.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.hymnsFound(filteredHymnsCount),
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            searchController.clear();
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
    );
  }
}
