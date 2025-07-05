import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../booking/domain/entities/partner.dart';
import '../repositories/client_service_repository.dart';

/// Use case for searching available partners for a service
class SearchAvailablePartners implements UseCase<List<Partner>, SearchAvailablePartnersParams> {
  final ClientServiceRepository repository;

  SearchAvailablePartners(this.repository);

  @override
  Future<Either<Failure, List<Partner>>> call(SearchAvailablePartnersParams params) async {
    return await repository.getAvailablePartners(
      serviceId: params.serviceId,
      date: params.date,
      timeSlot: params.timeSlot,
      clientLatitude: params.clientLatitude,
      clientLongitude: params.clientLongitude,
      maxDistance: params.maxDistance,
    );
  }
}

/// Parameters for searching available partners
class SearchAvailablePartnersParams extends Equatable {
  final String serviceId;
  final DateTime date;
  final String timeSlot;
  final double? clientLatitude;
  final double? clientLongitude;
  final double maxDistance;

  const SearchAvailablePartnersParams({
    required this.serviceId,
    required this.date,
    required this.timeSlot,
    this.clientLatitude,
    this.clientLongitude,
    this.maxDistance = 50.0,
  });

  @override
  List<Object?> get props => [
        serviceId,
        date,
        timeSlot,
        clientLatitude,
        clientLongitude,
        maxDistance,
      ];

  SearchAvailablePartnersParams copyWith({
    String? serviceId,
    DateTime? date,
    String? timeSlot,
    double? clientLatitude,
    double? clientLongitude,
    double? maxDistance,
  }) {
    return SearchAvailablePartnersParams(
      serviceId: serviceId ?? this.serviceId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      clientLatitude: clientLatitude ?? this.clientLatitude,
      clientLongitude: clientLongitude ?? this.clientLongitude,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }

  @override
  String toString() {
    return 'SearchAvailablePartnersParams(serviceId: $serviceId, date: $date, '
        'timeSlot: $timeSlot, clientLatitude: $clientLatitude, '
        'clientLongitude: $clientLongitude, maxDistance: $maxDistance)';
  }
}
