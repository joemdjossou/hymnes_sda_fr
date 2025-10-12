import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/features/auth/bloc/auth_bloc.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_colors.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

class CollapsedAppBar extends StatelessWidget {
  final int hymnsCount;

  const CollapsedAppBar({
    super.key,
    required this.hymnsCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface(context),
      surfaceTintColor: AppColors.surface(context),
      elevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
      ),
      title: _buildTitle(context, l10n, theme),
      actions: [_buildUserMenu(context, l10n)],
    );
  }

  Widget _buildTitle(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.music_note_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${hymnsCount} ${l10n.hymns.toLowerCase()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          return PopupMenuButton<String>(
            icon: Container(
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
              child: Text(
                authState.user.initials,
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
              borderRadius:
                  BorderRadius.circular(AppConstants.largeBorderRadius),
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
}
