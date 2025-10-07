import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'app_routes.dart';

/// Service for programmatic navigation throughout the app
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// Navigate to a specific route
  static void go(String route) {
    GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).go(route);
  }

  /// Navigate to a specific route and replace current route
  static void goNamed(String name,
      {Map<String, String>? pathParameters,
      Map<String, dynamic>? queryParameters}) {
    GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).goNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
    );
  }

  /// Push a new route onto the stack
  static void push(String route) {
    GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).push(route);
  }

  /// Push a named route onto the stack
  static void pushNamed(String name,
      {Map<String, String>? pathParameters,
      Map<String, dynamic>? queryParameters}) {
    GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).pushNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
    );
  }

  /// Pop the current route
  static void pop([dynamic result]) {
    GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).pop(result);
  }

  /// Check if we can pop the current route
  static bool canPop() {
    return GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).canPop();
  }

  /// Pop until a specific route
  static void popUntil(String route) {
    GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).go(route);
  }

  /// Replace the current route
  static void replace(String route) {
    GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).go(route);
  }

  // ========== Specific Navigation Methods ==========

  /// Navigate to splash screen
  static void toSplash() {
    go(AppRoutes.splash);
  }

  /// Navigate to onboarding
  static void toOnboarding() {
    go(AppRoutes.onboarding);
  }

  /// Navigate to login
  static void toLogin() {
    go(AppRoutes.login);
  }

  /// Navigate to signup
  static void toSignup() {
    go(AppRoutes.signup);
  }

  /// Navigate to forgot password
  static void toForgotPassword() {
    go(AppRoutes.forgotPassword);
  }

  /// Navigate to home
  static void toHome() {
    go(AppRoutes.home);
  }

  /// Navigate to search
  static void toSearch({String? query}) {
    if (query != null && query.isNotEmpty) {
      go(AppRoutes.getSearchRoute(query));
    } else {
      go(AppRoutes.search);
    }
  }

  /// Navigate to favorites
  static void toFavorites() {
    go(AppRoutes.favorites);
  }

  /// Navigate to settings
  static void toSettings() {
    go(AppRoutes.settings);
  }

  /// Navigate to hymn detail from home
  static void toHymnDetailFromHome(String hymnNumber) {
    go(AppRoutes.getHomeHymnDetailRoute(hymnNumber));
  }

  /// Navigate to hymn detail from search
  static void toHymnDetailFromSearch(String hymnNumber) {
    go(AppRoutes.getSearchHymnDetailRoute(hymnNumber));
  }

  /// Navigate to hymn detail from favorites
  static void toHymnDetailFromFavorites(String hymnNumber) {
    go(AppRoutes.getFavoritesHymnDetailRoute(hymnNumber));
  }

  /// Navigate to hymn detail (generic)
  static void toHymnDetail(String hymnNumber, {String? from}) {
    switch (from) {
      case 'home':
        toHymnDetailFromHome(hymnNumber);
        break;
      case 'search':
        toHymnDetailFromSearch(hymnNumber);
        break;
      case 'favorites':
        toHymnDetailFromFavorites(hymnNumber);
        break;
      default:
        toHymnDetailFromHome(hymnNumber);
    }
  }

  /// Navigate to main tab by index
  static void toMainTab(int index) {
    final route = AppRoutes.getMainTabRoute(index);
    go(route);
  }

  /// Navigate to main tab by name
  static void toMainTabByName(String tabName) {
    switch (tabName.toLowerCase()) {
      case 'home':
        toHome();
        break;
      case 'search':
        toSearch();
        break;
      case 'favorites':
        toFavorites();
        break;
      case 'settings':
        toSettings();
        break;
      default:
        toHome();
    }
  }

  /// Get current route location
  static String getCurrentLocation() {
    return GoRouter.of(AppRouter.rootNavigatorKey.currentContext!).routerDelegate.currentConfiguration.uri.path;
  }

  /// Get current route name
  static String? getCurrentRouteName() {
    return GoRouter.of(AppRouter.rootNavigatorKey.currentContext!)
        .routeInformationProvider
        .value
        .uri
        .path;
  }

  /// Check if current route is a main tab
  static bool isMainTabRoute() {
    final location = getCurrentLocation();
    return AppRoutes.isMainTabRoute(location);
  }

  /// Get current main tab index
  static int getCurrentMainTabIndex() {
    final location = getCurrentLocation();
    return AppRoutes.getMainTabIndex(location);
  }

  /// Navigate back to previous route
  static void back() {
    if (canPop()) {
      pop();
    } else {
      toHome();
    }
  }

  /// Clear navigation stack and go to home
  static void clearStackAndGoHome() {
    go(AppRoutes.home);
  }

  /// Clear navigation stack and go to login
  static void clearStackAndGoLogin() {
    go(AppRoutes.login);
  }

  /// Show a dialog and handle navigation
  static Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = false,
  }) {
    return showDialog<T>(
      context: AppRouter.rootNavigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      builder: (context) => child,
    );
  }

  /// Show a bottom sheet and handle navigation
  static Future<T?> showBottomSheet<T>({
    required Widget child,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = false,
  }) {
    return showModalBottomSheet<T>(
      context: AppRouter.rootNavigatorKey.currentContext!,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      builder: (context) => child,
    );
  }
}
