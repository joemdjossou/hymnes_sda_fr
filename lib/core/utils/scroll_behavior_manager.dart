import 'dart:async';

/// Manages scroll-based UI behavior (app bar collapse, bottom nav visibility)
/// Follows Single Responsibility Principle
class ScrollBehaviorManager {
  final Function(bool) onCollapsedAppBarChanged;
  final Function(bool) onBottomNavBarVisibilityChanged;
  final double collapsedAppBarThreshold;
  final double scrollThreshold;
  final Duration autoHideDuration;

  double _lastScrollOffset = 0.0;
  Timer? _hideBottomNavBarTimer;
  bool _isBottomNavBarVisible = true;

  ScrollBehaviorManager({
    required this.onCollapsedAppBarChanged,
    required this.onBottomNavBarVisibilityChanged,
    this.collapsedAppBarThreshold = 150.0,
    this.scrollThreshold = 10.0,
    this.autoHideDuration = const Duration(seconds: 5),
  });

  void handleScroll(double currentOffset) {
    // Handle collapsed app bar visibility
    final shouldShowCollapsed = currentOffset > collapsedAppBarThreshold;
    onCollapsedAppBarChanged(shouldShowCollapsed);

    // Handle bottom navigation bar visibility based on scroll direction
    final scrollDelta = currentOffset - _lastScrollOffset;

    if (scrollDelta.abs() > scrollThreshold) {
      if (scrollDelta > 0) {
        // Scrolling down - hide bottom nav bar
        hideBottomNavBar();
      } else {
        // Scrolling up - show bottom nav bar
        showBottomNavBarWithTimer();
      }
    }

    _lastScrollOffset = currentOffset;
  }

  void showBottomNavBarWithTimer() {
    // Cancel existing timer if any
    _hideBottomNavBarTimer?.cancel();

    // Show the bottom nav bar
    if (!_isBottomNavBarVisible) {
      _isBottomNavBarVisible = true;
      onBottomNavBarVisibilityChanged(true);
    }

    // Start timer to auto-hide after specified duration
    _hideBottomNavBarTimer = Timer(autoHideDuration, () {
      if (_isBottomNavBarVisible) {
        hideBottomNavBar();
      }
    });
  }

  void hideBottomNavBar() {
    // Cancel existing timer
    _hideBottomNavBarTimer?.cancel();
    _hideBottomNavBarTimer = null;

    // Hide the bottom nav bar
    if (_isBottomNavBarVisible) {
      _isBottomNavBarVisible = false;
      onBottomNavBarVisibilityChanged(false);
    }
  }

  void dispose() {
    _hideBottomNavBarTimer?.cancel();
    _hideBottomNavBarTimer = null;
  }
}

