import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/features/partner/data/repositories/partner_job_repository_impl.dart';
import 'package:flutter_pro_test/features/partner/data/datasources/partner_job_remote_data_source.dart';
import 'package:flutter_pro_test/features/partner/data/models/job_model.dart';
import 'package:flutter_pro_test/features/partner/data/models/partner_earnings_model.dart';
import 'package:flutter_pro_test/features/partner/domain/entities/job.dart';
import 'package:flutter_pro_test/features/partner/domain/entities/partner_earnings.dart';
import 'package:flutter_pro_test/core/errors/exceptions.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'partner_job_repository_impl_test.mocks.dart';

@GenerateMocks([PartnerJobRemoteDataSource])
void main() {
  late PartnerJobRepositoryImpl repository;
  late MockPartnerJobRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPartnerJobRemoteDataSource();
    repository = PartnerJobRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tPartnerId = 'test-partner-id';
  const tJobId = 'test-job-id';

  final tJobModel = JobModel(
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
    status: 'pending',
    priority: 'normal',
    clientAddress: '123 Main St',
    clientLocation: const GeoPoint(37.7749, -122.4194),
    createdAt: DateTime(2024, 1, 10),
  );

  final tJob = tJobModel.toEntity();

  final tEarningsModel = PartnerEarningsModel(
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

  final tEarnings = tEarningsModel.toEntity();

  group('PartnerJobRepositoryImpl', () {
    group('getPendingJobs', () {
      test('should return list of jobs when remote data source call succeeds', () async {
        // arrange
        when(mockRemoteDataSource.getPendingJobs(any))
            .thenAnswer((_) async => [tJobModel]);

        // act
        final result = await repository.getPendingJobs(tPartnerId);

        // assert
        verify(mockRemoteDataSource.getPendingJobs(tPartnerId));
        expect(result, equals(Right([tJob])));
      });

      test('should return ServerFailure when remote data source throws ServerException', () async {
        // arrange
        when(mockRemoteDataSource.getPendingJobs(any))
            .thenThrow(const ServerException('Failed to get pending jobs'));

        // act
        final result = await repository.getPendingJobs(tPartnerId);

        // assert
        verify(mockRemoteDataSource.getPendingJobs(tPartnerId));
        expect(result, equals(const Left(ServerFailure('Failed to get pending jobs'))));
      });

      test('should return ServerFailure when remote data source throws generic exception', () async {
        // arrange
        when(mockRemoteDataSource.getPendingJobs(any))
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.getPendingJobs(tPartnerId);

        // assert
        verify(mockRemoteDataSource.getPendingJobs(tPartnerId));
        expect(result, isA<Left<Failure, List<Job>>>());
      });
    });

    group('acceptJob', () {
      test('should return updated job when remote data source call succeeds', () async {
        // arrange
        final acceptedJobModel = tJobModel.copyWith(status: 'accepted');
        when(mockRemoteDataSource.acceptJob(any, any))
            .thenAnswer((_) async => acceptedJobModel);

        // act
        final result = await repository.acceptJob(tJobId, tPartnerId);

        // assert
        verify(mockRemoteDataSource.acceptJob(tJobId, tPartnerId));
        expect(result, isA<Right<Failure, Job>>());
        result.fold(
          (failure) => fail('Should return job'),
          (job) => expect(job.status, JobStatus.accepted),
        );
      });

      test('should return ServerFailure when remote data source throws ServerException', () async {
        // arrange
        when(mockRemoteDataSource.acceptJob(any, any))
            .thenThrow(const ServerException('Failed to accept job'));

        // act
        final result = await repository.acceptJob(tJobId, tPartnerId);

        // assert
        verify(mockRemoteDataSource.acceptJob(tJobId, tPartnerId));
        expect(result, equals(const Left(ServerFailure('Failed to accept job'))));
      });
    });

    group('rejectJob', () {
      const tRejectionReason = 'Not available';

      test('should return updated job when remote data source call succeeds', () async {
        // arrange
        final rejectedJobModel = tJobModel.copyWith(
          status: 'rejected',
          rejectionReason: tRejectionReason,
        );
        when(mockRemoteDataSource.rejectJob(any, any, any))
            .thenAnswer((_) async => rejectedJobModel);

        // act
        final result = await repository.rejectJob(tJobId, tPartnerId, tRejectionReason);

        // assert
        verify(mockRemoteDataSource.rejectJob(tJobId, tPartnerId, tRejectionReason));
        expect(result, isA<Right<Failure, Job>>());
        result.fold(
          (failure) => fail('Should return job'),
          (job) {
            expect(job.status, JobStatus.rejected);
            expect(job.rejectionReason, tRejectionReason);
          },
        );
      });

      test('should return ServerFailure when remote data source throws ServerException', () async {
        // arrange
        when(mockRemoteDataSource.rejectJob(any, any, any))
            .thenThrow(const ServerException('Failed to reject job'));

        // act
        final result = await repository.rejectJob(tJobId, tPartnerId, tRejectionReason);

        // assert
        verify(mockRemoteDataSource.rejectJob(tJobId, tPartnerId, tRejectionReason));
        expect(result, equals(const Left(ServerFailure('Failed to reject job'))));
      });
    });

    group('getPartnerEarnings', () {
      test('should return partner earnings when remote data source call succeeds', () async {
        // arrange
        when(mockRemoteDataSource.getPartnerEarnings(any))
            .thenAnswer((_) async => tEarningsModel);

        // act
        final result = await repository.getPartnerEarnings(tPartnerId);

        // assert
        verify(mockRemoteDataSource.getPartnerEarnings(tPartnerId));
        expect(result, equals(Right(tEarnings)));
      });

      test('should return ServerFailure when remote data source throws ServerException', () async {
        // arrange
        when(mockRemoteDataSource.getPartnerEarnings(any))
            .thenThrow(const ServerException('Failed to get earnings'));

        // act
        final result = await repository.getPartnerEarnings(tPartnerId);

        // assert
        verify(mockRemoteDataSource.getPartnerEarnings(tPartnerId));
        expect(result, equals(const Left(ServerFailure('Failed to get earnings'))));
      });
    });

    group('listenToPendingJobs', () {
      test('should return stream of jobs when remote data source stream succeeds', () async {
        // arrange
        when(mockRemoteDataSource.listenToPendingJobs(any))
            .thenAnswer((_) => Stream.value([tJobModel]));

        // act
        final stream = repository.listenToPendingJobs(tPartnerId);

        // assert
        expect(stream, emits(Right([tJob])));
        verify(mockRemoteDataSource.listenToPendingJobs(tPartnerId));
      });

      test('should return stream with failure when remote data source stream fails', () async {
        // arrange
        when(mockRemoteDataSource.listenToPendingJobs(any))
            .thenAnswer((_) => Stream.error(const ServerException('Stream error')));

        // act
        final stream = repository.listenToPendingJobs(tPartnerId);

        // assert
        expect(stream, emits(isA<Left<Failure, List<Job>>>()));
        verify(mockRemoteDataSource.listenToPendingJobs(tPartnerId));
      });
    });
  });
}
