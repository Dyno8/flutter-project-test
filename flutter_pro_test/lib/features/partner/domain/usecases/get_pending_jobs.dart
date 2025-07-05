import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job.dart';
import '../repositories/partner_job_repository.dart';

/// Use case for getting pending jobs for a partner
class GetPendingJobs implements UseCase<List<Job>, GetPendingJobsParams> {
  final PartnerJobRepository repository;

  GetPendingJobs(this.repository);

  @override
  Future<Either<Failure, List<Job>>> call(GetPendingJobsParams params) async {
    return await repository.getPendingJobs(params.partnerId);
  }
}

class GetPendingJobsParams {
  final String partnerId;

  GetPendingJobsParams({required this.partnerId});
}
