import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// Use case for sending push notifications
class SendPushNotification
    implements UseCase<void, SendPushNotificationParams> {
  final NotificationRepository repository;

  SendPushNotification(this.repository);

  @override
  Future<Either<Failure, void>> call(SendPushNotificationParams params) async {
    return await repository.sendPushNotification(
      userId: params.userId,
      title: params.title,
      body: params.body,
      data: params.data,
      imageUrl: params.imageUrl,
    );
  }
}

/// Parameters for SendPushNotification use case
class SendPushNotificationParams extends Equatable {
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  const SendPushNotificationParams({
    required this.userId,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [userId, title, body, data, imageUrl];
}
