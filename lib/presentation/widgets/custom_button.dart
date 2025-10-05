import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../shared/constants/app_colors.dart';

enum ButtonVariant {
  filled,
  outlined,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.filled,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get theme-aware colors
    final primaryColor = AppColors.primary;
    final onPrimaryColor = Colors.white;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ButtonVariant.filled ? onPrimaryColor : primaryColor,
              ),
            ),
          ),
          const Gap(12),
        ] else if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color:
                variant == ButtonVariant.filled ? onPrimaryColor : primaryColor,
          ),
          const Gap(8),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color:
                variant == ButtonVariant.filled ? onPrimaryColor : primaryColor,
            fontWeight: FontWeight.w600,
            fontFamily: 'Raleway',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    switch (variant) {
      case ButtonVariant.filled:
        return Container(
          width: width,
          height: height ?? 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: buttonChild,
              ),
            ),
          ),
        );

      case ButtonVariant.outlined:
        return Container(
          width: width,
          height: height ?? 52,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: buttonChild,
              ),
            ),
          ),
        );

      case ButtonVariant.text:
        return Container(
          width: width,
          height: height ?? 52,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: buttonChild,
              ),
            ),
          ),
        );
    }
  }
}
