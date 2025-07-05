import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../booking/domain/entities/service.dart';
import '../repositories/client_service_repository.dart';

/// Use case for getting all available services
class GetAvailableServices implements UseCase<List<Service>, NoParams> {
  final ClientServiceRepository repository;

  GetAvailableServices(this.repository);

  @override
  Future<Either<Failure, List<Service>>> call(NoParams params) async {
    return await repository.getAvailableServices();
  }
}
