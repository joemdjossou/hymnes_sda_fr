import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/providers/language_provider.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/modern_sliver_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/theme_selection_widget.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  String _appVersion = 'v1.0.0';
  String _buildNumber = '1';
  final ScrollController _scrollController = ScrollController();
  bool _showCollapsedAppBar = false;

  late AnimationController _heroAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAppVersion();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.easeOut,
    ));

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.easeOut,
    ));

    _heroAnimationController.forward();
  }

  void _onScroll() {
    // Show collapsed app bar when scrolled past the hero section (around 80px)
    final shouldShow = _scrollController.offset > 80;
    if (shouldShow != _showCollapsedAppBar) {
      setState(() {
        _showCollapsedAppBar = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroAnimationController.dispose();
    super.dispose();
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Modern App Bar
          ModernSliverAppBar(
            title: l10n.settings,
            subtitle: l10n.customizeExperience,
            icon: Icons.settings_rounded,
            expandedHeight: 120,
            showCollapsedAppBar: _showCollapsedAppBar,
            animationController: _heroAnimationController,
            fadeAnimation: _heroFadeAnimation,
            slideAnimation: _heroSlideAnimation,
          ),

          // Settings Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAccountSection(context, l10n),
                const SizedBox(height: 20),
                _buildLanguageSection(context, l10n),
                const SizedBox(height: 20),
                const ThemeSelectionWidget(),
                const SizedBox(height: 20),
                _buildAppInfoSection(context, l10n),
                const Gap(100), // Extra padding at bottom for better scrolling
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.choosePreferredLanguage,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context)
                            .withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context
                              .read<LanguageBloc>()
                              .add(ChangeLanguage(locale));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surface(context)
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : AppColors.border(context)
                                      .withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardBackground(context),
                  AppColors.cardBackground(context).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.account,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.manageUserAccount,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context)
                                  .withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardBackground(context),
                  AppColors.cardBackground(context).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.account,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.signInToSaveFavorites,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context)
                                  .withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appInfo,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.appInformation,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context)
                            .withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
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
          const Gap(8),
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
