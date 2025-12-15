// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';
import 'package:hymnes_sda_fr/shared/widgets/custom_toast.dart';

import '../../core/models/hymn.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../constants/app_colors.dart';
import 'favorite_button_shimmer.dart';

class HymnCard extends StatelessWidget {
  final Hymn hymn;
  final VoidCallback onTap;

  const HymnCard({
    super.key,
    required this.hymn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state is FavoritesLoaded
            ? state.favoriteStatus[hymn.number] ?? false
            : false;

        // Check if this hymn is currently being toggled
        final isToggling =
            state is FavoritesLoaded && state.togglingHymnNumber == hymn.number;

        // Show local data immediately, no loading states for background sync

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
              borderRadius:
                  BorderRadius.circular(AppConstants.mediumBorderRadius),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                child: Row(
                  children: [
                    // Hymn Number with Modern Design
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.background(context),
                            AppColors.cardBackground(context)
                                .withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                            AppConstants.mediumBorderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardBackground(context)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          hymn.number,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const Gap(16),

                    // Hymn Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hymn.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(6),
                          Text(
                            hymn.author,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary(context),
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              (hymn.style.isNotEmpty)
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppConstants.smallPadding,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.smallBorderRadius),
                                      ),
                                      child: Text(
                                        hymn.style,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              (hymn.theme.isNotEmpty)
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppConstants.smallPadding,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.smallBorderRadius),
                                      ),
                                      child: Text(
                                        hymn.theme,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.secondaryDark,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Gap(12),

                    // Action Buttons
                    Column(
                      children: [
                        // Favorite Button
                        isToggling
                            ? const FavoriteButtonShimmer(
                                size: 48,
                                iconSize: 20,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: isFavorite
                                      ? AppColors.favorite
                                          .withValues(alpha: 0.1)
                                      : AppColors.textSecondary(context)
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadius),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    context
                                        .read<FavoritesBloc>()
                                        .add(ToggleFavorite(hymn));
                                    ToastService.showSuccess(
                                      context,
                                      title: l10n.favorite,
                                      message: context
                                              .read<FavoritesBloc>()
                                              .isFavorite(hymn.number)
                                          ? l10n.favoriteRemoved
                                          : l10n.favoriteAdded,
                                    );
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFavorite
                                        ? AppColors.favorite
                                        : AppColors.textSecondary(context),
                                    size: 20,
                                  ),
                                ),
                              ),
                        const Gap(8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
