import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/navigation/navigation_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  int _currentPage = 0;
  final int _totalPages = 4;

  List<OnboardingData> _getPages(AppLocalizations l10n) => [
        OnboardingData(
          title: l10n.welcomeToHymnes,
          subtitle: l10n.discoverSacredMusic,
          description: l10n.welcomeDescription,
          icon: Icons.music_note,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          particles: 50,
        ),
        OnboardingData(
          title: l10n.searchAndDiscover,
          subtitle: l10n.findYourFavorites,
          description: l10n.searchDescription,
          icon: Icons.search,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
          ),
          particles: 40,
        ),
        OnboardingData(
          title: l10n.midiPlayback,
          subtitle: l10n.highQualityAudio,
          description: l10n.midiDescription,
          icon: Icons.play_circle_fill,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
          ),
          particles: 60,
        ),
        OnboardingData(
          title: l10n.favoritesAndHistory,
          subtitle: l10n.personalCollection,
          description: l10n.favoritesDescription,
          icon: Icons.favorite,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          ),
          particles: 45,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      NavigationService.toHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;
    final pages = _getPages(l10n);

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: pages[_currentPage].gradient,
            ),
            child: CustomPaint(
              painter: ParticlesPainter(
                particles: pages[_currentPage].particles,
                animationValue: _animationController.value,
              ),
              size: size,
            ),
          ),

          // Main Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              return _buildPage(pages[index], size);
            },
          ),

          // Top Navigation
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                AnimatedOpacity(
                  opacity: _currentPage < _totalPages - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _skipOnboarding,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        l10n.skip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page Indicators
                Row(
                  children: List.generate(
                    _totalPages,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 20,
            right: 20,
            child: _buildBottomNavigation(l10n, pages),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Animated Icon
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(70),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          // Animated Text Content
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      // Subtitle
                      Text(
                        data.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Gap(16),

                      // Title
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Gap(24),

                      // Description
                      Text(
                        data.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(
      AppLocalizations l10n, List<OnboardingData> pages) {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _buttonAnimationController.forward(),
            onTapUp: (_) => _buttonAnimationController.reverse(),
            onTapCancel: () => _buttonAnimationController.reverse(),
            onTap: _nextPage,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage < _totalPages - 1
                        ? l10n.continue_
                        : l10n.getStarted,
                    style: TextStyle(
                      color: pages[_currentPage].gradient.colors.first,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Icon(
                    _currentPage < _totalPages - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                    color: pages[_currentPage].gradient.colors.first,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final int particles;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.particles,
  });
}

class ParticlesPainter extends CustomPainter {
  final int particles;
  final double animationValue;

  ParticlesPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particles; i++) {
      final x = (i * 137.5) % size.width;
      final y = (i * 73.3) % size.height;
      final radius = (i % 3 + 1) * animationValue;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
