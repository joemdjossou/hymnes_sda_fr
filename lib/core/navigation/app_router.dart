import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/forgot_password_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/hymn_detail_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/main_navigation_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/signup_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import 'app_routes.dart';

/// Main router configuration for the app
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  static GlobalKey<NavigatorState> get shellNavigatorKey => _shellNavigatorKey;

  /// Main router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Flow
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Flow
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          // Home Tab
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.homeName,
            builder: (context, state) => const HomeScreen(),
            routes: [
              // Hymn Detail (nested under home)
              GoRoute(
                path: AppRoutes.hymnDetail,
                name: AppRoutes.hymnDetailName,
                builder: (context, state) {
                  final hymnNumber = state.pathParameters['hymnNumber']!;
                  return HymnDetailScreen(hymnId: hymnNumber);
                },
              ),
            ],
          ),

          // Search Tab
          GoRoute(
            path: AppRoutes.search,
            name: AppRoutes.searchName,
            builder: (context, state) => const SearchScreen(),
            routes: [
              // Hymn Detail (nested under search)
              GoRoute(
                path: AppRoutes.hymnDetail,
                name: AppRoutes.hymnDetailFromSearchName,
                builder: (context, state) {
                  final hymnNumber = state.pathParameters['hymnNumber']!;
                  return HymnDetailScreen(hymnId: hymnNumber);
                },
              ),
            ],
          ),

          // Favorites Tab
          GoRoute(
            path: AppRoutes.favorites,
            name: AppRoutes.favoritesName,
            builder: (context, state) => const FavoritesScreen(),
            routes: [
              // Hymn Detail (nested under favorites)
              GoRoute(
                path: AppRoutes.hymnDetail,
                name: AppRoutes.hymnDetailFromFavoritesName,
                builder: (context, state) {
                  final hymnNumber = state.pathParameters['hymnNumber']!;
                  return HymnDetailScreen(hymnId: hymnNumber);
                },
              ),
            ],
          ),

          // Settings Tab
          GoRoute(
            path: AppRoutes.settings,
            name: AppRoutes.settingsName,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Handle redirects based on authentication and onboarding status
  static Future<String?> _handleRedirect(
      BuildContext context, GoRouterState state) async {
    final location = state.uri.path;
    
    // Skip redirect for splash screen
    if (location == AppRoutes.splash) {
      return null;
    }

    // Check if onboarding is complete
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    // If onboarding is not complete, redirect to onboarding
    if (!isOnboardingComplete && location != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    // Check authentication status
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    // If user is not authenticated and trying to access protected routes
    if (authState is! Authenticated && _isProtectedRoute(location)) {
      return AppRoutes.login;
    }

    // If user is authenticated and trying to access auth routes
    if (authState is Authenticated && _isAuthRoute(location)) {
      return AppRoutes.home;
    }

    return null;
  }

  /// Check if a route is protected (requires authentication)
  static bool _isProtectedRoute(String location) {
    const protectedRoutes = [
      AppRoutes.home,
      AppRoutes.search,
      AppRoutes.favorites,
      AppRoutes.settings,
    ];

    return protectedRoutes.any((route) => location.startsWith(route));
  }

  /// Check if a route is an authentication route
  static bool _isAuthRoute(String location) {
    const authRoutes = [
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
    ];

    return authRoutes.contains(location);
  }
}
