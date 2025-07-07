import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pro_test/core/errors/exceptions.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/features/notifications/domain/entities/notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/entities/notification_preferences.dart';
import 'package:flutter_pro_test/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_pro_test/features/notifications/data/models/notification_model.dart';
import 'package:flutter_pro_test/features/notifications/data/models/notification_preferences_model.dart';
import 'package:flutter_pro_test/features/notifications/data/repositories/notification_repository_impl.dart';

import 'notification_repository_impl_test.mocks.dart';

@GenerateMocks([NotificationRemoteDataSource])
void main() {
  late NotificationRepositoryImpl repository;
  late MockNotificationRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockNotificationRemoteDataSource();
    repository = NotificationRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  const testUserId = 'test_user_id';
  const testNotificationId = 'test_notification_id';

  final testNotificationModel = NotificationModel(
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

  final testNotificationEntity = NotificationEntity(
    id: testNotificationId,
    userId: testUserId,
    title: 'Test Notification',
    body: 'Test body',
    type: 'test_type',
    data: const {'key': 'value'},
    createdAt: testNotificationModel.createdAt,
    isRead: false,
    priority: NotificationPriority.normal,
    category: NotificationCategory.system,
    isScheduled: false,
    isPersistent: false,
  );

  group('NotificationRepositoryImpl', () {
    group('getUserNotifications', () {
      test(
        'should return notifications when remote data source succeeds',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getUserNotifications(
              testUserId,
              limit: 20,
              lastNotificationId: null,
            ),
          ).thenAnswer((_) async => [testNotificationModel]);

          // act
          final result = await repository.getUserNotifications(
            testUserId,
            limit: 20,
          );

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Expected Right but got Left'),
            (notifications) => expect(notifications, [testNotificationModel]),
          );
          verify(
            mockRemoteDataSource.getUserNotifications(
              testUserId,
              limit: 20,
              lastNotificationId: null,
            ),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getUserNotifications(
              testUserId,
              limit: 20,
              lastNotificationId: null,
            ),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.getUserNotifications(
            testUserId,
            limit: 20,
          );

          // assert
          expect(
            result,
            isA<Left<Failure, List<NotificationEntity>>>().having(
              (l) => l.value,
              'failure',
              isA<ServerFailure>(),
            ),
          );
          verify(
            mockRemoteDataSource.getUserNotifications(
              testUserId,
              limit: 20,
              lastNotificationId: null,
            ),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remote data source throws generic exception',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getUserNotifications(
              testUserId,
              limit: 20,
              lastNotificationId: null,
            ),
          ).thenThrow(Exception('Generic error'));

          // act
          final result = await repository.getUserNotifications(
            testUserId,
            limit: 20,
          );

          // assert
          expect(result.isLeft(), true);
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (r) => fail('Should return failure'),
          );
          verify(
            mockRemoteDataSource.getUserNotifications(
              testUserId,
              limit: 20,
              lastNotificationId: null,
            ),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

    group('createNotification', () {
      test(
        'should return notification when remote data source succeeds',
        () async {
          // arrange
          when(
            mockRemoteDataSource.createNotification(any),
          ).thenAnswer((_) async => testNotificationModel);

          // act
          final result = await repository.createNotification(
            testNotificationEntity,
          );

          // assert
          expect(result, Right(testNotificationModel));
          verify(mockRemoteDataSource.createNotification(any));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.createNotification(any),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.createNotification(
            testNotificationEntity,
          );

          // assert
          expect(
            result,
            isA<Left<Failure, NotificationEntity>>().having(
              (l) => l.value,
              'failure',
              isA<ServerFailure>(),
            ),
          );
          verify(mockRemoteDataSource.createNotification(any));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

    group('markAsRead', () {
      test(
        'should return updated notification when remote data source succeeds',
        () async {
          // arrange
          final readNotification =
              testNotificationModel.markAsRead() as NotificationModel;
          when(
            mockRemoteDataSource.markAsRead(testNotificationId),
          ).thenAnswer((_) async => readNotification);

          // act
          final result = await repository.markAsRead(testNotificationId);

          // assert
          expect(result, Right(readNotification));
          verify(mockRemoteDataSource.markAsRead(testNotificationId));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.markAsRead(testNotificationId),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.markAsRead(testNotificationId);

          // assert
          expect(
            result,
            isA<Left<Failure, NotificationEntity>>().having(
              (l) => l.value,
              'failure',
              isA<ServerFailure>(),
            ),
          );
          verify(mockRemoteDataSource.markAsRead(testNotificationId));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

    group('getNotificationPreferences', () {
      final testPreferencesModel = NotificationPreferencesModel.fromEntity(
        NotificationPreferences.defaultPreferences(testUserId),
      );

      test(
        'should return preferences when remote data source succeeds',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getNotificationPreferences(testUserId),
          ).thenAnswer((_) async => testPreferencesModel);

          // act
          final result = await repository.getNotificationPreferences(
            testUserId,
          );

          // assert
          expect(result, Right(testPreferencesModel));
          verify(mockRemoteDataSource.getNotificationPreferences(testUserId));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getNotificationPreferences(testUserId),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.getNotificationPreferences(
            testUserId,
          );

          // assert
          expect(
            result,
            isA<Left<Failure, NotificationPreferences>>().having(
              (l) => l.value,
              'failure',
              isA<ServerFailure>(),
            ),
          );
          verify(mockRemoteDataSource.getNotificationPreferences(testUserId));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

    group('updateNotificationPreferences', () {
      final testPreferences = NotificationPreferences.defaultPreferences(
        testUserId,
      );
      final testPreferencesModel = NotificationPreferencesModel.fromEntity(
        testPreferences,
      );

      test(
        'should return updated preferences when remote data source succeeds',
        () async {
          // arrange
          when(
            mockRemoteDataSource.updateNotificationPreferences(any),
          ).thenAnswer((_) async => testPreferencesModel);

          // act
          final result = await repository.updateNotificationPreferences(
            testPreferences,
          );

          // assert
          expect(result, Right(testPreferencesModel));
          verify(mockRemoteDataSource.updateNotificationPreferences(any));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.updateNotificationPreferences(any),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.updateNotificationPreferences(
            testPreferences,
          );

          // assert
          expect(
            result,
            isA<Left<Failure, NotificationPreferences>>().having(
              (l) => l.value,
              'failure',
              isA<ServerFailure>(),
            ),
          );
          verify(mockRemoteDataSource.updateNotificationPreferences(any));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

    group('deleteNotification', () {
      test('should return void when remote data source succeeds', () async {
        // arrange
        when(
          mockRemoteDataSource.deleteNotification(testNotificationId),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.deleteNotification(testNotificationId);

        // assert
        expect(result, const Right(null));
        verify(mockRemoteDataSource.deleteNotification(testNotificationId));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.deleteNotification(testNotificationId),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.deleteNotification(
            testNotificationId,
          );

          // assert
          expect(
            result,
            isA<Left<Failure, void>>().having(
              (l) => l.value,
              'failure',
              isA<ServerFailure>(),
            ),
          );
          verify(mockRemoteDataSource.deleteNotification(testNotificationId));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

    group('getUnreadCount', () {
      test('should return count when remote data source succeeds', () async {
        // arrange
        when(
          mockRemoteDataSource.getUnreadCount(testUserId),
        ).thenAnswer((_) async => 5);

        // act
        final result = await repository.getUnreadCount(testUserId);

        // assert
        expect(result, const Right(5));
        verify(mockRemoteDataSource.getUnreadCount(testUserId));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getUnreadCount(testUserId),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.getUnreadCount(testUserId);

          // assert
          expect(
            result,
            isA<Left<Failure, int>>().having(
              (l) => l.value,
              'failure',
              isA<ServerFailure>(),
            ),
          );
          verify(mockRemoteDataSource.getUnreadCount(testUserId));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });
  });
}
