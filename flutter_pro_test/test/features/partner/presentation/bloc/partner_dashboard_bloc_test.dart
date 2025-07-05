import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_pro_test/features/partner/domain/entities/job.dart';
import 'package:flutter_pro_test/features/partner/domain/entities/partner_earnings.dart';
import 'package:flutter_pro_test/features/partner/domain/repositories/partner_job_repository.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/get_pending_jobs.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/accept_job.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/reject_job.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/manage_job_status.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/get_partner_earnings.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/manage_availability.dart';
import 'package:flutter_pro_test/features/partner/presentation/bloc/partner_dashboard_bloc.dart';
import 'package:flutter_pro_test/features/partner/presentation/bloc/partner_dashboard_event.dart';
import 'package:flutter_pro_test/features/partner/presentation/bloc/partner_dashboard_state.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';

import 'partner_dashboard_bloc_test.mocks.dart';

@GenerateMocks([
  PartnerJobRepository,
  GetPendingJobs,
  AcceptJob,
  RejectJob,
  StartJob,
  CompleteJob,
  CancelJob,
  GetPartnerEarnings,
  GetPartnerAvailability,
  UpdateAvailabilityStatus,
  UpdateOnlineStatus,
  UpdateWorkingHours,
])
void main() {
  late PartnerDashboardBloc bloc;
  late MockPartnerJobRepository mockRepository;
  late MockGetPendingJobs mockGetPendingJobs;
  late MockAcceptJob mockAcceptJob;
  late MockRejectJob mockRejectJob;
  late MockStartJob mockStartJob;
  late MockCompleteJob mockCompleteJob;
  late MockCancelJob mockCancelJob;
  late MockGetPartnerEarnings mockGetPartnerEarnings;
  late MockGetPartnerAvailability mockGetPartnerAvailability;
  late MockUpdateAvailabilityStatus mockUpdateAvailabilityStatus;
  late MockUpdateOnlineStatus mockUpdateOnlineStatus;
  late MockUpdateWorkingHours mockUpdateWorkingHours;

  setUp(() {
    mockRepository = MockPartnerJobRepository();
    mockGetPendingJobs = MockGetPendingJobs();
    mockAcceptJob = MockAcceptJob();
    mockRejectJob = MockRejectJob();
    mockStartJob = MockStartJob();
    mockCompleteJob = MockCompleteJob();
    mockCancelJob = MockCancelJob();
    mockGetPartnerEarnings = MockGetPartnerEarnings();
    mockGetPartnerAvailability = MockGetPartnerAvailability();
    mockUpdateAvailabilityStatus = MockUpdateAvailabilityStatus();
    mockUpdateOnlineStatus = MockUpdateOnlineStatus();
    mockUpdateWorkingHours = MockUpdateWorkingHours();

    bloc = PartnerDashboardBloc(
      getPendingJobs: mockGetPendingJobs,
      acceptJob: mockAcceptJob,
      rejectJob: mockRejectJob,
      startJob: mockStartJob,
      completeJob: mockCompleteJob,
      cancelJob: mockCancelJob,
      getPartnerEarnings: mockGetPartnerEarnings,
      getPartnerAvailability: mockGetPartnerAvailability,
      updateAvailabilityStatus: mockUpdateAvailabilityStatus,
      updateOnlineStatus: mockUpdateOnlineStatus,
      updateWorkingHours: mockUpdateWorkingHours,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tPartnerId = 'test-partner-id';
  const tJobId = 'test-job-id';

  final tJob = Job(
    id: tJobId,
    bookingId: 'booking-123',
    partnerId: tPartnerId,
    userId: 'user-123',
    clientName: 'John Doe',
    clientPhone: '+1234567890',
    serviceId: 'service-123',
    serviceName: 'House Cleaning',
    scheduledDate: DateTime(2024, 1, 15),
    timeSlot: '09:00',
    hours: 2.0,
    totalPrice: 100.0,
    partnerEarnings: 80.0,
    status: JobStatus.pending,
    priority: JobPriority.normal,
    clientAddress: '123 Main St',
    clientLatitude: 37.7749,
    clientLongitude: -122.4194,
    createdAt: DateTime(2024, 1, 10),
  );

  final tEarnings = PartnerEarnings(
    id: tPartnerId,
    partnerId: tPartnerId,
    totalEarnings: 1000.0,
    todayEarnings: 100.0,
    weekEarnings: 500.0,
    monthEarnings: 800.0,
    totalJobs: 10,
    todayJobs: 1,
    weekJobs: 5,
    monthJobs: 8,
    averageRating: 4.5,
    totalReviews: 20,
    platformFeeRate: 0.15,
    lastUpdated: DateTime(2024, 1, 15),
  );

  final tAvailability = PartnerAvailability(
    partnerId: tPartnerId,
    isAvailable: true,
    isOnline: true,
    workingHours: {
      'monday': ['09:00', '17:00'],
      'tuesday': ['09:00', '17:00'],
    },
    lastUpdated: DateTime(2024, 1, 15),
  );

  group('PartnerDashboardBloc', () {
    test('initial state should be PartnerDashboardInitial', () {
      expect(bloc.state, equals(PartnerDashboardInitial()));
    });

    group('LoadPartnerDashboard', () {
      blocTest<PartnerDashboardBloc, PartnerDashboardState>(
        'should emit [Loading, Loaded] when data is loaded successfully',
        build: () {
          when(mockGetPendingJobs(any)).thenAnswer((_) async => Right([tJob]));
          when(mockRepository.getAcceptedJobs(any)).thenAnswer((_) async => const Right([]));
          when(mockRepository.getJobHistory(any, limit: anyNamed('limit')))
              .thenAnswer((_) async => const Right([]));
          when(mockGetPartnerEarnings(any)).thenAnswer((_) async => Right(tEarnings));
          when(mockGetPartnerAvailability(any)).thenAnswer((_) async => Right(tAvailability));
          when(mockRepository.getUnreadNotificationsCount(any))
              .thenAnswer((_) async => const Right(0));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPartnerDashboard(partnerId: tPartnerId)),
        expect: () => [
          PartnerDashboardLoading(),
          isA<PartnerDashboardLoaded>()
              .having((state) => state.pendingJobs.length, 'pending jobs count', 1)
              .having((state) => state.earnings, 'earnings', tEarnings)
              .having((state) => state.availability, 'availability', tAvailability),
        ],
      );

      blocTest<PartnerDashboardBloc, PartnerDashboardState>(
        'should emit [Loading, Error] when data loading fails',
        build: () {
          when(mockGetPendingJobs(any))
              .thenAnswer((_) async => const Left(ServerFailure('Failed to load')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPartnerDashboard(partnerId: tPartnerId)),
        expect: () => [
          PartnerDashboardLoading(),
          const PartnerDashboardError(message: 'Failed to load dashboard data'),
        ],
      );
    });

    group('AcceptJobEvent', () {
      blocTest<PartnerDashboardBloc, PartnerDashboardState>(
        'should emit [JobOperationInProgress, JobOperationSuccess] when job is accepted successfully',
        build: () {
          final acceptedJob = tJob.copyWith(status: JobStatus.accepted);
          when(mockAcceptJob(any)).thenAnswer((_) async => Right(acceptedJob));
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptJobEvent(
          jobId: tJobId,
          partnerId: tPartnerId,
        )),
        expect: () => [
          const JobOperationInProgress(jobId: tJobId, operation: 'accepting'),
          isA<JobOperationSuccess>()
              .having((state) => state.jobId, 'jobId', tJobId)
              .having((state) => state.operation, 'operation', 'accepting')
              .having((state) => state.message, 'message', 'Job accepted successfully'),
        ],
      );

      blocTest<PartnerDashboardBloc, PartnerDashboardState>(
        'should emit [JobOperationInProgress, JobOperationError] when job acceptance fails',
        build: () {
          when(mockAcceptJob(any))
              .thenAnswer((_) async => const Left(ServerFailure('Failed to accept job')));
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptJobEvent(
          jobId: tJobId,
          partnerId: tPartnerId,
        )),
        expect: () => [
          const JobOperationInProgress(jobId: tJobId, operation: 'accepting'),
          const JobOperationError(
            jobId: tJobId,
            operation: 'accepting',
            message: 'Failed to accept job',
          ),
        ],
      );
    });

    group('ToggleAvailabilityEvent', () {
      blocTest<PartnerDashboardBloc, PartnerDashboardState>(
        'should emit [AvailabilityUpdateInProgress, AvailabilityUpdateSuccess] when availability is updated successfully',
        build: () {
          final updatedAvailability = tAvailability.copyWith(isAvailable: false);
          when(mockUpdateAvailabilityStatus(any))
              .thenAnswer((_) async => Right(updatedAvailability));
          return bloc;
        },
        act: (bloc) => bloc.add(const ToggleAvailabilityEvent(
          partnerId: tPartnerId,
          isAvailable: false,
          reason: 'Taking a break',
        )),
        expect: () => [
          const AvailabilityUpdateInProgress(operation: 'toggling'),
          isA<AvailabilityUpdateSuccess>()
              .having((state) => state.message, 'message', 'You are now unavailable'),
        ],
      );

      blocTest<PartnerDashboardBloc, PartnerDashboardState>(
        'should emit [AvailabilityUpdateInProgress, AvailabilityUpdateError] when availability update fails',
        build: () {
          when(mockUpdateAvailabilityStatus(any))
              .thenAnswer((_) async => const Left(ServerFailure('Failed to update availability')));
          return bloc;
        },
        act: (bloc) => bloc.add(const ToggleAvailabilityEvent(
          partnerId: tPartnerId,
          isAvailable: false,
        )),
        expect: () => [
          const AvailabilityUpdateInProgress(operation: 'toggling'),
          const AvailabilityUpdateError(message: 'Failed to update availability'),
        ],
      );
    });
  });
}
