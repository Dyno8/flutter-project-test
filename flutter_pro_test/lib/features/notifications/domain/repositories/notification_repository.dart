import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';
import '../entities/notification_preferences.dart';

/// Repository interface for notification operations
abstract class NotificationRepository {
  // Notification CRUD operations

  /// Get all notifications for a user
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(
    String userId, {
    int? limit,
    String? lastNotificationId,
  });

  /// Get unread notifications for a user
  Future<Either<Failure, List<NotificationEntity>>> getUnreadNotifications(
    String userId,
  );

  /// Get notifications by category
  Future<Either<Failure, List<NotificationEntity>>> getNotificationsByCategory(
    String userId,
    NotificationCategory category, {
    int? limit,
  });

  /// Get notifications by type
  Future<Either<Failure, List<NotificationEntity>>> getNotificationsByType(
    String userId,
    String type, {
    int? limit,
  });

  /// Get notification by ID
  Future<Either<Failure, NotificationEntity>> getNotificationById(
    String notificationId,
  );

  /// Create a new notification
  Future<Either<Failure, NotificationEntity>> createNotification(
    NotificationEntity notification,
  );

  /// Update notification
  Future<Either<Failure, NotificationEntity>> updateNotification(
    NotificationEntity notification,
  );

  /// Delete notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Mark notification as read
  Future<Either<Failure, NotificationEntity>> markAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<Either<Failure, void>> markAllAsRead(String userId);

  /// Delete all notifications for a user
  Future<Either<Failure, void>> deleteAllNotifications(String userId);

  // Real-time operations

  /// Listen to real-time notification updates for a user
  Stream<Either<Failure, List<NotificationEntity>>> listenToUserNotifications(
    String userId,
  );

  /// Listen to unread notification count
  Stream<Either<Failure, int>> listenToUnreadCount(String userId);

  // Notification preferences

  /// Get user notification preferences
  Future<Either<Failure, NotificationPreferences>> getNotificationPreferences(
    String userId,
  );

  /// Update notification preferences
  Future<Either<Failure, NotificationPreferences>>
  updateNotificationPreferences(NotificationPreferences preferences);

  // Push notification operations

  /// Send push notification to user
  Future<Either<Failure, void>> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  });

  /// Send push notification to multiple users
  Future<Either<Failure, void>> sendBulkPushNotification({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  });

  /// Send push notification to topic
  Future<Either<Failure, void>> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  });

  // Scheduled notifications

  /// Schedule a notification
  Future<Either<Failure, NotificationEntity>> scheduleNotification({
    required String userId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String type,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.normal,
    NotificationCategory category = NotificationCategory.system,
  });

  /// Cancel scheduled notification
  Future<Either<Failure, void>> cancelScheduledNotification(
    String notificationId,
  );

  /// Get scheduled notifications for a user
  Future<Either<Failure, List<NotificationEntity>>> getScheduledNotifications(
    String userId,
  );

  // Statistics and analytics

  /// Get notification statistics for a user
  Future<Either<Failure, NotificationStats>> getNotificationStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get unread notification count
  Future<Either<Failure, int>> getUnreadCount(String userId);

  /// Get notification count by category
  Future<Either<Failure, Map<NotificationCategory, int>>> getCountByCategory(
    String userId,
  );

  // FCM token management

  /// Update user FCM token
  Future<Either<Failure, void>> updateFCMToken(String userId, String token);

  /// Get user FCM token
  Future<Either<Failure, String?>> getFCMToken(String userId);

  /// Subscribe user to topic
  Future<Either<Failure, void>> subscribeToTopic(String userId, String topic);

  /// Unsubscribe user from topic
  Future<Either<Failure, void>> unsubscribeFromTopic(
    String userId,
    String topic,
  );
}

/// Notification statistics model
class NotificationStats {
  final int totalNotifications;
  final int unreadNotifications;
  final int readNotifications;
  final Map<NotificationCategory, int> categoryBreakdown;
  final Map<NotificationPriority, int> priorityBreakdown;
  final Map<String, int> typeBreakdown;
  final DateTime periodStart;
  final DateTime periodEnd;

  const NotificationStats({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.readNotifications,
    required this.categoryBreakdown,
    required this.priorityBreakdown,
    required this.typeBreakdown,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Calculate read percentage
  double get readPercentage {
    if (totalNotifications == 0) return 0.0;
    return (readNotifications / totalNotifications) * 100;
  }

  /// Get most active category
  NotificationCategory? get mostActiveCategory {
    if (categoryBreakdown.isEmpty) return null;
    return categoryBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get most common priority
  NotificationPriority? get mostCommonPriority {
    if (priorityBreakdown.isEmpty) return null;
    return priorityBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
