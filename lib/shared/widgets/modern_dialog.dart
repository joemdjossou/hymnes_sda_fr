import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';

/// A modern, reusable dialog widget with customizable content and actions
class ModernDialog extends StatefulWidget {
  /// The icon to display at the top of the dialog
  final IconData? icon;

  /// The color of the icon (defaults to primary color)
  final Color? iconColor;

  /// The background color of the icon circle
  final Color? iconBackgroundColor;

  /// The title text of the dialog
  final String title;

  /// The description text of the dialog
  final String description;

  /// The primary action button text
  final String primaryButtonText;

  /// The secondary action button text (optional)
  final String? secondaryButtonText;

  /// Callback for primary button press
  final VoidCallback? onPrimaryPressed;

  /// Callback for secondary button press
  final VoidCallback? onSecondaryPressed;

  /// Whether to show the close button (X) in the top right
  final bool showCloseButton;

  /// Custom close button callback
  final VoidCallback? onClosePressed;

  /// Whether the primary button should be destructive (red color)
  final bool isDestructive;

  /// Custom dialog width
  final double? width;

  /// Custom dialog height
  final double? height;

  const ModernDialog({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.showCloseButton = true,
    this.onClosePressed,
    this.isDestructive = false,
    this.width,
    this.height,
  });

  @override
  State<ModernDialog> createState() => _ModernDialogState();

  /// Show the dialog with a notification style (bell icon)
  static Future<T?> showNotification<T>({
    required BuildContext context,
    required String title,
    required String description,
    required String primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showCloseButton = true,
    VoidCallback? onClosePressed,
    double? width,
    double? height,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernDialog(
        icon: Icons.notifications_outlined,
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showCloseButton: showCloseButton,
        onClosePressed: onClosePressed,
        width: width,
        height: height,
      ),
    );
  }

  /// Show the dialog with a confirmation style (question mark icon)
  static Future<T?> showConfirmation<T>({
    required BuildContext context,
    required String title,
    required String description,
    required String primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showCloseButton = true,
    VoidCallback? onClosePressed,
    bool isDestructive = false,
    double? width,
    double? height,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernDialog(
        icon: Icons.help_outline,
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showCloseButton: showCloseButton,
        onClosePressed: onClosePressed,
        isDestructive: isDestructive,
        width: width,
        height: height,
      ),
    );
  }

  /// Show the dialog with an info style (info icon)
  static Future<T?> showInfo<T>({
    required BuildContext context,
    required String title,
    required String description,
    required String primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showCloseButton = true,
    VoidCallback? onClosePressed,
    double? width,
    double? height,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernDialog(
        icon: Icons.info_outline,
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showCloseButton: showCloseButton,
        onClosePressed: onClosePressed,
        width: width,
        height: height,
      ),
    );
  }

  /// Show the dialog with a warning style (warning icon)
  static Future<T?> showWarning<T>({
    required BuildContext context,
    required String title,
    required String description,
    required String primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showCloseButton = true,
    VoidCallback? onClosePressed,
    double? width,
    double? height,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernDialog(
        icon: Icons.warning_outlined,
        iconColor: AppColors.warning,
        iconBackgroundColor: AppColors.warning.withValues(alpha: 0.1),
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showCloseButton: showCloseButton,
        onClosePressed: onClosePressed,
        width: width,
        height: height,
      ),
    );
  }

  /// Show the dialog with an error style (error icon)
  static Future<T?> showError<T>({
    required BuildContext context,
    required String title,
    required String description,
    required String primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showCloseButton = true,
    VoidCallback? onClosePressed,
    double? width,
    double? height,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernDialog(
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showCloseButton: showCloseButton,
        onClosePressed: onClosePressed,
        width: width,
        height: height,
      ),
    );
  }

  /// Show the dialog with a success style (check icon)
  static Future<T?> showSuccess<T>({
    required BuildContext context,
    required String title,
    required String description,
    required String primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showCloseButton = true,
    VoidCallback? onClosePressed,
    double? width,
    double? height,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernDialog(
        icon: Icons.check_circle_outline,
        iconColor: AppColors.success,
        iconBackgroundColor: AppColors.success.withValues(alpha: 0.1),
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showCloseButton: showCloseButton,
        onClosePressed: onClosePressed,
        width: width,
        height: height,
      ),
    );
  }
}

class _ModernDialogState extends State<ModernDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _iconController;
  late AnimationController _slideController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Initialize animations
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations with staggered timing
    _startAnimations();
  }

  void _startAnimations() {
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _iconController.forward();
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _iconController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handlePrimaryPressed() {
    HapticFeedback.lightImpact();
    widget.onPrimaryPressed?.call();
  }

  void _handleSecondaryPressed() {
    HapticFeedback.lightImpact();
    widget.onSecondaryPressed?.call();
  }

  void _handleClosePressed() {
    HapticFeedback.lightImpact();
    if (widget.onClosePressed != null) {
      widget.onClosePressed!();
    } else {
      // Default behavior: close the dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeAnimation,
        _iconAnimation,
        _slideAnimation,
      ]),
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: widget.width ?? 320,
                height: widget.height,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.cardBackground(context),
                      AppColors.cardBackground(context).withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: (widget.isDestructive
                              ? AppColors.error
                              : AppColors.primary)
                          .withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Animated background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DialogBackgroundPainter(
                          color: (widget.isDestructive
                                  ? AppColors.error
                                  : AppColors.primary)
                              .withValues(alpha: 0.03),
                          animation: _fadeAnimation.value,
                        ),
                      ),
                    ),

                    // Close button with animation
                    if (widget.showCloseButton)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _AnimatedCloseButton(
                              onPressed: _handleClosePressed,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ),

                    // Main content with staggered animations
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated Icon
                          if (widget.icon != null) ...[
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: _AnimatedIconContainer(
                                  icon: widget.icon!,
                                  iconColor: widget.iconColor ??
                                      (widget.isDestructive
                                          ? AppColors.error
                                          : AppColors.primary),
                                  backgroundColor: widget.iconBackgroundColor ??
                                      (widget.isDestructive
                                          ? AppColors.error
                                              .withValues(alpha: 0.1)
                                          : AppColors.primary
                                              .withValues(alpha: 0.1)),
                                  animation: _iconAnimation,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],

                          // Animated Title
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                widget.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(context),
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Animated Description
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                widget.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary(context),
                                  height: 1.6,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Animated Buttons
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  // Primary button with enhanced styling
                                  _AnimatedButton(
                                    text: widget.primaryButtonText,
                                    isPrimary: true,
                                    isDestructive: widget.isDestructive,
                                    onPressed: _handlePrimaryPressed,
                                    animation: _fadeAnimation,
                                  ),

                                  // Secondary button
                                  if (widget.secondaryButtonText != null) ...[
                                    const SizedBox(height: 16),
                                    _AnimatedButton(
                                      text: widget.secondaryButtonText!,
                                      isPrimary: false,
                                      isDestructive: false,
                                      onPressed: _handleSecondaryPressed,
                                      animation: _fadeAnimation,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for animated background pattern
class _DialogBackgroundPainter extends CustomPainter {
  final Color color;
  final double animation;

  _DialogBackgroundPainter({
    required this.color,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw subtle circular patterns
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3 * animation;

    canvas.drawCircle(
      center,
      radius,
      paint..color = color.withValues(alpha: 0.1 * animation),
    );

    // Draw smaller accent circles
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.2),
      radius * 0.3,
      paint..color = color.withValues(alpha: 0.05 * animation),
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      radius * 0.2,
      paint..color = color.withValues(alpha: 0.05 * animation),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated close button with hover effects
class _AnimatedCloseButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;

  const _AnimatedCloseButton({
    required this.onPressed,
    required this.color,
  });

  @override
  State<_AnimatedCloseButton> createState() => _AnimatedCloseButtonState();
}

class _AnimatedCloseButtonState extends State<_AnimatedCloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: widget.color,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated icon container with bounce effect
class _AnimatedIconContainer extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Animation<double> animation;

  const _AnimatedIconContainer({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  backgroundColor,
                  backgroundColor.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 36,
              color: iconColor,
            ),
          ),
        );
      },
    );
  }
}

/// Animated button with enhanced styling and micro-interactions
class _AnimatedButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onPressed;
  final Animation<double> animation;

  const _AnimatedButton({
    required this.text,
    required this.isPrimary,
    required this.isDestructive,
    required this.onPressed,
    required this.animation,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isDestructive ? AppColors.error : AppColors.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, widget.animation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            child: widget.isPrimary
                ? ElevatedButton(
                    onPressed: () {
                      _controller.forward().then((_) => _controller.reverse());
                      widget.onPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: backgroundColor.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: () {
                      _controller.forward().then((_) => _controller.reverse());
                      widget.onPressed();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary(context),
                      side: BorderSide(
                        color: AppColors.textPrimary(context),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
