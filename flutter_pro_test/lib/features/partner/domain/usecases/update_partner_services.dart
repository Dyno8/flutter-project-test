import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/partner_repository.dart';

/// Use case for updating partner services
class UpdatePartnerServices implements UseCase<void, UpdatePartnerServicesParams> {
  final PartnerRepository repository;

  const UpdatePartnerServices(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePartnerServicesParams params) async {
    // Validate partner ID
    if (params.uid.trim().isEmpty) {
      return const Left(ValidationFailure('Partner ID cannot be empty'));
    }

    // Validate services list
    if (params.services.isEmpty) {
      return const Left(ValidationFailure('Partner must provide at least one service'));
    }

    if (params.services.length > 10) {
      return const Left(ValidationFailure('Partner cannot provide more than 10 services'));
    }

    // Validate each service ID
    for (final serviceId in params.services) {
      if (serviceId.trim().isEmpty) {
        return const Left(ValidationFailure('Service ID cannot be empty'));
      }

      if (!_isValidServiceId(serviceId)) {
        return Left(ValidationFailure('Invalid service ID format: $serviceId'));
      }
    }

    // Check for duplicate services
    final uniqueServices = params.services.toSet();
    if (uniqueServices.length != params.services.length) {
      return const Left(ValidationFailure('Duplicate services are not allowed'));
    }

    return await repository.updatePartnerServices(params.uid, params.services);
  }

  bool _isValidServiceId(String serviceId) {
    // Service ID should be alphanumeric with underscores and hyphens
    return RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(serviceId);
  }
}

/// Parameters for update partner services use case
class UpdatePartnerServicesParams extends Equatable {
  final String uid;
  final List<String> services;

  const UpdatePartnerServicesParams({
    required this.uid,
    required this.services,
  });

  @override
  List<Object> get props => [uid, services];
}
