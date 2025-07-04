import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/partner.dart';

/// Domain repository interface for partner operations
abstract class PartnerRepository {
  // Get available partners for a service
  Future<Either<Failure, List<Partner>>> getAvailablePartners(
    String serviceId,
    DateTime date,
    String timeSlot, {
    double? clientLatitude,
    double? clientLongitude,
    double maxDistance = 50.0, // km
  });

  // Get partner by ID
  Future<Either<Failure, Partner>> getPartnerById(String partnerId);

  // Get partners by service
  Future<Either<Failure, List<Partner>>> getPartnersByService(String serviceId);

  // Search partners
  Future<Either<Failure, List<Partner>>> searchPartners(
    String query, {
    String? serviceId,
    double? clientLatitude,
    double? clientLongitude,
  });

  // Get partner availability
  Future<Either<Failure, Map<String, List<String>>>> getPartnerAvailability(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  );

  // Real-time listener for available partners
  Stream<Either<Failure, List<Partner>>> listenToAvailablePartners(
    String serviceId,
    DateTime date,
    String timeSlot,
  );
}
