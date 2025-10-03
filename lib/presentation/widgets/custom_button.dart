import 'package:flutter/material.dart';

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
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ButtonVariant.filled ? onPrimaryColor : primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color:
                variant == ButtonVariant.filled ? onPrimaryColor : primaryColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color:
                variant == ButtonVariant.filled ? onPrimaryColor : primaryColor,
            fontWeight: FontWeight.w600,
            fontFamily: 'Raleway',
          ),
        ),
      ],
    );

    switch (variant) {
      case ButtonVariant.filled:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: onPrimaryColor,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.outlined:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.text:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }
}
