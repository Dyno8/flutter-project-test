import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/partner_model.dart';
import '../repositories/partner_repository.dart';

/// Use case for searching partners
class SearchPartners implements UseCase<List<PartnerModel>, SearchPartnersParams> {
  final PartnerRepository repository;

  const SearchPartners(this.repository);

  @override
  Future<Either<Failure, List<PartnerModel>>> call(SearchPartnersParams params) async {
    // Validate search parameters
    if (params.query != null && params.query!.trim().length < 2) {
      return const Left(ValidationFailure('Search query must be at least 2 characters'));
    }

    if (params.minRating != null && (params.minRating! < 0 || params.minRating! > 5)) {
      return const Left(ValidationFailure('Minimum rating must be between 0 and 5'));
    }

    if (params.maxPrice != null && params.maxPrice! < 0) {
      return const Left(ValidationFailure('Maximum price cannot be negative'));
    }

    if (params.maxPrice != null && params.maxPrice! > 10000000) {
      return const Left(ValidationFailure('Maximum price cannot exceed 10,000,000 VND'));
    }

    // Validate services list
    if (params.services != null) {
      if (params.services!.isEmpty) {
        return const Left(ValidationFailure('Services list cannot be empty when provided'));
      }

      if (params.services!.length > 10) {
        return const Left(ValidationFailure('Cannot search for more than 10 services at once'));
      }

      for (final serviceId in params.services!) {
        if (serviceId.trim().isEmpty) {
          return const Left(ValidationFailure('Service ID cannot be empty'));
        }
      }
    }

    // Validate location parameters
    if (params.city != null && params.city!.trim().isEmpty) {
      return const Left(ValidationFailure('City cannot be empty when provided'));
    }

    if (params.district != null && params.district!.trim().isEmpty) {
      return const Left(ValidationFailure('District cannot be empty when provided'));
    }

    return await repository.searchPartners(
      query: params.query?.trim(),
      services: params.services,
      city: params.city?.trim(),
      district: params.district?.trim(),
      minRating: params.minRating,
      maxPrice: params.maxPrice,
      isVerified: params.isVerified,
      isAvailable: params.isAvailable,
    );
  }
}

/// Parameters for search partners use case
class SearchPartnersParams extends Equatable {
  final String? query;
  final List<String>? services;
  final String? city;
  final String? district;
  final double? minRating;
  final double? maxPrice;
  final bool? isVerified;
  final bool? isAvailable;

  const SearchPartnersParams({
    this.query,
    this.services,
    this.city,
    this.district,
    this.minRating,
    this.maxPrice,
    this.isVerified,
    this.isAvailable,
  });

  @override
  List<Object?> get props => [
        query,
        services,
        city,
        district,
        minRating,
        maxPrice,
        isVerified,
        isAvailable,
      ];
}
