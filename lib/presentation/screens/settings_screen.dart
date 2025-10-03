import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/providers/language_provider.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../shared/constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/theme_selection_widget.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'v1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version}';
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      // Keep default values if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountSection(context, l10n),
            const SizedBox(height: 24),
            _buildLanguageSection(context, l10n),
            const SizedBox(height: 24),
            const ThemeSelectionWidget(),
            const SizedBox(height: 24),
            _buildAppInfoSection(context, l10n),
            const Gap(100), // Extra padding at bottom for better scrolling
            // Add more settings sections here in the future
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.language,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectLanguage,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context).withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, state) {
              final currentLocale = state is LanguageLoaded
                  ? state.locale
                  : const Locale('en', 'US');

              return Column(
                children: LanguageBloc.supportedLocales.map((locale) {
                  final isSelected =
                      currentLocale.languageCode == locale.languageCode;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context
                              .read<LanguageBloc>()
                              .add(ChangeLanguage(locale));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surface(context)
                                    .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.border(context)
                                      .withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                LanguageBloc.getLanguageFlag(locale),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LanguageBloc.getLanguageName(locale),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary(context),
                                      ),
                                    ),
                                    Text(
                                      locale.languageCode == 'en'
                                          ? l10n.english
                                          : l10n.french,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary(context)
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardBackground(context),
                  AppColors.cardBackground(context).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.account,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        state.user.initials,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.user.displayNameOrEmail,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            state.user.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context)
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: l10n.signOut,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.signOut),
                        content: Text(l10n.signOutConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<AuthBloc>().add(SignOutRequested());
                            },
                            child: Text(l10n.signOut),
                          ),
                        ],
                      ),
                    );
                  },
                  variant: ButtonVariant.outlined,
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardBackground(context),
                  AppColors.cardBackground(context).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.account,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.signInToSaveFavorites,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        AppColors.textSecondary(context).withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: l10n.signIn,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildAppInfoSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.appInfo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.version,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      AppColors.textSecondary(context).withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                _appVersion,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.buildNumber,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      AppColors.textSecondary(context).withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                _buildNumber,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
