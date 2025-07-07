import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/create_notification.dart';
import '../../features/notifications/domain/usecases/send_push_notification.dart';
import '../../features/notifications/domain/usecases/get_notification_preferences.dart';
import '../../features/booking/domain/entities/booking.dart';
import '../../features/partner/domain/entities/job.dart';

import '../../shared/repositories/user_repository.dart';
import 'notification_service.dart';

/// Service for integrating notifications with booking and partner management
/// This service acts as a bridge between business logic and the notification system
class NotificationIntegrationService {
  final NotificationRepository _notificationRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final NotificationService _notificationService;
  final CreateNotification _createNotification;
  final SendPushNotification _sendPushNotification;
  final GetNotificationPreferences _getNotificationPreferences;

  NotificationIntegrationService({
    required NotificationRepository notificationRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required NotificationService notificationService,
    required CreateNotification createNotification,
    required SendPushNotification sendPushNotification,
    required GetNotificationPreferences getNotificationPreferences,
  }) : _notificationRepository = notificationRepository,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _notificationService = notificationService,
       _createNotification = createNotification,
       _sendPushNotification = sendPushNotification,
       _getNotificationPreferences = getNotificationPreferences;

  // ============================================================================
  // BOOKING NOTIFICATION METHODS
  // ============================================================================

  /// Send notification when a new booking is created
  Future<Either<Failure, void>> notifyBookingCreated(Booking booking) async {
    try {
      // Get client user info
      final clientResult = await _userRepository.getById(booking.userId);
      if (clientResult.isLeft()) {
        return Left(ServerFailure('Failed to get client info'));
      }
      final client = (clientResult as Right).value;
      if (client == null) {
        return Left(ServerFailure('Client not found'));
      }

      // Notify client about booking creation
      await _sendNotificationToUser(
        userId: booking.userId,
        title: 'Đặt lịch thành công',
        body:
            'Đặt lịch ${booking.serviceName} vào ${booking.formattedDateTime} đã được tạo thành công.',
        type: NotificationTypes.bookingCreated,
        category: NotificationCategory.booking,
        priority: NotificationPriority.normal,
        data: {
          'bookingId': booking.id,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'scheduledDate': booking.scheduledDate.toIso8601String(),
          'timeSlot': booking.timeSlot,
          'totalPrice': booking.totalPrice,
          'status': booking.status.name,
        },
        actionUrl: '/booking/${booking.id}',
      );

      developer.log(
        'Booking created notification sent for booking: ${booking.id}',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending booking created notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send booking created notification: $e'),
      );
    }
  }

  /// Send notification when a booking is confirmed (partner assigned)
  Future<Either<Failure, void>> notifyBookingConfirmed(
    Booking booking,
    String partnerName,
  ) async {
    try {
      // Notify client about booking confirmation
      await _sendNotificationToUser(
        userId: booking.userId,
        title: 'Đặt lịch đã được xác nhận',
        body:
            'Đặt lịch ${booking.serviceName} đã được xác nhận bởi $partnerName.',
        type: NotificationTypes.bookingConfirmed,
        category: NotificationCategory.booking,
        priority: NotificationPriority.high,
        data: {
          'bookingId': booking.id,
          'partnerId': booking.partnerId,
          'partnerName': partnerName,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'scheduledDate': booking.scheduledDate.toIso8601String(),
          'timeSlot': booking.timeSlot,
          'status': booking.status.name,
        },
        actionUrl: '/booking/${booking.id}',
      );

      developer.log(
        'Booking confirmed notification sent for booking: ${booking.id}',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending booking confirmed notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send booking confirmed notification: $e'),
      );
    }
  }

  /// Send notification when a booking is started
  Future<Either<Failure, void>> notifyBookingStarted(
    Booking booking,
    String partnerName,
  ) async {
    try {
      // Notify client about booking start
      await _sendNotificationToUser(
        userId: booking.userId,
        title: 'Dịch vụ đã bắt đầu',
        body:
            '$partnerName đã bắt đầu thực hiện dịch vụ ${booking.serviceName}.',
        type: NotificationTypes.bookingStarted,
        category: NotificationCategory.booking,
        priority: NotificationPriority.high,
        data: {
          'bookingId': booking.id,
          'partnerId': booking.partnerId,
          'partnerName': partnerName,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'scheduledDate': booking.scheduledDate.toIso8601String(),
          'timeSlot': booking.timeSlot,
          'status': booking.status.name,
        },
        actionUrl: '/booking/${booking.id}',
      );

      developer.log(
        'Booking started notification sent for booking: ${booking.id}',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending booking started notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send booking started notification: $e'),
      );
    }
  }

  /// Send notification when a booking is completed
  Future<Either<Failure, void>> notifyBookingCompleted(
    Booking booking,
    String partnerName,
  ) async {
    try {
      // Notify client about booking completion
      await _sendNotificationToUser(
        userId: booking.userId,
        title: 'Dịch vụ hoàn thành',
        body:
            'Dịch vụ ${booking.serviceName} đã được hoàn thành bởi $partnerName.',
        type: NotificationTypes.bookingCompleted,
        category: NotificationCategory.booking,
        priority: NotificationPriority.high,
        data: {
          'bookingId': booking.id,
          'partnerId': booking.partnerId,
          'partnerName': partnerName,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'scheduledDate': booking.scheduledDate.toIso8601String(),
          'timeSlot': booking.timeSlot,
          'totalPrice': booking.totalPrice,
          'status': booking.status.name,
        },
        actionUrl: '/booking/${booking.id}',
      );

      developer.log(
        'Booking completed notification sent for booking: ${booking.id}',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending booking completed notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send booking completed notification: $e'),
      );
    }
  }

  /// Send notification when a booking is cancelled
  Future<Either<Failure, void>> notifyBookingCancelled(
    Booking booking,
    String cancellationReason, {
    String? cancelledBy,
  }) async {
    try {
      // Notify client about booking cancellation
      await _sendNotificationToUser(
        userId: booking.userId,
        title: 'Đặt lịch đã bị hủy',
        body:
            'Đặt lịch ${booking.serviceName} đã bị hủy. Lý do: $cancellationReason',
        type: NotificationTypes.bookingCancelled,
        category: NotificationCategory.booking,
        priority: NotificationPriority.high,
        data: {
          'bookingId': booking.id,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'scheduledDate': booking.scheduledDate.toIso8601String(),
          'timeSlot': booking.timeSlot,
          'cancellationReason': cancellationReason,
          'cancelledBy': cancelledBy ?? 'system',
          'status': booking.status.name,
        },
        actionUrl: '/booking/${booking.id}',
      );

      // If booking had a partner, notify them too
      if (booking.partnerId.isNotEmpty) {
        await _sendNotificationToUser(
          userId: booking.partnerId,
          title: 'Công việc đã bị hủy',
          body:
              'Công việc ${booking.serviceName} đã bị hủy. Lý do: $cancellationReason',
          type: NotificationTypes.jobCancelled,
          category: NotificationCategory.job,
          priority: NotificationPriority.high,
          data: {
            'bookingId': booking.id,
            'jobId': booking.id,
            'serviceId': booking.serviceId,
            'serviceName': booking.serviceName,
            'scheduledDate': booking.scheduledDate.toIso8601String(),
            'timeSlot': booking.timeSlot,
            'cancellationReason': cancellationReason,
            'cancelledBy': cancelledBy ?? 'system',
            'status': booking.status.name,
          },
          actionUrl: '/partner/job/${booking.id}',
        );
      }

      developer.log(
        'Booking cancelled notification sent for booking: ${booking.id}',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending booking cancelled notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send booking cancelled notification: $e'),
      );
    }
  }

  /// Send booking reminder notification
  Future<Either<Failure, void>> notifyBookingReminder(
    Booking booking,
    String partnerName, {
    int hoursBeforeService = 2,
  }) async {
    try {
      // Notify client about upcoming booking
      await _sendNotificationToUser(
        userId: booking.userId,
        title: 'Nhắc nhở dịch vụ',
        body:
            'Dịch vụ ${booking.serviceName} với $partnerName sẽ bắt đầu trong $hoursBeforeService giờ nữa.',
        type: NotificationTypes.bookingReminder,
        category: NotificationCategory.reminder,
        priority: NotificationPriority.normal,
        data: {
          'bookingId': booking.id,
          'partnerId': booking.partnerId,
          'partnerName': partnerName,
          'serviceId': booking.serviceId,
          'serviceName': booking.serviceName,
          'scheduledDate': booking.scheduledDate.toIso8601String(),
          'timeSlot': booking.timeSlot,
          'hoursBeforeService': hoursBeforeService,
          'status': booking.status.name,
        },
        actionUrl: '/booking/${booking.id}',
      );

      developer.log(
        'Booking reminder notification sent for booking: ${booking.id}',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending booking reminder notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send booking reminder notification: $e'),
      );
    }
  }

  // ============================================================================
  // PARTNER JOB NOTIFICATION METHODS
  // ============================================================================

  /// Send notification when a new job is available for partner
  Future<Either<Failure, void>> notifyNewJobAvailable(Job job) async {
    try {
      // Get client info for job details
      final clientResult = await _userRepository.getById(job.userId);
      String clientName = job.clientName;
      if (clientResult.isRight()) {
        final client = (clientResult as Right).value;
        if (client != null) {
          clientName = client.name;
        }
      }

      // Notify partner about new job
      await _sendNotificationToUser(
        userId: job.partnerId,
        title: 'Công việc mới',
        body:
            'Có công việc ${job.serviceName} mới từ $clientName vào ${job.formattedDateTime}.',
        type: NotificationTypes.newJobAvailable,
        category: NotificationCategory.job,
        priority: NotificationPriority.high,
        data: {
          'jobId': job.id,
          'bookingId': job.bookingId,
          'userId': job.userId,
          'clientName': clientName,
          'serviceId': job.serviceId,
          'serviceName': job.serviceName,
          'scheduledDate': job.scheduledDate.toIso8601String(),
          'timeSlot': job.timeSlot,
          'totalPrice': job.totalPrice,
          'partnerEarnings': job.partnerEarnings,
          'priority': job.priority.name,
          'status': job.status.name,
        },
        actionUrl: '/partner/job/${job.id}',
      );

      developer.log(
        'New job available notification sent for job: ${job.id}',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending new job available notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send new job available notification: $e'),
      );
    }
  }

  /// Send notification when a job is accepted by partner
  Future<Either<Failure, void>> notifyJobAccepted(Job job) async {
    try {
      // Get partner info
      final partnerResult = await _userRepository.getById(job.partnerId);
      String partnerName = 'Partner';
      if (partnerResult.isRight()) {
        final partner = (partnerResult as Right).value;
        if (partner != null) {
          partnerName = partner.name;
        }
      }

      // Notify client about job acceptance
      await _sendNotificationToUser(
        userId: job.userId,
        title: 'Đặt lịch đã được nhận',
        body: '$partnerName đã nhận công việc ${job.serviceName} của bạn.',
        type: NotificationTypes.jobAccepted,
        category: NotificationCategory.booking,
        priority: NotificationPriority.high,
        data: {
          'jobId': job.id,
          'bookingId': job.bookingId,
          'partnerId': job.partnerId,
          'partnerName': partnerName,
          'serviceId': job.serviceId,
          'serviceName': job.serviceName,
          'scheduledDate': job.scheduledDate.toIso8601String(),
          'timeSlot': job.timeSlot,
          'status': job.status.name,
        },
        actionUrl: '/booking/${job.bookingId}',
      );

      developer.log(
        'Job accepted notification sent for job: ${job.id}',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending job accepted notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send job accepted notification: $e'),
      );
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Send notification to a specific user with preference checking
  Future<Either<Failure, void>> _sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String type,
    required NotificationCategory category,
    required NotificationPriority priority,
    required Map<String, dynamic> data,
    String? actionUrl,
    String? imageUrl,
  }) async {
    try {
      // Check user notification preferences
      final preferencesResult = await _getNotificationPreferences(
        GetNotificationPreferencesParams(userId: userId),
      );
      if (preferencesResult.isLeft()) {
        developer.log(
          'Failed to get notification preferences for user: $userId',
          name: 'NotificationIntegrationService',
        );
        // Continue with default preferences
      }

      // Create notification
      final createResult = await _createNotification(
        CreateNotificationParams(
          userId: userId,
          title: title,
          body: body,
          type: type,
          data: data,
          priority: priority,
          category: category,
          actionUrl: actionUrl,
          imageUrl: imageUrl,
        ),
      );

      if (createResult.isLeft()) {
        return Left(ServerFailure('Failed to create notification'));
      }

      final notification = (createResult as Right).value;

      // Send push notification if preferences allow
      if (preferencesResult.isRight()) {
        final preferences = (preferencesResult as Right).value;
        if (preferences.shouldShowNotification(notification)) {
          await _sendPushNotification(
            SendPushNotificationParams(
              userId: userId,
              title: title,
              body: body,
              data: data,
            ),
          );
        }
      } else {
        // Send push notification with default behavior
        await _sendPushNotification(
          SendPushNotificationParams(
            userId: userId,
            title: title,
            body: body,
            data: data,
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending notification to user $userId: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(ServerFailure('Failed to send notification: $e'));
    }
  }

  /// Send notification when partner earnings are updated
  Future<Either<Failure, void>> notifyEarningsUpdate(
    String partnerId,
    double newEarnings,
    double totalEarnings,
    String jobId,
  ) async {
    try {
      await _sendNotificationToUser(
        userId: partnerId,
        title: 'Thu nhập cập nhật',
        body:
            'Bạn đã nhận được ${newEarnings.toStringAsFixed(0)}k VND. Tổng thu nhập: ${totalEarnings.toStringAsFixed(0)}k VND.',
        type: NotificationTypes.earningsUpdate,
        category: NotificationCategory.payment,
        priority: NotificationPriority.normal,
        data: {
          'jobId': jobId,
          'newEarnings': newEarnings,
          'totalEarnings': totalEarnings,
          'timestamp': DateTime.now().toIso8601String(),
        },
        actionUrl: '/partner/earnings',
      );

      developer.log(
        'Earnings update notification sent for partner: $partnerId',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending earnings update notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send earnings update notification: $e'),
      );
    }
  }

  /// Send notification when payment is received
  Future<Either<Failure, void>> notifyPaymentReceived(
    String userId,
    double amount,
    String bookingId,
    String serviceName,
  ) async {
    try {
      await _sendNotificationToUser(
        userId: userId,
        title: 'Thanh toán thành công',
        body:
            'Thanh toán ${amount.toStringAsFixed(0)}k VND cho dịch vụ $serviceName đã thành công.',
        type: NotificationTypes.paymentReceived,
        category: NotificationCategory.payment,
        priority: NotificationPriority.normal,
        data: {
          'bookingId': bookingId,
          'serviceName': serviceName,
          'amount': amount,
          'timestamp': DateTime.now().toIso8601String(),
        },
        actionUrl: '/booking/$bookingId',
      );

      developer.log(
        'Payment received notification sent for user: $userId',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending payment received notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send payment received notification: $e'),
      );
    }
  }

  /// Send notification when payment fails
  Future<Either<Failure, void>> notifyPaymentFailed(
    String userId,
    double amount,
    String bookingId,
    String serviceName,
    String reason,
  ) async {
    try {
      await _sendNotificationToUser(
        userId: userId,
        title: 'Thanh toán thất bại',
        body:
            'Thanh toán ${amount.toStringAsFixed(0)}k VND cho dịch vụ $serviceName thất bại. Lý do: $reason',
        type: NotificationTypes.paymentFailed,
        category: NotificationCategory.payment,
        priority: NotificationPriority.high,
        data: {
          'bookingId': bookingId,
          'serviceName': serviceName,
          'amount': amount,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        },
        actionUrl: '/booking/$bookingId',
      );

      developer.log(
        'Payment failed notification sent for user: $userId',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending payment failed notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send payment failed notification: $e'),
      );
    }
  }

  /// Send system maintenance notification
  Future<Either<Failure, void>> notifySystemMaintenance(
    String userId,
    String title,
    String message,
    DateTime? scheduledTime,
  ) async {
    try {
      await _sendNotificationToUser(
        userId: userId,
        title: title,
        body: message,
        type: NotificationTypes.systemMaintenance,
        category: NotificationCategory.system,
        priority: NotificationPriority.normal,
        data: {
          'scheduledTime': scheduledTime?.toIso8601String(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      developer.log(
        'System maintenance notification sent for user: $userId',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending system maintenance notification: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(
        ServerFailure('Failed to send system maintenance notification: $e'),
      );
    }
  }

  /// Send bulk notifications to multiple users
  Future<Either<Failure, void>> sendBulkNotifications(
    List<String> userIds,
    String title,
    String body,
    String type,
    NotificationCategory category,
    NotificationPriority priority,
    Map<String, dynamic> data,
  ) async {
    try {
      final futures = userIds.map(
        (userId) => _sendNotificationToUser(
          userId: userId,
          title: title,
          body: body,
          type: type,
          category: category,
          priority: priority,
          data: data,
        ),
      );

      await Future.wait(futures);

      developer.log(
        'Bulk notifications sent to ${userIds.length} users',
        name: 'NotificationIntegrationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error sending bulk notifications: $e',
        name: 'NotificationIntegrationService',
      );
      return Left(ServerFailure('Failed to send bulk notifications: $e'));
    }
  }
}
