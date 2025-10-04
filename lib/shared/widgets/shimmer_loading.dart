import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.textSecondary(context).withValues(alpha: 0.1),
      highlightColor: AppColors.textSecondary(context).withValues(alpha: 0.3),
      enabled: enabled,
      child: child,
    );
  }
}

class ShimmerHymnCard extends StatelessWidget {
  const ShimmerHymnCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Hymn Number Shimmer
            ShimmerLoading(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary(context),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content Shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer
                  ShimmerLoading(
                    child: Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Author shimmer
                  ShimmerLoading(
                    child: Container(
                      height: 16,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tags shimmer
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ShimmerLoading(
                        child: Container(
                          height: 20,
                          width: 60,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ShimmerLoading(
                        child: Container(
                          height: 20,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action buttons shimmer
            Column(
              children: [
                ShimmerLoading(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border(context).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            ShimmerLoading(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(
                    child: Container(
                      height: 20,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShimmerLoading(
                    child: Container(
                      height: 14,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerSearchBar extends StatelessWidget {
  const ShimmerSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ShimmerLoading(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.textSecondary(context),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
