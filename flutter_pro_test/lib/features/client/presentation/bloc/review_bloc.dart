import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/repositories/review_repository.dart';
import 'review_event.dart';
import 'review_state.dart';

/// BLoC for managing review operations
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final CreateReview _createReview;
  final ReviewRepository _reviewRepository;

  ReviewBloc({
    required CreateReview createReview,
    required ReviewRepository reviewRepository,
  })  : _createReview = createReview,
        _reviewRepository = reviewRepository,
        super(const ReviewInitial()) {
    on<CreateReviewEvent>(_onCreateReview);
    on<LoadPartnerReviewsEvent>(_onLoadPartnerReviews);
    on<LoadServiceReviewsEvent>(_onLoadServiceReviews);
    on<LoadUserReviewsEvent>(_onLoadUserReviews);
    on<LoadBookingReviewEvent>(_onLoadBookingReview);
    on<UpdateReviewEvent>(_onUpdateReview);
    on<DeleteReviewEvent>(_onDeleteReview);
    on<CheckCanReviewEvent>(_onCheckCanReview);
    on<ClearReviewErrorEvent>(_onClearReviewError);
  }

  Future<void> _onCreateReview(
    CreateReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await _createReview(event.reviewRequest);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewCreated(review)),
    );
  }

  Future<void> _onLoadPartnerReviews(
    LoadPartnerReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await _reviewRepository.getPartnerReviews(
      partnerId: event.partnerId,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(PartnerReviewsLoaded(
        reviews: reviews,
        partnerId: event.partnerId,
      )),
    );
  }

  Future<void> _onLoadServiceReviews(
    LoadServiceReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await _reviewRepository.getServiceReviews(
      serviceId: event.serviceId,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(ServiceReviewsLoaded(
        reviews: reviews,
        serviceId: event.serviceId,
      )),
    );
  }

  Future<void> _onLoadUserReviews(
    LoadUserReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await _reviewRepository.getUserReviews(
      userId: event.userId,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(UserReviewsLoaded(
        reviews: reviews,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onLoadBookingReview(
    LoadBookingReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await _reviewRepository.getBookingReview(event.bookingId);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(BookingReviewLoaded(
        review: review,
        bookingId: event.bookingId,
      )),
    );
  }

  Future<void> _onUpdateReview(
    UpdateReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await _reviewRepository.updateReview(
      reviewId: event.reviewId,
      request: event.reviewRequest,
    );
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewUpdated(review)),
    );
  }

  Future<void> _onDeleteReview(
    DeleteReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await _reviewRepository.deleteReview(event.reviewId);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (_) => emit(ReviewDeleted(event.reviewId)),
    );
  }

  Future<void> _onCheckCanReview(
    CheckCanReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await _reviewRepository.canReviewBooking(
      bookingId: event.bookingId,
      userId: event.userId,
    );
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (canReview) => emit(CanReviewBookingResult(
        canReview: canReview,
        bookingId: event.bookingId,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onClearReviewError(
    ClearReviewErrorEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewInitial());
  }
}
