import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';
import '../models/notification_preferences_model.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(
    String userId, {
    int? limit,
    String? lastNotificationId,
  }) async {
    try {
      final notifications = await remoteDataSource.getUserNotifications(
        userId,
        limit: limit,
        lastNotificationId: lastNotificationId,
      );
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get user notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getUnreadNotifications(
    String userId,
  ) async {
    try {
      final notifications = await remoteDataSource.getUnreadNotifications(
        userId,
      );
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get unread notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotificationsByCategory(
    String userId,
    NotificationCategory category, {
    int? limit,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotificationsByCategory(
        userId,
        category,
        limit: limit,
      );
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get notifications by category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotificationsByType(
    String userId,
    String type, {
    int? limit,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotificationsByType(
        userId,
        type,
        limit: limit,
      );
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get notifications by type: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> getNotificationById(
    String notificationId,
  ) async {
    try {
      final notification = await remoteDataSource.getNotificationById(
        notificationId,
      );
      return Right(notification);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get notification: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> createNotification(
    NotificationEntity notification,
  ) async {
    try {
      final notificationModel = NotificationModel.fromEntity(notification);
      final createdNotification = await remoteDataSource.createNotification(
        notificationModel,
      );
      return Right(createdNotification);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create notification: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> updateNotification(
    NotificationEntity notification,
  ) async {
    try {
      final notificationModel = NotificationModel.fromEntity(notification);
      final updatedNotification = await remoteDataSource.updateNotification(
        notificationModel,
      );
      return Right(updatedNotification);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete notification: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markAsRead(
    String notificationId,
  ) async {
    try {
      final notification = await remoteDataSource.markAsRead(notificationId);
      return Right(notification);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to mark notification as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      await remoteDataSource.markAllAsRead(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to mark all notifications as read: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications(String userId) async {
    try {
      await remoteDataSource.deleteAllNotifications(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete all notifications: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> listenToUserNotifications(
    String userId,
  ) {
    return remoteDataSource
        .listenToUserNotifications(userId)
        .map(
          (notifications) =>
              Right<Failure, List<NotificationEntity>>(notifications),
        )
        .handleError((error) {
          return Left<Failure, List<NotificationEntity>>(
            ServerFailure('Failed to listen to notifications: $error'),
          );
        });
  }

  @override
  Stream<Either<Failure, int>> listenToUnreadCount(String userId) {
    return remoteDataSource
        .listenToUnreadCount(userId)
        .map((count) => Right<Failure, int>(count))
        .handleError((error) {
          return Left<Failure, int>(
            ServerFailure('Failed to listen to unread count: $error'),
          );
        });
  }

  @override
  Future<Either<Failure, NotificationPreferences>> getNotificationPreferences(
    String userId,
  ) async {
    try {
      final preferences = await remoteDataSource.getNotificationPreferences(
        userId,
      );
      return Right(preferences);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get notification preferences: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferences>>
  updateNotificationPreferences(NotificationPreferences preferences) async {
    try {
      final preferencesModel = NotificationPreferencesModel.fromEntity(
        preferences,
      );
      final updatedPreferences = await remoteDataSource
          .updateNotificationPreferences(preferencesModel);
      return Right(updatedPreferences);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to update notification preferences: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      await remoteDataSource.sendPushNotification(
        userId: userId,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to send push notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendBulkPushNotification({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      await remoteDataSource.sendBulkPushNotification(
        userIds: userIds,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to send bulk push notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      await remoteDataSource.sendTopicNotification(
        topic: topic,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to send topic notification: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> scheduleNotification({
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
      final notification = await remoteDataSource.scheduleNotification(
        userId: userId,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        type: type,
        data: data,
        priority: priority,
        category: category,
      );
      return Right(notification);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to schedule notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelScheduledNotification(
    String notificationId,
  ) async {
    try {
      await remoteDataSource.cancelScheduledNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel scheduled notification: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getScheduledNotifications(
    String userId,
  ) async {
    try {
      final notifications = await remoteDataSource.getScheduledNotifications(
        userId,
      );
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get scheduled notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationStats>> getNotificationStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getNotificationStats(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get notification stats: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final count = await remoteDataSource.getUnreadCount(userId);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get unread count: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<NotificationCategory, int>>> getCountByCategory(
    String userId,
  ) async {
    try {
      final counts = await remoteDataSource.getCountByCategory(userId);
      return Right(counts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get count by category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFCMToken(
    String userId,
    String token,
  ) async {
    try {
      await remoteDataSource.updateFCMToken(userId, token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update FCM token: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getFCMToken(String userId) async {
    try {
      final token = await remoteDataSource.getFCMToken(userId);
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get FCM token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToTopic(
    String userId,
    String topic,
  ) async {
    try {
      await remoteDataSource.subscribeToTopic(userId, topic);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to subscribe to topic: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromTopic(
    String userId,
    String topic,
  ) async {
    try {
      await remoteDataSource.unsubscribeFromTopic(userId, topic);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to unsubscribe from topic: $e'));
    }
  }
}
