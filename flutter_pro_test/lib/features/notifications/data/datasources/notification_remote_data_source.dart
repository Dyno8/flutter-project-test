import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';
import '../models/notification_preferences_model.dart';

/// Remote data source for notification operations
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getUserNotifications(
    String userId, {
    int? limit,
    String? lastNotificationId,
  });

  Future<List<NotificationModel>> getUnreadNotifications(String userId);

  Future<List<NotificationModel>> getNotificationsByCategory(
    String userId,
    NotificationCategory category, {
    int? limit,
  });

  Future<List<NotificationModel>> getNotificationsByType(
    String userId,
    String type, {
    int? limit,
  });

  Future<NotificationModel> getNotificationById(String notificationId);

  Future<NotificationModel> createNotification(NotificationModel notification);

  Future<NotificationModel> updateNotification(NotificationModel notification);

  Future<void> deleteNotification(String notificationId);

  Future<NotificationModel> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<void> deleteAllNotifications(String userId);

  Stream<List<NotificationModel>> listenToUserNotifications(String userId);

  Stream<int> listenToUnreadCount(String userId);

  Future<NotificationPreferencesModel> getNotificationPreferences(
    String userId,
  );

  Future<NotificationPreferencesModel> updateNotificationPreferences(
    NotificationPreferencesModel preferences,
  );

  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  });

  Future<void> sendBulkPushNotification({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  });

  Future<void> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  });

  Future<NotificationModel> scheduleNotification({
    required String userId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String type,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.normal,
    NotificationCategory category = NotificationCategory.system,
  });

  Future<void> cancelScheduledNotification(String notificationId);

  Future<List<NotificationModel>> getScheduledNotifications(String userId);

  Future<NotificationStats> getNotificationStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<int> getUnreadCount(String userId);

  Future<Map<NotificationCategory, int>> getCountByCategory(String userId);

  Future<void> updateFCMToken(String userId, String token);

  Future<String?> getFCMToken(String userId);

  Future<void> subscribeToTopic(String userId, String topic);

  Future<void> unsubscribeFromTopic(String userId, String topic);
}

/// Implementation of NotificationRemoteDataSource
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseMessaging messaging;

  NotificationRemoteDataSourceImpl({
    required this.firestore,
    required this.messaging,
  });

  CollectionReference get _notificationsCollection =>
      firestore.collection(AppConstants.notificationsCollection);

  CollectionReference get _preferencesCollection =>
      firestore.collection(AppConstants.notificationPreferencesCollection);

  CollectionReference get _usersCollection =>
      firestore.collection(AppConstants.usersCollection);

  @override
  Future<List<NotificationModel>> getUserNotifications(
    String userId, {
    int? limit,
    String? lastNotificationId,
  }) async {
    try {
      Query query = _notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastNotificationId != null) {
        final lastDoc = await _notificationsCollection
            .doc(lastNotificationId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    try {
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get unread notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsByCategory(
    String userId,
    NotificationCategory category, {
    int? limit,
  }) async {
    try {
      Query query = _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category.name)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get notifications by category: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsByType(
    String userId,
    String type, {
    int? limit,
  }) async {
    try {
      Query query = _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get notifications by type: $e');
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String notificationId) async {
    try {
      final doc = await _notificationsCollection.doc(notificationId).get();
      if (!doc.exists) {
        throw ServerException('Notification not found');
      }
      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get notification: $e');
    }
  }

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    try {
      final docRef = _notificationsCollection.doc(notification.id);
      await docRef.set(notification.toFirestore());

      final doc = await docRef.get();
      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to create notification: $e');
    }
  }

  @override
  Future<NotificationModel> updateNotification(
    NotificationModel notification,
  ) async {
    try {
      await _notificationsCollection
          .doc(notification.id)
          .update(notification.toFirestore());

      final doc = await _notificationsCollection.doc(notification.id).get();
      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to update notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      throw ServerException('Failed to delete notification: $e');
    }
  }

  @override
  Future<NotificationModel> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });

      final doc = await _notificationsCollection.doc(notificationId).get();
      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = firestore.batch();
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = firestore.batch();
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to delete all notifications: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> listenToUserNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<int> listenToUnreadCount(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<NotificationPreferencesModel> getNotificationPreferences(
    String userId,
  ) async {
    try {
      final doc = await _preferencesCollection.doc(userId).get();
      if (!doc.exists) {
        // Create default preferences
        final defaultPrefs = NotificationPreferencesModel.fromEntity(
          NotificationPreferences.defaultPreferences(userId),
        );
        await _preferencesCollection
            .doc(userId)
            .set(defaultPrefs.toFirestore());
        return defaultPrefs;
      }
      return NotificationPreferencesModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get notification preferences: $e');
    }
  }

  @override
  Future<NotificationPreferencesModel> updateNotificationPreferences(
    NotificationPreferencesModel preferences,
  ) async {
    try {
      await _preferencesCollection
          .doc(preferences.userId)
          .set(preferences.toFirestore(), SetOptions(merge: true));

      final doc = await _preferencesCollection.doc(preferences.userId).get();
      return NotificationPreferencesModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to update notification preferences: $e');
    }
  }

  // Additional methods will be implemented in the next part due to length constraints
  @override
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    // Implementation will be added in enhanced notification service
    throw UnimplementedError(
      'Push notification sending will be implemented in service layer',
    );
  }

  @override
  Future<void> sendBulkPushNotification({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    throw UnimplementedError(
      'Bulk push notification sending will be implemented in service layer',
    );
  }

  @override
  Future<void> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    throw UnimplementedError(
      'Topic notification sending will be implemented in service layer',
    );
  }

  @override
  Future<NotificationModel> scheduleNotification({
    required String userId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String type,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.normal,
    NotificationCategory category = NotificationCategory.system,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data ?? {},
        createdAt: DateTime.now(),
        isRead: false,
        priority: priority,
        category: category,
        scheduledAt: scheduledAt,
        isScheduled: true,
        isPersistent: false,
      );

      return await createNotification(notification);
    } catch (e) {
      throw ServerException('Failed to schedule notification: $e');
    }
  }

  @override
  Future<void> cancelScheduledNotification(String notificationId) async {
    await deleteNotification(notificationId);
  }

  @override
  Future<List<NotificationModel>> getScheduledNotifications(
    String userId,
  ) async {
    try {
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isScheduled', isEqualTo: true)
          .orderBy('scheduledAt')
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get scheduled notifications: $e');
    }
  }

  @override
  Future<NotificationStats> getNotificationStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _notificationsCollection.where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final querySnapshot = await query.get();
      final notifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      final categoryBreakdown = <NotificationCategory, int>{};
      final priorityBreakdown = <NotificationPriority, int>{};
      final typeBreakdown = <String, int>{};
      int readCount = 0;

      for (final notification in notifications) {
        // Category breakdown
        categoryBreakdown[notification.category] =
            (categoryBreakdown[notification.category] ?? 0) + 1;

        // Priority breakdown
        priorityBreakdown[notification.priority] =
            (priorityBreakdown[notification.priority] ?? 0) + 1;

        // Type breakdown
        typeBreakdown[notification.type] =
            (typeBreakdown[notification.type] ?? 0) + 1;

        // Read count
        if (notification.isRead) readCount++;
      }

      return NotificationStats(
        totalNotifications: notifications.length,
        unreadNotifications: notifications.length - readCount,
        readNotifications: readCount,
        categoryBreakdown: categoryBreakdown,
        priorityBreakdown: priorityBreakdown,
        typeBreakdown: typeBreakdown,
        periodStart:
            startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        periodEnd: endDate ?? DateTime.now(),
      );
    } catch (e) {
      throw ServerException('Failed to get notification stats: $e');
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw ServerException('Failed to get unread count: $e');
    }
  }

  @override
  Future<Map<NotificationCategory, int>> getCountByCategory(
    String userId,
  ) async {
    try {
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final result = <NotificationCategory, int>{};
      for (final doc in querySnapshot.docs) {
        final notification = NotificationModel.fromFirestore(doc);
        result[notification.category] =
            (result[notification.category] ?? 0) + 1;
      }

      return result;
    } catch (e) {
      throw ServerException('Failed to get count by category: $e');
    }
  }

  @override
  Future<void> updateFCMToken(String userId, String token) async {
    try {
      await _usersCollection.doc(userId).update({'fcmToken': token});
    } catch (e) {
      throw ServerException('Failed to update FCM token: $e');
    }
  }

  @override
  Future<String?> getFCMToken(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return data['fcmToken'] as String?;
    } catch (e) {
      throw ServerException('Failed to get FCM token: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String userId, String topic) async {
    try {
      final token = await getFCMToken(userId);
      if (token != null) {
        await messaging.subscribeToTopic(topic);
      }
    } catch (e) {
      throw ServerException('Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String userId, String topic) async {
    try {
      final token = await getFCMToken(userId);
      if (token != null) {
        await messaging.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      throw ServerException('Failed to unsubscribe from topic: $e');
    }
  }
}
