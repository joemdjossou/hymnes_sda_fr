import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../shared/constants/app_colors.dart';
import '../widgets/custom_button.dart';

class AuthRequiredWidget extends StatelessWidget {
  final Widget child;
  final String? message;

  const AuthRequiredWidget({
    super.key,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return child;
        } else {
          return _AuthRequiredPrompt(
            message: message,
          );
        }
      },
    );
  }
}

class _AuthRequiredPrompt extends StatelessWidget {
  final String? message;

  const _AuthRequiredPrompt({
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: AppColors.textSecondary(context),
              ),
            ),
            const Gap(32),
            Text(
              l10n.authenticationRequired,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            Text(
              message ?? l10n.authenticationRequiredDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(40),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CustomButton(
                text: l10n.signInToContinue,
                onPressed: () {
                  NavigationService.toLogin();
                },
                variant: ButtonVariant.filled,
              ),
            ),
            const Gap(20),
            if (Navigator.canPop(context))
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    NavigationService.pop();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
