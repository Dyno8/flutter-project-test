import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job.dart';
import '../repositories/partner_job_repository.dart';

/// Use case for starting a job
class StartJob implements UseCase<Job, StartJobParams> {
  final PartnerJobRepository repository;

  StartJob(this.repository);

  @override
  Future<Either<Failure, Job>> call(StartJobParams params) async {
    return await repository.startJob(params.jobId, params.partnerId);
  }
}

class StartJobParams {
  final String jobId;
  final String partnerId;

  StartJobParams({
    required this.jobId,
    required this.partnerId,
  });
}

/// Use case for completing a job
class CompleteJob implements UseCase<Job, CompleteJobParams> {
  final PartnerJobRepository repository;

  CompleteJob(this.repository);

  @override
  Future<Either<Failure, Job>> call(CompleteJobParams params) async {
    return await repository.completeJob(params.jobId, params.partnerId);
  }
}

class CompleteJobParams {
  final String jobId;
  final String partnerId;

  CompleteJobParams({
    required this.jobId,
    required this.partnerId,
  });
}

/// Use case for cancelling a job
class CancelJob implements UseCase<Job, CancelJobParams> {
  final PartnerJobRepository repository;

  CancelJob(this.repository);

  @override
  Future<Either<Failure, Job>> call(CancelJobParams params) async {
    return await repository.cancelJob(
      params.jobId,
      params.partnerId,
      params.cancellationReason,
    );
  }
}

class CancelJobParams {
  final String jobId;
  final String partnerId;
  final String cancellationReason;

  CancelJobParams({
    required this.jobId,
    required this.partnerId,
    required this.cancellationReason,
  });
}
