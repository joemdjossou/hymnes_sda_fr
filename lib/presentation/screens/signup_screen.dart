import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

import '../../core/navigation/navigation_service.dart';
import '../../core/utils/error_handler.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../shared/widgets/custom_toast.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _signUpWithEmail() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  void _signInWithApple() {
    context.read<AuthBloc>().add(AppleSignInRequested());
  }

  void _navigateToLogin() {
    NavigationService.back();
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

        if (state is Authenticated) {
          ToastService.showSuccess(
            context,
            title: l10n.success,
            message: l10n.signUpSuccess,
          );
          NavigationService.clearStackAndGoHome();
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
          title: Text(l10n.createAccount),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToLogin,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(20),
                  // App Logo/Icon
                  Icon(
                    Icons.music_note,
                    size: 80,
                    color: theme.primaryColor,
                  ),
                  const Gap(24),
                  // Title
                  Text(
                    l10n.createAccount,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  // Subtitle
                  Text(
                    l10n.createAccountDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(40),
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
                  const Gap(16),
                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    labelText: l10n.password,
                    hintText: l10n.enterPassword,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.passwordRequired;
                      }
                      if (value.length < 6) {
                        return l10n.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: l10n.confirmPassword,
                    hintText: l10n.enterConfirmPassword,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: _toggleConfirmPasswordVisibility,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.confirmPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const Gap(24),
                  // Sign Up Button
                  CustomButton(
                    text: l10n.createAccount,
                    onPressed: _isLoading ? null : _signUpWithEmail,
                    isLoading: _isLoading,
                  ),
                  const Gap(16),
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          l10n.or,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: theme.dividerColor)),
                    ],
                  ),
                  const Gap(16),
                  // Google Sign Up Button
                  CustomButton(
                    text: l10n.signInWithGoogle,
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    variant: ButtonVariant.outlined,
                    icon: Icons.g_mobiledata,
                  ),
                  const Gap(12),
                  // Apple Sign Up Button
                  CustomButton(
                    text: l10n.signInWithApple,
                    onPressed: _isLoading ? null : _signInWithApple,
                    variant: ButtonVariant.outlined,
                    icon: Icons.apple,
                  ),
                  const Gap(24),
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: Text(l10n.signIn),
                      ),
                    ],
                  ),
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
