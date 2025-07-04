import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../entities/booking_request.dart';

/// Domain repository interface for booking operations
abstract class BookingRepository {
  // Create a new booking
  Future<Either<Failure, Booking>> createBooking(BookingRequest request);

  // Get booking by ID
  Future<Either<Failure, Booking>> getBookingById(String bookingId);

  // Get user's bookings
  Future<Either<Failure, List<Booking>>> getUserBookings(
    String userId, {
    BookingStatus? status,
    int limit = 20,
  });

  // Get partner's bookings
  Future<Either<Failure, List<Booking>>> getPartnerBookings(
    String partnerId, {
    BookingStatus? status,
    int limit = 20,
  });

  // Get bookings by date range
  Future<Either<Failure, List<Booking>>> getBookingsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool isPartner = false,
  });

  // Update booking status
  Future<Either<Failure, Booking>> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  );

  // Cancel booking
  Future<Either<Failure, Booking>> cancelBooking(
    String bookingId,
    String cancellationReason,
  );

  // Confirm booking (partner accepts)
  Future<Either<Failure, Booking>> confirmBooking(
    String bookingId,
    String partnerId,
  );

  // Start booking (partner marks as in-progress)
  Future<Either<Failure, Booking>> startBooking(
    String bookingId,
    String partnerId,
  );

  // Complete booking
  Future<Either<Failure, Booking>> completeBooking(
    String bookingId,
    String partnerId,
  );

  // Real-time listeners
  Stream<Either<Failure, List<Booking>>> listenToUserBookings(
    String userId, {
    BookingStatus? status,
    int limit = 20,
  });

  Stream<Either<Failure, List<Booking>>> listenToPartnerBookings(
    String partnerId, {
    BookingStatus? status,
    int limit = 20,
  });

  Stream<Either<Failure, Booking>> listenToBooking(String bookingId);
}
