import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for marking a notification as read
class MarkNotificationAsRead
    implements UseCase<NotificationEntity, MarkNotificationAsReadParams> {
  final NotificationRepository repository;

  MarkNotificationAsRead(this.repository);

  @override
  Future<Either<Failure, NotificationEntity>> call(
    MarkNotificationAsReadParams params,
  ) async {
    return await repository.markAsRead(params.notificationId);
  }
}

/// Parameters for MarkNotificationAsRead use case
class MarkNotificationAsReadParams extends Equatable {
  final String notificationId;

  const MarkNotificationAsReadParams({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}
