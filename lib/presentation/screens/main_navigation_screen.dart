import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/constants/app_colors.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const SearchScreen(),
      const FavoritesScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 8,
            child: _buildGlassNavBar(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNavBar(AppLocalizations l10n) {
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
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
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
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondary(context),
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
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
