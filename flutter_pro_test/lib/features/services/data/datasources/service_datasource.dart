import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/service_model.dart';

/// Abstract interface for service data source
abstract class ServiceDataSource {
  Future<Either<Failure, List<ServiceModel>>> getAllServices();
  Future<Either<Failure, ServiceModel>> getService(String id);
  Future<Either<Failure, List<ServiceModel>>> getServicesByCategory(
    String category,
  );
  Future<Either<Failure, List<ServiceModel>>> searchServices({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    int? maxDuration,
    bool? isActive,
  });
  Future<Either<Failure, List<ServiceModel>>> getServicesByIds(
    List<String> ids,
  );
  Future<Either<Failure, ServiceModel>> createService(ServiceModel service);
  Future<Either<Failure, ServiceModel>> updateService(ServiceModel service);
  Future<Either<Failure, void>> deleteService(String id);
  Stream<Either<Failure, List<ServiceModel>>> watchAllServices();
  Stream<Either<Failure, List<ServiceModel>>> watchServicesByCategory(
    String category,
  );
}

/// Implementation of service data source using Firebase
class FirebaseServiceDataSource implements ServiceDataSource {
  final FirebaseFirestore _firestore;

  FirebaseServiceDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'services';

  @override
  Future<Either<Failure, List<ServiceModel>>> getAllServices() async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      final services = query.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      return Right(services);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to get services: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> getService(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return const Left(DataFailure('Service not found'));
      }

      final service = ServiceModel.fromFirestore(doc);
      return Right(service);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to get service: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getServicesByCategory(
    String category,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      final services = query.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      return Right(services);
    } on FirebaseException catch (e) {
      return Left(
        DataFailure('Failed to get services by category: ${e.message}'),
      );
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
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
    try {
      Query<Map<String, dynamic>> firestoreQuery = _firestore.collection(
        _collection,
      );

      // Add active filter (default to active only)
      if (isActive ?? true) {
        firestoreQuery = firestoreQuery.where('isActive', isEqualTo: true);
      }

      // Add category filter
      if (category != null && category.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category);
      }

      // Add minimum price filter
      if (minPrice != null) {
        firestoreQuery = firestoreQuery.where(
          'basePrice',
          isGreaterThanOrEqualTo: minPrice,
        );
      }

      // Add maximum price filter
      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where(
          'basePrice',
          isLessThanOrEqualTo: maxPrice,
        );
      }

      // Add maximum duration filter
      if (maxDuration != null) {
        firestoreQuery = firestoreQuery.where(
          'durationMinutes',
          isLessThanOrEqualTo: maxDuration,
        );
      }

      // Order by sort order
      firestoreQuery = firestoreQuery.orderBy('sortOrder');

      final querySnapshot = await firestoreQuery.get();

      List<ServiceModel> services = querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      // Filter by name/description query (client-side filtering)
      if (query != null && query.isNotEmpty) {
        services = services.where((service) {
          return service.name.toLowerCase().contains(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      return Right(services);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to search services: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getServicesByIds(
    List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        return const Right([]);
      }

      // Firestore 'in' query has a limit of 10 items
      if (ids.length > 10) {
        // Split into chunks and make multiple queries
        final List<ServiceModel> allServices = [];

        for (int i = 0; i < ids.length; i += 10) {
          final chunk = ids.skip(i).take(10).toList();
          final query = await _firestore
              .collection(_collection)
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          final services = query.docs
              .map((doc) => ServiceModel.fromFirestore(doc))
              .toList();

          allServices.addAll(services);
        }

        return Right(allServices);
      } else {
        final query = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: ids)
            .get();

        final services = query.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList();

        return Right(services);
      }
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to get services by IDs: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> createService(
    ServiceModel service,
  ) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final serviceWithId = service.copyWith(id: docRef.id);

      await docRef.set(serviceWithId.toMap());

      // Get the created service
      final createdDoc = await docRef.get();
      final createdService = ServiceModel.fromFirestore(createdDoc);

      return Right(createdService);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to create service: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> updateService(
    ServiceModel service,
  ) async {
    try {
      final docRef = _firestore.collection(_collection).doc(service.id);

      // Check if service exists
      final existingDoc = await docRef.get();
      if (!existingDoc.exists) {
        return const Left(DataFailure('Service not found'));
      }

      await docRef.update(service.toMap());

      // Get the updated service
      final updatedDoc = await docRef.get();
      final updatedService = ServiceModel.fromFirestore(updatedDoc);

      return Right(updatedService);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to update service: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to delete service: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ServiceModel>>> watchAllServices() {
    try {
      return _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map((snapshot) {
            final services = snapshot.docs
                .map((doc) => ServiceModel.fromFirestore(doc))
                .toList();
            return Right<Failure, List<ServiceModel>>(services);
          })
          .handleError((error) {
            if (error is FirebaseException) {
              return Left(
                DataFailure('Failed to watch services: ${error.message}'),
              );
            }
            return Left(DataFailure('Unexpected error: $error'));
          });
    } catch (e) {
      return Stream.value(
        Left(DataFailure('Failed to create services stream: $e')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<ServiceModel>>> watchServicesByCategory(
    String category,
  ) {
    try {
      return _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map((snapshot) {
            final services = snapshot.docs
                .map((doc) => ServiceModel.fromFirestore(doc))
                .toList();
            return Right<Failure, List<ServiceModel>>(services);
          })
          .handleError((error) {
            if (error is FirebaseException) {
              return Left(
                DataFailure(
                  'Failed to watch services by category: ${error.message}',
                ),
              );
            }
            return Left(DataFailure('Unexpected error: $error'));
          });
    } catch (e) {
      return Stream.value(
        Left(DataFailure('Failed to create services stream: $e')),
      );
    }
  }
}
