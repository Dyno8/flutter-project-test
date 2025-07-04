import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service.dart';

/// Domain repository interface for service operations
abstract class ServiceRepository {
  // Get all active services
  Future<Either<Failure, List<Service>>> getActiveServices();

  // Get service by ID
  Future<Either<Failure, Service>> getServiceById(String serviceId);

  // Get services by category
  Future<Either<Failure, List<Service>>> getServicesByCategory(String category);

  // Search services
  Future<Either<Failure, List<Service>>> searchServices(String query);

  // Real-time listener for services
  Stream<Either<Failure, List<Service>>> listenToActiveServices();
}
