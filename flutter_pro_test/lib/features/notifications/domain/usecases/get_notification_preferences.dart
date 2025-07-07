import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_preferences.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting notification preferences
class GetNotificationPreferences
    implements
        UseCase<NotificationPreferences, GetNotificationPreferencesParams> {
  final NotificationRepository repository;

  GetNotificationPreferences(this.repository);

  @override
  Future<Either<Failure, NotificationPreferences>> call(
    GetNotificationPreferencesParams params,
  ) async {
    return await repository.getNotificationPreferences(params.userId);
  }
}

/// Parameters for GetNotificationPreferences use case
class GetNotificationPreferencesParams extends Equatable {
  final String userId;

  const GetNotificationPreferencesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
