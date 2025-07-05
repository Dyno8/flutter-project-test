import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job.dart';
import '../repositories/partner_job_repository.dart';

/// Use case for rejecting a job
class RejectJob implements UseCase<Job, RejectJobParams> {
  final PartnerJobRepository repository;

  RejectJob(this.repository);

  @override
  Future<Either<Failure, Job>> call(RejectJobParams params) async {
    return await repository.rejectJob(
      params.jobId,
      params.partnerId,
      params.rejectionReason,
    );
  }
}

class RejectJobParams {
  final String jobId;
  final String partnerId;
  final String rejectionReason;

  RejectJobParams({
    required this.jobId,
    required this.partnerId,
    required this.rejectionReason,
  });
}
