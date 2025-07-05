import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/firebase_service.dart';
import '../models/review_model.dart';

/// Remote data source for review operations using Firebase
abstract class ReviewRemoteDataSource {
  Future<ReviewModel> createReview(ReviewRequestModel request);
  Future<List<ReviewModel>> getPartnerReviews({
    required String partnerId,
    int limit = 20,
  });
  Future<List<ReviewModel>> getServiceReviews({
    required String serviceId,
    int limit = 20,
  });
  Future<List<ReviewModel>> getUserReviews({
    required String userId,
    int limit = 20,
  });
  Future<ReviewModel?> getBookingReview(String bookingId);
  Future<ReviewModel> updateReview({
    required String reviewId,
    required ReviewRequestModel request,
  });
  Future<void> deleteReview(String reviewId);
  Future<bool> canReviewBooking({
    required String bookingId,
    required String userId,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseService _firebaseService;

  ReviewRemoteDataSourceImpl(this._firebaseService);

  static const String _reviewsCollection = 'reviews';
  static const String _bookingsCollection = 'bookings';
  static const String _partnersCollection = 'partners';

  @override
  Future<ReviewModel> createReview(ReviewRequestModel request) async {
    try {
      final reviewData = {
        ...request.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firebaseService.firestore
          .collection(_reviewsCollection)
          .add(reviewData);

      // Update partner's rating statistics
      await _updatePartnerRating(request.partnerId);

      // Update booking to mark as reviewed
      await _markBookingAsReviewed(request.bookingId);

      final doc = await docRef.get();
      return ReviewModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to create review: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getPartnerReviews({
    required String partnerId,
    int limit = 20,
  }) async {
    try {
      final query = _firebaseService.firestore
          .collection(_reviewsCollection)
          .where('partnerId', isEqualTo: partnerId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get partner reviews: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getServiceReviews({
    required String serviceId,
    int limit = 20,
  }) async {
    try {
      final query = _firebaseService.firestore
          .collection(_reviewsCollection)
          .where('serviceId', isEqualTo: serviceId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get service reviews: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getUserReviews({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final query = _firebaseService.firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user reviews: $e');
    }
  }

  @override
  Future<ReviewModel?> getBookingReview(String bookingId) async {
    try {
      final query = _firebaseService.firestore
          .collection(_reviewsCollection)
          .where('bookingId', isEqualTo: bookingId)
          .limit(1);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return null;
      }

      return ReviewModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw ServerException('Failed to get booking review: $e');
    }
  }

  @override
  Future<ReviewModel> updateReview({
    required String reviewId,
    required ReviewRequestModel request,
  }) async {
    try {
      final updateData = {
        ...request.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firebaseService.firestore
          .collection(_reviewsCollection)
          .doc(reviewId)
          .update(updateData);

      // Update partner's rating statistics
      await _updatePartnerRating(request.partnerId);

      final doc = await _firebaseService.firestore
          .collection(_reviewsCollection)
          .doc(reviewId)
          .get();

      return ReviewModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to update review: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      // Get review data before deletion to update partner rating
      final reviewDoc = await _firebaseService.firestore
          .collection(_reviewsCollection)
          .doc(reviewId)
          .get();

      if (reviewDoc.exists) {
        final reviewData = reviewDoc.data() as Map<String, dynamic>;
        final partnerId = reviewData['partnerId'] as String;

        // Delete the review
        await _firebaseService.firestore
            .collection(_reviewsCollection)
            .doc(reviewId)
            .delete();

        // Update partner's rating statistics
        await _updatePartnerRating(partnerId);

        // Update booking to mark as not reviewed
        final bookingId = reviewData['bookingId'] as String;
        await _markBookingAsNotReviewed(bookingId);
      }
    } catch (e) {
      throw ServerException('Failed to delete review: $e');
    }
  }

  @override
  Future<bool> canReviewBooking({
    required String bookingId,
    required String userId,
  }) async {
    try {
      // Check if booking exists and belongs to user
      final bookingDoc = await _firebaseService.firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) {
        return false;
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      
      // Check if booking belongs to user
      if (bookingData['userId'] != userId) {
        return false;
      }

      // Check if booking is completed
      if (bookingData['status'] != 'completed') {
        return false;
      }

      // Check if already reviewed
      final existingReview = await getBookingReview(bookingId);
      if (existingReview != null) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update partner's rating statistics
  Future<void> _updatePartnerRating(String partnerId) async {
    try {
      // Get all reviews for this partner
      final reviewsQuery = _firebaseService.firestore
          .collection(_reviewsCollection)
          .where('partnerId', isEqualTo: partnerId);

      final reviewsSnapshot = await reviewsQuery.get();
      
      if (reviewsSnapshot.docs.isEmpty) {
        return;
      }

      // Calculate average rating
      double totalRating = 0;
      int totalReviews = reviewsSnapshot.docs.length;
      
      for (final doc in reviewsSnapshot.docs) {
        final data = doc.data();
        totalRating += (data['rating'] ?? 0).toDouble();
      }

      final averageRating = totalRating / totalReviews;

      // Update partner document
      await _firebaseService.firestore
          .collection(_partnersCollection)
          .doc(partnerId)
          .update({
        'rating': averageRating,
        'totalReviews': totalReviews,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't fail the review creation
      print('Failed to update partner rating: $e');
    }
  }

  /// Mark booking as reviewed
  Future<void> _markBookingAsReviewed(String bookingId) async {
    try {
      await _firebaseService.firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .update({
        'isReviewed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't fail the review creation
      print('Failed to mark booking as reviewed: $e');
    }
  }

  /// Mark booking as not reviewed
  Future<void> _markBookingAsNotReviewed(String bookingId) async {
    try {
      await _firebaseService.firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .update({
        'isReviewed': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't fail the review deletion
      print('Failed to mark booking as not reviewed: $e');
    }
  }
}
