import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job.dart';
import '../repositories/partner_job_repository.dart';

/// Use case for accepting a job
class AcceptJob implements UseCase<Job, AcceptJobParams> {
  final PartnerJobRepository repository;

  AcceptJob(this.repository);

  @override
  Future<Either<Failure, Job>> call(AcceptJobParams params) async {
    return await repository.acceptJob(params.jobId, params.partnerId);
  }
}

class AcceptJobParams {
  final String jobId;
  final String partnerId;

  AcceptJobParams({
    required this.jobId,
    required this.partnerId,
  });
}
