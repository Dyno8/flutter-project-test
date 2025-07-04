import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/service_model.dart';
import '../repositories/service_repository.dart';

/// Use case for getting services by category
class GetServicesByCategory implements UseCase<List<ServiceModel>, GetServicesByCategoryParams> {
  final ServiceRepository repository;

  const GetServicesByCategory(this.repository);

  @override
  Future<Either<Failure, List<ServiceModel>>> call(GetServicesByCategoryParams params) async {
    // Validate category
    if (params.category.trim().isEmpty) {
      return const Left(ValidationFailure('Category cannot be empty'));
    }

    // Validate category format
    if (!_isValidCategory(params.category)) {
      return const Left(ValidationFailure('Invalid category format'));
    }

    return await repository.getServicesByCategory(params.category.toLowerCase());
  }

  bool _isValidCategory(String category) {
    // Valid categories for CareNow
    const validCategories = [
      'elder_care',
      'child_care',
      'pet_care',
      'housekeeping',
      'medical_care',
      'companion_care',
      'disability_care',
      'postpartum_care',
    ];

    return validCategories.contains(category.toLowerCase());
  }
}

/// Parameters for get services by category use case
class GetServicesByCategoryParams extends Equatable {
  final String category;

  const GetServicesByCategoryParams({required this.category});

  @override
  List<Object> get props => [category];
}
