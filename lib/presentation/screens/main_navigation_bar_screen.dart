import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../shared/constants/app_colors.dart';

/// Screen that handles the 4 main tab screens with bottom navigation bar
class MainNavigationBarScreen extends StatefulWidget {
  final Widget child;

  const MainNavigationBarScreen({super.key, required this.child});

  @override
  State<MainNavigationBarScreen> createState() => _MainNavigationBarScreenState();
}

class _MainNavigationBarScreenState extends State<MainNavigationBarScreen>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    // Add observer for keyboard visibility changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    final newKeyboardVisible = bottomInset > 0;

    if (newKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newKeyboardVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocation =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final currentIndex = AppRoutes.getMainTabIndex(currentLocation);

    return Scaffold(
      body: Stack(
        children: [
          // Main content area
          widget.child,
          // Bottom navigation bar - always visible since this screen only handles main tabs
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            left: 20,
            right: 20,
            bottom: _isKeyboardVisible ? -120 : 8,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              opacity: _isKeyboardVisible ? 0.0 : 1.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutBack,
                scale: _isKeyboardVisible ? 0.8 : 1.0,
                child: _buildGlassNavBar(l10n, currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNavBar(AppLocalizations l10n, int currentIndex) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              // Water-like semi-transparent background
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardBackground(context).withValues(alpha: 0.25),
                  AppColors.cardBackground(context).withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              // Subtle border for definition
              border: Border.all(
                color: AppColors.border(context).withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(28),
              // Subtle shadow for depth
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary(context).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGlassNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: l10n.home,
                    index: 0,
                  ),
                  _buildGlassNavItem(
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search_rounded,
                    label: l10n.search,
                    index: 1,
                  ),
                  _buildGlassNavItem(
                    icon: Icons.favorite_outline_rounded,
                    activeIcon: Icons.favorite_rounded,
                    label: l10n.favorites,
                    index: 2,
                  ),
                  _buildGlassNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: l10n.settings,
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final currentLocation =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final currentIndex = AppRoutes.getMainTabIndex(currentLocation);
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          final route = AppRoutes.getMainTabRoute(index);
          context.go(route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  activeIcon,
                  key: ValueKey(isActive),
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondary(context),
                  size: 24,
                ),
              ),
              const Gap(2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondary(context),
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
