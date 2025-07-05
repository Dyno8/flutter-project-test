import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';
import '../models/review_model.dart';

/// Implementation of ReviewRepository
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Review>> createReview(ReviewRequest request) async {
    try {
      final requestModel = ReviewRequestModel.fromEntity(request);
      final review = await remoteDataSource.createReview(requestModel);
      return Right(review.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create review: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getPartnerReviews({
    required String partnerId,
    int limit = 20,
  }) async {
    try {
      final reviews = await remoteDataSource.getPartnerReviews(
        partnerId: partnerId,
        limit: limit,
      );
      return Right(reviews.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get partner reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getServiceReviews({
    required String serviceId,
    int limit = 20,
  }) async {
    try {
      final reviews = await remoteDataSource.getServiceReviews(
        serviceId: serviceId,
        limit: limit,
      );
      return Right(reviews.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get service reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getUserReviews({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final reviews = await remoteDataSource.getUserReviews(
        userId: userId,
        limit: limit,
      );
      return Right(reviews.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get user reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, Review?>> getBookingReview(String bookingId) async {
    try {
      final review = await remoteDataSource.getBookingReview(bookingId);
      return Right(review?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get booking review: $e'));
    }
  }

  @override
  Future<Either<Failure, Review>> updateReview({
    required String reviewId,
    required ReviewRequest request,
  }) async {
    try {
      final requestModel = ReviewRequestModel.fromEntity(request);
      final review = await remoteDataSource.updateReview(
        reviewId: reviewId,
        request: requestModel,
      );
      return Right(review.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update review: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete review: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> canReviewBooking({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final canReview = await remoteDataSource.canReviewBooking(
        bookingId: bookingId,
        userId: userId,
      );
      return Right(canReview);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to check review eligibility: $e'));
    }
  }
}
