import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../booking/domain/entities/service.dart';
import '../../../booking/domain/entities/partner.dart';
import '../../../booking/domain/entities/booking.dart' as domain;
import '../../domain/entities/booking_request.dart';
import '../../domain/repositories/client_service_repository.dart';
import '../datasources/client_service_remote_data_source.dart';
import '../models/booking_request_model.dart';
import '../../../booking/data/mappers/partner_mapper.dart';
import '../../../booking/data/mappers/service_mapper.dart';
import '../../../booking/data/mappers/booking_mapper.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/models/booking_model.dart';

/// Implementation of ClientServiceRepository
class ClientServiceRepositoryImpl implements ClientServiceRepository {
  final ClientServiceRemoteDataSource remoteDataSource;

  ClientServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Service>>> getAvailableServices() async {
    try {
      final services = await remoteDataSource.getAvailableServices();
      return Right(
        services.map((model) => ServiceMapper.fromModel(model)).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get available services: $e'));
    }
  }

  @override
  Future<Either<Failure, Service>> getServiceById(String serviceId) async {
    try {
      final service = await remoteDataSource.getServiceById(serviceId);
      return Right(ServiceMapper.fromModel(service));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get service: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> searchServices(String query) async {
    try {
      final services = await remoteDataSource.searchServices(query);
      return Right(
        services.map((model) => ServiceMapper.fromModel(model)).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to search services: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> getServicesByCategory(
    String category,
  ) async {
    try {
      final services = await remoteDataSource.getServicesByCategory(category);
      return Right(
        services.map((model) => ServiceMapper.fromModel(model)).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get services by category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Partner>>> getAvailablePartners({
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    double? clientLatitude,
    double? clientLongitude,
    double maxDistance = 50.0,
  }) async {
    try {
      final partners = await remoteDataSource.getAvailablePartners(
        serviceId: serviceId,
        date: date,
        timeSlot: timeSlot,
        clientLatitude: clientLatitude,
        clientLongitude: clientLongitude,
        maxDistance: maxDistance,
      );
      return Right(
        partners.map((model) => PartnerMapper.fromModel(model)).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get available partners: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Booking>> createBooking(
    BookingRequest request,
  ) async {
    try {
      final requestModel = BookingRequestModel.fromEntity(request);
      final booking = await remoteDataSource.createBooking(requestModel);
      return Right(BookingMapper.fromModel(booking));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create booking: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Booking>>> getClientBookings({
    required String userId,
    domain.BookingStatus? status,
    int limit = 20,
  }) async {
    try {
      final bookings = await remoteDataSource.getClientBookings(
        userId: userId,
        status: status?.name,
        limit: limit,
      );
      return Right(
        bookings.map((model) => BookingMapper.fromModel(model)).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get client bookings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      await remoteDataSource.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel booking: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Booking>> getBookingDetails(
    String bookingId,
  ) async {
    try {
      final booking = await remoteDataSource.getBookingDetails(bookingId);
      return Right(BookingMapper.fromModel(booking));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get booking details: $e'));
    }
  }
}
