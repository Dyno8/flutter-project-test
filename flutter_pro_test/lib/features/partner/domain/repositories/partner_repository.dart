import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/partner_model.dart';

/// Abstract repository interface for partner operations
abstract class PartnerRepository {
  /// Get partner profile by ID
  Future<Either<Failure, PartnerModel>> getPartner(String uid);

  /// Create new partner profile
  Future<Either<Failure, PartnerModel>> createPartner(PartnerModel partner);

  /// Update existing partner profile
  Future<Either<Failure, PartnerModel>> updatePartner(PartnerModel partner);

  /// Delete partner profile
  Future<Either<Failure, void>> deletePartner(String uid);

  /// Update partner services
  Future<Either<Failure, void>> updatePartnerServices(String uid, List<String> services);

  /// Update partner working hours
  Future<Either<Failure, void>> updateWorkingHours(String uid, Map<String, List<String>> workingHours);

  /// Update partner location
  Future<Either<Failure, void>> updatePartnerLocation(String uid, LocationModel location);

  /// Update partner availability status
  Future<Either<Failure, void>> updateAvailabilityStatus(String uid, bool isAvailable);

  /// Update partner verification status
  Future<Either<Failure, void>> updateVerificationStatus(String uid, bool isVerified);

  /// Update partner rating
  Future<Either<Failure, void>> updatePartnerRating(String uid, double rating, int totalReviews);

  /// Get partners by service
  Future<Either<Failure, List<PartnerModel>>> getPartnersByService(String serviceId);

  /// Get partners by location
  Future<Either<Failure, List<PartnerModel>>> getPartnersByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  /// Search partners
  Future<Either<Failure, List<PartnerModel>>> searchPartners({
    String? query,
    List<String>? services,
    String? city,
    String? district,
    double? minRating,
    double? maxPrice,
    bool? isVerified,
    bool? isAvailable,
  });

  /// Get available partners for specific time slot
  Future<Either<Failure, List<PartnerModel>>> getAvailablePartners({
    required String day,
    required String timeSlot,
    List<String>? services,
    double? latitude,
    double? longitude,
    double? radiusKm,
  });

  /// Get top rated partners
  Future<Either<Failure, List<PartnerModel>>> getTopRatedPartners({
    int limit = 10,
    List<String>? services,
  });

  /// Get nearby partners
  Future<Either<Failure, List<PartnerModel>>> getNearbyPartners({
    required double latitude,
    required double longitude,
    required double radiusKm,
    List<String>? services,
  });

  /// Stream of partner profile changes
  Stream<Either<Failure, PartnerModel>> watchPartner(String uid);

  /// Stream of partners by criteria
  Stream<Either<Failure, List<PartnerModel>>> watchPartnersByCriteria({
    List<String>? services,
    String? city,
    bool? isAvailable,
  });
}
