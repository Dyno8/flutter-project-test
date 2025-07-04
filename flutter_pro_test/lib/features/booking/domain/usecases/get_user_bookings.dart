import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetUserBookings implements UseCase<List<Booking>, GetUserBookingsParams> {
  final BookingRepository repository;

  GetUserBookings(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(GetUserBookingsParams params) async {
    return await repository.getUserBookings(
      params.userId,
      status: params.status,
      limit: params.limit,
    );
  }
}

class GetUserBookingsParams {
  final String userId;
  final BookingStatus? status;
  final int limit;

  GetUserBookingsParams({
    required this.userId,
    this.status,
    this.limit = 20,
  });
}
