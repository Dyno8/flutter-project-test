import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/service_model.dart';
import '../repositories/service_repository.dart';

/// Use case for searching services
class SearchServices implements UseCase<List<ServiceModel>, SearchServicesParams> {
  final ServiceRepository repository;

  const SearchServices(this.repository);

  @override
  Future<Either<Failure, List<ServiceModel>>> call(SearchServicesParams params) async {
    // Validate search query
    if (params.query != null && params.query!.trim().length < 2) {
      return const Left(ValidationFailure('Search query must be at least 2 characters'));
    }

    // Validate price range
    if (params.minPrice != null && params.minPrice! < 0) {
      return const Left(ValidationFailure('Minimum price cannot be negative'));
    }

    if (params.maxPrice != null && params.maxPrice! < 0) {
      return const Left(ValidationFailure('Maximum price cannot be negative'));
    }

    if (params.minPrice != null && 
        params.maxPrice != null && 
        params.minPrice! > params.maxPrice!) {
      return const Left(ValidationFailure('Minimum price cannot be greater than maximum price'));
    }

    // Validate duration
    if (params.maxDuration != null && params.maxDuration! <= 0) {
      return const Left(ValidationFailure('Maximum duration must be positive'));
    }

    if (params.maxDuration != null && params.maxDuration! > 1440) {
      return const Left(ValidationFailure('Maximum duration cannot exceed 24 hours (1440 minutes)'));
    }

    // Validate category
    if (params.category != null && !_isValidCategory(params.category!)) {
      return const Left(ValidationFailure('Invalid category'));
    }

    return await repository.searchServices(
      query: params.query?.trim(),
      category: params.category?.toLowerCase(),
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      maxDuration: params.maxDuration,
      isActive: params.isActive ?? true, // Default to active services only
    );
  }

  bool _isValidCategory(String category) {
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

/// Parameters for search services use case
class SearchServicesParams extends Equatable {
  final String? query;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final int? maxDuration;
  final bool? isActive;

  const SearchServicesParams({
    this.query,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.maxDuration,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        query,
        category,
        minPrice,
        maxPrice,
        maxDuration,
        isActive,
      ];
}
