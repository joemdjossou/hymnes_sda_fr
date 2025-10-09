import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/services/sabbath_reminder_service.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';

import '../../../shared/constants/app_colors.dart';

class NotificationSectionWidget extends StatefulWidget {
  const NotificationSectionWidget({super.key});

  @override
  State<NotificationSectionWidget> createState() =>
      _NotificationSectionWidgetState();
}

class _NotificationSectionWidgetState extends State<NotificationSectionWidget> {
  final SabbathReminderService _sabbathReminderService =
      SabbathReminderService();
  bool _sabbathReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSabbathReminderSetting();
  }

  void _loadSabbathReminderSetting() {
    _sabbathReminderEnabled =
        _sabbathReminderService.getSabbathReminderEnabled();
  }

  Future<void> _initializeSabbathReminder(AppLocalizations l10n) async {
    await _sabbathReminderService.initializeSabbathReminder(l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Initialize Sabbath reminder on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSabbathReminder(l10n);
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_rounded,
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
                      l10n.notifications,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      l10n.manageNotificationPreferences,
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
          const Gap(20),
          const Gap(12),
          _buildSabbathReminderOption(
            context,
            l10n.weeklySabbathReminder,
            l10n.weeklySabbathReminderDescription,
            Icons.calendar_today_rounded,
            _sabbathReminderEnabled,
            (value) async {
              setState(() {
                _sabbathReminderEnabled = value;
              });

              // Use the Sabbath reminder service to handle the toggle
              await _sabbathReminderService.toggleSabbathReminder(value, l10n);
            },
          ),
          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildSabbathReminderOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        AppColors.textSecondary(context).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textSecondary(context),
            inactiveTrackColor:
                AppColors.textSecondary(context).withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
