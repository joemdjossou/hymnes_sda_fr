import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/features/auth/bloc/auth_bloc.dart';
import 'package:hymnes_sda_fr/features/favorites/bloc/favorites_bloc.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_colors.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';
import 'package:hymnes_sda_fr/shared/widgets/shimmer_loading.dart';
import 'package:logger/logger.dart';

import 'stat_card.dart';

class HeroSection extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final int hymnsCount;
  final bool isLoading;

  const HeroSection({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.hymnsCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.05),
                AppColors.surface(context),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppConstants.largeBorderRadius),
              bottomRight: Radius.circular(AppConstants.largeBorderRadius),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildWelcomeSection(context, l10n, theme),
                  const Gap(16),
                  _buildStatsSection(context, l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcome,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Gap(4),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String title = l10n.appTitle;
                  if (state is Authenticated) {
                    title = state.user.displayNameOrEmail;
                  }
                  return Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        _buildUserAvatar(context, l10n),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                state.user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'signout') {
                context.read<AuthBloc>().add(SignOutRequested());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const Gap(8),
                    Text(l10n.signOut),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                NavigationService.toLogin();
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildStatsSection(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        isLoading
            ? const ShimmerStatCard()
            : StatCard(
                icon: Icons.music_note,
                value: hymnsCount.toString(),
                label: l10n.hymns,
                onTap: () async {
                  Logger().d('Hymns count: $hymnsCount');
                },
              ),
        const Gap(12),
        BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, favoritesState) {
            final favoritesCount = favoritesState is FavoritesLoaded
                ? favoritesState.favorites.length
                : 0;
            return StatCard(
              onTap: () {
                NavigationService.toFavorites();
              },
              icon: Icons.favorite,
              value: favoritesCount.toString(),
              label: l10n.favorites,
            );
          },
        ),
      ],
    );
  }
}
