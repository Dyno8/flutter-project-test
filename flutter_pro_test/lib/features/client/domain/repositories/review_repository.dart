import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review.dart';

/// Domain repository interface for review operations
abstract class ReviewRepository {
  /// Create a new review
  Future<Either<Failure, Review>> createReview(ReviewRequest request);

  /// Get reviews for a partner
  Future<Either<Failure, List<Review>>> getPartnerReviews({
    required String partnerId,
    int limit = 20,
  });

  /// Get reviews for a service
  Future<Either<Failure, List<Review>>> getServiceReviews({
    required String serviceId,
    int limit = 20,
  });

  /// Get reviews by a user
  Future<Either<Failure, List<Review>>> getUserReviews({
    required String userId,
    int limit = 20,
  });

  /// Get review for a specific booking
  Future<Either<Failure, Review?>> getBookingReview(String bookingId);

  /// Update an existing review
  Future<Either<Failure, Review>> updateReview({
    required String reviewId,
    required ReviewRequest request,
  });

  /// Delete a review
  Future<Either<Failure, void>> deleteReview(String reviewId);

  /// Check if user can review a booking
  Future<Either<Failure, bool>> canReviewBooking({
    required String bookingId,
    required String userId,
  });
}
