import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/booking_request.dart';

/// Remote data source for booking operations using Firebase
abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingRequest request);
  Future<BookingModel> getBookingById(String bookingId);
  Future<List<BookingModel>> getUserBookings(String userId, {String? status, int limit = 20});
  Future<List<BookingModel>> getPartnerBookings(String partnerId, {String? status, int limit = 20});
  Future<List<BookingModel>> getBookingsByDateRange(String userId, DateTime startDate, DateTime endDate, {bool isPartner = false});
  Future<BookingModel> updateBookingStatus(String bookingId, String status);
  Future<BookingModel> cancelBooking(String bookingId, String cancellationReason);
  Future<BookingModel> confirmBooking(String bookingId, String partnerId);
  Future<BookingModel> startBooking(String bookingId, String partnerId);
  Future<BookingModel> completeBooking(String bookingId, String partnerId);
  Stream<List<BookingModel>> listenToUserBookings(String userId, {String? status, int limit = 20});
  Stream<List<BookingModel>> listenToPartnerBookings(String partnerId, {String? status, int limit = 20});
  Stream<BookingModel> listenToBooking(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseService _firebaseService;

  BookingRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<BookingModel> createBooking(BookingRequest request) async {
    try {
      final bookingData = {
        'userId': request.userId,
        'partnerId': '', // Will be assigned later
        'serviceId': request.serviceId,
        'serviceName': request.serviceName,
        'scheduledDate': Timestamp.fromDate(request.scheduledDate),
        'timeSlot': request.timeSlot,
        'hours': request.hours,
        'totalPrice': request.totalPrice,
        'status': AppConstants.statusPending,
        'paymentStatus': AppConstants.paymentUnpaid,
        'clientAddress': request.clientAddress,
        'clientLocation': GeoPoint(request.clientLatitude, request.clientLongitude),
        'specialInstructions': request.specialInstructions,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      final docRef = await _firebaseService.addDocument(
        AppConstants.bookingsCollection,
        bookingData,
      );

      final doc = await docRef.get();
      return BookingModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.bookingsCollection,
        bookingId,
      );
      return BookingModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId, {String? status, int limit = 20}) async {
    try {
      Query<Map<String, dynamic>> query = _firebaseService.collection(AppConstants.bookingsCollection)
          .where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  @override
  Future<List<BookingModel>> getPartnerBookings(String partnerId, {String? status, int limit = 20}) async {
    try {
      Query<Map<String, dynamic>> query = _firebaseService.collection(AppConstants.bookingsCollection)
          .where('partnerId', isEqualTo: partnerId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get partner bookings: $e');
    }
  }

  @override
  Future<List<BookingModel>> getBookingsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool isPartner = false,
  }) async {
    try {
      final field = isPartner ? 'partnerId' : 'userId';
      final query = _firebaseService.collection(AppConstants.bookingsCollection)
          .where(field, isEqualTo: userId)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('scheduledDate');

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get bookings by date range: $e');
    }
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.bookingsCollection,
        bookingId,
        {
          'status': status,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      return await getBookingById(bookingId);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, String cancellationReason) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.bookingsCollection,
        bookingId,
        {
          'status': AppConstants.statusCancelled,
          'cancellationReason': cancellationReason,
          'cancelledAt': Timestamp.fromDate(DateTime.now()),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      return await getBookingById(bookingId);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  @override
  Future<BookingModel> confirmBooking(String bookingId, String partnerId) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.bookingsCollection,
        bookingId,
        {
          'partnerId': partnerId,
          'status': AppConstants.statusConfirmed,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      return await getBookingById(bookingId);
    } catch (e) {
      throw Exception('Failed to confirm booking: $e');
    }
  }

  @override
  Future<BookingModel> startBooking(String bookingId, String partnerId) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.bookingsCollection,
        bookingId,
        {
          'status': AppConstants.statusInProgress,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      return await getBookingById(bookingId);
    } catch (e) {
      throw Exception('Failed to start booking: $e');
    }
  }

  @override
  Future<BookingModel> completeBooking(String bookingId, String partnerId) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.bookingsCollection,
        bookingId,
        {
          'status': AppConstants.statusCompleted,
          'completedAt': Timestamp.fromDate(DateTime.now()),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      return await getBookingById(bookingId);
    } catch (e) {
      throw Exception('Failed to complete booking: $e');
    }
  }

  @override
  Stream<List<BookingModel>> listenToUserBookings(String userId, {String? status, int limit = 20}) {
    try {
      Query<Map<String, dynamic>> query = _firebaseService.collection(AppConstants.bookingsCollection)
          .where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw Exception('Failed to listen to user bookings: $e');
    }
  }

  @override
  Stream<List<BookingModel>> listenToPartnerBookings(String partnerId, {String? status, int limit = 20}) {
    try {
      Query<Map<String, dynamic>> query = _firebaseService.collection(AppConstants.bookingsCollection)
          .where('partnerId', isEqualTo: partnerId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw Exception('Failed to listen to partner bookings: $e');
    }
  }

  @override
  Stream<BookingModel> listenToBooking(String bookingId) {
    try {
      return _firebaseService
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .snapshots()
          .map((doc) => BookingModel.fromFirestore(doc));
    } catch (e) {
      throw Exception('Failed to listen to booking: $e');
    }
  }
}
