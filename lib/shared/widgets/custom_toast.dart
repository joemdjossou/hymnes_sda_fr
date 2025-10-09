import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';

import '../constants/app_colors.dart';

enum ToastType {
  error,
  warning,
  success,
  info,
}

class CustomToast extends StatefulWidget {
  final String title;
  final String message;
  final ToastType type;
  final VoidCallback? onClose;
  final Duration? duration;

  const CustomToast({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onClose,
    this.duration,
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration ?? const Duration(seconds: 4),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main content
          IntrinsicHeight(
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _getAccentColor(isDark),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getAccentColor(isDark),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const Gap(12),
                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                widget.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close button
                        if (widget.onClose != null)
                          GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Animated progress bar
          if (widget.duration != null)
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getAccentColor(isDark).withValues(alpha: 0.3),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getAccentColor(bool isDark) {
    switch (widget.type) {
      case ToastType.error:
        return isDark ? const Color(0xFFE53E3E) : const Color(0xFFF56565);
      case ToastType.warning:
        return isDark ? const Color(0xFFDD6B20) : const Color(0xFFED8936);
      case ToastType.success:
        return isDark ? const Color(0xFF38A169) : const Color(0xFF68D391);
      case ToastType.info:
        return isDark ? const Color(0xFF3182CE) : const Color(0xFF63B3ED);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}

class ToastService {
  static void showToast(
    BuildContext context, {
    required String title,
    required String message,
    required ToastType type,
    Duration? duration,
    VoidCallback? onClose,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: CustomToast(
            title: title,
            message: message,
            type: type,
            onClose: () {
              overlayEntry.remove();
              onClose?.call();
            },
            duration: duration,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after duration
    if (duration != null) {
      Future.delayed(duration, () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    }
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onClose,
  }) {
    showToast(
      context,
      title: title,
      message: message,
      type: ToastType.error,
      duration: duration ?? const Duration(seconds: 4),
      onClose: onClose,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onClose,
  }) {
    showToast(
      context,
      title: title,
      message: message,
      type: ToastType.warning,
      duration: duration ?? const Duration(seconds: 4),
      onClose: onClose,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onClose,
  }) {
    showToast(
      context,
      title: title,
      message: message,
      type: ToastType.success,
      duration: duration ?? const Duration(seconds: 3),
      onClose: onClose,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onClose,
  }) {
    showToast(
      context,
      title: title,
      message: message,
      type: ToastType.info,
      duration: duration ?? const Duration(seconds: 4),
      onClose: onClose,
    );
  }

  /// Demo method to showcase all toast types with animated progress bars
  static void showDemoToasts(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Show error toast
    showError(
      context,
      title: l10n.somethingWentWrong,
      message: l10n.couldNotProcessRequest,
      duration: const Duration(seconds: 5),
    );

    // Show warning toast after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      showWarning(
        context,
        title: l10n.actionRequired,
        message: l10n.checkSettingsBeforeProceeding,
        duration: const Duration(seconds: 4),
      );
    });

    // Show success toast after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      showSuccess(
        context,
        title: l10n.actionCompleted,
        message: l10n.changesSavedSuccessfully,
        duration: const Duration(seconds: 3),
      );
    });

    // Show info toast after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      showInfo(
        context,
        title: l10n.justSoYouKnow,
        message: l10n.loggedInOverHour,
        duration: const Duration(seconds: 4),
      );
    });
  }
}
