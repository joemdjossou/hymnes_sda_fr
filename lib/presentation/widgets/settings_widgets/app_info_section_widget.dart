import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/custom_toast.dart';

class AppInfoSectionWidget extends StatelessWidget {
  final String appVersion;
  final String buildNumber;

  // App store URLs
  static const String _androidAppUrl = AppConstants.playStoreUrl;
  static const String _iosAppUrl = AppConstants.appStoreUrl;

  // Review URLs (direct to review page)
  static const String _androidReviewUrl = AppConstants.androidReviewUrl;
  static const String _iosReviewUrl = AppConstants.iosReviewUrl;

  const AppInfoSectionWidget({
    super.key,
    required this.appVersion,
    required this.buildNumber,
  });

  /// Helper method to get localized string with fallback
  /// This will work once localization files are regenerated
  String _getLocalizedString(
    BuildContext context,
    AppLocalizations l10n,
    String key,
    String englishFallback,
    String frenchFallback,
  ) {
    // Try to access the property using dynamic invocation
    // This is a temporary solution until localization files are regenerated
    try {
      final value = (l10n as dynamic)[key];
      if (value != null && value is String) {
        return value;
      }
    } catch (_) {
      // Ignore errors and use fallback
    }

    // Fallback based on current locale
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'fr' ? frenchFallback : englishFallback;
  }

  Future<void> _openReviewPage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Try to open the review URL (market:// for Android, App Store for iOS)
      Uri reviewUrl;
      if (Platform.isAndroid) {
        reviewUrl = Uri.parse(_androidReviewUrl);
        // If market:// fails, fallback to web URL
        if (!await canLaunchUrl(reviewUrl)) {
          reviewUrl = Uri.parse(_androidAppUrl);
        }
      } else {
        reviewUrl = Uri.parse(_iosReviewUrl);
      }

      if (await canLaunchUrl(reviewUrl)) {
        await launchUrl(reviewUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web URL
        final fallbackUrl = Platform.isAndroid
            ? Uri.parse(_androidAppUrl)
            : Uri.parse(_iosAppUrl);
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ToastService.showError(
              context,
              title: l10n.error,
              message: 'Cannot open app store',
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(
          context,
          title: l10n.error,
          message: 'Failed to open app store: $e',
        );
      }
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final shareUrl = Platform.isAndroid ? _androidAppUrl : _iosAppUrl;
      // Use localized message - will work once localization files are regenerated
      String shareText;
      try {
        // Try to call the method using dynamic invocation
        final method = (l10n as dynamic).shareAppMessage;
        if (method != null) {
          shareText = method(shareUrl) as String;
        } else {
          throw Exception('Method not found');
        }
      } catch (_) {
        // Fallback if localization not yet generated
        final locale = Localizations.localeOf(context);
        if (locale.languageCode == 'fr') {
          shareText =
              "Découvrez cette application incroyable d'Hymnes Adventistes ! 🎵🙏\n\n$shareUrl";
        } else {
          shareText =
              'Check out this amazing Adventist Hymns app! 🎵🙏\n\n$shareUrl';
        }
      }

      // For iOS, we need to provide the share position origin
      if (Platform.isIOS) {
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin =
            box != null ? box.localToGlobal(Offset.zero) & box.size : null;

        await Share.share(
          shareText,
          subject: 'Hymnes et Louanges Adventiste',
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        // Android doesn't need sharePositionOrigin
        await Share.share(
          shareText,
          subject: 'Hymnes et Louanges Adventiste',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(
          context,
          title: l10n.error,
          message: 'Failed to share app: $e',
        );
        Logger().d('Failed to share app: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding - 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius:
                      BorderRadius.circular(AppConstants.mediumBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appInfo,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      l10n.appInformation,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context)
                            .withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.version,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      AppColors.textSecondary(context).withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                appVersion,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.buildNumber,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      AppColors.textSecondary(context).withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                buildNumber,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const Gap(24),
          // Action Buttons
          Row(
            children: [
              // Review Button
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.star_outline_rounded,
                  label: _getLocalizedString(
                      context, l10n, 'review', 'Review', 'Noter'),
                  onTap: () => _openReviewPage(context),
                  gradient: AppColors.primaryGradient(context),
                ),
              ),
              const Gap(12),
              // Share Button
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.share_rounded,
                  label: _getLocalizedString(
                      context, l10n, 'share', 'Share', 'Partager'),
                  onTap: () => _shareApp(context),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const Gap(8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
