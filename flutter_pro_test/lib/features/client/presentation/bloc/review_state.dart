import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';

/// Base class for all review states
abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

/// Loading state
class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

/// Error state
class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Review created successfully
class ReviewCreated extends ReviewState {
  final Review review;

  const ReviewCreated(this.review);

  @override
  List<Object?> get props => [review];
}

/// Review updated successfully
class ReviewUpdated extends ReviewState {
  final Review review;

  const ReviewUpdated(this.review);

  @override
  List<Object?> get props => [review];
}

/// Review deleted successfully
class ReviewDeleted extends ReviewState {
  final String reviewId;

  const ReviewDeleted(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

/// Partner reviews loaded
class PartnerReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  final String partnerId;

  const PartnerReviewsLoaded({
    required this.reviews,
    required this.partnerId,
  });

  @override
  List<Object?> get props => [reviews, partnerId];
}

/// Service reviews loaded
class ServiceReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  final String serviceId;

  const ServiceReviewsLoaded({
    required this.reviews,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [reviews, serviceId];
}

/// User reviews loaded
class UserReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  final String userId;

  const UserReviewsLoaded({
    required this.reviews,
    required this.userId,
  });

  @override
  List<Object?> get props => [reviews, userId];
}

/// Booking review loaded
class BookingReviewLoaded extends ReviewState {
  final Review? review;
  final String bookingId;

  const BookingReviewLoaded({
    required this.review,
    required this.bookingId,
  });

  @override
  List<Object?> get props => [review, bookingId];
}

/// Can review booking result
class CanReviewBookingResult extends ReviewState {
  final bool canReview;
  final String bookingId;
  final String userId;

  const CanReviewBookingResult({
    required this.canReview,
    required this.bookingId,
    required this.userId,
  });

  @override
  List<Object?> get props => [canReview, bookingId, userId];
}
