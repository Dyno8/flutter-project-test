import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'base_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

class UserRepository extends BaseRepository<UserModel> {
  @override
  String get collectionName => AppConstants.usersCollection;

  @override
  UserModel fromFirestore(DocumentSnapshot doc) {
    return UserModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toMap(UserModel model) {
    return model.toMap();
  }

  // User-specific methods
  Future<Either<Failure, UserModel>> createUser(UserModel user) async {
    try {
      // Use the user's UID as the document ID
      await FirebaseService().setDocument(
        collectionName,
        user.uid,
        user.toMap(),
      );

      final doc = await FirebaseService().getDocument(collectionName, user.uid);
      final createdUser = fromFirestore(doc);
      return Right(createdUser);
    } catch (e) {
      return Left(ServerFailure('Failed to create user: $e'));
    }
  }

  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final currentUser = FirebaseService().currentUser;
      if (currentUser == null) {
        return const Right(null);
      }

      final doc = await FirebaseService().getDocument(
        collectionName,
        currentUser.uid,
      );
      if (!doc.exists) {
        return const Right(null);
      }

      final user = fromFirestore(doc);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Failed to get current user: $e'));
    }
  }

  Future<Either<Failure, UserModel>> updateUser(UserModel user) async {
    try {
      final updateData = user.copyWith(updatedAt: DateTime.now()).toMap();
      await FirebaseService().setDocument(
        collectionName,
        user.uid,
        updateData,
        merge: true,
      );

      final doc = await FirebaseService().getDocument(collectionName, user.uid);
      final updatedUser = fromFirestore(doc);
      return Right(updatedUser);
    } catch (e) {
      return Left(ServerFailure('Failed to update user: $e'));
    }
  }

  Future<Either<Failure, UserModel?>> getUserByEmail(String email) async {
    try {
      final query = where('email', email);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }

      final user = fromFirestore(snapshot.docs.first);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Failed to get user by email: $e'));
    }
  }

  Future<Either<Failure, UserModel?>> getUserByPhone(String phone) async {
    try {
      final query = where('phone', phone);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }

      final user = fromFirestore(snapshot.docs.first);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Failed to get user by phone: $e'));
    }
  }

  Future<Either<Failure, List<UserModel>>> getUsersByRole(String role) async {
    try {
      final query = where('role', role);
      final snapshot = await query.get();

      final users = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure('Failed to get users by role: $e'));
    }
  }

  Future<Either<Failure, void>> updateFCMToken(
    String userId,
    String token,
  ) async {
    try {
      await FirebaseService().updateDocument(collectionName, userId, {
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update FCM token: $e'));
    }
  }

  Future<Either<Failure, void>> updateLastSeen(String userId) async {
    try {
      await FirebaseService().updateDocument(collectionName, userId, {
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update last seen: $e'));
    }
  }

  // Real-time listeners
  Stream<Either<Failure, UserModel?>> listenToCurrentUser() {
    try {
      final currentUser = FirebaseService().currentUser;
      if (currentUser == null) {
        return Stream.value(const Right(null));
      }

      return FirebaseService()
          .listenToDocument(collectionName, currentUser.uid)
          .map((doc) {
            if (!doc.exists) {
              return const Right(null);
            }
            final user = fromFirestore(doc);
            return Right(user);
          });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to listen to current user: $e')),
      );
    }
  }

  Stream<Either<Failure, List<UserModel>>> listenToUsersByRole(String role) {
    try {
      final query = where('role', role);
      return FirebaseService()
          .listenToCollection(collectionName, query: query)
          .map((snapshot) {
            final users = snapshot.docs
                .map((doc) => fromFirestore(doc))
                .toList();
            return Right(users);
          });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to listen to users by role: $e')),
      );
    }
  }

  // Validation methods
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    // Vietnamese phone number validation
    return RegExp(r'^(\+84|84|0)(3|5|7|8|9)([0-9]{8})$').hasMatch(phone);
  }

  bool isValidName(String name) {
    return name.trim().length >= 2 && name.trim().length <= 50;
  }

  // Search methods
  Future<Either<Failure, List<UserModel>>> searchUsers(
    String searchTerm, {
    String? role,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseService().firestore
          .collection(collectionName);

      if (role != null) {
        query = query.where('role', isEqualTo: role);
      }

      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that searches by name prefix
      query = query
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .limit(limit);

      final snapshot = await query.get();
      final users = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure('Failed to search users: $e'));
    }
  }
}
