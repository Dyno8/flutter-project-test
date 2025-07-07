import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for creating a new notification
class CreateNotification
    implements UseCase<NotificationEntity, CreateNotificationParams> {
  final NotificationRepository repository;

  CreateNotification(this.repository);

  @override
  Future<Either<Failure, NotificationEntity>> call(
    CreateNotificationParams params,
  ) async {
    final notification = NotificationEntity(
      id: params.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: params.userId,
      title: params.title,
      body: params.body,
      type: params.type,
      data: params.data,
      createdAt: DateTime.now(),
      isRead: false,
      priority: params.priority,
      category: params.category,
      imageUrl: params.imageUrl,
      actionUrl: params.actionUrl,
      scheduledAt: params.scheduledAt,
      isScheduled: params.scheduledAt != null,
      isPersistent: params.isPersistent,
    );

    return await repository.createNotification(notification);
  }
}

/// Parameters for CreateNotification use case
class CreateNotificationParams extends Equatable {
  final String? id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final NotificationPriority priority;
  final NotificationCategory category;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime? scheduledAt;
  final bool isPersistent;

  const CreateNotificationParams({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    this.priority = NotificationPriority.normal,
    this.category = NotificationCategory.system,
    this.imageUrl,
    this.actionUrl,
    this.scheduledAt,
    this.isPersistent = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    body,
    type,
    data,
    priority,
    category,
    imageUrl,
    actionUrl,
    scheduledAt,
    isPersistent,
  ];
}
