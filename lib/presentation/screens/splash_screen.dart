import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/constants/app_colors.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _loadAppVersion();
    _startAnimations();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version}';
      });
    } catch (e) {
      // Keep default version if there's an error
    }
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      await _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isOnboardingComplete =
          prefs.getBool('onboarding_complete') ?? false;

      if (isOnboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      // If there's an error, default to onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Title
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // App Subtitle
                  Text(
                    l10n.appSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // App version
                  Text(
                    _appVersion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),

                  // Progress bar
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
