import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/service_model.dart';

/// Abstract repository interface for service operations
abstract class ServiceRepository {
  /// Get all services
  Future<Either<Failure, List<ServiceModel>>> getAllServices();

  /// Get service by ID
  Future<Either<Failure, ServiceModel>> getService(String id);

  /// Get services by category
  Future<Either<Failure, List<ServiceModel>>> getServicesByCategory(String category);

  /// Search services
  Future<Either<Failure, List<ServiceModel>>> searchServices({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    int? maxDuration,
    bool? isActive,
  });

  /// Get popular services
  Future<Either<Failure, List<ServiceModel>>> getPopularServices({int limit = 10});

  /// Get featured services
  Future<Either<Failure, List<ServiceModel>>> getFeaturedServices();

  /// Get services by IDs
  Future<Either<Failure, List<ServiceModel>>> getServicesByIds(List<String> ids);

  /// Create new service (admin only)
  Future<Either<Failure, ServiceModel>> createService(ServiceModel service);

  /// Update existing service (admin only)
  Future<Either<Failure, ServiceModel>> updateService(ServiceModel service);

  /// Delete service (admin only)
  Future<Either<Failure, void>> deleteService(String id);

  /// Update service popularity
  Future<Either<Failure, void>> updateServicePopularity(String id, int popularity);

  /// Toggle service active status
  Future<Either<Failure, void>> toggleServiceStatus(String id, bool isActive);

  /// Get service categories
  Future<Either<Failure, List<String>>> getServiceCategories();

  /// Stream of all services
  Stream<Either<Failure, List<ServiceModel>>> watchAllServices();

  /// Stream of services by category
  Stream<Either<Failure, List<ServiceModel>>> watchServicesByCategory(String category);
}
