import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/partner_earnings.dart';
import '../../domain/repositories/partner_job_repository.dart';
import '../datasources/partner_job_remote_data_source.dart';

/// Implementation of PartnerJobRepository
class PartnerJobRepositoryImpl implements PartnerJobRepository {
  final PartnerJobRemoteDataSource remoteDataSource;

  PartnerJobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Job>>> getPendingJobs(String partnerId) async {
    try {
      final jobModels = await remoteDataSource.getPendingJobs(partnerId);
      final jobs = jobModels.map((model) => model.toEntity()).toList();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get pending jobs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> getAcceptedJobs(String partnerId) async {
    try {
      final jobModels = await remoteDataSource.getAcceptedJobs(partnerId);
      final jobs = jobModels.map((model) => model.toEntity()).toList();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get accepted jobs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> getJobHistory(
    String partnerId, {
    JobStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    try {
      final jobModels = await remoteDataSource.getJobHistory(
        partnerId,
        status: status?.name,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      final jobs = jobModels.map((model) => model.toEntity()).toList();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get job history: $e'));
    }
  }

  @override
  Future<Either<Failure, Job>> getJobById(String jobId) async {
    try {
      final jobModel = await remoteDataSource.getJobById(jobId);
      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get job: $e'));
    }
  }

  @override
  Future<Either<Failure, Job>> acceptJob(String jobId, String partnerId) async {
    try {
      final jobModel = await remoteDataSource.acceptJob(jobId, partnerId);
      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to accept job: $e'));
    }
  }

  @override
  Future<Either<Failure, Job>> rejectJob(
    String jobId,
    String partnerId,
    String rejectionReason,
  ) async {
    try {
      final jobModel = await remoteDataSource.rejectJob(jobId, partnerId, rejectionReason);
      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to reject job: $e'));
    }
  }

  @override
  Future<Either<Failure, Job>> startJob(String jobId, String partnerId) async {
    try {
      final jobModel = await remoteDataSource.startJob(jobId, partnerId);
      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to start job: $e'));
    }
  }

  @override
  Future<Either<Failure, Job>> completeJob(String jobId, String partnerId) async {
    try {
      final jobModel = await remoteDataSource.completeJob(jobId, partnerId);
      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to complete job: $e'));
    }
  }

  @override
  Future<Either<Failure, Job>> cancelJob(
    String jobId,
    String partnerId,
    String cancellationReason,
  ) async {
    try {
      final jobModel = await remoteDataSource.cancelJob(jobId, partnerId, cancellationReason);
      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel job: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Job>>> listenToPendingJobs(String partnerId) {
    try {
      return remoteDataSource.listenToPendingJobs(partnerId).map(
        (jobModels) {
          final jobs = jobModels.map((model) => model.toEntity()).toList();
          return Right<Failure, List<Job>>(jobs);
        },
      ).handleError((error) {
        return Left<Failure, List<Job>>(ServerFailure('Failed to listen to pending jobs: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to pending jobs: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<Job>>> listenToAcceptedJobs(String partnerId) {
    try {
      return remoteDataSource.listenToAcceptedJobs(partnerId).map(
        (jobModels) {
          final jobs = jobModels.map((model) => model.toEntity()).toList();
          return Right<Failure, List<Job>>(jobs);
        },
      ).handleError((error) {
        return Left<Failure, List<Job>>(ServerFailure('Failed to listen to accepted jobs: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to accepted jobs: $e')));
    }
  }

  @override
  Stream<Either<Failure, Job>> listenToJob(String jobId) {
    try {
      return remoteDataSource.listenToJob(jobId).map(
        (jobModel) => Right<Failure, Job>(jobModel.toEntity()),
      ).handleError((error) {
        return Left<Failure, Job>(ServerFailure('Failed to listen to job: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to job: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<Job>>> listenToActiveJobs(String partnerId) {
    try {
      return remoteDataSource.listenToActiveJobs(partnerId).map(
        (jobModels) {
          final jobs = jobModels.map((model) => model.toEntity()).toList();
          return Right<Failure, List<Job>>(jobs);
        },
      ).handleError((error) {
        return Left<Failure, List<Job>>(ServerFailure('Failed to listen to active jobs: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to active jobs: $e')));
    }
  }

  @override
  Future<Either<Failure, PartnerEarnings>> getPartnerEarnings(String partnerId) async {
    try {
      final earningsModel = await remoteDataSource.getPartnerEarnings(partnerId);
      return Right(earningsModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get partner earnings: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerEarnings>> updatePartnerEarnings(
    String partnerId,
    double jobEarnings,
  ) async {
    try {
      final earningsModel = await remoteDataSource.updatePartnerEarnings(partnerId, jobEarnings);
      return Right(earningsModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update partner earnings: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DailyEarning>>> getEarningsByDateRange(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final earningsData = await remoteDataSource.getEarningsByDateRange(partnerId, startDate, endDate);
      final dailyEarnings = earningsData.map((data) {
        return DailyEarning(
          date: data['date'],
          earnings: data['earnings'],
          jobsCompleted: data['jobsCompleted'],
          hoursWorked: data['hoursWorked'],
        );
      }).toList();
      return Right(dailyEarnings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get earnings by date range: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAvailability>> getPartnerAvailability(String partnerId) async {
    try {
      final availabilityModel = await remoteDataSource.getPartnerAvailability(partnerId);
      return Right(availabilityModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get partner availability: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAvailability>> updateAvailabilityStatus(
    String partnerId,
    bool isAvailable,
    String? reason,
  ) async {
    try {
      final availabilityModel = await remoteDataSource.updateAvailabilityStatus(partnerId, isAvailable, reason);
      return Right(availabilityModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update availability status: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAvailability>> updateOnlineStatus(
    String partnerId,
    bool isOnline,
  ) async {
    try {
      final availabilityModel = await remoteDataSource.updateOnlineStatus(partnerId, isOnline);
      return Right(availabilityModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update online status: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAvailability>> updateWorkingHours(
    String partnerId,
    Map<String, List<String>> workingHours,
  ) async {
    try {
      final availabilityModel = await remoteDataSource.updateWorkingHours(partnerId, workingHours);
      return Right(availabilityModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update working hours: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAvailability>> blockDates(
    String partnerId,
    List<String> dates,
  ) async {
    try {
      final availabilityModel = await remoteDataSource.blockDates(partnerId, dates);
      return Right(availabilityModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to block dates: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAvailability>> unblockDates(
    String partnerId,
    List<String> dates,
  ) async {
    try {
      final availabilityModel = await remoteDataSource.unblockDates(partnerId, dates);
      return Right(availabilityModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to unblock dates: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAvailability>> setTemporaryUnavailability(
    String partnerId,
    DateTime unavailableUntil,
    String reason,
  ) async {
    try {
      final availabilityModel = await remoteDataSource.setTemporaryUnavailability(partnerId, unavailableUntil, reason);
      return Right(availabilityModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to set temporary unavailability: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAvailability>> clearTemporaryUnavailability(String partnerId) async {
    try {
      final availabilityModel = await remoteDataSource.clearTemporaryUnavailability(partnerId);
      return Right(availabilityModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to clear temporary unavailability: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getJobStatistics(
    String partnerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getJobStatistics(partnerId, startDate: startDate, endDate: endDate);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get job statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceMetrics(String partnerId) async {
    try {
      final metrics = await remoteDataSource.getPerformanceMetrics(partnerId);
      return Right(metrics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get performance metrics: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markJobNotificationAsRead(String partnerId, String jobId) async {
    try {
      await remoteDataSource.markJobNotificationAsRead(partnerId, jobId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to mark notification as read: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationsCount(String partnerId) async {
    try {
      final count = await remoteDataSource.getUnreadNotificationsCount(partnerId);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get unread notifications count: $e'));
    }
  }
}
