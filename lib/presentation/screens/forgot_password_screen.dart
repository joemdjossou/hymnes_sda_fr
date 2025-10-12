import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../core/utils/error_handler.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../shared/widgets/custom_toast.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(PasswordResetRequested(
            _emailController.text.trim(),
          ));
    }
  }

  void _navigateBack() {
    NavigationService.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }

        if (state is PasswordResetSent) {
          setState(() {
            _emailSent = true;
          });
          ToastService.showSuccess(
            context,
            title: l10n.success,
            message: l10n.passwordResetSent(state.email),
          );
        } else if (state is AuthError) {
          ToastService.showError(
            context,
            title: l10n.error,
            message: ErrorHandler.getLocalizedErrorMessage(state.message, l10n),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.resetPassword),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(40),
                  // Icon
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: theme.iconTheme.color,
                  ),
                  const Gap(24),
                  // Title
                  Text(
                    l10n.resetPassword,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  // Subtitle
                  Text(
                    l10n.resetPasswordDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(40),
                  if (!_emailSent) ...[
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: l10n.email,
                      hintText: l10n.enterEmail,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.emailRequired;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return l10n.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const Gap(24),
                    // Send Reset Email Button
                    CustomButton(
                      text: l10n.sendResetEmail,
                      onPressed: _isLoading ? null : _sendResetEmail,
                      isLoading: _isLoading,
                    ),
                  ] else ...[
                    // Success State
                    Container(
                      padding: const EdgeInsets.all(AppConstants.largePadding),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green,
                          ),
                          const Gap(16),
                          Text(
                            l10n.passwordResetSent(
                                _emailController.text.trim()),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.green.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(8),
                          Text(
                            l10n.checkEmailInstructions,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),
                    // Back to Sign In Button
                    CustomButton(
                      text: l10n.backToSignIn,
                      onPressed: _navigateBack,
                      variant: ButtonVariant.outlined,
                    ),
                  ],
                  const Gap(40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
