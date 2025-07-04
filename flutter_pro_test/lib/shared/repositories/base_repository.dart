import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../../core/errors/failures.dart';

abstract class BaseRepository<T> {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Abstract methods to be implemented by concrete repositories
  String get collectionName;
  T fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toMap(T model);
  
  // Common CRUD operations
  Future<Either<Failure, T>> create(T model) async {
    try {
      final data = toMap(model);
      final docRef = await _firebaseService.addDocument(collectionName, data);
      final doc = await docRef.get();
      final createdModel = fromFirestore(doc);
      return Right(createdModel);
    } catch (e) {
      return Left(ServerFailure('Failed to create document: $e'));
    }
  }
  
  Future<Either<Failure, T>> getById(String id) async {
    try {
      final doc = await _firebaseService.getDocument(collectionName, id);
      if (!doc.exists) {
        return Left(ServerFailure('Document not found'));
      }
      final model = fromFirestore(doc);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure('Failed to get document: $e'));
    }
  }
  
  Future<Either<Failure, List<T>>> getAll({
    Query<Map<String, dynamic>>? query,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> baseQuery = 
          _firebaseService.firestore.collection(collectionName);
      
      if (query != null) {
        baseQuery = query;
      }
      
      if (limit != null) {
        baseQuery = baseQuery.limit(limit);
      }
      
      final snapshot = await baseQuery.get();
      final models = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(models);
    } catch (e) {
      return Left(ServerFailure('Failed to get documents: $e'));
    }
  }
  
  Future<Either<Failure, T>> update(String id, Map<String, dynamic> data) async {
    try {
      await _firebaseService.updateDocument(collectionName, id, data);
      final doc = await _firebaseService.getDocument(collectionName, id);
      final updatedModel = fromFirestore(doc);
      return Right(updatedModel);
    } catch (e) {
      return Left(ServerFailure('Failed to update document: $e'));
    }
  }
  
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _firebaseService.deleteDocument(collectionName, id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete document: $e'));
    }
  }
  
  // Real-time listeners
  Stream<Either<Failure, T>> listenToDocument(String id) {
    try {
      return _firebaseService
          .listenToDocument(collectionName, id)
          .map((doc) {
        if (!doc.exists) {
          return Left(ServerFailure('Document not found'));
        }
        final model = fromFirestore(doc);
        return Right(model);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to document: $e')));
    }
  }
  
  Stream<Either<Failure, List<T>>> listenToCollection({
    Query<Map<String, dynamic>>? query,
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> baseQuery = 
          _firebaseService.firestore.collection(collectionName);
      
      if (query != null) {
        baseQuery = query;
      }
      
      if (limit != null) {
        baseQuery = baseQuery.limit(limit);
      }
      
      return _firebaseService
          .listenToCollection(collectionName, query: baseQuery)
          .map((snapshot) {
        final models = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        return Right(models);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to collection: $e')));
    }
  }
  
  // Batch operations
  Future<Either<Failure, void>> batchWrite(
    List<BatchOperation<T>> operations,
  ) async {
    try {
      final batch = _firebaseService.batch();
      
      for (final operation in operations) {
        final docRef = _firebaseService.firestore
            .collection(collectionName)
            .doc(operation.id);
            
        switch (operation.type) {
          case BatchOperationType.create:
          case BatchOperationType.set:
            batch.set(docRef, operation.data!);
            break;
          case BatchOperationType.update:
            batch.update(docRef, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to execute batch operation: $e'));
    }
  }
  
  // Query helpers
  Query<Map<String, dynamic>> where(
    String field,
    dynamic isEqualTo, {
    dynamic isNotEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic>? arrayContainsAny,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool? isNull,
  }) {
    return _firebaseService.firestore.collection(collectionName).where(
      field,
      isEqualTo: isEqualTo,
      isNotEqualTo: isNotEqualTo,
      isLessThan: isLessThan,
      isLessThanOrEqualTo: isLessThanOrEqualTo,
      isGreaterThan: isGreaterThan,
      isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      arrayContains: arrayContains,
      arrayContainsAny: arrayContainsAny,
      whereIn: whereIn,
      whereNotIn: whereNotIn,
      isNull: isNull,
    );
  }
  
  Query<Map<String, dynamic>> orderBy(
    String field, {
    bool descending = false,
  }) {
    return _firebaseService.firestore
        .collection(collectionName)
        .orderBy(field, descending: descending);
  }
}

// Either type for error handling
abstract class Either<L, R> {
  const Either();
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}

// Batch operation types
enum BatchOperationType { create, set, update, delete }

class BatchOperation<T> {
  final String id;
  final BatchOperationType type;
  final Map<String, dynamic>? data;
  
  const BatchOperation({
    required this.id,
    required this.type,
    this.data,
  });
  
  factory BatchOperation.create(String id, Map<String, dynamic> data) {
    return BatchOperation(id: id, type: BatchOperationType.create, data: data);
  }
  
  factory BatchOperation.set(String id, Map<String, dynamic> data) {
    return BatchOperation(id: id, type: BatchOperationType.set, data: data);
  }
  
  factory BatchOperation.update(String id, Map<String, dynamic> data) {
    return BatchOperation(id: id, type: BatchOperationType.update, data: data);
  }
  
  factory BatchOperation.delete(String id) {
    return BatchOperation(id: id, type: BatchOperationType.delete);
  }
}
