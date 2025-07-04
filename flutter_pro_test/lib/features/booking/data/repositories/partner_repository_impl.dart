import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/partner.dart';
import '../../domain/repositories/partner_repository.dart';
import '../datasources/partner_remote_datasource.dart';
import '../mappers/partner_mapper.dart';

class PartnerRepositoryImpl implements PartnerRepository {
  final PartnerRemoteDataSource remoteDataSource;

  PartnerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Partner>>> getAvailablePartners(
    String serviceId,
    DateTime date,
    String timeSlot, {
    double? clientLatitude,
    double? clientLongitude,
    double maxDistance = 50.0,
  }) async {
    try {
      final partnerModels = await remoteDataSource.getAvailablePartners(
        serviceId,
        date,
        timeSlot,
        clientLatitude: clientLatitude,
        clientLongitude: clientLongitude,
        maxDistance: maxDistance,
      );
      final partners = partnerModels.map((model) => PartnerMapper.fromModel(model)).toList();
      return Right(partners);
    } catch (e) {
      return Left(ServerFailure('Failed to get available partners: $e'));
    }
  }

  @override
  Future<Either<Failure, Partner>> getPartnerById(String partnerId) async {
    try {
      final partnerModel = await remoteDataSource.getPartnerById(partnerId);
      final partner = PartnerMapper.fromModel(partnerModel);
      return Right(partner);
    } catch (e) {
      return Left(ServerFailure('Failed to get partner: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Partner>>> getPartnersByService(String serviceId) async {
    try {
      final partnerModels = await remoteDataSource.getPartnersByService(serviceId);
      final partners = partnerModels.map((model) => PartnerMapper.fromModel(model)).toList();
      return Right(partners);
    } catch (e) {
      return Left(ServerFailure('Failed to get partners by service: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Partner>>> searchPartners(
    String query, {
    String? serviceId,
    double? clientLatitude,
    double? clientLongitude,
  }) async {
    try {
      final partnerModels = await remoteDataSource.searchPartners(
        query,
        serviceId: serviceId,
        clientLatitude: clientLatitude,
        clientLongitude: clientLongitude,
      );
      final partners = partnerModels.map((model) => PartnerMapper.fromModel(model)).toList();
      return Right(partners);
    } catch (e) {
      return Left(ServerFailure('Failed to search partners: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<String>>>> getPartnerAvailability(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final availability = await remoteDataSource.getPartnerAvailability(
        partnerId,
        startDate,
        endDate,
      );
      return Right(availability);
    } catch (e) {
      return Left(ServerFailure('Failed to get partner availability: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Partner>>> listenToAvailablePartners(
    String serviceId,
    DateTime date,
    String timeSlot,
  ) {
    try {
      return remoteDataSource
          .listenToAvailablePartners(serviceId, date, timeSlot)
          .map((partnerModels) {
        final partners = partnerModels.map((model) => PartnerMapper.fromModel(model)).toList();
        return Right(partners);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to available partners: $e')));
    }
  }
}
