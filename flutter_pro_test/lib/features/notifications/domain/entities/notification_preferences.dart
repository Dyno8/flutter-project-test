import 'package:equatable/equatable.dart';
import 'notification.dart';

/// Notification preferences entity for managing user notification settings
class NotificationPreferences extends Equatable {
  final String userId;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final Map<NotificationCategory, bool> categoryPreferences;
  final Map<NotificationPriority, bool> priorityPreferences;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showOnLockScreen;
  final bool showPreview;
  final String? quietHoursStart; // Format: "HH:mm"
  final String? quietHoursEnd; // Format: "HH:mm"
  final bool quietHoursEnabled;
  final List<String> mutedTypes;
  final DateTime updatedAt;

  const NotificationPreferences({
    required this.userId,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.smsNotificationsEnabled,
    required this.categoryPreferences,
    required this.priorityPreferences,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.showOnLockScreen,
    required this.showPreview,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.quietHoursEnabled,
    required this.mutedTypes,
    required this.updatedAt,
  });

  /// Create default notification preferences
  factory NotificationPreferences.defaultPreferences(String userId) {
    return NotificationPreferences(
      userId: userId,
      pushNotificationsEnabled: true,
      emailNotificationsEnabled: true,
      smsNotificationsEnabled: false,
      categoryPreferences: {
        NotificationCategory.booking: true,
        NotificationCategory.job: true,
        NotificationCategory.payment: true,
        NotificationCategory.system: true,
        NotificationCategory.promotion: false,
        NotificationCategory.reminder: true,
        NotificationCategory.social: true,
      },
      priorityPreferences: {
        NotificationPriority.low: true,
        NotificationPriority.normal: true,
        NotificationPriority.high: true,
        NotificationPriority.urgent: true,
      },
      soundEnabled: true,
      vibrationEnabled: true,
      showOnLockScreen: true,
      showPreview: true,
      quietHoursStart: null,
      quietHoursEnd: null,
      quietHoursEnabled: false,
      mutedTypes: [],
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  NotificationPreferences copyWith({
    String? userId,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    Map<NotificationCategory, bool>? categoryPreferences,
    Map<NotificationPriority, bool>? priorityPreferences,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showOnLockScreen,
    bool? showPreview,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? quietHoursEnabled,
    List<String>? mutedTypes,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      userId: userId ?? this.userId,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      categoryPreferences: categoryPreferences ?? this.categoryPreferences,
      priorityPreferences: priorityPreferences ?? this.priorityPreferences,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showOnLockScreen: showOnLockScreen ?? this.showOnLockScreen,
      showPreview: showPreview ?? this.showPreview,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      mutedTypes: mutedTypes ?? this.mutedTypes,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if a notification should be shown based on preferences
  bool shouldShowNotification(NotificationEntity notification) {
    // Check if push notifications are enabled
    if (!pushNotificationsEnabled) return false;

    // Check category preferences
    if (!categoryPreferences[notification.category]!) return false;

    // Check priority preferences
    if (!priorityPreferences[notification.priority]!) return false;

    // Check if type is muted
    if (mutedTypes.contains(notification.type)) return false;

    // Check quiet hours
    if (quietHoursEnabled && _isInQuietHours()) {
      // Only show urgent notifications during quiet hours
      return notification.priority == NotificationPriority.urgent;
    }

    return true;
  }

  /// Check if current time is within quiet hours
  bool _isInQuietHours() {
    if (!quietHoursEnabled || quietHoursStart == null || quietHoursEnd == null) {
      return false;
    }

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Handle cases where quiet hours span midnight
    if (quietHoursStart!.compareTo(quietHoursEnd!) > 0) {
      return currentTime.compareTo(quietHoursStart!) >= 0 || 
             currentTime.compareTo(quietHoursEnd!) <= 0;
    } else {
      return currentTime.compareTo(quietHoursStart!) >= 0 && 
             currentTime.compareTo(quietHoursEnd!) <= 0;
    }
  }

  /// Toggle category preference
  NotificationPreferences toggleCategory(NotificationCategory category) {
    final newPreferences = Map<NotificationCategory, bool>.from(categoryPreferences);
    newPreferences[category] = !newPreferences[category]!;
    return copyWith(categoryPreferences: newPreferences);
  }

  /// Toggle priority preference
  NotificationPreferences togglePriority(NotificationPriority priority) {
    final newPreferences = Map<NotificationPriority, bool>.from(priorityPreferences);
    newPreferences[priority] = !newPreferences[priority]!;
    return copyWith(priorityPreferences: newPreferences);
  }

  /// Mute notification type
  NotificationPreferences muteType(String type) {
    if (mutedTypes.contains(type)) return this;
    final newMutedTypes = List<String>.from(mutedTypes)..add(type);
    return copyWith(mutedTypes: newMutedTypes);
  }

  /// Unmute notification type
  NotificationPreferences unmuteType(String type) {
    if (!mutedTypes.contains(type)) return this;
    final newMutedTypes = List<String>.from(mutedTypes)..remove(type);
    return copyWith(mutedTypes: newMutedTypes);
  }

  /// Set quiet hours
  NotificationPreferences setQuietHours({
    required String start,
    required String end,
    required bool enabled,
  }) {
    return copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
      quietHoursEnabled: enabled,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        pushNotificationsEnabled,
        emailNotificationsEnabled,
        smsNotificationsEnabled,
        categoryPreferences,
        priorityPreferences,
        soundEnabled,
        vibrationEnabled,
        showOnLockScreen,
        showPreview,
        quietHoursStart,
        quietHoursEnd,
        quietHoursEnabled,
        mutedTypes,
        updatedAt,
      ];
}
