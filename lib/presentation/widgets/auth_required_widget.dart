import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../screens/login_screen.dart';
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: theme.primaryColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.authenticationRequired,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? l10n.authenticationRequiredDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: l10n.signInToContinue,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            //TextButton(
            //onPressed: () {
            //Navigator.of(context).pop();
            //},
            //child: Text(l10n.cancel),
            //),
          ],
        ),
      ),
    );
  }
}
