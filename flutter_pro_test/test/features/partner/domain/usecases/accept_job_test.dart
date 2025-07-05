import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/features/partner/domain/entities/job.dart';
import 'package:flutter_pro_test/features/partner/domain/repositories/partner_job_repository.dart';
import 'package:flutter_pro_test/features/partner/domain/usecases/accept_job.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';

import 'accept_job_test.mocks.dart';

@GenerateMocks([PartnerJobRepository])
void main() {
  late AcceptJob usecase;
  late MockPartnerJobRepository mockRepository;

  setUp(() {
    mockRepository = MockPartnerJobRepository();
    usecase = AcceptJob(mockRepository);
  });

  const tJobId = 'test-job-id';
  const tPartnerId = 'test-partner-id';
  
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
    status: JobStatus.accepted,
    priority: JobPriority.normal,
    clientAddress: '123 Main St',
    clientLatitude: 37.7749,
    clientLongitude: -122.4194,
    createdAt: DateTime(2024, 1, 10),
  );

  group('AcceptJob', () {
    test('should accept job successfully when repository call succeeds', () async {
      // arrange
      when(mockRepository.acceptJob(any, any))
          .thenAnswer((_) async => Right(tJob));

      // act
      final result = await usecase(AcceptJobParams(
        jobId: tJobId,
        partnerId: tPartnerId,
      ));

      // assert
      expect(result, Right(tJob));
      verify(mockRepository.acceptJob(tJobId, tPartnerId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to accept job');
      when(mockRepository.acceptJob(any, any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(AcceptJobParams(
        jobId: tJobId,
        partnerId: tPartnerId,
      ));

      // assert
      expect(result, const Left(tFailure));
      verify(mockRepository.acceptJob(tJobId, tPartnerId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository with correct parameters', () async {
      // arrange
      when(mockRepository.acceptJob(any, any))
          .thenAnswer((_) async => Right(tJob));

      // act
      await usecase(AcceptJobParams(
        jobId: tJobId,
        partnerId: tPartnerId,
      ));

      // assert
      verify(mockRepository.acceptJob(tJobId, tPartnerId));
    });
  });

  group('AcceptJobParams', () {
    test('should create params with correct values', () {
      // act
      final params = AcceptJobParams(
        jobId: tJobId,
        partnerId: tPartnerId,
      );

      // assert
      expect(params.jobId, tJobId);
      expect(params.partnerId, tPartnerId);
    });
  });
}
