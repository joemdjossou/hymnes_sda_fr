import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import 'main_navigation_bar_screen.dart';

/// Main navigation screen that conditionally shows the navbar
/// Only shows navbar on the 4 main tab screens
class MainNavigationScreen extends StatelessWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentLocation =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    
    // Check if we're on one of the main tab screens
    final shouldShowNavBar = _shouldShowNavigationBar(currentLocation);

    if (shouldShowNavBar) {
      // Show the navbar screen for main tabs
      return MainNavigationBarScreen(child: child);
    } else {
      // Show just the content without navbar for other screens
      return Scaffold(body: child);
    }
  }

  /// Check if navigation bar should be shown
  /// Only show on the 4 main tab screens
  bool _shouldShowNavigationBar(String location) {
    const mainTabRoutes = [
      AppRoutes.home,
      AppRoutes.search,
      AppRoutes.favorites,
      AppRoutes.settings,
    ];

    // Check if current location exactly matches a main tab route
    return mainTabRoutes.contains(location);
  }

}
