import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';

class FavoriteButtonShimmer extends StatelessWidget {
  final double size;
  final double iconSize;

  const FavoriteButtonShimmer({
    super.key,
    this.size = 48,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.textSecondary(context).withValues(alpha: 0.1),
      highlightColor: AppColors.textSecondary(context).withValues(alpha: 0.30),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.textSecondary(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.favorite_border_rounded,
          color: AppColors.textSecondary(context).withValues(alpha: 0.4),
          size: iconSize,
        ),
      ),
    );
  }
}
