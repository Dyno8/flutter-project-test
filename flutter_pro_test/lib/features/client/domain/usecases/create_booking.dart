import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../booking/domain/entities/booking.dart';
import '../entities/booking_request.dart';
import '../repositories/client_service_repository.dart';

/// Use case for creating a new booking
class CreateBooking implements UseCase<Booking, BookingRequest> {
  final ClientServiceRepository repository;

  CreateBooking(this.repository);

  @override
  Future<Either<Failure, Booking>> call(BookingRequest params) async {
    // Validate booking request
    if (!params.isValid) {
      return Left(ValidationFailure('Invalid booking request'));
    }

    return await repository.createBooking(params);
  }
}

/// Custom failure for validation errors
class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
