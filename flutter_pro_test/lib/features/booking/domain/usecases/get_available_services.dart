import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class GetAvailableServices implements UseCase<List<Service>, NoParams> {
  final ServiceRepository repository;

  GetAvailableServices(this.repository);

  @override
  Future<Either<Failure, List<Service>>> call(NoParams params) async {
    return await repository.getActiveServices();
  }
}
