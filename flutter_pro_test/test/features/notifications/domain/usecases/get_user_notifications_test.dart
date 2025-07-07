import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/features/notifications/domain/entities/notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/get_user_notifications.dart';

import 'get_user_notifications_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late GetUserNotifications usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = GetUserNotifications(mockRepository);
  });

  const testUserId = 'test_user_id';
  const testLimit = 20;
  const testLastNotificationId = 'last_notification_id';

  final testNotifications = [
    NotificationEntity(
      id: '1',
      userId: testUserId,
      title: 'Test Notification 1',
      body: 'Test body 1',
      type: 'test_type',
      data: const {'key': 'value'},
      createdAt: DateTime.now(),
      isRead: false,
      priority: NotificationPriority.normal,
      category: NotificationCategory.system,
      isScheduled: false,
      isPersistent: false,
    ),
    NotificationEntity(
      id: '2',
      userId: testUserId,
      title: 'Test Notification 2',
      body: 'Test body 2',
      type: 'test_type',
      data: const {'key': 'value'},
      createdAt: DateTime.now(),
      isRead: true,
      priority: NotificationPriority.high,
      category: NotificationCategory.booking,
      isScheduled: false,
      isPersistent: false,
    ),
  ];

  group('GetUserNotifications', () {
    test('should get notifications from the repository', () async {
      // arrange
      when(
        mockRepository.getUserNotifications(
          testUserId,
          limit: testLimit,
          lastNotificationId: testLastNotificationId,
        ),
      ).thenAnswer((_) async => Right(testNotifications));

      // act
      final result = await usecase(
        const GetUserNotificationsParams(
          userId: testUserId,
          limit: testLimit,
          lastNotificationId: testLastNotificationId,
        ),
      );

      // assert
      expect(result, Right(testNotifications));
      verify(
        mockRepository.getUserNotifications(
          testUserId,
          limit: testLimit,
          lastNotificationId: testLastNotificationId,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      const testFailure = ServerFailure('Server error');
      when(
        mockRepository.getUserNotifications(
          testUserId,
          limit: testLimit,
          lastNotificationId: testLastNotificationId,
        ),
      ).thenAnswer((_) async => const Left(testFailure));

      // act
      final result = await usecase(
        const GetUserNotificationsParams(
          userId: testUserId,
          limit: testLimit,
          lastNotificationId: testLastNotificationId,
        ),
      );

      // assert
      expect(result, const Left(testFailure));
      verify(
        mockRepository.getUserNotifications(
          testUserId,
          limit: testLimit,
          lastNotificationId: testLastNotificationId,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test('should work with minimal parameters', () async {
      // arrange
      when(
        mockRepository.getUserNotifications(
          testUserId,
          limit: null,
          lastNotificationId: null,
        ),
      ).thenAnswer((_) async => Right(testNotifications));

      // act
      final result = await usecase(
        const GetUserNotificationsParams(userId: testUserId),
      );

      // assert
      expect(result, Right(testNotifications));
      verify(
        mockRepository.getUserNotifications(
          testUserId,
          limit: null,
          lastNotificationId: null,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetUserNotificationsParams', () {
    test('should have correct props', () {
      const params1 = GetUserNotificationsParams(
        userId: testUserId,
        limit: testLimit,
        lastNotificationId: testLastNotificationId,
      );
      const params2 = GetUserNotificationsParams(
        userId: testUserId,
        limit: testLimit,
        lastNotificationId: testLastNotificationId,
      );
      const params3 = GetUserNotificationsParams(
        userId: 'different_user',
        limit: testLimit,
        lastNotificationId: testLastNotificationId,
      );

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
      expect(params1.props, [testUserId, testLimit, testLastNotificationId]);
    });
  });
}
