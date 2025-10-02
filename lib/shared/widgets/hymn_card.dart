// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../core/models/hymn.dart';
import '../constants/app_colors.dart';

class HymnCard extends StatelessWidget {
  final Hymn hymn;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const HymnCard({
    super.key,
    required this.hymn,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Hymn Number
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    hymn.number,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Hymn Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hymn.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hymn.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hymn.style,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Favorite Button
              IconButton(
                onPressed: onFavoriteToggle,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      isFavorite ? AppColors.favorite : AppColors.textSecondary,
                ),
              ),

              // Play Button
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
