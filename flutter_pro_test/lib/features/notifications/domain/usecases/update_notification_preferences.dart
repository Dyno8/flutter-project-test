import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_preferences.dart';
import '../repositories/notification_repository.dart';

/// Use case for updating notification preferences
class UpdateNotificationPreferences
    implements
        UseCase<NotificationPreferences, UpdateNotificationPreferencesParams> {
  final NotificationRepository repository;

  UpdateNotificationPreferences(this.repository);

  @override
  Future<Either<Failure, NotificationPreferences>> call(
    UpdateNotificationPreferencesParams params,
  ) async {
    return await repository.updateNotificationPreferences(params.preferences);
  }
}

/// Parameters for UpdateNotificationPreferences use case
class UpdateNotificationPreferencesParams extends Equatable {
  final NotificationPreferences preferences;

  const UpdateNotificationPreferencesParams({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}
