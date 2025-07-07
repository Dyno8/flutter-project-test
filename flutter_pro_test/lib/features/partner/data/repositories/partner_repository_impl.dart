import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/location_model.dart';
import '../../../../shared/models/partner_model.dart';
import '../../domain/repositories/partner_repository.dart';
import '../datasources/partner_datasource.dart';

/// Implementation of PartnerRepository using Firebase
class PartnerRepositoryImpl implements PartnerRepository {
  final PartnerDataSource dataSource;

  const PartnerRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, PartnerModel>> getPartner(String uid) async {
    return await dataSource.getPartner(uid);
  }

  @override
  Future<Either<Failure, PartnerModel>> createPartner(
    PartnerModel partner,
  ) async {
    return await dataSource.createPartner(partner);
  }

  @override
  Future<Either<Failure, PartnerModel>> updatePartner(
    PartnerModel partner,
  ) async {
    return await dataSource.updatePartner(partner);
  }

  @override
  Future<Either<Failure, void>> deletePartner(String uid) async {
    return await dataSource.deletePartner(uid);
  }

  @override
  Future<Either<Failure, void>> updatePartnerServices(
    String uid,
    List<String> services,
  ) async {
    final partnerResult = await dataSource.getPartner(uid);

    return partnerResult.fold((failure) => Left(failure), (partner) async {
      final updatedPartner = partner.copyWith(
        services: services,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updatePartner(updatedPartner);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, void>> updateWorkingHours(
    String uid,
    Map<String, List<String>> workingHours,
  ) async {
    final partnerResult = await dataSource.getPartner(uid);

    return partnerResult.fold((failure) => Left(failure), (partner) async {
      final updatedPartner = partner.copyWith(
        workingHours: workingHours,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updatePartner(updatedPartner);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, void>> updatePartnerLocation(
    String uid,
    GeoPoint location,
  ) async {
    final partnerResult = await dataSource.getPartner(uid);

    return partnerResult.fold((failure) => Left(failure), (partner) async {
      final updatedPartner = partner.copyWith(
        location: location,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updatePartner(updatedPartner);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, void>> updateAvailabilityStatus(
    String uid,
    bool isAvailable,
  ) async {
    final partnerResult = await dataSource.getPartner(uid);

    return partnerResult.fold((failure) => Left(failure), (partner) async {
      final updatedPartner = partner.copyWith(
        isAvailable: isAvailable,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updatePartner(updatedPartner);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, void>> updateVerificationStatus(
    String uid,
    bool isVerified,
  ) async {
    final partnerResult = await dataSource.getPartner(uid);

    return partnerResult.fold((failure) => Left(failure), (partner) async {
      final updatedPartner = partner.copyWith(
        isVerified: isVerified,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updatePartner(updatedPartner);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, void>> updatePartnerRating(
    String uid,
    double rating,
    int totalReviews,
  ) async {
    final partnerResult = await dataSource.getPartner(uid);

    return partnerResult.fold((failure) => Left(failure), (partner) async {
      final updatedPartner = partner.copyWith(
        rating: rating,
        totalReviews: totalReviews,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updatePartner(updatedPartner);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, List<PartnerModel>>> getPartnersByService(
    String serviceId,
  ) async {
    return await dataSource.getPartnersByService(serviceId);
  }

  @override
  Future<Either<Failure, List<PartnerModel>>> getPartnersByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    // Get all available partners first
    final partnersResult = await dataSource.searchPartners(isAvailable: true);

    return partnersResult.fold((failure) => Left(failure), (partners) {
      // Filter partners by distance
      final nearbyPartners = partners.where((partner) {
        if (partner.location?.latitude == null ||
            partner.location?.longitude == null) {
          return false;
        }

        final distance = _calculateDistance(
          latitude,
          longitude,
          partner.location!.latitude,
          partner.location!.longitude,
        );

        return distance <= radiusKm;
      }).toList();

      // Sort by distance
      nearbyPartners.sort((a, b) {
        final distanceA = _calculateDistance(
          latitude,
          longitude,
          a.location!.latitude,
          a.location!.longitude,
        );
        final distanceB = _calculateDistance(
          latitude,
          longitude,
          b.location!.latitude,
          b.location!.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return Right(nearbyPartners);
    });
  }

  @override
  Future<Either<Failure, List<PartnerModel>>> searchPartners({
    String? query,
    List<String>? services,
    String? city,
    String? district,
    double? minRating,
    double? maxPrice,
    bool? isVerified,
    bool? isAvailable,
  }) async {
    return await dataSource.searchPartners(
      query: query,
      services: services,
      city: city,
      district: district,
      minRating: minRating,
      maxPrice: maxPrice,
      isVerified: isVerified,
      isAvailable: isAvailable,
    );
  }

  @override
  Future<Either<Failure, List<PartnerModel>>> getAvailablePartners({
    required String day,
    required String timeSlot,
    List<String>? services,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    // Get partners by services or all available partners
    final partnersResult = services != null && services.isNotEmpty
        ? await dataSource.searchPartners(services: services, isAvailable: true)
        : await dataSource.searchPartners(isAvailable: true);

    return partnersResult.fold((failure) => Left(failure), (partners) {
      // Filter by availability for specific time slot
      List<PartnerModel> availablePartners = partners.where((partner) {
        return partner.isAvailableAt(day, timeSlot);
      }).toList();

      // Filter by location if provided
      if (latitude != null && longitude != null && radiusKm != null) {
        availablePartners = availablePartners.where((partner) {
          if (partner.location?.latitude == null ||
              partner.location?.longitude == null) {
            return false;
          }

          final distance = _calculateDistance(
            latitude,
            longitude,
            partner.location!.latitude,
            partner.location!.longitude,
          );

          return distance <= radiusKm;
        }).toList();

        // Sort by distance
        availablePartners.sort((a, b) {
          final distanceA = _calculateDistance(
            latitude,
            longitude,
            a.location!.latitude,
            a.location!.longitude,
          );
          final distanceB = _calculateDistance(
            latitude,
            longitude,
            b.location!.latitude,
            b.location!.longitude,
          );
          return distanceA.compareTo(distanceB);
        });
      } else {
        // Sort by rating if no location filtering
        availablePartners.sort((a, b) => b.rating.compareTo(a.rating));
      }

      return Right(availablePartners);
    });
  }

  @override
  Future<Either<Failure, List<PartnerModel>>> getTopRatedPartners({
    int limit = 10,
    List<String>? services,
  }) async {
    final partnersResult = await dataSource.searchPartners(
      services: services,
      isAvailable: true,
      minRating: 4.0, // Only get highly rated partners
    );

    return partnersResult.fold((failure) => Left(failure), (partners) {
      // Sort by rating and total reviews
      partners.sort((a, b) {
        // First sort by rating
        final ratingComparison = b.rating.compareTo(a.rating);
        if (ratingComparison != 0) return ratingComparison;

        // If ratings are equal, sort by total reviews
        return b.totalReviews.compareTo(a.totalReviews);
      });

      // Take only the requested number
      final topPartners = partners.take(limit).toList();
      return Right(topPartners);
    });
  }

  @override
  Future<Either<Failure, List<PartnerModel>>> getNearbyPartners({
    required double latitude,
    required double longitude,
    required double radiusKm,
    List<String>? services,
  }) async {
    return await getPartnersByLocation(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }

  @override
  Stream<Either<Failure, PartnerModel>> watchPartner(String uid) {
    return dataSource.watchPartner(uid);
  }

  @override
  Stream<Either<Failure, List<PartnerModel>>> watchPartnersByCriteria({
    List<String>? services,
    String? city,
    bool? isAvailable,
  }) {
    return dataSource.watchPartnersByCriteria(
      services: services,
      city: city,
      isAvailable: isAvailable,
    );
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
