import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking_request.dart';
import '../../../booking/domain/entities/service.dart';
import '../../../booking/domain/entities/partner.dart';
import '../../../booking/domain/entities/booking.dart';

/// Domain repository interface for client service operations
abstract class ClientServiceRepository {
  /// Get all available services
  Future<Either<Failure, List<Service>>> getAvailableServices();

  /// Get service by ID
  Future<Either<Failure, Service>> getServiceById(String serviceId);

  /// Search services by query
  Future<Either<Failure, List<Service>>> searchServices(String query);

  /// Get services by category
  Future<Either<Failure, List<Service>>> getServicesByCategory(String category);

  /// Get available partners for a service and time slot
  Future<Either<Failure, List<Partner>>> getAvailablePartners({
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    double? clientLatitude,
    double? clientLongitude,
    double maxDistance = 50.0,
  });

  /// Create a new booking
  Future<Either<Failure, Booking>> createBooking(BookingRequest request);

  /// Get client's booking history
  Future<Either<Failure, List<Booking>>> getClientBookings({
    required String userId,
    BookingStatus? status,
    int limit = 20,
  });

  /// Cancel a booking
  Future<Either<Failure, void>> cancelBooking({
    required String bookingId,
    String? reason,
  });

  /// Get booking details
  Future<Either<Failure, Booking>> getBookingDetails(String bookingId);
}
