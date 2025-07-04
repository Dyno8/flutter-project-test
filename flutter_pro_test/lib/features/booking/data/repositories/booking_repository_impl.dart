import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../mappers/booking_mapper.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Booking>> createBooking(BookingRequest request) async {
    try {
      final bookingModel = await remoteDataSource.createBooking(request);
      final booking = BookingMapper.fromModel(bookingModel);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure('Failed to create booking: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String bookingId) async {
    try {
      final bookingModel = await remoteDataSource.getBookingById(bookingId);
      final booking = BookingMapper.fromModel(bookingModel);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure('Failed to get booking: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings(
    String userId, {
    BookingStatus? status,
    int limit = 20,
  }) async {
    try {
      final statusString = status?.toString().split('.').last;
      final bookingModels = await remoteDataSource.getUserBookings(
        userId,
        status: statusString,
        limit: limit,
      );
      final bookings = bookingModels.map((model) => BookingMapper.fromModel(model)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure('Failed to get user bookings: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getPartnerBookings(
    String partnerId, {
    BookingStatus? status,
    int limit = 20,
  }) async {
    try {
      final statusString = status?.toString().split('.').last;
      final bookingModels = await remoteDataSource.getPartnerBookings(
        partnerId,
        status: statusString,
        limit: limit,
      );
      final bookings = bookingModels.map((model) => BookingMapper.fromModel(model)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure('Failed to get partner bookings: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getBookingsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool isPartner = false,
  }) async {
    try {
      final bookingModels = await remoteDataSource.getBookingsByDateRange(
        userId,
        startDate,
        endDate,
        isPartner: isPartner,
      );
      final bookings = bookingModels.map((model) => BookingMapper.fromModel(model)).toList();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure('Failed to get bookings by date range: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      final statusString = status.toString().split('.').last;
      final bookingModel = await remoteDataSource.updateBookingStatus(bookingId, statusString);
      final booking = BookingMapper.fromModel(bookingModel);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure('Failed to update booking status: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(
    String bookingId,
    String cancellationReason,
  ) async {
    try {
      final bookingModel = await remoteDataSource.cancelBooking(bookingId, cancellationReason);
      final booking = BookingMapper.fromModel(bookingModel);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure('Failed to cancel booking: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> confirmBooking(
    String bookingId,
    String partnerId,
  ) async {
    try {
      final bookingModel = await remoteDataSource.confirmBooking(bookingId, partnerId);
      final booking = BookingMapper.fromModel(bookingModel);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure('Failed to confirm booking: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> startBooking(
    String bookingId,
    String partnerId,
  ) async {
    try {
      final bookingModel = await remoteDataSource.startBooking(bookingId, partnerId);
      final booking = BookingMapper.fromModel(bookingModel);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure('Failed to start booking: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> completeBooking(
    String bookingId,
    String partnerId,
  ) async {
    try {
      final bookingModel = await remoteDataSource.completeBooking(bookingId, partnerId);
      final booking = BookingMapper.fromModel(bookingModel);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure('Failed to complete booking: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Booking>>> listenToUserBookings(
    String userId, {
    BookingStatus? status,
    int limit = 20,
  }) {
    try {
      final statusString = status?.toString().split('.').last;
      return remoteDataSource
          .listenToUserBookings(userId, status: statusString, limit: limit)
          .map((bookingModels) {
        final bookings = bookingModels.map((model) => BookingMapper.fromModel(model)).toList();
        return Right(bookings);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to user bookings: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<Booking>>> listenToPartnerBookings(
    String partnerId, {
    BookingStatus? status,
    int limit = 20,
  }) {
    try {
      final statusString = status?.toString().split('.').last;
      return remoteDataSource
          .listenToPartnerBookings(partnerId, status: statusString, limit: limit)
          .map((bookingModels) {
        final bookings = bookingModels.map((model) => BookingMapper.fromModel(model)).toList();
        return Right(bookings);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to partner bookings: $e')));
    }
  }

  @override
  Stream<Either<Failure, Booking>> listenToBooking(String bookingId) {
    try {
      return remoteDataSource.listenToBooking(bookingId).map((bookingModel) {
        final booking = BookingMapper.fromModel(bookingModel);
        return Right(booking);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to booking: $e')));
    }
  }
}
