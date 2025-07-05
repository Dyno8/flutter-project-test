import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../booking/domain/entities/booking.dart';
import '../repositories/client_service_repository.dart';

/// Use case for getting client's booking history
class GetClientBookings implements UseCase<List<Booking>, GetClientBookingsParams> {
  final ClientServiceRepository repository;

  GetClientBookings(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(GetClientBookingsParams params) async {
    return await repository.getClientBookings(
      userId: params.userId,
      status: params.status,
      limit: params.limit,
    );
  }
}

/// Parameters for getting client bookings
class GetClientBookingsParams extends Equatable {
  final String userId;
  final BookingStatus? status;
  final int limit;

  const GetClientBookingsParams({
    required this.userId,
    this.status,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, status, limit];

  GetClientBookingsParams copyWith({
    String? userId,
    BookingStatus? status,
    int? limit,
  }) {
    return GetClientBookingsParams(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      limit: limit ?? this.limit,
    );
  }

  @override
  String toString() {
    return 'GetClientBookingsParams(userId: $userId, status: $status, limit: $limit)';
  }
}
