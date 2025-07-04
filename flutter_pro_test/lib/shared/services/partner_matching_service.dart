import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partner_model.dart';
import '../models/booking_model.dart';
import '../repositories/partner_repository.dart';
import '../repositories/booking_repository.dart';
import '../../core/errors/failures.dart';

class PartnerMatchingService {
  final PartnerRepository _partnerRepository = PartnerRepository();
  final BookingRepository _bookingRepository = BookingRepository();

  // Find best matching partners for a booking request
  Future<Either<Failure, List<PartnerModel>>> findMatchingPartners({
    required List<String> serviceTypes,
    required GeoPoint clientLocation,
    required DateTime scheduledDate,
    required String timeSlot,
    double maxDistance = 10.0, // km
    double minRating = 3.0,
    int maxResults = 10,
  }) async {
    try {
      // Get available partners for the service types
      final partnersResult = await _partnerRepository.getAvailablePartners(
        services: serviceTypes,
        location: clientLocation,
        radiusKm: maxDistance,
        minRating: minRating,
        limit: maxResults * 2, // Get more to filter by availability
      );

      if (partnersResult is Left) {
        return partnersResult;
      }

      final partners = (partnersResult as Right).value;

      // Filter partners by time availability
      final availablePartners = <PartnerModel>[];
      final dayOfWeek = _getDayOfWeek(scheduledDate);

      for (final partner in partners) {
        if (await _isPartnerAvailableAt(partner, scheduledDate, timeSlot, dayOfWeek)) {
          availablePartners.add(partner);
        }
      }

      // Sort by matching score
      availablePartners.sort((a, b) => _calculateMatchingScore(
        b, clientLocation, serviceTypes, scheduledDate, timeSlot
      ).compareTo(_calculateMatchingScore(
        a, clientLocation, serviceTypes, scheduledDate, timeSlot
      )));

      return Right(availablePartners.take(maxResults).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to find matching partners: $e'));
    }
  }

  // Calculate matching score for a partner
  double _calculateMatchingScore(
    PartnerModel partner,
    GeoPoint clientLocation,
    List<String> serviceTypes,
    DateTime scheduledDate,
    String timeSlot,
  ) {
    double score = 0.0;

    // Rating score (0-50 points)
    score += partner.rating * 10;

    // Experience score (0-20 points)
    score += (partner.experienceYears * 2).clamp(0, 20);

    // Service match score (0-20 points)
    final matchingServices = serviceTypes.where(
      (service) => partner.services.contains(service)
    ).length;
    score += (matchingServices / serviceTypes.length) * 20;

    // Distance score (0-10 points, closer is better)
    final distance = _calculateDistance(
      clientLocation.latitude,
      clientLocation.longitude,
      partner.location.latitude,
      partner.location.longitude,
    );
    score += (10 - distance).clamp(0, 10);

    // Verification bonus (5 points)
    if (partner.isVerified) {
      score += 5;
    }

    // Total reviews bonus (0-5 points)
    score += (partner.totalReviews / 10).clamp(0, 5);

    return score;
  }

  // Check if partner is available at specific time
  Future<bool> _isPartnerAvailableAt(
    PartnerModel partner,
    DateTime scheduledDate,
    String timeSlot,
    String dayOfWeek,
  ) async {
    // Check working hours
    if (!partner.isAvailableAt(dayOfWeek, timeSlot)) {
      return false;
    }

    // Check for existing bookings at the same time
    final existingBookingsResult = await _bookingRepository.getPartnerBookings(
      partner.uid,
      status: 'confirmed',
    );

    if (existingBookingsResult is Left) {
      return true; // Assume available if we can't check
    }

    final existingBookings = (existingBookingsResult as Right).value;
    
    // Check for time conflicts
    for (final booking in existingBookings) {
      if (_isSameDate(booking.scheduledDate, scheduledDate) &&
          _isTimeConflict(booking.timeSlot, booking.hours, timeSlot)) {
        return false;
      }
    }

    return true;
  }

  // Get day of week string
  String _getDayOfWeek(DateTime date) {
    const days = [
      'monday', 'tuesday', 'wednesday', 'thursday',
      'friday', 'saturday', 'sunday'
    ];
    return days[date.weekday - 1];
  }

  // Check if two dates are the same day
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Check if time slots conflict
  bool _isTimeConflict(String existingTimeSlot, double existingHours, String newTimeSlot) {
    final existingStart = _parseTimeSlot(existingTimeSlot);
    final existingEnd = existingStart.add(Duration(
      minutes: (existingHours * 60).round()
    ));
    
    final newStart = _parseTimeSlot(newTimeSlot);
    
    return newStart.isBefore(existingEnd) && newStart.isAfter(existingStart.subtract(const Duration(minutes: 1)));
  }

  // Parse time slot string to DateTime
  DateTime _parseTimeSlot(String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Calculate distance between two points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * 
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Auto-assign partner to booking
  Future<Either<Failure, PartnerModel?>> autoAssignPartner({
    required List<String> serviceTypes,
    required GeoPoint clientLocation,
    required DateTime scheduledDate,
    required String timeSlot,
    double maxDistance = 15.0,
    double minRating = 3.5,
  }) async {
    final matchingPartnersResult = await findMatchingPartners(
      serviceTypes: serviceTypes,
      clientLocation: clientLocation,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      maxDistance: maxDistance,
      minRating: minRating,
      maxResults: 1,
    );

    if (matchingPartnersResult is Left) {
      return matchingPartnersResult;
    }

    final partners = (matchingPartnersResult as Right).value;
    return Right(partners.isNotEmpty ? partners.first : null);
  }

  // Get partner recommendations based on user history
  Future<Either<Failure, List<PartnerModel>>> getRecommendedPartners(
    String userId, {
    int limit = 5,
  }) async {
    try {
      // Get user's booking history
      final bookingHistoryResult = await _bookingRepository.getUserBookings(
        userId,
        status: 'completed',
        limit: 20,
      );

      if (bookingHistoryResult is Left) {
        return bookingHistoryResult;
      }

      final bookings = (bookingHistoryResult as Right).value;
      
      // Extract preferred service types
      final serviceTypes = bookings
          .map((booking) => booking.serviceId)
          .toSet()
          .toList();

      if (serviceTypes.isEmpty) {
        // No history, return top-rated partners
        return await _partnerRepository.getTopRatedPartners(limit: limit);
      }

      // Get partners for preferred services
      final partnersResult = await _partnerRepository.getAvailablePartners(
        services: serviceTypes,
        minRating: 4.0,
        limit: limit,
      );

      return partnersResult;
    } catch (e) {
      return Left(ServerFailure('Failed to get recommended partners: $e'));
    }
  }

  // Check partner availability for next 7 days
  Future<Either<Failure, Map<String, List<String>>>> getPartnerAvailability(
    String partnerId,
  ) async {
    try {
      final partnerResult = await _partnerRepository.getById(partnerId);
      if (partnerResult is Left) {
        return partnerResult;
      }

      final partner = (partnerResult as Right).value;
      final availability = <String, List<String>>{};
      
      final now = DateTime.now();
      
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final dayOfWeek = _getDayOfWeek(date);
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        final workingHours = partner.workingHours[dayOfWeek] ?? [];
        final availableSlots = <String>[];
        
        for (final timeSlot in workingHours) {
          if (await _isPartnerAvailableAt(partner, date, timeSlot, dayOfWeek)) {
            availableSlots.add(timeSlot);
          }
        }
        
        availability[dayKey] = availableSlots;
      }

      return Right(availability);
    } catch (e) {
      return Left(ServerFailure('Failed to get partner availability: $e'));
    }
  }
}
