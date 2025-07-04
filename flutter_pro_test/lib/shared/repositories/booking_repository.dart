import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../services/firebase_service.dart';
import 'base_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

class BookingRepository extends BaseRepository<BookingModel> {
  @override
  String get collectionName => AppConstants.bookingsCollection;

  @override
  BookingModel fromFirestore(DocumentSnapshot doc) {
    return BookingModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toMap(BookingModel model) {
    return model.toMap();
  }

  // Booking-specific methods
  Future<Either<Failure, BookingModel>> createBooking(BookingModel booking) async {
    try {
      final data = booking.toMap();
      final docRef = await FirebaseService().addDocument(collectionName, data);
      final doc = await docRef.get();
      final createdBooking = fromFirestore(doc);
      return Right(createdBooking);
    } catch (e) {
      return Left(ServerFailure('Failed to create booking: $e'));
    }
  }

  Future<Either<Failure, List<BookingModel>>> getUserBookings(
    String userId, {
    String? status,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = where('userId', userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get();
      final bookings = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure('Failed to get user bookings: $e'));
    }
  }

  Future<Either<Failure, List<BookingModel>>> getPartnerBookings(
    String partnerId, {
    String? status,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = where('partnerId', partnerId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get();
      final bookings = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure('Failed to get partner bookings: $e'));
    }
  }

  Future<Either<Failure, List<BookingModel>>> getPendingBookings({
    int limit = 50,
  }) async {
    try {
      final query = where('status', AppConstants.statusPending)
          .orderBy('createdAt', descending: false)
          .limit(limit);

      final snapshot = await query.get();
      final bookings = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure('Failed to get pending bookings: $e'));
    }
  }

  Future<Either<Failure, List<BookingModel>>> getTodayBookings(
    String partnerId,
  ) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final query = where('partnerId', partnerId)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('scheduledDate');

      final snapshot = await query.get();
      final bookings = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure('Failed to get today bookings: $e'));
    }
  }

  Future<Either<Failure, BookingModel>> updateBookingStatus(
    String bookingId,
    String status, {
    String? cancellationReason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == AppConstants.statusCompleted) {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      } else if (status == AppConstants.statusCancelled) {
        updateData['cancelledAt'] = FieldValue.serverTimestamp();
        if (cancellationReason != null) {
          updateData['cancellationReason'] = cancellationReason;
        }
      }

      await FirebaseService().updateDocument(collectionName, bookingId, updateData);
      
      final doc = await FirebaseService().getDocument(collectionName, bookingId);
      final updatedBooking = fromFirestore(doc);
      return Right(updatedBooking);
    } catch (e) {
      return Left(ServerFailure('Failed to update booking status: $e'));
    }
  }

  Future<Either<Failure, BookingModel>> updatePaymentStatus(
    String bookingId,
    String paymentStatus, {
    String? paymentMethod,
    String? transactionId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (paymentMethod != null) {
        updateData['paymentMethod'] = paymentMethod;
      }

      if (transactionId != null) {
        updateData['paymentTransactionId'] = transactionId;
      }

      await FirebaseService().updateDocument(collectionName, bookingId, updateData);
      
      final doc = await FirebaseService().getDocument(collectionName, bookingId);
      final updatedBooking = fromFirestore(doc);
      return Right(updatedBooking);
    } catch (e) {
      return Left(ServerFailure('Failed to update payment status: $e'));
    }
  }

  Future<Either<Failure, List<BookingModel>>> getBookingsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool isPartner = false,
  }) async {
    try {
      final field = isPartner ? 'partnerId' : 'userId';
      final query = where(field, userId)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('scheduledDate');

      final snapshot = await query.get();
      final bookings = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure('Failed to get bookings by date range: $e'));
    }
  }

  Future<Either<Failure, double>> calculatePartnerEarnings(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = where('partnerId', partnerId)
          .where('status', AppConstants.statusCompleted)
          .where('paymentStatus', AppConstants.paymentPaid)
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      final snapshot = await query.get();
      final bookings = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      
      final totalEarnings = bookings.fold<double>(
        0.0,
        (sum, booking) => sum + booking.totalPrice,
      );

      return Right(totalEarnings);
    } catch (e) {
      return Left(ServerFailure('Failed to calculate partner earnings: $e'));
    }
  }

  // Real-time listeners
  Stream<Either<Failure, List<BookingModel>>> listenToUserBookings(
    String userId, {
    String? status,
    int limit = 20,
  }) {
    try {
      Query<Map<String, dynamic>> query = where('userId', userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      return FirebaseService()
          .listenToCollection(collectionName, query: query)
          .map((snapshot) {
        final bookings = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        return Right(bookings);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to user bookings: $e')));
    }
  }

  Stream<Either<Failure, List<BookingModel>>> listenToPartnerBookings(
    String partnerId, {
    String? status,
    int limit = 20,
  }) {
    try {
      Query<Map<String, dynamic>> query = where('partnerId', partnerId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      return FirebaseService()
          .listenToCollection(collectionName, query: query)
          .map((snapshot) {
        final bookings = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        return Right(bookings);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to partner bookings: $e')));
    }
  }

  // Validation methods
  bool isValidBookingTime(DateTime scheduledDate, String timeSlot) {
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1]),
    );
    
    // Booking must be at least 2 hours in the future
    return bookingDateTime.difference(now).inHours >= 2;
  }

  bool isValidHours(double hours) {
    return hours >= 1.0 && hours <= 12.0; // 1-12 hours per booking
  }

  bool isValidPrice(double price) {
    return price > 0 && price <= 10000; // Reasonable price range in thousands VND
  }
}
