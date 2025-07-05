import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/partner_earnings.dart';
import '../repositories/partner_job_repository.dart';

/// Use case for getting partner availability
class GetPartnerAvailability implements UseCase<PartnerAvailability, GetPartnerAvailabilityParams> {
  final PartnerJobRepository repository;

  GetPartnerAvailability(this.repository);

  @override
  Future<Either<Failure, PartnerAvailability>> call(GetPartnerAvailabilityParams params) async {
    return await repository.getPartnerAvailability(params.partnerId);
  }
}

class GetPartnerAvailabilityParams {
  final String partnerId;

  GetPartnerAvailabilityParams({required this.partnerId});
}

/// Use case for updating availability status
class UpdateAvailabilityStatus implements UseCase<PartnerAvailability, UpdateAvailabilityStatusParams> {
  final PartnerJobRepository repository;

  UpdateAvailabilityStatus(this.repository);

  @override
  Future<Either<Failure, PartnerAvailability>> call(UpdateAvailabilityStatusParams params) async {
    return await repository.updateAvailabilityStatus(
      params.partnerId,
      params.isAvailable,
      params.reason,
    );
  }
}

class UpdateAvailabilityStatusParams {
  final String partnerId;
  final bool isAvailable;
  final String? reason;

  UpdateAvailabilityStatusParams({
    required this.partnerId,
    required this.isAvailable,
    this.reason,
  });
}

/// Use case for updating online status
class UpdateOnlineStatus implements UseCase<PartnerAvailability, UpdateOnlineStatusParams> {
  final PartnerJobRepository repository;

  UpdateOnlineStatus(this.repository);

  @override
  Future<Either<Failure, PartnerAvailability>> call(UpdateOnlineStatusParams params) async {
    return await repository.updateOnlineStatus(params.partnerId, params.isOnline);
  }
}

class UpdateOnlineStatusParams {
  final String partnerId;
  final bool isOnline;

  UpdateOnlineStatusParams({
    required this.partnerId,
    required this.isOnline,
  });
}

/// Use case for updating working hours
class UpdateWorkingHours implements UseCase<PartnerAvailability, UpdateWorkingHoursParams> {
  final PartnerJobRepository repository;

  UpdateWorkingHours(this.repository);

  @override
  Future<Either<Failure, PartnerAvailability>> call(UpdateWorkingHoursParams params) async {
    return await repository.updateWorkingHours(params.partnerId, params.workingHours);
  }
}

class UpdateWorkingHoursParams {
  final String partnerId;
  final Map<String, List<String>> workingHours;

  UpdateWorkingHoursParams({
    required this.partnerId,
    required this.workingHours,
  });
}
