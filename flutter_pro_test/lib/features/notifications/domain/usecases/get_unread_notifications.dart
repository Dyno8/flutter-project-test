import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting unread notifications
class GetUnreadNotifications
    implements UseCase<List<NotificationEntity>, GetUnreadNotificationsParams> {
  final NotificationRepository repository;

  GetUnreadNotifications(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetUnreadNotificationsParams params,
  ) async {
    return await repository.getUnreadNotifications(params.userId);
  }
}

/// Parameters for GetUnreadNotifications use case
class GetUnreadNotificationsParams extends Equatable {
  final String userId;

  const GetUnreadNotificationsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
