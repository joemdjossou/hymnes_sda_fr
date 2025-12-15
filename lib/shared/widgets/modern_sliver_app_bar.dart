import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../shared/constants/app_colors.dart';

class ModernSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? style;
  final String? author;
  final String? composer;
  final IconData icon;
  final double expandedHeight;
  final bool showCollapsedAppBar;
  final List<Widget>? actions;
  final Widget? heroContent;
  final Widget? leading;
  final AnimationController? animationController;
  final Animation<double>? fadeAnimation;
  final Animation<Offset>? slideAnimation;

  const ModernSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.style,
    this.author,
    this.composer,
    required this.icon,
    this.expandedHeight = 140,
    required this.showCollapsedAppBar,
    this.actions,
    this.heroContent,
    this.leading,
    this.animationController,
    this.fadeAnimation,
    this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor:
          showCollapsedAppBar ? AppColors.surface(context) : Colors.transparent,
      surfaceTintColor:
          showCollapsedAppBar ? AppColors.surface(context) : Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: leading,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
      ),
      title: showCollapsedAppBar
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.largeBorderRadius),
                  bottomRight: Radius.circular(AppConstants.largeBorderRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.smallPadding),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
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
                      child: Icon(
                        icon,
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
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (style != null)
                            Container(
                              margin: const EdgeInsets.only(
                                  top: AppConstants.smallPadding - 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                style!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: animationController != null
            ? AnimatedBuilder(
                animation: animationController!,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                    child: SlideTransition(
                      position: slideAnimation ??
                          const AlwaysStoppedAnimation(Offset.zero),
                      child: _buildHeroContent(context, l10n, theme),
                    ),
                  );
                },
              )
            : _buildHeroContent(context, l10n, theme),
      ),
    );
  }

  Widget _buildHeroContent(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Container(
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
              if (heroContent != null)
                heroContent!
              else
                _buildDefaultHeroContent(context, l10n, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultHeroContent(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding - 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius:
                    BorderRadius.circular(AppConstants.mediumBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const Gap(4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (author != null || composer != null || style != null) ...[
          const Gap(16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              (style != null && style!.isNotEmpty)
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding - 4,
                        vertical: AppConstants.smallPadding - 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Text(
                        style!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const Gap(20),
              if (composer != null && composer!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding - 4,
                    vertical: AppConstants.smallPadding - 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppColors.textSecondary(context).withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Text(
                    '${l10n.composer}: $composer',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
