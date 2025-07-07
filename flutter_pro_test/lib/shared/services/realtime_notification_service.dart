import 'dart:async';
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/partner/domain/repositories/partner_job_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'notification_integration_service.dart';

/// Service for managing real-time notification listeners and badge counts
class RealtimeNotificationService {
  final NotificationRepository _notificationRepository;
  final BookingRepository _bookingRepository;
  final PartnerJobRepository _partnerJobRepository;
  final AuthRepository _authRepository;
  final NotificationIntegrationService _notificationIntegrationService;

  // Stream controllers for real-time updates
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();
  final StreamController<List<NotificationEntity>> _notificationsController =
      StreamController<List<NotificationEntity>>.broadcast();
  final StreamController<NotificationEntity> _newNotificationController =
      StreamController<NotificationEntity>.broadcast();

  // Stream subscriptions
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _unreadCountSubscription;
  StreamSubscription? _bookingSubscription;
  StreamSubscription? _jobSubscription;

  // Current user ID
  String? _currentUserId;

  RealtimeNotificationService({
    required NotificationRepository notificationRepository,
    required BookingRepository bookingRepository,
    required PartnerJobRepository partnerJobRepository,
    required AuthRepository authRepository,
    required NotificationIntegrationService notificationIntegrationService,
  }) : _notificationRepository = notificationRepository,
       _bookingRepository = bookingRepository,
       _partnerJobRepository = partnerJobRepository,
       _authRepository = authRepository,
       _notificationIntegrationService = notificationIntegrationService;

  // Getters for streams
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  Stream<List<NotificationEntity>> get notificationsStream =>
      _notificationsController.stream;
  Stream<NotificationEntity> get newNotificationStream =>
      _newNotificationController.stream;

  /// Initialize real-time notification listeners for a user
  Future<Either<Failure, void>> initializeForUser(String userId) async {
    try {
      _currentUserId = userId;

      // Stop any existing listeners
      await stopListening();

      // Start notification listeners
      await _startNotificationListeners(userId);

      // Start booking/job listeners for automatic notifications
      await _startBookingJobListeners(userId);

      developer.log(
        'Real-time notification listeners initialized for user: $userId',
        name: 'RealtimeNotificationService',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error initializing real-time notification listeners: $e',
        name: 'RealtimeNotificationService',
      );
      return Left(
        ServerFailure('Failed to initialize notification listeners: $e'),
      );
    }
  }

  /// Start notification listeners
  Future<void> _startNotificationListeners(String userId) async {
    // Listen to user notifications
    _notificationsSubscription = _notificationRepository
        .listenToUserNotifications(userId)
        .listen((result) {
          result.fold(
            (failure) => developer.log(
              'Error in notifications stream: ${failure.message}',
              name: 'RealtimeNotificationService',
            ),
            (notifications) {
              _notificationsController.add(notifications);

              // Check for new notifications and emit them
              _checkForNewNotifications(notifications);
            },
          );
        });

    // Listen to unread count
    _unreadCountSubscription = _notificationRepository
        .listenToUnreadCount(userId)
        .listen((result) {
          result.fold(
            (failure) => developer.log(
              'Error in unread count stream: ${failure.message}',
              name: 'RealtimeNotificationService',
            ),
            (count) => _unreadCountController.add(count),
          );
        });
  }

  /// Start booking and job listeners for automatic notifications
  Future<void> _startBookingJobListeners(String userId) async {
    // Listen to user bookings for clients
    _bookingSubscription = _bookingRepository
        .listenToUserBookings(userId)
        .listen((result) {
          result.fold(
            (failure) => developer.log(
              'Error in booking stream: ${failure.message}',
              name: 'RealtimeNotificationService',
            ),
            (bookings) => _handleBookingUpdates(bookings),
          );
        });

    // Listen to partner jobs if user is a partner
    _jobSubscription = _partnerJobRepository.listenToActiveJobs(userId).listen((
      result,
    ) {
      result.fold(
        (failure) => developer.log(
          'Error in job stream: ${failure.message}',
          name: 'RealtimeNotificationService',
        ),
        (jobs) => _handleJobUpdates(jobs),
      );
    });
  }

  /// Check for new notifications and emit them
  void _checkForNewNotifications(List<NotificationEntity> notifications) {
    // This is a simplified implementation
    // In a real app, you'd want to track which notifications are truly "new"
    // by comparing with previously received notifications

    final recentNotifications = notifications
        .where(
          (notification) =>
              DateTime.now().difference(notification.createdAt).inMinutes < 5,
        )
        .toList();

    for (final notification in recentNotifications) {
      if (!notification.isRead) {
        _newNotificationController.add(notification);
      }
    }
  }

  /// Handle booking updates and trigger notifications if needed
  void _handleBookingUpdates(List<dynamic> bookings) {
    // This method can be used to trigger additional notifications
    // based on booking state changes detected in real-time
    developer.log(
      'Received booking updates: ${bookings.length} bookings',
      name: 'RealtimeNotificationService',
    );
  }

  /// Handle job updates and trigger notifications if needed
  void _handleJobUpdates(List<dynamic> jobs) {
    // This method can be used to trigger additional notifications
    // based on job state changes detected in real-time
    developer.log(
      'Received job updates: ${jobs.length} jobs',
      name: 'RealtimeNotificationService',
    );
  }

  /// Get current unread notification count
  Future<Either<Failure, int>> getCurrentUnreadCount() async {
    if (_currentUserId == null) {
      return Left(ValidationFailure('No user initialized'));
    }

    try {
      final result = await _notificationRepository.getUnreadNotifications(
        _currentUserId!,
      );
      return result.fold(
        (failure) => Left(failure),
        (notifications) => Right(notifications.length),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get unread count: $e'));
    }
  }

  /// Mark notification as read and update streams
  Future<Either<Failure, void>> markNotificationAsRead(
    String notificationId,
  ) async {
    if (_currentUserId == null) {
      return Left(ValidationFailure('No user initialized'));
    }

    try {
      final result = await _notificationRepository.markAsRead(notificationId);

      // The streams will automatically update due to the listeners
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to mark notification as read: $e'));
    }
  }

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllNotificationsAsRead() async {
    if (_currentUserId == null) {
      return Left(ValidationFailure('No user initialized'));
    }

    try {
      final result = await _notificationRepository.markAllAsRead(
        _currentUserId!,
      );
      return result;
    } catch (e) {
      return Left(
        ServerFailure('Failed to mark all notifications as read: $e'),
      );
    }
  }

  /// Send a test notification (for debugging)
  Future<Either<Failure, void>> sendTestNotification() async {
    if (_currentUserId == null) {
      return Left(ValidationFailure('No user initialized'));
    }

    return await _notificationIntegrationService.sendBulkNotifications(
      [_currentUserId!],
      'Test Notification',
      'This is a test notification from the real-time service',
      'test',
      NotificationCategory.system,
      NotificationPriority.normal,
      {'test': true, 'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Stop all listeners and clean up resources
  Future<void> stopListening() async {
    await _notificationsSubscription?.cancel();
    await _unreadCountSubscription?.cancel();
    await _bookingSubscription?.cancel();
    await _jobSubscription?.cancel();

    _notificationsSubscription = null;
    _unreadCountSubscription = null;
    _bookingSubscription = null;
    _jobSubscription = null;

    developer.log(
      'Real-time notification listeners stopped',
      name: 'RealtimeNotificationService',
    );
  }

  /// Dispose of all resources
  void dispose() {
    stopListening();
    _unreadCountController.close();
    _notificationsController.close();
    _newNotificationController.close();
  }
}
