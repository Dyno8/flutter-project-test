import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/models/partner_model.dart';
import '../../../booking/data/mappers/partner_mapper.dart';
import '../models/booking_request_model.dart';

/// Remote data source for client service operations using Firebase
abstract class ClientServiceRemoteDataSource {
  Future<List<ServiceModel>> getAvailableServices();
  Future<ServiceModel> getServiceById(String serviceId);
  Future<List<ServiceModel>> searchServices(String query);
  Future<List<ServiceModel>> getServicesByCategory(String category);
  Future<List<PartnerModel>> getAvailablePartners({
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    double? clientLatitude,
    double? clientLongitude,
    double maxDistance = 50.0,
  });
  Future<BookingModel> createBooking(BookingRequestModel request);
  Future<List<BookingModel>> getClientBookings({
    required String userId,
    String? status,
    int limit = 20,
  });
  Future<void> cancelBooking({required String bookingId, String? reason});
  Future<BookingModel> getBookingDetails(String bookingId);
}

class ClientServiceRemoteDataSourceImpl
    implements ClientServiceRemoteDataSource {
  final FirebaseService _firebaseService;

  ClientServiceRemoteDataSourceImpl(this._firebaseService);

  static const String _servicesCollection = 'services';
  static const String _partnersCollection = 'partners';
  static const String _bookingsCollection = 'bookings';
  static const String _partnerAvailabilityCollection = 'partner_availability';

  @override
  Future<List<ServiceModel>> getAvailableServices() async {
    try {
      final query = _firebaseService.firestore
          .collection(_servicesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder');

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get available services: $e');
    }
  }

  @override
  Future<ServiceModel> getServiceById(String serviceId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(_servicesCollection)
          .doc(serviceId)
          .get();

      if (!doc.exists) {
        throw ServerException('Service not found');
      }

      return ServiceModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get service: $e');
    }
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      // Search by name (case-insensitive)
      final nameQuery = _firebaseService.firestore
          .collection(_servicesCollection)
          .where('isActive', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff');

      final snapshot = await nameQuery.get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to search services: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    try {
      final query = _firebaseService.firestore
          .collection(_servicesCollection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder');

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get services by category: $e');
    }
  }

  @override
  Future<List<PartnerModel>> getAvailablePartners({
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    double? clientLatitude,
    double? clientLongitude,
    double maxDistance = 50.0,
  }) async {
    try {
      // Get partners who provide this service
      final partnersQuery = _firebaseService.firestore
          .collection(_partnersCollection)
          .where('services', arrayContains: serviceId)
          .where('isAvailable', isEqualTo: true)
          .where('isVerified', isEqualTo: true);

      final partnersSnapshot = await partnersQuery.get();
      final partners = partnersSnapshot.docs
          .map((doc) => PartnerModel.fromFirestore(doc))
          .toList();

      // Filter by availability and distance
      final availablePartners = <PartnerModel>[];

      for (final partner in partners) {
        // Check if partner is available at the requested time
        if (await _isPartnerAvailable(partner.uid, date, timeSlot)) {
          // Check distance if location provided
          if (clientLatitude != null && clientLongitude != null) {
            final distance = _calculateDistance(
              partner.location.latitude,
              partner.location.longitude,
              clientLatitude,
              clientLongitude,
            );
            if (distance <= maxDistance) {
              availablePartners.add(partner);
            }
          } else {
            availablePartners.add(partner);
          }
        }
      }

      // Sort by rating and distance
      availablePartners.sort((a, b) {
        // Primary sort: rating (descending)
        final ratingComparison = b.rating.compareTo(a.rating);
        if (ratingComparison != 0) return ratingComparison;

        // Secondary sort: distance (ascending) if location provided
        if (clientLatitude != null && clientLongitude != null) {
          final distanceA = _calculateDistance(
            a.location.latitude,
            a.location.longitude,
            clientLatitude,
            clientLongitude,
          );
          final distanceB = _calculateDistance(
            b.location.latitude,
            b.location.longitude,
            clientLatitude,
            clientLongitude,
          );
          return distanceA.compareTo(distanceB);
        }

        return 0;
      });

      return availablePartners;
    } catch (e) {
      throw ServerException('Failed to get available partners: $e');
    }
  }

  /// Check if partner is available at the requested time
  Future<bool> _isPartnerAvailable(
    String partnerId,
    DateTime date,
    String timeSlot,
  ) async {
    try {
      // Check partner availability settings
      final availabilityDoc = await _firebaseService.firestore
          .collection(_partnerAvailabilityCollection)
          .doc(partnerId)
          .get();

      if (!availabilityDoc.exists) return false;

      final availability = availabilityDoc.data() as Map<String, dynamic>;
      final workingHours =
          availability['workingHours'] as Map<String, dynamic>?;

      if (workingHours == null) return false;

      // Get day of week
      final dayNames = [
        'sunday',
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
      ];
      final dayName = dayNames[date.weekday % 7];

      final dayHours = workingHours[dayName] as List<dynamic>?;
      if (dayHours == null || dayHours.isEmpty) return false;

      // Check if requested time slot overlaps with working hours
      final requestedStart = timeSlot.split('-')[0].trim();
      final requestedEnd = timeSlot.split('-')[1].trim();

      final workStart = dayHours[0] as String;
      final workEnd = dayHours[1] as String;

      // Simple time comparison (you might want to use a more robust time parsing)
      return _isTimeInRange(requestedStart, requestedEnd, workStart, workEnd);
    } catch (e) {
      return false;
    }
  }

  /// Simple time range check
  bool _isTimeInRange(
    String reqStart,
    String reqEnd,
    String workStart,
    String workEnd,
  ) {
    try {
      final reqStartTime = _parseTime(reqStart);
      final reqEndTime = _parseTime(reqEnd);
      final workStartTime = _parseTime(workStart);
      final workEndTime = _parseTime(workEnd);

      return reqStartTime >= workStartTime && reqEndTime <= workEndTime;
    } catch (e) {
      return false;
    }
  }

  /// Parse time string to minutes since midnight
  int _parseTime(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  /// Calculate distance between two points (simplified)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simplified distance calculation
    // In production, use a proper geolocation library
    final latDiff = (lat1 - lat2).abs();
    final lonDiff = (lon1 - lon2).abs();
    return (latDiff + lonDiff) * 111; // Rough km conversion
  }

  @override
  Future<BookingModel> createBooking(BookingRequestModel request) async {
    try {
      // Auto-assign partner if not specified
      String? partnerId = request.partnerId;
      if (partnerId == null) {
        final availablePartners = await getAvailablePartners(
          serviceId: request.serviceId,
          date: request.scheduledDate,
          timeSlot: request.timeSlot,
          clientLatitude: request.clientLatitude,
          clientLongitude: request.clientLongitude,
          maxDistance: request.maxDistance ?? 50.0,
        );

        if (availablePartners.isEmpty) {
          throw ServerException('No available partners found');
        }

        // Select the best partner (highest rated, closest)
        partnerId = availablePartners.first.uid;
      }

      // Get service details for pricing
      final service = await getServiceById(request.serviceId);
      final totalPrice = request.calculateTotalPrice(service.basePrice);

      // Create booking
      final bookingData = {
        'userId': request.userId,
        'partnerId': partnerId,
        'serviceId': request.serviceId,
        'serviceName': service.name,
        'scheduledDate': Timestamp.fromDate(request.scheduledDate),
        'timeSlot': request.timeSlot,
        'hours': request.hours,
        'totalPrice': totalPrice,
        'status': 'pending',
        'paymentStatus': 'unpaid',
        'clientAddress': request.clientAddress,
        'clientLatitude': request.clientLatitude,
        'clientLongitude': request.clientLongitude,
        'specialInstructions': request.specialInstructions,
        'isUrgent': request.isUrgent,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firebaseService.firestore
          .collection(_bookingsCollection)
          .add(bookingData);

      final doc = await docRef.get();
      return BookingModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to create booking: $e');
    }
  }

  @override
  Future<List<BookingModel>> getClientBookings({
    required String userId,
    String? status,
    int limit = 20,
  }) async {
    try {
      Query query = _firebaseService.firestore
          .collection(_bookingsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get client bookings: $e');
    }
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      await _firebaseService.firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .update({
            'status': 'cancelled',
            'cancellationReason': reason,
            'cancelledAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw ServerException('Failed to cancel booking: $e');
    }
  }

  @override
  Future<BookingModel> getBookingDetails(String bookingId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .get();

      if (!doc.exists) {
        throw ServerException('Booking not found');
      }

      return BookingModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get booking details: $e');
    }
  }
}
