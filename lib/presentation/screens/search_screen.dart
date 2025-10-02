import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/constants/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.search,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          l10n.advancedSearchToBe,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
