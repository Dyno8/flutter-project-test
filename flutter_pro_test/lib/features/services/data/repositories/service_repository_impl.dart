import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/service_model.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_datasource.dart';

/// Implementation of ServiceRepository using Firebase
class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceDataSource dataSource;

  const ServiceRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<ServiceModel>>> getAllServices() async {
    return await dataSource.getAllServices();
  }

  @override
  Future<Either<Failure, ServiceModel>> getService(String id) async {
    return await dataSource.getService(id);
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getServicesByCategory(String category) async {
    return await dataSource.getServicesByCategory(category);
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> searchServices({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    int? maxDuration,
    bool? isActive,
  }) async {
    return await dataSource.searchServices(
      query: query,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      maxDuration: maxDuration,
      isActive: isActive,
    );
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getPopularServices({int limit = 10}) async {
    // Get all services and sort by popularity
    final servicesResult = await dataSource.getAllServices();
    
    return servicesResult.fold(
      (failure) => Left(failure),
      (services) {
        // Sort by sort order (which represents popularity)
        services.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        
        // Take only the requested number
        final popularServices = services.take(limit).toList();
        return Right(popularServices);
      },
    );
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getFeaturedServices() async {
    // Get services with low sort order (featured services have lower sort order)
    final servicesResult = await dataSource.getAllServices();
    
    return servicesResult.fold(
      (failure) => Left(failure),
      (services) {
        // Filter featured services (sort order <= 10)
        final featuredServices = services
            .where((service) => service.sortOrder <= 10)
            .toList();
        
        return Right(featuredServices);
      },
    );
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getServicesByIds(List<String> ids) async {
    return await dataSource.getServicesByIds(ids);
  }

  @override
  Future<Either<Failure, ServiceModel>> createService(ServiceModel service) async {
    return await dataSource.createService(service);
  }

  @override
  Future<Either<Failure, ServiceModel>> updateService(ServiceModel service) async {
    return await dataSource.updateService(service);
  }

  @override
  Future<Either<Failure, void>> deleteService(String id) async {
    return await dataSource.deleteService(id);
  }

  @override
  Future<Either<Failure, void>> updateServicePopularity(String id, int popularity) async {
    final serviceResult = await dataSource.getService(id);
    
    return serviceResult.fold(
      (failure) => Left(failure),
      (service) async {
        final updatedService = service.copyWith(
          sortOrder: popularity,
          updatedAt: DateTime.now(),
        );
        
        final updateResult = await dataSource.updateService(updatedService);
        return updateResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> toggleServiceStatus(String id, bool isActive) async {
    final serviceResult = await dataSource.getService(id);
    
    return serviceResult.fold(
      (failure) => Left(failure),
      (service) async {
        final updatedService = service.copyWith(
          isActive: isActive,
          updatedAt: DateTime.now(),
        );
        
        final updateResult = await dataSource.updateService(updatedService);
        return updateResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<String>>> getServiceCategories() async {
    final servicesResult = await dataSource.getAllServices();
    
    return servicesResult.fold(
      (failure) => Left(failure),
      (services) {
        // Extract unique categories
        final categories = services
            .map((service) => service.category)
            .toSet()
            .toList();
        
        // Sort categories alphabetically
        categories.sort();
        
        return Right(categories);
      },
    );
  }

  @override
  Stream<Either<Failure, List<ServiceModel>>> watchAllServices() {
    return dataSource.watchAllServices();
  }

  @override
  Stream<Either<Failure, List<ServiceModel>>> watchServicesByCategory(String category) {
    return dataSource.watchServicesByCategory(category);
  }
}
