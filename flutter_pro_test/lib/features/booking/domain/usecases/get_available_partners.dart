import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/partner.dart';
import '../repositories/partner_repository.dart';

class GetAvailablePartners implements UseCase<List<Partner>, GetAvailablePartnersParams> {
  final PartnerRepository repository;

  GetAvailablePartners(this.repository);

  @override
  Future<Either<Failure, List<Partner>>> call(GetAvailablePartnersParams params) async {
    return await repository.getAvailablePartners(
      params.serviceId,
      params.date,
      params.timeSlot,
      clientLatitude: params.clientLatitude,
      clientLongitude: params.clientLongitude,
      maxDistance: params.maxDistance,
    );
  }
}

class GetAvailablePartnersParams {
  final String serviceId;
  final DateTime date;
  final String timeSlot;
  final double? clientLatitude;
  final double? clientLongitude;
  final double maxDistance;

  GetAvailablePartnersParams({
    required this.serviceId,
    required this.date,
    required this.timeSlot,
    this.clientLatitude,
    this.clientLongitude,
    this.maxDistance = 50.0,
  });
}
