import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_datasource.dart';
import '../mappers/service_mapper.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Service>>> getActiveServices() async {
    try {
      final serviceModels = await remoteDataSource.getActiveServices();
      final services = serviceModels.map((model) => ServiceMapper.fromModel(model)).toList();
      return Right(services);
    } catch (e) {
      return Left(ServerFailure('Failed to get active services: $e'));
    }
  }

  @override
  Future<Either<Failure, Service>> getServiceById(String serviceId) async {
    try {
      final serviceModel = await remoteDataSource.getServiceById(serviceId);
      final service = ServiceMapper.fromModel(serviceModel);
      return Right(service);
    } catch (e) {
      return Left(ServerFailure('Failed to get service: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> getServicesByCategory(String category) async {
    try {
      final serviceModels = await remoteDataSource.getServicesByCategory(category);
      final services = serviceModels.map((model) => ServiceMapper.fromModel(model)).toList();
      return Right(services);
    } catch (e) {
      return Left(ServerFailure('Failed to get services by category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> searchServices(String query) async {
    try {
      final serviceModels = await remoteDataSource.searchServices(query);
      final services = serviceModels.map((model) => ServiceMapper.fromModel(model)).toList();
      return Right(services);
    } catch (e) {
      return Left(ServerFailure('Failed to search services: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Service>>> listenToActiveServices() {
    try {
      return remoteDataSource.listenToActiveServices().map((serviceModels) {
        final services = serviceModels.map((model) => ServiceMapper.fromModel(model)).toList();
        return Right(services);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to active services: $e')));
    }
  }
}
