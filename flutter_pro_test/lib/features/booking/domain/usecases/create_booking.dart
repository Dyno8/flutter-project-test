import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../entities/booking_request.dart';
import '../repositories/booking_repository.dart';

class CreateBooking implements UseCase<Booking, CreateBookingParams> {
  final BookingRepository repository;

  CreateBooking(this.repository);

  @override
  Future<Either<Failure, Booking>> call(CreateBookingParams params) async {
    // Validate booking request
    if (!params.request.isValid) {
      final errors = params.request.validationErrors.join(', ');
      return Left(ValidationFailure('Invalid booking request: $errors'));
    }

    // Create the booking
    return await repository.createBooking(params.request);
  }
}

class CreateBookingParams {
  final BookingRequest request;

  CreateBookingParams({required this.request});
}
