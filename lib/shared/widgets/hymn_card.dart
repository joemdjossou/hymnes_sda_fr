// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/hymn.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../constants/app_colors.dart';

class HymnCard extends StatelessWidget {
  final Hymn hymn;
  final VoidCallback onTap;

  const HymnCard({
    super.key,
    required this.hymn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state is FavoritesLoaded
            ? state.favoriteStatus[hymn.number] ?? false
            : false;

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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hymn.author,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hymn.style,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Favorite Button
                  IconButton(
                    onPressed: () {
                      context.read<FavoritesBloc>().add(ToggleFavorite(hymn));
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? AppColors.favorite
                          : AppColors.textSecondary(context),
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
      },
    );
  }
}
