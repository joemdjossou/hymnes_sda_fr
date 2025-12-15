import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/utils/error_handler.dart';
import 'package:hymnes_sda_fr/features/auth/bloc/auth_bloc.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/custom_toast.dart';
import '../../shared/widgets/modern_sliver_app_bar.dart';
import '../widgets/home_widgets/glass_navigation_bar.dart';
import '../widgets/settings_widgets/account_section_widget.dart';
import '../widgets/settings_widgets/app_info_section_widget.dart';
import '../widgets/settings_widgets/feedback_section_widget.dart';
import '../widgets/settings_widgets/hymns_data_section_widget.dart';
import '../widgets/settings_widgets/language_section_widget.dart';
import '../widgets/settings_widgets/notification_section_widget.dart';
import '../widgets/settings_widgets/theme_selection_widget.dart';

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
    if (!mounted) return;
    // Show collapsed app bar when scrolled past the hero section (around 80px)
    final shouldShow = _scrollController.offset > 70;
    if (shouldShow != _showCollapsedAppBar) {
      setState(() {
        _showCollapsedAppBar = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _heroAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'v${packageInfo.version}';
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      // Keep default values if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle account deletion success
        if (state is AccountDeleted) {
          ToastService.showSuccess(
            context,
            title: l10n.success,
            message: l10n.deleteAccountSuccess,
          );
        } else if (state is AuthError) {
          // Handle account deletion error
          ToastService.showError(
            context,
            title: l10n.error,
            message: state.message.contains('deleteAccount') ||
                    state.message.contains('delete')
                ? l10n.deleteAccountError
                : ErrorHandler.getLocalizedErrorMessage(state.message, l10n),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Stack(
          children: [
            CustomScrollView(
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
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const AccountSectionWidget(),
                      const Gap(20),
                      const LanguageSectionWidget(),
                      const Gap(20),
                      const NotificationSectionWidget(),
                      const Gap(20),
                      const ThemeSelectionWidget(),
                      const Gap(20),
                      const FeedbackSectionWidget(),
                      const Gap(20),
                      if (kDebugMode) ...[
                        const HymnsDataSectionWidget(),
                        const Gap(20),
                      ],
                      AppInfoSectionWidget(
                        appVersion: _appVersion,
                        buildNumber: _buildNumber,
                      ),
                      const Gap(20),
                      const Gap(
                          100), // Extra padding at bottom for better scrolling
                    ]),
                  ),
                ),
              ],
            ),
            // Glass Navigation Bar
            const GlassNavigationBar(),
          ],
        ),
      ),
    );
  }
}
