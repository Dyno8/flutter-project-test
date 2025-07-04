import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/service_model.dart';
import '../repositories/service_repository.dart';

/// Use case for getting popular services
class GetPopularServices implements UseCase<List<ServiceModel>, GetPopularServicesParams> {
  final ServiceRepository repository;

  const GetPopularServices(this.repository);

  @override
  Future<Either<Failure, List<ServiceModel>>> call(GetPopularServicesParams params) async {
    // Validate limit
    if (params.limit <= 0) {
      return const Left(ValidationFailure('Limit must be positive'));
    }

    if (params.limit > 50) {
      return const Left(ValidationFailure('Limit cannot exceed 50'));
    }

    return await repository.getPopularServices(limit: params.limit);
  }
}

/// Parameters for get popular services use case
class GetPopularServicesParams extends Equatable {
  final int limit;

  const GetPopularServicesParams({this.limit = 10});

  @override
  List<Object> get props => [limit];
}
