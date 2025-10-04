import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textHint(context),
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textHint(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppColors.textHint(context),
                      size: 20,
                    ),
                    onPressed: onClear,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}
