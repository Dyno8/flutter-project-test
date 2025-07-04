import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_profile_model.dart';

/// Abstract interface for user profile data source
abstract class UserProfileDataSource {
  Future<Either<Failure, UserProfileModel>> getUserProfile(String uid);
  Future<Either<Failure, UserProfileModel>> createUserProfile(UserProfileModel profile);
  Future<Either<Failure, UserProfileModel>> updateUserProfile(UserProfileModel profile);
  Future<Either<Failure, void>> deleteUserProfile(String uid);
  Future<Either<Failure, bool>> profileExists(String uid);
  Future<Either<Failure, String>> uploadProfileImage(String uid, String imagePath);
  Future<Either<Failure, List<UserProfileModel>>> getUsersByRole(UserRole role);
  Future<Either<Failure, List<UserProfileModel>>> searchUsers({
    String? query,
    UserRole? role,
    String? city,
    String? district,
  });
  Stream<Either<Failure, UserProfileModel>> watchUserProfile(String uid);
}

/// Implementation of user profile data source using Firebase
class FirebaseUserProfileDataSource implements UserProfileDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseUserProfileDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  static const String _collection = 'user_profiles';

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      
      if (!doc.exists) {
        return const Left(DataFailure('User profile not found'));
      }

      final profile = UserProfileModel.fromFirestore(doc);
      return Right(profile);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to get user profile: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> createUserProfile(UserProfileModel profile) async {
    try {
      final docRef = _firestore.collection(_collection).doc(profile.uid);
      
      // Check if profile already exists
      final existingDoc = await docRef.get();
      if (existingDoc.exists) {
        return const Left(DataFailure('User profile already exists'));
      }

      await docRef.set(profile.toMap());
      
      // Get the created profile
      final createdDoc = await docRef.get();
      final createdProfile = UserProfileModel.fromFirestore(createdDoc);
      
      return Right(createdProfile);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to create user profile: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> updateUserProfile(UserProfileModel profile) async {
    try {
      final docRef = _firestore.collection(_collection).doc(profile.uid);
      
      // Check if profile exists
      final existingDoc = await docRef.get();
      if (!existingDoc.exists) {
        return const Left(DataFailure('User profile not found'));
      }

      await docRef.update(profile.toMap());
      
      // Get the updated profile
      final updatedDoc = await docRef.get();
      final updatedProfile = UserProfileModel.fromFirestore(updatedDoc);
      
      return Right(updatedProfile);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to update user profile: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to delete user profile: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> profileExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return Right(doc.exists);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to check profile existence: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String uid, String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return const Left(DataFailure('Image file not found'));
      }

      // Create a reference to the file location
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      
      // Upload the file
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to upload image: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileModel>>> getUsersByRole(UserRole role) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: role.name)
          .get();

      final profiles = query.docs
          .map((doc) => UserProfileModel.fromFirestore(doc))
          .toList();

      return Right(profiles);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to get users by role: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileModel>>> searchUsers({
    String? query,
    UserRole? role,
    String? city,
    String? district,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _firestore.collection(_collection);

      // Add role filter
      if (role != null) {
        firestoreQuery = firestoreQuery.where('role', isEqualTo: role.name);
      }

      // Add city filter
      if (city != null && city.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('city', isEqualTo: city);
      }

      // Add district filter
      if (district != null && district.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('district', isEqualTo: district);
      }

      final querySnapshot = await firestoreQuery.get();
      
      List<UserProfileModel> profiles = querySnapshot.docs
          .map((doc) => UserProfileModel.fromFirestore(doc))
          .toList();

      // Filter by name query if provided (client-side filtering)
      if (query != null && query.isNotEmpty) {
        profiles = profiles.where((profile) {
          return profile.displayName.toLowerCase().contains(query.toLowerCase()) ||
                 (profile.bio?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }

      return Right(profiles);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to search users: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Either<Failure, UserProfileModel>> watchUserProfile(String uid) {
    try {
      return _firestore
          .collection(_collection)
          .doc(uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          return const Left(DataFailure('User profile not found'));
        }
        
        final profile = UserProfileModel.fromFirestore(doc);
        return Right(profile);
      }).handleError((error) {
        if (error is FirebaseException) {
          return Left(DataFailure('Failed to watch user profile: ${error.message}'));
        }
        return Left(DataFailure('Unexpected error: $error'));
      });
    } catch (e) {
      return Stream.value(Left(DataFailure('Failed to create profile stream: $e')));
    }
  }
}
