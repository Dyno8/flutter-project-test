import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';

/// Base class for all review events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a new review
class CreateReviewEvent extends ReviewEvent {
  final ReviewRequest reviewRequest;

  const CreateReviewEvent(this.reviewRequest);

  @override
  List<Object?> get props => [reviewRequest];
}

/// Event to load reviews for a partner
class LoadPartnerReviewsEvent extends ReviewEvent {
  final String partnerId;
  final int limit;

  const LoadPartnerReviewsEvent({
    required this.partnerId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [partnerId, limit];
}

/// Event to load reviews for a service
class LoadServiceReviewsEvent extends ReviewEvent {
  final String serviceId;
  final int limit;

  const LoadServiceReviewsEvent({
    required this.serviceId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [serviceId, limit];
}

/// Event to load reviews by a user
class LoadUserReviewsEvent extends ReviewEvent {
  final String userId;
  final int limit;

  const LoadUserReviewsEvent({
    required this.userId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, limit];
}

/// Event to load review for a specific booking
class LoadBookingReviewEvent extends ReviewEvent {
  final String bookingId;

  const LoadBookingReviewEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Event to update an existing review
class UpdateReviewEvent extends ReviewEvent {
  final String reviewId;
  final ReviewRequest reviewRequest;

  const UpdateReviewEvent({
    required this.reviewId,
    required this.reviewRequest,
  });

  @override
  List<Object?> get props => [reviewId, reviewRequest];
}

/// Event to delete a review
class DeleteReviewEvent extends ReviewEvent {
  final String reviewId;

  const DeleteReviewEvent(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

/// Event to check if user can review a booking
class CheckCanReviewEvent extends ReviewEvent {
  final String bookingId;
  final String userId;

  const CheckCanReviewEvent({
    required this.bookingId,
    required this.userId,
  });

  @override
  List<Object?> get props => [bookingId, userId];
}

/// Event to clear review errors
class ClearReviewErrorEvent extends ReviewEvent {
  const ClearReviewErrorEvent();
}
