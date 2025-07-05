import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/features/booking/domain/entities/booking.dart';
import 'package:flutter_pro_test/features/booking/domain/repositories/booking_repository.dart';
import 'package:flutter_pro_test/features/booking/domain/usecases/create_booking.dart';
import 'package:flutter_pro_test/features/partner/domain/entities/job.dart';
import 'package:flutter_pro_test/features/partner/domain/repositories/partner_job_repository.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/get_pending_jobs.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/accept_job.dart';
import 'package:flutter_pro_test/shared/services/notification_service.dart';

import 'booking_to_partner_workflow_test.mocks.dart';

@GenerateMocks([
  BookingRepository,
  PartnerJobRepository,
  NotificationService,
])
void main() {
  late MockBookingRepository mockBookingRepository;
  late MockPartnerJobRepository mockPartnerJobRepository;
  late MockNotificationService mockNotificationService;
  late CreateBooking createBookingUseCase;
  late GetPendingJobs getPendingJobsUseCase;
  late AcceptJob acceptJobUseCase;

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    mockPartnerJobRepository = MockPartnerJobRepository();
    mockNotificationService = MockNotificationService();
    
    createBookingUseCase = CreateBooking(mockBookingRepository);
    getPendingJobsUseCase = GetPendingJobs(mockPartnerJobRepository);
    acceptJobUseCase = AcceptJob(mockPartnerJobRepository);
  });

  const tUserId = 'test-user-id';
  const tPartnerId = 'test-partner-id';
  const tServiceId = 'test-service-id';
  const tBookingId = 'test-booking-id';

  final tBooking = Booking(
    id: tBookingId,
    userId: tUserId,
    partnerId: tPartnerId,
    serviceId: tServiceId,
    serviceName: 'House Cleaning',
    scheduledDate: DateTime(2024, 1, 15),
    timeSlot: '09:00',
    hours: 2.0,
    totalPrice: 100.0,
    status: BookingStatus.pending,
    paymentStatus: PaymentStatus.pending,
    clientAddress: '123 Main St',
    clientLatitude: 37.7749,
    clientLongitude: -122.4194,
    createdAt: DateTime(2024, 1, 10),
  );

  final tJob = Job(
    id: tBookingId, // Job ID same as booking ID
    bookingId: tBookingId,
    partnerId: tPartnerId,
    userId: tUserId,
    clientName: 'John Doe',
    clientPhone: '+1234567890',
    serviceId: tServiceId,
    serviceName: 'House Cleaning',
    scheduledDate: DateTime(2024, 1, 15),
    timeSlot: '09:00',
    hours: 2.0,
    totalPrice: 100.0,
    partnerEarnings: 80.0, // 80% of total price
    status: JobStatus.pending,
    priority: JobPriority.normal,
    clientAddress: '123 Main St',
    clientLatitude: 37.7749,
    clientLongitude: -122.4194,
    createdAt: DateTime(2024, 1, 10),
  );

  group('Booking to Partner Workflow Integration Tests', () {
    group('Complete Booking Flow', () {
      test('should create booking and generate partner job successfully', () async {
        // arrange
        when(mockBookingRepository.createBooking(any))
            .thenAnswer((_) async => Right(tBooking));
        when(mockPartnerJobRepository.getPendingJobs(any))
            .thenAnswer((_) async => Right([tJob]));

        // act - Client creates booking
        final bookingResult = await createBookingUseCase(CreateBookingParams(
          userId: tUserId,
          partnerId: tPartnerId,
          serviceId: tServiceId,
          scheduledDate: DateTime(2024, 1, 15),
          timeSlot: '09:00',
          hours: 2.0,
          totalPrice: 100.0,
          clientAddress: '123 Main St',
          clientLatitude: 37.7749,
          clientLongitude: -122.4194,
        ));

        // act - Partner checks pending jobs
        final pendingJobsResult = await getPendingJobsUseCase(
          GetPendingJobsParams(partnerId: tPartnerId),
        );

        // assert
        expect(bookingResult, isA<Right<dynamic, Booking>>());
        expect(pendingJobsResult, isA<Right<dynamic, List<Job>>>());
        
        bookingResult.fold(
          (failure) => fail('Booking creation should succeed'),
          (booking) {
            expect(booking.id, tBookingId);
            expect(booking.status, BookingStatus.pending);
          },
        );

        pendingJobsResult.fold(
          (failure) => fail('Getting pending jobs should succeed'),
          (jobs) {
            expect(jobs.length, 1);
            expect(jobs.first.bookingId, tBookingId);
            expect(jobs.first.status, JobStatus.pending);
          },
        );

        verify(mockBookingRepository.createBooking(any));
        verify(mockPartnerJobRepository.getPendingJobs(tPartnerId));
      });

      test('should handle job acceptance and update booking status', () async {
        // arrange
        final acceptedJob = tJob.copyWith(status: JobStatus.accepted);
        final confirmedBooking = tBooking.copyWith(status: BookingStatus.confirmed);
        
        when(mockPartnerJobRepository.acceptJob(any, any))
            .thenAnswer((_) async => Right(acceptedJob));
        when(mockBookingRepository.getBookingById(any))
            .thenAnswer((_) async => Right(confirmedBooking));

        // act - Partner accepts job
        final acceptResult = await acceptJobUseCase(AcceptJobParams(
          jobId: tBookingId,
          partnerId: tPartnerId,
        ));

        // assert
        expect(acceptResult, isA<Right<dynamic, Job>>());
        
        acceptResult.fold(
          (failure) => fail('Job acceptance should succeed'),
          (job) {
            expect(job.status, JobStatus.accepted);
            expect(job.acceptedAt, isNotNull);
          },
        );

        verify(mockPartnerJobRepository.acceptJob(tBookingId, tPartnerId));
      });

      test('should handle job rejection and notify client', () async {
        // arrange
        const rejectionReason = 'Not available at this time';
        final rejectedJob = tJob.copyWith(
          status: JobStatus.rejected,
          rejectionReason: rejectionReason,
        );
        
        when(mockPartnerJobRepository.rejectJob(any, any, any))
            .thenAnswer((_) async => Right(rejectedJob));

        // act - Partner rejects job
        final rejectResult = await mockPartnerJobRepository.rejectJob(
          tBookingId,
          tPartnerId,
          rejectionReason,
        );

        // assert
        expect(rejectResult, isA<Right<dynamic, Job>>());
        
        rejectResult.fold(
          (failure) => fail('Job rejection should succeed'),
          (job) {
            expect(job.status, JobStatus.rejected);
            expect(job.rejectionReason, rejectionReason);
            expect(job.rejectedAt, isNotNull);
          },
        );

        verify(mockPartnerJobRepository.rejectJob(tBookingId, tPartnerId, rejectionReason));
      });
    });

    group('Real-time Updates', () {
      test('should handle real-time job status updates', () async {
        // arrange
        final jobStream = Stream.fromIterable([
          [tJob], // Initial pending job
          [tJob.copyWith(status: JobStatus.accepted)], // Job accepted
          [tJob.copyWith(status: JobStatus.inProgress)], // Job started
          [tJob.copyWith(status: JobStatus.completed)], // Job completed
        ]);

        when(mockPartnerJobRepository.listenToPendingJobs(any))
            .thenAnswer((_) => jobStream.map((jobs) => Right(jobs)));

        // act
        final stream = mockPartnerJobRepository.listenToPendingJobs(tPartnerId);

        // assert
        expect(
          stream,
          emitsInOrder([
            Right([tJob]),
            Right([tJob.copyWith(status: JobStatus.accepted)]),
            Right([tJob.copyWith(status: JobStatus.inProgress)]),
            Right([tJob.copyWith(status: JobStatus.completed)]),
          ]),
        );

        verify(mockPartnerJobRepository.listenToPendingJobs(tPartnerId));
      });
    });

    group('Notification Flow', () {
      test('should send notification when new job is available', () async {
        // arrange
        when(mockNotificationService.sendNewJobNotification(
          partnerId: anyNamed('partnerId'),
          jobId: anyNamed('jobId'),
          serviceName: anyNamed('serviceName'),
          clientName: anyNamed('clientName'),
          earnings: anyNamed('earnings'),
        )).thenAnswer((_) async {});

        // act
        await mockNotificationService.sendNewJobNotification(
          partnerId: tPartnerId,
          jobId: tBookingId,
          serviceName: 'House Cleaning',
          clientName: 'John Doe',
          earnings: '80k VND',
        );

        // assert
        verify(mockNotificationService.sendNewJobNotification(
          partnerId: tPartnerId,
          jobId: tBookingId,
          serviceName: 'House Cleaning',
          clientName: 'John Doe',
          earnings: '80k VND',
        ));
      });

      test('should send notification when job status changes', () async {
        // arrange
        when(mockNotificationService.sendJobStatusNotification(
          partnerId: anyNamed('partnerId'),
          jobId: anyNamed('jobId'),
          status: anyNamed('status'),
          serviceName: anyNamed('serviceName'),
        )).thenAnswer((_) async {});

        // act
        await mockNotificationService.sendJobStatusNotification(
          partnerId: tPartnerId,
          jobId: tBookingId,
          status: 'accepted',
          serviceName: 'House Cleaning',
        );

        // assert
        verify(mockNotificationService.sendJobStatusNotification(
          partnerId: tPartnerId,
          jobId: tBookingId,
          status: 'accepted',
          serviceName: 'House Cleaning',
        ));
      });
    });

    group('Error Handling', () {
      test('should handle booking creation failure gracefully', () async {
        // arrange
        when(mockBookingRepository.createBooking(any))
            .thenAnswer((_) async => const Left(ServerFailure('Failed to create booking')));

        // act
        final result = await createBookingUseCase(CreateBookingParams(
          userId: tUserId,
          partnerId: tPartnerId,
          serviceId: tServiceId,
          scheduledDate: DateTime(2024, 1, 15),
          timeSlot: '09:00',
          hours: 2.0,
          totalPrice: 100.0,
          clientAddress: '123 Main St',
          clientLatitude: 37.7749,
          clientLongitude: -122.4194,
        ));

        // assert
        expect(result, isA<Left<Failure, Booking>>());
        result.fold(
          (failure) => expect(failure.message, 'Failed to create booking'),
          (booking) => fail('Should return failure'),
        );
      });

      test('should handle partner job acceptance failure gracefully', () async {
        // arrange
        when(mockPartnerJobRepository.acceptJob(any, any))
            .thenAnswer((_) async => const Left(ServerFailure('Failed to accept job')));

        // act
        final result = await acceptJobUseCase(AcceptJobParams(
          jobId: tBookingId,
          partnerId: tPartnerId,
        ));

        // assert
        expect(result, isA<Left<Failure, Job>>());
        result.fold(
          (failure) => expect(failure.message, 'Failed to accept job'),
          (job) => fail('Should return failure'),
        );
      });
    });
  });
}
