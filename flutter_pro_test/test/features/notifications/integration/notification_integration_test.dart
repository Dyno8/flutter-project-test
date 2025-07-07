import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/features/notifications/domain/entities/notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/entities/notification_preferences.dart';
import 'package:flutter_pro_test/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/get_user_notifications.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/get_unread_notifications.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/create_notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/send_push_notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/get_notification_preferences.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/update_notification_preferences.dart';
import 'package:flutter_pro_test/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:flutter_pro_test/features/notifications/presentation/bloc/notification_event.dart';
import 'package:flutter_pro_test/features/notifications/presentation/bloc/notification_state.dart';

import 'notification_integration_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  group('Notification System Integration Tests', () {
    late NotificationBloc bloc;
    late MockNotificationRepository mockRepository;
    late GetUserNotifications getUserNotifications;
    late GetUnreadNotifications getUnreadNotifications;
    late MarkNotificationAsRead markNotificationAsRead;
    late CreateNotification createNotification;
    late SendPushNotification sendPushNotification;
    late GetNotificationPreferences getNotificationPreferences;
    late UpdateNotificationPreferences updateNotificationPreferences;

    setUp(() {
      mockRepository = MockNotificationRepository();

      // Initialize use cases with mock repository
      getUserNotifications = GetUserNotifications(mockRepository);
      getUnreadNotifications = GetUnreadNotifications(mockRepository);
      markNotificationAsRead = MarkNotificationAsRead(mockRepository);
      createNotification = CreateNotification(mockRepository);
      sendPushNotification = SendPushNotification(mockRepository);
      getNotificationPreferences = GetNotificationPreferences(mockRepository);
      updateNotificationPreferences = UpdateNotificationPreferences(
        mockRepository,
      );

      // Initialize BLoC with use cases
      bloc = NotificationBloc(
        getUserNotifications: getUserNotifications,
        getUnreadNotifications: getUnreadNotifications,
        markNotificationAsRead: markNotificationAsRead,
        createNotification: createNotification,
        sendPushNotification: sendPushNotification,
        getNotificationPreferences: getNotificationPreferences,
        updateNotificationPreferences: updateNotificationPreferences,
        repository: mockRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    const testUserId = 'test_user_id';

    final testNotifications = [
      NotificationEntity(
        id: '1',
        userId: testUserId,
        title: 'Booking Confirmed',
        body: 'Your booking has been confirmed',
        type: NotificationTypes.bookingConfirmed,
        data: const {'bookingId': 'booking_1'},
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        priority: NotificationPriority.high,
        category: NotificationCategory.booking,
        isScheduled: false,
        isPersistent: false,
      ),
      NotificationEntity(
        id: '2',
        userId: testUserId,
        title: 'Payment Received',
        body: 'Payment of \$50 received',
        type: NotificationTypes.paymentReceived,
        data: const {'amount': '50', 'currency': 'USD'},
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        priority: NotificationPriority.normal,
        category: NotificationCategory.payment,
        isScheduled: false,
        isPersistent: false,
        readAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    test('should complete full notification workflow', () async {
      // Setup mock responses
      when(
        mockRepository.getUserNotifications(testUserId),
      ).thenAnswer((_) async => Right(testNotifications));
      when(
        mockRepository.getUnreadCount(testUserId),
      ).thenAnswer((_) async => const Right(1));
      when(
        mockRepository.markAsRead('1'),
      ).thenAnswer((_) async => Right(testNotifications[0].markAsRead()));

      // Test 1: Load notifications
      bloc.add(const LoadUserNotificationsEvent(userId: testUserId));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const NotificationLoading(),
          NotificationsLoaded(
            notifications: testNotifications,
            unreadCount: 1,
            hasMore: false,
            lastNotificationId: '2',
          ),
        ]),
      );

      // Test 2: Mark notification as read
      bloc.add(const MarkNotificationAsReadEvent(notificationId: '1'));

      await expectLater(
        bloc.stream,
        emits(
          NotificationMarkedAsRead(
            notification: testNotifications[0].markAsRead(),
          ),
        ),
      );

      // Verify interactions
      verify(mockRepository.getUserNotifications(testUserId)).called(1);
      verify(mockRepository.getUnreadCount(testUserId)).called(1);
      verify(mockRepository.markAsRead('1')).called(1);
    });

    test('should handle notification preferences workflow', () async {
      final testPreferences = NotificationPreferences.defaultPreferences(
        testUserId,
      );
      final updatedPreferences = testPreferences.copyWith(soundEnabled: false);

      // Setup mock responses
      when(
        mockRepository.getNotificationPreferences(testUserId),
      ).thenAnswer((_) async => Right(testPreferences));
      when(
        mockRepository.updateNotificationPreferences(any),
      ).thenAnswer((_) async => Right(updatedPreferences));

      // Test 1: Load preferences
      bloc.add(const LoadNotificationPreferencesEvent(userId: testUserId));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const NotificationLoading(),
          NotificationPreferencesLoaded(preferences: testPreferences),
        ]),
      );

      // Test 2: Update preferences
      bloc.add(
        UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
      );

      await expectLater(
        bloc.stream,
        emits(NotificationPreferencesUpdated(preferences: updatedPreferences)),
      );

      // Verify interactions
      verify(mockRepository.getNotificationPreferences(testUserId)).called(1);
      verify(mockRepository.updateNotificationPreferences(any)).called(1);
    });

    test('should handle notification creation workflow', () async {
      final newNotification = NotificationEntity(
        id: '3',
        userId: testUserId,
        title: 'New Job Available',
        body: 'A new job is available in your area',
        type: NotificationTypes.newJobAvailable,
        data: const {'jobId': 'job_123'},
        createdAt: DateTime.now(),
        isRead: false,
        priority: NotificationPriority.high,
        category: NotificationCategory.job,
        isScheduled: false,
        isPersistent: false,
      );

      // Setup mock response
      when(
        mockRepository.createNotification(any),
      ).thenAnswer((_) async => Right(newNotification));

      // Test: Create notification
      bloc.add(
        const CreateNotificationEvent(
          userId: testUserId,
          title: 'New Job Available',
          body: 'A new job is available in your area',
          type: NotificationTypes.newJobAvailable,
          data: {'jobId': 'job_123'},
          priority: NotificationPriority.high,
          category: NotificationCategory.job,
        ),
      );

      await expectLater(
        bloc.stream,
        emits(NotificationCreated(notification: newNotification)),
      );

      // Verify interaction
      verify(mockRepository.createNotification(any)).called(1);
    });

    test('should handle category filtering', () async {
      final bookingNotifications = testNotifications
          .where((n) => n.category == NotificationCategory.booking)
          .toList();

      // Setup mock response
      when(
        mockRepository.getNotificationsByCategory(
          testUserId,
          NotificationCategory.booking,
          limit: null,
        ),
      ).thenAnswer((_) async => Right(bookingNotifications));

      // Test: Load notifications by category
      bloc.add(
        const LoadNotificationsByCategoryEvent(
          userId: testUserId,
          category: NotificationCategory.booking,
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const NotificationLoading(),
          NotificationsByCategoryLoaded(
            notifications: bookingNotifications,
            category: NotificationCategory.booking,
          ),
        ]),
      );

      // Verify interaction
      verify(
        mockRepository.getNotificationsByCategory(
          testUserId,
          NotificationCategory.booking,
          limit: null,
        ),
      ).called(1);
    });

    test('should handle push notification sending', () async {
      // Setup mock response
      when(
        mockRepository.sendPushNotification(
          userId: testUserId,
          title: 'Test Push',
          body: 'Test push notification',
          data: null,
          imageUrl: null,
        ),
      ).thenAnswer((_) async => const Right(null));

      // Test: Send push notification
      bloc.add(
        const SendPushNotificationEvent(
          userId: testUserId,
          title: 'Test Push',
          body: 'Test push notification',
        ),
      );

      await expectLater(bloc.stream, emits(const PushNotificationSent()));

      // Verify interaction
      verify(
        mockRepository.sendPushNotification(
          userId: testUserId,
          title: 'Test Push',
          body: 'Test push notification',
          data: null,
          imageUrl: null,
        ),
      ).called(1);
    });

    test('should handle bulk operations', () async {
      // Setup mock responses
      when(
        mockRepository.markAllAsRead(testUserId),
      ).thenAnswer((_) async => const Right(null));
      when(
        mockRepository.deleteAllNotifications(testUserId),
      ).thenAnswer((_) async => const Right(null));

      // Test 1: Mark all as read
      bloc.add(const MarkAllNotificationsAsReadEvent(userId: testUserId));

      await expectLater(
        bloc.stream,
        emits(const AllNotificationsMarkedAsRead()),
      );

      // Test 2: Delete all notifications
      bloc.add(const DeleteAllNotificationsEvent(userId: testUserId));

      await expectLater(bloc.stream, emits(const AllNotificationsDeleted()));

      // Verify interactions
      verify(mockRepository.markAllAsRead(testUserId)).called(1);
      verify(mockRepository.deleteAllNotifications(testUserId)).called(1);
    });

    test('should handle error scenarios gracefully', () async {
      // Setup mock error response
      when(
        mockRepository.getUserNotifications(testUserId),
      ).thenAnswer((_) async => Left(ServerFailure('Network error')));

      // Test: Load notifications with error
      bloc.add(const LoadUserNotificationsEvent(userId: testUserId));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const NotificationLoading(),
          const NotificationError(message: 'Network error'),
        ]),
      );

      // Test: Clear error
      bloc.add(const ClearNotificationErrorEvent());

      await expectLater(bloc.stream, emits(const NotificationInitial()));

      // Verify interaction
      verify(mockRepository.getUserNotifications(testUserId)).called(1);
    });
  });
}
