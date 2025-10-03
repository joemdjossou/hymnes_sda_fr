import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import '../../core/models/hymn.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/hymn_card.dart';
import '../widgets/auth_required_widget.dart';
import 'hymn_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _onHymnTap(BuildContext context, Hymn hymn) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HymnDetailScreen(hymnId: hymn.number),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          l10n.favorites,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface(context),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: AuthRequiredWidget(
        message: l10n.authenticationRequiredDescription,
        child: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is FavoritesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.textSecondary(context)
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Logger().d('🔔🚀 ${state.message}');
                        context.read<FavoritesBloc>().add(LoadFavorites());
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is FavoritesLoaded) {
              final favorites = state.favorites;

              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppColors.textSecondary(context)
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noFavoritesYet,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addFavoritesDescription,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final hymn = favorites[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HymnCard(
                      hymn: hymn,
                      onTap: () => _onHymnTap(context, hymn),
                    ),
                  );
                },
              );
            }

            return Center(
              child: Text(
                l10n.favoritesToBe,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
