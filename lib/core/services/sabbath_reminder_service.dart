import 'package:hymnes_sda_fr/core/services/notification_service.dart';
import 'package:hymnes_sda_fr/core/services/storage_service.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';

class SabbathReminderService {
  static final SabbathReminderService _instance =
      SabbathReminderService._internal();
  factory SabbathReminderService() => _instance;
  SabbathReminderService._internal();

  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  static const String _sabbathReminderKey = 'sabbath_reminder_enabled';

  /// Get the current Sabbath reminder setting
  bool getSabbathReminderEnabled() {
    return _storageService.getSetting<bool>(_sabbathReminderKey,
            defaultValue: true) ??
        true;
  }

  /// Save the Sabbath reminder setting
  Future<void> setSabbathReminderEnabled(bool enabled) async {
    await _storageService.saveSetting(_sabbathReminderKey, enabled);
  }

  /// Toggle the Sabbath reminder and handle notification scheduling
  Future<void> toggleSabbathReminder(
      bool enabled, AppLocalizations l10n) async {
    // Save the setting
    await setSabbathReminderEnabled(enabled);

    if (enabled) {
      // Schedule weekly reminder for Friday at 6:00 PM
      await _notificationService.scheduleWeeklyReminder(
        title: l10n.sabbathReminderTitle,
        body: l10n.sabbathReminderBody,
        weekday: DateTime.friday,
        hour: 18, // 6:00 PM
        minute: 0,
      );
    } else {
      // Cancel the weekly reminder
      await _notificationService.cancelWeeklyReminder();
    }
  }

  /// Initialize Sabbath reminder on app startup
  Future<void> initializeSabbathReminder(AppLocalizations l10n) async {
    final isEnabled = getSabbathReminderEnabled();

    if (isEnabled) {
      // Schedule the reminder if it's enabled
      await _notificationService.scheduleWeeklyReminder(
        title: l10n.sabbathReminderTitle,
        body: l10n.sabbathReminderBody,
        weekday: DateTime.friday,
        hour: 18, // 6:00 PM
        minute: 0,
      );
    }
  }
}
