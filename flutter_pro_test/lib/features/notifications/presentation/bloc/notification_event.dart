import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_preferences.dart';

/// Base class for notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

// Notification loading events

/// Load user notifications
class LoadUserNotificationsEvent extends NotificationEvent {
  final String userId;
  final int? limit;
  final String? lastNotificationId;

  const LoadUserNotificationsEvent({
    required this.userId,
    this.limit,
    this.lastNotificationId,
  });

  @override
  List<Object?> get props => [userId, limit, lastNotificationId];
}

/// Load unread notifications
class LoadUnreadNotificationsEvent extends NotificationEvent {
  final String userId;

  const LoadUnreadNotificationsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Load notifications by category
class LoadNotificationsByCategoryEvent extends NotificationEvent {
  final String userId;
  final NotificationCategory category;
  final int? limit;

  const LoadNotificationsByCategoryEvent({
    required this.userId,
    required this.category,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, category, limit];
}

/// Load notifications by type
class LoadNotificationsByTypeEvent extends NotificationEvent {
  final String userId;
  final String type;
  final int? limit;

  const LoadNotificationsByTypeEvent({
    required this.userId,
    required this.type,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, type, limit];
}

/// Refresh notifications
class RefreshNotificationsEvent extends NotificationEvent {
  final String userId;

  const RefreshNotificationsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Notification action events

/// Mark notification as read
class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  final String userId;

  const MarkAllNotificationsAsReadEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Delete notification
class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Delete all notifications
class DeleteAllNotificationsEvent extends NotificationEvent {
  final String userId;

  const DeleteAllNotificationsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Create notification
class CreateNotificationEvent extends NotificationEvent {
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final NotificationPriority priority;
  final NotificationCategory category;
  final String? imageUrl;
  final String? actionUrl;
  final bool isPersistent;

  const CreateNotificationEvent({
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    this.priority = NotificationPriority.normal,
    this.category = NotificationCategory.system,
    this.imageUrl,
    this.actionUrl,
    this.isPersistent = false,
  });

  @override
  List<Object?> get props => [
        userId,
        title,
        body,
        type,
        data,
        priority,
        category,
        imageUrl,
        actionUrl,
        isPersistent,
      ];
}

// Real-time events

/// Start listening to real-time notifications
class StartListeningToNotificationsEvent extends NotificationEvent {
  final String userId;

  const StartListeningToNotificationsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Stop listening to real-time notifications
class StopListeningToNotificationsEvent extends NotificationEvent {
  const StopListeningToNotificationsEvent();
}

/// Real-time notifications updated
class NotificationsUpdatedEvent extends NotificationEvent {
  final List<NotificationEntity> notifications;

  const NotificationsUpdatedEvent({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

/// Unread count updated
class UnreadCountUpdatedEvent extends NotificationEvent {
  final int count;

  const UnreadCountUpdatedEvent({required this.count});

  @override
  List<Object?> get props => [count];
}

// Push notification events

/// Send push notification
class SendPushNotificationEvent extends NotificationEvent {
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  const SendPushNotificationEvent({
    required this.userId,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [userId, title, body, data, imageUrl];
}

/// Send bulk push notification
class SendBulkPushNotificationEvent extends NotificationEvent {
  final List<String> userIds;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  const SendBulkPushNotificationEvent({
    required this.userIds,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [userIds, title, body, data, imageUrl];
}

// Scheduled notification events

/// Schedule notification
class ScheduleNotificationEvent extends NotificationEvent {
  final String userId;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String type;
  final Map<String, dynamic>? data;
  final NotificationPriority priority;
  final NotificationCategory category;

  const ScheduleNotificationEvent({
    required this.userId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.type,
    this.data,
    this.priority = NotificationPriority.normal,
    this.category = NotificationCategory.system,
  });

  @override
  List<Object?> get props => [
        userId,
        title,
        body,
        scheduledAt,
        type,
        data,
        priority,
        category,
      ];
}

/// Cancel scheduled notification
class CancelScheduledNotificationEvent extends NotificationEvent {
  final String notificationId;

  const CancelScheduledNotificationEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Load scheduled notifications
class LoadScheduledNotificationsEvent extends NotificationEvent {
  final String userId;

  const LoadScheduledNotificationsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Preference events

/// Load notification preferences
class LoadNotificationPreferencesEvent extends NotificationEvent {
  final String userId;

  const LoadNotificationPreferencesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Update notification preferences
class UpdateNotificationPreferencesEvent extends NotificationEvent {
  final NotificationPreferences preferences;

  const UpdateNotificationPreferencesEvent({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

/// Toggle category preference
class ToggleCategoryPreferenceEvent extends NotificationEvent {
  final String userId;
  final NotificationCategory category;

  const ToggleCategoryPreferenceEvent({
    required this.userId,
    required this.category,
  });

  @override
  List<Object?> get props => [userId, category];
}

/// Toggle priority preference
class TogglePriorityPreferenceEvent extends NotificationEvent {
  final String userId;
  final NotificationPriority priority;

  const TogglePriorityPreferenceEvent({
    required this.userId,
    required this.priority,
  });

  @override
  List<Object?> get props => [userId, priority];
}

/// Set quiet hours
class SetQuietHoursEvent extends NotificationEvent {
  final String userId;
  final String start;
  final String end;
  final bool enabled;

  const SetQuietHoursEvent({
    required this.userId,
    required this.start,
    required this.end,
    required this.enabled,
  });

  @override
  List<Object?> get props => [userId, start, end, enabled];
}

// Statistics events

/// Load notification statistics
class LoadNotificationStatsEvent extends NotificationEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadNotificationStatsEvent({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

// Error handling events

/// Clear error
class ClearNotificationErrorEvent extends NotificationEvent {
  const ClearNotificationErrorEvent();
}

/// Retry failed operation
class RetryNotificationOperationEvent extends NotificationEvent {
  const RetryNotificationOperationEvent();
}
