import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/shared/services/notification_integration_service.dart';
import 'package:flutter_pro_test/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_pro_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_pro_test/shared/repositories/user_repository.dart';
import 'package:flutter_pro_test/shared/services/notification_service.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/create_notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/send_push_notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/get_notification_preferences.dart';
import 'package:flutter_pro_test/features/booking/domain/entities/booking.dart';

import 'package:flutter_pro_test/shared/models/user_model.dart';
import 'package:flutter_pro_test/features/notifications/domain/entities/notification.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';

import 'notification_integration_service_test.mocks.dart';

@GenerateMocks([
  NotificationRepository,
  AuthRepository,
  UserRepository,
  NotificationService,
  CreateNotification,
  SendPushNotification,
  GetNotificationPreferences,
])
void main() {
  late NotificationIntegrationService service;
  late MockNotificationRepository mockNotificationRepository;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockNotificationService mockNotificationService;
  late MockCreateNotification mockCreateNotification;
  late MockSendPushNotification mockSendPushNotification;
  late MockGetNotificationPreferences mockGetNotificationPreferences;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockNotificationService = MockNotificationService();
    mockCreateNotification = MockCreateNotification();
    mockSendPushNotification = MockSendPushNotification();
    mockGetNotificationPreferences = MockGetNotificationPreferences();

    service = NotificationIntegrationService(
      notificationRepository: mockNotificationRepository,
      authRepository: mockAuthRepository,
      userRepository: mockUserRepository,
      notificationService: mockNotificationService,
      createNotification: mockCreateNotification,
      sendPushNotification: mockSendPushNotification,
      getNotificationPreferences: mockGetNotificationPreferences,
    );
  });

  group('NotificationIntegrationService', () {
    group('notifyBookingCreated', () {
      test('should send booking created notification successfully', () async {
        // Arrange
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          partnerId: '',
          serviceId: 'service123',
          serviceName: 'House Cleaning',
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          timeSlot: '09:00 - 11:00',
          hours: 2,
          totalPrice: 200.0,
          status: BookingStatus.pending,
          paymentStatus: PaymentStatus.unpaid,
          paymentMethod: 'cash',
          paymentTransactionId: '',
          clientAddress: '123 Test St',
          clientLatitude: 10.0,
          clientLongitude: 106.0,
          specialInstructions: '',
          cancellationReason: '',
          completedAt: null,
          cancelledAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final user = UserModel(
          uid: 'user123',
          name: 'Test User',
          email: 'test@example.com',
          phone: '1234567890',
          address: '123 Test St',
          role: 'client',
          createdAt: DateTime.now(),
        );

        final notification = NotificationEntity(
          id: 'notif123',
          userId: 'user123',
          title: 'Đặt lịch thành công',
          body:
              'Đặt lịch House Cleaning vào ${booking.formattedDateTime} đã được tạo thành công.',
          type: NotificationTypes.bookingCreated,
          data: {
            'bookingId': booking.id,
            'serviceId': booking.serviceId,
            'serviceName': booking.serviceName,
          },
          isRead: false,
          priority: NotificationPriority.normal,
          category: NotificationCategory.booking,
          actionUrl: '/booking/${booking.id}',
          imageUrl: null,
          createdAt: DateTime.now(),
          isScheduled: false,
          isPersistent: true,
        );

        when(
          mockUserRepository.getById('user123'),
        ).thenAnswer((_) async => Right(user));
        when(
          mockGetNotificationPreferences(any),
        ).thenAnswer((_) async => Left(ServerFailure('No preferences')));
        when(
          mockCreateNotification(any),
        ).thenAnswer((_) async => Right(notification));
        when(
          mockSendPushNotification(any),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await service.notifyBookingCreated(booking);

        // Assert
        expect(result.isRight(), true);
        verify(mockUserRepository.getById('user123')).called(1);
        verify(mockCreateNotification(any)).called(1);
        verify(mockSendPushNotification(any)).called(1);
      });

      test('should return failure when user not found', () async {
        // Arrange
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          partnerId: '',
          serviceId: 'service123',
          serviceName: 'House Cleaning',
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          timeSlot: '09:00 - 11:00',
          hours: 2,
          totalPrice: 200.0,
          status: BookingStatus.pending,
          paymentStatus: PaymentStatus.unpaid,
          paymentMethod: 'cash',
          paymentTransactionId: '',
          clientAddress: '123 Test St',
          clientLatitude: 10.0,
          clientLongitude: 106.0,
          specialInstructions: '',
          cancellationReason: '',
          completedAt: null,
          cancelledAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockUserRepository.getById('user123'),
        ).thenAnswer((_) async => Left(ServerFailure('User not found')));

        // Act
        final result = await service.notifyBookingCreated(booking);

        // Assert
        expect(result.isLeft(), true);
        final failure = (result as Left).value;
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('Client not found'));
      });
    });

    group('notifyBookingConfirmed', () {
      test('should send booking confirmed notification successfully', () async {
        // Arrange
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          partnerId: 'partner123',
          serviceId: 'service123',
          serviceName: 'House Cleaning',
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          timeSlot: '09:00 - 11:00',
          hours: 2,
          totalPrice: 200.0,
          status: BookingStatus.confirmed,
          paymentStatus: PaymentStatus.unpaid,
          paymentMethod: 'cash',
          paymentTransactionId: '',
          clientAddress: '123 Test St',
          clientLatitude: 10.0,
          clientLongitude: 106.0,
          specialInstructions: '',
          cancellationReason: '',
          completedAt: null,
          cancelledAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        const partnerName = 'Test Partner';

        final notification = NotificationEntity(
          id: 'notif123',
          userId: 'user123',
          title: 'Đặt lịch đã được xác nhận',
          body: 'Đặt lịch House Cleaning đã được xác nhận bởi Test Partner.',
          type: NotificationTypes.bookingConfirmed,
          data: {
            'bookingId': booking.id,
            'partnerId': booking.partnerId,
            'partnerName': partnerName,
          },
          isRead: false,
          priority: NotificationPriority.high,
          category: NotificationCategory.booking,
          actionUrl: '/booking/${booking.id}',
          imageUrl: null,
          createdAt: DateTime.now(),
          isScheduled: false,
          isPersistent: true,
        );

        when(
          mockGetNotificationPreferences(any),
        ).thenAnswer((_) async => Left(ServerFailure('No preferences')));
        when(
          mockCreateNotification(any),
        ).thenAnswer((_) async => Right(notification));
        when(
          mockSendPushNotification(any),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await service.notifyBookingConfirmed(
          booking,
          partnerName,
        );

        // Assert
        expect(result.isRight(), true);
        verify(mockCreateNotification(any)).called(1);
        verify(mockSendPushNotification(any)).called(1);
      });
    });

    group('notifyEarningsUpdate', () {
      test('should send earnings update notification successfully', () async {
        // Arrange
        const partnerId = 'partner123';
        const newEarnings = 150.0;
        const totalEarnings = 1500.0;
        const jobId = 'job123';

        final notification = NotificationEntity(
          id: 'notif123',
          userId: partnerId,
          title: 'Thu nhập cập nhật',
          body: 'Bạn đã nhận được 150k VND. Tổng thu nhập: 1500k VND.',
          type: NotificationTypes.earningsUpdate,
          data: {
            'jobId': jobId,
            'newEarnings': newEarnings,
            'totalEarnings': totalEarnings,
          },
          isRead: false,
          priority: NotificationPriority.normal,
          category: NotificationCategory.payment,
          actionUrl: '/partner/earnings',
          imageUrl: null,
          createdAt: DateTime.now(),
          isScheduled: false,
          isPersistent: true,
        );

        when(
          mockGetNotificationPreferences(any),
        ).thenAnswer((_) async => Left(ServerFailure('No preferences')));
        when(
          mockCreateNotification(any),
        ).thenAnswer((_) async => Right(notification));
        when(
          mockSendPushNotification(any),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await service.notifyEarningsUpdate(
          partnerId,
          newEarnings,
          totalEarnings,
          jobId,
        );

        // Assert
        expect(result.isRight(), true);
        verify(mockCreateNotification(any)).called(1);
        verify(mockSendPushNotification(any)).called(1);
      });
    });

    group('sendBulkNotifications', () {
      test('should send bulk notifications to multiple users', () async {
        // Arrange
        final userIds = ['user1', 'user2', 'user3'];
        const title = 'System Maintenance';
        const body = 'The system will be under maintenance tonight.';
        const type = 'system_maintenance';
        const category = NotificationCategory.system;
        const priority = NotificationPriority.normal;
        final data = {'maintenance': true};

        final notification = NotificationEntity(
          id: 'notif123',
          userId: 'user1',
          title: title,
          body: body,
          type: type,
          data: data,
          isRead: false,
          priority: priority,
          category: category,
          actionUrl: null,
          imageUrl: null,
          createdAt: DateTime.now(),
          isScheduled: false,
          isPersistent: true,
        );

        when(
          mockGetNotificationPreferences(any),
        ).thenAnswer((_) async => Left(ServerFailure('No preferences')));
        when(
          mockCreateNotification(any),
        ).thenAnswer((_) async => Right(notification));
        when(
          mockSendPushNotification(any),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await service.sendBulkNotifications(
          userIds,
          title,
          body,
          type,
          category,
          priority,
          data,
        );

        // Assert
        expect(result.isRight(), true);
        verify(mockCreateNotification(any)).called(3); // Once for each user
        verify(mockSendPushNotification(any)).called(3); // Once for each user
      });
    });
  });
}
