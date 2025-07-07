import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting user notifications
class GetUserNotifications
    implements UseCase<List<NotificationEntity>, GetUserNotificationsParams> {
  final NotificationRepository repository;

  GetUserNotifications(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetUserNotificationsParams params,
  ) async {
    return await repository.getUserNotifications(
      params.userId,
      limit: params.limit,
      lastNotificationId: params.lastNotificationId,
    );
  }
}

/// Parameters for GetUserNotifications use case
class GetUserNotificationsParams extends Equatable {
  final String userId;
  final int? limit;
  final String? lastNotificationId;

  const GetUserNotificationsParams({
    required this.userId,
    this.limit,
    this.lastNotificationId,
  });

  @override
  List<Object?> get props => [userId, limit, lastNotificationId];
}
