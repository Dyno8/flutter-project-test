import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Use case for creating a review
class CreateReview implements UseCase<Review, ReviewRequest> {
  final ReviewRepository repository;

  CreateReview(this.repository);

  @override
  Future<Either<Failure, Review>> call(ReviewRequest params) async {
    // Validate review request
    if (!params.isValid) {
      return Left(ValidationFailure('Invalid review request'));
    }

    // Check if user can review this booking
    final canReviewResult = await repository.canReviewBooking(
      bookingId: params.bookingId,
      userId: params.userId,
    );

    return canReviewResult.fold(
      (failure) => Left(failure),
      (canReview) {
        if (!canReview) {
          return Left(ValidationFailure('User cannot review this booking'));
        }
        return repository.createReview(params);
      },
    );
  }
}

/// Custom failure for validation errors
class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
