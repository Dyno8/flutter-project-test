import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
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

import 'notification_bloc_test.mocks.dart';

@GenerateMocks([
  GetUserNotifications,
  GetUnreadNotifications,
  MarkNotificationAsRead,
  CreateNotification,
  SendPushNotification,
  GetNotificationPreferences,
  UpdateNotificationPreferences,
  NotificationRepository,
])
void main() {
  late NotificationBloc bloc;
  late MockGetUserNotifications mockGetUserNotifications;
  late MockGetUnreadNotifications mockGetUnreadNotifications;
  late MockMarkNotificationAsRead mockMarkNotificationAsRead;
  late MockCreateNotification mockCreateNotification;
  late MockSendPushNotification mockSendPushNotification;
  late MockGetNotificationPreferences mockGetNotificationPreferences;
  late MockUpdateNotificationPreferences mockUpdateNotificationPreferences;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockGetUserNotifications = MockGetUserNotifications();
    mockGetUnreadNotifications = MockGetUnreadNotifications();
    mockMarkNotificationAsRead = MockMarkNotificationAsRead();
    mockCreateNotification = MockCreateNotification();
    mockSendPushNotification = MockSendPushNotification();
    mockGetNotificationPreferences = MockGetNotificationPreferences();
    mockUpdateNotificationPreferences = MockUpdateNotificationPreferences();
    mockRepository = MockNotificationRepository();

    bloc = NotificationBloc(
      getUserNotifications: mockGetUserNotifications,
      getUnreadNotifications: mockGetUnreadNotifications,
      markNotificationAsRead: mockMarkNotificationAsRead,
      createNotification: mockCreateNotification,
      sendPushNotification: mockSendPushNotification,
      getNotificationPreferences: mockGetNotificationPreferences,
      updateNotificationPreferences: mockUpdateNotificationPreferences,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const testUserId = 'test_user_id';
  const testNotificationId = 'test_notification_id';

  final testNotification = NotificationEntity(
    id: testNotificationId,
    userId: testUserId,
    title: 'Test Notification',
    body: 'Test body',
    type: 'test_type',
    data: const {'key': 'value'},
    createdAt: DateTime.now(),
    isRead: false,
    priority: NotificationPriority.normal,
    category: NotificationCategory.system,
    isScheduled: false,
    isPersistent: false,
  );

  final testNotifications = [testNotification];

  group('NotificationBloc', () {
    test('initial state should be NotificationInitial', () {
      expect(bloc.state, equals(const NotificationInitial()));
    });

    group('LoadUserNotificationsEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should emit [NotificationLoading, NotificationsLoaded] when successful',
        build: () {
          when(
            mockGetUserNotifications(any),
          ).thenAnswer((_) async => Right(testNotifications));
          when(
            mockRepository.getUnreadCount(testUserId),
          ).thenAnswer((_) async => const Right(1));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const LoadUserNotificationsEvent(userId: testUserId)),
        expect: () => [
          const NotificationLoading(),
          NotificationsLoaded(
            notifications: testNotifications,
            unreadCount: 1,
            hasMore: false,
            lastNotificationId: testNotificationId,
          ),
        ],
        verify: (_) {
          verify(
            mockGetUserNotifications(
              const GetUserNotificationsParams(
                userId: testUserId,
                limit: null,
                lastNotificationId: null,
              ),
            ),
          );
          verify(mockRepository.getUnreadCount(testUserId));
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'should emit [NotificationLoading, NotificationError] when fails',
        build: () {
          when(
            mockGetUserNotifications(any),
          ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const LoadUserNotificationsEvent(userId: testUserId)),
        expect: () => [
          const NotificationLoading(),
          const NotificationError(message: 'Server error'),
        ],
        verify: (_) {
          verify(
            mockGetUserNotifications(
              const GetUserNotificationsParams(
                userId: testUserId,
                limit: null,
                lastNotificationId: null,
              ),
            ),
          );
        },
      );
    });

    group('MarkNotificationAsReadEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should emit [NotificationMarkedAsRead] when successful',
        build: () {
          when(
            mockMarkNotificationAsRead(any),
          ).thenAnswer((_) async => Right(testNotification.markAsRead()));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const MarkNotificationAsReadEvent(notificationId: testNotificationId),
        ),
        expect: () => [
          isA<NotificationMarkedAsRead>()
              .having((state) => state.notification.isRead, 'isRead', true)
              .having(
                (state) => state.notification.id,
                'id',
                testNotificationId,
              ),
        ],
        verify: (_) {
          verify(
            mockMarkNotificationAsRead(
              const MarkNotificationAsReadParams(
                notificationId: testNotificationId,
              ),
            ),
          );
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'should emit [NotificationError] when fails',
        build: () {
          when(
            mockMarkNotificationAsRead(any),
          ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const MarkNotificationAsReadEvent(notificationId: testNotificationId),
        ),
        expect: () => [const NotificationError(message: 'Server error')],
        verify: (_) {
          verify(
            mockMarkNotificationAsRead(
              const MarkNotificationAsReadParams(
                notificationId: testNotificationId,
              ),
            ),
          );
        },
      );
    });

    group('CreateNotificationEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should emit [NotificationCreated] when successful',
        build: () {
          when(
            mockCreateNotification(any),
          ).thenAnswer((_) async => Right(testNotification));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const CreateNotificationEvent(
            userId: testUserId,
            title: 'Test Notification',
            body: 'Test body',
            type: 'test_type',
            data: {'key': 'value'},
          ),
        ),
        expect: () => [NotificationCreated(notification: testNotification)],
        verify: (_) {
          verify(mockCreateNotification(any));
        },
      );
    });

    group('LoadNotificationPreferencesEvent', () {
      final testPreferences = NotificationPreferences.defaultPreferences(
        testUserId,
      );

      blocTest<NotificationBloc, NotificationState>(
        'should emit [NotificationLoading, NotificationPreferencesLoaded] when successful',
        build: () {
          when(
            mockGetNotificationPreferences(any),
          ).thenAnswer((_) async => Right(testPreferences));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const LoadNotificationPreferencesEvent(userId: testUserId),
        ),
        expect: () => [
          const NotificationLoading(),
          NotificationPreferencesLoaded(preferences: testPreferences),
        ],
        verify: (_) {
          verify(
            mockGetNotificationPreferences(
              const GetNotificationPreferencesParams(userId: testUserId),
            ),
          );
        },
      );
    });

    group('UpdateNotificationPreferencesEvent', () {
      final testPreferences = NotificationPreferences.defaultPreferences(
        testUserId,
      );

      blocTest<NotificationBloc, NotificationState>(
        'should emit [NotificationPreferencesUpdated] when successful',
        build: () {
          when(
            mockUpdateNotificationPreferences(any),
          ).thenAnswer((_) async => Right(testPreferences));
          return bloc;
        },
        act: (bloc) => bloc.add(
          UpdateNotificationPreferencesEvent(preferences: testPreferences),
        ),
        expect: () => [
          NotificationPreferencesUpdated(preferences: testPreferences),
        ],
        verify: (_) {
          verify(
            mockUpdateNotificationPreferences(
              UpdateNotificationPreferencesParams(preferences: testPreferences),
            ),
          );
        },
      );
    });

    group('SendPushNotificationEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should emit [PushNotificationSent] when successful',
        build: () {
          when(
            mockSendPushNotification(any),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const SendPushNotificationEvent(
            userId: testUserId,
            title: 'Test Push',
            body: 'Test push body',
          ),
        ),
        expect: () => [const PushNotificationSent()],
        verify: (_) {
          verify(
            mockSendPushNotification(
              const SendPushNotificationParams(
                userId: testUserId,
                title: 'Test Push',
                body: 'Test push body',
              ),
            ),
          );
        },
      );
    });

    group('ClearNotificationErrorEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should emit [NotificationInitial] when clearing error',
        build: () => bloc,
        seed: () => const NotificationError(message: 'Test error'),
        act: (bloc) => bloc.add(const ClearNotificationErrorEvent()),
        expect: () => [const NotificationInitial()],
      );
    });
  });
}
