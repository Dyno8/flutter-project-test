import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';

/// Base class for notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Notifications loaded successfully
class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool hasMore;
  final String? lastNotificationId;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = false,
    this.lastNotificationId,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore, lastNotificationId];

  /// Create a copy with updated fields
  NotificationsLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? hasMore,
    String? lastNotificationId,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      lastNotificationId: lastNotificationId ?? this.lastNotificationId,
    );
  }

  /// Add more notifications (for pagination)
  NotificationsLoaded addNotifications(List<NotificationEntity> newNotifications) {
    final allNotifications = List<NotificationEntity>.from(notifications)
      ..addAll(newNotifications);
    
    return copyWith(
      notifications: allNotifications,
      lastNotificationId: newNotifications.isNotEmpty ? newNotifications.last.id : lastNotificationId,
      hasMore: newNotifications.length >= 20, // Assuming page size of 20
    );
  }

  /// Update a specific notification
  NotificationsLoaded updateNotification(NotificationEntity updatedNotification) {
    final updatedNotifications = notifications.map((notification) {
      return notification.id == updatedNotification.id ? updatedNotification : notification;
    }).toList();

    // Recalculate unread count
    final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

    return copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  /// Remove a notification
  NotificationsLoaded removeNotification(String notificationId) {
    final updatedNotifications = notifications.where((n) => n.id != notificationId).toList();
    final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

    return copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  /// Mark all as read
  NotificationsLoaded markAllAsRead() {
    final updatedNotifications = notifications.map((n) => n.markAsRead()).toList();
    return copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    );
  }
}

/// Unread notifications loaded
class UnreadNotificationsLoaded extends NotificationState {
  final List<NotificationEntity> unreadNotifications;
  final int count;

  const UnreadNotificationsLoaded({
    required this.unreadNotifications,
    required this.count,
  });

  @override
  List<Object?> get props => [unreadNotifications, count];
}

/// Notifications by category loaded
class NotificationsByCategoryLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final NotificationCategory category;

  const NotificationsByCategoryLoaded({
    required this.notifications,
    required this.category,
  });

  @override
  List<Object?> get props => [notifications, category];
}

/// Notifications by type loaded
class NotificationsByTypeLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final String type;

  const NotificationsByTypeLoaded({
    required this.notifications,
    required this.type,
  });

  @override
  List<Object?> get props => [notifications, type];
}

/// Scheduled notifications loaded
class ScheduledNotificationsLoaded extends NotificationState {
  final List<NotificationEntity> scheduledNotifications;

  const ScheduledNotificationsLoaded({
    required this.scheduledNotifications,
  });

  @override
  List<Object?> get props => [scheduledNotifications];
}

/// Notification created successfully
class NotificationCreated extends NotificationState {
  final NotificationEntity notification;

  const NotificationCreated({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Notification updated successfully
class NotificationUpdated extends NotificationState {
  final NotificationEntity notification;

  const NotificationUpdated({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Notification deleted successfully
class NotificationDeleted extends NotificationState {
  final String notificationId;

  const NotificationDeleted({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// All notifications deleted successfully
class AllNotificationsDeleted extends NotificationState {
  const AllNotificationsDeleted();
}

/// Notification marked as read
class NotificationMarkedAsRead extends NotificationState {
  final NotificationEntity notification;

  const NotificationMarkedAsRead({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// All notifications marked as read
class AllNotificationsMarkedAsRead extends NotificationState {
  const AllNotificationsMarkedAsRead();
}

/// Push notification sent successfully
class PushNotificationSent extends NotificationState {
  const PushNotificationSent();
}

/// Bulk push notification sent successfully
class BulkPushNotificationSent extends NotificationState {
  const BulkPushNotificationSent();
}

/// Notification scheduled successfully
class NotificationScheduled extends NotificationState {
  final NotificationEntity notification;

  const NotificationScheduled({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Scheduled notification cancelled
class ScheduledNotificationCancelled extends NotificationState {
  final String notificationId;

  const ScheduledNotificationCancelled({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Notification preferences loaded
class NotificationPreferencesLoaded extends NotificationState {
  final NotificationPreferences preferences;

  const NotificationPreferencesLoaded({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

/// Notification preferences updated
class NotificationPreferencesUpdated extends NotificationState {
  final NotificationPreferences preferences;

  const NotificationPreferencesUpdated({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

/// Notification statistics loaded
class NotificationStatsLoaded extends NotificationState {
  final NotificationStats stats;

  const NotificationStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

/// Real-time listening state
class NotificationListeningStarted extends NotificationState {
  final String userId;

  const NotificationListeningStarted({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Real-time listening stopped
class NotificationListeningStopped extends NotificationState {
  const NotificationListeningStopped();
}

/// Real-time notifications updated
class NotificationRealTimeUpdated extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationRealTimeUpdated({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// Unread count updated
class NotificationUnreadCountUpdated extends NotificationState {
  final int count;

  const NotificationUnreadCountUpdated({required this.count});

  @override
  List<Object?> get props => [count];
}

/// Error state
class NotificationError extends NotificationState {
  final String message;
  final String? errorCode;

  const NotificationError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Network error state
class NotificationNetworkError extends NotificationError {
  const NotificationNetworkError({
    required super.message,
    super.errorCode,
  });
}

/// Permission error state
class NotificationPermissionError extends NotificationError {
  const NotificationPermissionError({
    required super.message,
    super.errorCode,
  });
}

/// Loading more notifications (for pagination)
class NotificationLoadingMore extends NotificationState {
  final List<NotificationEntity> currentNotifications;
  final int unreadCount;

  const NotificationLoadingMore({
    required this.currentNotifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [currentNotifications, unreadCount];
}
