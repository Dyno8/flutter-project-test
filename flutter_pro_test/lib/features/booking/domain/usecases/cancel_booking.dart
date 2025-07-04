import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CancelBooking implements UseCase<Booking, CancelBookingParams> {
  final BookingRepository repository;

  CancelBooking(this.repository);

  @override
  Future<Either<Failure, Booking>> call(CancelBookingParams params) async {
    // Validate cancellation reason
    if (params.cancellationReason.trim().isEmpty) {
      return Left(ValidationFailure('Cancellation reason is required'));
    }

    return await repository.cancelBooking(
      params.bookingId,
      params.cancellationReason,
    );
  }
}

class CancelBookingParams {
  final String bookingId;
  final String cancellationReason;

  CancelBookingParams({
    required this.bookingId,
    required this.cancellationReason,
  });
}
